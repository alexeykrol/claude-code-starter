#!/bin/bash
#
# Claude Code Starter Framework — Initial Security Scan
#
# Purpose: Scan existing project for credentials during legacy migration
# Usage: bash security/initial-scan.sh
#
# This is MANDATORY during legacy migration (first-time framework integration)
# If credentials found → STOPS migration and asks user for action

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🔒 Initial Security Scan${NC}"
echo -e "${BLUE}  Scanning existing project for credentials...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create report directory
mkdir -p security/reports
REPORT_FILE="security/reports/initial-scan-$(date +%Y%m%d-%H%M%S).txt"

# Initialize counters
ISSUES_FOUND=0
CRITICAL_ISSUES=0
HIGH_ISSUES=0
MEDIUM_ISSUES=0

# Start report
cat > "$REPORT_FILE" <<EOF
Initial Security Scan Report
Generated: $(date -Iseconds)
Project: $(basename "$(pwd)")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

# ============================================================================
# CRITICAL: Check for committed .env files
# ============================================================================

echo -e "${YELLOW}⚠${NC}  Checking for .env files in repository..."

ENV_FILES=$(find . -type f \( \
  -name ".env" -o \
  -name ".env.local" -o \
  -name ".env.production" -o \
  -name ".env.development" \
\) ! -path "*/node_modules/*" ! -path "*/.git/*" 2>/dev/null)

if [ -n "$ENV_FILES" ]; then
  CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
  echo -e "${RED}🚨 CRITICAL: .env files found in repository!${NC}"
  echo ""
  echo "$ENV_FILES" | while read file; do
    echo "  • $file"
  done
  echo ""

  cat >> "$REPORT_FILE" <<EOF
🚨 CRITICAL: .env Files in Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found .env files that should NEVER be committed:

EOF
  echo "$ENV_FILES" | while read file; do
    echo "  • $file" >> "$REPORT_FILE"
  done
  echo "" >> "$REPORT_FILE"
else
  echo -e "${GREEN}✓${NC} No .env files in repository"
fi

# ============================================================================
# CRITICAL: Check for credentials/secrets files
# ============================================================================

echo -e "${YELLOW}⚠${NC}  Checking for credential files..."

CRED_FILES=$(find . -type f \( \
  -name "*credentials*" -o \
  -name "*secret*" -o \
  -name "*password*" -o \
  -name "*.pem" -o \
  -name "*.key" -o \
  -name "*token*" \
\) ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" 2>/dev/null)

if [ -n "$CRED_FILES" ]; then
  # Filter out likely false positives
  REAL_CREDS=$(echo "$CRED_FILES" | grep -v "README" | grep -v "test" | grep -v "example" | grep -v ".md" || true)

  if [ -n "$REAL_CREDS" ]; then
    HIGH_ISSUES=$((HIGH_ISSUES + 1))
    echo -e "${RED}⚠️  HIGH: Potential credential files found!${NC}"
    echo ""
    echo "$REAL_CREDS" | while read file; do
      echo "  • $file"
    done
    echo ""

    cat >> "$REPORT_FILE" <<EOF
⚠️  HIGH: Potential Credential Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found files with credential-related names:

EOF
    echo "$REAL_CREDS" | while read file; do
      echo "  • $file" >> "$REPORT_FILE"
    done
    echo "" >> "$REPORT_FILE"
  else
    echo -e "${GREEN}✓${NC} No suspicious credential files (only test/example files)"
  fi
else
  echo -e "${GREEN}✓${NC} No credential files found"
fi

# ============================================================================
# HIGH: Scan code for hardcoded credentials
# ============================================================================

echo -e "${YELLOW}⚠${NC}  Scanning code for hardcoded credentials..."

# Common patterns for hardcoded credentials
HARDCODED=$(grep -r -n -E \
  '(password|api_key|secret|token|access_key|private_key)\s*=\s*["\047][^"\047]{8,}' \
  . \
  --include="*.js" \
  --include="*.ts" \
  --include="*.tsx" \
  --include="*.jsx" \
  --include="*.py" \
  --include="*.java" \
  --include="*.go" \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=build \
  2>/dev/null | head -20 || true)

if [ -n "$HARDCODED" ]; then
  HIGH_ISSUES=$((HIGH_ISSUES + 1))
  echo -e "${RED}⚠️  HIGH: Hardcoded credentials found in code!${NC}"
  echo ""
  echo "$HARDCODED" | head -10 | while IFS= read -r line; do
    echo "  • $line"
  done
  if [ $(echo "$HARDCODED" | wc -l) -gt 10 ]; then
    echo "  ... and $(($(echo "$HARDCODED" | wc -l) - 10)) more occurrences"
  fi
  echo ""

  cat >> "$REPORT_FILE" <<EOF
⚠️  HIGH: Hardcoded Credentials in Code
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found potential hardcoded credentials:

EOF
  echo "$HARDCODED" | while IFS= read -r line; do
    echo "  • $line" >> "$REPORT_FILE"
  done
  echo "" >> "$REPORT_FILE"
else
  echo -e "${GREEN}✓${NC} No hardcoded credentials detected"
fi

# ============================================================================
# MEDIUM: Check for API keys in config files
# ============================================================================

echo -e "${YELLOW}⚠${NC}  Checking configuration files..."

CONFIG_KEYS=$(grep -r -n -E \
  '(API_KEY|APIKEY|api_key|SECRET|secret|TOKEN|token|PASSWORD|password)\s*[:=]' \
  . \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --include="*.toml" \
  --include="*.ini" \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  2>/dev/null | grep -v "example" | grep -v "test" | head -10 || true)

if [ -n "$CONFIG_KEYS" ]; then
  MEDIUM_ISSUES=$((MEDIUM_ISSUES + 1))
  echo -e "${YELLOW}⚠️  MEDIUM: Potential keys in configuration files${NC}"
  echo ""
  echo "$CONFIG_KEYS" | while IFS= read -r line; do
    echo "  • $line"
  done
  echo ""

  cat >> "$REPORT_FILE" <<EOF
⚠️  MEDIUM: Configuration Files with Keys
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found potential keys in config files:

EOF
  echo "$CONFIG_KEYS" | while IFS= read -r line; do
    echo "  • $line" >> "$REPORT_FILE"
  done
  echo "" >> "$REPORT_FILE"
else
  echo -e "${GREEN}✓${NC} No keys in configuration files"
fi

# ============================================================================
# MEDIUM: Check .gitignore coverage
# ============================================================================

echo -e "${YELLOW}⚠${NC}  Checking .gitignore for security patterns..."

if [ -f ".gitignore" ]; then
  GITIGNORE_OK=true

  # Check for common security patterns
  if ! grep -q "\.env" .gitignore 2>/dev/null; then
    GITIGNORE_OK=false
    MEDIUM_ISSUES=$((MEDIUM_ISSUES + 1))
    echo -e "${YELLOW}⚠️  MEDIUM: .env not in .gitignore${NC}"
  fi

  if ! grep -q "credentials" .gitignore 2>/dev/null; then
    GITIGNORE_OK=false
    MEDIUM_ISSUES=$((MEDIUM_ISSUES + 1))
    echo -e "${YELLOW}⚠️  MEDIUM: credentials not in .gitignore${NC}"
  fi

  if [ "$GITIGNORE_OK" = true ]; then
    echo -e "${GREEN}✓${NC} .gitignore has security patterns"
  else
    cat >> "$REPORT_FILE" <<EOF
⚠️  MEDIUM: .gitignore Missing Security Patterns
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

.gitignore should include:
  • .env
  • .env.*
  • *credentials*
  • *secret*
  • *.pem
  • *.key

EOF
  fi
else
  MEDIUM_ISSUES=$((MEDIUM_ISSUES + 1))
  echo -e "${YELLOW}⚠️  MEDIUM: No .gitignore file found${NC}"

  cat >> "$REPORT_FILE" <<EOF
⚠️  MEDIUM: No .gitignore File
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project should have .gitignore with security patterns.

EOF
fi

# ============================================================================
# Summary
# ============================================================================

TOTAL_ISSUES=$((CRITICAL_ISSUES + HIGH_ISSUES + MEDIUM_ISSUES))

cat >> "$REPORT_FILE" <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Issues: $TOTAL_ISSUES
  • CRITICAL: $CRITICAL_ISSUES
  • HIGH: $HIGH_ISSUES
  • MEDIUM: $MEDIUM_ISSUES

Report saved: $REPORT_FILE

EOF

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Scan Complete${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Total Issues: $TOTAL_ISSUES"
echo "  • CRITICAL: $CRITICAL_ISSUES"
echo "  • HIGH: $HIGH_ISSUES"
echo "  • MEDIUM: $MEDIUM_ISSUES"
echo ""
echo "Report: $REPORT_FILE"
echo ""

# Exit code based on severity
if [ $CRITICAL_ISSUES -gt 0 ]; then
  exit 2  # CRITICAL
elif [ $HIGH_ISSUES -gt 0 ]; then
  exit 1  # HIGH
elif [ $MEDIUM_ISSUES -gt 0 ]; then
  exit 3  # MEDIUM
else
  exit 0  # CLEAN
fi
