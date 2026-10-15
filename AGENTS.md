# Agents

Read CLAUDE.md first — it has all architecture, conventions, and testing instructions.

## Before Making Changes

1. Read the relevant files before modifying them.
2. Run `make lint` after any Ansible or YAML changes.
3. Run `chezmoi apply --dry-run --verbose` after any chezmoi template changes, and before applying, so the diff shows nothing unintended (for example the Claude model in `settings.json`).
4. Run `make test` after agent-profile changes (settings merger and coordination map).
5. Run `make docker-test` for significant changes to verify Ubuntu compatibility.

## Common Mistakes to Avoid

- Adding `#!/bin/sh` to shell modules that use bash syntax.
- Using `failed_when: false` instead of specific error conditions in Ansible.
- Forgetting `version:` on `ansible.builtin.git` tasks.
- Adding the oh-my-zsh `git` plugin back (it conflicts with `~/.shell/git.sh`).
- Hardcoding `/usr/sbin/` or `/usr/bin/` paths in cross-platform shell files.
- Using `ls -G` (macOS-only) without an OS guard — Linux uses `ls --color`.
