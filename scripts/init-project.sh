#!/bin/bash
#
# Claude Code Starter — Bootstrap Payload
# Version: 6.0.0 (content-aware)
#
# Internal bootstrap used by the public root launcher.
# Разворачивает управляющую среду Claude Code в новом проекте.
# Не трогает существующий код. Создаёт только инфраструктуру управления.
#
# Использование:
#   bash init-project.sh                                       # Авто-определение типа
#   bash init-project.sh --name "My Project"
#   bash init-project.sh --type code|content|hybrid|auto
#   bash init-project.sh --content-type book|course|knowledge-base|documents|transcripts|mixed
#   bash init-project.sh --template /path/to/framework
#   bash init-project.sh --rollback                            # Восстановить из последнего backup
#   bash init-project.sh --apply-proposal                      # Применить CLAUDE.md merge proposal
#   bash init-project.sh --force                               # Перезаписать существующее (для разработчиков фреймворка)
#

set -e

# === Config (caller responsibilities) ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/.."
PROJECT_DIR="$(pwd)"

# Подключаем общую библиотеку (определения функций, цвета, TIMESTAMP, BACKUP_TAG).
# shellcheck source=lib/install_common.sh
source "$SCRIPT_DIR/lib/install_common.sh"

# === Defaults ===
PROJECT_NAME=""
TEMPLATE_PATH=""
PROJECT_TYPE="auto"
CONTENT_TYPE=""
MODE="install"
FORCE=0

# === Parse Arguments ===
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)            PROJECT_NAME="$2"; shift 2 ;;
        --template)        TEMPLATE_PATH="$2"; shift 2 ;;
        --type)            PROJECT_TYPE="$2"; shift 2 ;;
        --content-type)    CONTENT_TYPE="$2"; shift 2 ;;
        --rollback)        MODE="rollback"; shift ;;
        --apply-proposal)  MODE="apply-proposal"; shift ;;
        --force)           FORCE=1; shift ;;
        *)                 shift ;;
    esac
done

# === Determine Template Source ===
if [ -n "$TEMPLATE_PATH" ] && [ -d "$TEMPLATE_PATH" ]; then
    TEMPLATE_DIR="$TEMPLATE_PATH"
elif [ -d "$SCRIPT_DIR/../.claude/rules" ]; then
    TEMPLATE_DIR="$SCRIPT_DIR/.."
else
    if [ "$MODE" = "install" ]; then
        log_error "Template not found. Provide --template path or run from a framework checkout with scripts/"
        exit 1
    fi
fi

# ============================================================================
# Mode dispatcher
# ============================================================================

case "$MODE" in
    rollback)
        rollback
        exit 0
        ;;
    apply-proposal)
        apply_proposal
        exit 0
        ;;
    install)
        # Welcome
        if [ -z "$PROJECT_NAME" ]; then
            PROJECT_NAME=$(basename "$PROJECT_DIR")
            echo ""
            echo -e "${BLUE}Claude Code Starter v6.0 — Bootstrap${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            if [ -t 0 ] && [ -t 1 ]; then
                read -p "Project name [$PROJECT_NAME]: " input_name
                PROJECT_NAME="${input_name:-$PROJECT_NAME}"
            fi
        fi

        echo ""
        log_info "Setting up environment for: $PROJECT_NAME"
        echo ""

        # Git detection
        detect_git

        # Project type detection (если auto)
        if [ "$PROJECT_TYPE" = "auto" ]; then
            log_info "Detecting project type..."
            PROJECT_TYPE=$(detect_project_type)
            log_info "Detected project type: $PROJECT_TYPE"
        fi

        # Content type detection (если применимо)
        if [ "$PROJECT_TYPE" = "content" ] || [ "$PROJECT_TYPE" = "hybrid" ]; then
            if [ -z "$CONTENT_TYPE" ]; then
                CONTENT_TYPE=$(detect_content_type)
                log_info "Detected content type: $CONTENT_TYPE"
            fi
        fi

        # Unknown → fallback на code
        if [ "$PROJECT_TYPE" = "unknown" ]; then
            log_warning "Could not detect project type. Defaulting to 'code'. Use --type to override."
            PROJECT_TYPE="code"
        fi

        # Backup до любых изменений
        backup_existing

        # Установка
        install_common

        case "$PROJECT_TYPE" in
            code)
                install_code
                ;;
            content)
                install_content
                ;;
            hybrid)
                install_hybrid
                ;;
            *)
                log_error "Unknown project type: $PROJECT_TYPE"
                exit 1
                ;;
        esac

        # CLAUDE.md merge — выбираем правильный template через helper
        merge_claude_md "CLAUDE.md" "$(claude_md_template_for_type)"

        # Manifest (с расширенными полями)
        generate_manifest

        # Git init (если ещё нет — detect_git мог пропустить)
        if [ ! -d ".git" ]; then
            git init -q 2>/dev/null && log_success "Initialized git repository" || true
        fi

        print_summary
        ;;
    *)
        log_error "Unknown mode: $MODE"
        exit 1
        ;;
esac
