# Codex Adapter Workspace

This directory contains Codex-specific workflows for the framework.

Rules:
- Keep shared project memory in profile-specific files:
  - software: `.claude/SNAPSHOT.md`, `.claude/BACKLOG.md`, `.claude/ARCHITECTURE.md`
  - content: `.claude/content/SNAPSHOT.md`, `.claude/content/BACKLOG.md`, `.claude/content/ARCHITECTURE.md`
- Use `.codex/` only for Codex runtime files, commands, and adapter configuration.

Structure:
- `commands/` Codex command procedures
- `contracts/` runtime and state contracts
- `config/` Codex adapter configuration
- `hooks/` Codex hook placeholders
- `skills/` Codex skill placeholders
- `subagents/` Codex subagent placeholders
