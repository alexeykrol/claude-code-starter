# CLAUDE.md — AI Agent Instructions

**Framework:** Claude Code Starter v2.5.1
**Type:** Meta-framework extending Claude Code capabilities

---

## Architecture: Hybrid Protocol Files

**NEW in v2.4.1:** Protocols are now modular files, immune to context compaction.

**Why this matters:**
- Long sessions → context compaction → protocol details lost
- Solution: Protocol files are read FRESH each time
- No agent overhead (fast, deterministic)
- CLAUDE.md becomes simple router

**Protocol Files:**
- `.claude/protocols/cold-start.md` — Session initialization
- `.claude/protocols/completion.md` — Sprint finalization

---

## Triggers

**"start", "начать":**
→ Execute Cold Start Protocol

**"заверши", "завершить", "finish", "done":**
→ Execute Completion Protocol

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

**Read and execute the protocol file:**

```
Read .claude/protocols/cold-start.md and execute all steps.
```

**What this file contains:**
- Step 0.05: Migration Cleanup Recovery
- Step 0.1: Crash Recovery & Auto-Recovery
- Step 0.2: Framework Version Check
- Step 0.15: Bug Reporting Consent (first run only)
- Step 0.3: Initialize Protocol Logging
- Step 0.4: Framework Developer Mode (framework project only)
- Step 0.5: Security Cleanup & Export Sessions
- Step 1: Mark Session Active
- Step 2: Load Context (SNAPSHOT, BACKLOG, ARCHITECTURE)
- Step 3: Context ON DEMAND (ROADMAP, IDEAS, CHANGELOG)
- Step 4: Confirm

**Why read fresh:**
- Long sessions → context compaction → protocol details lost
- Reading protocol file ensures complete, up-to-date instructions
- Immune to context compaction (file read is fresh every time)
- ~3-5k tokens vs 50-100k for full project scan

**Token Economy:** Protocol file is compact and self-contained.

---

## Completion Protocol

**Purpose:** Finalize sprint/task, update metafiles, export sessions, commit changes.

**Read and execute the protocol file:**

```
Read .claude/protocols/completion.md and execute all steps.
```

**What this file contains:**
- Step 0: Re-read Completion Protocol (Self-Check)
- Step 0.1: Initialize Completion Logging
- Step 1: Build (if code changed)
- Step 2: Update Metafiles (BACKLOG, SNAPSHOT, CHANGELOG, README, ARCHITECTURE)
- Step 2.1: Version Bumping (if creating release)
- Step 3: Export Dialogs
- Step 3.5: Security - Clean Current Dialog + Smart Trigger Detection
- Step 4: Git Commit
- Step 5: Ask About Push & PR
- Step 6: Mark Session Clean
- Step 6.5: Finalize Completion Log & Create Bug Report

**Why read fresh:**
- Long sessions → context compaction → protocol details lost
- Reading protocol file ensures complete, up-to-date instructions
- Immune to context compaction (file read is fresh every time)
- Includes full security decision logic for trigger handling

**Token Economy:** Protocol file is compact and self-contained (~3-4k tokens)

---

## Repository Structure

```
claude-code-starter/
├── src/claude-export/      # Source code (TypeScript)
├── dist/claude-export/     # Compiled JavaScript
├── .claude/
│   ├── commands/           # 19 slash commands
│   ├── protocols/          # Protocol files (NEW in v2.4.1)
│   │   ├── cold-start.md   #   Session initialization
│   │   └── completion.md   #   Sprint finalization
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
*Framework: Claude Code Starter v2.5.1 | Updated: 2026-01-17*
