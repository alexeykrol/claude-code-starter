---
description: Start auto-export watcher for dialogs
---

# Dialog Watcher

Start automatic export of Claude Code dialogs as they happen.

## Execute

First time setup (install dependencies):
```bash
cd .claude/dist/claude-export && npm install && cd ../../..
```

Then run:
```bash
node .claude/dist/claude-export/cli.js watch
```

## Features

- Monitors ~/.claude/projects/ for new sessions
- Auto-exports to dialog/ folder
- Auto-adds to .gitignore (private by default)
- Generates HTML viewer with exported dialogs

Press Ctrl+C to stop.
