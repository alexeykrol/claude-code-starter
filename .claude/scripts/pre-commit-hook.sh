#!/bin/bash
#
# Claude Code Starter Framework — Pre-commit Hook
# Last line of defense against accidental leaks
#
# This hook is automatically installed by framework
# Location: .git/hooks/pre-commit (symlinked to this file)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Read forbidden patterns from COMMIT_POLICY.md
# These patterns should NEVER be committed
FORBIDDEN_PATTERNS=(
  # Internal development
  "^notes/"
  "^scratch/"
  "^experiments/"
  "/WIP_"
  "/INTERNAL_"
  "/DRAFT_"

  # Framework logs and dialogs (CRITICAL!)
  "^dialog/"
  "^\.claude/logs/"
  "\.debug\.log$"
  "^debug/"

  # Local configs
  "\.local\."
  "^\.vscode/"
  "^\.idea/"

  # Sensitive data (CRITICAL!)
  "^secrets/"
  "^credentials/"
  "\.key$"
  "\.pem$"
  "^\.production-credentials"
  "^backup/"
)

# Get staged files
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
  # No files staged, allow commit
  exit 0
fi

# Check each staged file against forbidden patterns
BLOCKED_FILES=()

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  MATCHES=$(echo "$STAGED_FILES" | grep -E "$pattern" || true)
  if [ -n "$MATCHES" ]; then
    while IFS= read -r file; do
      BLOCKED_FILES+=("$file")
    done <<< "$MATCHES"
  fi
done

# Remove duplicates
BLOCKED_FILES=($(printf '%s\n' "${BLOCKED_FILES[@]}" | sort -u))

if [ ${#BLOCKED_FILES[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}❌ COMMIT BLOCKED by COMMIT_POLICY.md${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${YELLOW}Forbidden files detected in commit:${NC}"
  echo ""

  for file in "${BLOCKED_FILES[@]}"; do
    echo -e "  ${RED}•${NC} $file"
  done

  echo ""
  echo -e "${YELLOW}These files match COMMIT_POLICY 'НИКОГДА' patterns.${NC}"
  echo ""
  echo "To fix:"
  echo "  1. Review .claude/COMMIT_POLICY.md"
  echo "  2. Unstage forbidden files: git reset HEAD <file>"
  echo "  3. Add to .gitignore if needed"
  echo "  4. Retry commit"
  echo ""
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  exit 1
fi

# All clear, allow commit
exit 0
