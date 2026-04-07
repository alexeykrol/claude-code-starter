#!/bin/bash
#
# Claude Code Starter — Installer
# Version: 5.0.0
#
# Public entrypoint for every installation scenario:
# - new project bootstrap
# - existing project integration
# - legacy framework migration
# - top-up upgrade for partially installed v5 projects
#
# Usage:
#   bash init-project.sh
#   bash init-project.sh --name "My Project"
#   bash init-project.sh --mode init
#   bash init-project.sh --mode migrate
#   bash init-project.sh --template /path/to/local/framework
#

set -euo pipefail

VERSION="${FRAMEWORK_VERSION:-5.0.0}"
REPO="${FRAMEWORK_REPO:-alexeykrol/claude-code-starter}"
ARCHIVE_URL="${FRAMEWORK_ARCHIVE_URL:-https://github.com/${REPO}/releases/download/v${VERSION}/framework.tar.gz}"
FALLBACK_URL="${FRAMEWORK_FALLBACK_URL:-https://codeload.github.com/${REPO}/tar.gz/refs/heads/main}"
GIT_URL="${FRAMEWORK_GIT_URL:-https://github.com/${REPO}.git}"

PROJECT_DIR="$(pwd)"
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
TEMP_DIR="$(mktemp -d "/tmp/claude-code-starter-XXXXXX")"

PROJECT_NAME=""
FORCE_MODE=""
TEMPLATE_PATH=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "${RED}✗${NC} $1"; }

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

usage() {
    cat <<'EOF'
Claude Code Starter — Installer

Usage:
  bash init-project.sh [options]

Options:
  --name "Project Name"     Set the project name for fresh bootstrap
  --mode init               Force bootstrap mode
  --mode migrate            Force additive migration mode
  --template /path          Use a local framework checkout instead of downloading
  --help                    Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            PROJECT_NAME="${2:-}"
            shift 2
            ;;
        --mode)
            FORCE_MODE="${2:-}"
            shift 2
            ;;
        --template)
            TEMPLATE_PATH="${2:-}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

download_file() {
    local url="$1"
    local out="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$out" "$url"
    else
        log_error "curl or wget is required to download the framework payload"
        exit 1
    fi
}

resolve_source_dir() {
    local source_dir=""
    local archive_path=""

    if [ -n "$TEMPLATE_PATH" ]; then
        if [ ! -d "$TEMPLATE_PATH" ]; then
            log_error "Template path not found: $TEMPLATE_PATH"
            exit 1
        fi
        source_dir="$TEMPLATE_PATH"
    elif [ -f "$SCRIPT_DIR/scripts/init-project.sh" ] && [ -f "$SCRIPT_DIR/scripts/migrate.sh" ] && [ -d "$SCRIPT_DIR/.claude/rules" ]; then
        source_dir="$SCRIPT_DIR"
    else
        archive_path="$TEMP_DIR/framework.tar.gz"
        log_info "Standalone launcher detected. Downloading Claude Code Starter payload..." >&2

        if download_file "$ARCHIVE_URL" "$archive_path"; then
            log_success "Downloaded release payload" >&2
            tar -xzf "$archive_path" -C "$TEMP_DIR"
            source_dir="$(find "$TEMP_DIR" -mindepth 1 -maxdepth 2 -type d -exec test -f '{}/scripts/init-project.sh' ';' -print | head -1)"
        elif git clone --depth 1 "$GIT_URL" "$TEMP_DIR/payload" >/dev/null 2>&1; then
            log_success "Cloned framework payload via git" >&2
            source_dir="$TEMP_DIR/payload"
        else
            log_warning "Release payload unavailable. Falling back to repository snapshot." >&2
            download_file "$FALLBACK_URL" "$archive_path"
            tar -xzf "$archive_path" -C "$TEMP_DIR"
            source_dir="$(find "$TEMP_DIR" -mindepth 1 -maxdepth 2 -type d -exec test -f '{}/scripts/init-project.sh' ';' -print | head -1)"
        fi
    fi

    if [ -z "$source_dir" ] || [ ! -f "$source_dir/scripts/init-project.sh" ] || [ ! -f "$source_dir/scripts/migrate.sh" ]; then
        log_error "Framework payload is incomplete. Expected scripts/init-project.sh and scripts/migrate.sh."
        exit 1
    fi

    if [ "$PROJECT_DIR" = "$source_dir" ]; then
        log_error "You are in the framework repository itself."
        echo "Run this launcher from a target project directory, or copy the file there."
        exit 1
    fi

    echo "$source_dir"
}

has_legacy_markers() {
    [ -d "$PROJECT_DIR/.claude/commands" ] || \
    [ -d "$PROJECT_DIR/.claude/protocols" ] || \
    [ -f "$PROJECT_DIR/.claude/.framework-config" ] || \
    [ -d "$PROJECT_DIR/.codex" ]
}

has_v5_markers() {
    [ -f "$PROJECT_DIR/manifest.md" ] || \
    [ -d "$PROJECT_DIR/.claude/rules" ] || \
    [ -d "$PROJECT_DIR/.claude/skills" ] || \
    [ -d "$PROJECT_DIR/.claude/agents" ] || \
    [ -f "$PROJECT_DIR/scripts/framework-state-mode.sh" ] || \
    [ -f "$PROJECT_DIR/scripts/switch-repo-access.sh" ]
}

has_host_files() {
    find "$PROJECT_DIR" -mindepth 1 -maxdepth 2 \
        ! -path "$PROJECT_DIR/.git" \
        ! -path "$PROJECT_DIR/.git/*" \
        ! -path "$PROJECT_DIR/init-project.sh" \
        ! -path "$PROJECT_DIR/.DS_Store" \
        -print -quit | grep -q .
}

detect_scenario() {
    case "$FORCE_MODE" in
        init)
            echo "new"
            return
            ;;
        migrate)
            if has_legacy_markers; then
                echo "legacy"
            elif has_v5_markers; then
                echo "upgrade"
            else
                echo "existing"
            fi
            return
            ;;
        "" ) ;;
        *)
            log_error "Unsupported mode: $FORCE_MODE"
            echo "Use --mode init or --mode migrate"
            exit 1
            ;;
    esac

    if has_legacy_markers; then
        echo "legacy"
    elif has_v5_markers; then
        echo "upgrade"
    elif has_host_files; then
        echo "existing"
    else
        echo "new"
    fi
}

run_internal_init() {
    local source_dir="$1"
    local args=("--template" "$source_dir")

    if [ -n "$PROJECT_NAME" ]; then
        args=("--name" "$PROJECT_NAME" "${args[@]}")
    fi

    bash "$source_dir/scripts/init-project.sh" "${args[@]}"
}

run_internal_migrate() {
    local source_dir="$1"
    bash "$source_dir/scripts/migrate.sh" --template "$source_dir"
}

SOURCE_DIR="$(resolve_source_dir)"
SCENARIO="$(detect_scenario)"

echo ""
echo -e "${BLUE}Claude Code Starter v5.0${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "Target project: $(basename "$PROJECT_DIR")"

case "$SCENARIO" in
    new)
        log_info "Scenario detected: new project bootstrap"
        echo ""
        run_internal_init "$SOURCE_DIR"
        ;;
    existing)
        log_info "Scenario detected: existing project without framework"
        log_info "Running additive integration."
        echo ""
        run_internal_migrate "$SOURCE_DIR"
        ;;
    legacy)
        log_info "Scenario detected: legacy framework installation"
        log_info "Running additive migration."
        echo ""
        run_internal_migrate "$SOURCE_DIR"
        ;;
    upgrade)
        log_info "Scenario detected: existing v5 or partial installation"
        log_info "Filling missing files and normalizing operational layer."
        echo ""
        run_internal_migrate "$SOURCE_DIR"
        ;;
esac
