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

### Step 0.4: Framework Developer Mode — Check Bug Reports

**Purpose:** Automatically check for new bug reports from host projects (framework project only).

**Trigger:** Only runs in claude-code-starter framework repository.

```bash
# Check if this is the framework project
if [ -d "migration" ] && [ -f "migration/build-distribution.sh" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Framework Developer Mode"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Check if gh CLI is available
  if ! command -v gh &> /dev/null; then
    echo "ℹ️  GitHub CLI not installed - skipping bug report check"
    echo "   Install: brew install gh (macOS) or sudo apt install gh (Linux)"
    echo ""
  else
    # Check if authenticated
    if ! gh auth status &> /dev/null; then
      echo "ℹ️  GitHub CLI not authenticated - skipping bug report check"
      echo "   Run: gh auth login"
      echo ""
    else
      # Fetch bug reports from GitHub Issues
      echo "📊 Checking for bug reports from host projects..."

      BUG_REPORTS=$(gh issue list \
        --repo "alexeykrol/claude-code-starter" \
        --label "bug-report" \
        --state "open" \
        --json number,title,createdAt \
        --limit 100 2>/dev/null)

      if [ $? -eq 0 ]; then
        REPORT_COUNT=$(echo "$BUG_REPORTS" | jq length 2>/dev/null || echo "0")

        if [ "$REPORT_COUNT" -gt 0 ]; then
          echo ""
          echo "⚠️  Found $REPORT_COUNT open bug report(s)"
          echo ""

          # Show recent reports (last 5)
          echo "Recent reports:"
          echo "$BUG_REPORTS" | jq -r '.[:5] | .[] | "  • #\(.number): \(.title)"' 2>/dev/null
          echo ""

          # Count by recency (last 7 days)
          WEEK_AGO=$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)
          RECENT_COUNT=$(echo "$BUG_REPORTS" | jq --arg week "$WEEK_AGO" '[.[] | select(.createdAt > $week)] | length' 2>/dev/null || echo "0")

          if [ "$RECENT_COUNT" -gt 0 ]; then
            echo "📌 $RECENT_COUNT new report(s) in the last 7 days"
            echo ""
          fi

          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          echo "💡 Recommended actions:"
          echo "   1. Run /analyze-bugs for detailed analysis"
          echo "   2. Review and prioritize bug reports"
          echo "   3. Create fixes for critical issues"
          echo ""

          # Save bug report summary for later reference
          export BUG_REPORT_COUNT="$REPORT_COUNT"
          export BUG_RECENT_COUNT="$RECENT_COUNT"
        else
          echo "✅ No open bug reports"
          echo ""
        fi
      else
        echo "⚠️  Failed to fetch bug reports"
        echo ""
      fi
    fi
  fi
fi
```

**Notes:**
- Only runs in framework repository (claude-code-starter)
- Requires GitHub CLI (`gh`) installed and authenticated
- Shows count of open bug reports with "bug-report" label
- Highlights reports from last 7 days
- Suggests running `/analyze-bugs` for detailed analysis
- Non-blocking: continues even if gh CLI unavailable
- First priority task: fix user-reported issues

---

### Step 0.5: Security Cleanup & Export Sessions

**CRITICAL: Security First**

```bash
# Security: Clean LAST dialog (from previous session)
# Removes credentials before export to prevent leaks in git
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last
fi

npm run dialog:export --no-html
node dist/claude-export/cli.js generate-html
git add html-viewer/index.html && git commit -m "chore: Update student UI with latest dialogs"
```

**What this does:**
1. **Security cleanup** — Redacts credentials from last closed dialog
   - SSH credentials (user@host, IP addresses, SSH keys)
   - Database URLs (postgres://, mysql://, mongodb://)
   - API keys, JWT tokens, passwords
   - Prevents credentials from leaking into git
2. **Export dialogs** — Exports closed sessions without HTML generation
3. **Update Student UI** — Generates html-viewer/index.html with ALL sessions
4. **Auto-commit** — Commits student UI so students see complete history

**Why --last flag:**
- Only cleans LAST closed dialog (fast, 1 file vs 300+)
- Each dialog gets cleaned on next Cold Start
- Gradual cleanup ensures all dialogs eventually cleaned

**Security guarantee:**
- All closed dialogs are cleaned before ever being committed to git
- Cleanup runs BEFORE export, blocking credentials at source

### Step 1: Mark Session Active
```bash
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

### Step 2: Load Context (ALWAYS read — keep compact!)
- `.claude/SNAPSHOT.md` — current version, what's in progress (~30-50 lines)
- `.claude/BACKLOG.md` — current sprint tasks (~50-100 lines)
- `.claude/ARCHITECTURE.md` — code structure (~100-200 lines)

**CRITICAL: NEVER read `dialog/` files** — they are for archive only, not for context loading. Reading them wastes tokens.

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

### 0. Re-read Completion Protocol (Self-Check)

**Purpose:** Ensure protocol is followed correctly by re-reading instructions.

**Why needed:**
- During long sessions, context may be compacted/summarized
- Re-reading ensures sharp focus on protocol steps
- Prevents forgetting metafile updates (CLAUDE.md, SNAPSHOT.md, BACKLOG.md)
- "Practice what we preach" — we require this from host projects
- Catches systemic errors where changes are made but not documented

**Action:**
```
Read the Completion Protocol section from CLAUDE.md to refresh protocol steps.
Mentally review what was done in this session and what needs to be updated.
```

**Self-check questions:**
- Did I add new features? → Update SNAPSHOT.md, BACKLOG.md, CHANGELOG.md
- Did I modify CLAUDE.md? → Ensure changes are in migration/CLAUDE.production.md too
- Did I add new commands? → Are they in distribution?
- Did I fix bugs? → Document in CHANGELOG.md

---

### 0.1. Initialize Completion Logging

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

    log_completion_step "Step 0.1: Logging initialized"
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

### 3.5. Security: Clean Current Dialog + Auto AI Agent

**MANDATORY SECURITY CHECK** — Prevents credentials from leaking into git

**Part 1: Regex-Based Cleanup (Layer 2)**

```bash
# Clean CURRENT dialog (this session) before commit
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last
  CLEANUP_EXIT=$?
fi
```

**What this does:**
- Cleans CURRENT (active) dialog session before git commit
- Redacts credentials using regex patterns (fast, ~1-2 seconds)
- Blocks commit if credentials detected (script exits with error)
- **CRITICAL:** This is the LAST line of defense before credentials enter git

**Part 2: Smart Trigger Detection (Advisory for Claude AI)**

```bash
# Check security triggers (advisory mode)
if [ -f "security/auto-invoke-agent.sh" ]; then
  bash security/auto-invoke-agent.sh
  TRIGGER_EXIT=$?
fi
```

**Claude AI Decision Logic:**

**Exit code interpretation:**
- `0` = No triggers → skip deep scan
- `1` = CRITICAL + release mode → **auto-invoke agent (no confirmation)**
- `10` = CRITICAL triggers → **ask user**
- `11` = HIGH triggers → **ask user**
- `12` = MEDIUM triggers → **optional mention**

**If exit code = 1 (Release Mode):**
```
Claude automatically invokes /security-dialogs without asking.
User sees: "🚨 RELEASE MODE: Running mandatory deep scan..."
```

**If exit code = 10 or 11 (CRITICAL/HIGH):**
```
Claude asks user:

⚠️  Обнаружены потенциальные риски безопасности:
  • [reasons from trigger detection]

Рекомендую запустить deep scan изменений спринта (1-2 минуты).
Запустить AI-агент для проверки? (y/N)

If user answers "y" → Claude invokes /security-dialogs
If user answers "N" → Claude skips, proceeds with commit
```

**If exit code = 12 (MEDIUM):**
```
Claude optionally mentions:
"💡 Если хотите дополнительную проверку, можете запустить /security-dialogs"
```

**Important:**
- Claude (AI) reads trigger info and sprint context
- Claude decides whether to ask based on what was discussed in session
- Only release mode (git tag v2.x.x) auto-invokes without asking
- Normal commits → user always decides

**Why this is mandatory:**
- Cold Start Step 0.5 cleans PREVIOUS session
- This step cleans CURRENT session (the one being committed now)
- Double protection: previous session (0.5) + current session (3.5)
- **NEW:** Auto-invokes AI agent when high-risk conditions detected

**What gets redacted by regex:**
- SSH credentials (user@host, IPs, SSH keys, ports)
- Database URLs (postgres, mysql, mongodb)
- API keys, tokens, passwords
- JWT tokens, bearer tokens
- Private keys (PEM format)

**When AI agent is invoked automatically:**

**CRITICAL triggers (always invoke, no confirmation):**
- Production credentials file exists (`.production-credentials`)
- Git release tag detected (creating release)
- Release workflow in recent dialogs

**HIGH triggers (invoke with explanation):**
- Regex cleanup found credentials
- Security-sensitive keywords in dialogs (ssh, api key, password, etc.)
- Production/deployment discussion detected

**MEDIUM triggers (suggest, allow skip):**
- Large diff (>500 lines changed)
- Many new dialog files (>5 uncommitted)
- Security config files modified

**If credentials detected:**
- Script exits with error (non-zero exit code)
- Commit is blocked
- Review `security/reports/cleanup-*.txt` for details
- AI agent may be invoked for deep context analysis
- Manually verify redactions before proceeding

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

  # Check if there were any errors in the log
  if grep -q "## ⚠️ ERROR" "$COMPLETION_LOG"; then
    echo ""
    echo "⚠️  Errors detected during completion protocol"
    echo "Log contains error information: $COMPLETION_LOG"
    echo ""

    # Offer to create bug report
    read -p "Create anonymized bug report? (y/N) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Run anonymization script
      if [ -f ".claude/scripts/anonymize-report.sh" ]; then
        REPORT_FILE=$(bash .claude/scripts/anonymize-report.sh "$COMPLETION_LOG")
        echo "✅ Bug report created: $REPORT_FILE"
        echo ""
        echo "You can submit this to: github.com/alexeykrol/claude-code-starter/issues"
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
- Offers to create anonymized bug report if errors found
- Uses anonymization script to remove sensitive data

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
*Framework: Claude Code Starter v2.4.0 | Updated: 2026-01-16*
