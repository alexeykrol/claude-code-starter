# Codex Migration Router

Goal:
- Route first-launch migration scenarios without changing Claude adapter logic.

Executable entry:
- `bash .codex/commands/migration-router.sh`

Procedure:
1. Check `.claude/migration-context.json`.
2. If absent: continue standard start path.
3. If present, route by `mode`:
   - `legacy` -> execute legacy migration workflow equivalent.
   - `upgrade` -> execute upgrade workflow equivalent.
   - `new` -> continue standard start for a freshly installed project.
4. Preserve migration logs and safety checks.
5. Remove migration marker only after successful completion.

Output contract:
- JSON with fields: `has_migration_context`, `mode`, `route`, `next_command`.
