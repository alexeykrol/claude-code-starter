---
description: Start auto-export watcher for dialogs
---

# Dialog Watcher

Start automatic export of Claude Code dialogs as they happen.

## Command

```bash
npm run dialog:watch
```

Or directly:
```bash
node .claude-export/dist/cli.js watch
```

## Features

- Monitors ~/.claude/projects/ for new sessions
- Auto-exports to .dialog/ folder
- Auto-adds to .gitignore (private by default)
- Generates HTML viewer with exported dialogs
- Generates AI summaries after 30 seconds idle

## Usage

1. Run the command above
2. Work with Claude Code as usual
3. Dialogs are exported automatically
4. Press Ctrl+C to stop

## Output

```
.dialog/
├── 2025-12-07_session-abc123.md
├── 2025-12-07_session-def456.md
└── viewer.html
```

## Notes

- Keep watcher running during development
- All dialogs private by default
- Use `/ui` to manage visibility
