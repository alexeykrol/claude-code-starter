# Working with Claude Code Starter Framework

> This project uses **Claude Code Starter Framework v4.0.2**.

## Quick Start

1. Open this project in terminal.
2. Launch your preferred agent:

```bash
# Option A
codex

# Option B
claude
```

3. In agent chat, type:

```text
start
```

4. At the end of your work cycle, type:

```text
/fi
```

## Agent Model

This framework supports both agents in one project:

- `CLAUDE.md` + `.claude/` for Claude Code
- `AGENTS.md` + `.codex/` for Codex

Both agents share the same state contract with profile-specific files:

- software profile:
  - `.claude/SNAPSHOT.md`
  - `.claude/BACKLOG.md`
  - `.claude/ARCHITECTURE.md`
- content profile:
  - `.claude/content/SNAPSHOT.md`
  - `.claude/content/BACKLOG.md`
  - `.claude/content/ARCHITECTURE.md`

## What `start` Does

- Routes migration/upgrade flow on first run if needed
- Executes cold-start protocol via shared Python core
- Checks updates and applies framework update automatically when configured
- Loads shared memory context

## What `/fi` Does

- Executes completion protocol via shared Python core
- Runs security/export checks
- Runs git status/diff checks
- Returns structured completion result

## Key Paths

```text
CLAUDE.md                    # Claude adapter entry
AGENTS.md                    # Codex adapter entry
.claude/                     # Shared memory + Claude workflows
.codex/                      # Codex workflows
src/framework-core/          # Shared runtime
security/                    # Security scripts
.claude/scripts/quick-update.sh  # Claude updater entry
.codex/commands/quick-update.sh  # Codex updater entry
```

## Notes

- Framework files and project business code are separate concerns.
- Migration and upgrade flows are additive by design.
- Keep profile memory files current as work progresses.

## Troubleshooting

- If protocol reports crash recovery needed: resolve in `start` flow and re-run `start`.
- If update issues occur: run `bash .codex/commands/quick-update.sh` manually.
- If migration was interrupted: check `reports/*MIGRATION_REPORT.md` and rerun `start`.
