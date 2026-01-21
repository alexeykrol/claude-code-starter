#!/usr/bin/env python3
"""
Framework Core - CLI entry point

Usage:
    python3 main.py cold-start
    python3 main.py completion
    python3 main.py --version
"""

import sys
import os
import argparse

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commands.cold_start import run_cold_start
from commands.completion import run_completion
from utils.result import print_result
from utils.logger import setup_logging

__version__ = "3.0.0"


def main():
    parser = argparse.ArgumentParser(
        description="Framework Core - Python utility for Claude Code Starter"
    )
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")

    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # Cold start command
    subparsers.add_parser("cold-start", help="Run cold start protocol")

    # Completion command
    subparsers.add_parser("completion", help="Run completion protocol")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Setup logging
    setup_logging(args.command)

    # Execute command
    try:
        if args.command == "cold-start":
            result = run_cold_start()
        elif args.command == "completion":
            result = run_completion()
        else:
            print_result({
                "status": "error",
                "errors": [{"message": f"Unknown command: {args.command}"}]
            })
            sys.exit(1)

        # Print result as JSON
        print_result(result)

        # Exit with appropriate code
        if result["status"] == "error":
            sys.exit(1)
        elif result["status"] == "needs_input":
            sys.exit(2)
        else:
            sys.exit(0)

    except Exception as e:
        print_result({
            "status": "error",
            "command": args.command,
            "errors": [{"message": str(e)}]
        })
        sys.exit(1)


if __name__ == "__main__":
    main()
