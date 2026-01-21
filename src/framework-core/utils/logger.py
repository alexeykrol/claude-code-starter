"""Logging utilities."""

import os
import logging
from datetime import datetime
from pathlib import Path


def setup_logging(command):
    """Setup logging to file.

    Args:
        command: Command name (e.g., "cold-start")
    """
    # Create logs directory
    log_dir = Path(".claude/logs/framework-core")
    log_dir.mkdir(parents=True, exist_ok=True)

    # Create log file with timestamp
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    log_file = log_dir / f"{command}-{timestamp}.log"

    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="[%(asctime)s] %(levelname)s: %(message)s",
        datefmt="%H:%M:%S",
        handlers=[
            logging.FileHandler(log_file),
            # Optionally log to stderr for debugging
            # logging.StreamHandler()
        ]
    )

    logging.info(f"Framework Core v3.1.1 - {command}")
    logging.info(f"Log file: {log_file}")


def log_task(name, status, duration_ms=0, details=""):
    """Log task execution.

    Args:
        name: Task name
        status: Task status
        duration_ms: Duration in milliseconds
        details: Additional details
    """
    msg = f"Task '{name}': {status}"
    if duration_ms > 0:
        msg += f" ({duration_ms}ms)"
    if details:
        msg += f" - {details}"

    logging.info(msg)
