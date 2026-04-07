# Codex Start Command

User protocol:
- type `start` in Codex.

Adapter entry:
- `bash .codex/commands/start.sh`

What happens:
1. Migration/upgrade route is auto-detected and executed if needed.
2. Cold-start protocol runs.
3. If a newer framework version is detected, update is applied automatically via `.codex/commands/quick-update.sh`.
4. Shared project memory is loaded from `.claude/*`.
