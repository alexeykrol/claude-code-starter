#!/bin/bash
#
# Claude Code Starter Framework — Distribution Builder
# Version: 2.1.0
#
# This script creates a self-extracting init-project.sh installer
# that users can download and run directly.
#

set -e  # Exit on error

VERSION="2.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$PROJECT_ROOT/dist-release"
TEMP_DIR="/tmp/claude-framework-build-$$"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Building Claude Code Starter Framework Distribution"
echo "  Version: $VERSION"
echo "════════════════════════════════════════════════════════════"
echo ""

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Clean previous build
if [ -d "$DIST_DIR" ]; then
    echo -e "${BLUE}ℹ${NC} Cleaning previous build..."
    rm -rf "$DIST_DIR"
fi

# Create directories
mkdir -p "$DIST_DIR"
mkdir -p "$TEMP_DIR/framework"
echo -e "${GREEN}✓${NC} Created build directories"

# ============================================================================
# Copy Framework Files to Temp
# ============================================================================

echo -e "${BLUE}ℹ${NC} Collecting framework files..."

# 1. CLAUDE.md (framework instructions)
cp "$PROJECT_ROOT/CLAUDE.md" "$TEMP_DIR/framework/"
echo -e "${GREEN}✓${NC} Copied CLAUDE.md"

# 2. FRAMEWORK_GUIDE (usage guide for users)
cp "$SCRIPT_DIR/FRAMEWORK_GUIDE.template.md" "$TEMP_DIR/framework/FRAMEWORK_GUIDE.md"
echo -e "${GREEN}✓${NC} Copied FRAMEWORK_GUIDE.md"

# 3. .claude/commands/ (slash commands)
mkdir -p "$TEMP_DIR/framework/.claude/commands"
cp -r "$PROJECT_ROOT/.claude/commands/"* "$TEMP_DIR/framework/.claude/commands/"
echo -e "${GREEN}✓${NC} Copied slash commands"

# 4. .claude/dist/ (compiled framework code)
mkdir -p "$TEMP_DIR/framework/.claude/dist"
cp -r "$PROJECT_ROOT/dist/claude-export" "$TEMP_DIR/framework/.claude/dist/"
echo -e "${GREEN}✓${NC} Copied compiled framework code"

# 5. .claude/templates/ (meta file templates)
mkdir -p "$TEMP_DIR/framework/.claude/templates"
cp "$SCRIPT_DIR/templates/"*.md "$TEMP_DIR/framework/.claude/templates/"
echo -e "${GREEN}✓${NC} Copied meta file templates"

# ============================================================================
# Create Framework Archive
# ============================================================================

echo -e "${BLUE}ℹ${NC} Creating framework archive..."
cd "$TEMP_DIR"
tar -czf framework.tar.gz framework/
echo -e "${GREEN}✓${NC} Created framework.tar.gz"

# ============================================================================
# Build Self-Extracting Installer
# ============================================================================

echo -e "${BLUE}ℹ${NC} Building self-extracting installer..."

# Copy installer template
cp "$SCRIPT_DIR/init-project.sh" "$DIST_DIR/init-project.sh"

# Append base64-encoded archive
echo "" >> "$DIST_DIR/init-project.sh"
base64 -i framework.tar.gz >> "$DIST_DIR/init-project.sh"

# Make executable
chmod +x "$DIST_DIR/init-project.sh"

echo -e "${GREEN}✓${NC} Created self-extracting init-project.sh"

# ============================================================================
# Create Distribution Summary
# ============================================================================

INSTALLER_SIZE=$(du -h "$DIST_DIR/init-project.sh" | awk '{print $1}')

cat > "$DIST_DIR/README.txt" <<EOF
Claude Code Starter Framework v${VERSION}
Distribution Package

Files:
  - init-project.sh (${INSTALLER_SIZE}) - Self-extracting installer

Usage:
  1. Copy init-project.sh to your project directory
  2. Make executable: chmod +x init-project.sh
  3. Run: ./init-project.sh

Or use curl:
  curl -O https://github.com/alexeykrol/claude-code-starter/releases/download/v${VERSION}/init-project.sh
  chmod +x init-project.sh
  ./init-project.sh

This installer is self-contained and includes all framework files.
No additional downloads required.

---
Generated: $(date)
EOF

echo -e "${GREEN}✓${NC} Created README.txt"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Build Complete!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Distribution location:"
echo "  $DIST_DIR/"
echo ""
echo "Files created:"
echo "  - init-project.sh (${INSTALLER_SIZE}) - Self-extracting installer"
echo "  - README.txt - Usage instructions"
echo ""
echo "Next steps:"
echo "  1. Test the installer on a clean project"
echo "  2. Upload init-project.sh to GitHub Releases"
echo "  3. Update MIGRATION_GUIDE.md with download URL"
echo ""
echo "Test command:"
echo "  cp $DIST_DIR/init-project.sh /path/to/test-project/"
echo "  cd /path/to/test-project && ./init-project.sh"
echo ""
