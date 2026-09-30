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
- **`scripts/`** — Testing utilities (Docker smoke test).

## Usage

```bash
make help        # Show all targets
make dotfiles    # Apply dotfiles only (chezmoi)
make system      # Run system provisioning only (ansible)
make apply       # Both
make lint        # Lint ansible + yaml
make docker-test # Run full setup in a clean Ubuntu container
```

## AI agents

`home/.chezmoidata.yaml` declares the Claude Code / Codex profile: marketplaces,
plugins, global skills (vercel-labs `skills` CLI), npm and pipx tools, and
peon-ping. `make system` runs the `agents` role (macOS) which installs what is
missing through the native managers; `make dotfiles` places `~/.claude`
(CLAUDE.md, RTK.md, hooks, status line, personal skills) and merges the managed
keys into `~/.claude/settings.json` without touching keys written by Claude Code
or peon-ping. Logins (claude.ai connectors, MCP OAuth, Codex) and the claude.ai
"synced" plugins are not reproduced; sign in after the first run.

```bash
cd ansible && ansible-playbook playbook.yml --tags agents --diff   # agents role only
```

## Editor

Uses [AstroNvim](https://astronvim.com/) with AI completion via [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) using Claude (Anthropic). Set `ANTHROPIC_API_KEY` in your environment, then use `:CodeCompanionChat` in nvim.


## CI

GitHub Actions runs on every push/PR:
- `yamllint` + `ansible-lint` + syntax-check (Ubuntu)
- `chezmoi verify` (macOS + Ubuntu matrix)
