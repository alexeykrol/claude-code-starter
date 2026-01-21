"""Version checking tasks."""

import re
import subprocess
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


@time_task
def check_update():
    """Check for framework updates on GitHub.

    Returns:
        dict: Task result with version info
    """
    try:
        # Get local version from CLAUDE.md
        claude_file = Path("CLAUDE.md")
        if not claude_file.exists():
            return create_task_result("version_check", "error", "", error="CLAUDE.md not found")

        with open(claude_file) as f:
            content = f.read()

        # Parse version
        match = re.search(r'Framework: Claude Code Starter v([\d.]+)', content)
        if not match:
            return create_task_result("version_check", "error", "", error="Version not found in CLAUDE.md")

        local_version = match.group(1)

        # Get latest version from GitHub
        try:
            result = subprocess.run(
                ["curl", "-s", "https://api.github.com/repos/alexeykrol/claude-code-starter/releases/latest"],
                capture_output=True,
                text=True,
                timeout=5
            )

            if result.returncode != 0:
                return create_task_result("version_check", "success", f"UPDATE:check_failed:{local_version}")

            # Parse tag_name
            match = re.search(r'"tag_name":\s*"v?([\d.]+)"', result.stdout)
            if not match:
                return create_task_result("version_check", "success", f"UPDATE:none:{local_version}")

            latest_version = match.group(1)

            if local_version != latest_version:
                return create_task_result(
                    "version_check",
                    "success",
                    f"UPDATE:available:{local_version}:{latest_version}"
                )

            return create_task_result("version_check", "success", f"UPDATE:none:{local_version}")

        except subprocess.TimeoutExpired:
            return create_task_result("version_check", "success", f"UPDATE:timeout:{local_version}")

    except Exception as e:
        return create_task_result("version_check", "error", "", error=str(e))
