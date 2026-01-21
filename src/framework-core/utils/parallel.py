"""Parallel task execution utilities."""

import concurrent.futures
import time
from utils.logger import log_task


def run_tasks_parallel(tasks, max_workers=10):
    """Run tasks in parallel using ThreadPoolExecutor.

    Args:
        tasks: List of callables (task functions)
        max_workers: Maximum number of parallel workers

    Returns:
        list: List of task results
    """
    results = []

    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Submit all tasks
        future_to_task = {executor.submit(task): task.__name__ for task in tasks}

        # Collect results as they complete
        for future in concurrent.futures.as_completed(future_to_task):
            task_name = future_to_task[future]
            try:
                result = future.result()
                results.append(result)
                log_task(task_name, "completed",
                        duration_ms=result.get("duration_ms", 0))
            except Exception as e:
                log_task(task_name, "failed", details=str(e))
                results.append({
                    "name": task_name,
                    "status": "error",
                    "error": str(e)
                })

    return results


def time_task(func):
    """Decorator to measure task execution time.

    Args:
        func: Function to measure

    Returns:
        Wrapped function that includes duration_ms in result
    """
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()

        duration_ms = int((end_time - start_time) * 1000)

        if isinstance(result, dict):
            result["duration_ms"] = duration_ms

        return result

    wrapper.__name__ = func.__name__
    return wrapper
