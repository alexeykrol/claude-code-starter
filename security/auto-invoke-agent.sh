#!/bin/bash
#
# Claude Code Starter Framework — Security Trigger Advisory
#
# Purpose: Check security triggers and provide recommendations to Claude AI
# Usage: bash security/auto-invoke-agent.sh
#
# This script is called by CLAUDE.md Step 3.5 during Completion Protocol
# It checks triggers and outputs advisory info for Claude to decide
# Claude will ask user if deep scan needed (except release mode)

# NOTE: Do NOT use set -e here — check-triggers.sh returns non-zero exit codes
# by design (1=CRITICAL, 2=HIGH, 3=MEDIUM, 4=LOW) to indicate trigger levels.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if trigger detection script exists
if [ ! -f "security/check-triggers.sh" ]; then
  echo -e "${YELLOW}⚠${NC} Trigger detection script not found, skipping auto-invoke"
  exit 0
fi

# Run trigger detection
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Security: Checking Deep Scan Triggers${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TRIGGER_RESULT=$(bash security/check-triggers.sh)
TRIGGER_EXIT=$?

# Parse trigger result
TRIGGER_LEVEL=$(echo "$TRIGGER_RESULT" | grep -o '"trigger_level": *"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
TRIGGER_SCORE=$(echo "$TRIGGER_RESULT" | grep -o '"trigger_score": *[0-9]*' | sed 's/.*: *//')
RECOMMENDATION=$(echo "$TRIGGER_RESULT" | grep -o '"recommendation": *"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')

# Display results
echo "Trigger Level: $TRIGGER_LEVEL"
echo "Risk Score: $TRIGGER_SCORE"
echo ""

# Extract reasons (simplified - just show from JSON)
echo "Detected conditions:"
if echo "$TRIGGER_RESULT" | grep -q '"reasons"'; then
  echo "$TRIGGER_RESULT" | sed -n 's/.*"reasons": *\[\(.*\)\].*/\1/p' | tr ',' '\n' | sed 's/^ *"/  • /' | sed 's/"$//' | sed 's/  •   •/  •/'
fi
echo ""

# ============================================================================
# Check for Release Mode (ONLY auto-invoke case)
# ============================================================================

IS_RELEASE=false
if git describe --tags --exact-match HEAD 2>/dev/null | grep -q "^v[0-9]"; then
  IS_RELEASE=true
fi

# ============================================================================
# Decision Logic (Advisory Mode)
# ============================================================================

case $TRIGGER_LEVEL in
  CRITICAL)
    # CRITICAL triggers detected
    echo -e "${RED}🚨 CRITICAL TRIGGERS DETECTED${NC}"
    echo ""
    echo "Recommendation: $RECOMMENDATION"
    echo ""

    if [ "$IS_RELEASE" = true ]; then
      # RELEASE MODE: Auto-invoke without asking
      echo -e "${YELLOW}⚠${NC}  RELEASE MODE: Automatic deep scan required"
      echo -e "${YELLOW}⚠${NC}  This will take 1-2 minutes for thorough analysis"
      echo ""

      # Export trigger info for agent
      export DEEP_SCAN_TRIGGER_LEVEL="CRITICAL"
      export DEEP_SCAN_TRIGGER_REASONS="$TRIGGER_RESULT"
      export DEEP_SCAN_AUTO_INVOKE="true"

      # Exit code 1 = auto-invoke agent
      exit 1
    else
      # NORMAL MODE: Claude will ask user
      echo -e "${BLUE}ℹ${NC}  Claude AI will ask if you want to run deep scan"
      echo ""

      # Export trigger info for Claude's decision
      export DEEP_SCAN_TRIGGER_LEVEL="CRITICAL"
      export DEEP_SCAN_TRIGGER_REASONS="$TRIGGER_RESULT"
      export DEEP_SCAN_AUTO_INVOKE="false"

      # Exit code 10 = ask user
      exit 10
    fi
    ;;

  HIGH)
    # HIGH triggers: Claude should ask user
    echo -e "${YELLOW}⚠️  HIGH-PRIORITY TRIGGERS DETECTED${NC}"
    echo ""
    echo "Recommendation: $RECOMMENDATION"
    echo ""
    echo -e "${BLUE}ℹ${NC}  Claude AI will recommend deep scan"
    echo ""

    # Export trigger info for Claude's decision
    export DEEP_SCAN_TRIGGER_LEVEL="HIGH"
    export DEEP_SCAN_TRIGGER_REASONS="$TRIGGER_RESULT"
    export DEEP_SCAN_AUTO_INVOKE="false"

    # Exit code 11 = ask user (high priority)
    exit 11
    ;;

  MEDIUM)
    # MEDIUM triggers: Claude may mention it
    echo -e "${BLUE}ℹ️  Medium-priority conditions detected${NC}"
    echo ""
    echo "Recommendation: $RECOMMENDATION"
    echo ""

    # Export trigger info for optional use
    export DEEP_SCAN_TRIGGER_LEVEL="MEDIUM"
    export DEEP_SCAN_TRIGGER_REASONS="$TRIGGER_RESULT"
    export DEEP_SCAN_AUTO_INVOKE="false"

    # Exit code 12 = optional mention
    exit 12
    ;;

  LOW|NONE)
    # LOW/NONE: Informational only, no action
    echo -e "${GREEN}✓${NC} No significant security triggers detected"
    if [ "$TRIGGER_LEVEL" = "LOW" ]; then
      echo -e "${BLUE}ℹ${NC} Low-priority conditions noted (informational only)"
    fi
    echo ""

    # No deep scan needed
    exit 0
    ;;
esac
