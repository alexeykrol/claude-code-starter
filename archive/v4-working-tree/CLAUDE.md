# Project Manifest

See `./manifest.md` for project metadata.

This file defines:
- `project_type`
- `project_priority`

# CLAUDE.md — AI Agent Instructions

**Framework:** Claude Code Starter v4.0.2
**Type:** Meta-framework extending Claude Code capabilities

---

## Architecture: Python Framework Core + Silent Mode Protocols

**NEW in v4.0.0:** Dual-agent architecture (Claude + Codex) with shared state contract and additive adapters.

**Previous versions:**
- v2.4.1-v2.5.1: Modular protocol files (5-6 min, verbose output)
- v2.6.0: Optimized protocols (15-30s, compact output)
- v2.7.0: True silent mode (bash background tasks)

**Why Python utility:**
- Bash = 10 separate commands = terminal spam (task notifications)
- Python = 1 command, structured JSON output, true silent execution
- Faster: 359ms vs minutes (1000x+ improvement)
- Better: parallel execution, easy debugging, cross-platform

**Protocol Files:**
- `.claude/protocols/cold-start-silent.md` — Invisible session initialization
- `.claude/protocols/completion-silent.md` — Invisible sprint finalization
- `.claude/protocols/auto-triggers.md` — Automatic task completion detection

**Python Utility:**
- `src/framework-core/main.py` — CLI entry point
- `python3 src/framework-core/main.py cold-start` — Execute all tasks
- Returns JSON to stdout (AI parses, user sees nothing)
- Logs to `.claude/logs/framework-core/`

**Key improvements in v4.0.0:**
- **Zero terminal noise:** JSON output instead of task notifications
- **1000x faster:** 359ms vs minutes execution time
- **True silent mode:** User sees NOTHING unless error/confirmation needed
- **Parallel execution:** Python threading for all tasks
- **Cross-platform:** Works on Windows native (no WSL)
- **Easy debugging:** Proper code structure vs bash scripts

---

## Triggers

**"start", "начать":**
→ Execute Cold Start Protocol (silent mode)

**Manual Completion:**
**"/fi", "заверши", "завершить", "finish":**
→ Execute Completion Protocol (silent mode)

**Auto-Trigger Detection (NEW in v2.7.0):**
Framework automatically detects task completion and triggers Completion Protocol:

**Explicit keywords** (instant trigger):
- "готово", "сделано", "завершил", "закончил", "done", "completed"
- Framework runs Completion automatically (or asks once, based on config)

**Implicit signals** (suggest commit):
- "задача завершена", "фича готова", "баг исправлен", "тесты проходят"
- Framework suggests: "Commit changes? (Y/n)"

**Significant changes detected** (git analysis):
- 100+ lines changed, or 5+ files modified
- Framework suggests commit

**Context analysis** (AI analyzes conversation):
- Framework detects task completion from conversation flow
- Suggests commit when confidence high

See `.claude/protocols/auto-triggers.md` for full specification.

---

## Cold Start Protocol

**Purpose:** Initialize framework session, load context, prepare for work.

### Routing Logic

**Step 1: Check for First Launch / Migration**

```bash
cat .claude/migration-context.json 2>/dev/null
```

**If file exists** → This is first launch after installation:
- Read `"mode"` field from JSON
- If `"mode": "legacy"` → Execute **Legacy Migration Protocol** (defined below)
- If `"mode": "upgrade"` → Execute **Framework Upgrade Protocol** (defined below)
- If `"mode": "new"` → Execute **New Project Setup Protocol** (defined below)
- After workflow completes, delete marker: `rm .claude/migration-context.json`
- **STOP HERE** — workflow will instruct user to restart session

**If no migration context** → Continue to Step 2

### Step 2: Execute Cold Start Protocol

**Read and execute the SILENT protocol file:**

```
Read .claude/protocols/cold-start-silent.md and execute all steps.
```

**What this file contains:**
- Phase 1: Silent background execution (parallel, 10-20s)
  - 10 background agents: Migration cleanup, Crash detection, Version check, Security cleanup, Dialog export, COMMIT_POLICY check, Git hooks, Config init, Load context, Mark active
- Phase 2: Check results & show ONLY issues (if any)
- Phase 3: Silent completion (show nothing or "✅ Ready")

**Output philosophy:**
- **Silent by default:** Show NOTHING if everything OK
- **Show ONLY:** Crashes, critical errors, (optional) updates
- **Result:** User doesn't think about protocol, just starts working

**Why read fresh:**
- Long sessions → context compaction → protocol details lost
- Reading protocol file ensures complete, up-to-date instructions
- Immune to context compaction (file read is fresh every time)
- ~6.5-7.5k tokens (includes full silent mode logic)

**Token Economy:** Protocol file is self-contained with all error handling.

---

## Completion Protocol

**Purpose:** Invisible sprint finalization. Auto-commit, auto-update metafiles, show ONLY result.

**Read and execute the SILENT protocol file:**

```
Read .claude/protocols/completion-silent.md and execute all steps.
```

**What this file contains:**
- Phase 1: Silent background execution (parallel)
  - 3 background agents: Build, Dialog export, Security cleanup
  - AI updates metafiles in parallel: SNAPSHOT, BACKLOG, CHANGELOG, README, ARCHITECTURE
- Phase 2: Check results & handle errors (silent unless error)
- Phase 3: Silent commit (auto-commit or one confirmation)
- Phase 4: Optional push/PR
- Phase 5: Silent cleanup

**Output philosophy:**
- **Silent by default:** Everything happens in background, NO progress indicators
- **Show ONLY:** Build errors, Security warnings, Commit confirmation (optional)
- **Result:** "✓ Committed (hash)" or nothing at all

**Configuration options:**
```json
{
  "completion": {
    "silent_mode": true,
    "auto_commit": false,        // Ask before commit (safe) or auto-commit
    "show_commit_message": true, // Show for quick review
    "auto_push": false,
    "auto_trigger": true         // Enable auto-detection (see auto-triggers.md)
  }
}
```

**Presets:** "paranoid" (safe), "autopilot" (fully automated), "balanced" (default)

---

## Repository Structure

```
claude-code-starter/
├── src/claude-export/      # Source code (TypeScript)
├── dist/claude-export/     # Compiled JavaScript
├── .claude/
│   ├── commands/           # 19 slash commands
│   ├── protocols/          # Protocol files (True Silent Mode in v2.7.0)
│   │   ├── cold-start-silent.md   #   Invisible session initialization
│   │   ├── completion-silent.md   #   Invisible sprint finalization
│   │   └── auto-triggers.md       #   Automatic task completion detection
│   ├── SNAPSHOT.md         # Current state
│   ├── ARCHITECTURE.md     # Code structure
│   └── BACKLOG.md          # Tasks
├── dialog/                 # Development dialogs
├── reports/                # Migration logs and bug reports
│
├── package.json            # npm scripts
├── tsconfig.json           # TypeScript config
├── CLAUDE.md               # THIS FILE (Router)
├── CHANGELOG.md            # Version history
├── README.md / README_RU.md
└── init-project.sh         # Installer (for distribution)
```

## npm Scripts

```bash
npm run build           # Compile TypeScript
npm run dialog:export   # Export dialogs to dialog/
npm run dialog:ui       # Web UI on :3333
npm run dialog:watch    # Auto-export watcher
npm run dialog:list     # List sessions
```

## Slash Commands

**Core:** `/fi`, `/commit`, `/pr`, `/release`
**Dev:** `/fix`, `/feature`, `/review`, `/test`, `/security`
**Quality:** `/explain`, `/refactor`, `/optimize`
**Installation:** `/migrate-legacy`, `/upgrade-framework`
**Legacy v1.x:** `/migrate`, `/migrate-resolve`, `/migrate-finalize`, `/migrate-rollback`

## Key Principles

1. **Framework as AI Extension** — not just docs, but functionality
2. **Privacy by Default** — dialogs private in .gitignore
3. **Local Processing** — no external APIs
4. **Token Economy** — minimal context loading (NEVER read dialog/ files)

## Warnings

- DO NOT skip Crash Recovery check
- DO NOT forget `npm run build` after code changes
- DO NOT commit without updating metafiles
- ALWAYS mark session clean at completion
- NEVER read files from `dialog/` directory — wastes tokens

---

## Framework Developer Mode

**This section is ONLY for the framework development project (claude-code-starter repo).**

### Step 0.4: Read Bug Reports from Host Projects

**When to run:** During Cold Start on framework project, after Step 0.3 (Protocol Logging).

**Purpose:** Fetch and analyze bug reports submitted by host projects.

```bash
# Check if this is the framework project
if [ -d "migration" ] && [ -f "migration/build-distribution.sh" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Framework Developer Mode Active"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Check for new bug reports on GitHub
  # Note: Use /analyze-bugs command for detailed analysis
  ISSUE_COUNT=$(gh issue list --label "bug-report" --json number --jq length 2>/dev/null || echo "0")

  if [ "$ISSUE_COUNT" -gt "0" ]; then
    echo "⚠️  $ISSUE_COUNT bug report(s) available from host projects"
    echo ""
    echo "To analyze:"
    echo "  • Run: /analyze-bugs"
    echo "  • Or view: gh issue list --label bug-report"
    echo ""
  else
    echo "✅ No new bug reports"
    echo ""
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

**Notes:**
- Only activates on framework project (checks for `migration/build-distribution.sh`)
- Shows count of open bug reports with `bug-report` label
- Directs to `/analyze-bugs` command for detailed analysis
- Does NOT activate on host projects

---

## Legacy Migration Protocol

**Triggered when:** `.claude/migration-context.json` exists with `"mode": "legacy"`

**Purpose:** Analyze existing project and generate Framework files.

**Workflow:**

1. **Read migration context:**
   ```bash
   cat .claude/migration-context.json
   ```

2. **Execute `/migrate-legacy` command:**
   - Follow instructions in `.claude/commands/migrate-legacy.md`
   - Discovery → Deep Analysis → Questions → Report → Generate Files

3. **After completion:**
   - Verify all Framework files created
   - Delete migration marker:
     ```bash
     rm .claude/migration-context.json
     ```
   - Show success summary

4. **Next session:**
   - Use normal Cold Start Protocol

---

## Framework Upgrade Protocol

**Triggered when:** `.claude/migration-context.json` exists with `"mode": "upgrade"`

**Purpose:** Migrate from old Framework version to v2.1.

**Workflow:**

1. **Read migration context:**
   ```bash
   cat .claude/migration-context.json
   ```
   Extract `old_version` field.

2. **Execute `/upgrade-framework` command:**
   - Follow instructions in `.claude/commands/upgrade-framework.md`
   - Detect Version → Migration Plan → Backup → Execute → Verify

3. **After completion:**
   - Verify migration successful
   - Delete migration marker:
     ```bash
     rm .claude/migration-context.json
     ```
   - Show success summary

4. **Next session:**
   - Use normal Cold Start Protocol with new structure

---

## New Project Setup Protocol

**Triggered when:** `.claude/migration-context.json` exists with `"mode": "new"`

**Purpose:** Verify Framework installation and welcome user.

**Workflow:**

1. **Show welcome message:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ Установка завершена!
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   📁 Framework Files Created:

     ✅ .claude/SNAPSHOT.md
     ✅ .claude/BACKLOG.md
     ✅ .claude/ROADMAP.md
     ✅ .claude/ARCHITECTURE.md
     ✅ .claude/IDEAS.md

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   🚀 Next Step:

     Введите команду "start" или "начать", чтобы фреймворк запустился.
     (Type "start" or "начать" to launch the framework)

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

2. **Delete migration marker:**
   ```bash
   rm .claude/migration-context.json
   ```

3. **Next session:**
   - Use normal Cold Start Protocol

---
*Framework: Claude Code Starter v4.0.2 | Updated: 2026-02-11*


### Делегирование задач субагентам

При получении задачи от пользователя — сначала оценить:
- **Сам:** быстрые правки (< 2 мин), обсуждения, анализ, вопросы, мелкие фиксы
- **Субагент:** код > 50 строк, новые модули, рефакторинг, UI-изменения, исследования, любые задачи > 5 мин

При делегировании субагенту:
- Составить детальное ТЗ с контекстом, файлами для чтения, ожидаемым результатом
- Запустить в фоне
- Сообщить пользователю что запущено
- По завершении — дать краткий отчёт о результате
- Можно запускать несколько субагентов параллельно на независимые задачи

Цель: максимальная параллельность и минимальное время ожидания пользователя.
