#!/bin/bash
#
# Anonymize Bug Report Script
#
# Removes sensitive information from log files before sharing:
# - File paths (replace with generic paths)
# - API keys, tokens, secrets
# - Email addresses
# - IP addresses
# - Custom project-specific identifiers
#

set -e

# Check arguments
if [ -z "$1" ]; then
  echo "Usage: $0 <log-file>"
  exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
  echo "Error: Log file not found: $LOG_FILE"
  exit 1
fi

# Create anonymized reports directory
mkdir -p .claude/logs/bug-reports

# Generate output filename
PROJECT_NAME=$(basename "$(pwd)")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_FILE=".claude/logs/bug-reports/${PROJECT_NAME}-bug-${TIMESTAMP}.md"

# Copy log to report file
cp "$LOG_FILE" "$REPORT_FILE"

# ============================================
# Anonymization Rules
# ============================================

# 1. Replace absolute paths with generic paths
# Pattern: /Users/username/... → /PROJECT_ROOT/...
# Pattern: /home/username/... → /PROJECT_ROOT/...
# Pattern: C:\Users\username\... → PROJECT_ROOT\...
sed -i.bak -E \
  -e 's|/Users/[^/]+/[^/]+/[^/]+/([^/]+)|/PROJECT_ROOT/\1|g' \
  -e 's|/home/[^/]+/[^/]+/([^/]+)|/PROJECT_ROOT/\1|g' \
  -e 's|C:\\Users\\[^\\]+\\[^\\]+\\([^\\]+)|PROJECT_ROOT\\\1|g' \
  "$REPORT_FILE"

# 2. Replace project name with generic "project_anon"
# Already done in log generation, but ensure consistency
sed -i.bak "s/${PROJECT_NAME}/${PROJECT_NAME}_anon/g" "$REPORT_FILE"

# 3. Remove API keys and tokens
# Pattern: key=abc123, token=xyz789, apikey=..., api_key=...
sed -i.bak -E \
  -e 's/(api[_-]?key|token|secret|password)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9_-]+/\1=***REDACTED***/gi' \
  "$REPORT_FILE"

# 4. Remove email addresses
# Pattern: user@example.com → ***@***
sed -i.bak -E 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}/***@***/g' "$REPORT_FILE"

# 5. Remove IP addresses
# Pattern: 192.168.1.1 → *.*.*.*
sed -i.bak -E 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/*.*.*.*!/g' "$REPORT_FILE"

# 6. Remove GitHub tokens (gh_xxx, ghp_xxx, gho_xxx, etc.)
sed -i.bak -E 's/gh[ps]_[A-Za-z0-9]+/gh_***REDACTED***/g' "$REPORT_FILE"

# 7. Remove environment variables that might contain secrets
# Pattern: export FOO=bar → export FOO=***
sed -i.bak -E 's/(export [A-Z_]+)=[^[:space:]]+/\1=***/g' "$REPORT_FILE"

# 8. Remove npm tokens
sed -i.bak -E 's/npm_[A-Za-z0-9_]+/npm_***REDACTED***/g' "$REPORT_FILE"

# 9. Remove AWS keys
sed -i.bak -E 's/AKIA[0-9A-Z]{16}/AKIA***REDACTED***/g' "$REPORT_FILE"

# 10. Remove JWT tokens (base64 pattern)
sed -i.bak -E 's/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/JWT_***REDACTED***/g' "$REPORT_FILE"

# Clean up backup file
rm -f "$REPORT_FILE.bak"

# ============================================
# Generate Smart Title
# ============================================

# Detect protocol type
PROTOCOL_TYPE="Unknown"
if grep -q "# Cold Start Protocol Log" "$REPORT_FILE" 2>/dev/null; then
  PROTOCOL_TYPE="Cold Start"
elif grep -q "# Completion Protocol Log" "$REPORT_FILE" 2>/dev/null; then
  PROTOCOL_TYPE="Completion"
fi

# Extract framework version
FW_VERSION=$(grep "^\*\*Framework:\*\*" "$REPORT_FILE" 2>/dev/null | head -1 | sed 's/.*v\([0-9.]*\).*/\1/' | tr -d '\n')
if [ -z "$FW_VERSION" ]; then
  FW_VERSION="unknown"
fi

# Check for errors
STATUS="Success"
if grep -q "## ⚠️ ERROR\|ERROR at" "$REPORT_FILE" 2>/dev/null; then
  # Extract error description (first error line)
  ERROR_DESC=$(grep -E "## ⚠️ ERROR|ERROR at" "$REPORT_FILE" | head -1 | sed 's/.*ERROR[: ]*//' | cut -c1-50)
  if [ -n "$ERROR_DESC" ]; then
    STATUS="$ERROR_DESC"
  else
    STATUS="Error Detected"
  fi
fi

# Generate title
TITLE="[Bug Report][${PROTOCOL_TYPE}] v${FW_VERSION} - ${STATUS}"

# ============================================
# Add Title and Anonymization Notice
# ============================================

# Prepend title and notice to report
cat > "$REPORT_FILE.tmp" <<EOF
# $TITLE

---
**ANONYMIZED BUG REPORT**

This report has been automatically anonymized. The following data has been removed:
- File paths (replaced with /PROJECT_ROOT/...)
- API keys, tokens, secrets (replaced with ***REDACTED***)
- Email addresses (replaced with ***@***)
- IP addresses (replaced with *.*.*.*)
- Environment variables
- GitHub/npm/AWS tokens

Please review before submitting to ensure no sensitive data remains.
---

EOF

cat "$REPORT_FILE" >> "$REPORT_FILE.tmp"
mv "$REPORT_FILE.tmp" "$REPORT_FILE"

# ============================================
# Output result
# ============================================

echo "$REPORT_FILE"
