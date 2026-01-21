# Cold Start Protocol (True Silent Mode)

**Version:** 3.0.0
**Last updated:** 2026-01-20

**Purpose:** Invisible session initialization. Show ONLY critical issues.

**Philosophy:** User doesn't think about protocols. Framework works in background. Show output ONLY when user input required or critical error occurred.

**NEW in v3.0.0:** Python utility replaces bash commands. Zero terminal noise, faster execution.

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

    # Check for version update
    version_task = next((t for t in tasks if t["name"] == "version_check"), None)
    if version_task and "UPDATE:available" in version_task["result"]:
        # Extract versions
        parts = version_task["result"].split(":")
        current, latest = parts[2], parts[3]

        # Optional: show update (configurable)
        config = load_config()
        if config.get("cold_start", {}).get("show_updates", False):
            print(f"📦 Update: v{current} → v{latest}\n")

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
