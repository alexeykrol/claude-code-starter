"""Configuration management tasks."""

import json
import os
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


@time_task
def migration_cleanup():
    """Check and cleanup migration files.

    Returns:
        dict: Task result
    """
    try:
        cleanup_file = Path(".claude/CLAUDE.production.md")

        if cleanup_file.exists():
            # Copy to CLAUDE.md
            import shutil
            shutil.copy2(cleanup_file, "CLAUDE.md")

            # Remove migration files
            cleanup_file.unlink(missing_ok=True)
            Path(".claude/migration-context.json").unlink(missing_ok=True)

            return create_task_result("migration_cleanup", "success", "CLEANUP:performed")

        return create_task_result("migration_cleanup", "success", "CLEANUP:done")

    except Exception as e:
        return create_task_result("migration_cleanup", "error", "", error=str(e))


@time_task
def init_config():
    """Initialize .framework-config if missing.

    Returns:
        dict: Task result
    """
    try:
        config_file = Path(".claude/.framework-config")

        if config_file.exists():
            return create_task_result("config_init", "success", "CONFIG:exists")

        # Create default config
        config_file.parent.mkdir(parents=True, exist_ok=True)

        project_name = Path.cwd().name

        default_config = {
            "bug_reporting_enabled": False,
            "project_name": project_name,
            "first_run_completed": False,
            "cold_start": {
                "silent_mode": True,
                "show_ready": False,
                "auto_update": True
            }
        }

        with open(config_file, "w") as f:
            json.dump(default_config, f, indent=2)

        return create_task_result("config_init", "success", "CONFIG:created")

    except Exception as e:
        return create_task_result("config_init", "error", "", error=str(e))


@time_task
def ensure_commit_policy():
    """Ensure COMMIT_POLICY.md exists.

    Returns:
        dict: Task result
    """
    try:
        policy_file = Path(".claude/COMMIT_POLICY.md")

        if policy_file.exists():
            return create_task_result("commit_policy", "success", "POLICY:exists")

        # Check for template
        template_file = Path("migration/templates/COMMIT_POLICY.template.md")
        project_name = Path.cwd().name

        if template_file.exists():
            # Use template
            with open(template_file) as f:
                content = f.read()
            content = content.replace("{{PROJECT_NAME}}", project_name)
        else:
            # Create minimal version
            content = f"""# Commit Policy

## ❌ Never commit:
dialog/, .claude/logs/, reports/, notes/, secrets/

## ✅ Always commit:
src/, tests/, README.md, package.json
"""

        policy_file.parent.mkdir(parents=True, exist_ok=True)
        with open(policy_file, "w") as f:
            f.write(content)

        return create_task_result("commit_policy", "success", "POLICY:created")

    except Exception as e:
        return create_task_result("commit_policy", "error", "", error=str(e))


def get_context_files():
    """Get list of context files to load.

    Returns:
        list: List of file paths
    """
    return [
        ".claude/SNAPSHOT.md",
        ".claude/BACKLOG.md",
        ".claude/ARCHITECTURE.md"
    ]
