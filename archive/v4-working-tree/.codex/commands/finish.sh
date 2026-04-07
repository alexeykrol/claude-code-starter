#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
OWNER_PID="${PPID:-$$}"

set +e
OUTPUT="$(FRAMEWORK_AGENT_NAME=codex FRAMEWORK_OWNER_PID=$OWNER_PID python3 src/framework-core/main.py completion 2>&1)"
EXIT_CODE=$?
set -e

printf "%s\n" "$OUTPUT"

if [ "$EXIT_CODE" -ne 0 ]; then
  echo "[codex] completion failed: review task errors above."
fi

exit "$EXIT_CODE"
