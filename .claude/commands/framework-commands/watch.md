---
description: Start auto-export watcher for dialogs
---

# Dialog Watcher

Start automatic export of Claude Code dialogs as they happen.

## Execute

```bash
node .claude/dist/claude-export/cli.js watch
```

**Note:** Dependencies are installed automatically on first run.

## Features

- Monitors ~/.claude/projects/ for new sessions
- Auto-exports to dialog/ folder
- Auto-adds to .gitignore (private by default)
- Generates HTML viewer with exported dialogs

Press Ctrl+C to stop.
