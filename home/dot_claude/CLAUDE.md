# Claude Code Global Config

## Behavioral Principles

These rules apply in every session, every project.

- Think before coding: read the full context before writing
- Simplicity: fewest tokens, fewest files, least surprise
- Surgical changes: edit only what the task requires
- Goal-driven: verify each action serves the stated goal

## Workflow

- Substantive work (a bug, a feature, research, a review, a handoff): invoke the
  `samari:samari` skill and follow it. It reads the project's own instructions,
  loads only the relevant references, delegates when useful, and records
  observed evidence. Shared engineering methodology (design interviews,
  architecture deepening, triage, specs, tickets) lives in that bundle; do not
  look for it under ~/.claude/skills.
- Commits: always invoke `samari:commit` before writing or executing a git
  commit message.
- Output compression: `rtk <command>` is installed for noisy inspection output
  (listings, logs, long test output). Call it explicitly when a result would be
  large; never route an acceptance check through it, because its filtered
  output is not evidence of the real exit status.

## Tools

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
