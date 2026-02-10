# Codex Start Command (Parallel Mode)

Goal:
- Execute framework cold start via shared Python core.
- Respect frozen Claude adapter policy.

Executable entry:
- `bash .codex/commands/start.sh`

Procedure:
1. Verify non-regression guard: do not modify `CLAUDE.md` or `.claude/` structure.
2. Run:
   - `python3 src/framework-core/main.py cold-start`
3. Parse JSON status:
   - `success`: continue normally.
   - `needs_input`: ask user for crash-recovery choice.
   - `error`: surface actionable failure and stop.
4. Load shared state context:
   - `.claude/SNAPSHOT.md`
   - `.claude/BACKLOG.md`
   - `.claude/ARCHITECTURE.md`

Exit codes:
- `0` success
- `1` error
- `2` action required (`needs_input`)
