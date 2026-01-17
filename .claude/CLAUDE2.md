# CLAUDE.md — AI Agent Instructions

**Framework:** Claude Code Starter v2.0
**Type:** Meta-framework extending Claude Code capabilities

## Triggers

**"start", "начать":**
→ Execute Cold Start Protocol

**"заверши", "завершить", "finish", "done":**
→ Execute Completion Protocol

---

## Cold Start Protocol

### Step 0: First Launch Detection

**Check for migration context first:**
```bash
cat .claude/migration-context.json 2>/dev/null
```

If file exists, this is first launch after installation.

**Read context and route:**
- If `"mode": "legacy"` → Execute Legacy Migration workflow (see below)
- If `"mode": "upgrade"` → Execute Framework Upgrade workflow (see below)
- If `"mode": "new"` → Execute New Project Setup workflow (see below)

After completing workflow, delete marker:
```bash
rm .claude/migration-context.json
```

If no migration context, continue to Step 0.05 (Migration Cleanup).

---

### Step 0.05: Migration Cleanup Recovery

Check for leftover migration files and clean them up:

```bash
# Check for production CLAUDE.md waiting to be swapped
if [ -f ".claude/CLAUDE.production.md" ]; then
  echo "⚠️  Found leftover migration files. Cleaning up..."

  # Swap CLAUDE.md if needed
  if grep -q "Migration Mode" CLAUDE.md 2>/dev/null; then
    cp .claude/CLAUDE.production.md CLAUDE.md
    echo "✓ Swapped CLAUDE.md to production version"
  fi

  # Remove all migration artifacts
  rm -f .claude/CLAUDE.production.md
  rm -f .claude/migration-context.json
  rm -f .claude/migration-log.json
  rm -f .claude/commands/migrate-legacy.md
  rm -f .claude/commands/upgrade-framework.md
  rm -f .claude/framework-pending.tar.gz

  echo "✓ Migration cleanup complete"
fi
```

If cleanup performed, continue to Step 0.1 (Crash Recovery).

If no cleanup needed, continue to Step 0.1 (Crash Recovery).

---

### Step 0.1: Crash Recovery & Auto-Recovery
```bash
cat .claude/.last_session
```
- If `"status": "active"` → Check if real crash or just missing `/fi`:
  ```bash
  # Check for uncommitted changes
  if git diff --quiet && git diff --staged --quiet; then
    # Working tree clean - probably forgot /fi
    echo "ℹ️  Previous session didn't run /fi but working tree is clean."
    echo "Auto-recovering to clean state..."
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
    # Continue to Step 0.5
  else
    # True crash - has uncommitted changes
    echo "⚠️  Previous session crashed with uncommitted changes"
    git status
    npm run dialog:export --no-html
    # Read .claude/SNAPSHOT.md for context
    # Ask: "Continue or commit first?"
  fi
  ```
- If `"status": "clean"` → OK, continue to Step 0.2

### Step 0.2: Framework Version Check

**Purpose:** Automatically update framework to latest version if available.

```bash
# 1. Parse local version from CLAUDE.md
LOCAL_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

# 2. Get latest version from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/alexeykrol/claude-code-starter/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')

# 3. If newer version available - auto-update (aggressive)
if [ "$LOCAL_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "" ]; then
  echo "📦 Framework update available: v$LOCAL_VERSION → v$LATEST_VERSION"
  echo "Updating framework..."

  # Download CLAUDE.md
  curl -sL "https://github.com/alexeykrol/claude-code-starter/releases/download/v$LATEST_VERSION/CLAUDE.md" -o CLAUDE.md.new

  # Download framework commands (5 files)
  curl -sL "https://github.com/alexeykrol/claude-code-starter/releases/download/v$LATEST_VERSION/framework-commands.tar.gz" -o /tmp/fw-cmd.tar.gz

  # Verify downloads successful
  if [ -f "CLAUDE.md.new" ] && [ -f "/tmp/fw-cmd.tar.gz" ]; then
    # Replace CLAUDE.md
    mv CLAUDE.md.new CLAUDE.md

    # Extract commands
    tar -xzf /tmp/fw-cmd.tar.gz -C .claude/commands/
    rm /tmp/fw-cmd.tar.gz

    echo "✅ Framework updated to v$LATEST_VERSION"
    echo ""
    echo "⚠️  IMPORTANT: Restart this session to use new framework version"
    echo "   Type 'exit' and start new session with 'claude'"
    echo ""
  else
    echo "⚠️  Update failed - continuing with v$LOCAL_VERSION"
    rm -f CLAUDE.md.new /tmp/fw-cmd.tar.gz
  fi
fi
```

**Notes:**
- Updates only framework files (CLAUDE.md + 5 commands)
- Does NOT touch user files (SNAPSHOT.md, BACKLOG.md, etc.)
- Safe to run - preserves all project data
- Requires session restart to use new version

---

### Step 0.15: Bug Reporting Consent (First Run Only)

**Purpose:** Ask user for consent to collect anonymous bug reports on first framework run.

```bash
# Check if first run or consent not yet given
if [ ! -f ".claude/.framework-config" ]; then
  # Initialize config file
  PROJECT_NAME=$(basename "$(pwd)")
  cat > .claude/.framework-config <<EOF
{
  "bug_reporting_enabled": false,
  "project_name": "$PROJECT_NAME",
  "first_run_completed": false,
  "consent_version": "1.0"
}
EOF
fi

# Read config
FIRST_RUN=$(cat .claude/.framework-config | grep -o '"first_run_completed": *[^,}]*' | sed 's/.*: *//' | tr -d ' ')

if [ "$FIRST_RUN" = "false" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔒 Framework Bug Reporting"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "The framework can collect anonymous bug reports to help improve it."
  echo ""
  echo "What gets sent (if errors occur):"
  echo "  • Error messages and stack traces (anonymized)"
  echo "  • Framework version and protocol step"
  echo "  • Timestamp"
  echo ""
  echo "What does NOT get sent:"
  echo "  • Your code or file contents"
  echo "  • File paths (anonymized)"
  echo "  • API keys, tokens, secrets (removed)"
  echo "  • Project name (anonymized)"
  echo ""
  echo "Reports are sent to: github.com/alexeykrol/claude-code-starter/issues"
  echo ""
  echo "You can change this anytime with: /bug-reporting enable|disable"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Ask for consent
  read -p "Enable anonymous bug reporting? (y/N) " -n 1 -r
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Enable bug reporting
    cat .claude/.framework-config | sed 's/"bug_reporting_enabled": false/"bug_reporting_enabled": true/' | sed 's/"first_run_completed": false/"first_run_completed": true/' > .claude/.framework-config.tmp
    mv .claude/.framework-config.tmp .claude/.framework-config
    echo "✅ Bug reporting enabled. Thank you for helping improve the framework!"
  else
    # Mark first run complete but keep disabled
    cat .claude/.framework-config | sed 's/"first_run_completed": false/"first_run_completed": true/' > .claude/.framework-config.tmp
    mv .claude/.framework-config.tmp .claude/.framework-config
    echo "ℹ️  Bug reporting disabled. You can enable it later with: /bug-reporting enable"
  fi
  echo ""
fi
```

**Notes:**
- Only runs once on first framework launch
- Stores preference in `.claude/.framework-config`
- Can be changed anytime with `/bug-reporting` command
- Fully opt-in, default is disabled

---

### Step 0.3: Initialize Protocol Logging

**Purpose:** Set up logging for Cold Start protocol execution (if enabled).

```bash
# Check if bug reporting enabled
if [ -f ".claude/.framework-config" ]; then
  BUG_REPORTING=$(cat .claude/.framework-config | grep -o '"bug_reporting_enabled": *[^,}]*' | sed 's/.*: *//' | tr -d ' ')

  if [ "$BUG_REPORTING" = "true" ]; then
    # Create log directory
    mkdir -p .claude/logs/cold-start

    # Generate log filename with timestamp
    PROJECT_NAME=$(basename "$(pwd)")
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    LOG_FILE=".claude/logs/cold-start/${PROJECT_NAME}-${TIMESTAMP}.md"

    # Initialize log file
    cat > "$LOG_FILE" <<EOF
# Cold Start Protocol Log

**Project:** ${PROJECT_NAME}_anon
**Started:** $(date -Iseconds)
**Framework:** $(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v/v/')

## Protocol Execution

EOF

    # Export log file path for use in subsequent steps
    export COLD_START_LOG="$LOG_FILE"

    # Log function
    log_step() {
      if [ -n "$COLD_START_LOG" ]; then
        echo "- [$(date +%H:%M:%S)] $1" >> "$COLD_START_LOG"
      fi
    }

    # Log error function
    log_error() {
      if [ -n "$COLD_START_LOG" ]; then
        echo "" >> "$COLD_START_LOG"
        echo "## ⚠️ ERROR at $(date +%H:%M:%S)" >> "$COLD_START_LOG"
        echo "" >> "$COLD_START_LOG"
        echo '```' >> "$COLD_START_LOG"
        echo "$1" >> "$COLD_START_LOG"
        echo '```' >> "$COLD_START_LOG"
        echo "" >> "$COLD_START_LOG"
      fi
    }

    export -f log_step log_error

    log_step "Step 0.3: Logging initialized"
  fi
fi
```

**Notes:**
- Only creates logs if bug reporting is enabled
- Log files named: `{project}-{timestamp}.md`
- Stored in `.claude/logs/cold-start/` (gitignored)
- Includes project name (anonymized), timestamp, framework version
- Provides `log_step()` and `log_error()` functions for protocol steps

---

### Step 0.5: Clean Last Dialog & Export Sessions
```bash
# Security: Clean LAST dialog (from previous session)
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last
fi

npm run dialog:export --no-html

node dist/claude-export/cli.js generate-html
git add html-viewer/index.html && git commit -m "chore: Update student UI with latest dialogs"
```
- Exports any closed sessions from previous work (without HTML generation)
- **Security check:** Runs cleanup script to remove production credentials
- Verifies no credentials leaked into dialogs
- Syncs current active session (if exists)
- Generates html-viewer/index.html with ALL closed sessions (including last closed one)
- Auto-commits student UI so students see complete dialog history
- This ensures students see the most recent closed session

### Step 1: Mark Session Active
```bash
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

### Step 2: Load Context (ALWAYS read — keep compact!)
- `.claude/SNAPSHOT.md` — current version, what's in progress (~30-50 lines)
- `.claude/BACKLOG.md` — current sprint tasks (~50-100 lines)
- `.claude/ARCHITECTURE.md` — code structure (~100-200 lines)

### Step 3: Context (ON DEMAND — read when needed)
- `.claude/ROADMAP.md` — strategic direction (when planning)
- `.claude/IDEAS.md` — ideas backlog (when exploring ideas)
- `CHANGELOG.md` — version history (when need history)

### Step 4: Confirm
```
Context loaded. Directory: [pwd]
Framework: Claude Code Starter v2.2
Ready to work!
```

> **Token Economy:** Files in Step 2 are read EVERY session — keep them compact.
> Historical/strategic content → Step 3 files or CHANGELOG.md.

---

## Completion Protocol

### 0. Initialize Completion Logging

**Purpose:** Set up logging for Completion protocol execution (if enabled).

```bash
# Check if bug reporting enabled
if [ -f ".claude/.framework-config" ]; then
  BUG_REPORTING=$(cat .claude/.framework-config | grep -o '"bug_reporting_enabled": *[^,}]*' | sed 's/.*: *//' | tr -d ' ')

  if [ "$BUG_REPORTING" = "true" ]; then
    # Create log directory
    mkdir -p .claude/logs/completion

    # Generate log filename with timestamp
    PROJECT_NAME=$(basename "$(pwd)")
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    LOG_FILE=".claude/logs/completion/${PROJECT_NAME}-${TIMESTAMP}.md"

    # Initialize log file
    cat > "$LOG_FILE" <<EOF
# Completion Protocol Log

**Project:** ${PROJECT_NAME}_anon
**Started:** $(date -Iseconds)
**Framework:** $(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v/v/')

## Protocol Execution

EOF

    # Export log file path for use in subsequent steps
    export COMPLETION_LOG="$LOG_FILE"

    # Log function
    log_completion_step() {
      if [ -n "$COMPLETION_LOG" ]; then
        echo "- [$(date +%H:%M:%S)] $1" >> "$COMPLETION_LOG"
      fi
    }

    # Log error function
    log_completion_error() {
      if [ -n "$COMPLETION_LOG" ]; then
        echo "" >> "$COMPLETION_LOG"
        echo "## ⚠️ ERROR at $(date +%H:%M:%S)" >> "$COMPLETION_LOG"
        echo "" >> "$COMPLETION_LOG"
        echo '```' >> "$COMPLETION_LOG"
        echo "$1" >> "$COMPLETION_LOG"
        echo '```' >> "$COMPLETION_LOG"
        echo "" >> "$COMPLETION_LOG"
      fi
    }

    export -f log_completion_step log_completion_error

    log_completion_step "Step 0: Logging initialized"
  fi
fi
```

**Notes:**
- Only creates logs if bug reporting is enabled
- Log files named: `{project}-{timestamp}.md`
- Stored in `.claude/logs/completion/` (gitignored)

---

### 1. Build (if code changed)
```bash
npm run build
```

### 2. Update Metafiles
- `.claude/BACKLOG.md` — mark completed tasks `[x]`
- `.claude/SNAPSHOT.md` — update version and status
- `CHANGELOG.md` — add entry (if release)
- `README.md` + `README_RU.md` — update if major features added
- `.claude/ARCHITECTURE.md` — update if code structure changed

### 2.1 Version Bumping (if creating release)

**Semantic Versioning (X.Y.Z):**
- **X** (major) — breaking changes, major architecture rewrites
- **Y** (minor) — new features, significant improvements (e.g., 2.1.0 → 2.2.0)
- **Z** (patch) — bug fixes, small tweaks (e.g., 2.2.0 → 2.2.1)

**Files to update with new version:**
- `init-project.sh` — line 4 (comment) and line 11 (VERSION variable)
- `migration/build-distribution.sh` — line 4 (comment) and line 12 (VERSION variable)
- `README.md` — version badge (line ~13)
- `README_RU.md` — version badge (line ~13)
- `.claude/SNAPSHOT.md` — Version field
- `CHANGELOG.md` — new section header

**After version bump:**
1. Run `bash migration/build-distribution.sh` to rebuild dist-release/
2. Create GitHub Release with `gh release create vX.Y.Z dist-release/init-project.sh dist-release/framework.tar.gz`

### 3. Export Dialogs
```bash
npm run dialog:export --no-html
```
- Exports dialog sessions without generating html-viewer
- Student UI (html-viewer) is NOT updated here (current session still active)
- Student UI will be updated on next Cold Start (Step 0.5)

### 3.5. Security: Clean Current Dialog
```bash
# Clean CURRENT dialog (this session) before commit
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last
fi
```
- **Purpose:** Prevent credentials from leaking into git
- Cleans only LAST dialog (current session) — fast, not all 300+ files
- Removes: SSH hosts, IPs, Supabase project IDs, JWT tokens
- Blocks git commit if violations detected
- **CRITICAL:** This step protects production infrastructure from exposure

### 4. Git Commit
```bash
git add -A && git status
git commit -m "$(cat <<'EOF'
type: Brief description

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 5. Ask About Push & PR

**Push:**
- Ask user: "Push to remote?"
- If yes: `git push`

**Check PR status:**
```bash
git log origin/main..HEAD --oneline
```
- If **empty** → All merged, no PR needed
- If **has commits** → Ask: "Create PR?"

### 5.5 Create GitHub Release (if applicable)

**Purpose:** Automatically create GitHub release when version changes.

**Check if project uses releases:**
```bash
RELEASE_COUNT=$(gh release list --limit 1 2>/dev/null | wc -l | tr -d ' ')
```

**If project uses releases (RELEASE_COUNT > 0):**

1. **Extract current version from README:**
   ```bash
   CURRENT_VERSION=$(grep -o 'version-[0-9.]*' README.md | head -1 | sed 's/version-//')
   ```

2. **Check if this version already has a release:**
   ```bash
   EXISTING_RELEASE=$(gh release view "v$CURRENT_VERSION" 2>/dev/null)
   ```

3. **If release doesn't exist, create it:**
   ```bash
   if [ -z "$EXISTING_RELEASE" ] && [ -n "$CURRENT_VERSION" ]; then
     echo "Creating GitHub Release v$CURRENT_VERSION..."

     # Extract changelog entry for this version
     CHANGELOG_ENTRY=$(awk "/## \[$CURRENT_VERSION\]/,/## \[/" CHANGELOG.md | sed '$d' | tail -n +2)

     # Create release
     gh release create "v$CURRENT_VERSION" \
       --title "v$CURRENT_VERSION" \
       --notes "$CHANGELOG_ENTRY"

     echo "✅ GitHub Release v$CURRENT_VERSION created"
   else
     echo "ℹ️  Release v$CURRENT_VERSION already exists or version not found"
   fi
   ```

**Notes:**
- Only runs if project has existing releases (detects via `gh release list`)
- Reads version from README badge (format: `version-X.Y.Z`)
- Reads release notes from CHANGELOG.md for that version
- Skips if release already exists (idempotent)
- Safe to run - won't create duplicates

### 6. Mark Session Clean
```bash
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

### 6.5 Finalize Completion Log & Create Bug Report

**Purpose:** Complete the log, check for errors, and create bug report if needed.

```bash
# Finalize log if enabled
if [ -n "$COMPLETION_LOG" ] && [ -f "$COMPLETION_LOG" ]; then
  log_completion_step "Step 6: Session marked clean"

  # Add completion timestamp
  cat >> "$COMPLETION_LOG" <<EOF

## Completion

**Finished:** $(date -Iseconds)
**Status:** Success
EOF

  echo "✅ Completion log saved: $COMPLETION_LOG"

  # Check if bug reporting is enabled
  if [ -f ".claude/.framework-config" ] && grep -q '"bug_reporting_enabled": true' ".claude/.framework-config" 2>/dev/null; then
    # Check if there were any errors in the log
    if grep -q "## ⚠️ ERROR" "$COMPLETION_LOG"; then
      echo ""
      echo "⚠️  Errors detected during completion protocol"
      echo "Log contains error information: $COMPLETION_LOG"
      echo ""
    else
      echo ""
      echo "✓ Completion protocol executed successfully (no errors)"
      echo ""
    fi

    # ALWAYS offer to create bug report (for analytics & telemetry)
    echo "📊 Bug reporting is enabled (analytics & telemetry)"
    read -p "Create anonymized report? (y/N) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Run anonymization script
      if [ -f ".claude/scripts/anonymize-report.sh" ]; then
        REPORT_FILE=$(bash .claude/scripts/anonymize-report.sh "$COMPLETION_LOG")
        echo "✅ Report created: $REPORT_FILE"
        echo ""

        # Offer to submit to GitHub automatically
        read -p "Submit report to GitHub? (y/N) " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
          # Submit to GitHub Issues
          if [ -f ".claude/scripts/submit-bug-report.sh" ]; then
            ISSUE_URL=$(bash .claude/scripts/submit-bug-report.sh "$REPORT_FILE")
            if [ $? -eq 0 ]; then
              echo "✅ Submitted to GitHub: $ISSUE_URL"
            fi
          else
            echo "⚠️  Submit script not found"
            echo "You can submit manually: github.com/alexeykrol/claude-code-starter/issues"
          fi
        else
          echo "ℹ️  Report saved locally: $REPORT_FILE"
          echo "You can submit later: github.com/alexeykrol/claude-code-starter/issues"
        fi
      else
        echo "⚠️  Anonymization script not found"
        echo "Manual review needed before sharing: $COMPLETION_LOG"
      fi
    fi
  fi
fi
```

**Notes:**
- Finalizes log with completion timestamp
- Checks for errors in log
- **ALWAYS offers to create bug report if bug reporting is enabled** (for analytics & telemetry)
- Creates report regardless of errors (successful executions are valuable data)
- Uses anonymization script to remove sensitive data
- Two-step confirmation: create report → submit to GitHub

---

## Repository Structure

```
claude-code-starter/
├── src/claude-export/      # Source code (TypeScript)
├── dist/claude-export/     # Compiled JavaScript
├── .claude/
│   ├── commands/           # 19 slash commands
│   ├── SNAPSHOT.md         # Current state
│   ├── ARCHITECTURE.md     # Code structure
│   └── BACKLOG.md          # Tasks
├── dialog/                 # Development dialogs
├── reports/                # Migration logs and bug reports
│
├── package.json            # npm scripts
├── tsconfig.json           # TypeScript config
├── CLAUDE.md               # THIS FILE
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
4. **Token Economy** — minimal context loading

## Warnings

- DO NOT skip Crash Recovery check
- DO NOT forget `npm run build` after code changes
- DO NOT commit without updating metafiles
- ALWAYS mark session clean at completion

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

## Production Deployment Rules

**⚠️ CRITICAL: Read before ANY production operations**

### Rule #1: NO Cache Management

**NEVER touch cache without explicit user permission.**

```
❌ FORBIDDEN:
- Cache clearing commands
- Cache configuration changes
- Suggesting cache-related fixes
- Accessing cache management panels
```

**Reason:** All plugin pages (`/test-no-elem-2/`, `/reg_*/`, auth forms) are **already excluded** from LiteSpeed Cache. User has configured this correctly. Do NOT interfere.

### Rule #2: File Upload Locations

**WordPress plugin files MUST go to plugin directory:**

```bash
# ✅ CORRECT:
scp file.php alexeykrol-prod:/home/.../wp-content/plugins/supabase-bridge/

# ❌ WRONG:
scp file.html alexeykrol-prod:/home/.../public_html/
```

**Files:**
- `supabase-bridge.php` → plugin directory
- `auth-form.html` → plugin directory
- `callback.html` → plugin directory

Plugin reads files from its own directory, NOT site root.

### Rule #3: Always Ask Before Deploy

**NEVER deploy without explicit "yes" / "да" / "deploy".**

1. Show what will be changed
2. Wait for user confirmation
3. Only then execute `scp` commands

### Rule #4: SSH Credentials

**Always use credentials from `.production-credentials`:**
- SSH key: `~/.ssh/claude_prod_new`
- Port: `65002`
- Host: `45.145.187.249`
- User: `u465545808`
- Alias: `alexeykrol-prod`

---
*Framework: Claude Code Starter v2.3.1 | Updated: 2025-12-16*
