# Claude Code Global Config

## Behavioral Principles

These rules apply in every session, every project.

- Think before coding: read the full context before writing
- Simplicity: fewest tokens, fewest files, least surprise
- Surgical changes: edit only what the task requires
- Goal-driven: verify each action serves the stated goal

## Workflow

- Substantive work (a bug, a feature, research, a review, a handoff): invoke the
  `samari:samari` skill and follow it. Samari is the default owner of the task:
  it reads the project's own instructions, loads only the relevant references,
  selects one installed specialist method or agent per activity when that fits
  the current bottleneck, delegates when useful, and records observed evidence.
  The installed marketplace is a library of methods and tools under that owner,
  not a set of competing workflows; do not nest a complete workflow plugin
  (brainstorm/plan/subagent cycles, the full feature workflow, the publishing
  review command, a loop) inside a Samari task.
- An explicit request for a complete workflow by name (`/feature-dev`,
  `/code-review`, `/ralph-loop`, a Superpowers plan cycle) is the user's choice:
  that workflow owns its declared scope and lifecycle; project authority and
  safety controls stay in force; do not replace it with Samari or add Samari's
  duplicate sequence around it. A matching catalog name is not such a request.
- Trivial, well-specified changes stay direct: no delegation, no planning
  documents, no specialist, no review ceremony.
- The per-plugin map (which plugin owns which activity, how it is invoked, what
  its hooks do, how Codex is dispatched) is in `~/.claude/coordination.md`; read
  it when choosing between installed capabilities, not for every task. Shared
  engineering methodology (design interviews, architecture deepening, triage,
  specs, tickets) lives in the Samari bundle; do not look for it under
  ~/.claude/skills.
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
