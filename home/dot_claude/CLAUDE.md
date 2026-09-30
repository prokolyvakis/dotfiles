# Claude Code Global Config

## Behavioral Principles

These rules apply in every session, every project.

- Think before coding: read the full context before writing
- Simplicity: fewest tokens, fewest files, least surprise
- Surgical changes: edit only what the task requires
- Goal-driven: verify each action serves the stated goal

## Agent skills

Universal discipline skills installed in ~/.claude/skills/

Project-specific skills live in each project's .claude/skills/ and are discovered automatically when working in that project.

## Tools

@RTK.md
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# commit
- **samari:commit** (Samari plugin) - conventional commit message style guide. Trigger: any git commit operation.
Always invoke the Skill tool with `skill: "samari:commit"` before writing or executing any git commit message.
