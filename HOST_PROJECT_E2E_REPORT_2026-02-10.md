# Host Project E2E Report (Dual-Agent Installer)

Date: 2026-02-10
Repository: `alexeykrol/claude-code-starter`

## Scope

Validate single-file host installation flow:
1. User runs `init-project.sh` once.
2. Framework installs both adapters:
   - `CLAUDE.md` + `.claude/`
   - `AGENTS.md` + `.codex/`
3. User runs Codex and types `start`.
4. Migration route executes automatically and cold-start completes.

## Source Assets

Validated against GitHub Release assets at tag `v3.1.1`:
- `init-project.sh`
- `framework.tar.gz`
- `framework-commands.tar.gz`
- `quick-update.sh`
- `CLAUDE.md`
- `AGENTS.md`

## Result

Status: PASS

Observed behavior:
- Installer deployed Claude adapter + Codex adapter + shared runtime + security scripts.
- `bash .codex/commands/start.sh` auto-detected migration context.
- Legacy migration executed before cold-start without manual routing steps.
- Required artifacts generated:
  - `reports/<project>-MIGRATION_REPORT.md`
  - `reports/<project>-migration-log.json`
- Cold-start returned JSON `status=success`.

## Notes

- Security gate is enforced during legacy migration via `security/initial-scan.sh`.
- If security scan returns non-zero, migration blocks as designed until issues are resolved.
