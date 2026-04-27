#!/bin/bash
#
# Claude Code Starter — Global Installer
# Version: 6.1.0
#
# Устанавливает framework в глобальный ~/.claude/, чтобы он был доступен
# во всех проектах без отдельного init.
#
# Что делает:
#   - Backup ~/.claude/ → ~/.claude/.backup-TIMESTAMP/
#   - Аддитивно копирует content rules/skills/agents (которых ещё нет)
#   - Заменяет skills/housekeeping на content-version (она универсальнее)
#   - Добавляет content-reviewer как отдельного агента
#   - Копирует code-only skills из framework (db-migrate, playwright)
#   - Устанавливает skill /init для бутстрапа новых проектов
#   - Аддитивно мёрджит ~/.claude/CLAUDE.md с framework addendum
#   - Записывает путь к framework checkout в ~/.claude/framework-source-path
#
# Использование:
#   bash scripts/install-global.sh
#   bash scripts/install-global.sh --rollback
#   bash scripts/install-global.sh --dry-run
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GLOBAL_DIR="$HOME/.claude"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$GLOBAL_DIR/.backup-$TIMESTAMP"
MERGER="$SCRIPT_DIR/lib/merge_claude_md.py"

MODE="install"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --rollback) MODE="rollback"; shift ;;
        --dry-run)  DRY_RUN=1; shift ;;
        --help|-h)
            cat <<'EOF'
Usage:
  bash scripts/install-global.sh           Install/update global framework layer
  bash scripts/install-global.sh --rollback  Restore from latest backup
  bash scripts/install-global.sh --dry-run   Show what would be done
EOF
            exit 0
            ;;
        *) shift ;;
    esac
done

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

run() {
    if [ "$DRY_RUN" = "1" ]; then
        echo "  [dry-run] $*"
    else
        "$@"
    fi
}

# ============================================================================
# Rollback
# ============================================================================

do_rollback() {
    local last_backup
    last_backup=$(ls -dt "$GLOBAL_DIR"/.backup-* 2>/dev/null | head -1)
    if [ -z "$last_backup" ] || [ ! -d "$last_backup" ]; then
        log_error "No backup found in $GLOBAL_DIR"
        exit 1
    fi

    log_info "Rolling back from: $last_backup"

    # Restore each tracked subdir/file from backup, but only if backup contains it
    for item in CLAUDE.md rules skills agents framework-source-path; do
        local src="$last_backup/$item"
        local dst="$GLOBAL_DIR/$item"
        if [ -e "$src" ]; then
            if [ -d "$dst" ]; then
                rm -rf "$dst"
            elif [ -f "$dst" ]; then
                rm -f "$dst"
            fi
            cp -R "$src" "$dst"
            log_success "Restored: $item"
        fi
    done

    log_info "Rollback complete. Backup directory preserved at: $last_backup"
}

if [ "$MODE" = "rollback" ]; then
    do_rollback
    exit 0
fi

# ============================================================================
# Install
# ============================================================================

echo ""
echo -e "${BLUE}Claude Code Starter — Global Layer Installer${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Sanity checks
if [ ! -d "$FRAMEWORK_DIR/templates/content" ]; then
    log_error "Framework checkout missing templates/content/ at $FRAMEWORK_DIR"
    exit 1
fi
if [ ! -d "$FRAMEWORK_DIR/templates/global" ]; then
    log_error "Framework checkout missing templates/global/ at $FRAMEWORK_DIR"
    exit 1
fi

# Ensure ~/.claude/ exists
mkdir -p "$GLOBAL_DIR"

# === Backup ===
log_info "Creating backup: $BACKUP_DIR"
if [ "$DRY_RUN" = "0" ]; then
    mkdir -p "$BACKUP_DIR"
    [ -f "$GLOBAL_DIR/CLAUDE.md" ]            && cp "$GLOBAL_DIR/CLAUDE.md"   "$BACKUP_DIR/CLAUDE.md"
    [ -f "$GLOBAL_DIR/framework-source-path" ] && cp "$GLOBAL_DIR/framework-source-path" "$BACKUP_DIR/framework-source-path"
    for d in rules skills agents; do
        if [ -d "$GLOBAL_DIR/$d" ]; then
            cp -R "$GLOBAL_DIR/$d" "$BACKUP_DIR/$d"
        fi
    done
    log_success "Backup created"
fi

# === Ensure target dirs ===
run mkdir -p "$GLOBAL_DIR/rules" "$GLOBAL_DIR/skills" "$GLOBAL_DIR/agents"

# === Add content rules (additive) ===
log_info "Installing content rules..."
for f in content-pipeline.md content-quality.md source-management.md content-formats.md content-commit-policy.md; do
    src="$FRAMEWORK_DIR/templates/content/rules/$f"
    dst="$GLOBAL_DIR/rules/$f"
    if [ -f "$dst" ]; then
        log_warning "Exists:  rules/$f (not overwritten)"
    elif [ -f "$src" ]; then
        run cp "$src" "$dst"
        log_success "Added:   rules/$f"
    fi
done

# === Add code-only skills not present globally ===
log_info "Installing code-only skills..."
for d in db-migrate playwright; do
    src="$FRAMEWORK_DIR/.claude/skills/$d"
    dst="$GLOBAL_DIR/skills/$d"
    if [ -d "$dst" ]; then
        log_warning "Exists:  skills/$d/ (not overwritten)"
    elif [ -d "$src" ]; then
        run cp -R "$src" "$dst"
        log_success "Added:   skills/$d/"
    fi
done

# === Add content skills (housekeeping replaced with content-version) ===
log_info "Installing content skills..."
for d in research outline write-content review-content enrich content-index; do
    src="$FRAMEWORK_DIR/templates/content/skills/$d"
    dst="$GLOBAL_DIR/skills/$d"
    if [ -d "$dst" ]; then
        log_warning "Exists:  skills/$d/ (not overwritten)"
    elif [ -d "$src" ]; then
        run cp -R "$src" "$dst"
        log_success "Added:   skills/$d/"
    fi
done

# Housekeeping: replace with content-version (broader coverage)
src="$FRAMEWORK_DIR/templates/content/skills/housekeeping"
dst="$GLOBAL_DIR/skills/housekeeping"
if [ -d "$src" ]; then
    if [ -d "$dst" ]; then
        log_info "Replacing skills/housekeeping/ with content-version (old version backed up)"
        # Backup is already in $BACKUP_DIR/skills/housekeeping
        run rm -rf "$dst"
    fi
    run cp -R "$src" "$dst"
    log_success "Installed: skills/housekeeping/ (content-aware, universal)"
fi

# === Install /setup-project bootstrap skill ===
log_info "Installing /setup-project skill..."
src="$FRAMEWORK_DIR/templates/global/skills/setup-project"
dst="$GLOBAL_DIR/skills/setup-project"
if [ -d "$src" ]; then
    if [ -d "$dst" ]; then
        run rm -rf "$dst"
    fi
    run cp -R "$src" "$dst"
    log_success "Installed: skills/setup-project/ (framework bootstrap)"
fi

# Clean up old name if it was installed by an earlier version
if [ -d "$GLOBAL_DIR/skills/init" ] && [ -f "$GLOBAL_DIR/skills/init/SKILL.md" ]; then
    if grep -q "Установить Claude Code Starter framework" "$GLOBAL_DIR/skills/init/SKILL.md" 2>/dev/null; then
        run rm -rf "$GLOBAL_DIR/skills/init"
        log_info "Removed legacy skills/init/ (renamed to setup-project/)"
    fi
fi

# === Add content agents ===
log_info "Installing content agents..."
for a in writer editor; do
    src="$FRAMEWORK_DIR/templates/content/agents/$a"
    dst="$GLOBAL_DIR/agents/$a"
    if [ -d "$dst" ]; then
        log_warning "Exists:  agents/$a/ (not overwritten)"
    elif [ -d "$src" ]; then
        run cp -R "$src" "$dst"
        log_success "Added:   agents/$a/"
    fi
done

# Content reviewer goes under a dedicated name to coexist with code reviewer
src="$FRAMEWORK_DIR/templates/content/agents/reviewer/reviewer.md"
dst_dir="$GLOBAL_DIR/agents/content-reviewer"
dst="$dst_dir/content-reviewer.md"
if [ -f "$dst" ]; then
    log_warning "Exists:  agents/content-reviewer/ (not overwritten)"
elif [ -f "$src" ]; then
    run mkdir -p "$dst_dir"
    if [ "$DRY_RUN" = "0" ]; then
        # Rewrite frontmatter name to "content-reviewer" so it doesn't shadow code reviewer
        awk '
            BEGIN { in_fm = 0; fm_count = 0 }
            /^---$/ { fm_count++; print; if (fm_count == 1) in_fm = 1; else in_fm = 0; next }
            in_fm && /^name:/ { print "name: content-reviewer"; next }
            { print }
        ' "$src" > "$dst"
    else
        echo "  [dry-run] write content-reviewer.md with name: content-reviewer"
    fi
    log_success "Added:   agents/content-reviewer/"
fi

# === Merge global CLAUDE.md with addendum ===
log_info "Merging global CLAUDE.md with framework addendum..."
addendum="$FRAMEWORK_DIR/templates/global/CLAUDE.addendum.md"
target="$GLOBAL_DIR/CLAUDE.md"

if [ ! -f "$addendum" ]; then
    log_warning "No addendum found at $addendum — skipping CLAUDE.md merge"
elif [ ! -f "$target" ]; then
    # No existing global CLAUDE.md → just install addendum as-is
    run cp "$addendum" "$target"
    log_success "Installed: CLAUDE.md (from addendum)"
elif [ ! -f "$MERGER" ]; then
    log_warning "Merger not found at $MERGER — skipping CLAUDE.md merge"
    log_warning "Addendum left at $addendum for manual merge if desired"
else
    if [ "$DRY_RUN" = "0" ]; then
        if python3 "$MERGER" check "$target" "$addendum" >/dev/null 2>&1; then
            python3 "$MERGER" merge "$target" "$addendum" > "$target.merged.tmp"
            mv "$target.merged.tmp" "$target"
            log_success "Merged:  CLAUDE.md (additive)"
        else
            python3 "$MERGER" propose "$target" "$addendum" > "$GLOBAL_DIR/CLAUDE.md.merge-proposal.md"
            log_warning "Hard conflict in global CLAUDE.md — proposal at $GLOBAL_DIR/CLAUDE.md.merge-proposal.md"
            log_warning "CLAUDE.md NOT modified. Review and apply manually."
        fi
    else
        echo "  [dry-run] merge $target with $addendum"
    fi
fi

# === Record framework source path ===
log_info "Recording framework source path..."
run sh -c "echo '$FRAMEWORK_DIR' > '$GLOBAL_DIR/framework-source-path'"
log_success "Source path: $FRAMEWORK_DIR"

# === Summary ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Global framework layer installed.${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Backup:        $BACKUP_DIR"
echo "Source path:   $GLOBAL_DIR/framework-source-path → $FRAMEWORK_DIR"
echo ""
echo "Test it:"
echo "  mkdir /tmp/test-setup && cd /tmp/test-setup"
echo "  # Open Claude Code here, then say: /setup-project"
echo "  # (or just \"новый проект\" / \"поставь фреймворк\")"
echo ""
echo "Rollback if needed:"
echo "  bash $SCRIPT_DIR/install-global.sh --rollback"
