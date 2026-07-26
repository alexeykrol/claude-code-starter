---
name: handoff
description: "Prepare reliable, role-typed cross-session handoffs for any project. Use when the user runs /handoff, asks to create, update, improve, or use a handoff / transition file / context bridge; pass work to a new Claude Code session, thread, agent, owner, or executor; spin up parallel sessions on a project; close or archive a source session before compaction; preserve project context; generate a kickoff prompt; or evaluate a new session's Verification Report. Always perform a pre-handoff documentation/state audit, reconcile stale docs with facts when safe, ground-verify commands, preserve dirty-tree boundaries, make the next session read and verify context, and when it reports back, judge whether it understood the context accurately rather than assigning its next work."
allowed-tools: Read Write Edit Glob Grep Bash
disable-model-invocation: false
---

# Skill: Handoff

## Core Rule

Create a handoff only after the project state and documentation have been
reconciled. A handoff is not a chat summary; it is the final transfer artifact
after audit, consistency cleanup, verification, and scoped git handling. The
handoff is the control surface between the owner and a session.

Do not trust memory files, old handoffs, README/status files, SNAPSHOT, or
prior chat as current truth without checking the workspace.

When the source session receives a Verification Report from the target session,
its job is acceptance, not command-and-control. Confirm whether the target
session accurately understood the handoff, boundaries and readiness state so the
source session can be safely archived. Do not turn that response into a new task
brief unless the user explicitly asks for new instructions.

## Control Model — what gets a handoff, and why

```
OWNER     decides which modules = sessions exist; reviews each session's output      (coarse control)
SESSION   owns its module/role; decides HOW, including spawning subagents             (fine control — the agent)
SUBAGENT  ephemeral legwork inside a session; invisible to the owner; gets NO handoff (the session's own call)

boundary owner↔session    = the module CONTRACT  (enforced via handoff → report → consensus → output review)
boundary session↔subagent = the session's internal task spec (Agent tool: researcher / implementer / reviewer)
```

- **A session is the owner's unit of control** — launchable, observable, correctable, reviewable. **Each module → its own session.**
- **A subagent is internal delegation** via the Agent tool — the session decides it; the owner does not see or steer it. **Subagents get NO handoff.**
- Therefore **handoffs are for SESSIONS only.** This skill produces session handoffs.
- Module=session control only holds when the module's **seam contracts are clean** — otherwise correcting one session ripples into others. Define seams before parallelizing.

## Handoff TYPES — pick by what the new session will DO

`TYPE: orchestrator | executor | reviewer | owner | general`

The two primary types have opposite failure modes; a session onboarded to the
wrong type fails in a characteristic way:

| | **Orchestrator** | **Executor** |
|---|---|---|
| Scope | global: roadmap, module map, all seams, all module states | ONE module (its folder-root) + its named contracts |
| Focus | coordination + architecture | implementation |
| Does | decompose work, define/maintain seam contracts, write executor handoffs, review their reports, integrate, sequence | build the module's pipeline/console/store/fixtures/reference; debug against its own metrics |
| NEVER | implements module internals by hand; reads deep into one module to build | touches other modules; redefines contracts; edits the roadmap; climbs into global context |
| May | use subagents (Agent tool) for legwork it owns end-to-end (stays in the loop) | use its own subagents internally |
| Output | coordination artifacts: contracts, executor handoffs, roadmap/state updates, decisions | module code + its verification report + commits within its contract |
| Mis-onboard failure | "grabs the work and starts implementing" — loses coordination altitude | "climbs into the whole project" — loses focus |

Other TYPE values, when neither fits:
- **reviewer** — audits/reviews a defined scope; reports findings; does not implement.
- **owner** — transfer of ownership/decision context to a human or lead session.
- **general** — continuation of the same role in a fresh session (e.g. pre-compaction archive); state the scope explicitly anyway.

Parallelizing a project typically means **one orchestrator handoff + N executor handoffs** (one per module). Slugs disambiguate.

## Grounding Discipline — all handoffs (hard-won)

- **Ground claims in territory, not metafiles.** Verify each load-bearing fact (counts, file/store states, what's done) by running the command BEFORE writing it. Stale metafile claims make the new session repeat or break work.
- **Never pin a moving "last/current commit" hash** — it goes stale on your own next commit. Give a STABLE ref (the commit holding the key work) + "check `git log` for live HEAD".
- **Honest done-vs-pending.** Work finished THIS session is done — say so; never label it "to do" (or the reverse).
- **Include the verification commands** so the new session can re-confirm the facts itself.
- **Scope discipline.** Each handoff confines its session to its scope — a focused worker, not "everyone at every meeting."

## Workflow

### 1. Establish The Target

- Identify the project root, current working directory, branch, owner intent,
  and the role expected in the next session → that fixes the TYPE.
- If the target is a git worktree, inspect current status and recent history.
- Respect dirty-tree boundaries: never revert or stage unrelated user changes.
- If the user gives stop rules, ownership boundaries, or "do not commit/push"
  instructions, obey them over this generic workflow.

### 2. Audit Documentation Before Handoff

Read the docs that define current project truth before writing the handoff.
Start with project instruction files and then follow the local architecture:

- `CLAUDE.md` (and `AGENTS.md` if the project is dual-agent), `README*`,
  `MIGRATION*`, `STATUS*`, `ROADMAP*`, `BACKLOG*`, architecture docs, module
  registries, contract docs, and existing handoffs in `.handoffs/`.
- Framework metafiles when present: `.claude/SNAPSHOT.md`, `.claude/BACKLOG.md`,
  `manifest.md`, recent session logs in `.claude/logs/sessions/`.
- User-specified files and any docs named by local project instructions.
- Owning module/bounded-context docs for the area being handed off.

Compare those docs against grounded facts:

- Recent commits and branch state.
- Current file tree and moved/deleted files.
- Package scripts, schemas, fixtures, migrations, configs, and generated-data
  boundaries.
- Available tests, guards, checks, or runtime smoke commands.
- Actual implemented behavior when it is cheap and safe to verify.

When the user asks for "all docs", make a broad docs inventory with fast file
search and sample likely stale assertions; delegate the legwork to a
`researcher` subagent (Agent tool) if the inventory is large. Prioritize
canonical/status/contract docs over archival notes.

### 3. Reconcile Stale Docs

If docs lag behind verified facts, fix the docs first. Keep edits scoped to
documentation, contracts, fixtures, or guards unless the user explicitly asked
for implementation. Update `.claude/SNAPSHOT.md` if the project keeps one and
it is stale.

- Mark unresolved contradictions as blockers instead of guessing product intent.
- Preserve unrelated local changes.
- Stage only files that belong to this handoff/audit work.
- Re-run relevant checks after doc changes.

If reconciliation is impossible without an owner decision, do not fabricate a
clean handoff. Record the blocker and prepare a handoff that makes the decision
boundary explicit.

### 4. Verify

Before writing the final handoff, collect commands and outcomes that a new
session can repeat:

- `git status --short --branch` when the target is a git repo.
- Recent commit history, using enough depth to include key commits.
- Project-specific tests, validators, schema checks, guards, or smoke commands.
- Any doc consistency checks you used.

Record exact commands and concise results. Prefer robust facts over brittle
expectations. For example, after extra handoff commits, say "key commit X should
be present in recent history" instead of "HEAD must be X" unless HEAD truly must
be fixed.

### 5. Write The Handoff

Create the handoff under the project root (create the dir if missing); slug is
2–4 lowercase hyphenated words:

```text
.handoffs/YYYY-MM-DD-HHMM-<short-slug>.md
```

Write the handoff body in the conversation language. Use this structure:

````markdown
# Handoff (<type>): <short title>

## Metadata

- Created: <local ISO timestamp>
- Project root: `<absolute path>`
- Branch: `<branch or n/a>`
- Stable refs: `<key commits, tags, files, or artifacts>`
- Source description: <why this handoff exists>
- TYPE: <orchestrator|executor|reviewer|owner|general>

## Role & Scope

<What the next session is and is not allowed to do.
Orchestrator: "global; you coordinate, you do not implement."
Executor: the exact folder + named contracts; "this and nothing else.">

## Project Context

<Current product/project framing in durable terms; 2–4 sentences orienting a fresh session.>

## Read First

- `<absolute or project-relative path>`
- ...

## Grounded Facts (verified)

- `<command>` -> <result>
- ...
<Note: metafiles are a map, not the territory.>

## Current State

Done (verified):
- ...

Pending:
- ...

## Files / Contracts In Scope

- `<path>` — <why it matters; executor: ONLY its module + contracts>

## Decisions Made

- <decision + reasoning>

## Open Questions / Blockers

- ... or `—`

## Recommended Next Move

<One concrete first move after owner/parent confirmation.>

## Kickoff Prompt

```text
Ты новая Claude Code session для `<absolute project root>`.
Сначала открой и прочитай handoff:
`<absolute path to this handoff file>`

Затем прочитай listed docs из handoff. После этого GROUND-VERIFY факты
командами из "Grounded Facts"; не доверяй metafiles без проверки.

Твоя роль: <role/scope in one paragraph, carrying the TYPE discipline>.

После чтения и проверки выдай в чат Verification Report:
- Understood: роль, scope, task/model своими словами (не эхо handoff).
- Verified: какие команды прогнал и совпали ли факты (с реальными числами).
- Discrepancies: расхождения или `—`.
- Questions: вопросы или `—`.
- Readiness: `ready on confirmation` / `blocked: ...`, плюс proposed first move.

Не начинай работу до подтверждения owner/parent.
```
````

Kickoff prompt rules — VERIFY → REPORT → WAIT (never act immediately):

- Standalone; under ~180 words; must include the **absolute path** to the
  handoff file. Do not write "this handoff" without the path.
- It must make the new session: (a) read the handoff + listed docs;
  (b) GROUND-VERIFY against the territory; (c) output a Verification Report and
  NOT start work until the parent/owner confirms consensus; (d) carry the TYPE
  discipline explicitly in the role paragraph:
  - **orchestrator:** "You ORCHESTRATE — define/refine contracts, dispatch
    executors, review their reports, integrate, sequence. You do NOT implement
    module internals; if you catch yourself editing module code, stop.
    Legwork → subagents, staying in the loop."
  - **executor:** "You build ONLY within <module> + the named contracts. You do
    NOT touch the roadmap, other modules, or contracts. Report, then wait."

### 6. Accept Or Reject The Verification Report

Use this step when the target session reports back with `Verification Report`
or when the user asks whether the new session understood the handoff. The point
is confidence, not speed — the handshake catches misunderstanding and stale
facts before any work happens.

Evaluate only comprehension and boundary alignment:

- Did the target session read the handoff and required docs?
- Did it restate role/scope/task IN ITS OWN WORDS (comprehension, not echo)?
- Did it rerun the grounded facts or clearly report equivalent verification?
- Did it preserve the stated scope and stop rules?
- Did it identify discrepancies without treating minor expected differences as
  blockers?
- Is its proposed first move inside the handoff boundaries?

Respond with one of these verdicts:

- `Accepted` — the target session understood the context and boundaries well
  enough; the source session can be archived.
- `Needs correction` — list the exact misunderstanding or missing verification
  the target session must correct before work begins.
- `Blocked` — state the blocker and why the source session cannot safely
  archive yet.

Keep the acceptance response short. Do not provide a fresh task list, detailed
implementation plan, or new sequencing commands unless the user explicitly asks
for them. If the target session proposed a first move, judge whether it is
inside scope; do not micromanage how it should execute that move.

Recommended acceptance wording:

```text
Verification Report accepted. The target session understood the scope,
boundaries and current state correctly. Source session can be archived.
```

### 7. Commit And Push When Safe

If the project is a git repo and the user did not prohibit git actions:

- Commit scoped doc/contract/guard/handoff changes after verification. Follow
  the project commit policy (`repo_access` in `manifest.md`,
  `commit-policy.md`): `git add` specific files only — never `git add .` or
  `git add -A`. In `public`/`private-shared` repos, `.handoffs/` is a process
  artifact — keep it local/gitignored unless the project says otherwise; in
  `private-solo` committing it is fine.
- Use a clear commit message such as
  `docs(handoff): add <topic> handoff` or
  `docs(<scope>): reconcile docs before handoff`.
- Push when the branch has a configured remote, authentication works, and doing
  so does not require staging unrelated dirty files. Pushes to main/production
  follow the production-safety rule — confirmation required.
- If push is not safe or not possible, record that explicitly in the handoff or
  final response.

Committing the handoff changes branch history. After committing, ensure the
handoff's Grounded Facts are still phrased correctly for the next session.
Update or amend if necessary.

## Final Response

Keep the final response short:

- Give the handoff file path.
- Include the kickoff prompt verbatim in a fenced `text` block.
- State commit/push status only if relevant.
- Don't echo the full handoff; no commentary unless asked.

## Notes

- Empty section → `—`, never fabricate.
- Don't pad. Fast, correct context transfer, not documentation.
- Subagents need no handoff (internal, the session's call via the Agent tool).
  Handoffs are for sessions.
- Parallel rollout → one file per session; one orchestrator + N executors;
  slugs disambiguate.
