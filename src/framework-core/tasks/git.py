"""Git operations tasks."""

import subprocess
from utils.parallel import time_task
from utils.result import create_task_result


@time_task
def check_git_status():
    """Check git status for uncommitted changes.

    Returns:
        dict: Task result with file counts
    """
    try:
        result = subprocess.run(
            ["git", "status", "--short"],
            capture_output=True,
            text=True,
            check=True
        )

        files = result.stdout.strip().split("\n") if result.stdout.strip() else []
        file_count = len(files)

        return create_task_result(
            "git_status",
            "success",
            f"STATUS:{file_count} files"
        )

    except subprocess.CalledProcessError as e:
        return create_task_result("git_status", "error", "", error=str(e))


@time_task
def get_git_diff():
    """Get git diff for all changes.

    Returns:
        dict: Task result with diff
    """
    try:
        result = subprocess.run(
            ["git", "diff", "HEAD"],
            capture_output=True,
            text=True,
            check=True
        )

        lines = len(result.stdout.split("\n")) if result.stdout else 0

        return create_task_result(
            "git_diff",
            "success",
            f"DIFF:{lines} lines"
        )

    except subprocess.CalledProcessError as e:
        return create_task_result("git_diff", "error", "", error=str(e))
