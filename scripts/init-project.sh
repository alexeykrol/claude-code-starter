#!/bin/bash
#
# Claude Code Starter — Bootstrap Payload
# Version: 5.0.0
#
# Internal bootstrap used by the public root launcher.
# Разворачивает управляющую среду Claude Code в новом проекте.
# Не трогает существующий код. Создаёт только инфраструктуру управления.
#
# Использование:
#   bash init-project.sh                          # Интерактивный режим
#   bash init-project.sh --name "My Project"      # С именем проекта
#   bash init-project.sh --template /path/to/template  # Из шаблона
#

set -e

# === Config ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/.."
PROJECT_DIR="$(pwd)"
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
log_error()   { echo -e "${RED}✗${NC} $1"; }

# === Parse Arguments ===
PROJECT_NAME=""
TEMPLATE_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)     PROJECT_NAME="$2"; shift 2 ;;
        --template) TEMPLATE_PATH="$2"; shift 2 ;;
        *)          shift ;;
    esac
done

# === Determine Template Source ===
if [ -n "$TEMPLATE_PATH" ] && [ -d "$TEMPLATE_PATH" ]; then
    TEMPLATE_DIR="$TEMPLATE_PATH"
elif [ -d "$SCRIPT_DIR/../.claude/rules" ]; then
    TEMPLATE_DIR="$SCRIPT_DIR/.."
else
    log_error "Template not found. Provide --template path or run from a framework checkout with scripts/"
    exit 1
fi

# === Interactive: Project Name ===
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    echo ""
    echo -e "${BLUE}Claude Code Starter v5.0 — Bootstrap${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "Project name [$PROJECT_NAME]: " input_name
    PROJECT_NAME="${input_name:-$PROJECT_NAME}"
fi

echo ""
log_info "Setting up environment for: $PROJECT_NAME"
echo ""

# === Create Directory Structure ===
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_success "Created: $1"
    else
        log_warning "Exists:  $1"
    fi
}

create_dir ".claude"
create_dir ".claude/rules"
create_dir ".claude/skills/start"
create_dir ".claude/skills/finish"
create_dir ".claude/skills/testing"
create_dir ".claude/skills/playwright"
create_dir ".claude/skills/db-migrate"
create_dir ".claude/skills/housekeeping"
create_dir ".claude/agents/researcher"
create_dir ".claude/agents/implementer"
create_dir ".claude/agents/reviewer"
create_dir ".claude/hooks"
create_dir ".claude/logs/sessions"
create_dir ".claude/logs/migrations"
create_dir ".claude/logs/errors"
create_dir "scripts"

# === Copy Template Files (only if not exists) ===
copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$dst" ]; then
        if [ -f "$src" ]; then
            cp "$src" "$dst"
            log_success "Created: $dst"
        fi
    else
        log_warning "Exists:  $dst (not overwritten)"
    fi
}

# Rules
for rule in autonomy delegation context-management production-safety local-first commit-policy logging; do
    copy_if_missing "$TEMPLATE_DIR/.claude/rules/${rule}.md" ".claude/rules/${rule}.md"
done

# Skills
for skill in start finish testing playwright db-migrate housekeeping; do
    copy_if_missing "$TEMPLATE_DIR/.claude/skills/${skill}/SKILL.md" ".claude/skills/${skill}/SKILL.md"
done

# Agents
for agent in researcher implementer reviewer; do
    copy_if_missing "$TEMPLATE_DIR/.claude/agents/${agent}/${agent}.md" ".claude/agents/${agent}/${agent}.md"
done

# Hooks
copy_if_missing "$TEMPLATE_DIR/.claude/hooks/pre-compact.sh" ".claude/hooks/pre-compact.sh"
copy_if_missing "$TEMPLATE_DIR/.claude/hooks/post-compact.sh" ".claude/hooks/post-compact.sh"
copy_if_missing "$TEMPLATE_DIR/.claude/hooks/post-tool-checkpoint.sh" ".claude/hooks/post-tool-checkpoint.sh"
copy_if_missing "$TEMPLATE_DIR/.claude/hooks/subagent-done.sh" ".claude/hooks/subagent-done.sh"
chmod +x .claude/hooks/*.sh 2>/dev/null || true

# Local scripts installed into the target project
copy_if_missing "$TEMPLATE_DIR/scripts/framework-state-mode.sh" "scripts/framework-state-mode.sh"
copy_if_missing "$TEMPLATE_DIR/scripts/switch-repo-access.sh" "scripts/switch-repo-access.sh"
chmod +x scripts/*.sh 2>/dev/null || true

# Settings — merge hooks if file already exists
if [ ! -f ".claude/settings.json" ]; then
    if [ -f "$TEMPLATE_DIR/.claude/settings.json" ]; then
        cp "$TEMPLATE_DIR/.claude/settings.json" ".claude/settings.json"
        log_success "Created: .claude/settings.json"
    fi
else
    # File exists — check if hooks section needs merging from template
    merge_needed=$(python3 -c "
import json, sys
try:
    with open('.claude/settings.json') as f:
        existing = json.load(f)
    with open('$TEMPLATE_DIR/.claude/settings.json') as f:
        template = json.load(f)
    t_hooks = template.get('hooks', {})
    e_hooks = existing.get('hooks', {})
    # Check if any template hook key is missing from existing
    missing = [k for k in t_hooks if k not in e_hooks]
    print('yes' if missing else 'no')
except Exception as e:
    print('error:' + str(e), file=sys.stderr)
    print('no')
" 2>/dev/null)

    if [ "$merge_needed" = "yes" ]; then
        python3 -c "
import json, sys
with open('.claude/settings.json') as f:
    existing = json.load(f)
with open('$TEMPLATE_DIR/.claude/settings.json') as f:
    template = json.load(f)
t_hooks = template.get('hooks', {})
e_hooks = existing.get('hooks', {})
# Add missing hook keys from template (don't overwrite existing ones)
for key, val in t_hooks.items():
    if key not in e_hooks:
        e_hooks[key] = val
existing['hooks'] = e_hooks
with open('.claude/settings.json', 'w') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_success "Updated: .claude/settings.json (merged missing hooks from template)"
        else
            log_error "Failed to merge hooks into .claude/settings.json"
        fi
    else
        log_warning "Exists:  .claude/settings.json (hooks up to date)"
    fi
fi
# settings.local.json is NOT auto-copied (opt-in only)
# To enable full autonomy, manually create .claude/settings.local.json with:
#   {"permissions": {"bypassPermissions": true}}
if [ ! -f ".claude/settings.local.json" ]; then
    log_info "Tip: For full autonomy, create .claude/settings.local.json with bypassPermissions:true"
fi

# SNAPSHOT
if [ ! -f ".claude/SNAPSHOT.md" ]; then
    # Use awk to safely substitute without sed special char issues
    awk -v val="$TIMESTAMP" '{gsub(/\{\{DATE\}\}/, val); print}' "$TEMPLATE_DIR/.claude/SNAPSHOT.md" > ".claude/SNAPSHOT.md"
    log_success "Created: .claude/SNAPSHOT.md"
else
    log_warning "Exists:  .claude/SNAPSHOT.md (not overwritten)"
fi

# manifest.md — generate with project name
if [ ! -f "manifest.md" ]; then
    awk -v val="$PROJECT_NAME" 'BEGIN{gsub(/&/, "\\\\&", val)} {gsub(/\{\{PROJECT_NAME\}\}/, val); print}' "$TEMPLATE_DIR/manifest.md" > "manifest.md"
    log_success "Created: manifest.md"
else
    log_warning "Exists:  manifest.md (not overwritten)"
fi

# CLAUDE.md — generate with project name
if [ ! -f "CLAUDE.md" ]; then
    # Use awk for safe substitution.
    # IMPORTANT: In awk gsub(), & in replacement = matched text.
    # Escape & inside awk via BEGIN block before using val in gsub.
    awk -v val="$PROJECT_NAME" 'BEGIN{gsub(/&/, "\\\\&", val)} {gsub(/\{\{PROJECT_NAME\}\}/, val); print}' "$TEMPLATE_DIR/CLAUDE.md" > "CLAUDE.md"
    log_success "Created: CLAUDE.md (customize this file for your project)"
else
    log_warning "Exists:  CLAUDE.md (not overwritten)"
fi

# .gitignore — merge, don't overwrite
if [ ! -f ".gitignore" ]; then
    cp "$TEMPLATE_DIR/.gitignore" ".gitignore"
    log_success "Created: .gitignore"
else
    # Add missing entries
    added=0
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [[ "$line" == \#* ]] && continue
        if ! grep -qF "$line" ".gitignore" 2>/dev/null; then
            echo "$line" >> ".gitignore"
            added=$((added + 1))
        fi
    done < "$TEMPLATE_DIR/.gitignore"
    if [ "$added" -gt 0 ]; then
        log_success "Updated: .gitignore (+$added entries)"
    else
        log_warning "Exists:  .gitignore (up to date)"
    fi
fi

# === Git Init ===
if [ ! -d ".git" ]; then
    git init -q
    log_success "Initialized git repository"
fi

# === Summary ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Claude Code Starter ready: $PROJECT_NAME${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md — describe your project"
echo "  2. Edit manifest.md — set project_name and repo_access"
echo "  3. If repo_access is public/private-shared, run scripts/switch-repo-access.sh BEFORE the first framework commit"
echo "  4. Open in Claude Code and run: /start"
echo ""
