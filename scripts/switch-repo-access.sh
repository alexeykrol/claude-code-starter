#!/bin/bash
#
# Switch repo_access safely between private-solo and shared/public modes.
#
# This script updates:
# - manifest.md
# - .gitignore framework block
# - git index for tracked framework files
#
# It does not rewrite history. If framework files are already present on an
# upstream branch, it stops and tells the user to perform a history rewrite
# or create a fresh shared/public branch.
#

set -euo pipefail

TARGET_MODE="${1:-}"
COMMIT_CHANGES=false

if [ "${2:-}" = "--commit" ] || [ "${1:-}" = "--commit" ]; then
    COMMIT_CHANGES=true
fi

case "$TARGET_MODE" in
    public|private-shared|private-solo) ;;
    *)
        echo "Usage: scripts/switch-repo-access.sh <public|private-shared|private-solo> [--commit]"
        exit 1
        ;;
esac

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$PROJECT_DIR/manifest.md"
GITIGNORE="$PROJECT_DIR/.gitignore"
HELPER="$PROJECT_DIR/scripts/framework-state-mode.sh"

if [ ! -f "$MANIFEST" ]; then
    echo "switch-repo-access: manifest.md not found"
    exit 1
fi

if [ ! -f "$GITIGNORE" ]; then
    echo "switch-repo-access: .gitignore not found"
    exit 1
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Fresh installs are naturally untracked before the first commit.
    # Block only on tracked/staged changes, not on untracked files.
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "switch-repo-access: tracked/staged changes must be clean before switching modes"
        exit 1
    fi
fi

awk -F= -v mode="$TARGET_MODE" '
    BEGIN { done=0 }
    /^repo_access=/ { print "repo_access=" mode; done=1; next }
    { print }
    END { if (!done) print "repo_access=" mode }
' "$MANIFEST" > "$MANIFEST.tmp"
mv "$MANIFEST.tmp" "$MANIFEST"

awk -v enable="$TARGET_MODE" '
    BEGIN {
        inside=0
        uncomment=(enable=="public" || enable=="private-shared")
    }
    /^# >>> framework-public-ignore$/ { inside=1; print; next }
    /^# <<< framework-public-ignore$/ { inside=0; print; next }
    {
        if (inside && $0 ~ /^# / && $0 !~ /^# Uncomment these lines/) {
            if (uncomment) {
                sub(/^# /, "")
            }
        } else if (inside && $0 !~ /^# / && $0 !~ /^$/) {
            if (!uncomment) {
                $0 = "# " $0
            }
        }
        print
    }
' "$GITIGNORE" > "$GITIGNORE.tmp"
mv "$GITIGNORE.tmp" "$GITIGNORE"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [ "$TARGET_MODE" = "public" ] || [ "$TARGET_MODE" = "private-shared" ]; then
        if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
            if git log --oneline '@{u}' -- .claude CLAUDE.md manifest.md AGENTS.md 2>/dev/null | grep -q .; then
                echo "switch-repo-access: upstream history already contains framework files."
                echo "Stop. Use history rewrite or start a fresh shared/public branch."
                exit 2
            fi
        fi

        git rm -r --cached --ignore-unmatch .claude CLAUDE.md manifest.md AGENTS.md >/dev/null 2>&1 || true
    fi

    if [ "$TARGET_MODE" = "public" ] || [ "$TARGET_MODE" = "private-shared" ]; then
        git add -- "$GITIGNORE" 2>/dev/null || true
    else
        git add -- "$MANIFEST" "$GITIGNORE"
    fi

    if [ "$COMMIT_CHANGES" = true ] && ! git diff --cached --quiet; then
        git commit -m "chore(repo-access): switch to $TARGET_MODE mode"
    fi
fi

echo "switch-repo-access: repo_access set to $TARGET_MODE"
echo "switch-repo-access: framework-state mode now = $("$HELPER" should-commit-framework-state 2>/dev/null || echo unknown)"

if [ "$TARGET_MODE" = "public" ] || [ "$TARGET_MODE" = "private-shared" ]; then
    echo "switch-repo-access: framework files were untracked from the index when possible."
    echo "switch-repo-access: use a clean branch or rewrite history if those files were already pushed."
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && ! git diff --cached --quiet; then
    echo "switch-repo-access: staged transition detected."
    echo "switch-repo-access: commit it now or rerun with --commit for an explicit mode-switch commit."
fi
