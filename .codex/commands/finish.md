# Codex Finish Command (Parallel Mode)

Goal:
- Execute completion via shared Python core and preserve parity with framework lifecycle.

Executable entry:
- `bash .codex/commands/finish.sh`

Procedure:
1. Run:
   - `python3 src/framework-core/main.py completion`
2. Parse JSON status:
   - `success`: summarize completion artifacts.
   - `error`: show failed tasks with fixes.
3. If needed, execute follow-up steps from project policy:
   - selective git staging,
   - commit policy checks,
   - push/PR by user confirmation.
4. Keep shared state files consistent with work performed.

Exit codes:
- `0` success
- `1` error
