# Dotfiles Project

## Architecture

Hybrid setup: **chezmoi** for dotfiles, **Ansible** for system provisioning.

- `home/` — chezmoi source directory. All dotfiles and `~/.shell/*.sh` modules.
- `ansible/` — Ansible playbook with roles: preflight, packages, shell, tmux, fonts, node, neovim.
- `scripts/` — Docker smoke test.

## Key Conventions

- chezmoi templates use `.tmpl` suffix. OS-conditional logic via `{{ if eq .chezmoi.os "darwin" }}`.
- Shell modules in `home/private_dot_shell/` are sourced by both zshrc and bashrc.
- Shell files use `# shellcheck shell=bash` (not `#!/bin/sh`) — they are sourced, never executed directly.
- Git aliases: shell wrappers (`alias gst='git status'`) go in `git.sh`. Git-internal aliases (`l = log ...`) stay in `dot_gitconfig.tmpl`.
- Ansible roles use FQCN (`ansible.builtin.*`, `community.general.*`).
- Ansible role variables must be prefixed with the role name (e.g., `shell_omz_plugins`, `neovim_version`).
- No `become: yes` on Homebrew tasks. Only `become: true` on apt tasks.
- No `failed_when: false` — use specific conditions instead.

## Testing

- `make lint` — yamllint + ansible-lint (must pass at production profile)
- `make docker-test` — full Ubuntu 24.04 smoke test (packages + chezmoi + idempotence)
- CI runs on push/PR: lint on Ubuntu, chezmoi template verify on both macOS and Ubuntu.

## Workflow

- Dotfile changes: edit in `home/`, run `chezmoi apply`.
- Package changes: edit `ansible/group_vars/all/{macos,ubuntu}.yml`, run `make system`.
- After any change: run `make lint` before committing.
