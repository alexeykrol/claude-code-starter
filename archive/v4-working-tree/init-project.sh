#!/bin/bash
#
# Claude Code Starter Framework — Installer
# Version: 4.0.2
#
# Downloads and installs the framework from GitHub Releases
#

set -e  # Exit on error

VERSION="${FRAMEWORK_VERSION:-4.0.2}"
REPO="${FRAMEWORK_REPO:-alexeykrol/claude-code-starter}"
ARCHIVE_URL="${FRAMEWORK_ARCHIVE_URL:-https://github.com/${REPO}/releases/download/v${VERSION}/framework.tar.gz}"
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

is_interactive_mode() {
    [ "${FRAMEWORK_INTERACTIVE:-0}" = "1" ]
}

normalize_project_profile() {
    local raw="${1:-}"
    raw="$(printf "%s" "$raw" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
    case "$raw" in
        "content"|"software")
            echo "$raw"
            ;;
        *)
            echo ""
            ;;
    esac
}

detect_existing_project_profile() {
    local config_file=".claude/.framework-config"
    if [ ! -f "$config_file" ]; then
        echo ""
        return
    fi

    python3 - "$config_file" <<'PY' 2>/dev/null || true
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding="utf-8"))
except Exception:
    print("")
    raise SystemExit(0)

profile = str(data.get("project_type", "")).strip().lower()
if profile in {"software", "content"}:
    print(profile)
else:
    print("")
PY
}

detect_project_profile_guess() {
    local text_count code_count

    text_count=$(find . -maxdepth 3 -type f \
        \( -name "*.md" -o -name "*.txt" -o -name "*.rst" -o -name "*.docx" \) \
        ! -path "./.git/*" \
        ! -path "./.claude/*" \
        ! -path "./.codex/*" \
        ! -path "./node_modules/*" \
        ! -path "./dist/*" \
        ! -path "./build/*" \
        ! -path "./archive/*" \
        ! -path "./reports/*" \
        2>/dev/null | wc -l | tr -d '[:space:]')
    code_count=$(find . -maxdepth 3 -type f \
        \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.php" -o -name "*.rb" \) \
        ! -path "./.git/*" \
        ! -path "./.claude/*" \
        ! -path "./.codex/*" \
        ! -path "./node_modules/*" \
        ! -path "./dist/*" \
        ! -path "./build/*" \
        ! -path "./archive/*" \
        ! -path "./reports/*" \
        2>/dev/null | wc -l | tr -d '[:space:]')

    if [ -z "$text_count" ]; then
        text_count=0
    fi
    if [ -z "$code_count" ]; then
        code_count=0
    fi

    if [ "$text_count" -ge 8 ] && [ "$text_count" -gt "$((code_count * 2 + 3))" ]; then
        echo "content"
    else
        echo "software"
    fi
}

select_project_profile() {
    local scenario="${1:-}"
    local existing_profile env_profile guessed_profile input selected
    local require_profile_prompt=0

    existing_profile="$(detect_existing_project_profile)"
    if [ -n "$existing_profile" ]; then
        PROJECT_PROFILE="$existing_profile"
        log_info "Using existing project profile from .framework-config: $PROJECT_PROFILE"
        return
    fi

    env_profile="$(normalize_project_profile "${FRAMEWORK_PROJECT_TYPE:-}")"
    if [ -n "$env_profile" ]; then
        PROJECT_PROFILE="$env_profile"
        log_info "Using project profile from FRAMEWORK_PROJECT_TYPE: $PROJECT_PROFILE"
        return
    fi

    guessed_profile="$(detect_project_profile_guess)"
    PROJECT_PROFILE="$guessed_profile"

    case "$scenario" in
        framework-upgrade:*|framework-current:*)
            require_profile_prompt=1
            ;;
    esac

    if [ "$require_profile_prompt" -eq 1 ]; then
        if [ -t 0 ]; then
            echo ""
            echo "Project profile is required for upgrade from older framework versions."
            echo "Select project profile:"
            echo "  1) software (application/service development)"
            echo "  2) content  (course/book/article/research production)"
            echo ""
            if [ "$guessed_profile" = "content" ]; then
                read -r -p "Choose profile [1/2] (default: 2): " input
            else
                read -r -p "Choose profile [1/2] (default: 1): " input
            fi

            case "$(printf "%s" "$input" | tr -d '[:space:]')" in
                "2"|"content")
                    selected="content"
                    ;;
                "1"|"software"|"")
                    if [ "$guessed_profile" = "content" ] && [ -z "$(printf "%s" "$input" | tr -d '[:space:]')" ]; then
                        selected="content"
                    else
                        selected="software"
                    fi
                    ;;
                *)
                    selected="$guessed_profile"
                    ;;
            esac
            PROJECT_PROFILE="$selected"
            log_info "Selected project profile: $PROJECT_PROFILE"
            return
        fi

        log_warning "Cannot prompt for project profile in non-interactive mode."
        log_warning "Using auto-detected profile: $PROJECT_PROFILE (override with FRAMEWORK_PROJECT_TYPE=software|content)"
        return
    fi

    if is_interactive_mode; then
        echo ""
        echo "Select project profile:"
        echo "  1) software (application/service development)"
        echo "  2) content  (course/book/article/research production)"
        echo ""
        if [ "$guessed_profile" = "content" ]; then
            read -r -p "Choose profile [1/2] (default: 2): " input
        else
            read -r -p "Choose profile [1/2] (default: 1): " input
        fi

        case "$(printf "%s" "$input" | tr -d '[:space:]')" in
            "2"|"content")
                selected="content"
                ;;
            "1"|"software"|"")
                if [ "$guessed_profile" = "content" ] && [ -z "$(printf "%s" "$input" | tr -d '[:space:]')" ]; then
                    selected="content"
                else
                    selected="software"
                fi
                ;;
            *)
                selected="$guessed_profile"
                ;;
        esac
        PROJECT_PROFILE="$selected"
        log_info "Selected project profile: $PROJECT_PROFILE"
    else
        log_info "Auto-selected project profile: $PROJECT_PROFILE (set FRAMEWORK_PROJECT_TYPE to override)"
    fi
}

get_state_dir_for_profile() {
    local profile="$1"
    if [ "$profile" = "content" ]; then
        echo ".claude/content"
    else
        echo ".claude"
    fi
}

render_template_file() {
    local template_path="$1"
    local target_path="$2"
    local project_name="$3"
    local date_value="$4"
    local branch_value="$5"
    local profile="$6"
    local project_description="$7"
    local project_structure="$8"

    python3 - "$template_path" "$target_path" "$project_name" "$date_value" "$branch_value" "$profile" "$project_description" "$project_structure" <<'PY'
import sys
from pathlib import Path

template_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])
project_name = sys.argv[3]
date_value = sys.argv[4]
branch_value = sys.argv[5]
project_type = sys.argv[6]
project_description = sys.argv[7]
project_structure = sys.argv[8]

replacements = {
    "PROJECT_NAME": project_name,
    "DATE": date_value,
    "CURRENT_BRANCH": branch_value,
    "PROJECT_TYPE": project_type,
    "PROJECT_DESCRIPTION": project_description,
    "PROJECT_STRUCTURE": project_structure,
}

content = template_path.read_text(encoding="utf-8")
for key, value in replacements.items():
    content = content.replace("{{" + key + "}}", value)

target_path.parent.mkdir(parents=True, exist_ok=True)
target_path.write_text(content, encoding="utf-8")
PY
}

confirm_step() {
    local prompt="$1"

    if is_interactive_mode; then
        read -p "$prompt (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
        return
    fi

    log_info "$prompt -> auto-confirmed (set FRAMEWORK_INTERACTIVE=1 to enable prompts)"
    return 0
}

install_codex_adapter() {
    if [ -d "$TEMP_DIR/framework/.codex" ]; then
        mkdir -p .codex
        cp -r "$TEMP_DIR/framework/.codex/"* .codex/ 2>/dev/null || true
        log_success "Installed .codex/ directory"
    else
        log_warning "Codex adapter directory (.codex) not found in framework archive"
    fi

    if [ -f "$TEMP_DIR/framework/AGENTS.md" ]; then
        cp "$TEMP_DIR/framework/AGENTS.md" AGENTS.md
        log_success "Installed AGENTS.md (Codex adapter entry)"
    else
        log_warning "AGENTS.md not found in framework archive"
    fi
}

install_shared_runtime() {
    if [ -d "$TEMP_DIR/framework/src/framework-core" ]; then
        mkdir -p src/framework-core
        cp -r "$TEMP_DIR/framework/src/framework-core/"* src/framework-core/ 2>/dev/null || true
        chmod +x src/framework-core/main.py 2>/dev/null || true
        log_success "Installed shared core runtime (src/framework-core)"
    else
        log_warning "Shared core runtime (src/framework-core) not found in framework archive"
    fi

    if [ -d "$TEMP_DIR/framework/security" ]; then
        mkdir -p security
        cp -r "$TEMP_DIR/framework/security/"* security/ 2>/dev/null || true
        chmod +x security/*.sh 2>/dev/null || true
        log_success "Installed security scripts"
    else
        log_warning "Security scripts directory not found in framework archive"
    fi
}

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
    if ! confirm_step "Continue anyway?"; then
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
    # Check for existing Framework markers.
    # Note: some projects may have a local `.claude/` from Claude app settings
    # without framework installation. Treat as framework only if real markers exist.
    FRAMEWORK_MARKERS=0
    if [ -f "CLAUDE.md" ] || [ -f "AGENTS.md" ] || [ -d ".codex" ]; then
        FRAMEWORK_MARKERS=1
    elif [ -d ".claude" ] && { [ -d ".claude/commands" ] || [ -d ".claude/protocols" ] || [ -d ".claude/templates" ] || [ -f ".claude/migration-context.json" ]; }; then
        FRAMEWORK_MARKERS=1
    fi

    # Check for existing Framework
    if [ "$FRAMEWORK_MARKERS" -eq 1 ]; then
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
    # Check for explicit code markers (legacy without Framework)
    elif [ -d "src" ] || [ -d "lib" ] || [ -f "package.json" ] || [ -f "pom.xml" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ] || [ -f "pyproject.toml" ]; then
        echo "legacy-migration"
    else
        # Heuristic: if project already has meaningful user files, treat as legacy.
        NON_FRAMEWORK_CONTENT=$(find . -mindepth 1 -maxdepth 2 \
            ! -path "./.git*" \
            ! -path "./.claude*" \
            ! -path "./.codex*" \
            ! -path "./node_modules*" \
            ! -path "./dist*" \
            ! -path "./build*" \
            ! -path "./archive*" \
            ! -path "./reports*" \
            ! -path "./.DS_Store" \
            ! -name "init-project.sh" \
            ! -name "quick-update.sh" \
            ! -name "framework.tar.gz" \
            ! -name "framework-commands.tar.gz" \
            ! -name "CLAUDE.md" \
            ! -name "AGENTS.md" \
            ! -name "FRAMEWORK_GUIDE.md" \
            -print -quit 2>/dev/null || true)

        if [ -n "$NON_FRAMEWORK_CONTENT" ]; then
            echo "legacy-migration"
        else
            # New empty project
            echo "new-project"
        fi
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
select_project_profile "$PROJECT_TYPE"

# ============================================
# Route to Appropriate Scenario
# ============================================

case $PROJECT_TYPE in
    "new-project")
        log_info "📦 Scenario: New Project"
        log_info "Simple installation with template files"
        log_info "Project profile: $PROJECT_PROFILE"
        echo ""

        # Mark as new project mode
        MIGRATION_MODE="new"
        # Continue with simple installation below
        ;;

    "legacy-migration")
        log_warning "🔍 Scenario: Legacy Project (No Framework)"
        log_info "Project profile: $PROJECT_PROFILE"
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

        if ! confirm_step "Proceed with deep analysis?"; then
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
        log_info "Project profile: $PROJECT_PROFILE"
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

        if ! confirm_step "Proceed with migration?"; then
            log_info "Migration cancelled"
            exit 0
        fi

        MIGRATION_MODE="upgrade"
        OLD_FW_VERSION="$OLD_VERSION"

        # Will create migration context after installation
        ;;

    "framework-current:v2.1")
        if [ -f "AGENTS.md" ] && [ -d ".codex" ]; then
            log_success "✅ Framework v2.1+ already installed"
            echo ""
            echo "Claude and Codex adapters are already present."
            echo "No installation needed."
            echo ""
            exit 0
        fi

        log_warning "🧩 Framework is current, but Codex adapter is missing"
        log_info "Project profile: $PROJECT_PROFILE"
        echo ""
        echo "This run will add Codex adapter files (AGENTS.md + .codex/)."
        echo "Existing Claude adapter files will be preserved."
        echo ""

        if ! confirm_step "Proceed with Codex adapter installation?"; then
            log_info "Installation cancelled"
            exit 0
        fi

        MIGRATION_MODE="upgrade"
        OLD_FW_VERSION="v2.1"
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

    # Install Codex adapter files
    install_codex_adapter

    # Install shared runtime utilities used by both adapters
    install_shared_runtime

    # Install npm dependencies for framework CLI
    if [ -f ".claude/dist/claude-export/package.json" ]; then
        log_info "Installing framework dependencies..."
        if command -v npm &> /dev/null; then
            (cd .claude/dist/claude-export && npm install --silent 2>&1 | grep -v "^npm WARN" || true) && \
                log_success "Framework dependencies installed" || {
                log_warning "Failed to install dependencies automatically"
                log_info "You can install them later with: cd .claude/dist/claude-export && npm install"
            }
        else
            log_warning "npm not found - skipping dependency installation"
            log_info "Install npm, then run: cd .claude/dist/claude-export && npm install"
        fi
    fi

    # Copy CLAUDE.production.md as CLAUDE.md (no migration needed)
    if [ ! -f "CLAUDE.md" ] && [ -f "$TEMP_DIR/framework/CLAUDE.production.md" ]; then
        cp "$TEMP_DIR/framework/CLAUDE.production.md" CLAUDE.md
        log_success "Installed CLAUDE.md (production)"
    fi

    # Copy FRAMEWORK_GUIDE.md
    if [ -f "$TEMP_DIR/framework/FRAMEWORK_GUIDE.md" ]; then
        cp "$TEMP_DIR/framework/FRAMEWORK_GUIDE.md" .
        log_success "Installed FRAMEWORK_GUIDE.md"
    fi

    # Generate memory and config files from templates
    if [ -d ".claude/templates" ]; then
        log_info "Generating framework files from templates..."

        PROJECT_NAME=$(basename "$PROJECT_DIR")
        DATE=$(date +%Y-%m-%d)
        BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n' || echo "main")
        [ -z "$BRANCH" ] && BRANCH="main"
        STATE_DIR="$(get_state_dir_for_profile "$PROJECT_PROFILE")"
        TEMPLATE_DIR=".claude/templates"
        if [ "$PROJECT_PROFILE" = "content" ]; then
            if [ -d ".claude/templates/content" ]; then
                TEMPLATE_DIR=".claude/templates/content"
            else
                log_warning "Content templates not found in archive, falling back to software templates"
            fi
        fi

        if [ "$PROJECT_PROFILE" = "content" ]; then
            PROJECT_DESCRIPTION="Content project focused on producing high-quality textual assets."
        else
            PROJECT_DESCRIPTION="Software project initialized with dual-agent framework lifecycle."
        fi

        PROJECT_STRUCTURE=$(find . -mindepth 1 -maxdepth 2 \
            ! -path "./.git*" \
            ! -path "./.claude*" \
            ! -path "./.codex*" \
            ! -path "./node_modules*" \
            ! -path "./dist*" \
            ! -path "./build*" \
            ! -path "./archive*" \
            ! -path "./reports*" \
            -print 2>/dev/null | sed 's|^\./||' | head -10 | paste -sd ', ' -)
        [ -z "$PROJECT_STRUCTURE" ] && PROJECT_STRUCTURE="<project files>"

        mkdir -p "$STATE_DIR"

        if [ -f "$TEMPLATE_DIR/SNAPSHOT.template.md" ]; then
            render_template_file "$TEMPLATE_DIR/SNAPSHOT.template.md" "$STATE_DIR/SNAPSHOT.md" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated $STATE_DIR/SNAPSHOT.md"
        fi

        if [ -f "$TEMPLATE_DIR/BACKLOG.template.md" ]; then
            render_template_file "$TEMPLATE_DIR/BACKLOG.template.md" "$STATE_DIR/BACKLOG.md" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated $STATE_DIR/BACKLOG.md"
        fi

        if [ -f "$TEMPLATE_DIR/ARCHITECTURE.template.md" ]; then
            render_template_file "$TEMPLATE_DIR/ARCHITECTURE.template.md" "$STATE_DIR/ARCHITECTURE.md" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated $STATE_DIR/ARCHITECTURE.md"
        fi

        if [ "$PROJECT_PROFILE" = "content" ] && [ -f "$TEMPLATE_DIR/EDITORIAL_CALENDAR.template.md" ]; then
            render_template_file "$TEMPLATE_DIR/EDITORIAL_CALENDAR.template.md" "$STATE_DIR/EDITORIAL_CALENDAR.md" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated $STATE_DIR/EDITORIAL_CALENDAR.md"
        fi

        if [ "$PROJECT_PROFILE" = "content" ] && [ -f "$TEMPLATE_DIR/SOURCES.template.md" ]; then
            render_template_file "$TEMPLATE_DIR/SOURCES.template.md" "$STATE_DIR/SOURCES.md" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated $STATE_DIR/SOURCES.md"
        fi

        # Generate .framework-config from template
        if [ -f ".claude/templates/.framework-config.template.json" ]; then
            render_template_file ".claude/templates/.framework-config.template.json" ".claude/.framework-config" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated .claude/.framework-config"
        elif [ ! -f ".claude/.framework-config" ]; then
            cat > .claude/.framework-config <<EOF
{
  "bug_reporting_enabled": false,
  "dialog_export_enabled": false,
  "project_name": "$PROJECT_NAME",
  "project_type": "$PROJECT_PROFILE",
  "first_run_completed": false,
  "consent_version": "1.0",
  "cold_start": {
    "silent_mode": true,
    "show_ready": false,
    "auto_update": true
  },
  "completion": {
    "silent_mode": true,
    "auto_commit": false,
    "show_commit_message": true
  }
}
EOF
            log_success "Generated .claude/.framework-config (fallback)"
        fi

        # Generate COMMIT_POLICY.md from template (NEW in v2.5.0)
        if [ -f ".claude/templates/COMMIT_POLICY.template.md" ]; then
            render_template_file ".claude/templates/COMMIT_POLICY.template.md" ".claude/COMMIT_POLICY.md" "$PROJECT_NAME" "$DATE" "$BRANCH" "$PROJECT_PROFILE" "$PROJECT_DESCRIPTION" "$PROJECT_STRUCTURE"
            log_success "Generated .claude/COMMIT_POLICY.md"
        fi
    fi

else
    # LEGACY or UPGRADE: Copy full framework structure
    # Meta files will be created/updated by Claude after analysis

    # Copy full .claude directory (commands, dist, protocols, scripts, templates)
    if [ -d "$TEMP_DIR/framework/.claude" ]; then
        mkdir -p .claude
        cp -r "$TEMP_DIR/framework/.claude/"* .claude/ 2>/dev/null || true
        log_success "Installed .claude/ directory"
    fi

    # Install Codex adapter files
    install_codex_adapter

    # Install shared runtime utilities used by both adapters
    install_shared_runtime

    # Install npm dependencies for framework CLI
    if [ -f ".claude/dist/claude-export/package.json" ]; then
        log_info "Installing framework dependencies..."
        if command -v npm &> /dev/null; then
            (cd .claude/dist/claude-export && npm install --silent 2>&1 | grep -v "^npm WARN" || true) && \
                log_success "Framework dependencies installed" || {
                log_warning "Failed to install dependencies automatically"
                log_info "You can install them later with: cd .claude/dist/claude-export && npm install"
            }
        else
            log_warning "npm not found - skipping dependency installation"
            log_info "Install npm, then run: cd .claude/dist/claude-export && npm install"
        fi
    fi

    # Copy CLAUDE.migration.md as CLAUDE.md (temporary, will be replaced after migration)
    if [ -f "$TEMP_DIR/framework/CLAUDE.migration.md" ]; then
        cp "$TEMP_DIR/framework/CLAUDE.migration.md" CLAUDE.md
        log_success "Installed CLAUDE.md (migration mode)"
    fi

    # Store CLAUDE.production.md for swap after migration completes
    if [ -f "$TEMP_DIR/framework/CLAUDE.production.md" ]; then
        cp "$TEMP_DIR/framework/CLAUDE.production.md" .claude/CLAUDE.production.md
        log_info "Staged CLAUDE.production.md for post-migration swap"
    fi
fi

# Create migration context for all scenarios
if [ "$MIGRATION_MODE" = "legacy" ]; then
    echo "{\"mode\": \"legacy\", \"project_type\": \"$PROJECT_PROFILE\", \"timestamp\": \"$(date -Iseconds)\"}" > .claude/migration-context.json
    log_success "Created migration context"
elif [ "$MIGRATION_MODE" = "upgrade" ]; then
    echo "{\"mode\": \"upgrade\", \"old_version\": \"$OLD_FW_VERSION\", \"project_type\": \"$PROJECT_PROFILE\", \"timestamp\": \"$(date -Iseconds)\"}" > .claude/migration-context.json
    log_success "Created migration context"
elif [ "$MIGRATION_MODE" = "new" ]; then
    echo "{\"mode\": \"new\", \"project_type\": \"$PROJECT_PROFILE\", \"timestamp\": \"$(date -Iseconds)\"}" > .claude/migration-context.json
    log_success "Created migration context"
fi

# Success summary
echo ""
echo "════════════════════════════════════════════════════════════"
log_success "Installation complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
log_info "Project profile configured: $PROJECT_PROFILE"
if [ "$PROJECT_PROFILE" = "content" ]; then
    log_info "Primary memory files: .claude/content/{SNAPSHOT,BACKLOG,ARCHITECTURE}.md"
else
    log_info "Primary memory files: .claude/{SNAPSHOT,BACKLOG,ARCHITECTURE}.md"
fi
echo ""

echo "🚀 Next steps:"
echo ""
echo "  Option A (Codex):"
echo "    1. Run: codex"
echo "    2. Type: start"
echo ""
echo "  Option B (Claude Code):"
echo "    1. Run: claude"
echo "    2. Type: start"
echo ""
