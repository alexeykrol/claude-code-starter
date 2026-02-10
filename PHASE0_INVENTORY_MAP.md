# Phase 0 Inventory Map: Claude Feature -> Core -> Codex Adapter

Date: 2026-02-10  
Status: baseline inventory for parallel Codex implementation

## 1. Objective

Create a complete, execution-oriented inventory that separates:
- agent-agnostic business logic (Core),
- Claude-specific adapter logic,
- Codex adapter implementation scope.

This is the required gate before implementing Codex workflows at scale.

## 2. Inventory Summary

Detected framework assets:
- Claude commands: 19 (`.claude/commands/*.md`)
- Protocol files: 7 (`.claude/protocols/*.md`)
- Claude adapter scripts: 5 (`.claude/scripts/*.sh`)
- Python core runtime: `src/framework-core/*`
- Security chain scripts: `security/*.sh`
- Installer/update lifecycle scripts: `init-project.sh`, `quick-update.sh`, `migration/*.sh`
- Dialog export engine: `src/claude-export/*`

## 3. Classification Matrix

## 3.1 Entry and protocols

| Claude feature | Current role | Target class | Codex plan |
|---|---|---|---|
| `CLAUDE.md` | Entry router + protocol bridge | Claude-only adapter | Create parallel `AGENTS.md` |
| `.claude/protocols/cold-start-silent.md` | Orchestration spec for cold start | Core semantics + Claude phrasing | Implement Codex execution using Python core + Codex-facing prompts |
| `.claude/protocols/completion-silent.md` | Orchestration spec for completion | Core semantics + Claude phrasing | Implement Codex completion orchestration |
| `.claude/protocols/auto-triggers.md` | Auto completion trigger policy | Shared policy candidate | Port trigger policy to Codex adapter config |
| `.claude/protocols/cold-start.md` / `completion.md` | legacy/verbose protocol variants | Claude-specific legacy layer | No immediate Codex dependency |

## 3.2 Core runtime (Python)

| Module | Role | Target class | Codex plan |
|---|---|---|---|
| `src/framework-core/main.py` | stable CLI entry | Core | Reuse as-is |
| `commands/cold_start.py` | cold-start execution graph | Core | Reuse as-is |
| `commands/completion.py` | completion execution graph | Core | Reuse as-is |
| `tasks/config.py` | config init, migration cleanup, commit policy | Core (path currently `.claude/*`) | Reuse now; abstract paths later |
| `tasks/session.py` | crash recovery/session state | Core | Reuse now |
| `tasks/version.py` | latest-version check | Core | Reuse now |
| `tasks/security.py` | cleanup/export orchestration | Core | Reuse now |
| `tasks/hooks.py` | git hook installation | Core | Reuse now |
| `tasks/git.py` | git status/diff summary | Core | Reuse now |

## 3.3 Dialog export and UI

| Component | Role | Target class | Codex plan |
|---|---|---|---|
| `src/claude-export/exporter.ts` | read Claude sessions from `~/.claude/projects`, export to markdown | Adapter-level (Claude source format) | Keep untouched for Claude; later define source abstraction for Codex session format |
| `src/claude-export/watcher.ts` | watcher + summary generation | Claude adapter runtime | No immediate port in Phase 0 |
| `src/claude-export/server.ts` | local UI + API for dialog visibility | Shared utility with Claude assumptions | Reuse for now as optional tool; abstract auth/path safety later |

## 3.4 Security and migration scripts

| Script group | Role | Target class | Codex plan |
|---|---|---|---|
| `security/cleanup-dialogs.sh` | redact credentials in dialogs | Core utility | Reuse from Codex adapter |
| `security/check-triggers.sh` | risk trigger scoring | Core utility | Reuse from Codex adapter |
| `security/auto-invoke-agent.sh` | Claude-oriented advisory bridge | Claude adapter glue | Create Codex equivalent advisory bridge later |
| `security/initial-scan.sh` | legacy migration initial scan | Core migration utility | Reuse from Codex migration route |
| `init-project.sh` | install/bootstrap and migration mode detection | Core lifecycle utility | Reuse unchanged |
| `quick-update.sh` | update flow | Core lifecycle utility | Reuse unchanged |
| `migration/*.sh` | release/update validation and packaging | Core maintenance utility | Reuse unchanged |

## 3.5 Command-level inventory

### Commands that must have Codex equivalents (high priority)
- `.claude/commands/fi.md`
- `.claude/commands/watch.md`
- `.claude/commands/ui.md`
- `.claude/commands/migrate-legacy.md`
- `.claude/commands/upgrade-framework.md`
- `.claude/commands/security-dialogs.md`

### Commands that are project-dev helpers (medium priority, adapter-local)
- `commit.md`, `pr.md`, `review.md`, `fix.md`, `feature.md`, `refactor.md`, `test.md`, `optimize.md`, `explain.md`, `security.md`, `db-migrate.md`

### Commands that are framework-maintainer specific (optional for Codex host usage)
- `release.md`, `analyze-bugs.md`, `analyze-local-bugs.md`, `bug-reporting.md`

## 4. Dependency and Side-Effect Notes

Key side effects in current core path:
- writes `.claude/.last_session`
- writes `.claude/.framework-config`
- may create/modify `.claude/COMMIT_POLICY.md`
- reads/writes git state and hooks
- may call npm dialog export

Conclusion:
- Python core is reusable now with current paths.
- Path abstraction (`.claude` vs generic state dir) can be deferred to post-parity refactor.

## 5. Phase 0 Blockers (must track)

1. Adapter mismatch: Claude command markdown is not directly executable by Codex runtime.
2. Dialog source coupling: exporter depends on Claude session storage format.
3. Known security-chain fragility must stay under parity tests.
4. Need explicit lock/ownership policy before dual-agent concurrent writes.

## 6. Parity Acceptance Matrix (initial)

| Scenario | Input trigger | Expected artifact/state |
|---|---|---|
| Cold start success | `start` | JSON success from python core, session marked active, state files loaded |
| Crash recovery required | `start` + active session + dirty git | `needs_input`, uncommitted file count surfaced |
| Completion run | `finish`/`/fi` | cleanup/export/git summary tasks complete, session clean flow |
| Migration route | migration context exists | proper route to legacy/upgrade/new workflow |
| Version check | internet available | update status in task result |
| Security cleanup | dialog exists | cleanup report produced, status parsed |

## 7. Deliverables Produced in This Step

- Root map: `/Users/alexeykrolmini/Downloads/Code/Project_init/PHASE0_INVENTORY_MAP.md`
- Codex adapter entry: `/Users/alexeykrolmini/Downloads/Code/Project_init/AGENTS.md`
- Parallel Codex scaffold: `/Users/alexeykrolmini/Downloads/Code/Project_init/.codex/`

## 8. Next Implementation Step

Implement Phase 2 in additive-only mode:
- wire Codex start/finish/migration/update command docs to executable procedures,
- run parity smoke checks,
- prepare Go/No-Go protocol artifact before any core refactor.
