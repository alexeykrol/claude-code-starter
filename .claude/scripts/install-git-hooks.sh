#!/bin/bash
#
# Claude Code Starter Framework — Install Git Hooks
#
# Installs pre-commit hook for COMMIT_POLICY protection
# Called during Cold Start Protocol

# Check if we're in a git repository
if [ ! -d ".git" ]; then
  # Not a git repo, skip
  exit 0
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install pre-commit hook
HOOK_SOURCE=".claude/scripts/pre-commit-hook.sh"
HOOK_TARGET=".git/hooks/pre-commit"

if [ -f "$HOOK_SOURCE" ]; then
  # Make source executable
  chmod +x "$HOOK_SOURCE"

  # Create symlink (or copy if symlink fails)
  if ln -sf "../../$HOOK_SOURCE" "$HOOK_TARGET" 2>/dev/null; then
    # Symlink created successfully
    chmod +x "$HOOK_TARGET"
  else
    # Symlink failed, copy instead
    cp "$HOOK_SOURCE" "$HOOK_TARGET"
    chmod +x "$HOOK_TARGET"
  fi

  # Silent success (no output unless debugging)
  # echo "✓ Git pre-commit hook installed"
fi

exit 0
