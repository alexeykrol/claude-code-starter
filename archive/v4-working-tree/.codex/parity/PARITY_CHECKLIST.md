# Parity Checklist (Bootstrap)

Status: phase-2-initial-run

Date: 2026-02-10

## Results

1. Cold start success path parity
- Command: `bash .codex/commands/start.sh` with fixture `.claude/.last_session.status=clean`
- Result: `status=success`, exit `0`
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

2. Cold start crash-recovery path parity
- Command: `bash .codex/commands/start.sh` with fixture `.claude/.last_session.status=active` + dirty tracked files
- Result: `status=needs_input`, exit `2`
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

3. Completion success path parity
- Command: `bash .codex/commands/finish.sh`
- Result: `status=success`, exit `0`
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

4. Migration route parity
- Command: `bash .codex/commands/migration-router.sh` with fixtures `mode=legacy|upgrade|new|none`
- Result: deterministic route JSON for all modes
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

5. Legacy migration executor parity
- Command: `FRAMEWORK_ROOT_DIR=<fixture> bash .codex/commands/migrate-legacy.sh`
- Result: security gate + state generation + report artifacts + cleanup markers
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

6. Upgrade executor parity
- Command: `FRAMEWORK_ROOT_DIR=<fixture> bash .codex/commands/upgrade-framework.sh`
- Result: backup + missing-state fill + report artifacts + cleanup markers
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

7. Version-check/update parity
- Command: `bash .codex/commands/update-check.sh`
- Result: valid `version_check` task JSON
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

8. Security cleanup chain parity
- Command: `bash security/cleanup-dialogs.sh --last` with credential fixture + python `cleanup_dialogs()` task
- Result: credentials redacted, parser returned `SECURITY:redacted:*`
- Evidence: `PHASE2_PARITY_REPORT_2026-02-10.md`
- Verdict: PASS

9. No regressions in Claude contour smoke checks
- Method: additive-only implementation, no edits to `CLAUDE.md` and `.claude/` functional files
- Result: no structural changes in frozen Claude contour
- Evidence: git diff scope and file-change audit
- Verdict: PASS (smoke level)
