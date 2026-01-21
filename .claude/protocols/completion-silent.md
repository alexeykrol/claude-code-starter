# Completion Protocol (True Silent Mode)

**Version:** 2.7.0
**Last updated:** 2026-01-20

**Purpose:** Invisible sprint finalization. Auto-commit, auto-update metafiles, show ONLY result.

**Philosophy:** User says "done" or framework auto-detects → everything happens in background → shows only commit hash. NO ceremony, NO noise.

---

## Design Principles

**Silent by default:**
- NO progress indicators
- NO "Building...", "Exporting...", "Cleaning..."
- NO metafile update confirmations
- NO step-by-step output
- Everything happens in background

**Show ONLY:**
- ❌ Build errors (if build fails)
- ⚠️ Security issues (if credentials found)
- ✅ Commit result: `✓ Committed (83e637a)`
- (Optional) Commit message for quick review

**Result:**
- If OK: Show commit hash, that's it
- If error: Show error + fix instructions

---

## Auto-Trigger Detection

**Framework can auto-detect when to run Completion:**

### Trigger Patterns:

**1. Explicit completion keywords:**
- User says: "готово", "сделано", "завершил", "done", "finished", "complete"
- User types: `/fi`, "заверши", "завершить", "finish"
- Immediately trigger Completion

**2. Task completion analysis:**
```typescript
// AI analyzes last few messages
patterns = [
  "задача завершена",
  "фича готова",
  "баг исправлен",
  "код работает",
  "тесты проходят",
  "всё сделал",
  "можно коммитить"
]

if (dialog_contains_completion_signal) {
  // Ask: "Commit changes? (Y/n)"
  // or auto-commit if configured
}
```

**3. Significant changes detected:**
```bash
# Check git diff size
LINES_CHANGED=$(git diff --stat | tail -1 | grep -o '[0-9]\+ insertions' | grep -o '[0-9]\+')

if [ "$LINES_CHANGED" -gt 100 ]; then
  # Suggest commit after substantial work
  # "100+ lines changed. Commit? (Y/n)"
fi
```

**4. Idle time:**
```bash
# If no activity for N minutes and changes exist
LAST_ACTIVITY=$(date -r .claude/.last_activity +%s 2>/dev/null || echo 0)
NOW=$(date +%s)
IDLE=$((NOW - LAST_ACTIVITY))

if [ "$IDLE" -gt 1800 ] && ! git diff --quiet; then
  # 30 min idle + uncommitted changes
  # Suggest: "Idle 30min. Commit changes? (Y/n)"
fi
```

**Configuration:**
```json
{
  "completion": {
    "auto_trigger": true,         // Enable auto-detection
    "auto_commit": false,         // Auto-commit without asking
    "trigger_on_keywords": true,  // Detect completion keywords
    "trigger_on_idle": false,     // Trigger after idle time
    "idle_threshold": 1800        // Seconds (30 min)
  }
}
```

---

## Implementation

### Phase 1: Silent Background Execution

**Launch ALL tasks in background (parallel):**

```typescript
// Use Task tool, launch 3 agents in parallel, ALL in background
// No output shown to user

Background agents:
1. Build (if TypeScript changed)
2. Dialog export
3. Security cleanup

// While background tasks run, AI updates metafiles in parallel
4. Update SNAPSHOT.md (if needed)
5. Update BACKLOG.md (mark tasks complete)
6. Update CHANGELOG.md (if release)
7. Update README.md (if major changes)
```

**All run silently. User sees NOTHING during execution.**

---

### Phase 2: Check Results & Handle Errors

**Parse background task outputs:**

```typescript
// Read all TaskOutput results

// Check build result
if (build_failed) {
  // SHOW - user must fix
  output: `❌ Build failed

  Error in src/exporter.ts:42
    Expected ';' but found '}'

  Fix error and run /fi again`

  exit()
}

// Check security result
if (security_credentials_found) {
  // SHOW - security issue
  output: `⚠️ Security: ${count} credentials redacted

  Review: .claude/logs/security/cleanup-*.txt

  Continue commit? (Y/n):`

  wait_for_user_input()

  if (choice === "n") {
    exit()
  }
}

// Check export result
if (export_failed) {
  // Log error, don't block commit
  log_error("Dialog export failed", error)
  // Continue anyway
}
```

---

### Phase 3: Silent Commit

**Git workflow (automatic or one confirmation):**

```typescript
// Read COMMIT_POLICY.md (silent check)
check_commit_policy()

// If forbidden files staged
if (forbidden_files_staged) {
  // SHOW - critical error
  output: `❌ Cannot commit: forbidden files staged

  Forbidden:
    dialog/session-xyz.md
    .claude/logs/debug.log

  Review COMMIT_POLICY.md

  Fix: git restore --staged <files>`

  exit()
}

// Analyze changes (silent)
git_status = get_git_status()
git_diff = get_git_diff()

// AI drafts commit message (silent)
commit_message = draft_commit_message(
  changes: git_diff,
  context: session_summary,
  style: "concise, imperative, specific"
)

// Option A: Auto-commit (if configured)
if (auto_commit === true) {
  git_add_all()
  git_commit(commit_message)

  output: `✓ Committed (${commit_hash})`
  // That's it!
}

// Option B: Quick review (default)
if (auto_commit === false) {
  output: `Commit: "${commit_message}"

  ✓ (Y/n):`

  wait_for_user_input()

  if (confirmed) {
    git_add_all()
    git_commit(commit_message)

    output: `✓ Committed (${commit_hash})`
  } else {
    output: `Cancelled`
  }
}

// Option C: Ultra-silent (background trigger)
// Just commits, shows nothing
```

---

### Phase 4: Optional Push/PR

**If configured, auto-push:**

```typescript
// Check config
if (auto_push === true) {
  git_push()

  output: `✓ Pushed to origin/${branch}`

  // If auto_pr enabled
  if (auto_pr === true) {
    create_pr_automatically()

    output: `✓ PR created: ${pr_url}`
  }
}

// Otherwise: skip, user pushes manually
```

---

### Phase 5: Silent Cleanup

```bash
# Mark session clean (silent)
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session

# Update last activity timestamp (silent)
touch .claude/.last_activity
```

**No output to user.**

---

## Configuration

**Settings in `.claude/.framework-config`:**

```json
{
  "completion": {
    "silent_mode": true,           // Silent by default
    "auto_commit": false,          // Ask before commit (safe default)
    "show_commit_message": true,   // Show message for quick review
    "auto_push": false,            // Don't auto-push (safe default)
    "auto_pr": false,              // Don't auto-create PR
    "auto_trigger": true,          // Enable auto-detection
    "trigger_on_keywords": true,   // Detect "готово", "done", etc.
    "trigger_on_idle": false,      // Don't trigger on idle (can be annoying)
    "trigger_on_significant_changes": true,  // Suggest commit after 100+ lines
    "metafile_updates": "auto"     // Auto-update metafiles (vs ask)
  }
}
```

**Presets:**

```json
// Preset: "paranoid" (safe, asks everything)
{
  "auto_commit": false,
  "auto_push": false,
  "show_commit_message": true
}

// Preset: "autopilot" (fully automated)
{
  "auto_commit": true,
  "auto_push": true,
  "auto_pr": false  // PRs still manual (too risky)
}

// Preset: "balanced" (default, recommended)
{
  "auto_commit": false,      // Quick review
  "auto_push": false,        // Manual push
  "show_commit_message": true
}
```

---

## Background Tasks Detail

### Task 1: Build (if needed)
```bash
# Check if TypeScript files changed
if git diff --name-only | grep -q '\.ts$'; then
  npm run build 2>&1
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    # Extract error message
    ERROR=$(npm run build 2>&1 | grep -A 5 "error TS")
    echo "BUILD:failed:${ERROR}"
  else
    echo "BUILD:success"
  fi
else
  echo "BUILD:skipped:no_ts_changes"
fi
```

### Task 2: Dialog Export
```bash
# Check if dialog export enabled
DIALOG_ENABLED=$(cat .claude/.framework-config 2>/dev/null | grep -o '"dialog_export_enabled": *[^,}]*' | grep -o 'true\|false')

if [ "$DIALOG_ENABLED" = "true" ]; then
  npm run dialog:export --no-html 2>&1 | tail -1
  EXIT_CODE=$?

  if [ $EXIT_CODE -eq 0 ]; then
    echo "EXPORT:success"
  else
    echo "EXPORT:failed:${EXIT_CODE}"
  fi
else
  echo "EXPORT:skipped:disabled"
fi
```

### Task 3: Security Cleanup
```bash
# Check if dialog export enabled (no dialogs = no cleanup needed)
DIALOG_ENABLED=$(cat .claude/.framework-config 2>/dev/null | grep -o '"dialog_export_enabled": *[^,}]*' | grep -o 'true\|false')

if [ "$DIALOG_ENABLED" = "true" ] && [ -f "security/cleanup-dialogs.sh" ]; then
  RESULT=$(bash security/cleanup-dialogs.sh --last 2>&1)

  if echo "$RESULT" | grep -q "credentials redacted"; then
    COUNT=$(echo "$RESULT" | grep -o '[0-9]\+ credentials' | head -1 | grep -o '[0-9]\+')
    echo "SECURITY:redacted:${COUNT}"
  else
    echo "SECURITY:clean"
  fi
else
  echo "SECURITY:skipped:dialogs_disabled"
fi
```

---

## Metafile Updates (AI Work)

**While background tasks run, AI updates metafiles in parallel:**

```typescript
// Analyze session changes
session_summary = analyze_session()

// Update BACKLOG.md
if (tasks_completed) {
  mark_tasks_completed(BACKLOG)
}

if (new_tasks_discovered) {
  add_tasks_to_backlog(BACKLOG)
}

// Update SNAPSHOT.md (if significant changes)
if (version_changed || major_feature_added) {
  update_snapshot(version, status, changes)
}

// Update CHANGELOG.md (if release)
if (is_release) {
  add_changelog_entry(version, changes)
}

// Update README.md (if major features)
if (major_feature_added) {
  update_readme(features)
}

// All done silently, no output to user
```

---

## Commit Message Generation

**AI automatically drafts commit message:**

```typescript
// Analyze changes
changes = {
  files_changed: git_status,
  diff: git_diff,
  session_context: last_20_messages
}

// Determine commit type
type = detect_commit_type(changes)
// "feat", "fix", "chore", "docs", "refactor", etc.

// Generate message
message = `${type}: ${concise_summary}

${optional_details}

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`

// Examples:
// "feat: Add True Silent protocol mode"
// "fix: Build error in exporter.ts"
// "chore: Update metafiles"
// "docs: Add protocol optimization guide"
```

**Quality guidelines:**
- Concise (50 chars title)
- Imperative mood ("Add" not "Added")
- Specific (mention what, not just "updates")
- Skip body if obvious from title

---

## Output Examples

### Scenario 1: Everything OK (auto-commit disabled)

**User types:** "заверши"

**Output:**
```
Commit: "feat: Add True Silent protocol mode"

✓ (Y/n):
```

**User presses:** Enter (Y)

**Output:**
```
✓ Committed (a3f82d1)
```

**Total output:** 3 lines

---

### Scenario 2: Everything OK (auto-commit enabled)

**Framework detects:** "готово" in dialog

**Output:**
```
✓ Committed (a3f82d1)
```

**Total output:** 1 line

---

### Scenario 3: Build Error

**User types:** "/fi"

**Output:**
```
❌ Build failed

Error in src/exporter.ts:42
  Type 'string' is not assignable to type 'number'

Fix error and run /fi again
```

**Total output:** 5 lines, actionable

---

### Scenario 4: Security Warning

**User types:** "finish"

**Output:**
```
⚠️ Security: 2 credentials redacted

Review: .claude/logs/security/cleanup-20260120.txt

Continue commit? (Y/n):
```

**User presses:** Y

**Output:**
```
Commit: "feat: Add auth system"

✓ (Y/n):
```

---

### Scenario 5: Auto-trigger (background)

**Framework detects:** 150 lines changed, idle 10 min

**Output:**
```
150+ lines changed. Commit? (Y/n):
```

**User presses:** Y

**Output:**
```
✓ Committed (f9d41c2)
```

---

## Logging

**Everything logged to file:**

```
.claude/logs/completion/session-YYYYMMDD-HHMMSS.log
```

**Log format:**
```
[19:15:32] Completion v2.7.0 (Silent Mode)
[19:15:32] Trigger: explicit (/fi command)
[19:15:32] Launching 3 background tasks...
[19:15:36] ✓ Task 1: Build - success (4.2s)
[19:15:37] ✓ Task 2: Export - 3 sessions (1.1s)
[19:15:38] ✓ Task 3: Security - clean (0.8s)
[19:15:38] All tasks complete (6.1s)
[19:15:40] Metafiles updated: SNAPSHOT, BACKLOG
[19:15:41] Commit message drafted
[19:15:45] User confirmed commit
[19:15:45] ✓ Committed (a3f82d1)
[19:15:46] Session marked clean
[19:15:46] Protocol complete (14s total)
```

---

## Error Handling

**Each error type handled specifically:**

```typescript
// Build errors
if (build_error) {
  show: `❌ Build failed
  ${extract_meaningful_error(output)}
  Fix error and run /fi again`
}

// Git errors
if (git_error) {
  show: `❌ Git error: ${error}
  ${suggested_fix}`
}

// Security critical
if (security_critical) {
  show: `⚠️ Security: credentials found
  Review and confirm: (Y/n)`
}

// Network errors (push failed)
if (push_error) {
  show: `⚠️ Push failed: ${error}
  Committed locally (${hash})
  Push manually: git push`
}
```

---

## Time Comparison

**v2.5.1 (Verbose):**
- Output: 200+ lines
- Time shown: 5-6 minutes
- User attention: Constant (every step)
- Confirmations: 5-10 times

**v2.6.0 (Compact):**
- Output: 10-15 lines
- Time shown: 30-60 seconds
- User attention: Occasional (progress)
- Confirmations: 2-3 times

**v2.7.0 (Silent):**
- Output: 1-3 lines (commit message + hash)
- Time: Unknown to user (background)
- User attention: ONCE (commit confirmation) or ZERO (auto-commit)
- Confirmations: 0-1 time

**Goal achieved:** User says "done" → framework handles everything → shows commit hash.

---

## Verbose Mode Override

**For debugging:**

```bash
export CLAUDE_MODE=verbose
```

**Shows full output:**
- All task progress
- Metafile update details
- Git operations
- Timing info

---

**Protocol Complete** ✅
