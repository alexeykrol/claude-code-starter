#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

python3 - <<'PY'
import json
import os
import sys

sys.path.insert(0, os.path.abspath("src/framework-core"))
from tasks.version import check_update

result = check_update()
print(json.dumps(result, indent=2))
PY
