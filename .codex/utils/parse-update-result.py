#!/usr/bin/env python3
"""Parse cold-start JSON and extract update-available marker."""

import json
import sys


def main() -> int:
    if len(sys.argv) < 2:
        print("")
        return 0

    raw = sys.argv[1]
    try:
        data = json.loads(raw)
    except Exception:
        print("")
        return 0

    for task in data.get("tasks", []):
        if task.get("name") != "version_check":
            continue
        result = str(task.get("result", ""))
        if result.startswith("UPDATE:available:"):
            print(result)
            return 0

    print("")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
