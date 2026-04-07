#!/bin/bash
#
# Validate release readiness for Claude Code Starter.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="$(sed -n 's/^VERSION="${FRAMEWORK_VERSION:-\(.*\)}"/\1/p' "$REPO_DIR/init-project.sh" | head -1)"

if [ -z "$VERSION" ]; then
    echo "validate-release: failed to resolve version from init-project.sh"
    exit 1
fi

required_files=(
    "$REPO_DIR/init-project.sh"
    "$REPO_DIR/CLAUDE.md"
    "$REPO_DIR/README.md"
    "$REPO_DIR/CHANGELOG.md"
    "$REPO_DIR/manifest.md"
    "$REPO_DIR/.gitignore"
    "$REPO_DIR/.claude/SNAPSHOT.md"
    "$REPO_DIR/.claude/settings.json"
    "$REPO_DIR/scripts/init-project.sh"
    "$REPO_DIR/scripts/migrate.sh"
    "$REPO_DIR/scripts/switch-repo-access.sh"
    "$REPO_DIR/scripts/framework-state-mode.sh"
    "$REPO_DIR/scripts/build-release.sh"
    "$REPO_DIR/release-notes/v$VERSION.md"
    "$REPO_DIR/release-notes/GITHUB_RELEASE_v$VERSION.md"
)

for path in "${required_files[@]}"; do
    if [ ! -e "$path" ]; then
        echo "validate-release: missing required file: $path"
        exit 1
    fi
done

bash -n \
    "$REPO_DIR/init-project.sh" \
    "$REPO_DIR/scripts/init-project.sh" \
    "$REPO_DIR/scripts/migrate.sh" \
    "$REPO_DIR/scripts/switch-repo-access.sh" \
    "$REPO_DIR/scripts/framework-state-mode.sh" \
    "$REPO_DIR/scripts/build-release.sh"

if ! grep -q "## \\[$VERSION\\]" "$REPO_DIR/CHANGELOG.md"; then
    echo "validate-release: CHANGELOG.md does not contain an entry for version $VERSION"
    exit 1
fi

if ! grep -q "v$VERSION" "$REPO_DIR/release-notes/v$VERSION.md"; then
    echo "validate-release: release notes do not mention version v$VERSION"
    exit 1
fi

echo "validate-release: release inputs look consistent for v$VERSION"
