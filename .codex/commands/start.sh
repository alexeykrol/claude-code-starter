#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# Auto-route migration on first run so user can just type `start`.
if [ -f ".claude/migration-context.json" ]; then
  ROUTE_JSON="$(bash .codex/commands/migration-router.sh)"
  NEXT_COMMAND="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("next_command", ""))' "$ROUTE_JSON")"

  case "$NEXT_COMMAND" in
    "bash .codex/commands/migrate-legacy.sh")
      echo "[codex] migration context detected: running legacy migration before cold-start."
      bash .codex/commands/migrate-legacy.sh
      ;;
    "bash .codex/commands/upgrade-framework.sh")
      echo "[codex] migration context detected: running framework upgrade before cold-start."
      bash .codex/commands/upgrade-framework.sh
      ;;
  esac
fi

set +e
OUTPUT="$(python3 src/framework-core/main.py cold-start 2>&1)"
EXIT_CODE=$?
set -e

printf "%s\n" "$OUTPUT"

if [ "$EXIT_CODE" -eq 2 ]; then
  echo "[codex] action-required: crash recovery decision is needed before continuing."
fi

exit "$EXIT_CODE"
