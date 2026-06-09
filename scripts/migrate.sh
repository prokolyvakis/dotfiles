#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
OLD_SYMLINKS=(bash_profile bashrc zshrc gitconfig gitignore)
CHEZMOI_SOURCE="$DOTFILES_DIR/home"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; }

echo "=== Dotfiles Migration ==="
echo ""

# Step 1: Check prerequisites
echo "--- Step 1: Prerequisites ---"
if ! command -v chezmoi &>/dev/null; then
  fail "chezmoi is not installed. Run: make install"
  exit 1
fi
info "chezmoi found: $(chezmoi --version)"

if ! command -v ansible &>/dev/null; then
  fail "ansible is not installed. Install it first."
  exit 1
fi
info "ansible found: $(ansible --version | head -1)"
echo ""

# Step 2: Back up and remove old symlinks
echo "--- Step 2: Old symlinks ---"
needs_sudo=false
mkdir -p "$BACKUP_DIR"

for dotfile in "${OLD_SYMLINKS[@]}"; do
  target="$HOME/.$dotfile"

  if [ -L "$target" ]; then
    link_target=$(readlink "$target")
    if [[ "$link_target" == *".dotfiles/files/link/"* ]]; then
      # Check if root-owned
      owner=$(stat -f '%Su' "$target" 2>/dev/null || stat -c '%U' "$target" 2>/dev/null)
      if [ "$owner" = "root" ]; then
        needs_sudo=true
        warn "$target is root-owned symlink → will sudo rm"
      fi
      # Back up the link target content
      if ! cp -L "$target" "$BACKUP_DIR/$dotfile" 2>/dev/null; then
        warn "Could not back up $target"
      fi
    fi
  elif [ -f "$target" ]; then
    if ! cp "$target" "$BACKUP_DIR/$dotfile" 2>/dev/null; then
      warn "Could not back up $target"
    fi
  fi
done

# Verify critical files were backed up before proceeding to deletion
for critical in gitconfig zshrc; do
  if [ -f "$HOME/.$critical" ] && [ ! -f "$BACKUP_DIR/$critical" ]; then
    fail "Failed to back up ~/.$critical — aborting to prevent data loss"
    exit 1
  fi
done

info "Backed up to: $BACKUP_DIR"

if $needs_sudo; then
  echo ""
  echo "Some symlinks are owned by root and need sudo to remove."
  read -r -p "Proceed with sudo rm? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

for dotfile in "${OLD_SYMLINKS[@]}"; do
  target="$HOME/.$dotfile"
  if [ -L "$target" ]; then
    link_target=$(readlink "$target")
    if [[ "$link_target" == *".dotfiles/files/link/"* ]]; then
      owner=$(stat -f '%Su' "$target" 2>/dev/null || stat -c '%U' "$target" 2>/dev/null)
      if [ "$owner" = "root" ]; then
        sudo rm "$target"
      else
        rm "$target"
      fi
      info "Removed old symlink: $target"
    fi
  fi
done
echo ""

# Step 3: Back up SpaceVim if present
echo "--- Step 3: SpaceVim ---"
if [ -d "$HOME/.SpaceVim" ]; then
  mv "$HOME/.SpaceVim" "$BACKUP_DIR/SpaceVim"
  info "Backed up ~/.SpaceVim"
else
  info "No SpaceVim installation found (skip)"
fi

if [ -d "$HOME/.SpaceVim.d" ]; then
  mv "$HOME/.SpaceVim.d" "$BACKUP_DIR/SpaceVim.d"
  info "Backed up ~/.SpaceVim.d"
fi
echo ""

# Step 4: Apply chezmoi
echo "--- Step 4: chezmoi apply ---"
chezmoi init --source="$CHEZMOI_SOURCE"
chezmoi apply --source="$CHEZMOI_SOURCE"
info "chezmoi applied"
echo ""

# Step 5: Verify
echo "--- Step 5: Verify ---"
pass=true

for dotfile in bash_profile bashrc zshrc gitconfig gitignore_global; do
  target="$HOME/.$dotfile"
  if [ -f "$target" ] || [ -L "$target" ]; then
    info "$target exists"
  else
    fail "$target missing!"
    pass=false
  fi
done

if [ -d "$HOME/.shell" ]; then
  info "~/.shell/ directory exists"
  for f in aliases.sh git.sh networking.sh node.sh; do
    if [ -f "$HOME/.shell/$f" ]; then
      info "  ~/.shell/$f exists"
    else
      fail "  ~/.shell/$f missing!"
      pass=false
    fi
  done
else
  fail "~/.shell/ directory missing!"
  pass=false
fi

if [ -f "$HOME/.config/nvim/init.lua" ]; then
  info "~/.config/nvim/init.lua exists (AstroNvim)"
elif [ -d "$HOME/.config/nvim" ]; then
  warn "~/.config/nvim/ exists but no init.lua (existing nvim config — not overwritten)"
else
  fail "~/.config/nvim/ not created by chezmoi — check that private_dot_config/private_nvim/ exists in the chezmoi source"
  pass=false
fi
echo ""

# Step 6: Summary
echo "=== Migration Summary ==="
if $pass; then
  info "Migration complete!"
else
  fail "Migration finished with issues (see above)"
  echo ""
  echo "Backed up to: $BACKUP_DIR"
  exit 1
fi
echo ""
echo "Backed up to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Run 'make system' to install packages and shell setup"
echo "  2. Open a new terminal to verify your shell works"
echo "  3. Run 'nvim' and execute :Copilot auth for AI completion"
echo "  4. Once verified, old files can be deleted from the repo:"
echo "     files/ tasks/ group_vars/ main.yml inventory ansible.cfg"
echo "     aux_scripts/ .travis.yml"
