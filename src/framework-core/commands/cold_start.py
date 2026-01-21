"""Cold start command implementation."""

import time
from utils.result import create_result
from utils.parallel import run_tasks_parallel
from tasks.config import migration_cleanup, init_config, ensure_commit_policy, get_context_files
from tasks.session import check_crash, mark_active
from tasks.version import check_update
from tasks.security import cleanup_dialogs, export_dialogs
from tasks.hooks import install_git_hooks


def run_cold_start():
    """Run cold start protocol.

    Executes all 10 tasks in parallel and returns structured result.

    Returns:
        dict: Result with status, tasks, and timing info
    """
    start_time = time.time()

    # Define all tasks to run in parallel
    tasks = [
        migration_cleanup,      # Task 1
        check_crash,           # Task 2
        check_update,          # Task 3
        cleanup_dialogs,       # Task 4
        export_dialogs,        # Task 5
        ensure_commit_policy,  # Task 6
        install_git_hooks,     # Task 7
        init_config,           # Task 8
        # Task 9 (load context) - returns file paths, not a task
        mark_active            # Task 10
    ]

    # Run all tasks in parallel
    task_results = run_tasks_parallel(tasks)

    # Check for crash that needs user input
    crash_result = next(
        (r for r in task_results if r.get("name") == "crash_detection"),
        None
    )

    if crash_result and crash_result.get("status") == "needs_input":
        # Extract file count from result
        result_str = crash_result.get("result", "")
        if ":" in result_str:
            file_count = result_str.split(":")[-1]
        else:
            file_count = "unknown"

        return create_result(
            status="needs_input",
            command="cold-start",
            data={
                "reason": "crash_detected",
                "uncommitted_files": file_count,
                "message": "Previous session crashed with uncommitted changes"
            }
        )

    # Check for errors
    errors = [
        {
            "task": r.get("name"),
            "message": r.get("error", "Unknown error")
        }
        for r in task_results
        if r.get("status") == "error"
    ]

    # Add context files info
    context_files = get_context_files()
    task_results.append({
        "name": "context_files",
        "status": "success",
        "result": f"CONTEXT:{','.join(context_files)}",
        "duration_ms": 0
    })

    # Calculate total duration
    end_time = time.time()
    duration_ms = int((end_time - start_time) * 1000)

    # Return result
    if errors:
        return create_result(
            status="error",
            command="cold-start",
            tasks=task_results,
            errors=errors,
            duration_ms=duration_ms
        )

    return create_result(
        status="success",
        command="cold-start",
        tasks=task_results,
        duration_ms=duration_ms
    )
