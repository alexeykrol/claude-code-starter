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

# ============================================
# Project Type Detection & Qualification
# ============================================

detect_project_type() {
    # Check for existing Framework
    if [ -d ".claude" ]; then
        # Scenario 3: Has Framework - detect version
        if [ -f ".claude/SNAPSHOT.md" ]; then
            VERSION_LINE=$(grep -i "framework:" .claude/SNAPSHOT.md 2>/dev/null | head -1)
            if [ -n "$VERSION_LINE" ]; then
                FW_VERSION=$(echo "$VERSION_LINE" | awk '{print $NF}' | sed 's/[^0-9.]//g')
                echo "framework-upgrade:$FW_VERSION"
            else
                echo "framework-upgrade:v1.x"
            fi
        elif [ -f ".claude/BACKLOG.md" ]; then
            # v2.0 if BACKLOG exists but no ROADMAP/IDEAS
            if [ ! -f ".claude/ROADMAP.md" ]; then
                echo "framework-upgrade:v2.0"
            else
                # Already v2.1+
                echo "framework-current:v2.1"
            fi
        else
            echo "framework-upgrade:v1.x"
        fi
    # Check for legacy v1.x structure (Init/ folder)
    elif [ -d "Init" ] && [ -f "Init/PROJECT_SNAPSHOT.md" ]; then
        echo "framework-upgrade:v1.x"
    # Check for project code (legacy without Framework)
    elif [ -d "src" ] || [ -d "lib" ] || [ -f "package.json" ] || [ -f "pom.xml" ] || [ -f "Cargo.toml" ]; then
        echo "legacy-migration"
    else
        # New empty project
        echo "new-project"
    fi
}

estimate_analysis_cost() {
    log_info "Estimating analysis cost..."

    # Count lines in code files
    TOTAL_LINES=0
    if command -v find &> /dev/null && command -v wc &> /dev/null; then
        TOTAL_LINES=$(find . -type f \( \
            -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" \
            -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" \
            -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \
            -o -name "*.md" -o -name "*.txt" \
        \) ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" \
        2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    fi

    # Rough estimate: ~2 tokens per line
    ESTIMATED_TOKENS=$((TOTAL_LINES * 2))

    # Add overhead for analysis (~20k)
    ESTIMATED_TOKENS=$((ESTIMATED_TOKENS + 20000))

    # Calculate cost (Sonnet: $3 per 1M input tokens)
    ESTIMATED_COST=$(printf "%.2f" $(echo "$ESTIMATED_TOKENS * 0.000003" | bc -l 2>/dev/null || echo "0.15"))

    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  📊 Deep Analysis Cost Estimate"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "  Project size: ~$TOTAL_LINES lines of code"
    echo "  Estimated tokens: ~$ESTIMATED_TOKENS"
    echo "  Estimated cost: ~\$$ESTIMATED_COST USD"
    echo ""
    echo "  What will be analyzed:"
    echo "    • Project structure and modules"
    echo "    • Existing documentation (README, TODO, etc)"
    echo "    • Git history (recent commits)"
    echo "    • Package metadata"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo ""
}

# Detect project type
PROJECT_TYPE=$(detect_project_type)

# ============================================
# Route to Appropriate Scenario
# ============================================

case $PROJECT_TYPE in
    "new-project")
        log_info "📦 Scenario: New Project"
        log_info "Simple installation with template files"
        echo ""

        # Mark as new project mode
        MIGRATION_MODE="new"
        # Continue with simple installation below
        ;;

    "legacy-migration")
        log_warning "🔍 Scenario: Legacy Project (No Framework)"
        echo ""
        echo "This project has code but no Framework installed."
        echo "Deep analysis is recommended to generate accurate Framework files."
        echo ""

        estimate_analysis_cost

        echo "Legacy migration will:"
        echo "  1. Analyze your project structure"
        echo "  2. Find existing docs (README, TODO, ARCHITECTURE, etc)"
        echo "  3. Generate Framework files based on analysis"
        echo "  4. ❌ NOT modify your existing files"
        echo ""

        read -p "Proceed with deep analysis? (y/N) " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            log_info "You can install Framework later with: ./init-project.sh"
            exit 0
        fi

        # Mark as legacy migration mode
        MIGRATION_MODE="legacy"

        # Will create migration context after installation
        ;;

    framework-upgrade:*)
        OLD_VERSION=$(echo "$PROJECT_TYPE" | cut -d: -f2)
        log_warning "🔄 Scenario: Framework Upgrade (from $OLD_VERSION)"
        echo ""
        echo "This project has Framework $OLD_VERSION installed."
        echo "Migration to v$VERSION will preserve all your data."
        echo ""
        echo "Migration will:"

        if [[ "$OLD_VERSION" == "v1.x" ]]; then
            echo "  • Move Init/ → .claude/ structure"
            echo "  • Add ROADMAP.md and IDEAS.md"
            echo "  • Archive old Init/ folder"
        elif [[ "$OLD_VERSION" == "v2.0" ]]; then
            echo "  • Add ROADMAP.md (extract from BACKLOG)"
            echo "  • Add IDEAS.md (new template)"
            echo "  • Restructure BACKLOG.md"
        else
            echo "  • Update Framework files"
        fi

        echo "  • ✅ Preserve ALL existing data"
        echo "  • 💾 Create backup before changes"
        echo ""

        read -p "Proceed with migration? (y/N) " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Migration cancelled"
            exit 0
        fi

        MIGRATION_MODE="upgrade"
        OLD_FW_VERSION="$OLD_VERSION"

        # Will create migration context after installation
        ;;

    "framework-current:v2.1")
        log_success "✅ Framework v2.1+ already installed"
        echo ""
        echo "Your project already has the latest Framework structure."
        echo "No installation needed."
        echo ""
        exit 0
        ;;
esac

# ============================================
# Install Framework Files (mode-dependent)
# ============================================

log_info "Installing framework to current directory..."

if [ "$MIGRATION_MODE" = "new" ]; then
    # NEW PROJECT: Copy everything, generate meta files

    # Copy full .claude directory
    if [ -d "$TEMP_DIR/framework/.claude" ]; then
        mkdir -p .claude
        cp -r "$TEMP_DIR/framework/.claude/"* .claude/ 2>/dev/null || true
        log_success "Installed .claude/ directory"
    fi

    # Copy CLAUDE.md
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
        BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n' || echo "main")
        [ -z "$BRANCH" ] && BRANCH="main"

        if [ -f ".claude/templates/SNAPSHOT.template.md" ]; then
            sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
                -e "s/{{DATE}}/$DATE/g" \
                -e "s/{{CURRENT_BRANCH}}/$BRANCH/g" \
                .claude/templates/SNAPSHOT.template.md > .claude/SNAPSHOT.md
            log_success "Generated .claude/SNAPSHOT.md"
        fi

        if [ -f ".claude/templates/BACKLOG.template.md" ]; then
            sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
                -e "s/{{DATE}}/$DATE/g" \
                .claude/templates/BACKLOG.template.md > .claude/BACKLOG.md
            log_success "Generated .claude/BACKLOG.md"
        fi

        if [ -f ".claude/templates/ARCHITECTURE.template.md" ]; then
            sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
                .claude/templates/ARCHITECTURE.template.md > .claude/ARCHITECTURE.md
            log_success "Generated .claude/ARCHITECTURE.md"
        fi
    fi

else
    # LEGACY or UPGRADE: Copy only minimum for Claude to run analysis
    # Meta files will be created/updated by Claude after analysis

    mkdir -p .claude/commands

    # Copy only essential commands for migration
    cp "$TEMP_DIR/framework/.claude/commands/migrate-legacy.md" .claude/commands/ 2>/dev/null || true
    cp "$TEMP_DIR/framework/.claude/commands/upgrade-framework.md" .claude/commands/ 2>/dev/null || true
    log_success "Installed migration commands"

    # Copy CLAUDE.md (needed for Claude to know the protocol)
    if [ ! -f "CLAUDE.md" ] && [ -f "$TEMP_DIR/framework/CLAUDE.md" ]; then
        cp "$TEMP_DIR/framework/CLAUDE.md" .
        log_success "Installed CLAUDE.md"
    fi

    # Store framework archive path for Claude to use later
    cp "$TEMP_DIR/framework.tar.gz" .claude/framework-pending.tar.gz 2>/dev/null || true
    log_info "Framework files staged for post-analysis installation"
fi

# Create migration context for all scenarios
if [ "$MIGRATION_MODE" = "legacy" ]; then
    echo "{\"mode\": \"legacy\", \"timestamp\": \"$(date -Iseconds)\"}" > .claude/migration-context.json
    log_success "Created migration context"
elif [ "$MIGRATION_MODE" = "upgrade" ]; then
    echo "{\"mode\": \"upgrade\", \"old_version\": \"$OLD_FW_VERSION\", \"timestamp\": \"$(date -Iseconds)\"}" > .claude/migration-context.json
    log_success "Created migration context"
elif [ "$MIGRATION_MODE" = "new" ]; then
    echo "{\"mode\": \"new\", \"timestamp\": \"$(date -Iseconds)\"}" > .claude/migration-context.json
    log_success "Created migration context"
fi

# Success summary
echo ""
echo "════════════════════════════════════════════════════════════"
log_success "Installation complete!"
echo "════════════════════════════════════════════════════════════"
echo ""

echo "🚀 Next steps:"
echo ""
echo "  1. Run: claude"
echo "  2. Type: start"
echo ""

