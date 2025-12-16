# Bug Report: Claude Code Starter Framework v2.2

**Project:** Санта-Круз / Люденс
**Framework Version:** Claude Code Starter v2.2
**Report Date:** 2025-12-16
**Session ID:** 2025-12-16-cold-start-001
**Reporter:** Claude Sonnet 4.5
**Environment:** macOS Darwin 25.1.0, Node.js v20.19.4

---

## Executive Summary

During cold start and framework operation testing on 2025-12-16, **4 critical bugs** were identified in Claude Code Starter Framework v2.2:

1. **BUG-001:** Incomplete cleanup after migration completion (CRITICAL)
2. **BUG-002:** Missing dependency in package.json causing UI launch failure (HIGH)
3. **BUG-003:** Port conflict detection missing in UI command (MEDIUM)
4. **BUG-004:** Incomplete session cleanup in previous session (MEDIUM)

**Impact:**
- Framework migration leaves temporary files (tech debt)
- UI command fails on first run (poor UX)
- Manual intervention required for recovery

**Total Issues:** 4
**Critical:** 1
**High:** 1
**Medium:** 2

---

## BUG-001: Incomplete Cleanup After Migration Completion

### Severity: 🔴 CRITICAL

### Summary
Migration completes successfully with status "completed", but finalization step fails to remove all temporary files, leaving the framework in an inconsistent state.

### Impact
- **User Experience:** Poor - requires manual cleanup
- **Framework State:** Inconsistent - temporary files remain after "completed" status
- **Future Migrations:** Potential conflicts if migration is re-run
- **Repository Hygiene:** Untracked files pollute git status

### Environment
- Framework Version: v2.2
- Migration Mode: upgrade
- Old Version: v1.x → v2.2

### Steps to Reproduce

1. Run framework upgrade migration:
   ```bash
   # (Previous session ran /upgrade-framework)
   ```

2. Migration completes with status "completed" in `reports/santacruz-migration-log.json`:
   ```json
   {
     "status": "completed",
     "current_step_name": "completed",
     "files_removed": [
       ".claude/commands/migrate-legacy.md",
       ".claude/commands/upgrade-framework.md",
       ".claude/framework-pending.tar.gz",
       ".claude/CLAUDE.production.md",
       ".claude/migration-log.json",
       ".claude/migration-context.json"
     ]
   }
   ```

3. Execute cold start in new session:
   ```bash
   # User types "start"
   ```

4. Check for temporary files:
   ```bash
   ls -la .claude/CLAUDE.production.md \
          .claude/migration-context.json \
          .claude/commands/migrate-legacy.md \
          .claude/commands/upgrade-framework.md \
          .claude/framework-pending.tar.gz
   ```

### Expected Behavior

After migration status = "completed", ALL temporary files listed in `files_removed` should be deleted:

```bash
# These files should NOT exist:
.claude/CLAUDE.production.md           ❌
.claude/migration-context.json         ❌
.claude/migration-log.json             ❌
.claude/commands/migrate-legacy.md     ❌
.claude/commands/upgrade-framework.md  ❌
.claude/framework-pending.tar.gz       ❌
```

### Actual Behavior

Files remain after migration completion:

```bash
# Actual state on 2025-12-16:
.claude/CLAUDE.production.md           ✅ EXISTS (3418 bytes)
.claude/migration-context.json         ✅ EXISTS (76 bytes)
.claude/commands/migrate-legacy.md     ✅ EXISTS (22416 bytes)
.claude/commands/upgrade-framework.md  ✅ EXISTS (20648 bytes)
.claude/framework-pending.tar.gz       ✅ EXISTS (64833 bytes)
```

**Total leftover data:** ~108 KB of temporary files

### Root Cause Analysis

#### Hypothesis 1: Finalization Step Not Executed
Migration log shows:
```json
"steps_completed": [
  "detect", "read", "plan", "execute",
  "install", "verify", "finalize", "commit"
]
```

Step "finalize" is marked as completed, but files weren't deleted.

**Likely cause:** The finalization logic either:
- Ran but encountered silent errors (no error handling)
- Used incorrect file paths
- Was interrupted before completion

#### Hypothesis 2: CLAUDE.md Swap Not Executed
`CLAUDE.md` remained in "Migration Mode" instead of being swapped with `.claude/CLAUDE.production.md`.

**Evidence:**
```bash
# On cold start, CLAUDE.md header was:
# CLAUDE.md — Migration Mode
# (Should have been: CLAUDE.md — AI Agent Instructions)
```

This suggests the final swap command was never executed:
```bash
# Expected but not executed:
cp .claude/CLAUDE.production.md CLAUDE.md
rm .claude/CLAUDE.production.md
```

#### Hypothesis 3: Git Operations Interfered
The migration log shows step "commit" was completed. If files were staged but commit failed or was interrupted, cleanup might have been skipped.

### Affected Code

**File:** `.claude/commands/upgrade-framework.md` (or internal migration script)

**Suspected section:** Finalization step

```bash
# Expected cleanup commands (not executed or failed):
rm -f .claude/CLAUDE.production.md
rm -f .claude/migration-context.json
rm -f .claude/migration-log.json
rm -f .claude/commands/migrate-legacy.md
rm -f .claude/commands/upgrade-framework.md
rm -f .claude/framework-pending.tar.gz

# Swap CLAUDE.md
cp .claude/CLAUDE.production.md CLAUDE.md
```

### Recovery Process Performed

Manual recovery was required:

```bash
# Step 1: Detected during cold start
cat .claude/migration-context.json
# Output: {"mode": "upgrade", "old_version": "2.2", ...}

# Step 2: Found production CLAUDE.md
ls -la .claude/CLAUDE.production.md
# Output: exists

# Step 3: Manual swap executed by AI agent
cp .claude/CLAUDE.production.md CLAUDE.md
rm .claude/CLAUDE.production.md
rm .claude/migration-context.json

# Step 4: Remaining files still present
ls .claude/commands/migrate-legacy.md        # Still exists
ls .claude/commands/upgrade-framework.md     # Still exists
ls .claude/framework-pending.tar.gz          # Still exists
```

### Recommended Fix

#### Short-term (Immediate)
Add robust cleanup to Cold Start Protocol in `CLAUDE.md`:

```markdown
### Step 0: Migration Recovery

If `.claude/CLAUDE.production.md` exists:
1. Swap: `cp .claude/CLAUDE.production.md CLAUDE.md`
2. Cleanup ALL migration artifacts:
   ```bash
   rm -f .claude/CLAUDE.production.md
   rm -f .claude/migration-context.json
   rm -f .claude/migration-log.json
   rm -f .claude/commands/migrate-legacy.md
   rm -f .claude/commands/upgrade-framework.md
   rm -f .claude/framework-pending.tar.gz
   ```
3. Verify: `echo "Migration recovery complete"`
```

#### Long-term (Framework Fix)
Update migration finalization step:

```bash
# Add error handling and verification
finalize_migration() {
  echo "Starting finalization..."

  # List of files to remove
  FILES_TO_REMOVE=(
    ".claude/migration-context.json"
    ".claude/migration-log.json"
    ".claude/commands/migrate-legacy.md"
    ".claude/commands/upgrade-framework.md"
    ".claude/framework-pending.tar.gz"
  )

  # Remove each file with verification
  for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
      rm -f "$file"
      if [ -f "$file" ]; then
        echo "ERROR: Failed to remove $file"
        return 1
      else
        echo "✓ Removed $file"
      fi
    fi
  done

  # Swap CLAUDE.md
  if [ -f ".claude/CLAUDE.production.md" ]; then
    cp .claude/CLAUDE.production.md CLAUDE.md
    if [ $? -ne 0 ]; then
      echo "ERROR: Failed to swap CLAUDE.md"
      return 1
    fi
    rm -f .claude/CLAUDE.production.md
    echo "✓ Swapped CLAUDE.md"
  fi

  echo "Finalization complete"
  return 0
}
```

### Verification Steps

After fix is implemented:

```bash
# 1. Run migration
# 2. Check status
cat .claude/migration-log.json | grep status
# Expected: "status": "completed"

# 3. Verify cleanup
ls .claude/CLAUDE.production.md 2>/dev/null && echo "FAIL: File exists" || echo "PASS"
ls .claude/migration-context.json 2>/dev/null && echo "FAIL: File exists" || echo "PASS"
ls .claude/commands/migrate-legacy.md 2>/dev/null && echo "FAIL: File exists" || echo "PASS"

# 4. Verify CLAUDE.md
head -5 CLAUDE.md | grep "AI Agent Instructions"
# Expected: Should find "AI Agent Instructions", not "Migration Mode"
```

### Related Issues
- See BUG-004 for session cleanup issues

### Priority
🔴 **CRITICAL** - Affects framework integrity and user experience

### Status
- [x] Identified
- [x] Root cause analyzed
- [x] Manual workaround applied
- [ ] Permanent fix implemented
- [ ] Tested
- [ ] Documented

---

## BUG-002: Missing Dependency in package.json

### Severity: 🟠 HIGH

### Summary
`chokidar` module is required by `watcher.js` but not declared in `package.json`, causing `/ui` command to fail on first run.

### Impact
- **User Experience:** Bad - command fails immediately
- **Functionality:** UI command completely broken until manual fix
- **First-time Users:** Will encounter error without understanding why

### Environment
- Framework Version: v2.2
- Node.js: v20.19.4
- File: `.claude/dist/claude-export/package.json`

### Steps to Reproduce

1. Fresh framework installation (after migration)
2. Run UI command:
   ```bash
   node .claude/dist/claude-export/cli.js ui
   ```

### Expected Behavior

UI server launches successfully:
```
════════════════════════════════════════════════════════════
  Claude Export UI
════════════════════════════════════════════════════════════
  URL:      http://localhost:3333
  Source:   /Users/[user]/project
  Dialogs:  /Users/[user]/project/dialog
════════════════════════════════════════════════════════════
```

### Actual Behavior

```
node:internal/modules/cjs/loader:1215
  throw err;
  ^

Error: Cannot find module 'chokidar'
Require stack:
- /Users/[user]/project/.claude/dist/claude-export/watcher.js
- /Users/[user]/project/.claude/dist/claude-export/cli.js
    at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
    ...

Node.js v20.19.4
```

**Exit code:** 1

### Root Cause Analysis

**File:** `.claude/dist/claude-export/package.json`

**Current content:**
```json
{
  "name": "claude-export-local",
  "type": "commonjs",
  "dependencies": {
    "express": "^4.21.2"
  }
}
```

**Code dependency:** `watcher.js:43`
```javascript
const chokidar = require('chokidar');  // Line 43
```

**Diagnosis:** `chokidar` is used but not declared as dependency.

### Why This Wasn't Caught

1. **No pre-flight checks:** UI command doesn't verify dependencies before launch
2. **No integration tests:** Framework lacks automated tests for UI functionality
3. **Dependency installation timing:** Issue only appears after `npm install` with incomplete package.json

### Fix Applied

**Modified:** `.claude/dist/claude-export/package.json`

```json
{
  "name": "claude-export-local",
  "type": "commonjs",
  "dependencies": {
    "express": "^4.21.2",
    "chokidar": "^3.5.3"
  }
}
```

**Installation:**
```bash
cd .claude/dist/claude-export
npm install
# added 14 packages, and audited 83 packages in 1s
```

### Recommended Improvements

#### 1. Update Framework Distribution
Ensure `package.json` in framework distribution includes all dependencies:

```json
{
  "name": "claude-export-local",
  "type": "commonjs",
  "dependencies": {
    "express": "^4.21.2",
    "chokidar": "^3.5.3"
  }
}
```

#### 2. Add Dependency Check
Add pre-flight check to UI command:

```javascript
// At start of cli.js for 'ui' command
function checkDependencies() {
  const required = ['express', 'chokidar'];
  const missing = [];

  for (const dep of required) {
    try {
      require.resolve(dep);
    } catch (e) {
      missing.push(dep);
    }
  }

  if (missing.length > 0) {
    console.error('Missing dependencies:', missing.join(', '));
    console.error('Run: npm install');
    process.exit(1);
  }
}
```

#### 3. Update /ui Command Documentation
Update `.claude/commands/ui.md`:

```markdown
## Dependencies

Required packages:
- express: ^4.21.2
- chokidar: ^3.5.3

If you encounter "Cannot find module" errors:
```bash
cd .claude/dist/claude-export && npm install
```
```

### Verification Steps

```bash
# 1. Fresh install
rm -rf .claude/dist/claude-export/node_modules
cd .claude/dist/claude-export && npm install

# 2. Verify chokidar installed
npm list chokidar
# Expected: chokidar@3.5.3

# 3. Test UI launch
node cli.js ui
# Expected: Server starts successfully
```

### Priority
🟠 **HIGH** - Breaks core functionality but has simple workaround

### Status
- [x] Identified
- [x] Root cause analyzed
- [x] Fix applied
- [ ] Fix committed to framework repo
- [ ] Documentation updated

---

## BUG-003: Port Conflict Detection Missing

### Severity: 🟡 MEDIUM

### Summary
UI command attempts to bind to port 3333 without checking if port is already in use, resulting in cryptic error instead of helpful guidance.

### Impact
- **User Experience:** Confusing error message
- **Debugging Time:** Users waste time investigating Node.js internals
- **Frequency:** Common if user runs UI multiple times or has port conflicts

### Environment
- Framework Version: v2.2
- Command: `/ui`
- Port: 3333 (hardcoded)

### Steps to Reproduce

1. Start UI server:
   ```bash
   node .claude/dist/claude-export/cli.js ui
   ```

2. Keep server running

3. In another terminal, start UI again:
   ```bash
   node .claude/dist/claude-export/cli.js ui
   ```

### Expected Behavior

Graceful error with actionable guidance:

```
════════════════════════════════════════════════════════════
  Error: Port 3333 Already In Use
════════════════════════════════════════════════════════════

Another process is using port 3333.

Options:
1. Stop the existing process:
   lsof -ti:3333 | xargs kill

2. Use a different port:
   PORT=3334 node .claude/dist/claude-export/cli.js ui

════════════════════════════════════════════════════════════
```

### Actual Behavior

Raw Node.js error:

```
node:events:502
      throw er; // Unhandled 'error' event
      ^

Error: listen EADDRINUSE: address already in use :::3333
    at Server.setupListenHandle [as _listen2] (node:net:1908:16)
    at listenInCluster (node:net:1965:12)
    at Server.listen (node:net:2067:7)
    at Function.listen (/path/to/express/lib/application.js:635:24)
    ...

Emitted 'error' event on Server instance at:
    at emitErrorNT (node:net:1944:8)
    ...
{
  code: 'EADDRINUSE',
  errno: -48,
  syscall: 'listen',
  address: '::',
  port: 3333
}

Node.js v20.19.4
```

### Root Cause Analysis

**File:** `.claude/dist/claude-export/server.js` (assumed)

**Issue:** No error handling for `EADDRINUSE` error

**Current code pattern (approximate):**
```javascript
app.listen(3333, () => {
  console.log('Server running on port 3333');
});
// No .on('error', ...) handler
```

### Recovery Process Performed

Manual port cleanup:

```bash
# Find process on port 3333
lsof -ti:3333
# Output: [PID]

# Kill process
lsof -ti:3333 | xargs kill -9
# Output: Killed process on port 3333

# Retry UI command
node .claude/dist/claude-export/cli.js ui
# Success
```

### Recommended Fix

#### Option A: Pre-flight Port Check

```javascript
const net = require('net');

function isPortAvailable(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    server.once('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        resolve(false);
      }
    });
    server.once('listening', () => {
      server.close();
      resolve(true);
    });
    server.listen(port);
  });
}

async function startServer() {
  const port = process.env.PORT || 3333;

  if (!(await isPortAvailable(port))) {
    console.error(`\n════════════════════════════════════════════════════════════`);
    console.error(`  Error: Port ${port} Already In Use`);
    console.error(`════════════════════════════════════════════════════════════\n`);
    console.error(`Another process is using port ${port}.\n`);
    console.error(`Options:`);
    console.error(`1. Stop the existing process:`);
    console.error(`   lsof -ti:${port} | xargs kill\n`);
    console.error(`2. Use a different port:`);
    console.error(`   PORT=${port + 1} node .claude/dist/claude-export/cli.js ui\n`);
    process.exit(1);
  }

  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}
```

#### Option B: Graceful Error Handler

```javascript
const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\nPort ${port} is already in use.`);
    console.error(`Run: lsof -ti:${port} | xargs kill`);
    console.error(`Or use: PORT=${port + 1} node cli.js ui\n`);
    process.exit(1);
  } else {
    throw err;
  }
});
```

#### Option C: Auto-increment Port

```javascript
async function findAvailablePort(startPort) {
  let port = startPort;
  while (port < startPort + 10) {
    if (await isPortAvailable(port)) {
      return port;
    }
    port++;
  }
  throw new Error(`No available ports found between ${startPort}-${port}`);
}

const availablePort = await findAvailablePort(3333);
app.listen(availablePort, () => {
  console.log(`Server running on port ${availablePort}`);
});
```

### Additional Improvements

1. **Make port configurable:**
   ```bash
   PORT=4000 node .claude/dist/claude-export/cli.js ui
   ```

2. **Add to UI command help:**
   ```markdown
   ## Troubleshooting

   **Port already in use:**
   ```bash
   lsof -ti:3333 | xargs kill
   ```

   **Use different port:**
   ```bash
   PORT=3334 node .claude/dist/claude-export/cli.js ui
   ```
   ```

### Verification Steps

```bash
# 1. Start server
node .claude/dist/claude-export/cli.js ui &
PID1=$!

# 2. Try to start again (should fail gracefully)
node .claude/dist/claude-export/cli.js ui
# Expected: Clear error message with solutions

# 3. Cleanup
kill $PID1
```

### Priority
🟡 **MEDIUM** - Impacts UX but has workaround

### Status
- [x] Identified
- [x] Root cause analyzed
- [x] Workaround documented
- [ ] Fix implemented
- [ ] Tested

---

## BUG-004: Incomplete Session Cleanup

### Severity: 🟡 MEDIUM

### Summary
Previous session didn't execute Completion Protocol (`/fi`), leaving `.last_session` with status "active", triggering crash recovery on next cold start.

### Impact
- **User Experience:** Confusing crash recovery prompt when no actual crash occurred
- **Framework State:** Requires extra verification steps on every cold start
- **False Positives:** May lead to ignoring real crashes

### Environment
- Framework Version: v2.2
- Session tracking: `.claude/.last_session`

### Steps to Reproduce

1. Start session with `start` command
2. Do some work
3. Exit without running `/fi` (close terminal, kill process, etc.)
4. Start new session with `start`

### Expected Behavior

On cold start after clean exit:
```json
// .claude/.last_session should contain:
{"status": "clean", "timestamp": "2025-12-16T..."}
```

Cold start proceeds without warnings.

### Actual Behavior

On cold start:
```json
// .claude/.last_session contains:
{"status": "active", "timestamp": "2025-12-15T23:56:09-08:00"}
```

Crash recovery triggered:
```
⚠️ Previous session crashed or wasn't properly closed.
```

### Root Cause Analysis

**Cause:** Session ended without executing Completion Protocol

**Possible reasons:**
1. User closed terminal without running `/fi`
2. Process was killed (Ctrl+C, kill command)
3. System crash or restart
4. User forgot to run `/fi`

**Current behavior:** No automatic cleanup on session start

### Session Flow Analysis

```
Current flow:
start → Mark active → Work → [Session ends] → .last_session still "active"

Expected flow:
start → Mark active → Work → /fi → Mark clean → Session ends
```

**Problem:** No safeguard for interrupted sessions

### Observed Session

```bash
# Previous session (2025-12-15T23:56:09)
cat .claude/.last_session
# {"status": "active", "timestamp": "2025-12-15T23:56:09-08:00"}

# This session (2025-12-16T00:XX:XX)
# Triggered crash recovery unnecessarily
```

**Verification:** Git status showed no uncommitted work:
```bash
git status
# On branch main
# nothing to commit, working tree clean
```

**Conclusion:** Previous session ended cleanly but didn't mark as clean.

### Current Workaround

Manual verification required:
1. Check `.last_session` status
2. Run `git status`
3. Read SNAPSHOT.md for context
4. Manually confirm "Continue or commit first?"

### Recommended Fix

#### Option A: Auto-recover Clean Sessions

```bash
# In Cold Start Protocol, Step 0:
if [ "$status" = "active" ]; then
  # Check if working tree is clean
  if git diff --quiet && git diff --staged --quiet; then
    echo "Previous session ended without /fi but no uncommitted changes found."
    echo "Auto-recovering to clean state..."
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
    # Continue normally
  else
    # True crash - show recovery prompt
    echo "⚠️ Previous session crashed with uncommitted changes"
  fi
fi
```

#### Option B: Add Session Timeout

```bash
# Consider session stale after 24 hours
LAST_TIMESTAMP=$(cat .claude/.last_session | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
NOW=$(date -Iseconds)
DIFF=$(($(date -d "$NOW" +%s) - $(date -d "$LAST_TIMESTAMP" +%s)))

if [ $DIFF -gt 86400 ]; then  # 24 hours
  echo "Previous session is stale (>24h old). Auto-recovering..."
  echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
fi
```

#### Option C: Add Exit Hook

```bash
# Add to CLAUDE.md warnings:
## On Session End

Always run `/fi` to properly close the session.

If you must exit without /fi:
```bash
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```
```

#### Option D: Shell Integration

```bash
# Add to .bashrc or .zshrc
function claude_exit() {
  if [ -f .claude/.last_session ]; then
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
  fi
}

trap claude_exit EXIT
```

### Improved Crash Detection Logic

```bash
# Enhanced Step 0: Crash Recovery

cat .claude/.last_session 2>/dev/null

if [ "$status" = "active" ]; then
  # Check for actual uncommitted work
  if git diff --quiet && git diff --staged --quiet; then
    # Working tree clean - probably forgot /fi
    echo "ℹ️ Previous session didn't run /fi but working tree is clean."
    echo "Auto-recovering..."

    # Auto-mark as clean
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session

    # Continue to Step 1
  else
    # True crash - uncommitted changes exist
    echo "⚠️ Previous session crashed with uncommitted changes"
    git status

    # Show recovery options
    echo "Options:"
    echo "1. Continue and commit"
    echo "2. Review changes first"
    # Wait for user input
  fi
else
  # status = "clean" - normal flow
  # Continue to Step 1
fi
```

### User Education

Add to CLAUDE.md:

```markdown
## Session Best Practices

✅ **Always run `/fi` when done:**
- Updates metafiles
- Creates commit
- Marks session clean

❌ **Never just close terminal:**
- Leaves session marked as "active"
- Triggers false crash recovery
- Requires manual verification

If you must exit:
```bash
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```
```

### Verification Steps

```bash
# 1. Start session
# 2. Do work
# 3. Run /fi
cat .claude/.last_session
# Expected: {"status": "clean", ...}

# 4. Start new session
# Expected: No crash recovery warning
```

### Priority
🟡 **MEDIUM** - Annoying but doesn't break functionality

### Status
- [x] Identified
- [x] Root cause analyzed
- [ ] Fix implemented
- [ ] User documentation updated
- [ ] Tested

---

## Summary & Metrics

### Bugs by Severity

| Severity | Count | Bug IDs |
|----------|-------|---------|
| 🔴 Critical | 1 | BUG-001 |
| 🟠 High | 1 | BUG-002 |
| 🟡 Medium | 2 | BUG-003, BUG-004 |
| 🟢 Low | 0 | - |

### Bugs by Category

| Category | Count | Description |
|----------|-------|-------------|
| Migration | 1 | Incomplete cleanup after migration |
| Dependencies | 1 | Missing package in package.json |
| Error Handling | 1 | Port conflict detection |
| Session Management | 1 | Session cleanup tracking |

### Time Impact

| Bug | User Time Lost | Frequency |
|-----|----------------|-----------|
| BUG-001 | ~5 min (manual recovery) | Once per migration |
| BUG-002 | ~2 min (npm install) | Once after migration |
| BUG-003 | ~1 min (kill process) | Occasional |
| BUG-004 | ~1 min (verification) | Every session if /fi skipped |

### Quick Wins

Fastest fixes with highest impact:

1. **BUG-002** (5 min fix) - Add `chokidar` to package.json
2. **BUG-003** (15 min fix) - Add error handler for EADDRINUSE
3. **BUG-004** (10 min fix) - Auto-detect clean working tree

### Recommended Action Plan

#### Phase 1: Immediate Fixes (Day 1)
- [ ] Fix BUG-002: Update package.json
- [ ] Fix BUG-003: Add port conflict handler
- [ ] Document BUG-001 workaround in CLAUDE.md

#### Phase 2: Framework Update (Week 1)
- [ ] Fix BUG-001: Rewrite migration finalization
- [ ] Fix BUG-004: Add auto-recovery for clean sessions
- [ ] Add integration tests

#### Phase 3: Prevention (Week 2)
- [ ] Add dependency validation
- [ ] Add pre-flight checks for all commands
- [ ] Create automated test suite

---

## Testing Recommendations

### Manual Test Suite

```bash
# Test 1: Clean Migration
./test-clean-migration.sh
# Verify: No leftover files

# Test 2: UI Launch
./test-ui-launch.sh
# Verify: Starts without errors

# Test 3: Port Conflict
./test-port-conflict.sh
# Verify: Graceful error message

# Test 4: Session Recovery
./test-session-recovery.sh
# Verify: Auto-recovers clean sessions
```

### Automated Tests Needed

1. **Migration completeness test**
   ```javascript
   describe('Migration finalization', () => {
     it('should remove all temporary files', () => {
       // Run migration
       // Assert files don't exist
     });
   });
   ```

2. **Dependency validation test**
   ```javascript
   describe('Package dependencies', () => {
     it('should have all required dependencies', () => {
       const pkg = require('./package.json');
       expect(pkg.dependencies).toHaveProperty('chokidar');
     });
   });
   ```

---

## Appendix

### Environment Details

```
OS: Darwin 25.1.0 (macOS)
Node: v20.19.4
npm: (check with npm --version)
Git: (check with git --version)
Shell: zsh/bash
Framework: Claude Code Starter v2.2
Project: santacruz
```

### Files Involved

```
.claude/
├── .last_session                           # Session tracking
├── SNAPSHOT.md                             # Project state
├── BACKLOG.md                              # Current tasks
├── ARCHITECTURE.md                         # Structure
├── commands/
│   ├── ui.md                               # UI command definition
│   ├── migrate-legacy.md                   # (Should be removed)
│   └── upgrade-framework.md                # (Should be removed)
└── dist/
    └── claude-export/
        ├── package.json                    # Missing chokidar
        ├── cli.js                          # No port check
        ├── server.js                       # No error handling
        └── watcher.js                      # Requires chokidar

CLAUDE.md                                    # Framework instructions
reports/
├── santacruz-migration-log.json           # Migration completed
└── framework-bugs-2025-12-16.md           # This file
```

### Log Excerpts

**Migration log:**
```json
{
  "status": "completed",
  "mode": "upgrade",
  "current_step_name": "completed",
  "files_removed": [
    ".claude/commands/migrate-legacy.md",
    ".claude/commands/upgrade-framework.md",
    ".claude/framework-pending.tar.gz",
    ".claude/CLAUDE.production.md",
    ".claude/migration-log.json",
    ".claude/migration-context.json"
  ]
}
```

**Session log:**
```json
{"status": "active", "timestamp": "2025-12-15T23:56:09-08:00"}
```

---

## Contact & Follow-up

**Report Generated By:** Claude Sonnet 4.5
**Session Date:** 2025-12-16
**Framework Version:** v2.2

**Next Steps:**
1. Review this report
2. Prioritize fixes
3. Implement changes
4. Update framework distribution
5. Test thoroughly
6. Document changes

---

*End of Bug Report*
