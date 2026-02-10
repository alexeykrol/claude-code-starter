#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

CONTEXT_FILE=".claude/migration-context.json"

if [ ! -f "$CONTEXT_FILE" ]; then
  cat <<'JSON'
{
  "has_migration_context": false,
  "mode": null,
  "route": "none",
  "next_command": "bash .codex/commands/start.sh"
}
JSON
  exit 0
fi

python3 - <<'PY'
import json
from pathlib import Path

path = Path(".claude/migration-context.json")
data = json.loads(path.read_text(encoding="utf-8"))
mode = data.get("mode")

route_map = {
    "legacy": "legacy-migration",
    "upgrade": "framework-upgrade",
    "new": "new-project-setup",
}
route = route_map.get(mode, "unknown")

next_command = {
    "legacy-migration": "bash .codex/commands/migrate-legacy.sh",
    "framework-upgrade": "bash .codex/commands/upgrade-framework.sh",
    "new-project-setup": "bash .codex/commands/start.sh",
}.get(route, "manual-review-required")

print(json.dumps({
    "has_migration_context": True,
    "mode": mode,
    "route": route,
    "next_command": next_command
}, indent=2))
PY
