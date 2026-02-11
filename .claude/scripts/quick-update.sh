#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f ".codex/commands/quick-update.sh" ]; then
  echo "[framework] updater entry not found: .codex/commands/quick-update.sh"
  echo "[framework] run ./init-project.sh to restore framework runtime files."
  exit 1
fi

bash .codex/commands/quick-update.sh "$@"
