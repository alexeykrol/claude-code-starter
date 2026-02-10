# Parity Smoke Report (Core CLI)

Date: 2026-02-10
Mode: Codex parallel bootstrap

## Scope

Executed base framework lifecycle commands through shared core runtime:
- `python3 src/framework-core/main.py cold-start`
- `python3 src/framework-core/main.py completion`

## Results

### Cold Start

- Exit code: `0`
- Status: `success`
- Duration: `473 ms`
- Key task statuses:
  - `migration_cleanup`: `CLEANUP:done`
  - `version_check`: `UPDATE:none:3.1.1`
  - `git_hooks`: `HOOKS:done`
  - `mark_active`: `SESSION:active`
  - `context_files`: `.claude/SNAPSHOT.md,.claude/BACKLOG.md,.claude/ARCHITECTURE.md`

### Completion

- Exit code: `0`
- Status: `success`
- Duration: `12 ms`
- Key task statuses:
  - `security_cleanup`: `SECURITY:skipped:dialogs_disabled`
  - `dialog_export`: `EXPORT:skipped:disabled`
  - `git_status`: `STATUS:5 files`
  - `git_diff`: `DIFF:12 lines`

## Interpretation

- Core CLI is operational in this workspace for both lifecycle commands.
- Shared state/context paths are readable and returned by core.
- Current profile has dialog export disabled, so security/export tasks are skipped by design.

## Next Checks

1. Run crash-recovery branch (`needs_input`) parity test.
2. Run migration-router parity test with `.claude/migration-context.json` fixture.
3. Run security-chain parity with dialog export enabled in controlled fixture.
