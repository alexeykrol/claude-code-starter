#!/bin/bash
#
# Bug Report Pattern Analyzer
#
# Analyzes bug reports in .claude/logs/bug-reports/ to find:
# - Most common errors
# - Protocol failure patterns
# - Recurring issues
# - Framework version distribution
#

set -e

BUG_REPORTS_DIR=".claude/logs/bug-reports"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  Bug Report Pattern Analysis${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if bug reports directory exists
if [ ! -d "$BUG_REPORTS_DIR" ]; then
  echo -e "${YELLOW}⚠${NC} No bug reports directory found"
  echo ""
  echo "Location: $BUG_REPORTS_DIR"
  echo ""
  exit 0
fi

# Count bug reports
REPORT_COUNT=$(find "$BUG_REPORTS_DIR" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$REPORT_COUNT" -eq 0 ]; then
  echo -e "${GREEN}✓${NC} No bug reports found"
  echo ""
  echo "Your framework is running smoothly!"
  echo ""
  exit 0
fi

echo -e "${BLUE}ℹ${NC} Found ${BOLD}$REPORT_COUNT${NC} bug report(s)"
echo ""

# ============================================================================
# 1. Framework Version Distribution
# ============================================================================

echo -e "${CYAN}━━━ Framework Version Distribution ━━━${NC}"
echo ""

temp_versions=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Framework:" {} \; 2>/dev/null | awk '{print $NF}' > "$temp_versions"

if [ -s "$temp_versions" ]; then
  sort "$temp_versions" | uniq -c | sort -rn | while read -r count version; do
    percentage=$((count * 100 / REPORT_COUNT))
    echo -e "  ${version}: ${BOLD}${count}${NC} reports (${percentage}%)"
  done
else
  echo "  No version information found"
fi

rm -f "$temp_versions"
echo ""

# ============================================================================
# 2. Protocol Type Distribution
# ============================================================================

echo -e "${CYAN}━━━ Protocol Type Distribution ━━━${NC}"
echo ""

temp_protocols=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Protocol:" {} \; 2>/dev/null | sed 's/Protocol://' | xargs -n1 > "$temp_protocols"

if [ -s "$temp_protocols" ]; then
  sort "$temp_protocols" | uniq -c | sort -rn | while read -r count protocol; do
    percentage=$((count * 100 / REPORT_COUNT))
    echo -e "  ${protocol}: ${BOLD}${count}${NC} reports (${percentage}%)"
  done
else
  echo "  No protocol information found"
fi

rm -f "$temp_protocols"
echo ""

# ============================================================================
# 3. Most Common Errors (Top 5)
# ============================================================================

echo -e "${CYAN}━━━ Most Common Errors (Top 5) ━━━${NC}"
echo ""

# Extract error messages and count occurrences
temp_errors=$(mktemp)

while IFS= read -r report; do
  # Extract error messages (lines starting with "Error:" or "TypeError:", etc.)
  grep -E "^(Error|TypeError|ReferenceError|SyntaxError|RangeError):" "$report" 2>/dev/null | head -1 >> "$temp_errors" || true
done < <(find "$BUG_REPORTS_DIR" -type f -name "*.md")

if [ -s "$temp_errors" ]; then
  # Count and sort by frequency
  sort "$temp_errors" | uniq -c | sort -rn | head -5 | while read -r count error; do
    # Truncate long error messages
    short_error=$(echo "$error" | cut -c1-70)
    if [ ${#error} -gt 70 ]; then
      short_error="${short_error}..."
    fi
    echo -e "  ${BOLD}${count}x${NC} $short_error"
  done
else
  echo "  No error messages found"
fi

rm -f "$temp_errors"

echo ""

# ============================================================================
# 4. Step Failure Analysis
# ============================================================================

echo -e "${CYAN}━━━ Step Failure Analysis ━━━${NC}"
echo ""

temp_steps=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Step:" {} \; 2>/dev/null | sed 's/Step://' | xargs -n1 > "$temp_steps"

if [ -s "$temp_steps" ]; then
  sort "$temp_steps" | uniq -c | sort -rn | head -10 | while read -r count step; do
    echo -e "  Step ${BOLD}${step}${NC}: ${count} failure(s)"
  done
else
  echo "  No step information found"
fi

rm -f "$temp_steps"
echo ""

# ============================================================================
# 5. Recommendations
# ============================================================================

echo -e "${CYAN}━━━ Recommendations ━━━${NC}"
echo ""

# Find most problematic protocol
temp_protocols_rec=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Protocol:" {} \; 2>/dev/null | sed 's/Protocol://' | xargs -n1 > "$temp_protocols_rec"

if [ -s "$temp_protocols_rec" ]; then
  max_protocol_line=$(sort "$temp_protocols_rec" | uniq -c | sort -rn | head -1)
  max_protocol_count=$(echo "$max_protocol_line" | awk '{print $1}')
  max_protocol=$(echo "$max_protocol_line" | awk '{$1=""; print $0}' | xargs)

  if [ "$max_protocol_count" -gt 1 ]; then
    echo -e "  ${YELLOW}⚠${NC} ${BOLD}$max_protocol${NC} has $max_protocol_count failures"
    echo "    → Review protocol logic and error handling"
    echo ""
  fi
fi
rm -f "$temp_protocols_rec"

# Check for version-specific issues
temp_versions_rec=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Framework:" {} \; 2>/dev/null | awk '{print $NF}' > "$temp_versions_rec"

if [ -s "$temp_versions_rec" ]; then
  sort "$temp_versions_rec" | uniq -c | while read -r count version; do
    if [ "$count" -ge 3 ]; then
      echo -e "  ${YELLOW}⚠${NC} Version ${BOLD}${version}${NC} has $count reports"
      echo "    → Consider releasing bug fix update"
      echo ""
    fi
  done
fi
rm -f "$temp_versions_rec"

# General recommendations
if [ "$REPORT_COUNT" -ge 5 ]; then
  echo -e "  ${BLUE}ℹ${NC} ${BOLD}$REPORT_COUNT total reports${NC}"
  echo "    → Review error patterns and implement fixes"
  echo "    → Consider adding more defensive error handling"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# 6. Export Summary
# ============================================================================

SUMMARY_FILE=".claude/logs/bug-analysis-$(date +%Y%m%d-%H%M%S).md"

cat > "$SUMMARY_FILE" <<EOF
# Bug Report Analysis Summary

**Generated:** $(date -Iseconds)
**Total Reports:** $REPORT_COUNT

## Framework Version Distribution

EOF

# Add version distribution to summary
temp_versions_summary=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Framework:" {} \; 2>/dev/null | awk '{print $NF}' > "$temp_versions_summary"
if [ -s "$temp_versions_summary" ]; then
  sort "$temp_versions_summary" | uniq -c | sort -rn | while read -r count version; do
    percentage=$((count * 100 / REPORT_COUNT))
    echo "- $version: $count reports (${percentage}%)" >> "$SUMMARY_FILE"
  done
fi
rm -f "$temp_versions_summary"

cat >> "$SUMMARY_FILE" <<EOF

## Protocol Type Distribution

EOF

# Add protocol distribution to summary
temp_protocols_summary=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Protocol:" {} \; 2>/dev/null | sed 's/Protocol://' | xargs -n1 > "$temp_protocols_summary"
if [ -s "$temp_protocols_summary" ]; then
  sort "$temp_protocols_summary" | uniq -c | sort -rn | while read -r count protocol; do
    percentage=$((count * 100 / REPORT_COUNT))
    echo "- $protocol: $count reports (${percentage}%)" >> "$SUMMARY_FILE"
  done
fi
rm -f "$temp_protocols_summary"

cat >> "$SUMMARY_FILE" <<EOF

## Step Failure Analysis

EOF

# Add step analysis to summary
temp_steps_summary=$(mktemp)
find "$BUG_REPORTS_DIR" -type f -name "*.md" -exec grep "Step:" {} \; 2>/dev/null | sed 's/Step://' | xargs -n1 > "$temp_steps_summary"
if [ -s "$temp_steps_summary" ]; then
  sort "$temp_steps_summary" | uniq -c | sort -rn | head -10 | while read -r count step; do
    echo "- Step $step: $count failure(s)" >> "$SUMMARY_FILE"
  done
fi
rm -f "$temp_steps_summary"

cat >> "$SUMMARY_FILE" <<EOF

## Next Steps

1. Review most common errors and implement fixes
2. Add defensive error handling for problematic steps
3. Consider regression tests for recurring issues
4. Update documentation for common failure patterns

---
*Analysis tool: Bug Report Pattern Analyzer v1.0*
EOF

echo -e "${GREEN}✓${NC} Summary saved to: ${BOLD}$SUMMARY_FILE${NC}"
echo ""
