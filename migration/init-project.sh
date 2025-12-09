#!/bin/bash
#
# Claude Code Starter Framework — Installer
# Version: 2.1.1
#
# Downloads and installs the framework from GitHub Releases
#

set -e  # Exit on error

VERSION="2.1.1"
REPO="alexeykrol/claude-code-starter"
ARCHIVE_URL="https://github.com/${REPO}/releases/download/v${VERSION}/framework.tar.gz"
PROJECT_DIR="$(pwd)"
TEMP_DIR="/tmp/claude-framework-$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cleanup on exit
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Output functions
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Header
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Claude Code Starter Framework Installer"
echo "  Version: $VERSION"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if running in a project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "README.md" ]; then
    log_warning "This doesn't look like a project directory"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
fi

# Download framework archive
log_info "Downloading framework from GitHub Releases..."
mkdir -p "$TEMP_DIR"

if command -v curl &> /dev/null; then
    curl -L -f "$ARCHIVE_URL" -o "$TEMP_DIR/framework.tar.gz" || {
        log_error "Failed to download framework archive"
        log_info "URL: $ARCHIVE_URL"
        log_info "Make sure the release exists on GitHub"
        exit 1
    }
elif command -v wget &> /dev/null; then
    wget -q "$ARCHIVE_URL" -O "$TEMP_DIR/framework.tar.gz" || {
        log_error "Failed to download framework archive"
        exit 1
    }
else
    log_error "Neither curl nor wget found. Please install one of them."
    exit 1
fi

log_success "Downloaded framework archive"

# Extract archive
log_info "Extracting framework files..."
tar -xzf "$TEMP_DIR/framework.tar.gz" -C "$TEMP_DIR" || {
    log_error "Failed to extract archive"
    exit 1
}
log_success "Extracted framework files"

# Install framework files
log_info "Installing framework to current directory..."

# Copy .claude directory structure
if [ -d "$TEMP_DIR/framework/.claude" ]; then
    mkdir -p .claude
    cp -r "$TEMP_DIR/framework/.claude/"* .claude/ 2>/dev/null || true
    log_success "Installed .claude/ directory"
fi

# Copy CLAUDE.md if not exists
if [ ! -f "CLAUDE.md" ] && [ -f "$TEMP_DIR/framework/CLAUDE.md" ]; then
    cp "$TEMP_DIR/framework/CLAUDE.md" .
    log_success "Installed CLAUDE.md"
fi

# Copy FRAMEWORK_GUIDE.md
if [ -f "$TEMP_DIR/framework/FRAMEWORK_GUIDE.md" ]; then
    cp "$TEMP_DIR/framework/FRAMEWORK_GUIDE.md" .
    log_success "Installed FRAMEWORK_GUIDE.md"
fi

# Generate meta files from templates
if [ -d ".claude/templates" ]; then
    log_info "Generating meta files from templates..."

    PROJECT_NAME=$(basename "$PROJECT_DIR")
    DATE=$(date +%Y-%m-%d)
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

    # Generate SNAPSHOT.md (only if doesn't exist - preserve legacy project data!)
    if [ ! -f ".claude/SNAPSHOT.md" ] && [ -f ".claude/templates/SNAPSHOT.template.md" ]; then
        sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
            -e "s/{{DATE}}/$DATE/g" \
            -e "s/{{CURRENT_BRANCH}}/$BRANCH/g" \
            .claude/templates/SNAPSHOT.template.md > .claude/SNAPSHOT.md
        log_success "Generated .claude/SNAPSHOT.md"
    elif [ -f ".claude/SNAPSHOT.md" ]; then
        log_info "Preserved existing .claude/SNAPSHOT.md (legacy project)"
    fi

    # Generate BACKLOG.md (only if doesn't exist - preserve legacy project data!)
    if [ ! -f ".claude/BACKLOG.md" ] && [ -f ".claude/templates/BACKLOG.template.md" ]; then
        sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
            -e "s/{{DATE}}/$DATE/g" \
            .claude/templates/BACKLOG.template.md > .claude/BACKLOG.md
        log_success "Generated .claude/BACKLOG.md"
    elif [ -f ".claude/BACKLOG.md" ]; then
        log_info "Preserved existing .claude/BACKLOG.md (legacy project)"
    fi

    # Generate ARCHITECTURE.md (only if doesn't exist - preserve legacy project data!)
    if [ ! -f ".claude/ARCHITECTURE.md" ] && [ -f ".claude/templates/ARCHITECTURE.template.md" ]; then
        sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
            .claude/templates/ARCHITECTURE.template.md > .claude/ARCHITECTURE.md
        log_success "Generated .claude/ARCHITECTURE.md"
    elif [ -f ".claude/ARCHITECTURE.md" ]; then
        log_info "Preserved existing .claude/ARCHITECTURE.md (legacy project)"
    fi
fi

# Success summary
echo ""
echo "════════════════════════════════════════════════════════════"
log_success "Installation complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Framework files installed in .claude/"
echo "Meta files generated (SNAPSHOT, BACKLOG, ARCHITECTURE)"
echo ""
echo "Next steps:"
echo "  1. Open this project in Claude Code"
echo "  2. Type: start (or начать)"
echo "  3. Claude will load your project context"
echo ""
echo "Documentation:"
echo "  - FRAMEWORK_GUIDE.md — How to use the framework"
echo "  - .claude/SNAPSHOT.md — Edit to update project context"
echo "  - .claude/BACKLOG.md — Edit to manage tasks"
echo ""
