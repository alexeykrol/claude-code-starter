# Analyze Local Bug Reports Command

**Purpose:** Analyze local bug reports to find patterns and recurring issues.

**Usage:**
```bash
/analyze-local-bugs
```

---

## Implementation

### Run Pattern Analysis Script

```bash
# Check if script exists
if [ ! -f ".claude/scripts/analyze-bug-patterns.sh" ]; then
  echo "⚠️  Bug pattern analyzer not found"
  echo "   Expected: .claude/scripts/analyze-bug-patterns.sh"
  exit 1
fi

# Run analysis
bash .claude/scripts/analyze-bug-patterns.sh
```

---

## What Gets Analyzed

The script analyzes all bug reports in `.claude/logs/bug-reports/` and generates:

1. **Framework Version Distribution** - Which versions have most reports
2. **Protocol Type Distribution** - Cold Start vs Completion failures
3. **Most Common Errors** - Top 5 error messages
4. **Step Failure Analysis** - Which protocol steps fail most
5. **Recommendations** - Actionable insights and fixes

## Output

- **Console:** Visual summary with statistics and recommendations
- **File:** Detailed report saved to `.claude/logs/bug-analysis-TIMESTAMP.md`

---

## Notes

- **Works Everywhere:** Available in both framework and host projects
- **Local Analysis:** Analyzes only local bug reports (not GitHub Issues)
- **Complementary:** Use with `/analyze-bugs` (GitHub Issues) for complete picture
- **Privacy:** All data stays local, no network requests

---

## See Also

- `/analyze-bugs` - Analyze centralized GitHub Issues (framework project only)
- `/bug-reporting` - Manage bug reporting settings
