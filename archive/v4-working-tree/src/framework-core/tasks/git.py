"""Git operations tasks."""

import subprocess
from utils.parallel import time_task
from utils.result import create_task_result


def _run_git(args):
    return subprocess.run(
        ["git", *args],
        capture_output=True,
        text=True,
        check=False
    )


def _is_not_git_repo(stderr: str) -> bool:
    return "not a git repository" in (stderr or "").lower()


def _is_unborn_head(stderr: str) -> bool:
    text = (stderr or "").lower()
    return "ambiguous argument 'head'" in text or "bad revision 'head'" in text


@time_task
def check_git_status():
    """Check git status for uncommitted changes.

    Returns:
        dict: Task result with file counts
    """
    try:
        result = _run_git(["status", "--short"])
        if result.returncode != 0:
            if _is_not_git_repo(result.stderr):
                return create_task_result(
                    "git_status",
                    "success",
                    "STATUS:skipped:not_git_repo"
                )
            return create_task_result(
                "git_status",
                "error",
                "",
                error=(result.stderr.strip() or f"git status failed with code {result.returncode}")
            )

        files = result.stdout.strip().split("\n") if result.stdout.strip() else []
        file_count = len(files)

        return create_task_result(
            "git_status",
            "success",
            f"STATUS:{file_count} files"
        )

    except Exception as e:
        return create_task_result("git_status", "error", "", error=str(e))


@time_task
def get_git_diff():
    """Get git diff for all changes.

    Returns:
        dict: Task result with diff
    """
    try:
        result = _run_git(["diff", "HEAD"])
        if result.returncode != 0:
            if _is_not_git_repo(result.stderr):
                return create_task_result(
                    "git_diff",
                    "success",
                    "DIFF:skipped:not_git_repo"
                )
            if _is_unborn_head(result.stderr):
                return create_task_result(
                    "git_diff",
                    "success",
                    "DIFF:0 lines (no commits yet)"
                )
            return create_task_result(
                "git_diff",
                "error",
                "",
                error=(result.stderr.strip() or f"git diff failed with code {result.returncode}")
            )

        lines = len(result.stdout.split("\n")) if result.stdout else 0

        return create_task_result(
            "git_diff",
            "success",
            f"DIFF:{lines} lines"
        )

    except Exception as e:
        return create_task_result("git_diff", "error", "", error=str(e))
