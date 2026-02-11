"""Session management tasks."""

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


LOCK_FILE = Path(".claude/.session-owner")
SESSION_FILE = Path(".claude/.last_session")
DEFAULT_LOCK_TTL_SECONDS = 30 * 60


def _get_agent_name() -> str:
    value = os.environ.get("FRAMEWORK_AGENT_NAME", "unknown").strip().lower()
    return value or "unknown"


def _get_owner_pid() -> int:
    raw = os.environ.get("FRAMEWORK_OWNER_PID", "").strip()
    if raw.isdigit():
        return int(raw)
    return os.getpid()


def _get_lock_ttl_seconds() -> int:
    raw = os.environ.get("FRAMEWORK_LOCK_TTL_SECONDS", "").strip()
    if raw.isdigit():
        return int(raw)
    return DEFAULT_LOCK_TTL_SECONDS


def _read_json(path: Path):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return None


def _session_is_clean() -> bool:
    data = _read_json(SESSION_FILE)
    if not isinstance(data, dict):
        return False
    return str(data.get("status", "")).strip().lower() == "clean"


def _parse_timestamp(raw_value: str):
    if not raw_value:
        return None
    value = str(raw_value).strip()
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    try:
        parsed = datetime.fromisoformat(value)
        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=timezone.utc)
        return parsed
    except Exception:
        return None


def _pid_is_alive(pid_value) -> bool:
    try:
        pid = int(pid_value)
        if pid <= 0:
            return False
        os.kill(pid, 0)
        return True
    except Exception:
        return False


def _is_lock_stale(lock_data: dict) -> bool:
    if not isinstance(lock_data, dict):
        return True

    timestamp = _parse_timestamp(lock_data.get("timestamp"))
    if not timestamp:
        return True

    now = datetime.now(timezone.utc)
    age = (now - timestamp.astimezone(timezone.utc)).total_seconds()
    if age > _get_lock_ttl_seconds():
        return True

    lock_pid = lock_data.get("pid")
    if not str(lock_pid).isdigit():
        return True

    if not _pid_is_alive(lock_pid):
        return True

    # If session is marked clean, lock should not block new sessions.
    if _session_is_clean():
        return True

    return False


def _write_lock(agent_name: str, owner_pid: int):
    LOCK_FILE.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "agent": agent_name,
        "pid": owner_pid,
        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    }
    with open(LOCK_FILE, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)


@time_task
def acquire_session_lock():
    """Acquire shared session lock for current agent."""
    try:
        agent_name = _get_agent_name()
        owner_pid = _get_owner_pid()

        if LOCK_FILE.exists():
            lock_data = _read_json(LOCK_FILE)
            if isinstance(lock_data, dict):
                lock_agent = str(lock_data.get("agent", "unknown")).strip().lower() or "unknown"
                lock_pid = lock_data.get("pid", "unknown")
                lock_ts = str(lock_data.get("timestamp", "unknown"))

                if not _is_lock_stale(lock_data):
                    # Allow re-entry only for the same agent + same caller PID.
                    if lock_agent == agent_name and str(lock_pid) == str(owner_pid):
                        return create_task_result("session_lock", "success", "LOCK:reused")
                    return create_task_result(
                        "session_lock",
                        "needs_input",
                        f"LOCK:held:{lock_agent}:{lock_pid}:{lock_ts}"
                    )

            # Stale/invalid lock can be replaced.
            LOCK_FILE.unlink(missing_ok=True)
            _write_lock(agent_name, owner_pid)
            return create_task_result("session_lock", "success", "LOCK:recovered_stale")

        _write_lock(agent_name, owner_pid)
        return create_task_result("session_lock", "success", "LOCK:acquired")
    except Exception as e:
        return create_task_result("session_lock", "error", "", error=str(e))


@time_task
def release_session_lock():
    """Release shared session lock for current agent when ownership allows."""
    try:
        if not LOCK_FILE.exists():
            return create_task_result("session_lock_release", "success", "LOCK:none")

        lock_data = _read_json(LOCK_FILE)
        if not isinstance(lock_data, dict):
            LOCK_FILE.unlink(missing_ok=True)
            return create_task_result("session_lock_release", "success", "LOCK:released_invalid")

        lock_agent = str(lock_data.get("agent", "unknown")).strip().lower() or "unknown"
        agent_name = _get_agent_name()

        # Do not remove active lock owned by another agent.
        if lock_agent != agent_name and not _is_lock_stale(lock_data):
            return create_task_result(
                "session_lock_release",
                "success",
                f"LOCK:preserved:{lock_agent}"
            )

        LOCK_FILE.unlink(missing_ok=True)
        return create_task_result("session_lock_release", "success", "LOCK:released")
    except Exception as e:
        return create_task_result("session_lock_release", "error", "", error=str(e))


@time_task
def mark_clean_task():
    """Mark session as clean and return task-style result."""
    try:
        mark_clean()
        return create_task_result("mark_clean", "success", "SESSION:clean")
    except Exception as e:
        return create_task_result("mark_clean", "error", "", error=str(e))


@time_task
def check_crash():
    """Check if previous session crashed with uncommitted changes.

    Returns:
        dict: Task result with crash status
    """
    session_file = SESSION_FILE

    try:
        # Read last session status
        if not session_file.exists():
            return create_task_result("crash_detection", "success", "CRASH:none")

        with open(session_file) as f:
            session = json.load(f)

        status = session.get("status", "clean")

        if status != "active":
            return create_task_result("crash_detection", "success", "CRASH:none")

        # Non-git folders cannot have tracked uncommitted changes for crash recovery.
        repo_check = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            capture_output=True,
            text=True
        )
        if repo_check.returncode != 0:
            mark_clean()
            return create_task_result("crash_detection", "success", "CRASH:recovered_auto")

        # Check for uncommitted changes
        result = subprocess.run(
            ["git", "diff", "--quiet"],
            capture_output=True
        )

        has_unstaged = result.returncode != 0

        result = subprocess.run(
            ["git", "diff", "--staged", "--quiet"],
            capture_output=True
        )

        has_staged = result.returncode != 0

        if not has_unstaged and not has_staged:
            # Auto-recovery: no uncommitted changes
            mark_clean()
            return create_task_result("crash_detection", "success", "CRASH:recovered_auto")

        # True crash with uncommitted changes
        result = subprocess.run(
            ["git", "status", "--short"],
            capture_output=True,
            text=True
        )
        file_count = len(result.stdout.strip().split("\n")) if result.stdout.strip() else 0

        return create_task_result(
            "crash_detection",
            "needs_input",
            f"CRASH:needs_input:{file_count}"
        )

    except Exception as e:
        return create_task_result("crash_detection", "error", "", error=str(e))


def mark_clean():
    """Mark session as clean."""
    session_file = SESSION_FILE
    session_file.parent.mkdir(parents=True, exist_ok=True)

    with open(session_file, "w", encoding="utf-8") as f:
        json.dump({
            "status": "clean",
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }, f, indent=2)


@time_task
def mark_active():
    """Mark session as active.

    Returns:
        dict: Task result
    """
    try:
        session_file = SESSION_FILE
        session_file.parent.mkdir(parents=True, exist_ok=True)

        with open(session_file, "w", encoding="utf-8") as f:
            json.dump({
                "status": "active",
                "timestamp": datetime.utcnow().isoformat() + "Z"
            }, f, indent=2)

        return create_task_result("mark_active", "success", "SESSION:active")

    except Exception as e:
        return create_task_result("mark_active", "error", "", error=str(e))
