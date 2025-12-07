---
description: Launch Web UI for dialog management
---

# Dialog Web UI

Launch the web interface for browsing and managing Claude Code dialogs.

## Command

```bash
npm run dialog:ui
```

Or directly:
```bash
node .claude-export/dist/cli.js ui
```

## Features

- Browse all exported dialogs
- Toggle visibility (public/private)
- Search across dialogs
- View dialog details
- Manage .gitignore entries

## Usage

1. Run the command above
2. Open http://localhost:3333 in browser
3. Browse and manage your dialogs
4. Press Ctrl+C to stop

## Options

```bash
npm run dialog:ui -- --port 8080  # Custom port
```

## Notes

- Dialogs are private by default (in .gitignore)
- Toggle visibility to share specific dialogs
- All processing is local, no external APIs
