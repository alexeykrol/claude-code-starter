#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

run_cold_start() {
  set +e
  OUTPUT="$(python3 src/framework-core/main.py cold-start 2>&1)"
  EXIT_CODE=$?
  set -e
}

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

run_cold_start

if [ "$EXIT_CODE" -eq 0 ] && [ "${CODEX_AUTO_UPDATE:-1}" != "0" ] && [ -f "quick-update.sh" ]; then
  UPDATE_RESULT="$(python3 -c '
import json
import sys

raw = sys.argv[1]
try:
    data = json.loads(raw)
except Exception:
    print("")
    raise SystemExit(0)

for task in data.get("tasks", []):
    if task.get("name") == "version_check":
        result = str(task.get("result", ""))
        if result.startswith("UPDATE:available:"):
            print(result)
            break
' "$OUTPUT")"

  if [[ "$UPDATE_RESULT" == UPDATE:available:* ]]; then
    echo "[codex] update detected ($UPDATE_RESULT). applying framework update automatically."
    set +e
    UPDATE_OUTPUT="$(bash quick-update.sh 2>&1)"
    UPDATE_EXIT=$?
    set -e
    printf "%s\n" "$UPDATE_OUTPUT"

    if [ "$UPDATE_EXIT" -eq 0 ]; then
      echo "[codex] framework update applied. re-running start protocol."
      run_cold_start
    else
      echo "[codex] automatic update failed (exit $UPDATE_EXIT). continuing with current runtime."
    fi
  fi
fi

printf "%s\n" "$OUTPUT"

if [ "$EXIT_CODE" -eq 2 ]; then
  echo "[codex] action-required: crash recovery decision is needed before continuing."
fi

exit "$EXIT_CODE"
