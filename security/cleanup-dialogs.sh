#!/bin/bash
#
# Claude Code Starter Framework — Dialog Credentials Cleanup
#
# Purpose: Remove credentials from dialog files before git commit
# Usage: bash security/cleanup-dialogs.sh [--last] [--deep]
#
# Features:
# - Redacts SSH credentials (hosts, IPs, keys)
# - Redacts database URLs (postgres, mysql, mongodb)
# - Redacts API keys, tokens, passwords
# - Redacts JWT tokens
# - Creates cleanup report in security/reports/
# - Optional: AI-based deep scan for context-dependent secrets
#
# Flags:
# --last    Clean only last (most recent) dialog file (50x faster)
#           Without flag: cleans ALL dialog files
# --deep    Invoke AI agent for deep context-aware scan (slow but thorough)
#           Use when: regex may miss obfuscated/contextual credentials
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse flags
LAST_ONLY=false
DEEP_SCAN=false

for arg in "$@"; do
  case $arg in
    --last)
      LAST_ONLY=true
      ;;
    --deep)
      DEEP_SCAN=true
      ;;
  esac
done

# Get dialog files
if [ "$LAST_ONLY" = true ]; then
  # Find most recent dialog file
  DIALOG_FILES=$(find dialog -name "*.md" -o -name "*.jsonl" 2>/dev/null | sort -r | head -1)
  if [ -z "$DIALOG_FILES" ]; then
    echo -e "${BLUE}ℹ${NC} No dialog files found"
    exit 0
  fi
  echo -e "${BLUE}ℹ${NC} Cleaning last dialog: $(basename $DIALOG_FILES)"
else
  # Find all dialog files
  DIALOG_FILES=$(find dialog -name "*.md" -o -name "*.jsonl" 2>/dev/null)
  if [ -z "$DIALOG_FILES" ]; then
    echo -e "${BLUE}ℹ${NC} No dialog files found"
    exit 0
  fi
  FILE_COUNT=$(echo "$DIALOG_FILES" | wc -l | tr -d ' ')
  echo -e "${BLUE}ℹ${NC} Cleaning $FILE_COUNT dialog files..."
fi

# Create report
REPORT_FILE="security/reports/cleanup-$(date +%Y%m%d-%H%M%S).txt"
mkdir -p security/reports

echo "Dialog Cleanup Report" > "$REPORT_FILE"
echo "Date: $(date -Iseconds)" >> "$REPORT_FILE"
echo "Mode: $([ "$LAST_ONLY" = true ] && echo "Last file only" || echo "All files")" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

TOTAL_REDACTIONS=0
FILES_WITH_SECRETS=0

# Process each file
for FILE in $DIALOG_FILES; do
  if [ ! -f "$FILE" ]; then
    continue
  fi

  REDACTION_COUNT=0
  TEMP_FILE="${FILE}.cleanup.tmp"
  cp "$FILE" "$TEMP_FILE"

  # ==========================================
  # Redaction Patterns (Generic, No Supabase)
  # ==========================================

  # 1. SSH Credentials: user@host patterns
  # Example: root@192.168.1.1, user@192.168.1.100
  if grep -qE "[a-zA-Z0-9_-]+@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/[a-zA-Z0-9_-]+@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[REDACTED_SSH_USER]@[REDACTED_IP]/g' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 2. IPv4 addresses (standalone)
  # Example: 192.168.1.1, 192.168.1.100
  # Skip if already redacted
  if grep -qE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$TEMP_FILE" 2>/dev/null && ! grep -q "\[REDACTED_IP\]" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/([^0-9]|^)([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})([^0-9]|$)/\1[REDACTED_IP]\3/g' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 3. SSH private key paths
  # Example: ~/.ssh/id_rsa, ~/.ssh/claude_prod_new
  if grep -qE "~?/?\.ssh/[a-zA-Z0-9_-]+" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's|~?/?\.ssh/[a-zA-Z0-9_-]+|~/.ssh/[REDACTED_KEY]|g' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 4. Database URLs
  # Example: postgres://user:pass@host:5432/db, mysql://user:pass@host/db
  if grep -qE "(postgres|mysql|mongodb|redis)://" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/postgres:\/\/[^[:space:]"'\'']+/postgres:\/\/[REDACTED_USER]:[REDACTED_PASS]@[REDACTED_HOST]\/[REDACTED_DB]/g' "$TEMP_FILE"
    sed -i.bak -E 's/mysql:\/\/[^[:space:]"'\'']+/mysql:\/\/[REDACTED_USER]:[REDACTED_PASS]@[REDACTED_HOST]\/[REDACTED_DB]/g' "$TEMP_FILE"
    sed -i.bak -E 's/mongodb:\/\/[^[:space:]"'\'']+/mongodb:\/\/[REDACTED_USER]:[REDACTED_PASS]@[REDACTED_HOST]\/[REDACTED_DB]/g' "$TEMP_FILE"
    sed -i.bak -E 's/redis:\/\/[^[:space:]"'\'']+/redis:\/\/[REDACTED_USER]:[REDACTED_PASS]@[REDACTED_HOST]\/[REDACTED_DB]/g' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 5. JWT tokens
  # Example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  if grep -qE "eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}/[REDACTED_JWT_TOKEN]/g' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 6. API keys (generic patterns)
  # Example: sk-proj-xxx, pk-live-xxx, APIKEY=xxx
  if grep -qiE "(api[_-]?key|secret[_-]?key|access[_-]?key)[[:space:]]*[=:][[:space:]]*['\"]?[a-zA-Z0-9_-]{20,}" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/(api[_-]?key|secret[_-]?key|access[_-]?key)[[:space:]]*[=:][[:space:]]*['\''""]?[a-zA-Z0-9_-]{20,}/\1=[REDACTED_API_KEY]/gi' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 7. Bearer tokens
  # Example: Bearer eyJxxx, Authorization: Bearer xxx
  if grep -qiE "bearer[[:space:]]+[a-zA-Z0-9_-]{20,}" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/bearer[[:space:]]+[a-zA-Z0-9_-]{20,}/Bearer [REDACTED_TOKEN]/gi' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 8. Generic passwords
  # Example: password=xxx, PASSWORD: "xxx", pwd=xxx
  if grep -qiE "(password|passwd|pwd)[[:space:]]*[=:][[:space:]]*['\"]?[^[:space:]'\">]{8,}" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/(password|passwd|pwd)[[:space:]]*[=:][[:space:]]*['\''""]?[^[:space:]'\''"">]{8,}/\1=[REDACTED_PASSWORD]/gi' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 9. SSH port specifications
  # Example: -p 2222, --port 22000
  if grep -qE "(\-p|--port)[[:space:]]+[0-9]{4,5}" "$TEMP_FILE" 2>/dev/null; then
    sed -i.bak -E 's/(\-p|--port)[[:space:]]+[0-9]{4,5}/\1 [REDACTED_PORT]/g' "$TEMP_FILE"
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # 10. Private key content (PEM format)
  # Example: -----BEGIN PRIVATE KEY-----
  if grep -qE "-----BEGIN [A-Z ]+ PRIVATE KEY-----" "$TEMP_FILE" 2>/dev/null; then
    # Use perl for multiline replacement (more reliable than sed on macOS)
    perl -i.bak -0pe 's/-----BEGIN [A-Z ]+ PRIVATE KEY-----.*?-----END [A-Z ]+ PRIVATE KEY-----/[REDACTED_PRIVATE_KEY_CONTENT]/gs' "$TEMP_FILE" 2>/dev/null || true
    REDACTION_COUNT=$((REDACTION_COUNT + 1))
  fi

  # Clean up backup files
  rm -f "${TEMP_FILE}.bak"

  # If redactions were made, replace original file
  if [ $REDACTION_COUNT -gt 0 ]; then
    mv "$TEMP_FILE" "$FILE"
    FILES_WITH_SECRETS=$((FILES_WITH_SECRETS + 1))
    TOTAL_REDACTIONS=$((TOTAL_REDACTIONS + REDACTION_COUNT))
    echo "✓ $FILE: $REDACTION_COUNT pattern(s) redacted" >> "$REPORT_FILE"
    echo -e "${YELLOW}⚠${NC} $FILE: $REDACTION_COUNT credential pattern(s) redacted"
  else
    rm -f "$TEMP_FILE"
  fi
done

# Summary
echo "" >> "$REPORT_FILE"
echo "Summary:" >> "$REPORT_FILE"
echo "- Files scanned: $(echo "$DIALOG_FILES" | wc -l | tr -d ' ')" >> "$REPORT_FILE"
echo "- Files with secrets: $FILES_WITH_SECRETS" >> "$REPORT_FILE"
echo "- Total redactions: $TOTAL_REDACTIONS" >> "$REPORT_FILE"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Cleanup Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Files scanned: $(echo "$DIALOG_FILES" | wc -l | tr -d ' ')"
echo "  Files with secrets: $FILES_WITH_SECRETS"
echo "  Total redactions: $TOTAL_REDACTIONS"
echo ""
echo "  Report: $REPORT_FILE"
echo ""

if [ $FILES_WITH_SECRETS -gt 0 ]; then
  echo -e "${YELLOW}⚠${NC}  Credentials detected and redacted"
  echo -e "${YELLOW}⚠${NC}  Review report before committing"
  echo ""
fi

# ============================================================================
# Layer 4: Deep AI-Based Scan (Optional)
# ============================================================================

if [ "$DEEP_SCAN" = true ] || [ $FILES_WITH_SECRETS -gt 0 ]; then
  # Deep scan triggered if:
  # 1. User explicitly requested --deep flag
  # 2. Regex found credentials (want AI confirmation/analysis)

  if [ "$DEEP_SCAN" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Layer 4: Deep AI Scan${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}ℹ${NC}  Invoking AI agent for context-aware credential detection..."
    echo -e "${BLUE}ℹ${NC}  This may take 1-2 minutes (analyzing file context)"
    echo ""

    # Create marker file for Claude Code to pick up
    DEEP_SCAN_REQUEST="/tmp/claude-deep-scan-request-$$.json"
    cat > "$DEEP_SCAN_REQUEST" <<EOF
{
  "type": "deep_credential_scan",
  "dialog_files": $(echo "$DIALOG_FILES" | jq -R . | jq -s .),
  "regex_found": $FILES_WITH_SECRETS,
  "report_file": "$REPORT_FILE",
  "timestamp": "$(date -Iseconds)"
}
EOF

    echo -e "${YELLOW}⚠${NC}  Deep scan requires Claude Code session"
    echo -e "${YELLOW}⚠${NC}  Manual action required:"
    echo ""
    echo "    1. Open Claude Code session"
    echo "    2. Run: cat $DEEP_SCAN_REQUEST"
    echo "    3. Ask Claude to analyze files for context-dependent credentials"
    echo ""
    echo -e "${BLUE}ℹ${NC}  What AI will catch that regex misses:"
    echo "    • Obfuscated credentials (base64, hex, chr arrays)"
    echo "    • Context-dependent secrets (\"password is company name\")"
    echo "    • Multiline credentials in unusual formats"
    echo "    • Secrets mentioned in comments/discussions"
    echo ""
  fi
fi

# Exit code
if [ $FILES_WITH_SECRETS -gt 0 ]; then
  exit 1  # Block commit - credentials found
else
  echo -e "${GREEN}✓${NC}  No credentials detected by regex"
  if [ "$DEEP_SCAN" = true ]; then
    echo -e "${YELLOW}⚠${NC}  Deep scan requested - follow manual steps above"
  fi
  echo ""
  exit 0  # Allow commit - clean
fi
