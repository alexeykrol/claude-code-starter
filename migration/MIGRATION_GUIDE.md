# Claude Code Starter Framework — Migration Guide

**Version:** 2.0.5
**Updated:** 2025-12-07

## What is This?

Claude Code Starter Framework is a meta-layer for Claude Code that adds "memory" to AI-assisted development through structured meta files. It provides:

- **Cold Start Protocol** — Resume work with full project context
- **Completion Protocol** — Structured session endings with commits
- **Dialog Export** — Track and share conversation history
- **Slash Commands** — `/commit`, `/fix`, `/feature`, `/pr`, etc.
- **Crash Recovery** — Never lose work if session crashes

## Quick Start

### Option 1: New Project

```bash
# Create new project directory
mkdir my-app && cd my-app

# Download and install framework
curl -LO https://github.com/alexeykrol/claude-code-starter/releases/download/v2.0.5/claude-code-starter-v2.0.5.tar.gz
tar -xzf claude-code-starter-v2.0.5.tar.gz
./init-project.sh
```

### Option 2: Existing Project (Legacy Migration)

```bash
# Navigate to your project
cd your-existing-project

# Download and install framework
curl -LO https://github.com/alexeykrol/claude-code-starter/releases/download/v2.0.5/claude-code-starter-v2.0.5.tar.gz
tar -xzf claude-code-starter-v2.0.5.tar.gz
./init-project.sh
```

## What Happens During Installation?

### For New Projects:
1. ✅ Creates `.claude/` directory structure
2. ✅ Installs framework files (protocols, commands, code)
3. ✅ Generates empty meta files from templates
4. ✅ Sets up npm scripts for dialog management
5. ✅ Creates `FRAMEWORK_GUIDE.md` with usage instructions

### For Existing Projects:
1. ✅ Detects old framework files (if any)
2. ✅ Creates backup → `.claude/.backup-{timestamp}/`
3. ✅ **Commits backup to git** (can rollback!)
4. ✅ Analyzes project structure
5. ✅ Generates meta files populated with project data
6. ✅ Installs framework files
7. ✅ Updates `README.md` with framework link
8. ✅ Creates migration report

## Safety First

### Non-Invasive Installation
- ✅ **Doesn't modify your code** — only adds meta files
- ✅ **Doesn't change project structure** — framework lives in `.claude/`
- ✅ **Works with any stack** — Python, Node.js, Go, Rust, etc.

### Automatic Backup
- ✅ All old framework files backed up before changes
- ✅ Backup committed to git (can be restored)
- ✅ Migration report shows what changed

### Easy Rollback
```bash
# Full rollback (removes both backup and migration commits)
git reset --hard HEAD~2

# Restore specific file
git checkout HEAD~1 -- .claude/SNAPSHOT.md
```

## What Gets Installed?

```
your-project/
├── CLAUDE.md                   # Framework protocols (for AI)
├── FRAMEWORK_GUIDE.md          # Usage guide (for humans)
│
├── .claude/                    # Framework directory
│   ├── dist/                   # Framework code (compiled)
│   ├── commands/               # Slash commands (/commit, /fix, etc.)
│   ├── SNAPSHOT.md             # Project state
│   ├── BACKLOG.md              # Tasks
│   ├── ARCHITECTURE.md         # Code structure
│   ├── .last_session           # Session tracking
│   └── templates/              # Meta file templates
│
├── dialog/                     # Generated after first session
├── html-viewer/                # Generated after first session
│
└── (your project files...)     # Untouched!
```

## Requirements

- **Git** — Framework uses git for backups and commits
- **Node.js** — For dialog export functionality (optional)
- **Claude Code** — AI coding assistant

## After Installation

1. Open your project in Claude Code
2. Type: `start` or `начать`
3. Claude will load project context and be ready to work
4. See `FRAMEWORK_GUIDE.md` for full usage instructions

## Troubleshooting

### Installation Fails
```bash
# Check if git is initialized
git status

# If not, initialize git first
git init
git add .
git commit -m "Initial commit"

# Then run installation again
./init-project.sh
```

### Old Framework Detected
If installation detects old framework files:
1. All old files will be backed up
2. Backup will be committed to git
3. New framework will be installed
4. Check `.claude/MIGRATION_REPORT.md` for details

### Want to Uninstall?
```bash
# Remove framework files (keeps your code)
rm -rf .claude/
rm CLAUDE.md FRAMEWORK_GUIDE.md
rm -rf dialog/ html-viewer/

# Remove npm scripts (if added to package.json)
# Edit package.json manually to remove dialog:* scripts
```

## Support

- **Documentation:** https://github.com/alexeykrol/claude-code-starter
- **Issues:** https://github.com/alexeykrol/claude-code-starter/issues
- **Discussions:** https://github.com/alexeykrol/claude-code-starter/discussions

## What's Next?

After installation, see **FRAMEWORK_GUIDE.md** in your project root for:
- Daily workflow with Cold Start / Completion protocols
- Available slash commands
- Dialog export and viewing
- Best practices

---

**Ready to install?** Run `./init-project.sh` in your project directory.
