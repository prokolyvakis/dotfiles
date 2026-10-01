# Coordination map for the installed marketplace

Read this when a task could use an installed plugin and the choice is not
obvious. Samari (`samari:samari`) owns the task; the entries below are
specialist methods, agents, tools and explicitly requested workflows. Names are
the ones the host exposes; verify exposure and readiness in the session rather
than assuming from this list. Samari's generic procedure is in its
`plugin-coordination` reference; this file only binds it to this profile.

## Activity owners under Samari

| Activity | Use | Do not |
| --- | --- | --- |
| Debugging method | `superpowers:systematic-debugging` as a method inside the task; Feature Dev's `code-explorer` agent for one bounded source question | Enter the Superpowers brainstorm → plan → subagent cycle unless the user asked for it |
| Design brief / architecture | Feature Dev's `code-architect` agent for one bounded blueprint; Samari's grilling/codebase-design references | Run the full `/feature-dev` workflow as a side effect |
| Visual UI work | `frontend-design` for an actual visual brief | Apply it to non-visual changes |
| Domain guidance | `aws-amplify` for Amplify Gen2 only; `databases-on-aws` child `dsql` for Aurora DSQL only; the exact Stripe subskill for the exact question; `context7` for current library docs; `deploy-on-aws` for an authorized deployment phase | Treat a package name as a procedure for its siblings, adopt starter defaults (public API-key data, latest SDK) over an accepted project pin |
| Verification | Project checks first; one baseline evidence-oriented review (Samari verifier or native reviewer); `pr-review-toolkit` agents (`silent-failure-hunter`, `pr-test-analyzer`, `type-design-analyzer`, `comment-analyzer`) only for an identified gap | Launch every reviewer; count a reviewer's silence as proof |
| Simplification | One of `code-simplifier` or the toolkit simplifier, before final checks | Run a simplifier after a "final" review without invalidating it |
| Commit | `samari:commit` for the message; native git or one chosen command (`commit-commands`) to execute | Dispatch two commit flows |
| Publishing review | `/code-review` only inside an authorized PR-review workflow (it launches several agents and posts to GitHub) | Use it as a read-only library function |
| Browser | One controller per target: Playwright for repeatable interaction, Chrome DevTools for console/network/performance | Point both at the same page concurrently |
| Code navigation | TypeScript LSP for TypeScript; CodeGraph for symbol/impact questions after confirming index freshness | Treat an index as source authority |
| Maintenance | `claude-code-setup`, `claude-md-management`, `hookify`, `skill-creator`, `superpowers:diagnosing-superpowers` inside an explicitly bounded maintenance task | Self-reconfigure to make the current task easier |
| Iteration loop | `/ralph-loop` only as an explicit finite experiment the user requested | Nest it around another controller or an irreversible effect |

## Codex (official plugin)

- Internal assignment: the `codex:codex-rescue` **agent** through the Agent
  tool, with explicit read-only or write intent, scope, source identity,
  acceptance checks and a stop condition. It is a thin forwarder: one companion
  call, output verbatim, nothing on failure. It does not collect results.
- User-facing: `/codex:rescue`, `/codex:review --background`,
  `/codex:adversarial-review --background <concern>`. `/codex:rescue` asks once
  whether to resume a thread when one exists; answer it, do not pre-empt it.
- The parent collects `/codex:status <job>` and `/codex:result <job>` for the
  specific job ID, verifies the actual changes in the session checkout, and
  runs the affected checks. Empty output, a launched job or the forwarder's
  Claude model is not a Codex result. The stop-time review gate is off by
  default (`/codex:setup`); leave it off under Samari ownership.
- Model and effort stay at plugin defaults unless the user selects them. Claude
  plugins, MCP permissions and this file do not transfer to Codex.

## Ambient hooks (observed 2026-10-01; recheck after plugin updates)

| Owner | Events | Effect class | Rule |
| --- | --- | --- | --- |
| peon-ping (user settings) | Stop, SessionStart, SessionEnd, SubagentStart, UserPromptSubmit, Notification, PermissionRequest, PostToolUseFailure(Bash), PreCompact | Advisory notification (sound) | Ignore for task decisions |
| security-guidance | SessionStart (SDK bootstrap, may create a venv and pip-install), UserPromptSubmit, PostToolUse Edit/Write/Bash (pattern reminders), Stop and SubagentStop (model-backed review), commit/push review | Required-adjacent model-backed feedback | Keep enabled; treat its findings as candidate-bound evidence; Samari's explicit security review is the owner of the security verdict; do not add a second automatic loop |
| remember | SessionStart (injects memory), UserPromptSubmit (stamp), PostToolUse (capture), SessionEnd (save, Haiku summarization) | Memory capture, provider processing | Episodic hint only; canonical state lives in project records and the handoff; do not duplicate the handoff into its files |
| codex | SessionStart, SessionEnd (lifecycle), Stop (review gate, disabled by default) | Lifecycle; optional model-backed gate | Leave the gate off under Samari ownership |
| superpowers | SessionStart (startup, clear, compact) injects `using-superpowers` | Alternative workflow controller | Its own text defers to user instructions; CLAUDE.md above states the ownership rule; use its skills as methods |
| stripe | SessionStart, PostToolUse Skill/Agent, PostToolUseFailure, PostToolBatch, UserPromptSubmit | Setup and feedback callbacks | No effect on task decisions; no payment action without explicit authorization |
| hookify | PreToolUse, PostToolUse, Stop, UserPromptSubmit (user-authored rules; none present) | User rules | Author a rule only in a maintenance task |
| ralph-loop | Stop (active only with `.claude/ralph-loop.local.md`) | Iteration controller | Explicit finite experiment only |
| deploy-on-aws | PostToolUse Edit/Write on `.drawio` files | Artifact post-processor | Writer; runs before final artifact verification |
| databases-on-aws | PostToolUse on DSQL transact (prompt) | Advisory verification prompt | Only on DSQL work |

Memory division: project records are canonical; `remember` is episodic; an
Obsidian vault holds source-linked notes with explicit vault and path (Samari's
`knowledge` reference). Policy changes are reviewed edits to this file,
CLAUDE.md or the Samari bundle, never a memory entry.
