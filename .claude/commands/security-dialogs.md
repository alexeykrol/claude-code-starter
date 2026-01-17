---
description: Deep AI-based credential scan for dialog files
---

# Security Dialogs — Deep Credential Scan

**Purpose:** Use AI agent to analyze dialog files for context-dependent credentials that regex cannot detect.

**When to use:**
- Before creating GitHub release (paranoia mode)
- When bash cleanup found credentials and you want deeper analysis
- Manual security audit of dialog history
- Suspected credential leak in conversations

---

## Implementation

### Step 0: Check Why Agent Was Invoked

**This command can be invoked in two ways:**
1. **Manual:** User types `/security-dialogs`
2. **Automatic:** Triggered by `security/auto-invoke-agent.sh` based on risk triggers

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 Security Dialogs — Deep AI Credential Scan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if auto-invoked (environment variables set by auto-invoke-agent.sh)
if [ -n "$DEEP_SCAN_TRIGGER_LEVEL" ]; then
  echo "🤖 Auto-invoked due to: $DEEP_SCAN_TRIGGER_LEVEL trigger level"
  echo ""
  echo "Trigger reasons:"
  echo "$DEEP_SCAN_TRIGGER_REASONS" | grep -o '"reasons": *\[[^]]*\]' | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n' | sed 's/^ *"/  • /' | sed 's/"$//'
  echo ""
else
  echo "🔍 Manual deep scan requested by user"
  echo ""
fi
```

### Step 1: Run Regex Cleanup First

```bash
# Layer 1-3: Run standard bash cleanup (if not already run)
if [ ! -f "security/reports/"*"cleanup-report"* ] || [ -z "$CLEANUP_EXIT" ]; then
  echo "Step 1: Running regex-based cleanup (fast)..."
  bash security/cleanup-dialogs.sh --last
  REGEX_EXIT_CODE=$?

  if [ $REGEX_EXIT_CODE -eq 0 ]; then
    echo "✓ Regex cleanup: No credentials detected"
  else
    echo "⚠️  Regex cleanup: Credentials found and redacted"
  fi
else
  echo "Step 1: Regex cleanup already completed"
  REGEX_EXIT_CODE=$CLEANUP_EXIT
fi

echo ""
```

### Step 2: Identify Sprint Changes to Analyze

**Key principle:** Analyze ONLY changes from current sprint, not entire codebase.

```bash
echo "Step 2: Identifying sprint changes for deep scan..."
echo ""

# 1. Get last dialog (current session)
LAST_DIALOG=$(find dialog -name "*.md" 2>/dev/null | sort -r | head -1)

if [ -z "$LAST_DIALOG" ]; then
  echo "⚠️  No dialog files found"
  exit 0
fi

DIALOG_SIZE=$(du -h "$LAST_DIALOG" | awk '{print $1}')
echo "  • Dialog: $(basename $LAST_DIALOG) ($DIALOG_SIZE)"

# 2. Get git diff (changed files in sprint)
CHANGED_FILES=$(git diff --name-only HEAD~5..HEAD 2>/dev/null)
CHANGED_COUNT=$(echo "$CHANGED_FILES" | grep -v '^$' | wc -l | tr -d ' ')

if [ "$CHANGED_COUNT" -gt 0 ]; then
  echo "  • Changed files: $CHANGED_COUNT files in last 5 commits"

  # Show file types for context
  echo "$CHANGED_FILES" | grep '\.' | sed 's/.*\.//' | sort | uniq -c | while read count ext; do
    echo "    - $count .$ext files"
  done
else
  echo "  • Changed files: No git changes detected"
fi

echo ""
echo "Scope: Sprint changes only (NOT entire codebase)"
echo ""
```

### Step 3: Invoke sec24 Agent for Deep Analysis

**Use Task tool with sec24 subagent:**

```
I'm invoking the sec24 security audit agent to perform deep context-aware credential detection.

Agent task:
- Analyze the last 3 dialog files for ANY credentials that regex may have missed
- Look for obfuscated credentials (base64, hex encoding, chr arrays)
- Look for context-dependent secrets ("password is company name")
- Look for multiline credentials in unusual formats
- Look for secrets mentioned in comments or discussions
- Look for private keys, API tokens, database credentials

Files to analyze:
[list files from $RECENT_DIALOGS]

The agent will produce a security report with findings.
```

**Invoke agent:**

Use the Task tool with:
- `subagent_type`: "sec24"
- `description`: "Deep credential scan of sprint changes"
- `prompt`:
  ```
  Perform deep security analysis of SPRINT CHANGES ONLY for credential leaks.

  **Scope (analyze ONLY these):**

  1. Last dialog session:
     - File: {LAST_DIALOG}
     - Size: {DIALOG_SIZE}

  2. Git diff (changed files in sprint):
     - Run: git diff HEAD~5..HEAD
     - Files changed: {CHANGED_COUNT}
     - Focus on: code changes, config files, new files

  3. New/modified reports (if any):
     - reports/FRAMEWORK_*.md
     - reports/bug-*.md

  **DO NOT analyze:**
  - Entire codebase (only git diff)
  - Old dialog files (already cleaned)
  - Unchanged files

  **Look for:**
  1. Obfuscated credentials (base64, hex, chr arrays, etc.)
  2. Context-dependent secrets (e.g., "password is company name")
  3. Multiline credentials in unusual formats
  4. Secrets mentioned in discussions but not shown in code
  5. Private keys, SSH keys, API tokens, database URLs
  6. Composite credentials (user+pass+host split across lines)
  7. Any patterns that regex-based cleanup would miss

  **For each finding, report:**
  - File and line number
  - Type of credential
  - Severity (Critical/High/Medium/Low)
  - Context (why this is a credential)
  - Recommended action (redact/remove/move to .env)

  **Output:**
  Create security report in security/reports/deep-scan-{timestamp}.md

  **Token optimization:**
  Focus on changed lines in git diff, not entire files.
  ```

### Step 4: Review Agent Report

After agent completes:

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deep Scan Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find the agent's report
AGENT_REPORT=$(ls -t security/reports/deep-scan-*.md 2>/dev/null | head -1)

if [ -f "$AGENT_REPORT" ]; then
  echo "✓ Security report created: $AGENT_REPORT"
  echo ""

  # Show summary
  cat "$AGENT_REPORT"
  echo ""

  # Check if agent found issues
  if grep -q "Severity: Critical" "$AGENT_REPORT" || grep -q "Severity: High" "$AGENT_REPORT"; then
    echo "⚠️  CRITICAL or HIGH severity findings detected"
    echo "   Review report and take action before committing"
    exit 1
  else
    echo "✓ No critical issues found by deep scan"
    exit 0
  fi
else
  echo "⚠️  Agent report not found - manual review recommended"
  exit 1
fi
```

---

## Usage Example

```bash
# Before creating release
/security-dialogs

# After regex found credentials
bash security/cleanup-dialogs.sh --last  # Found credentials
/security-dialogs                        # Deep scan to verify context
```

---

## What AI Agent Catches (vs Regex)

| Pattern | Regex | AI Agent |
|---------|-------|----------|
| `password=abc123` | ✅ | ✅ |
| `pass: "".join([chr(x) for x in [112,97,115,115]])` | ❌ | ✅ |
| "password is company name lowercase" (context) | ❌ | ✅ |
| `user: admin, pass: super, host: prod` (composite) | ❌ | ✅ |
| SSH key mentioned in comment (not shown) | ❌ | ✅ |

---

## Performance

- **Regex cleanup**: ~1-2 seconds (10 patterns, deterministic)
- **AI deep scan**: ~1-2 minutes (context analysis, thorough)

**Recommendation:** Use AI scan only when needed (pre-release, audit mode).

---

## Integration with Completion Protocol

Optional addition to Step 3.5 for paranoid mode:

```bash
### 3.5. Security: Clean Current Dialog

# Standard cleanup (always)
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last
fi

# Deep scan (optional - only before releases)
# Uncomment for paranoia mode:
# /security-dialogs
```

---

**Notes:**
- This is Layer 4 (optional, manual invocation)
- Layers 1-3 (gitignore + bash + protocol) run automatically
- Use deep scan for high-stakes situations (releases, audits)
- Agent has full context understanding vs regex pattern matching
