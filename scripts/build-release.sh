#!/bin/bash
#
# Build GitHub Release assets for Claude Code Starter.
#
# Outputs:
# - dist-release/<version>/init-project.sh
# - dist-release/<version>/framework.tar.gz
# - dist-release/<version>/checksums.txt
# - dist-release/<version>/RELEASE_NOTES.md
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    VERSION="$(sed -n 's/^VERSION="${FRAMEWORK_VERSION:-\(.*\)}"/\1/p' "$REPO_DIR/init-project.sh" | head -1)"
fi

if [ -z "$VERSION" ]; then
    echo "build-release: could not resolve version from init-project.sh"
    exit 1
fi

OUT_DIR="$REPO_DIR/dist-release/$VERSION"
STAGE_DIR="$OUT_DIR/stage/claude-code-starter"
NOTES_FILE="$REPO_DIR/release-notes/v$VERSION.md"

rm -rf "$OUT_DIR"
mkdir -p "$STAGE_DIR/.claude" "$STAGE_DIR/scripts"

copy_required() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

copy_required "$REPO_DIR/init-project.sh" "$OUT_DIR/init-project.sh"
copy_required "$REPO_DIR/CLAUDE.md" "$STAGE_DIR/CLAUDE.md"
copy_required "$REPO_DIR/manifest.md" "$STAGE_DIR/manifest.md"
copy_required "$REPO_DIR/.gitignore" "$STAGE_DIR/.gitignore"
copy_required "$REPO_DIR/README.md" "$STAGE_DIR/README.md"
copy_required "$REPO_DIR/CHANGELOG.md" "$STAGE_DIR/CHANGELOG.md"
copy_required "$REPO_DIR/.claude/SNAPSHOT.md" "$STAGE_DIR/.claude/SNAPSHOT.md"
copy_required "$REPO_DIR/.claude/settings.json" "$STAGE_DIR/.claude/settings.json"

for dir in rules skills agents hooks; do
    cp -R "$REPO_DIR/.claude/$dir" "$STAGE_DIR/.claude/"
done

for script in init-project.sh migrate.sh switch-repo-access.sh framework-state-mode.sh; do
    copy_required "$REPO_DIR/scripts/$script" "$STAGE_DIR/scripts/$script"
done

if [ -f "$NOTES_FILE" ]; then
    cp "$NOTES_FILE" "$OUT_DIR/RELEASE_NOTES.md"
else
    cat > "$OUT_DIR/RELEASE_NOTES.md" <<EOF
# Claude Code Starter v$VERSION

Release notes file not found at:
$NOTES_FILE
EOF
fi

chmod +x "$OUT_DIR/init-project.sh" "$STAGE_DIR/scripts/"*.sh "$STAGE_DIR/.claude/hooks/"*.sh

tar -czf "$OUT_DIR/framework.tar.gz" -C "$OUT_DIR/stage" claude-code-starter

(
    cd "$OUT_DIR"
    shasum -a 256 init-project.sh framework.tar.gz RELEASE_NOTES.md > checksums.txt
)

rm -rf "$OUT_DIR/stage"

echo "build-release: created assets in $OUT_DIR"
ls -1 "$OUT_DIR"
