# Phase 2 Parity Report (Codex Parallel Adapter)

Date: 2026-02-10
Scope: executable Codex workflow + expanded parity fixtures

## 1) Executable workflow verification

### `start`
Command: `bash .codex/commands/start.sh`

- Success fixture (`.last_session=clean`):
  - Exit: `0`
  - Core status: `success`
- Crash fixture (`.last_session=active` + dirty tracked files):
  - Exit: `2`
  - Core status: `needs_input`
  - Data: `reason=crash_detected`

### `finish`
Command: `bash .codex/commands/finish.sh`

- Exit: `0`
- Core status: `success`
- Completion task set returned as expected

### `update-check`
Command: `bash .codex/commands/update-check.sh`

- Exit: `0`
- JSON task result returned (`name=version_check`)

### `migration-router`
Command: `bash .codex/commands/migration-router.sh`

- No context: `route=none`
- Fixture mode `legacy`: `route=legacy-migration`
- Fixture mode `upgrade`: `route=framework-upgrade`
- Fixture mode `new`: `route=new-project-setup`

### `migrate-legacy`
Command: `FRAMEWORK_ROOT_DIR=<fixture> bash .codex/commands/migrate-legacy.sh`

- Exit: `0` on clean fixture
- Mandatory security gate executed (`security/initial-scan.sh`)
- Generated state artifacts:
  - `.claude/SNAPSHOT.md`
  - `.claude/BACKLOG.md`
  - `.claude/ARCHITECTURE.md`
  - `.claude/ROADMAP.md`
  - `.claude/IDEAS.md`
  - `.claude/.framework-config`
  - `.claude/COMMIT_POLICY.md`
- Migration markers cleaned:
  - `.claude/migration-context.json` removed
  - `.claude/migration-log.json` removed after archiving
- Migration artifacts created:
  - `reports/<project>-migration-log.json`
  - `reports/<project>-MIGRATION_REPORT.md`

### `upgrade-framework`
Command: `FRAMEWORK_ROOT_DIR=<fixture> bash .codex/commands/upgrade-framework.sh`

- Exit: `0` on upgrade fixture
- Backup snapshot created:
  - `.claude/backups/upgrade-<timestamp>/...`
- Existing state files preserved; missing required files created.
- Migration markers cleaned and artifacts generated (same contract as legacy).

### Error-path checks (migration executors)

- `migrate-legacy.sh`:
  - missing context -> exit `2`
  - wrong mode -> exit `3`
  - security gate blocked (scan non-zero) -> exit `4` and context preserved for retry
- `upgrade-framework.sh`:
  - missing context -> exit `2`
  - wrong mode -> exit `3`

## 2) Expanded fixtures

### A. `needs_input` fixture

- Setup: force `.claude/.last_session` to `active` with tracked uncommitted changes present.
- Result: `start.sh` returned exit `2` and surfaced `needs_input` JSON.
- Cleanup: original `.last_session` restored from backup.

### B. migration fixture

- Setup: temporary `.claude/migration-context.json` with each mode (`legacy`, `upgrade`, `new`).
- Result: router emitted expected deterministic JSON routes.
- Cleanup: migration context restored/removed after test.

### D. migration executor fixtures

- Setup:
  - `legacy` fixture with migration context, templates, and security scan script.
  - `upgrade` fixture with existing state files + upgrade context.
- Result:
  - both executors returned exit `0`;
  - required reports and archived migration logs created;
  - migration context/log markers removed only after successful completion.
- Cleanup:
  - fixture directories under `/tmp` (no mutations in project runtime state).

### C. security-chain fixture

- Setup:
  - temp-enable `dialog_export_enabled=true` in `.claude/.framework-config`
  - create test dialog file with synthetic credentials
- Run:
  - `bash security/cleanup-dialogs.sh --last`
  - python call to `tasks.security.cleanup_dialogs()`
- Result:
  - redactions applied (`REDACTED_*` markers present)
  - raw synthetic secrets absent
  - python task returned `SECURITY:redacted:*`
- Cleanup:
  - config restored from backup
  - fixture dialog file removed

## 3) Non-regression check (Claude contour)

- No edits applied to frozen Claude adapter files by this phase:
  - `/Users/alexeykrolmini/Downloads/Code/Project_init/CLAUDE.md`
  - `/Users/alexeykrolmini/Downloads/Code/Project_init/.claude/` (except runtime `.last_session` updates by core execution)

## 4) Current limitation

Codex migration executors are implemented for automated baseline parity.
Remaining scope before deeper core refactor remains adapter hardening and broader host-project soak testing.
