"""Security tasks."""

import subprocess
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


@time_task
def cleanup_dialogs():
    """Run security cleanup on dialog files.

    Returns:
        dict: Task result
    """
    try:
        # Check if dialog export is enabled
        import json
        config_file = Path(".claude/.framework-config")

        if config_file.exists():
            with open(config_file) as f:
                config = json.load(f)
            dialog_enabled = config.get("dialog_export_enabled", False)
        else:
            dialog_enabled = False

        if not dialog_enabled:
            return create_task_result("security_cleanup", "success", "SECURITY:skipped:dialogs_disabled")

        # Check if cleanup script exists
        cleanup_script = Path("security/cleanup-dialogs.sh")
        if not cleanup_script.exists():
            return create_task_result("security_cleanup", "success", "SECURITY:skipped:script_missing")

        # Run cleanup script
        result = subprocess.run(
            ["bash", str(cleanup_script), "--last"],
            capture_output=True,
            text=True
        )

        if "Credentials detected and redacted" in result.stdout or "credential pattern(s) redacted" in result.stdout:
            # Extract count from "Total redactions: N" in summary
            import re
            match = re.search(r'Total redactions:\s*(\d+)', result.stdout)
            count = match.group(1) if match else "unknown"
            return create_task_result("security_cleanup", "success", f"SECURITY:redacted:{count}")

        return create_task_result("security_cleanup", "success", "SECURITY:clean")

    except Exception as e:
        return create_task_result("security_cleanup", "error", "", error=str(e))


@time_task
def export_dialogs():
    """Export dialogs using npm script.

    Returns:
        dict: Task result
    """
    try:
        # Check if dialog export is enabled
        import json
        config_file = Path(".claude/.framework-config")

        if config_file.exists():
            with open(config_file) as f:
                config = json.load(f)
            dialog_enabled = config.get("dialog_export_enabled", False)
        else:
            dialog_enabled = False

        if not dialog_enabled:
            return create_task_result("dialog_export", "success", "EXPORT:skipped:disabled")

        # Run npm export
        subprocess.run(
            ["npm", "run", "dialog:export", "--no-html"],
            capture_output=True,
            check=True
        )

        return create_task_result("dialog_export", "success", "EXPORT:done")

    except subprocess.CalledProcessError as e:
        return create_task_result("dialog_export", "error", "", error=str(e))
    except Exception as e:
        return create_task_result("dialog_export", "error", "", error=str(e))
