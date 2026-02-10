# Codex Adapter Entry

## Purpose

This file is the Codex entry orchestrator for projects that use the framework.
It runs Codex workflows on top of shared project memory.

## Shared State

Primary memory files:
- `.claude/SNAPSHOT.md`
- `.claude/BACKLOG.md`
- `.claude/ARCHITECTURE.md`
- `CHANGELOG.md`

Codex and Claude use the same state contract.

## Command Routing

### `start`
Run:
- `bash .codex/commands/start.sh`

### `/fi`
Run:
- `bash .codex/commands/fi.sh`

### migration detection
Run:
- `bash .codex/commands/migration-router.sh`

### version check
Run:
- `bash .codex/commands/update-check.sh`

## Core Runtime

Shared command entry points:
- `python3 src/framework-core/main.py cold-start`
- `python3 src/framework-core/main.py completion`

Output contract:
- `.codex/contracts/core-cli-contract.md`
