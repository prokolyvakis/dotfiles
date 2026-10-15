# Dotfiles Project

Hybrid setup: **chezmoi** for dotfiles, **Ansible** for system provisioning.

- `home/` — chezmoi source directory. All dotfiles and `~/.shell/*.sh` modules.
- `ansible/` — Ansible playbook with roles: preflight, packages, shell, tmux, fonts, node, neovim, agents (macOS), security (macOS).
- `scripts/` — Docker smoke test, settings-merger test, coordination-map test.

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
- Agent tooling (Claude/Codex plugins, npm/pipx tools) is declared once in `home/.chezmoidata.yaml`; the `agents` role installs it and `home/dot_claude/modify_settings.json.tmpl` merges the managed keys into `~/.claude/settings.json`. Never manage that file whole: Claude Code and peon-ping write to it.
- Defensive security scanners are declared under `security:` in `home/.chezmoidata.yaml` and installed by the `security` role (Homebrew, macOS); add a scanner there, not in a role task.

## Testing

- `make lint` — yamllint + ansible-lint (must pass at production profile).
- `make test` — runs the rendered `modify_settings.json` merger in a synthetic home: invalid input leaves the file untouched, only owned keys change, explicit disables and unknown entries survive, repeated apply is byte-stable, and re-applying an earlier profile changes only its owned value while keeping concurrent user edits. It also runs the coordination-map test: every plugin declared in `home/.chezmoidata.yaml` has exactly one row in the managed-mode table of `home/dot_claude/coordination.md`.
- `make docker-test` — full Ubuntu 24.04 smoke test (packages + chezmoi + idempotence).
- CI runs on push/PR: lint on Ubuntu; chezmoi template verify, the merger test and the coordination-map test on both macOS and Ubuntu.

## Workflow

- Dotfile changes: edit in `home/`, run `chezmoi apply`.
- Package changes: edit `ansible/group_vars/all/{macos,ubuntu}.yml`, run `make system`.
- Agent plugin/skill changes: edit `home/.chezmoidata.yaml` and add the plugin's row to `home/dot_claude/coordination.md`; run `make test`, then `chezmoi apply --dry-run --verbose` to confirm the model and unrelated settings are unchanged, then `make system` and `make dotfiles`.
- The `agents` role runs on macOS only; its Ubuntu entries (e.g. pipx `uv`) take effect once the role runs there.
- After any change: run `make lint` before committing.
