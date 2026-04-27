#!/bin/bash
#
# Claude Code Starter — Migration Payload
# Version: 6.1.0 (content-aware additive migration)
#
# Internal migration used by the public root launcher.
# Аддитивная интеграция framework в существующий проект.
#
# Принцип: НИЧЕГО НЕ ТРОГАТЬ, ТОЛЬКО ДОБАВЛЯТЬ.
# - Существующий код, документация, метафайлы остаются как есть
# - Добавляются только отсутствующие framework files (rules/skills/agents/hooks)
# - CLAUDE.md merge'ится аддитивно через scripts/lib/merge_claude_md.py
# - При hard conflict — стоп + конкретное предложение в .claude/CLAUDE.md.merge-proposal.md
# - Backup всегда создаётся перед любыми изменениями
# - Rollback восстанавливает последний backup
#
# Использование:
#   bash migrate.sh                                # Авто-определение типа
#   bash migrate.sh --name "My Project"
#   bash migrate.sh --type code|content|hybrid|auto
#   bash migrate.sh --content-type book|course|knowledge-base|documents|transcripts|mixed
#   bash migrate.sh --template /path/to/framework
#   bash migrate.sh --rollback                     # Восстановить из последнего backup
#   bash migrate.sh --apply-proposal               # Применить CLAUDE.md merge proposal
#   bash migrate.sh --force                        # Перезаписать существующее
#

set -e

# === Config (caller responsibilities) ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/.."
PROJECT_DIR="$(pwd)"

# Подключаем общую библиотеку.
# shellcheck source=lib/install_common.sh
source "$SCRIPT_DIR/lib/install_common.sh"

# === Defaults ===
PROJECT_NAME=""
TEMPLATE_PATH=""
PROJECT_TYPE="auto"
CONTENT_TYPE=""
MODE="migrate"
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
    if [ "$MODE" = "migrate" ]; then
        log_error "Template not found. Provide --template path or run from a framework checkout with scripts/"
        exit 1
    fi
fi

# ============================================================================
# Migration logging
# ============================================================================

# Пишет JSON-лог миграции в .claude/logs/migrations/.
write_migration_log() {
    local end_ts
    end_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local log_file
    log_file=".claude/logs/migrations/$(date +%Y-%m-%d_%H-%M).json"
    mkdir -p .claude/logs/migrations

    local doc_count
    doc_count=$(find . -maxdepth 3 -type f \( -name '*.md' -o -name '*.txt' -o -name '*.rst' \) \
        -not -path './node_modules/*' -not -path './.venv/*' -not -path './.git/*' \
        -not -path './.claude/*' 2>/dev/null | wc -l | tr -d ' ')

    local claude_enriched="false"
    grep -q "Операционный режим" "CLAUDE.md" 2>/dev/null && claude_enriched="true"

    cat > "$log_file" <<LOGEOF
{
  "timestamp": "$TIMESTAMP",
  "completed": "$end_ts",
  "project": "$PROJECT_NAME",
  "project_type": "$PROJECT_TYPE",
  "content_type": "$CONTENT_TYPE",
  "doc_files_found": $doc_count,
  "claude_md_enriched": $claude_enriched,
  "backup_dir": "$BACKUP_DIR",
  "errors": []
}
LOGEOF

    log_success "Migration log: $log_file"
}

# ============================================================================
# Mode dispatcher
# ============================================================================

# Header
echo ""
echo -e "${BLUE}Claude Code Starter v6.0 — Migration${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

case "$MODE" in
    rollback)
        rollback
        exit 0
        ;;
    apply-proposal)
        apply_proposal
        exit 0
        ;;
    migrate)
        # Resolve project name
        if [ -z "$PROJECT_NAME" ]; then
            PROJECT_NAME=$(basename "$PROJECT_DIR")
        fi

        log_info "Project: $PROJECT_NAME"
        log_info "Analyzing existing structure..."
        analyze_existing_project
        echo ""

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

        # Unknown → fallback на code (безопасный выбор для существующего кодового проекта)
        if [ "$PROJECT_TYPE" = "unknown" ]; then
            log_warning "Could not detect project type. Defaulting to 'code'. Use --type to override."
            PROJECT_TYPE="code"
        fi

        # Backup до любых изменений
        backup_existing

        # Установка (аддитивно — все функции используют copy_if_missing внутри)
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

        # CLAUDE.md merge — с детекцией конфликтов
        merge_claude_md "CLAUDE.md" "$(claude_md_template_for_type)"

        # Manifest (с расширенными полями)
        generate_manifest

        # Git init не делаем в migrate — у существующего проекта уже есть свой git

        # Migration log
        write_migration_log

        # Final summary
        print_migration_summary
        ;;
    *)
        log_error "Unknown mode: $MODE"
        exit 1
        ;;
esac
