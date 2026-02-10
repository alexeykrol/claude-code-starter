# Codex Update Check Command

Goal:
- Keep framework lifecycle parity for version checks and updates.

Executable entry:
- `bash .codex/commands/update-check.sh`

Procedure:
1. Reuse core version check via cold-start tasks.
2. If update is available, apply project-approved update flow.
3. Keep adapter-specific updates scoped to their own files and shared state contract.

Output contract:
- JSON task result compatible with `src/framework-core/tasks/version.py`.
