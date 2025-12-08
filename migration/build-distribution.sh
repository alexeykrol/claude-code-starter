#!/bin/bash
#
# Claude Code Starter Framework — Distribution Builder
# Version: 2.0.5
#
# This script creates the distribution package that users will download.
#

set -e  # Exit on error

VERSION="2.0.5"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$PROJECT_ROOT/dist-package"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Building Claude Code Starter Framework Distribution"
echo "  Version: $VERSION"
echo "════════════════════════════════════════════════════════════"
echo ""

# Clean previous build
if [ -d "$DIST_DIR" ]; then
    echo -e "${BLUE}ℹ${NC} Cleaning previous build..."
    rm -rf "$DIST_DIR"
fi

# Create distribution directory
mkdir -p "$DIST_DIR/framework-bundle"
echo -e "${GREEN}✓${NC} Created distribution directory"

# ============================================================================
# Copy Framework Files
# ============================================================================

echo -e "${BLUE}ℹ${NC} Copying framework files..."

# 1. CLAUDE.md (framework instructions)
cp "$PROJECT_ROOT/CLAUDE.md" "$DIST_DIR/framework-bundle/"
echo -e "${GREEN}✓${NC} Copied CLAUDE.md"

# 2. FRAMEWORK_GUIDE (usage guide for users)
cp "$SCRIPT_DIR/FRAMEWORK_GUIDE.template.md" "$DIST_DIR/framework-bundle/FRAMEWORK_GUIDE.md"
echo -e "${GREEN}✓${NC} Copied FRAMEWORK_GUIDE.md"

# 3. .claude/commands/ (slash commands)
mkdir -p "$DIST_DIR/framework-bundle/.claude/commands"
cp -r "$PROJECT_ROOT/.claude/commands/"* "$DIST_DIR/framework-bundle/.claude/commands/"
echo -e "${GREEN}✓${NC} Copied slash commands"

# 4. .claude/dist/ (compiled framework code)
mkdir -p "$DIST_DIR/framework-bundle/.claude/dist"
cp -r "$PROJECT_ROOT/dist/claude-export" "$DIST_DIR/framework-bundle/.claude/dist/"
echo -e "${GREEN}✓${NC} Copied compiled framework code"

# 5. .claude/templates/ (meta file templates)
mkdir -p "$DIST_DIR/framework-bundle/.claude/templates"
cp "$SCRIPT_DIR/templates/"*.md "$DIST_DIR/framework-bundle/.claude/templates/"
echo -e "${GREEN}✓${NC} Copied meta file templates"

# 6. package.json scripts (for dialog management)
cat > "$DIST_DIR/framework-bundle/package.json.snippet" <<'EOF'
{
  "scripts": {
    "dialog:export": "node .claude/dist/claude-export/cli.js export",
    "dialog:ui": "node .claude/dist/claude-export/cli.js ui",
    "dialog:watch": "node .claude/dist/claude-export/cli.js watch",
    "dialog:list": "node .claude/dist/claude-export/cli.js list"
  }
}
EOF
echo -e "${GREEN}✓${NC} Created package.json snippet"

# 7. .gitignore template
cat > "$DIST_DIR/framework-bundle/.gitignore.snippet" <<'EOF'
# Claude Code Starter Framework
dialog/
html-viewer/
.claude/.last_session
.claude/.backup-*
EOF
echo -e "${GREEN}✓${NC} Created .gitignore snippet"

# ============================================================================
# Create framework-bundle.tar.gz
# ============================================================================

echo -e "${BLUE}ℹ${NC} Creating framework bundle archive..."
cd "$DIST_DIR"
tar -czf framework-bundle.tar.gz framework-bundle/
rm -rf framework-bundle/
echo -e "${GREEN}✓${NC} Created framework-bundle.tar.gz"

# ============================================================================
# Copy Installation Files
# ============================================================================

echo -e "${BLUE}ℹ${NC} Copying installation files..."

# Copy init-project.sh
cp "$SCRIPT_DIR/init-project.sh" "$DIST_DIR/"
chmod +x "$DIST_DIR/init-project.sh"
echo -e "${GREEN}✓${NC} Copied init-project.sh"

# Copy MIGRATION_GUIDE.md
cp "$SCRIPT_DIR/MIGRATION_GUIDE.md" "$DIST_DIR/"
echo -e "${GREEN}✓${NC} Copied MIGRATION_GUIDE.md"

# ============================================================================
# Create Final Distribution Package
# ============================================================================

echo -e "${BLUE}ℹ${NC} Creating final distribution package..."
cd "$DIST_DIR"
tar -czf "$PROJECT_ROOT/claude-code-starter-v${VERSION}.tar.gz" \
    init-project.sh \
    MIGRATION_GUIDE.md \
    framework-bundle.tar.gz

echo -e "${GREEN}✓${NC} Created distribution package"

# ============================================================================
# Create Checksum
# ============================================================================

echo -e "${BLUE}ℹ${NC} Generating checksum..."
cd "$PROJECT_ROOT"
shasum -a 256 "claude-code-starter-v${VERSION}.tar.gz" > "claude-code-starter-v${VERSION}.tar.gz.sha256"
echo -e "${GREEN}✓${NC} Created checksum file"

# ============================================================================
# Cleanup
# ============================================================================

echo -e "${BLUE}ℹ${NC} Cleaning up..."
rm -rf "$DIST_DIR"
echo -e "${GREEN}✓${NC} Cleanup complete"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓${NC} Distribution built successfully!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Files created:"
echo "  - claude-code-starter-v${VERSION}.tar.gz"
echo "  - claude-code-starter-v${VERSION}.tar.gz.sha256"
echo ""
echo "Size: $(du -h claude-code-starter-v${VERSION}.tar.gz | cut -f1)"
echo ""
echo "To test installation:"
echo "  mkdir test-project && cd test-project"
echo "  git init"
echo "  tar -xzf ../claude-code-starter-v${VERSION}.tar.gz"
echo "  ./init-project.sh"
echo ""
echo "To publish:"
echo "  1. Create GitHub release: v${VERSION}"
echo "  2. Upload claude-code-starter-v${VERSION}.tar.gz"
echo "  3. Upload claude-code-starter-v${VERSION}.tar.gz.sha256"
echo "  4. Update download URLs in documentation"
echo ""
