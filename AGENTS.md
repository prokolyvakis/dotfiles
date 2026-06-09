# Agents

Instructions for AI coding agents working on this repository.

## Context

This is a personal dotfiles repo using chezmoi + Ansible. Read CLAUDE.md first for architecture and conventions.

## Before Making Changes

1. Read the relevant files before modifying them.
2. Run `make lint` after any Ansible or YAML changes.
3. Run `chezmoi apply --dry-run --verbose` after any chezmoi template changes.
4. Run `make docker-test` for significant changes to verify Ubuntu compatibility.

## Chezmoi

- Source directory is `home/`, not the default `~/.local/share/chezmoi`.
- `private_dot_shell/` maps to `~/.shell/` (private directory, 700 permissions).
- `private_dot_config/private_nvim/` maps to `~/.config/nvim/`.
- Templates (`.tmpl` files) use Go template syntax with chezmoi data.
- OS detection: `{{ if eq .chezmoi.os "darwin" }}` / `{{ if eq .chezmoi.os "linux" }}`.
- User data defined in `home/.chezmoi.yaml.tmpl`: `.name`, `.email`.

## Ansible

- Playbook entry point: `ansible/playbook.yml`.
- Roles: preflight, packages, shell, tmux, fonts, node, neovim.
- OS-specific variables: `ansible/group_vars/all/macos.yml` and `ubuntu.yml`.
- Use `community.general.*` FQCN for Homebrew modules.
- Never use `failed_when: false` without a specific condition.
- Pin `version:` on all `ansible.builtin.git` tasks (avoid `latest[git]` lint error).
- Some repos use `main`, not `master` — check before hardcoding branch names.

## Shell Modules

- Files in `home/private_dot_shell/` are sourced by both bash and zsh.
- Use `# shellcheck shell=bash` header, not `#!/bin/sh` (these files use bash features).
- The oh-my-zsh `git` plugin is intentionally excluded — `git.sh` is the single source of truth for git aliases.
- macOS-only code must be guarded with chezmoi templates (`macos.sh.tmpl`).
- Hardcoded paths like `/usr/bin/curl` break cross-platform — use bare command names.

## Common Mistakes to Avoid

- Adding `#!/bin/sh` to shell modules that use bash syntax.
- Using `failed_when: false` instead of specific error conditions in Ansible.
- Forgetting `version:` on git module tasks.
- Adding the oh-my-zsh `git` plugin back (it conflicts with `~/.shell/git.sh`).
- Hardcoding `/usr/sbin/` or `/usr/bin/` paths in cross-platform shell files.
- Using `ls -G` (macOS-only) without an OS guard — Linux uses `ls --color`.
