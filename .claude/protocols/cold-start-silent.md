# Cold Start Protocol (True Silent Mode)

**Version:** 4.0.0
**Last updated:** 2026-02-10

**Purpose:** Invisible session initialization. Show ONLY critical issues.

**Philosophy:** User doesn't think about protocols. Framework works in background. Show output ONLY when user input required or critical error occurred.

**NEW in v3.0.0:** Python utility replaces bash commands. Zero terminal noise, faster execution.
**NEW in v3.1.1:** Restored framework auto-update (Phase 2.5). Aggressive strategy - automatic updates without confirmation.
**NEW in v4.0.0:** Dual-agent runtime support (Codex adapter packaged and updated alongside Claude files).

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

### Phase 1: Execute Python Utility

**Single command - all tasks run in parallel:**

```bash
python3 src/framework-core/main.py cold-start
```

**What it does:**
- Executes all 10 tasks in parallel (Python threading)
- Returns JSON result to stdout
- Logs everything to `.claude/logs/framework-core/`
- User sees NOTHING during execution

**Tasks executed (parallel):**
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

---

### Phase 2: Parse JSON Result & React

**Read JSON from stdout:**

```python
import json
import subprocess

result = subprocess.run(
    ["python3", "src/framework-core/main.py", "cold-start"],
    capture_output=True,
    text=True
)

data = json.loads(result.stdout)
status = data.get("status")
```

**React based on status:**

```python
# Case 1: Needs user input (crash with uncommitted changes)
if status == "needs_input":
    reason = data["data"]["reason"]
    file_count = data["data"]["uncommitted_files"]

    # SHOW - ask user
    print(f"⚠️ Previous session crashed\n")
    print(f"Uncommitted: {file_count} files\n")
    print("1. Continue (keep uncommitted)")
    print("2. Commit first\n")

    choice = input("? (1/2): ")

    if choice == "2":
        # Run completion protocol for crashed session
        execute_completion_protocol()

    # Continue with session
    mark_session_active()

# Case 2: Critical error
elif status == "error":
    errors = data.get("errors", [])

    # SHOW - user must fix
    for error in errors:
        print(f"❌ {error['task']} failed")
        print(f"  {error['message']}\n")

    # Exit - cannot continue
    sys.exit(1)

# Case 3: Success
elif status == "success":
    tasks = data.get("tasks", [])

    # Check for security warnings
    security_task = next((t for t in tasks if t["name"] == "security_cleanup"), None)
    if security_task and "SECURITY:redacted" in security_task["result"]:
        config = load_config()
        if config.get("cold_start", {}).get("show_security_warnings", False):
            count = security_task["result"].split(":")[-1]
            print(f"⚠️ Security: {count} credentials redacted\n")

    # Get context files to read
    context_task = next((t for t in tasks if t["name"] == "context_files"), None)
    if context_task:
        files = context_task["result"].replace("CONTEXT:", "").split(",")
        # AI reads these files
        for file_path in files:
            read_file(file_path)

    # Success - show nothing or minimal
    config = load_config()
    if config.get("cold_start", {}).get("show_ready", False):
        print("✅ Ready")
```

---

### Phase 2.5: Framework Auto-Update (Aggressive Strategy)

**Purpose:** Automatically update framework if newer version available. Restored in v3.1.1 and extended for dual-agent runtime in v4.0.0.

**When:** After Phase 1 completes successfully and version_check task detected update.

**Implementation:**

```bash
# Parse result from Python utility (Phase 1)
RESULT=$(python3 src/framework-core/main.py cold-start)
STATUS=$(echo "$RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('status', 'error'))")

# Only proceed if status is success
if [ "$STATUS" = "success" ]; then
  # Extract version check result
  VERSION_CHECK=$(echo "$RESULT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tasks = data.get('tasks', [])
version_task = next((t for t in tasks if t['name'] == 'version_check'), None)
if version_task:
    print(version_task.get('result', ''))
")

  # If update available - download and install
  if echo "$VERSION_CHECK" | grep -q "UPDATE:available"; then
    # Extract versions
    CURRENT=$(echo "$VERSION_CHECK" | cut -d: -f3)
    LATEST=$(echo "$VERSION_CHECK" | cut -d: -f4)

    echo "📦 Framework update available: v$CURRENT → v$LATEST"
    echo "Updating framework..."

    # Download CLAUDE.md
    curl -sL "https://github.com/alexeykrol/claude-code-starter/releases/download/v$LATEST/CLAUDE.md" -o CLAUDE.md.new

    # Download framework commands (5 files)
    curl -sL "https://github.com/alexeykrol/claude-code-starter/releases/download/v$LATEST/framework-commands.tar.gz" -o /tmp/fw-cmd.tar.gz

    # Verify downloads successful
    if [ -f "CLAUDE.md.new" ] && [ -f "/tmp/fw-cmd.tar.gz" ]; then
      # Self-healing: Verify downloaded version matches expected
      DOWNLOADED_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md.new | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

      if [ "$DOWNLOADED_VERSION" != "$LATEST" ]; then
        echo "⚠️  Downloaded CLAUDE.md has wrong version (v$DOWNLOADED_VERSION)"
        echo "   Auto-correcting to v$LATEST..."

        # Fix version in downloaded file (Darwin/BSD sed requires '' after -i)
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "s/v$DOWNLOADED_VERSION/v$LATEST/g" CLAUDE.md.new
        else
          sed -i "s/v$DOWNLOADED_VERSION/v$LATEST/g" CLAUDE.md.new
        fi

        echo "   ✓ Version corrected in CLAUDE.md"
      fi

      # Replace CLAUDE.md
      mv CLAUDE.md.new CLAUDE.md

      # Extract commands (5 framework commands only)
      tar -xzf /tmp/fw-cmd.tar.gz -C .claude/commands/
      rm /tmp/fw-cmd.tar.gz

      echo "✅ Framework updated to v$LATEST"
      echo ""
      echo "⚠️  IMPORTANT: Restart this session to use new framework version"
      echo "   Type 'exit' and start new session"
      echo ""
    else
      echo "⚠️  Update failed - continuing with v$CURRENT"
      rm -f CLAUDE.md.new /tmp/fw-cmd.tar.gz
    fi
  fi
fi
```

**What gets updated:**
- `CLAUDE.md` - Framework instructions and protocols
- `.claude/commands/` - 5 framework commands:
  - `fi.md` (Completion Protocol)
  - `ui.md` (Web UI)
  - `watch.md` (Auto-export watcher)
  - `migrate-legacy.md` (Legacy migration)
  - `upgrade-framework.md` (Framework upgrade)

**What does NOT get updated:**
- User commands (commit, pr, fix, feature, review, test, security, optimize, refactor, explain, db-migrate)
- Project files (SNAPSHOT.md, BACKLOG.md, ARCHITECTURE.md, IDEAS.md, ROADMAP.md)
- Configuration (.claude/.framework-config)
- Dialog files (dialog/)
- Source code (src/)

**Safety:**
- Downloads to temporary files first
- Verifies downloads successful before replacing
- Self-healing: auto-corrects version mismatch
- Only updates framework files
- Preserves all user data

**Aggressive strategy:**
- No user confirmation required
- Automatic download and installation
- Happens on every Cold Start if update available
- Session restart required to use new version

**Why aggressive:**
- Framework updates are safe (only framework files)
- Users benefit from bug fixes immediately
- Reduces support burden (everyone on latest version)
- Can be disabled via config if needed

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

## Python Utility Implementation

**All tasks implemented in `src/framework-core/`:**

All 10 tasks now executed by Python utility (see `src/framework-core/tasks/`):

1. **migration_cleanup()** - `tasks/config.py`
2. **check_crash()** - `tasks/session.py`
3. **check_update()** - `tasks/version.py`
4. **cleanup_dialogs()** - `tasks/security.py`
5. **export_dialogs()** - `tasks/security.py`
6. **ensure_commit_policy()** - `tasks/config.py`
7. **install_git_hooks()** - `tasks/hooks.py`
8. **init_config()** - `tasks/config.py`
9. **get_context_files()** - `tasks/config.py` (returns list)
10. **mark_active()** - `tasks/session.py`

**Benefits over bash:**
- Parallel execution (Python threading)
- Structured JSON output
- Comprehensive logging
- Zero terminal noise
- Faster (native Python vs shell overhead)
- Cross-platform (works on Windows without WSL)

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
