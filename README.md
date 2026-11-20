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
- **`ansible/`** — Ansible playbook with roles preflight, packages, shell, tmux, fonts, node (Ubuntu), neovim and agents (macOS).
- **`scripts/`** — Tests: the Docker smoke test, the settings-merger test and the coordination-map test.

## Usage

```bash
make help        # Show all targets
make dotfiles    # Apply dotfiles only (chezmoi)
make system      # Run system provisioning only (ansible)
make apply       # Both
make lint        # Lint ansible + yaml
make test        # Settings merger (synthetic home) and coordination-map coverage
make docker-test # Run full setup in a clean Ubuntu container
```

## AI agents

`home/.chezmoidata.yaml` declares the Claude Code / Codex profile: marketplaces,
plugins, the Claude model, npm and pipx tools (including Omnigent), and
peon-ping. `make system` runs the `agents` role (macOS only for now) which
installs what is missing through the native managers; Ubuntu gets the
prerequisites (pipx, bubblewrap) but not the role yet; `make dotfiles` places `~/.claude`
(CLAUDE.md, coordination.md, status line) and merges the managed
keys into `~/.claude/settings.json` without touching keys written by Claude Code
or peon-ping. The merger refuses unparsable or wrongly typed input instead of
replacing it, keeps an explicit plugin disable, skips a local marketplace whose
directory is missing, and prints a before/after record of the owned values it
changed. Logins (claude.ai connectors, MCP OAuth, Codex) and the claude.ai
"synced" plugins are not reproduced; sign in after the first run.

`~/.claude/CLAUDE.md` holds the global working rules (which installed workflow
owns substantive work, worker mode for delegated assignments, commits) and
`~/.claude/coordination.md` records how the installed marketplace plugins
compose, standalone and when Omnigent dispatches the workers (loaded on demand,
not on every task). `make test` checks that every declared plugin has exactly
one row in that map.

The language-server plugins need their servers on `PATH`: `clangd` comes with
Xcode's command-line tools, and on macOS the `packages` role installs rustup
(keg-only, added to `PATH` by `~/.shell/path.sh`) with the stable toolchain and
`rust-analyzer`. Ubuntu does not get the Rust toolchain yet.

```bash
cd ansible && ansible-playbook playbook.yml --tags agents --diff   # agents role only
```

## Local models

`home/.chezmoidata.yaml` has a `local_models` block: a local runtime (Ollama),
one open-weight coding model (the list takes more), and the context length
the runtime must be started with. It changes no default. The Claude model in
`settings.json` and Codex's `config.toml` are untouched, and nothing switches
to a local model on its own.

Two launchers, `~/.local/bin/claude-local` and `~/.local/bin/codex-local`,
start one session on a local model:

```sh
OLLAMA_CONTEXT_LENGTH=64000 ollama serve     # once, in another terminal
claude-local                                 # default family
codex-local -f qwen exec "..."               # a family by name
```

`codex-local` starts Codex with connected apps off for that session. A local
model is sent every app tool's full definition up front, which alone is larger
than the context; plugins stay on.

Each refuses to start, with exit status 1, when the runtime does not answer or
the model is not pulled; it never falls back to another model. The `agents`
role installs the runtime, pulls missing weights when the runtime is running,
and keeps the Claude Code and Codex installers in Homebrew's cache, because
none of these can be downloaded during an outage. `make test` checks the
refusals with a fake runtime.

## Security scanners

`home/.chezmoidata.yaml` also declares a `security` set of defensive scanners —
Semgrep (static analysis), OSV-Scanner (dependencies), Gitleaks (secrets),
Trivy (containers and config), and zizmor and actionlint (GitHub Actions
workflows). The `security` role installs them with Homebrew on macOS; they are
mainstream tools and carry no credentials. Each tool's exact version is
recorded when it runs, not pinned here. Cisco's skill-scanner, a static scanner
for agent skill packages, is a Python tool, so it is pinned in the `pipx` list
and installed by the `agents` role. Ubuntu installation is wired
during the full container test.

```bash
cd ansible && ansible-playbook playbook.yml --tags security --diff  # scanners only
```

## Editor

Uses [AstroNvim](https://astronvim.com/) with AI completion via [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) using Claude (Anthropic). Set `ANTHROPIC_API_KEY` in your environment, then use `:CodeCompanionChat` in nvim.


## CI

GitHub Actions runs on every push/PR:
- `yamllint` + `ansible-lint` + syntax-check (Ubuntu)
- chezmoi template verify, the settings-merger test and the coordination-map test (macOS + Ubuntu matrix)
