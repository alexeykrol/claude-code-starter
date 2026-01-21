"""Session management tasks."""

import json
import subprocess
from datetime import datetime
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


@time_task
def check_crash():
    """Check if previous session crashed with uncommitted changes.

    Returns:
        dict: Task result with crash status
    """
    session_file = Path(".claude/.last_session")

    try:
        # Read last session status
        if not session_file.exists():
            return create_task_result("crash_detection", "success", "CRASH:none")

        with open(session_file) as f:
            session = json.load(f)

        status = session.get("status", "clean")

        if status != "active":
            return create_task_result("crash_detection", "success", "CRASH:none")

        # Check for uncommitted changes
        result = subprocess.run(
            ["git", "diff", "--quiet"],
            capture_output=True
        )

        has_unstaged = result.returncode != 0

        result = subprocess.run(
            ["git", "diff", "--staged", "--quiet"],
            capture_output=True
        )

        has_staged = result.returncode != 0

        if not has_unstaged and not has_staged:
            # Auto-recovery: no uncommitted changes
            mark_clean()
            return create_task_result("crash_detection", "success", "CRASH:recovered_auto")

        # True crash with uncommitted changes
        result = subprocess.run(
            ["git", "status", "--short"],
            capture_output=True,
            text=True
        )
        file_count = len(result.stdout.strip().split("\n")) if result.stdout.strip() else 0

        return create_task_result(
            "crash_detection",
            "needs_input",
            f"CRASH:needs_input:{file_count}"
        )

    except Exception as e:
        return create_task_result("crash_detection", "error", "", error=str(e))


def mark_clean():
    """Mark session as clean."""
    session_file = Path(".claude/.last_session")
    session_file.parent.mkdir(parents=True, exist_ok=True)

    with open(session_file, "w") as f:
        json.dump({
            "status": "clean",
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }, f, indent=2)


@time_task
def mark_active():
    """Mark session as active.

    Returns:
        dict: Task result
    """
    try:
        session_file = Path(".claude/.last_session")
        session_file.parent.mkdir(parents=True, exist_ok=True)

        with open(session_file, "w") as f:
            json.dump({
                "status": "active",
                "timestamp": datetime.utcnow().isoformat() + "Z"
            }, f, indent=2)

        return create_task_result("mark_active", "success", "SESSION:active")

    except Exception as e:
        return create_task_result("mark_active", "error", "", error=str(e))
