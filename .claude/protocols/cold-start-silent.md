# Cold Start Protocol (True Silent Mode)

**Version:** 2.7.0
**Last updated:** 2026-01-20

**Purpose:** Invisible session initialization. Show ONLY critical issues.

**Philosophy:** User doesn't think about protocols. Framework works in background. Show output ONLY when user input required or critical error occurred.

---

## Design Principles

**Silent by default:**
- NO progress indicators
- NO status messages
- NO "Running...", "Checking...", "Processing..."
- NO success confirmations
- Everything happens in background

**Show ONLY:**
- ⚠️ Crash with uncommitted changes (ask what to do)
- ❌ Critical errors (with fix instructions)
- (Optional) 📦 Update available

**Result:**
- If OK: Show nothing or just `✅ Ready`
- If problem: Show minimal actionable message

---

## Implementation

### Phase 1: Silent Background Execution

**Launch ALL tasks in background (single Task tool call with multiple agents):**

```typescript
// Use Task tool, launch 6 agents in parallel, ALL in background
// No output shown to user

Background agents:
1. Migration cleanup (if needed)
2. Crash detection & auto-recovery
3. Version check
4. Security cleanup
5. Dialog export
6. COMMIT_POLICY check & auto-create
7. Git hooks install
8. Config initialization
9. Load context files (SNAPSHOT, BACKLOG, ARCHITECTURE)
10. Mark session active
```

**All run silently. User sees NOTHING during execution.**

---

### Phase 2: Check Results & Show ONLY Issues

**Parse background task outputs:**

```typescript
// Read all TaskOutput results

// Check for crash
if (crash_detected && has_uncommitted_changes) {
  // SHOW - needs user decision
  output: `⚠️ Previous session crashed

  Uncommitted: ${file_count} files

  1. Continue (keep uncommitted)
  2. Commit first

  ? (1/2):`

  wait_for_user_input()

  if (choice === "2") {
    // Run completion protocol for crashed session
    execute_completion_protocol()
  }
}

// Check for version update
if (update_available) {
  // Option A: Show (configurable)
  if (show_updates === true) {
    output: `📦 Update: v${current} → v${latest}

    Updating...`

    perform_update()

    output: `✓ Updated to v${latest}

    Restart session: exit and run 'claude'`

    exit()
  }

  // Option B: Silent auto-update (default)
  perform_update_silently()
  restart_session()
}

// Check for critical errors
if (critical_error) {
  // SHOW - user must fix
  output: `❌ ${error_type}

  ${error_message}

  Fix: ${next_steps}`

  exit()
}

// Check for security issues (informational)
if (security_credentials_found) {
  // Optional: show warning
  if (verbose_security === true) {
    output: `⚠️ Security: ${count} credentials redacted`
  }
  // Otherwise: silent, log to file
}

// Framework developer mode (optional)
if (is_framework_project && bug_reports > 0) {
  // Optional: show count
  if (show_bug_reports === true) {
    output: `📊 ${bug_reports} bug report(s)`
  }
  // Otherwise: silent
}
```

---

### Phase 3: Silent Completion

**If everything OK (99% of cases):**

```typescript
// Show NOTHING or minimal:

// Option A: Completely silent
// (user just starts working)

// Option B: Minimal acknowledgment
output: `✅ Ready`

// Option C: Ultra-minimal
// (just change prompt or status indicator)
```

---

## Configuration

**Settings in `.claude/.framework-config`:**

```json
{
  "cold_start": {
    "silent_mode": true,           // Default: true (show nothing if OK)
    "show_ready": false,            // Show "✅ Ready" or not
    "auto_update": true,            // Auto-update without asking
    "show_updates": false,          // Show update messages
    "show_security_warnings": false, // Show security redactions
    "show_bug_reports": false       // Show bug report count (framework only)
  }
}
```

**Defaults:**
- Silent mode: ON
- Show nothing unless error
- Auto-update silently
- Log everything to `.claude/logs/`

---

## Execution Flow

```
User types "start"
        ↓
Launch 10 background agents (parallel)
        ↓
Wait for all to complete (10-20s)
        ↓
Check results:
        ↓
┌───────────────────────────────────────┐
│ All OK? (99% of cases)                │
│   → Show nothing or "✅ Ready"         │
│   → User starts working immediately   │
└───────────────────────────────────────┘
        ↓
┌───────────────────────────────────────┐
│ Crash detected?                       │
│   → Show warning + ask what to do     │
│   → Wait for user choice              │
└───────────────────────────────────────┘
        ↓
┌───────────────────────────────────────┐
│ Critical error?                       │
│   → Show error + fix instructions     │
│   → Exit                              │
└───────────────────────────────────────┘
        ↓
┌───────────────────────────────────────┐
│ Update available?                     │
│   → Auto-update silently (default)    │
│   OR show message (if configured)     │
└───────────────────────────────────────┘
```

---

## Background Tasks Detail

**All tasks run via Task tool with `run_in_background=true`:**

### Task 1: Migration Cleanup (if needed)
```bash
# Silent check and cleanup
if [ -f ".claude/CLAUDE.production.md" ]; then
  cp .claude/CLAUDE.production.md CLAUDE.md 2>/dev/null
  rm -f .claude/CLAUDE.production.md .claude/migration-context.json 2>/dev/null
fi
echo "CLEANUP:done"
```

### Task 2: Crash Detection
```bash
# Check last session status
STATUS=$(cat .claude/.last_session 2>/dev/null | grep -o '"status": *"[^"]*"' | cut -d'"' -f4)

if [ "$STATUS" = "active" ]; then
  # Check for uncommitted changes
  if git diff --quiet && git diff --staged --quiet; then
    # Auto-recovery
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
    echo "CRASH:recovered_auto"
  else
    # True crash - need user input
    FILE_COUNT=$(git status --short | wc -l | tr -d ' ')
    echo "CRASH:needs_input:${FILE_COUNT}"
  fi
else
  echo "CRASH:none"
fi
```

### Task 3: Version Check
```bash
# Check for updates
LOCAL=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')
LATEST=$(curl -s https://api.github.com/repos/alexeykrol/claude-code-starter/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')

if [ "$LOCAL" != "$LATEST" ] && [ "$LATEST" != "" ]; then
  echo "UPDATE:available:${LOCAL}:${LATEST}"
else
  echo "UPDATE:none:${LOCAL}"
fi
```

### Task 4: Security Cleanup
```bash
# Silent security cleanup
if [ -f "security/cleanup-dialogs.sh" ]; then
  RESULT=$(bash security/cleanup-dialogs.sh --last 2>&1)
  if echo "$RESULT" | grep -q "credentials redacted"; then
    COUNT=$(echo "$RESULT" | grep -o '[0-9]\+ credentials' | head -1 | grep -o '[0-9]\+')
    echo "SECURITY:redacted:${COUNT}"
  else
    echo "SECURITY:clean"
  fi
else
  echo "SECURITY:skipped"
fi
```

### Task 5: Dialog Export
```bash
# Silent export
npm run dialog:export --no-html 2>&1 | tail -1
echo "EXPORT:done"
```

### Task 6: COMMIT_POLICY Check
```bash
# Auto-create if missing (silent)
if [ ! -f ".claude/COMMIT_POLICY.md" ]; then
  if [ -f "migration/templates/COMMIT_POLICY.template.md" ]; then
    PROJECT_NAME=$(basename "$(pwd)")
    sed "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
      migration/templates/COMMIT_POLICY.template.md > .claude/COMMIT_POLICY.md
    echo "POLICY:created"
  else
    # Create minimal version
    cat > .claude/COMMIT_POLICY.md <<'EOF'
# Commit Policy
## ❌ Never commit:
dialog/, .claude/logs/, reports/, notes/, secrets/
## ✅ Always commit:
src/, tests/, README.md, package.json
EOF
    echo "POLICY:created_minimal"
  fi
else
  echo "POLICY:exists"
fi
```

### Task 7: Git Hooks
```bash
# Silent install
bash .claude/scripts/install-git-hooks.sh >/dev/null 2>&1
echo "HOOKS:done"
```

### Task 8: Config Init
```bash
# Initialize config if missing
if [ ! -f ".claude/.framework-config" ]; then
  PROJECT_NAME=$(basename "$(pwd)")
  cat > .claude/.framework-config <<EOF
{
  "bug_reporting_enabled": false,
  "project_name": "$PROJECT_NAME",
  "first_run_completed": false,
  "cold_start": {
    "silent_mode": true,
    "show_ready": false,
    "auto_update": true
  }
}
EOF
  echo "CONFIG:created"
else
  echo "CONFIG:exists"
fi
```

### Task 9: Load Context
```bash
# Read context files (AI does this, not bash)
# Return file paths to read
echo "CONTEXT:.claude/SNAPSHOT.md,.claude/BACKLOG.md,.claude/ARCHITECTURE.md"
```

### Task 10: Mark Active
```bash
# Mark session active
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
echo "SESSION:active"
```

---

## Error Handling

**Build failures, network issues, etc.:**

```typescript
// Check each background task exit code

if (task_failed) {
  // Show error with context
  output: `❌ ${task_name} failed

  Error: ${error_message}

  Fix: ${suggested_action}

  Details: .claude/logs/cold-start/latest.log`

  exit()
}
```

**Non-critical warnings:**
- Log to file
- Don't show to user
- Available in `.claude/logs/cold-start/`

---

## Logging

**Everything logged to file (even if silent to user):**

```
.claude/logs/cold-start/session-YYYYMMDD-HHMMSS.log
```

**Log format:**
```
[18:42:15] Cold Start v2.7.0 (Silent Mode)
[18:42:15] Launching 10 background tasks...
[18:42:16] ✓ Task 1: Migration cleanup (0.2s)
[18:42:17] ✓ Task 2: Crash detection - auto-recovered (0.8s)
[18:42:18] ✓ Task 3: Version check - up to date (1.2s)
[18:42:19] ✓ Task 4: Security cleanup - clean (1.5s)
[18:42:20] ✓ Task 5: Dialog export - 3 sessions (2.1s)
[18:42:20] ✓ Task 6: COMMIT_POLICY - exists (0.1s)
[18:42:20] ✓ Task 7: Git hooks - installed (0.2s)
[18:42:20] ✓ Task 8: Config - exists (0.1s)
[18:42:21] ✓ Task 9: Context loaded (0.5s)
[18:42:21] ✓ Task 10: Session marked active (0.1s)
[18:42:21] All tasks complete (6.8s total)
[18:42:21] Status: OK (no output to user)
[18:42:21] Protocol complete
```

---

## Verbose Mode Override

**For debugging, user can override silent mode:**

```bash
export CLAUDE_MODE=verbose
```

**Then Cold Start shows full output:**
- All task progress
- All status messages
- Full bash outputs
- Timing details

**Useful for:**
- Troubleshooting issues
- Understanding what's happening
- Framework development

---

## First Run Exception

**On first framework run (migration), show minimal intro:**

```
🚀 Framework installed

Quick setup...
  ✓ Config created
  ✓ Hooks installed

✅ Ready to work
```

**After that: Silent mode always.**

---

## Time Comparison

**v2.5.1 (Verbose):**
- Output: 100+ lines
- Time shown: 5-6 minutes
- User attention: Required for every step

**v2.6.0 (Compact):**
- Output: 5-10 lines
- Time shown: 15-30 seconds
- User attention: Occasional (progress shown)

**v2.7.0 (Silent):**
- Output: 0 lines (or 1 line "✅ Ready")
- Time: Unknown to user (happens in background)
- User attention: ZERO (unless error)

**Goal achieved:** User doesn't think about protocol.

---

**Protocol Complete** ✅
