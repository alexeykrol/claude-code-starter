#!/bin/bash
#
# Claude Code Starter — Migration Payload
# Version: 5.0.0
#
# Internal migration used by the public root launcher.
# Интегрирует управляющую среду в существующий проект.
#
# Принцип: НИЧЕГО НЕ ТРОГАТЬ, ТОЛЬКО ДОБАВЛЯТЬ.
# - Существующий код остаётся как есть
# - Существующая документация остаётся как есть
# - Существующие метафайлы остаются как есть
# - Старые commands/, protocols/, .codex/ — остаются (это документация проекта)
# - Добавляются только отсутствующие файлы управления фреймворка
#
# Использование:
#   bash migrate.sh                                # Автоматический режим
#   bash migrate.sh --template /path/to/template   # С указанием шаблона
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/.."
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# === Parse Arguments ===
while [[ $# -gt 0 ]]; do
    case $1 in
        --template) TEMPLATE_DIR="$2"; shift 2 ;;
        *)          shift ;;
    esac
done

echo ""
echo -e "${BLUE}Claude Code Starter v5.0 — Integration${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# === Analyze Existing Project ===
log_info "Project: $PROJECT_NAME"
log_info "Analyzing existing structure..."
echo ""

# Count existing documentation
DOC_COUNT=0
DOC_LIST=""
for ext in md txt rst; do
    while IFS= read -r -d '' f; do
        DOC_COUNT=$((DOC_COUNT + 1))
        DOC_LIST="${DOC_LIST}\n    $(echo "$f" | sed "s|^\./||")"
    done < <(find . -maxdepth 3 -name "*.${ext}" -not -path './node_modules/*' -not -path './.venv/*' -not -path './.git/*' -print0 2>/dev/null)
done

if [ "$DOC_COUNT" -gt 0 ]; then
    log_info "Found $DOC_COUNT documentation files (untouched):"
    echo -e "$DOC_LIST" | head -20
    [ "$DOC_COUNT" -gt 20 ] && echo "    ... and $((DOC_COUNT - 20)) more"
    echo ""
fi

# Check for existing framework elements
EXISTING=""
[ -f "CLAUDE.md" ]                    && EXISTING="${EXISTING} CLAUDE.md"
[ -f ".claude/SNAPSHOT.md" ]          && EXISTING="${EXISTING} SNAPSHOT.md"
[ -f ".claude/settings.json" ]        && EXISTING="${EXISTING} settings.json"
[ -d ".claude/rules" ]                && EXISTING="${EXISTING} rules/"
[ -d ".claude/skills" ]               && EXISTING="${EXISTING} skills/"
[ -d ".claude/agents" ]               && EXISTING="${EXISTING} agents/"
[ -d ".claude/commands" ]             && EXISTING="${EXISTING} commands/"
[ -d ".claude/protocols" ]            && EXISTING="${EXISTING} protocols/"
[ -d ".codex" ]                       && EXISTING="${EXISTING} .codex/"

if [ -n "$EXISTING" ]; then
    log_info "Existing framework elements (kept as-is):${EXISTING}"
    echo ""
fi

# === Add Missing Framework Files ===
log_info "Adding missing framework files..."
echo ""
bash "$SCRIPT_DIR/init-project.sh" --name "$PROJECT_NAME" --template "$TEMPLATE_DIR"

# === Enrich CLAUDE.md with Operations Section ===
# If CLAUDE.md exists but doesn't have the v5 operations block, append it.
# The existing project description is preserved entirely.
if [ -f "CLAUDE.md" ]; then
    if ! grep -q "Операционный режим" "CLAUDE.md" 2>/dev/null; then
        if [ -f "$TEMPLATE_DIR/CLAUDE.md" ]; then
            OPERATIONS_BLOCK=$(awk '/^## Операционный режим/,0' "$TEMPLATE_DIR/CLAUDE.md")
            if [ -n "$OPERATIONS_BLOCK" ]; then
                echo "" >> "CLAUDE.md"
                echo "$OPERATIONS_BLOCK" >> "CLAUDE.md"
                log_success "Enriched: CLAUDE.md — appended operations section (existing content preserved)"
            fi
        fi
    fi
fi

# === Upgrade settings.json Hook Schema (if needed) ===
# Strategy: MERGE hooks from template into existing file, preserving all other keys.
# Never replace the whole file — that destroys custom permissions and user keys.
if [ -f ".claude/settings.json" ]; then
    HAS_HOOKS=$(grep -c '"hooks"' ".claude/settings.json" 2>/dev/null) || HAS_HOOKS=0
    HAS_MATCHER=$(grep -c '"matcher"' ".claude/settings.json" 2>/dev/null) || HAS_MATCHER=0
    HAS_PRECOMPACT=$(grep -c '"PreCompact"' ".claude/settings.json" 2>/dev/null) || HAS_PRECOMPACT=0

    NEEDS_UPGRADE=false
    if [ "$HAS_HOOKS" -gt 0 ] && [ "$HAS_MATCHER" -eq 0 ]; then
        NEEDS_UPGRADE=true  # Old hook format
    elif [ "$HAS_HOOKS" -eq 0 ] && [ "$HAS_PRECOMPACT" -eq 0 ]; then
        NEEDS_UPGRADE=true  # No hooks at all
    fi

    if [ "$NEEDS_UPGRADE" = true ]; then
        cp ".claude/settings.json" ".claude/settings.json.bak"

        # Merge: take existing file, replace/add only the "hooks" key from template.
        # Uses Python (available on virtually all systems) for safe JSON merge.
        if command -v python3 &>/dev/null; then
            python3 -c "
import json, sys
with open('.claude/settings.json.bak') as f:
    existing = json.load(f)
with open('$TEMPLATE_DIR/.claude/settings.json') as f:
    template = json.load(f)
existing['hooks'] = template['hooks']
with open('.claude/settings.json', 'w') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
" 2>/dev/null
            if [ $? -eq 0 ]; then
                log_success "Merged: v5 hooks into .claude/settings.json (existing keys preserved, backup: settings.json.bak)"
            else
                # Python merge failed — fall back to full copy (with warning)
                cp "$TEMPLATE_DIR/.claude/settings.json" ".claude/settings.json"
                log_warning "Replaced: .claude/settings.json (JSON merge failed, backup: settings.json.bak)"
            fi
        else
            # No python3 — fall back to full copy (with warning)
            cp "$TEMPLATE_DIR/.claude/settings.json" ".claude/settings.json"
            log_warning "Replaced: .claude/settings.json (python3 not found for merge, backup: settings.json.bak)"
        fi
    fi
fi

# === Write Migration Log ===
MIGRATION_END=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE=".claude/logs/migrations/$(date +%Y-%m-%d_%H-%M).json"
mkdir -p .claude/logs/migrations

# Collect created files (from init-project.sh output)
CREATED_FILES=$(git status --porcelain 2>/dev/null | grep "^?" | awk '{print $2}' | head -50)
CLAUDE_ENRICHED="false"
grep -q "Операционный режим" "CLAUDE.md" 2>/dev/null && CLAUDE_ENRICHED="true"
SETTINGS_UPGRADED="false"
[ -f ".claude/settings.json.bak" ] && SETTINGS_UPGRADED="true"

cat > "$LOG_FILE" << LOGEOF
{
  "timestamp": "$TIMESTAMP",
  "completed": "$MIGRATION_END",
  "project": "$PROJECT_NAME",
  "doc_files_found": $DOC_COUNT,
  "claude_md_enriched": $CLAUDE_ENRICHED,
  "settings_upgraded": $SETTINGS_UPGRADED,
  "errors": []
}
LOGEOF

log_success "Migration log: $LOG_FILE"

# === Summary ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Claude Code Starter integrated: $PROJECT_NAME${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "What was done:"
echo "  - Added missing management files (rules, skills, agents, hooks)"
echo "  - Existing code, docs, and configs left untouched"
[ "$DOC_COUNT" -gt 0 ] && echo "  - $DOC_COUNT documentation files preserved in place"
echo ""
echo "Open in Claude Code and run: /start"
echo ""
