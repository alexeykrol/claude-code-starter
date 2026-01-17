#!/bin/bash
#
# Claude Code Starter Framework — Deep Scan Trigger Detection
#
# Purpose: Automatically detect situations requiring AI-based credential scan
# Usage: bash security/check-triggers.sh
#
# Output: JSON with trigger information
# Exit codes: 0 (no triggers), 1 (CRITICAL), 2 (HIGH), 3 (MEDIUM)

set -e

# Initialize results
TRIGGER_LEVEL="NONE"
TRIGGER_REASONS=()
TRIGGER_SCORE=0

# ============================================================================
# CRITICAL TRIGGERS (always invoke AI agent, no questions)
# ============================================================================

# 1. Production credentials file exists
if [ -f ".production-credentials" ] || [ -f ".production-credentials.json" ]; then
  TRIGGER_LEVEL="CRITICAL"
  TRIGGER_REASONS+=("Production credentials file detected (.production-credentials)")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 100))
fi

# 2. Git release tag detected (creating release)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if git describe --tags --exact-match HEAD 2>/dev/null | grep -q "^v[0-9]"; then
  TRIGGER_LEVEL="CRITICAL"
  TRIGGER_REASONS+=("Git release tag detected (creating release)")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 100))
fi

# 3. Release command detected in recent history
if [ -f ".claude/.last_session" ]; then
  # Check if /release was used recently
  RECENT_DIALOGS=$(find dialog -name "*.md" -mtime -1 2>/dev/null | head -1)
  if [ -n "$RECENT_DIALOGS" ] && grep -q "/release\|Creating release" "$RECENT_DIALOGS" 2>/dev/null; then
    TRIGGER_LEVEL="CRITICAL"
    TRIGGER_REASONS+=("Release workflow detected in recent dialogs")
    TRIGGER_SCORE=$((TRIGGER_SCORE + 100))
  fi
fi

# ============================================================================
# HIGH TRIGGERS (invoke AI agent with explanation)
# ============================================================================

# 4. Regex cleanup found credentials
if [ -f "security/reports/"*"cleanup-report"* ]; then
  LATEST_REPORT=$(ls -t security/reports/*cleanup-report* 2>/dev/null | head -1)
  if [ -f "$LATEST_REPORT" ]; then
    FILES_WITH_SECRETS=$(grep "Files with secrets:" "$LATEST_REPORT" | awk '{print $NF}')
    if [ -n "$FILES_WITH_SECRETS" ] && [ "$FILES_WITH_SECRETS" -gt 0 ]; then
      if [ "$TRIGGER_LEVEL" != "CRITICAL" ]; then
        TRIGGER_LEVEL="HIGH"
      fi
      TRIGGER_REASONS+=("Regex cleanup found $FILES_WITH_SECRETS file(s) with credentials")
      TRIGGER_SCORE=$((TRIGGER_SCORE + 50))
    fi
  fi
fi

# 5. Security-sensitive keywords in recent dialogs
RECENT_DIALOG=$(find dialog -name "*.md" -mtime -1 2>/dev/null | sort -r | head -1)
if [ -n "$RECENT_DIALOG" ]; then
  SENSITIVE_KEYWORDS="production|deploy|ssh.*key|api.*key|password|credential|token|secret|database.*url|postgres://|mysql://"
  KEYWORD_COUNT=$(grep -iE "$SENSITIVE_KEYWORDS" "$RECENT_DIALOG" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$KEYWORD_COUNT" -gt 5 ]; then
    if [ "$TRIGGER_LEVEL" = "NONE" ]; then
      TRIGGER_LEVEL="HIGH"
    fi
    TRIGGER_REASONS+=("Security-sensitive keywords detected ($KEYWORD_COUNT mentions)")
    TRIGGER_SCORE=$((TRIGGER_SCORE + 30))
  fi
fi

# 6. Production deployment mentioned
if [ -n "$RECENT_DIALOG" ] && grep -iq "production\|prod\|deploy" "$RECENT_DIALOG" 2>/dev/null; then
  if [ "$TRIGGER_LEVEL" = "NONE" ]; then
    TRIGGER_LEVEL="HIGH"
  fi
  TRIGGER_REASONS+=("Production/deployment discussion detected")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 40))
fi

# ============================================================================
# MEDIUM TRIGGERS (suggest AI agent, user can skip)
# ============================================================================

# 7. Large diff before commit
LINES_CHANGED=$(git diff --stat 2>/dev/null | tail -1 | awk '{print $4}' | tr -d '+')
if [ -n "$LINES_CHANGED" ] && [ "$LINES_CHANGED" -gt 500 ]; then
  if [ "$TRIGGER_LEVEL" = "NONE" ]; then
    TRIGGER_LEVEL="MEDIUM"
  fi
  TRIGGER_REASONS+=("Large diff detected ($LINES_CHANGED lines changed)")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 20))
fi

# 8. Many new dialog files uncommitted
NEW_DIALOGS=$(git ls-files --others --exclude-standard dialog/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$NEW_DIALOGS" -gt 5 ]; then
  if [ "$TRIGGER_LEVEL" = "NONE" ]; then
    TRIGGER_LEVEL="MEDIUM"
  fi
  TRIGGER_REASONS+=("Many new dialog files ($NEW_DIALOGS uncommitted)")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 15))
fi

# 9. Modified security-related files
SECURITY_FILES_CHANGED=$(git diff --name-only 2>/dev/null | grep -E "\.env|credentials|secrets|config" | wc -l | tr -d ' ')
if [ "$SECURITY_FILES_CHANGED" -gt 0 ]; then
  if [ "$TRIGGER_LEVEL" = "NONE" ]; then
    TRIGGER_LEVEL="MEDIUM"
  fi
  TRIGGER_REASONS+=("Security config files modified ($SECURITY_FILES_CHANGED files)")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 25))
fi

# ============================================================================
# LOW TRIGGERS (informational only, no action)
# ============================================================================

# 10. Long session (>2 hours since last commit)
LAST_COMMIT_TIME=$(git log -1 --format=%ct 2>/dev/null || echo "0")
CURRENT_TIME=$(date +%s)
SESSION_DURATION=$((CURRENT_TIME - LAST_COMMIT_TIME))
SESSION_HOURS=$((SESSION_DURATION / 3600))

if [ "$SESSION_HOURS" -gt 2 ]; then
  if [ "$TRIGGER_LEVEL" = "NONE" ]; then
    TRIGGER_LEVEL="LOW"
  fi
  TRIGGER_REASONS+=("Long session detected ($SESSION_HOURS hours)")
  TRIGGER_SCORE=$((TRIGGER_SCORE + 5))
fi

# ============================================================================
# Output JSON
# ============================================================================

# Convert reasons array to JSON
REASONS_JSON="["
FIRST=true
for reason in "${TRIGGER_REASONS[@]}"; do
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    REASONS_JSON+=","
  fi
  REASONS_JSON+="\"$reason\""
done
REASONS_JSON+="]"

# Generate recommendation
case $TRIGGER_LEVEL in
  CRITICAL) RECOMMENDATION="Invoke AI agent immediately (no confirmation needed)" ;;
  HIGH) RECOMMENDATION="Invoke AI agent with explanation to user" ;;
  MEDIUM) RECOMMENDATION="Suggest AI agent, allow user to skip" ;;
  LOW) RECOMMENDATION="Informational only, do not invoke agent" ;;
  NONE) RECOMMENDATION="No triggers detected, skip AI agent" ;;
esac

# Output result
cat <<EOF
{
  "trigger_level": "$TRIGGER_LEVEL",
  "trigger_score": $TRIGGER_SCORE,
  "reasons": $REASONS_JSON,
  "timestamp": "$(date -Iseconds)",
  "recommendation": "$RECOMMENDATION"
}
EOF

# Exit code based on trigger level
case $TRIGGER_LEVEL in
  CRITICAL) exit 1 ;;
  HIGH) exit 2 ;;
  MEDIUM) exit 3 ;;
  LOW) exit 4 ;;
  NONE) exit 0 ;;
esac
