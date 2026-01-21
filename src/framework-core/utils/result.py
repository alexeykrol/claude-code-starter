"""Result formatting and JSON output."""

import json
import sys
from datetime import datetime


def create_result(status, command, tasks=None, errors=None, warnings=None, data=None, duration_ms=0):
    """Create standardized result object.

    Args:
        status: "success", "error", or "needs_input"
        command: Command name (e.g., "cold-start")
        tasks: List of task results
        errors: List of errors
        warnings: List of warnings
        data: Additional data (for needs_input)
        duration_ms: Total duration in milliseconds

    Returns:
        dict: Standardized result object
    """
    result = {
        "status": status,
        "command": command,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

    if tasks is not None:
        result["tasks"] = tasks

    if errors is not None:
        result["errors"] = errors

    if warnings is not None:
        result["warnings"] = warnings

    if data is not None:
        result["data"] = data

    if duration_ms > 0:
        result["duration_total_ms"] = duration_ms

    return result


def create_task_result(name, status, result_data, duration_ms=0, error=None):
    """Create task result object.

    Args:
        name: Task name
        status: "success" or "error"
        result_data: Result string (e.g., "CLEANUP:done")
        duration_ms: Task duration in milliseconds
        error: Error message if failed

    Returns:
        dict: Task result object
    """
    task = {
        "name": name,
        "status": status,
        "result": result_data
    }

    if duration_ms > 0:
        task["duration_ms"] = duration_ms

    if error:
        task["error"] = error

    return task


def print_result(result):
    """Print result as JSON to stdout.

    Args:
        result: Result dictionary
    """
    print(json.dumps(result, indent=2))
    sys.stdout.flush()
