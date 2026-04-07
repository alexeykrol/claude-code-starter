#!/bin/bash
#
# Submit Bug Report to GitHub Issues
#
# Submits anonymized bug report to framework repository
# Uses gh CLI to create GitHub Issue with bug-report label
#

set -e

# Check arguments
if [ -z "$1" ]; then
  echo "Usage: $0 <anonymized-report-file>"
  exit 1
fi

REPORT_FILE="$1"

if [ ! -f "$REPORT_FILE" ]; then
  echo "Error: Report file not found: $REPORT_FILE"
  exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo "⚠️  GitHub CLI (gh) not installed"
  echo ""
  echo "To submit bug reports automatically, install gh CLI:"
  echo "  macOS: brew install gh"
  echo "  Linux: sudo apt install gh (Debian/Ubuntu)"
  echo ""
  echo "Your report is saved locally at: $REPORT_FILE"
  echo "You can submit it manually at:"
  echo "  https://github.com/alexeykrol/claude-code-starter/issues/new"
  exit 1
fi

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
  echo "⚠️  GitHub CLI not authenticated"
  echo ""
  echo "Please authenticate with: gh auth login"
  echo ""
  echo "Your report is saved locally at: $REPORT_FILE"
  exit 1
fi

# Extract title and body from report
# Title: First markdown header (# Bug Report Title)
TITLE=$(grep "^# " "$REPORT_FILE" | head -1 | sed 's/^# //')

if [ -z "$TITLE" ]; then
  TITLE="Bug Report from Host Project"
fi

# Body: entire file content
BODY=$(cat "$REPORT_FILE")

# Submit to GitHub Issues
echo ""
echo "📤 Submitting bug report to GitHub..."
echo ""

# Ensure "bug-report" label exists (auto-create if missing)
if ! gh label list --repo "alexeykrol/claude-code-starter" 2>/dev/null | grep -q "^bug-report"; then
  echo "Creating 'bug-report' label..."
  gh label create "bug-report" \
    --repo "alexeykrol/claude-code-starter" \
    --description "Automated bug report from host project (telemetry & analytics)" \
    --color "d73a4a" 2>/dev/null || true
fi

ISSUE_URL=$(gh issue create \
  --repo "alexeykrol/claude-code-starter" \
  --title "$TITLE" \
  --body "$BODY" \
  --label "bug-report" 2>&1)

if [ $? -eq 0 ]; then
  echo "✅ Bug report submitted successfully!"
  echo ""
  echo "Issue URL: $ISSUE_URL"
  echo ""
  echo "Thank you for helping improve the framework!"
  echo ""

  # Save issue URL to report metadata
  echo "" >> "$REPORT_FILE"
  echo "---" >> "$REPORT_FILE"
  echo "**Submitted:** $(date -Iseconds)" >> "$REPORT_FILE"
  echo "**Issue:** $ISSUE_URL" >> "$REPORT_FILE"

  # Return issue URL
  echo "$ISSUE_URL"
else
  echo "⚠️  Failed to submit bug report"
  echo ""
  echo "Your report is saved locally at: $REPORT_FILE"
  echo "You can submit it manually at:"
  echo "  https://github.com/alexeykrol/claude-code-starter/issues/new"
  exit 1
fi
