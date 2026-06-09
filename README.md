# dotfiles

Personal machine setup for macOS and Ubuntu. Uses [chezmoi](https://www.chezmoi.io/) for dotfiles and [Ansible](https://www.ansible.com/) for system provisioning.

## Quick Start

```bash
# Clone
git clone git@github.com:prokolyvakis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install prerequisites
make install

# Full setup (packages + dotfiles)
make apply
```

## Architecture

- **`home/`** — chezmoi source directory. Manages dotfiles (zshrc, bashrc, gitconfig), modular shell configs (`~/.shell/*.sh`), and AstroNvim config.
- **`ansible/`** — Ansible playbook with roles for packages, zsh, tmux, fonts, nvm, and neovim.
- **`scripts/`** — One-time migration script from the old structure.

## Usage

```bash
make help        # Show all targets
make dotfiles    # Apply dotfiles only (chezmoi)
make system      # Run system provisioning only (ansible)
make apply       # Both
make lint        # Lint ansible + yaml
make docker-test # Run full setup in a clean Ubuntu container
```

## Editor

Uses [AstroNvim](https://astronvim.com/) with AI completion via [copilot.lua](https://github.com/zbirenbaum/copilot.lua). On first launch, run `:Copilot auth` to authenticate.

> **Migration note:** Previously used SpaceVim. Run `make migrate` to clean up old SpaceVim files.

## CI

GitHub Actions runs on every push/PR:
- `yamllint` + `ansible-lint` + syntax-check (Ubuntu)
- `chezmoi verify` (macOS + Ubuntu matrix)
