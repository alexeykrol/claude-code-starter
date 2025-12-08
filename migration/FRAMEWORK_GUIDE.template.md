# Working with Claude Code Starter Framework

> 🤖 This project uses **Claude Code Starter Framework v2.0** for AI-assisted development.

## Quick Reference

### Starting Your Day
```bash
# In Claude Code, type:
start
# or in Russian:
начать
```

### Ending Your Day
```bash
# In Claude Code, type:
/fi
# or:
finish
завершить
```

## What is This Framework?

Claude Code Starter adds "memory" to Claude through structured meta files. When you start a session, Claude reads your project context and resumes exactly where you left off.

### Key Benefits:
- ✅ **Context Persistence** — Claude remembers your project
- ✅ **Crash Recovery** — Never lose work
- ✅ **Dialog History** — Track all conversations
- ✅ **Structured Workflow** — Cold Start → Work → Completion
- ✅ **Slash Commands** — Quick access to common tasks

## Daily Workflow

### 1. Cold Start Protocol (Beginning of Session)

When you type `start`, the framework:
1. Checks for crashed sessions (and recovers if needed)
2. Exports closed dialog sessions from previous work
3. Updates student UI (html-viewer) with latest dialogs
4. Marks session as active
5. Loads project context from `.claude/SNAPSHOT.md`
6. Ready to work!

### 2. Working

Use slash commands for common tasks:
- `/commit` — Create git commit with proper message
- `/fix` — Debug and fix bugs
- `/feature` — Plan and implement new features
- `/review` — Code review of recent changes
- `/test` — Write tests for code
- `/pr` — Create pull request
- `/security` — Security audit
- `/optimize` — Performance optimization

See `.claude/commands/` for all available commands.

### 3. Completion Protocol (End of Session)

When you type `/fi`, the framework:
1. Builds project (if code changed)
2. Updates meta files (SNAPSHOT, BACKLOG, CHANGELOG)
3. Exports dialogs (without HTML, current session still active)
4. Creates git commit
5. Optionally pushes to remote
6. Marks session as clean

## Framework Files

### For Claude (AI Memory)

```
.claude/
├── SNAPSHOT.md       # Current project state
├── BACKLOG.md        # Your tasks and TODOs
├── ARCHITECTURE.md   # Code structure
├── .last_session     # Session tracking
└── commands/         # Slash commands
```

**Edit these files** to update Claude's understanding of your project.

### For You (Human)

- `CLAUDE.md` — Framework protocols (don't edit)
- `FRAMEWORK_GUIDE.md` — This file
- `.claude/MIGRATION_REPORT.md` — Migration details (if applicable)

### Generated (Auto-Created)

- `dialog/` — Exported conversation history
- `html-viewer/` — Static web viewer for dialogs

## Viewing Your Dialogs

### Web UI (Teacher Mode)
```bash
npm run dialog:ui
```
Opens at http://localhost:3333
- Browse all dialogs
- Toggle visibility (public/private)
- Force sync current session
- Search across conversations

### Static HTML (Student Mode)
Open `html-viewer/index.html` in browser
- Shareable, standalone HTML
- No server needed
- Updates on Cold Start Protocol

## Important Commands

### Dialog Management
```bash
npm run dialog:list        # List all sessions
npm run dialog:export      # Export dialogs manually
npm run dialog:watch       # Auto-export watcher
npm run dialog:ui          # Web UI for management
```

### Framework Commands
```bash
node .claude/dist/cli.js generate-html    # Regenerate student UI
node .claude/dist/cli.js init             # Reinitialize framework
```

## Customizing Framework

### Update Project Context

Edit `.claude/SNAPSHOT.md`:
```markdown
## Current State

**Version:** 1.2.3
**Status:** Working on authentication feature
**Branch:** feat/auth

## Recent Progress
- [x] Implemented login form
- [x] Added JWT tokens
- [ ] Need to add refresh token logic
```

### Update Tasks

Edit `.claude/BACKLOG.md`:
```markdown
## Active Sprint

### High Priority
- [ ] Implement refresh token logic
- [ ] Add password reset flow

### Medium Priority
- [ ] Improve error handling
- [ ] Add loading states
```

### Update Architecture

Edit `.claude/ARCHITECTURE.md` when your code structure changes significantly.

## Privacy & Git

### By Default:
- ✅ `dialog/` is in `.gitignore` (private)
- ✅ `html-viewer/` is in `.gitignore` (private)
- ✅ `.claude/.last_session` is in `.gitignore`

### To Share Dialogs:
1. Open `npm run dialog:ui`
2. Toggle checkbox next to dialog
3. Dialog becomes public (committed to git)

Or edit `.gitignore` manually.

## Troubleshooting

### Claude doesn't see latest changes
```bash
# Manually update current session
npm run dialog:export

# Or force sync in UI
npm run dialog:ui
# Click "Force Sync" button
```

### Session crashed
Next time you start:
1. Framework detects crash
2. Shows uncommitted changes
3. Asks: "Continue or commit first?"
4. You choose how to recover

### Want to see what Claude sees
```bash
# Read Claude's memory
cat .claude/SNAPSHOT.md
cat .claude/BACKLOG.md
cat .claude/ARCHITECTURE.md
```

## Best Practices

1. **Update SNAPSHOT regularly** — Keep Claude's context fresh
2. **Use slash commands** — Faster than typing full requests
3. **Run /fi at end of day** — Ensures clean state
4. **Review dialogs** — Learn from past conversations
5. **Keep BACKLOG current** — Helps Claude prioritize

## Support

- **Framework Docs:** https://github.com/alexeykrol/claude-code-starter
- **Issues:** https://github.com/alexeykrol/claude-code-starter/issues
- **Your Project:** See `README.md` for project-specific info

---

**Remember:** The framework is for Claude, not your code. Your project runs independently of the framework.
