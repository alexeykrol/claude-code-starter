"""Cold start command implementation."""

import time
from utils.result import create_result
from utils.parallel import run_tasks_parallel
from tasks.config import migration_cleanup, init_config, ensure_commit_policy, get_context_files
from tasks.session import check_crash, mark_active, acquire_session_lock, release_session_lock
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

    # Init/normalize config first so downstream tasks read consistent defaults.
    config_result = init_config()
    lock_result = acquire_session_lock()
    task_results = [config_result, lock_result]

    if lock_result.get("status") == "needs_input":
        result_str = lock_result.get("result", "")
        parts = result_str.split(":")
        locked_by = parts[2] if len(parts) > 2 else "unknown"
        owner_pid = parts[3] if len(parts) > 3 else "unknown"
        lock_timestamp = parts[4] if len(parts) > 4 else "unknown"

        return create_result(
            status="needs_input",
            command="cold-start",
            tasks=task_results,
            data={
                "reason": "session_locked",
                "locked_by": locked_by,
                "owner_pid": owner_pid,
                "lock_timestamp": lock_timestamp,
                "message": (
                    f"Session is currently locked by {locked_by} "
                    f"(pid {owner_pid}). Finish that session or wait for stale lock cleanup."
                ),
            }
        )

    if lock_result.get("status") == "error":
        end_time = time.time()
        duration_ms = int((end_time - start_time) * 1000)
        return create_result(
            status="error",
            command="cold-start",
            tasks=task_results,
            errors=[{
                "task": lock_result.get("name"),
                "message": lock_result.get("error", "Unknown error")
            }],
            duration_ms=duration_ms
        )

    # Crash check must run before mark_active to avoid race in session status.
    crash_result = check_crash()
    task_results.append(crash_result)

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
            tasks=task_results,
            data={
                "reason": "crash_detected",
                "uncommitted_files": file_count,
                "message": "Previous session crashed with uncommitted changes"
            }
        )

    # Define tasks safe to run in parallel after crash-check phase.
    tasks = [
        migration_cleanup,      # Task 1
        check_update,          # Task 2
        cleanup_dialogs,       # Task 3
        export_dialogs,        # Task 4
        ensure_commit_policy,  # Task 5
        install_git_hooks,     # Task 6
    ]

    task_results.extend(run_tasks_parallel(tasks))
    task_results.append(mark_active())

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
        release_result = release_session_lock()
        task_results.append(release_result)
        if release_result.get("status") == "error":
            errors.append({
                "task": release_result.get("name"),
                "message": release_result.get("error", "Unknown error")
            })

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
