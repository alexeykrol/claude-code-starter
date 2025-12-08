# ARCHITECTURE.md — Claude Code Starter Framework

*Last updated: 2025-12-07*

## Overview

Claude Code Starter is a **meta-framework** that extends Claude Code capabilities. It's not just documentation templates — it's a layer on top of the AI coding agent that adds missing functionality.

## Core Concepts

### 1. Framework as AI Extension
- Adds structured protocols (Cold Start, Completion)
- Provides crash recovery
- Enables dialog export and tracking
- Standardizes project documentation

### 2. Dual Nature
- **Templates** (`Init/`) — copied to user projects
- **Code** (`src/`) — framework's own functionality

## Project Structure

```
claude-code-starter/
│
├── src/                      # Source code
│   └── claude-export/        # Dialog export utility
│       ├── cli.ts            # CLI interface
│       ├── exporter.ts       # JSONL → Markdown conversion
│       ├── server.ts         # Express API + Web UI
│       ├── watcher.ts        # File system watcher
│       ├── gitignore.ts      # .gitignore manipulation
│       └── public/           # Web UI assets
│
├── dist/                     # Compiled JavaScript
│   └── claude-export/
│
├── Init/                     # User templates (Russian)
│   ├── CLAUDE.md             # AI instructions template
│   ├── SNAPSHOT.md           # Project state template
│   ├── BACKLOG.md            # Tasks template
│   ├── ARCHITECTURE.md       # Architecture template
│   ├── SECURITY.md           # Security policy
│   ├── .claude/commands/     # Slash commands (19)
│   └── .claude-export/       # Pre-built utility (dist only)
│
├── .claude/                  # Framework's own commands
│   └── commands/
│
├── dialog/                   # Exported development dialogs
├── papers/                   # Concepts and ideas
├── archive/                  # Historical files
│
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript config
├── CLAUDE.md                 # Framework's AI context
├── SNAPSHOT.md               # Framework state
├── BACKLOG.md                # Framework tasks
├── CHANGELOG.md              # Version history
├── README.md                 # Documentation (EN)
├── README_RU.md              # Documentation (RU)
└── init-project.sh           # Installation script
```

## Code Modules

### claude-export

Dialog export utility that converts Claude Code sessions to Markdown.

| Module | Purpose | Size |
|--------|---------|------|
| `cli.ts` | CLI commands (init, watch, ui, export, list) | 9KB |
| `exporter.ts` | JSONL parsing, Markdown generation | 26KB |
| `server.ts` | Express API, Web UI | 15KB |
| `watcher.ts` | Chokidar file watching, auto-export | 17KB |
| `gitignore.ts` | Privacy control via .gitignore | 6KB |

### Data Flow

```
~/.claude/projects/*.jsonl    # Claude Code sessions
         │
         ▼
    [watcher.ts]              # Detect changes
         │
         ▼
    [exporter.ts]             # Parse JSONL
         │
         ▼
    dialog/*.md               # Markdown output
         │
         ▼
    [gitignore.ts]            # Add to .gitignore (private)
```

## Templates (Init/)

Templates installed to user projects via `init-project.sh`.

### Core Files
| File | Purpose |
|------|---------|
| CLAUDE.md | AI agent instructions, protocols |
| SNAPSHOT.md | Quick project state for cold start |
| BACKLOG.md | Tasks and progress tracking |
| ARCHITECTURE.md | Code structure documentation |
| SECURITY.md | Security policy and checklist |

### Slash Commands (19)
- **Core:** `/fix`, `/feature`, `/review`, `/test`, `/commit`, `/pr`
- **Quality:** `/security`, `/optimize`, `/refactor`, `/explain`
- **Migration:** `/migrate`, `/migrate-resolve`, `/migrate-finalize`, `/migrate-rollback`
- **Framework:** `/fi`, `/release`, `/db-migrate`, `/ui`, `/watch`

## Key Design Decisions

### 1. Privacy by Default
All exported dialogs are automatically added to .gitignore. Users must explicitly make them public.

### 2. Local Processing
No data leaves the machine. No external APIs. No telemetry.

### 3. Token Economy
- SNAPSHOT.md for quick context loading
- Modular focus — read only current module
- Cold Start Protocol — minimize token usage

### 4. Single Source of Truth
- One file per concept
- No duplication between templates
- Clear ownership of information

## Dependencies

```json
{
  "chokidar": "^3.5.3",    // File watching
  "express": "^4.18.2"     // Web server
}
```

Minimal dependencies by design.

## Build & Run

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Run commands
npm run dialog:export   # Export dialogs
npm run dialog:ui       # Web UI on :3333
npm run dialog:watch    # Auto-export watcher
npm run dialog:list     # List sessions
```

## Future Modules

Planned additions to `src/`:
- `context-manager/` — Smart context loading
- `session-recovery/` — Enhanced crash recovery
- `template-generator/` — Dynamic template creation

---
*Framework: Claude Code Starter v2.0*
