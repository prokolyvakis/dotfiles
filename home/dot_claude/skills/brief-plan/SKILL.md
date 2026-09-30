---
name: brief-plan
description: Generates a human-readable BRIEF.md from GSD planning artifacts (SPEC.md, CONTEXT.md, and PLAN files) for a given phase. Follows Diátaxis documentation principles — Overview, Why (Explanation prose), What (Reference), How (How-to narrative), Done When. Use when the user types /brief-plan, asks to explain a phase in plain English, or wants a human-readable summary of a GSD phase.
---

# Brief Plan

Reads the GSD planning artifacts for a phase and writes a `NN-BRIEF.md` into the phase directory — structured for a human developer, not an agent executor.

## Quick start

```
/brief-plan 1
```

Resolves `.planning/phases/01-*/`, reads SPEC.md + CONTEXT.md + all `01-NN-PLAN.md` files, writes `01-BRIEF.md`.

## Workflow

1. **Resolve phase directory** — find `.planning/phases/{NN}-*/`
2. **Read source files** in this order:
   - `NN-SPEC.md` — requirements and acceptance criteria
   - `NN-CONTEXT.md` — design decisions from discuss-phase
   - All `NN-NN-PLAN.md` files — execution waves
3. **Write `NN-BRIEF.md`** into the phase directory

## BRIEF.md Structure

### Overview (1 paragraph)
One sentence on the user problem this phase solves. One sentence on what it delivers. No jargon, no file names.

### Why
Prose in the Diátaxis Explanation style: discursive, connected, willing to say "because". Covers:
- What was broken or missing that makes this phase necessary
- The key design decisions and why they were made (from CONTEXT.md)
- Constraints that shaped the approach
- Trade-offs consciously accepted

Write as flowing prose. 3–5 paragraphs. No bullet lists in this section. Connect ideas with transitions. Explain *why*, not *what*.

### What
Reference-style: neutral, factual, structured.
- Table: file/component → one-line purpose (all files touched across all plans)
- New endpoints, screens, or services introduced
- Acceptance criteria rewritten as present-tense statements ("POST /bookings creates a booking in AWAITING_PAYMENT")

### How
One short paragraph per plan wave:
**Wave N of M — [plan name]:** What the executor does, what gets built, what it enables for subsequent waves. 2–3 sentences each. Write as a how-to narrative, not a task list.

### Done When
Each acceptance criterion from SPEC.md rewritten as a plain-English "When [action], [outcome]" statement. One per line, no checkboxes.

## Writing Rules

- No XML tags, no YAML frontmatter, no `<task>` blocks in the output
- No code blocks unless showing a concrete API or method signature (max 1)
- 500–1500 words total; cut anything a senior developer would infer
- Why section must be prose — no bullet lists
- Write for someone who hasn't read any of the source files
