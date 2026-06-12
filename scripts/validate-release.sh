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
    "$REPO_DIR/RELEASING.md"
    "$REPO_DIR/manifest.md"
    "$REPO_DIR/.gitignore"
    "$REPO_DIR/.claude/SNAPSHOT.md"
    "$REPO_DIR/.claude/ARCHITECTURE.md"
    "$REPO_DIR/.claude/BACKLOG.md"
    "$REPO_DIR/.claude/INVARIANTS.md"
    "$REPO_DIR/.claude/settings.json"
    "$REPO_DIR/.claude/rules/dialog-preservation.md"
    "$REPO_DIR/.claude/skills/save-dialog/SKILL.md"
    "$REPO_DIR/scripts/init-project.sh"
    "$REPO_DIR/scripts/migrate.sh"
    "$REPO_DIR/scripts/switch-repo-access.sh"
    "$REPO_DIR/scripts/framework-state-mode.sh"
    "$REPO_DIR/scripts/build-release.sh"
    "$REPO_DIR/scripts/save-dialogs.sh"
    "$REPO_DIR/scripts/install-global.sh"
    "$REPO_DIR/templates/methodology/_HOW-THIS-GROWS.md"
    "$REPO_DIR/templates/methodology/00-example-llm-as-component.md"
    "$REPO_DIR/templates/global/CLAUDE.addendum.md"
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

# Drift checks — descriptive files must reference current version, otherwise
# users land on outdated content even though the release ships fine.
if ! grep -q "version-v$VERSION" "$REPO_DIR/README.md"; then
    echo "validate-release: README.md badge does not reference v$VERSION (drift)"
    exit 1
fi

if ! grep -q "release-notes/v$VERSION.md" "$REPO_DIR/README.md"; then
    echo "validate-release: README.md does not link to release-notes/v$VERSION.md (drift)"
    exit 1
fi

# Onboarding-file guard — see FRAMEWORK-CASE-ONBOARDING.md.
# The framework must not ship a separate ONBOARDING.md template; the
# constitution lives in CLAUDE.md (which the harness auto-loads). A
# parallel onboarding file inevitably drifts from CLAUDE.md and reads
# like a second source of truth.
if find "$REPO_DIR/templates" -type f -name 'ONBOARDING.md' 2>/dev/null | grep -q .; then
    echo "validate-release: templates/ contains an ONBOARDING.md; constitution must live only in CLAUDE.md (see FRAMEWORK-CASE-ONBOARDING.md)"
    exit 1
fi
if [ -f "$REPO_DIR/.claude/ONBOARDING.md" ]; then
    echo "validate-release: .claude/ONBOARDING.md exists in repo root; constitution must live only in CLAUDE.md"
    exit 1
fi

# Internal script version comments — catch stale "Version: X.Y.Z" headers.
for script in \
    "$REPO_DIR/init-project.sh" \
    "$REPO_DIR/scripts/init-project.sh" \
    "$REPO_DIR/scripts/migrate.sh" \
    "$REPO_DIR/scripts/install-global.sh" \
    "$REPO_DIR/scripts/lib/install_common.sh"; do
    if [ -f "$script" ] && ! grep -q "# Version: $VERSION" "$script"; then
        echo "validate-release: $script does not advertise Version: $VERSION (drift)"
        exit 1
    fi
done

echo "validate-release: release inputs look consistent for v$VERSION"
