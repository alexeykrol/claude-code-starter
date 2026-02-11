#!/bin/bash
#
# Claude Code Starter Framework — Distribution Builder
# Version: 4.0.2
#
# This script creates a self-extracting init-project.sh installer
# that users can download and run directly.
#

set -e  # Exit on error

VERSION="4.0.2"
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

# 1. Claude entry files (migration + production)
cp "$SCRIPT_DIR/CLAUDE.migration.md" "$TEMP_DIR/framework/CLAUDE.migration.md"
cp "$SCRIPT_DIR/CLAUDE.production.md" "$TEMP_DIR/framework/CLAUDE.production.md"
echo -e "${GREEN}✓${NC} Copied CLAUDE.md versions (migration + production)"

# 2. Codex entry file
cp "$PROJECT_ROOT/AGENTS.md" "$TEMP_DIR/framework/AGENTS.md"
echo -e "${GREEN}✓${NC} Copied AGENTS.md"

# 3. FRAMEWORK_GUIDE (usage guide for users)
cp "$SCRIPT_DIR/FRAMEWORK_GUIDE.template.md" "$TEMP_DIR/framework/FRAMEWORK_GUIDE.md"
echo -e "${GREEN}✓${NC} Copied FRAMEWORK_GUIDE.md"

# 4. .claude/commands/ (slash commands, excluding dev-only commands)
mkdir -p "$TEMP_DIR/framework/.claude/commands"
for cmd in "$PROJECT_ROOT/.claude/commands/"*.md; do
    filename=$(basename "$cmd")
    # Skip dev-only commands not meant for user projects
    if [ "$filename" = "release.md" ]; then
        continue
    fi
    cp "$cmd" "$TEMP_DIR/framework/.claude/commands/"
done
echo -e "${GREEN}✓${NC} Copied slash commands"

# 5. .claude/dist/ (compiled framework code)
mkdir -p "$TEMP_DIR/framework/.claude/dist"
cp -r "$PROJECT_ROOT/dist/claude-export" "$TEMP_DIR/framework/.claude/dist/"
echo -e "${GREEN}✓${NC} Copied compiled framework code"

# 6. .claude/templates/ (meta file templates + framework config)
mkdir -p "$TEMP_DIR/framework/.claude/templates"
cp "$SCRIPT_DIR/templates/"*.md "$TEMP_DIR/framework/.claude/templates/"
cp "$SCRIPT_DIR/templates/.framework-config.template.json" "$TEMP_DIR/framework/.claude/templates/"
echo -e "${GREEN}✓${NC} Copied meta file templates and config template"

# 7. .claude/scripts/ (bug reporting + git hooks scripts)
mkdir -p "$TEMP_DIR/framework/.claude/scripts"
cp "$PROJECT_ROOT/.claude/scripts/anonymize-report.sh" "$TEMP_DIR/framework/.claude/scripts/"
cp "$PROJECT_ROOT/.claude/scripts/submit-bug-report.sh" "$TEMP_DIR/framework/.claude/scripts/"
cp "$PROJECT_ROOT/.claude/scripts/analyze-bug-patterns.sh" "$TEMP_DIR/framework/.claude/scripts/"
cp "$PROJECT_ROOT/.claude/scripts/pre-commit-hook.sh" "$TEMP_DIR/framework/.claude/scripts/"
cp "$PROJECT_ROOT/.claude/scripts/install-git-hooks.sh" "$TEMP_DIR/framework/.claude/scripts/"
cp "$PROJECT_ROOT/.claude/scripts/quick-update.sh" "$TEMP_DIR/framework/.claude/scripts/"
chmod +x "$TEMP_DIR/framework/.claude/scripts/anonymize-report.sh"
chmod +x "$TEMP_DIR/framework/.claude/scripts/submit-bug-report.sh"
chmod +x "$TEMP_DIR/framework/.claude/scripts/analyze-bug-patterns.sh"
chmod +x "$TEMP_DIR/framework/.claude/scripts/pre-commit-hook.sh"
chmod +x "$TEMP_DIR/framework/.claude/scripts/install-git-hooks.sh"
chmod +x "$TEMP_DIR/framework/.claude/scripts/quick-update.sh"
echo -e "${GREEN}✓${NC} Copied scripts (bug reporting + hooks + updater)"

# 7.5. .claude/protocols/ (protocol files)
mkdir -p "$TEMP_DIR/framework/.claude/protocols"
cp "$PROJECT_ROOT/.claude/protocols/cold-start-silent.md" "$TEMP_DIR/framework/.claude/protocols/"
cp "$PROJECT_ROOT/.claude/protocols/completion-silent.md" "$TEMP_DIR/framework/.claude/protocols/"
cp "$PROJECT_ROOT/.claude/protocols/auto-triggers.md" "$TEMP_DIR/framework/.claude/protocols/"
echo -e "${GREEN}✓${NC} Copied protocol files (cold-start-silent + completion-silent + auto-triggers)"

# 8. src/framework-core/ (Python utility)
mkdir -p "$TEMP_DIR/framework/src/framework-core"
cp -r "$PROJECT_ROOT/src/framework-core/"* "$TEMP_DIR/framework/src/framework-core/"
# Remove __pycache__ directories
find "$TEMP_DIR/framework/src/framework-core" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
# Make main.py executable
chmod +x "$TEMP_DIR/framework/src/framework-core/main.py"
echo -e "${GREEN}✓${NC} Copied Python framework core utility"

# 9. .codex/ adapter files
if [ -d "$PROJECT_ROOT/.codex" ]; then
    cp -r "$PROJECT_ROOT/.codex" "$TEMP_DIR/framework/"

    # Exclude internal development artifacts from user distribution
    rm -rf "$TEMP_DIR/framework/.codex/parity"
    rm -rf "$TEMP_DIR/framework/.codex/manifests"
    rm -rf "$TEMP_DIR/framework/.codex/reports"
    find "$TEMP_DIR/framework/.codex" -name ".DS_Store" -delete 2>/dev/null || true

    chmod +x "$TEMP_DIR/framework/.codex/commands/"*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Copied Codex adapter files"
else
    echo -e "${YELLOW}⚠${NC} .codex directory not found, skipping Codex adapter packaging"
fi

# 10. security/ scripts (credential scanning and trigger checks)
mkdir -p "$TEMP_DIR/framework/security"
for script in auto-invoke-agent.sh check-triggers.sh cleanup-dialogs.sh initial-scan.sh; do
    if [ -f "$PROJECT_ROOT/security/$script" ]; then
        cp "$PROJECT_ROOT/security/$script" "$TEMP_DIR/framework/security/"
        chmod +x "$TEMP_DIR/framework/security/$script"
    fi
done
if [ -f "$PROJECT_ROOT/security/README.md" ]; then
    cp "$PROJECT_ROOT/security/README.md" "$TEMP_DIR/framework/security/"
fi
echo -e "${GREEN}✓${NC} Copied security scripts"

# ============================================================================
# Create Framework Archive
# ============================================================================

echo -e "${BLUE}ℹ${NC} Creating framework archive..."
cd "$TEMP_DIR"
tar -czf framework.tar.gz framework/
echo -e "${GREEN}✓${NC} Created framework.tar.gz"

# ============================================================================
# Copy Installer and Archive (separate files)
# ============================================================================

echo -e "${BLUE}ℹ${NC} Preparing distribution files..."

# Copy installer script from project root (single source of truth)
cp "$PROJECT_ROOT/init-project.sh" "$DIST_DIR/init-project.sh"
chmod +x "$DIST_DIR/init-project.sh"
echo -e "${GREEN}✓${NC} Copied init-project.sh loader"

# Copy framework archive (separate file)
cp framework.tar.gz "$DIST_DIR/framework.tar.gz"
echo -e "${GREEN}✓${NC} Copied framework.tar.gz"

# ============================================================================
# Create Framework Commands Archive (for auto-update)
# ============================================================================

echo -e "${BLUE}ℹ${NC} Creating framework-commands archive (for auto-update)..."

# Create temp directory for update archive
mkdir -p "$TEMP_DIR/framework-commands"

# Copy only the 5 framework commands (for auto-update)
FRAMEWORK_COMMANDS=(
    "fi.md"
    "ui.md"
    "watch.md"
    "migrate-legacy.md"
    "upgrade-framework.md"
)

for cmd in "${FRAMEWORK_COMMANDS[@]}"; do
    if [ -f "$PROJECT_ROOT/.claude/commands/$cmd" ]; then
        cp "$PROJECT_ROOT/.claude/commands/$cmd" "$TEMP_DIR/framework-commands/"
    else
        echo -e "${YELLOW}⚠${NC} Warning: $cmd not found, skipping"
    fi
done

# Package Codex adapter update payload
mkdir -p "$TEMP_DIR/framework-commands/codex-adapter"
if [ -f "$PROJECT_ROOT/AGENTS.md" ]; then
    cp "$PROJECT_ROOT/AGENTS.md" "$TEMP_DIR/framework-commands/codex-adapter/AGENTS.md"
fi
if [ -d "$PROJECT_ROOT/.codex" ]; then
    cp -r "$PROJECT_ROOT/.codex" "$TEMP_DIR/framework-commands/codex-adapter/"
    rm -rf "$TEMP_DIR/framework-commands/codex-adapter/.codex/parity"
    rm -rf "$TEMP_DIR/framework-commands/codex-adapter/.codex/manifests"
    rm -rf "$TEMP_DIR/framework-commands/codex-adapter/.codex/reports"
    find "$TEMP_DIR/framework-commands/codex-adapter/.codex" -name ".DS_Store" -delete 2>/dev/null || true
fi

mkdir -p "$TEMP_DIR/framework-commands/claude-adapter/.claude/scripts"
if [ -f "$PROJECT_ROOT/.claude/scripts/quick-update.sh" ]; then
    cp "$PROJECT_ROOT/.claude/scripts/quick-update.sh" "$TEMP_DIR/framework-commands/claude-adapter/.claude/scripts/"
fi

# Create commands archive
cd "$TEMP_DIR"
tar -czf framework-commands.tar.gz framework-commands/
cp framework-commands.tar.gz "$DIST_DIR/framework-commands.tar.gz"

COMMANDS_SIZE=$(du -h "$DIST_DIR/framework-commands.tar.gz" | awk '{print $1}')
echo -e "${GREEN}✓${NC} Created framework-commands.tar.gz (${COMMANDS_SIZE})"

# ============================================================================
# Create Distribution Summary
# ============================================================================

INSTALLER_SIZE=$(du -h "$DIST_DIR/init-project.sh" | awk '{print $1}')
ARCHIVE_SIZE=$(du -h "$DIST_DIR/framework.tar.gz" | awk '{print $1}')
COMMANDS_SIZE=$(du -h "$DIST_DIR/framework-commands.tar.gz" | awk '{print $1}')

cat > "$DIST_DIR/README.txt" <<EOF
Claude Code Starter Framework v${VERSION}
Distribution Package

Files:
  - init-project.sh (${INSTALLER_SIZE}) - Installer script
  - framework.tar.gz (${ARCHIVE_SIZE}) - Full framework archive (Claude + Codex adapters)
  - framework-commands.tar.gz (${COMMANDS_SIZE}) - Update payload (commands + adapter runtime)

Installation:

Method 1 — Quick Install (requires internet):
  Download and run the installer, it will fetch the framework from GitHub Releases:

  curl -O https://github.com/alexeykrol/claude-code-starter/releases/download/v${VERSION}/init-project.sh
  chmod +x init-project.sh
  ./init-project.sh

Method 2 — Offline Install (manual):
  If you have both files locally:

  1. Download both files to your project directory
  2. Make executable: chmod +x init-project.sh
  3. Extract: tar -xzf framework.tar.gz
  4. Copy files from framework/ to your project

The installer script is small (${INSTALLER_SIZE}) and downloads the framework archive
automatically from GitHub Releases when run.

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
echo "  - init-project.sh (${INSTALLER_SIZE}) - Installer script (small loader)"
echo "  - framework.tar.gz (${ARCHIVE_SIZE}) - Framework files archive"
echo "  - framework-commands.tar.gz (${COMMANDS_SIZE}) - Update payload (commands + adapter runtime)"
echo "  - README.txt - Usage instructions"
echo ""
echo "Next steps:"
echo "  1. Test the installer on a clean project"
echo "  2. Upload files to GitHub Releases:"
echo "     - init-project.sh (for installation)"
echo "     - framework.tar.gz (for installation)"
echo "     - framework-commands.tar.gz (for auto-update)"
echo "     - CLAUDE.md (for Claude adapter updates)"
echo "     - AGENTS.md (for Codex adapter updates)"
echo "  3. Update documentation with download URLs"
echo ""
echo "Test command (requires uploading to GitHub first):"
echo "  curl -O https://github.com/USER/REPO/releases/download/v${VERSION}/init-project.sh"
echo "  chmod +x init-project.sh"
echo "  ./init-project.sh"
echo ""
