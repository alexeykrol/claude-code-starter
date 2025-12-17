# Bug Reporting Management Command

**Purpose:** Manage bug reporting settings for the framework.

## Usage

```bash
/bug-reporting [enable|disable|status|test]
```

## Commands

### enable
Enable anonymous bug reporting. When enabled, the framework will:
- Log Cold Start and Completion protocol steps
- Create anonymized bug reports when errors occur
- Submit reports to GitHub Issues (if error is critical)

### disable
Disable bug reporting. No logs will be created, no reports will be sent.

### status
Show current bug reporting configuration:
- Current status (enabled/disabled)
- Project name
- Config version
- Last update timestamp

### test
Test the bug reporting system by creating a sample report (does not submit).

---

## Implementation

### Enable Bug Reporting

```bash
if [ ! -f ".claude/.framework-config" ]; then
  echo "⚠️  Framework config not found. Run 'start' first to initialize."
  exit 1
fi

# Update config to enable
cat .claude/.framework-config | \
  sed 's/"bug_reporting_enabled": false/"bug_reporting_enabled": true/' > \
  .claude/.framework-config.tmp
mv .claude/.framework-config.tmp .claude/.framework-config

echo "✅ Bug reporting enabled"
echo ""
echo "What will be collected:"
echo "  • Anonymous error reports when crashes occur"
echo "  • Protocol execution logs (Cold Start, Completion)"
echo "  • Framework version and step information"
echo ""
echo "What will NOT be collected:"
echo "  • Your code or file contents"
echo "  • File paths (anonymized)"
echo "  • API keys, tokens, secrets (removed)"
echo ""
```

### Disable Bug Reporting

```bash
if [ ! -f ".claude/.framework-config" ]; then
  echo "⚠️  Framework config not found. Run 'start' first to initialize."
  exit 1
fi

# Update config to disable
cat .claude/.framework-config | \
  sed 's/"bug_reporting_enabled": true/"bug_reporting_enabled": false/' > \
  .claude/.framework-config.tmp
mv .claude/.framework-config.tmp .claude/.framework-config

echo "✅ Bug reporting disabled"
echo ""
echo "Existing logs in .claude/logs/ will be preserved but not submitted."
echo "You can delete them manually if needed."
echo ""
```

### Show Status

```bash
if [ ! -f ".claude/.framework-config" ]; then
  echo "⚠️  Framework config not found. Run 'start' first to initialize."
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 Bug Reporting Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse config
BUG_REPORTING=$(cat .claude/.framework-config | grep -o '"bug_reporting_enabled": *[^,}]*' | sed 's/.*: *//' | tr -d ' ')
PROJECT_NAME=$(cat .claude/.framework-config | grep -o '"project_name": *"[^"]*"' | sed 's/.*: *"//' | tr -d '"')

echo "Status: $BUG_REPORTING"
echo "Project: $PROJECT_NAME"
echo ""

# Count logs
COLD_START_LOGS=$(find .claude/logs/cold-start -type f 2>/dev/null | wc -l | tr -d ' ')
COMPLETION_LOGS=$(find .claude/logs/completion -type f 2>/dev/null | wc -l | tr -d ' ')

echo "Local logs:"
echo "  • Cold Start: $COLD_START_LOGS"
echo "  • Completion: $COMPLETION_LOGS"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

### Test Bug Reporting

```bash
if [ ! -f ".claude/.framework-config" ]; then
  echo "⚠️  Framework config not found. Run 'start' first to initialize."
  exit 1
fi

echo "🧪 Testing bug reporting system..."
echo ""

# Create test directories
mkdir -p .claude/logs/test

# Generate test report
PROJECT_NAME=$(basename "$(pwd)")
TIMESTAMP=$(date -Iseconds)
LOG_FILE=".claude/logs/test/test-report-${TIMESTAMP}.md"

cat > "$LOG_FILE" <<EOF
# Test Bug Report

**Generated:** $TIMESTAMP
**Project:** ${PROJECT_NAME}_anon
**Framework:** $(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1)

## Test Error

This is a test error report.

\`\`\`
Error: Test error
  at testFunction (test.ts:42)
  at main (test.ts:100)
\`\`\`

## System Info

- OS: $(uname -s)
- Shell: $SHELL

## Notes

This is a test report. No actual error occurred.
EOF

echo "✅ Test report created: $LOG_FILE"
echo ""
echo "Report contents:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

---

**Notes:**
- Config stored in `.claude/.framework-config` (JSON)
- Logs stored in `.claude/logs/` (gitignored)
- Reports anonymized before submission
- Fully opt-in, user controlled
