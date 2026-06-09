# Dotfiles Project

Hybrid setup: **chezmoi** for dotfiles, **Ansible** for system provisioning.

- `home/` — chezmoi source directory. All dotfiles and `~/.shell/*.sh` modules.
- `ansible/` — Ansible playbook with roles: preflight, packages, shell, tmux, fonts, node, neovim.
- `scripts/` — Docker smoke test.

## Conventions

- chezmoi templates use `.tmpl` suffix. OS-conditional logic via `{{ if eq .chezmoi.os "darwin" }}`.
- chezmoi source is `home/`, not the default `~/.local/share/chezmoi`.
- `private_dot_shell/` maps to `~/.shell/`, `private_dot_config/private_nvim/` maps to `~/.config/nvim/`.
- Shell modules are sourced by both zshrc and bashrc. Use `# shellcheck shell=bash` header (not `#!/bin/sh`).
- Git aliases: shell wrappers (`alias gst='git status'`) go in `git.sh`. Git-internal aliases (`l = log ...`) stay in `dot_gitconfig.tmpl`. The oh-my-zsh `git` plugin is excluded to avoid conflicts.
- Ansible roles use FQCN (`ansible.builtin.*`, `community.general.*`). Role variables must be prefixed with the role name.
- No `become: yes` on Homebrew tasks. Only `become: true` on apt tasks.
- No `failed_when: false` — use specific conditions instead.
- Pin `version:` on all `ansible.builtin.git` tasks. Some repos use `main`, not `master`.
- No hardcoded paths like `/usr/bin/curl` — use bare command names for cross-platform.
- macOS-only code must be in chezmoi-guarded templates.

## Testing

- `make lint` — yamllint + ansible-lint (must pass at production profile).
- `make docker-test` — full Ubuntu 24.04 smoke test (packages + chezmoi + idempotence).
- CI runs on push/PR: lint on Ubuntu, chezmoi template verify on both macOS and Ubuntu.

## Workflow

- Dotfile changes: edit in `home/`, run `chezmoi apply`.
- Package changes: edit `ansible/group_vars/all/{macos,ubuntu}.yml`, run `make system`.
- After any change: run `make lint` before committing.
