"""Completion command implementation."""

import time
from utils.result import create_result
from utils.parallel import run_tasks_parallel
from tasks.git import check_git_status, get_git_diff
from tasks.security import cleanup_dialogs, export_dialogs
from tasks.config import init_config, ensure_project_baseline


def run_completion():
    """Run completion protocol.

    Executes completion tasks and returns structured result.

    Returns:
        dict: Result with status, tasks, and timing info
    """
    start_time = time.time()

    # Normalize config and refresh only existing baseline files.
    # Missing baseline files must be created during migration/upgrade flows.
    bootstrap_results = [
        init_config(),
        ensure_project_baseline(create_missing=False),
    ]

    # Define tasks to run in parallel
    tasks = [
        cleanup_dialogs,     # Security cleanup
        export_dialogs,      # Dialog export
        check_git_status,    # Git status
        get_git_diff         # Git diff
    ]

    # Run all tasks in parallel
    task_results = bootstrap_results + run_tasks_parallel(tasks)

    # Check for errors
    errors = [
        {
            "task": r.get("name"),
            "message": r.get("error", "Unknown error")
        }
        for r in task_results
        if r.get("status") == "error"
    ]

    # Calculate total duration
    end_time = time.time()
    duration_ms = int((end_time - start_time) * 1000)

    # Return result
    if errors:
        return create_result(
            status="error",
            command="completion",
            tasks=task_results,
            errors=errors,
            duration_ms=duration_ms
        )

    return create_result(
        status="success",
        command="completion",
        tasks=task_results,
        duration_ms=duration_ms
    )
