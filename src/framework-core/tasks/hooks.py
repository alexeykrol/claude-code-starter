"""Git hooks installation tasks."""

import subprocess
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


@time_task
def install_git_hooks():
    """Install git hooks silently.

    Returns:
        dict: Task result
    """
    try:
        hook_script = Path(".claude/scripts/install-git-hooks.sh")

        if not hook_script.exists():
            return create_task_result("git_hooks", "success", "HOOKS:skipped")

        # Run installation script
        subprocess.run(
            ["bash", str(hook_script)],
            capture_output=True,
            check=True
        )

        return create_task_result("git_hooks", "success", "HOOKS:done")

    except subprocess.CalledProcessError as e:
        return create_task_result("git_hooks", "error", "", error=str(e))
    except Exception as e:
        return create_task_result("git_hooks", "error", "", error=str(e))
