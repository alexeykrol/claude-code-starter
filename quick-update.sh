#!/bin/bash
#
# Claude Code Starter Framework — Quick Updater
#
# Drop this file into any project and run to update the framework.
# Usage: bash quick-update.sh
#

set -e

REPO="alexeykrol/claude-code-starter"
TEMP_DIR="/tmp/claude-quick-update-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Cleanup on exit
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  Claude Code Starter — Quick Update${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. Detect Current Version
# ============================================

CURRENT_VERSION=""

# Try .claude/SNAPSHOT.md first
if [ -f ".claude/SNAPSHOT.md" ]; then
    CURRENT_VERSION=$(grep "^\*\*Version:\*\*" .claude/SNAPSHOT.md 2>/dev/null | awk '{print $2}' | tr -d '\n')
fi

# Fallback to CLAUDE.md footer
if [ -z "$CURRENT_VERSION" ] && [ -f "CLAUDE.md" ]; then
    CURRENT_VERSION=$(grep "Framework: Claude Code Starter" CLAUDE.md 2>/dev/null | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/' | tr -d '\n')
fi

# Check if framework is installed
if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${YELLOW}⚠${NC} Framework not found in this project"
    echo ""
    echo "To install the framework, run:"
    echo "  curl -O https://github.com/${REPO}/releases/latest/download/init-project.sh"
    echo "  chmod +x init-project.sh"
    echo "  ./init-project.sh"
    echo ""
    exit 1
fi

echo -e "${BLUE}ℹ${NC} Current version: ${BOLD}${CURRENT_VERSION}${NC}"

# ============================================
# 2. Fetch Latest Version from GitHub
# ============================================

echo -e "${BLUE}ℹ${NC} Checking for updates..."

if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗${NC} curl not found. Please install curl."
    exit 1
fi

# Fetch latest release info from GitHub API
LATEST_JSON=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest")

if [ $? -ne 0 ]; then
    echo -e "${RED}✗${NC} Failed to fetch latest version from GitHub"
    exit 1
fi

# Extract version from tag_name
LATEST_VERSION=$(echo "$LATEST_JSON" | grep '"tag_name"' | sed 's/.*"v\([0-9.]*\)".*/\1/' | tr -d '\n')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}✗${NC} Failed to parse latest version"
    exit 1
fi

echo -e "${BLUE}ℹ${NC} Latest version:  ${BOLD}${LATEST_VERSION}${NC}"
echo ""

# ============================================
# 3. Compare Versions
# ============================================

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "${GREEN}✓${NC} Framework is already up to date!"
    echo ""
    exit 0
fi

echo -e "${YELLOW}⚠${NC} Update available: ${BOLD}v${CURRENT_VERSION}${NC} → ${BOLD}v${LATEST_VERSION}${NC}"
echo ""

# ============================================
# 4. Download Framework Commands Archive
# ============================================

echo -e "${BLUE}ℹ${NC} Downloading framework update..."

mkdir -p "$TEMP_DIR"

# Download framework-commands.tar.gz (lightweight, only commands)
COMMANDS_URL="https://github.com/${REPO}/releases/download/v${LATEST_VERSION}/framework-commands.tar.gz"

if ! curl -L -f "$COMMANDS_URL" -o "$TEMP_DIR/framework-commands.tar.gz" 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} Commands archive not found, downloading full framework..."

    # Fallback to full framework.tar.gz
    FRAMEWORK_URL="https://github.com/${REPO}/releases/download/v${LATEST_VERSION}/framework.tar.gz"

    if ! curl -L -f "$FRAMEWORK_URL" -o "$TEMP_DIR/framework.tar.gz" 2>/dev/null; then
        echo -e "${RED}✗${NC} Failed to download framework"
        exit 1
    fi

    # Extract full framework
    tar -xzf "$TEMP_DIR/framework.tar.gz" -C "$TEMP_DIR"
    FRAMEWORK_DIR="$TEMP_DIR/framework"
else
    # Extract commands archive
    tar -xzf "$TEMP_DIR/framework-commands.tar.gz" -C "$TEMP_DIR"
    FRAMEWORK_DIR="$TEMP_DIR/framework-commands"
fi

echo -e "${GREEN}✓${NC} Downloaded v${LATEST_VERSION}"

# ============================================
# 5. Download Latest CLAUDE.md
# ============================================

echo -e "${BLUE}ℹ${NC} Downloading latest CLAUDE.md..."

CLAUDE_MD_URL="https://github.com/${REPO}/releases/download/v${LATEST_VERSION}/CLAUDE.md"

if ! curl -L -f "$CLAUDE_MD_URL" -o "$TEMP_DIR/CLAUDE.md" 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} CLAUDE.md not found in release, skipping"
else
    echo -e "${GREEN}✓${NC} Downloaded CLAUDE.md"
fi

# ============================================
# 6. Backup Current Files
# ============================================

echo -e "${BLUE}ℹ${NC} Creating backup..."

BACKUP_DIR=".claude/backups/v${CURRENT_VERSION}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup framework commands
if [ -d ".claude/commands" ]; then
    cp -r ".claude/commands" "$BACKUP_DIR/"
fi

# Backup CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    cp "CLAUDE.md" "$BACKUP_DIR/"
fi

echo -e "${GREEN}✓${NC} Backup saved to: $BACKUP_DIR"

# ============================================
# 7. Apply Update
# ============================================

echo -e "${BLUE}ℹ${NC} Applying update..."

# Update commands
if [ -d "$FRAMEWORK_DIR" ]; then
    mkdir -p ".claude/commands"

    # Copy framework commands (fi.md, ui.md, watch.md, etc.)
    for cmd in "$FRAMEWORK_DIR"/*.md; do
        if [ -f "$cmd" ]; then
            filename=$(basename "$cmd")
            cp "$cmd" ".claude/commands/"
            echo -e "${GREEN}  ✓${NC} Updated: .claude/commands/${filename}"
        fi
    done
fi

# Update CLAUDE.md
if [ -f "$TEMP_DIR/CLAUDE.md" ]; then
    cp "$TEMP_DIR/CLAUDE.md" "CLAUDE.md"
    echo -e "${GREEN}  ✓${NC} Updated: CLAUDE.md"
fi

# Update version in .claude/SNAPSHOT.md
if [ -f ".claude/SNAPSHOT.md" ]; then
    if command -v sed &> /dev/null; then
        # macOS compatible sed
        sed -i '' "s/^\*\*Version:\*\* .*/\*\*Version:\*\* ${LATEST_VERSION}/" ".claude/SNAPSHOT.md" 2>/dev/null || \
        sed -i "s/^\*\*Version:\*\* .*/\*\*Version:\*\* ${LATEST_VERSION}/" ".claude/SNAPSHOT.md"
        echo -e "${GREEN}  ✓${NC} Updated: .claude/SNAPSHOT.md"
    fi
fi

echo ""
echo -e "${GREEN}✓${NC} Update complete!"
echo ""

# ============================================
# 8. Summary
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}  Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Previous version: v${CURRENT_VERSION}"
echo "  Current version:  v${LATEST_VERSION}"
echo ""
echo "  Backup location:  $BACKUP_DIR"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🚀 Framework updated successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review changes in CLAUDE.md"
echo "  2. Run 'claude' and type 'start' to use updated framework"
echo ""
