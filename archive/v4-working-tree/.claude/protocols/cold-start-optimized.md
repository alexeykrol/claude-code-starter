# Cold Start Protocol (Optimized)

**Version:** 2.6.0
**Last updated:** 2026-01-20

**Purpose:** Fast session initialization with background processing.

**Trigger:** User types "start" or "начать"

**Time:** 15-30 seconds (was 5-6 minutes)

---

## Design Philosophy

**Problems with v2.5.1:**
- 5-6 minutes to complete
- Blocks work during execution
- Excessive output (100+ lines)
- Too many confirmations for routine operations
- 20-30% of development time spent on protocol overhead

**Solutions in v2.6.0:**
- Background agents for slow operations (build, export, cleanup)
- Compact output (5-10 lines vs 100+)
- Silent success, only show errors/warnings
- Auto-continue for routine checks
- Parallel execution where possible

---

## Output Format

**Simple progress indicators:**
```
🚀 Cold Start v2.5.1

⏳ Initializing (background: version check, cleanup, export)...
  ✓ Crash recovery (clean)
  ✓ Version v2.5.1 (up to date)
  ✓ Security cleanup (0 issues)
  ✓ Dialog export (3 sessions)
  ✓ COMMIT_POLICY.md exists

📖 Context loaded (SNAPSHOT, BACKLOG, ARCHITECTURE)

✅ Ready — Time: 18s
```

**Error example:**
```
⚠️  Previous session crashed
  → 3 uncommitted files

Choose:
  1. Continue (keep uncommitted)
  2. Commit first

? (1/2):
```

---

## Protocol Steps

### Phase 1: Quick Checks (Sequential, <5s)

Execute these checks FAST, no background agents:

**Step 0: First Launch Detection**
```bash
if [ -f ".claude/migration-context.json" ]; then
  # First launch workflow (same as before)
  # This is rare, keep detailed output
fi
```

**Step 0.05: Migration Cleanup (Silent)**
```bash
# Clean leftover migration files (silent if successful)
if [ -f ".claude/CLAUDE.production.md" ]; then
  # Swap and cleanup (silent)
  cp .claude/CLAUDE.production.md CLAUDE.md 2>/dev/null
  rm -f .claude/CLAUDE.production.md .claude/migration-context.json .claude/migration-log.json
fi
```

**Step 0.1: Crash Recovery (Auto or Ask)**
```bash
STATUS=$(cat .claude/.last_session 2>/dev/null | grep -o '"status": *"[^"]*"' | cut -d'"' -f4)

if [ "$STATUS" = "active" ]; then
  # Check if real crash
  if git diff --quiet && git diff --staged --quiet; then
    # Auto-recovery: clean state
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
  else
    # True crash: ask user
    echo "⚠️  Previous session crashed"
    echo "  → $(git status --short | wc -l | tr -d ' ') uncommitted files"
    echo ""
    echo "Choose:"
    echo "  1. Continue (keep uncommitted)"
    echo "  2. Commit first"
    echo ""
    read -p "? (1/2): " CRASH_CHOICE

    if [ "$CRASH_CHOICE" = "2" ]; then
      # Run completion protocol
      echo "Run /fi to commit crashed session changes"
      exit 1
    fi
  fi
fi
```

**Show initial status:**
```
🚀 Cold Start v2.5.1

⏳ Initializing...
```

---

### Phase 2: Background Processing (Parallel, 10-20s)

Launch ALL background tasks in parallel using Task tool:

**Use Task tool with `run_in_background=true` for each:**

**Task 1: Version Check**
```bash
# Background agent: Bash specialist
LOCAL_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')
LATEST_VERSION=$(curl -s https://api.github.com/repos/alexeykrol/claude-code-starter/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')

if [ "$LOCAL_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "" ]; then
  echo "UPDATE_AVAILABLE:$LOCAL_VERSION:$LATEST_VERSION"
else
  echo "UP_TO_DATE:$LOCAL_VERSION"
fi
```

**Task 2: Security Cleanup**
```bash
# Background agent: Bash specialist
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last 2>&1
  echo "CLEANUP_EXIT_CODE:$?"
else
  echo "CLEANUP_SKIPPED:no_script"
fi
```

**Task 3: Dialog Export**
```bash
# Background agent: Bash specialist
npm run dialog:export --no-html 2>&1 | tail -5
echo "EXPORT_EXIT_CODE:$?"
```

**Task 4: COMMIT_POLICY Check & Create**
```bash
# Background agent: Bash specialist
if [ ! -f ".claude/COMMIT_POLICY.md" ]; then
  if [ -f "migration/templates/COMMIT_POLICY.template.md" ]; then
    PROJECT_NAME=$(basename "$(pwd)")
    sed "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
      migration/templates/COMMIT_POLICY.template.md > .claude/COMMIT_POLICY.md
    echo "POLICY_CREATED:from_template"
  else
    # Create minimal version (hardcoded in protocol, not repeating here)
    echo "POLICY_CREATED:minimal"
  fi
else
  echo "POLICY_EXISTS"
fi
```

**Task 5: Git Hooks**
```bash
# Background agent: Bash specialist
bash .claude/scripts/install-git-hooks.sh 2>&1
echo "HOOKS_EXIT_CODE:$?"
```

**Task 6: Bug Reporting Consent (First Run Only)**
```bash
# Background agent: Bash specialist
# Initialize config if needed
if [ ! -f ".claude/.framework-config" ]; then
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

FIRST_RUN=$(cat .claude/.framework-config | grep -o '"first_run_completed": *[^,}]*' | sed 's/.*: *//' | tr -d ' ')

if [ "$FIRST_RUN" = "false" ]; then
  echo "CONSENT_NEEDED"
else
  echo "CONSENT_DONE"
fi
```

---

### Phase 3: Wait & Show Results (<2s)

**Read all background task outputs using TaskOutput tool**

**Parse results and show compact summary:**
```
  ✓ Crash recovery (clean)
  ✓ Version v2.5.1 (up to date)
  ✓ Security cleanup (0 issues)
  ✓ Dialog export (3 sessions)
  ✓ COMMIT_POLICY.md exists
  ✓ Git hooks installed
```

**If version update available:**
```
  ⚠️  Update available: v2.5.1 → v2.6.0
     Run after session: curl -sL https://raw.githubusercontent.com/alexeykrol/claude-code-starter/main/init-project.sh | bash
```

**If security issues found:**
```
  ⚠️  Security: 2 credentials redacted
     Details: .claude/logs/security/cleanup-*.txt
```

**If bug reporting consent needed:**
```
  ❓ Enable anonymous bug reporting? (y/N)
     Helps improve framework, opt-in only
```

---

### Phase 4: Load Context (<5s)

**Read files sequentially (fast, local I/O):**

```markdown
# Read these files using Read tool:
1. .claude/SNAPSHOT.md
2. .claude/BACKLOG.md
3. .claude/ARCHITECTURE.md
```

**Show:**
```
📖 Context loaded (SNAPSHOT, BACKLOG, ARCHITECTURE)
```

---

### Phase 5: Framework Developer Mode (Optional, <2s)

**If framework project, check bug reports in background:**

```bash
# Only if migration/ exists
if [ -d "migration" ] && [ -f "migration/build-distribution.sh" ]; then
  if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    REPORT_COUNT=$(gh issue list --label "bug-report" --state "open" --json number --jq length 2>/dev/null || echo "0")

    if [ "$REPORT_COUNT" -gt 0 ]; then
      echo "  📊 $REPORT_COUNT bug report(s) — run /analyze-bugs"
    fi
  fi
fi
```

---

### Phase 6: Mark Active & Complete

```bash
# Mark session active
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session

# Show completion
echo ""
echo "✅ Ready — Time: ${SECONDS}s"
```

---

## Implementation Notes

**Background agents:**
- Use Task tool with `run_in_background=true`
- Launch ALL in parallel (6 tasks simultaneously)
- Use TaskOutput to read results after
- Silent success, only report errors/warnings

**Compact output:**
- No ━━━ borders
- No "Running...", "Checking...", "Processing..."
- Use emoji progress: ⏳ ✓ ⚠️ ❌ 📖 ✅
- Group related info
- Details in log files

**Auto-continue:**
- Migration cleanup → silent
- Crash recovery (if clean) → auto
- COMMIT_POLICY check → auto (create if missing)
- Git hooks → auto install
- Only ask when user input REQUIRED

**Parallel execution:**
- Version check + Security + Export + Hooks + COMMIT_POLICY + Config
- All run simultaneously
- Wait once for all to complete
- Show aggregated results

**Error handling:**
- Capture exit codes from background tasks
- Show errors with context
- Provide actionable next steps
- Don't block on non-critical errors

---

## Time Breakdown

**v2.5.1 (Sequential):**
- Step 0.05: Migration cleanup: 1s
- Step 0.1: Crash recovery: 2s
- Step 0.2: Version check: 5-10s
- Step 0.15: Bug reporting (first run): 10-30s
- Step 0.3: Logging: 1s
- Step 0.4: Framework dev mode: 3-5s
- Step 0.5: Security + Export: 10-20s
- Step 0.55: COMMIT_POLICY: 1s
- Step 0.6: Git hooks: 1s
- Step 1: Mark active: 1s
- Step 2: Load context: 5-10s
- Step 4: Confirm: 1s
- **Total:** 41-82s (+ massive output)

**v2.6.0 (Parallel):**
- Phase 1: Quick checks: 3-5s
- Phase 2: Background processing: 10-15s (parallel!)
- Phase 3: Show results: 1s
- Phase 4: Load context: 3-5s
- Phase 5: Developer mode: 1s
- Phase 6: Complete: 1s
- **Total:** 19-32s (compact output)

**Savings:** 50-60% faster + 90% less noise

---

## Logging

**All background tasks log to:**
```
.claude/logs/cold-start/session-YYYYMMDD-HHMMSS.log
```

**Log format:**
```
[HH:MM:SS] Phase 1: Quick checks
[HH:MM:SS] ✓ Crash recovery: clean
[HH:MM:SS] Phase 2: Background processing started
[HH:MM:SS]   → Task 1: Version check
[HH:MM:SS]   → Task 2: Security cleanup
[HH:MM:SS]   → Task 3: Dialog export
[HH:MM:SS]   → Task 4: COMMIT_POLICY
[HH:MM:SS]   → Task 5: Git hooks
[HH:MM:SS]   → Task 6: Config init
[HH:MM:SS] Phase 2: Waiting for background tasks...
[HH:MM:SS] ✓ All background tasks complete
[HH:MM:SS] Phase 4: Loading context...
[HH:MM:SS] ✓ Protocol complete (18s total)
```

---

## Verbose Mode (Optional)

**For debugging, set environment variable:**
```bash
export CLAUDE_MODE=verbose
```

**Then run Cold Start:**
- Shows detailed output from all background tasks
- Displays full bash command outputs
- Shows timing for each phase
- Useful for troubleshooting

**Default mode:**
```bash
export CLAUDE_MODE=quick  # or unset
```

---

**Protocol Complete** ✅
