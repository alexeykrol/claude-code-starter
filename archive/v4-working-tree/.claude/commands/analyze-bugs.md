# Analyze Bug Reports Command

**Purpose:** Analyze bug reports from host projects (framework project only).

**Usage:**
```bash
/analyze-bugs
```

---

## Implementation

### 1. Verify Framework Project

```bash
# Check if this is the framework project
if [ ! -d "migration" ] || [ ! -f "migration/build-distribution.sh" ]; then
  echo "⚠️  This command is only available in the framework project"
  echo "   (claude-code-starter repository)"
  exit 1
fi
```

### 2. Fetch Bug Reports from GitHub Issues

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Analyzing Bug Reports"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Fetch all open issues with bug-report label
echo "Fetching bug reports from GitHub..."
gh issue list --label "bug-report" --state open --json number,title,body,createdAt,url > /tmp/bug-reports.json 2>/dev/null || {
  echo "⚠️  Failed to fetch issues. Make sure 'gh' CLI is installed and authenticated."
  echo "   Run: gh auth login"
  exit 1
}

# Count reports
REPORT_COUNT=$(cat /tmp/bug-reports.json | jq length)

if [ "$REPORT_COUNT" -eq "0" ]; then
  echo "✅ No open bug reports found"
  echo ""
  exit 0
fi

echo "Found $REPORT_COUNT bug report(s)"
echo ""
```

### 3. Group Reports by Error Type

```bash
# Create analysis directory
mkdir -p .claude/logs/bug-analysis
ANALYSIS_FILE=".claude/logs/bug-analysis/analysis-$(date +%Y%m%d-%H%M%S).md"

# Start analysis file
cat > "$ANALYSIS_FILE" <<EOF
# Bug Report Analysis

**Generated:** $(date -Iseconds)
**Total Reports:** $REPORT_COUNT

## Summary by Error Type

EOF

# Group by error patterns (simplified - can be enhanced)
echo "Analyzing error patterns..."
echo ""

# Parse each report
for i in $(seq 0 $((REPORT_COUNT - 1))); do
  ISSUE_NUM=$(cat /tmp/bug-reports.json | jq -r ".[$i].number")
  TITLE=$(cat /tmp/bug-reports.json | jq -r ".[$i].title")
  BODY=$(cat /tmp/bug-reports.json | jq -r ".[$i].body")
  URL=$(cat /tmp/bug-reports.json | jq -r ".[$i].url")
  CREATED=$(cat /tmp/bug-reports.json | jq -r ".[$i].createdAt")

  # Extract error type from body
  ERROR_TYPE="Unknown"
  if echo "$BODY" | grep -q "ERROR at"; then
    ERROR_TYPE=$(echo "$BODY" | grep "ERROR at" | head -1 | sed 's/.*ERROR at //')
  fi

  # Add to analysis
  cat >> "$ANALYSIS_FILE" <<EOF

### Issue #$ISSUE_NUM: $TITLE

**Created:** $CREATED
**Error Type:** $ERROR_TYPE
**URL:** $URL

**Error Details:**
\`\`\`
$(echo "$BODY" | sed -n '/```/,/```/p' | sed '1d;$d' | head -20)
\`\`\`

EOF

done

# Generate recommendations
cat >> "$ANALYSIS_FILE" <<EOF

---

## Recommendations

Based on the reports above, consider:

1. **Common Patterns:** Identify recurring error messages
2. **Framework Steps:** Which protocol steps fail most often?
3. **Priority:** Address issues affecting multiple projects first
4. **Testing:** Add regression tests for fixed issues

## Next Steps

- [ ] Review each report in detail
- [ ] Reproduce errors locally
- [ ] Create fix branches for each issue
- [ ] Add tests to prevent regression
- [ ] Close resolved issues

EOF

echo "✅ Analysis complete: $ANALYSIS_FILE"
echo ""
```

### 4. Display Summary

```bash
# Display summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Count by protocol type
COLD_START_ERRORS=$(cat /tmp/bug-reports.json | jq -r '.[].body' | grep -c "Cold Start Protocol" || echo "0")
COMPLETION_ERRORS=$(cat /tmp/bug-reports.json | jq -r '.[].body' | grep -c "Completion Protocol" || echo "0")

echo "• Total reports: $REPORT_COUNT"
echo "• Cold Start errors: $COLD_START_ERRORS"
echo "• Completion errors: $COMPLETION_ERRORS"
echo ""
echo "Full analysis: $ANALYSIS_FILE"
echo ""
echo "To review individual issues:"
echo "  gh issue list --label bug-report"
echo ""
echo "To view specific issue:"
echo "  gh issue view <number>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Cleanup temp file
rm -f /tmp/bug-reports.json
```

---

## Notes

- **Framework Project Only:** This command only works in the claude-code-starter repo
- **Requires gh CLI:** Must have GitHub CLI installed and authenticated
- **Analysis File:** Saves detailed analysis to `.claude/logs/bug-analysis/`
- **Groups by Type:** Categorizes errors by Cold Start vs Completion protocol
- **Actionable:** Provides next steps for addressing issues

---

## Prerequisites

```bash
# Install GitHub CLI (if not installed)
# macOS:
brew install gh

# Linux:
sudo apt install gh  # Debian/Ubuntu
sudo dnf install gh  # Fedora

# Authenticate
gh auth login
```
