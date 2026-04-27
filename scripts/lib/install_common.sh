#!/bin/bash
#
# Claude Code Starter — Shared install/migration library
# Version: 6.1.0
#
# Общая библиотека функций для install (init-project.sh) и migration (migrate.sh).
# Caller'ы делают `source` этого файла, парсят аргументы и вызывают функции.
#
# Соглашения:
# - В этом файле ТОЛЬКО определения функций + общая конфигурация (цвета, timestamp).
# - Никакого set -e — это решает caller.
# - Никакого парсинга аргументов или dispatch — это решает caller.
# - Caller обязан задать перед вызовом функций следующие переменные:
#     SCRIPT_DIR        — каталог запуска скрипта-caller'а
#     TEMPLATE_DIR      — корень framework checkout (по умолчанию SCRIPT_DIR/..)
#     PROJECT_DIR       — корень целевого проекта (обычно $(pwd))
#     PROJECT_NAME      — имя проекта
#     PROJECT_TYPE      — code | content | hybrid
#     CONTENT_TYPE      — book | course | knowledge-base | documents | transcripts | mixed (опционально)
#     MODE              — install | migrate | rollback | apply-proposal
#     FORCE             — 0 | 1
#

# === Common Config ===
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BACKUP_TAG=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR=""

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

# CONTENT_TEMPLATE_DIR и MERGER_PY вычисляем лениво через геттеры,
# потому что TEMPLATE_DIR может быть переопределён caller'ом после source.
content_template_dir() { echo "$TEMPLATE_DIR/templates/content"; }
merger_py()            { echo "$SCRIPT_DIR/lib/merge_claude_md.py"; }

# Возвращает путь к шаблону CLAUDE.md в зависимости от PROJECT_TYPE.
# Для hybrid берём content (он шире и включает code-секции по convention).
claude_md_template_for_type() {
    local ct
    ct="$(content_template_dir)"
    case "$PROJECT_TYPE" in
        content)
            if [ -f "$ct/CLAUDE.md" ]; then
                echo "$ct/CLAUDE.md"
            else
                echo "$TEMPLATE_DIR/CLAUDE.md"
            fi
            ;;
        hybrid)
            if [ -f "$ct/CLAUDE.md" ]; then
                echo "$ct/CLAUDE.md"
            else
                echo "$TEMPLATE_DIR/CLAUDE.md"
            fi
            ;;
        *)
            echo "$TEMPLATE_DIR/CLAUDE.md"
            ;;
    esac
}

# ============================================================================
# Helper functions
# ============================================================================

# Создаёт директорию, если её нет.
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_success "Created: $1"
    fi
}

# Копирует файл, если целевого файла ещё нет (или установлен FORCE).
copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$src" ]; then
        return 0
    fi
    if [ ! -f "$dst" ] || [ "$FORCE" = "1" ]; then
        cp "$src" "$dst"
        log_success "Created: $dst"
    else
        log_warning "Exists:  $dst (not overwritten)"
    fi
}

# Копирует файл с backup'ом существующего и принудительной перезаписью.
copy_with_backup() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$src" ]; then
        return 0
    fi
    if [ -f "$dst" ]; then
        local rel="${dst#./}"
        local bdst="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$bdst")"
        cp "$dst" "$bdst"
    fi
    cp "$src" "$dst"
    log_success "Installed (with backup): $dst"
}

# Подставляет плейсхолдеры в файл: {{PROJECT_NAME}}, {{DATE}}, {{CONTENT_TYPE}}.
# Остальные плейсхолдеры остаются как есть — пользователь заполнит вручную.
substitute_placeholders() {
    local src="$1"
    local dst="$2"
    awk -v name="$PROJECT_NAME" -v date="$TIMESTAMP" -v ctype="$CONTENT_TYPE" '
        BEGIN {
            gsub(/&/, "\\\\&", name)
            gsub(/&/, "\\\\&", date)
            gsub(/&/, "\\\\&", ctype)
        }
        {
            gsub(/\{\{PROJECT_NAME\}\}/, name)
            gsub(/\{\{DATE\}\}/, date)
            gsub(/\{\{CONTENT_TYPE\}\}/, ctype)
            print
        }
    ' "$src" > "$dst"
}

# ============================================================================
# Git detection
# ============================================================================

# Проверяет наличие .git и при необходимости предлагает инициализацию.
detect_git() {
    if [ -d ".git" ]; then
        return 0
    fi

    log_warning "No .git directory found in $PROJECT_DIR"

    if [ -t 0 ] && [ -t 1 ]; then
        read -p "Initialize git repository? [Y/n]: " answer
        answer="${answer:-Y}"
        if [[ "$answer" =~ ^[Yy] ]]; then
            git init -q
            log_success "Initialized git repository"
        else
            log_warning "Skipped git init — framework will work, but no version control"
        fi
    else
        log_warning "Non-interactive shell; skipping git init. Run 'git init' manually if needed."
    fi
}

# ============================================================================
# Project type detection
# ============================================================================

# Считает количество content и code файлов в проекте, определяет project_type.
# Возвращает одно из: code, content, hybrid, unknown.
detect_project_type() {
    # Если папка свежая, ничего нет — unknown
    local total_files
    total_files=$(find . -maxdepth 4 -type f \
        -not -path './.git/*' \
        -not -path './node_modules/*' \
        -not -path './.venv/*' \
        -not -path './venv/*' \
        -not -path './dist/*' \
        -not -path './build/*' \
        -not -path './.claude/*' \
        2>/dev/null | wc -l | tr -d ' ')

    if [ "$total_files" -lt 3 ]; then
        echo "unknown"
        return 0
    fi

    local content_count code_count manifest_count
    content_count=$(find . -maxdepth 4 -type f \
        \( -name '*.md' -o -name '*.txt' -o -name '*.rst' -o -name '*.adoc' \
           -o -name '*.pdf' -o -name '*.docx' -o -name '*.doc' -o -name '*.pptx' \) \
        -not -path './.git/*' \
        -not -path './node_modules/*' \
        -not -path './.venv/*' \
        -not -path './venv/*' \
        -not -path './dist/*' \
        -not -path './build/*' \
        -not -path './.claude/*' \
        2>/dev/null | wc -l | tr -d ' ')

    code_count=$(find . -maxdepth 4 -type f \
        \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' \
           -o -name '*.go' -o -name '*.rs' -o -name '*.php' -o -name '*.sh' -o -name '*.rb' \
           -o -name '*.java' -o -name '*.cs' -o -name '*.swift' -o -name '*.kt' \) \
        -not -path './.git/*' \
        -not -path './node_modules/*' \
        -not -path './.venv/*' \
        -not -path './venv/*' \
        -not -path './dist/*' \
        -not -path './build/*' \
        -not -path './.claude/*' \
        2>/dev/null | wc -l | tr -d ' ')

    manifest_count=0
    [ -f "package.json" ]   && manifest_count=$((manifest_count + 1))
    [ -f "pyproject.toml" ] && manifest_count=$((manifest_count + 1))
    [ -f "Cargo.toml" ]     && manifest_count=$((manifest_count + 1))
    [ -f "composer.json" ]  && manifest_count=$((manifest_count + 1))
    [ -f "go.mod" ]         && manifest_count=$((manifest_count + 1))

    local content_dirs_score=0
    for d in content chapters lessons modules courses docs source briefs bible drafts templates transcripts assets articles; do
        [ -d "$d" ] && content_dirs_score=$((content_dirs_score + 1))
    done

    local code_dirs_score=0
    for d in src lib app pages components tests e2e migrations infra; do
        [ -d "$d" ] && code_dirs_score=$((code_dirs_score + 1))
    done

    local has_content_entry=0
    [ -f "INDEX.md" ] && has_content_entry=1
    [ -d "chapters" ] && has_content_entry=1
    [ -d "content" ]  && has_content_entry=1
    [ -d "docs" ]     && has_content_entry=1

    local has_code_manifest=0
    [ "$manifest_count" -gt 0 ] && has_code_manifest=1

    local total_signal=$((content_count + code_count))
    local content_ratio_pct=0
    local code_ratio_pct=0

    if [ "$total_signal" -gt 0 ]; then
        content_ratio_pct=$(( (content_count * 100) / total_signal ))
        code_ratio_pct=$(( (code_count * 100) / total_signal ))
    fi

    # Логи в stderr, чтобы не сломать stdout-возврат
    {
        echo "  scan: content=$content_count code=$code_count" \
             "content_dirs=$content_dirs_score code_dirs=$code_dirs_score" \
             "content_ratio=${content_ratio_pct}% code_ratio=${code_ratio_pct}%" \
             "manifest=$has_code_manifest content_entry=$has_content_entry"
    } >&2

    # Унknown сигналов очень мало
    if [ "$total_signal" -lt 10 ] && [ "$content_dirs_score" -lt 2 ] && [ "$code_dirs_score" -lt 2 ]; then
        echo "unknown"
        return 0
    fi

    # Hybrid: оба сильные
    if [ "$content_ratio_pct" -ge 20 ] && [ "$code_ratio_pct" -ge 20 ]; then
        echo "hybrid"
        return 0
    fi
    if [ "$content_dirs_score" -ge 2 ] && [ "$code_dirs_score" -ge 2 ]; then
        echo "hybrid"
        return 0
    fi
    if [ "$has_code_manifest" = "1" ] && [ "$content_dirs_score" -ge 2 ]; then
        echo "hybrid"
        return 0
    fi

    # Content
    if [ "$content_ratio_pct" -ge 70 ] && [ "$has_content_entry" = "1" ] \
       && [ "$code_dirs_score" -le 1 ]; then
        echo "content"
        return 0
    fi
    if [ "$content_dirs_score" -ge 3 ] && [ "$code_dirs_score" -le 1 ] \
       && [ "$has_code_manifest" = "0" ]; then
        echo "content"
        return 0
    fi

    # Code
    if [ "$code_ratio_pct" -ge 70 ] && [ "$has_code_manifest" = "1" ]; then
        echo "code"
        return 0
    fi
    if [ "$code_dirs_score" -ge 2 ] && [ "$has_code_manifest" = "1" ] \
       && [ "$content_dirs_score" -le 1 ]; then
        echo "code"
        return 0
    fi

    # Дефолт: нет уверенного сигнала
    echo "unknown"
}

# Определяет content_type на основе структуры папок.
# Возвращает: book, course, knowledge-base, documents, transcripts, mixed.
detect_content_type() {
    local has_chapters=0 has_briefs=0 has_bible=0
    local has_modules=0 has_lessons=0 has_lesson_files=0
    local has_articles=0 has_index=0
    local has_docs_only=0
    local has_section_dirs=0 has_screenshots=0 has_lecture_files=0

    [ -d "chapters" ]    && has_chapters=1
    [ -d "briefs" ]      && has_briefs=1
    [ -d "bible" ]       && has_bible=1
    [ -d "modules" ]     && has_modules=1
    [ -d "lessons" ]     && has_lessons=1
    [ -d "articles" ]    && has_articles=1
    [ -f "INDEX.md" ]    && has_index=1
    [ -d "screenshots" ] && has_screenshots=1

    # lesson-* files (anywhere depth 4)
    has_lesson_files=$(find . -maxdepth 4 -type f -name 'lesson-*.md' \
        -not -path './.claude/*' 2>/dev/null | head -1 | wc -l | tr -d ' ')

    # Section-NN dirs
    has_section_dirs=$(find . -maxdepth 3 -type d -name 'Section-*' \
        -not -path './.claude/*' 2>/dev/null | head -1 | wc -l | tr -d ' ')

    # *-Lecture-* files
    has_lecture_files=$(find . -maxdepth 4 -type f -name '*Lecture-*.md' \
        -not -path './.claude/*' 2>/dev/null | head -1 | wc -l | tr -d ' ')

    # docs/ без chapters/, modules/
    if [ -d "docs" ] && [ "$has_chapters" = "0" ] && [ "$has_modules" = "0" ] \
       && [ "$has_lessons" = "0" ] && [ "$has_articles" = "0" ]; then
        has_docs_only=1
    fi

    if [ "$has_section_dirs" -ge 1 ] || [ "$has_lecture_files" -ge 1 ] \
       || ([ "$has_screenshots" = "1" ] && [ "$has_section_dirs" -ge 1 ]); then
        echo "transcripts"
        return 0
    fi

    if [ "$has_chapters" = "1" ] || [ "$has_briefs" = "1" ] || [ "$has_bible" = "1" ]; then
        echo "book"
        return 0
    fi

    if [ "$has_modules" = "1" ] || [ "$has_lessons" = "1" ] || [ "$has_lesson_files" -ge 1 ]; then
        echo "course"
        return 0
    fi

    if [ "$has_articles" = "1" ] || ([ "$has_index" = "1" ] && [ -d "categories" ]); then
        echo "knowledge-base"
        return 0
    fi

    if [ "$has_docs_only" = "1" ]; then
        echo "documents"
        return 0
    fi

    echo "mixed"
}

# ============================================================================
# Backup / rollback
# ============================================================================

# Создаёт snapshot текущих файлов, которые могут быть изменены установкой.
backup_existing() {
    BACKUP_DIR=".claude/backup-$BACKUP_TAG"
    mkdir -p "$BACKUP_DIR"

    local files_backed_up=()

    if [ -f "CLAUDE.md" ]; then
        cp "CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
        files_backed_up+=("CLAUDE.md")
    fi
    if [ -f ".claude/settings.json" ]; then
        cp ".claude/settings.json" "$BACKUP_DIR/settings.json"
        files_backed_up+=(".claude/settings.json")
    fi
    if [ -f ".claude/SNAPSHOT.md" ]; then
        cp ".claude/SNAPSHOT.md" "$BACKUP_DIR/SNAPSHOT.md"
        files_backed_up+=(".claude/SNAPSHOT.md")
    fi
    if [ -f "manifest.md" ]; then
        cp "manifest.md" "$BACKUP_DIR/manifest.md"
        files_backed_up+=("manifest.md")
    fi
    if [ -f ".gitignore" ]; then
        cp ".gitignore" "$BACKUP_DIR/.gitignore"
        files_backed_up+=(".gitignore")
    fi

    {
        echo "Backup created: $(date)"
        echo "Mode: $MODE"
        echo "Project type: $PROJECT_TYPE"
        echo "Content type: $CONTENT_TYPE"
        echo "Files backed up:"
        if [ ${#files_backed_up[@]} -eq 0 ]; then
            echo "  (none — fresh install)"
        else
            for f in "${files_backed_up[@]}"; do
                echo "  $f"
            done
        fi
    } > "$BACKUP_DIR/manifest.txt"

    if [ ${#files_backed_up[@]} -gt 0 ]; then
        log_info "Backed up ${#files_backed_up[@]} file(s) to $BACKUP_DIR"
    fi
}

# Восстанавливает файлы из последнего backup (.claude/backup-*).
rollback() {
    if [ ! -d ".claude" ]; then
        log_error "No .claude/ directory found — nothing to rollback"
        exit 1
    fi

    local last_backup
    last_backup=$(find .claude -maxdepth 1 -type d -name 'backup-*' 2>/dev/null \
        | sort | tail -1)

    if [ -z "$last_backup" ]; then
        log_error "No backup found in .claude/backup-*"
        exit 1
    fi

    log_info "Rolling back from: $last_backup"

    local restored=0

    if [ -f "$last_backup/CLAUDE.md" ]; then
        cp "$last_backup/CLAUDE.md" "CLAUDE.md"
        log_success "Restored: CLAUDE.md"
        restored=$((restored + 1))
    fi
    if [ -f "$last_backup/settings.json" ]; then
        cp "$last_backup/settings.json" ".claude/settings.json"
        log_success "Restored: .claude/settings.json"
        restored=$((restored + 1))
    fi
    if [ -f "$last_backup/SNAPSHOT.md" ]; then
        cp "$last_backup/SNAPSHOT.md" ".claude/SNAPSHOT.md"
        log_success "Restored: .claude/SNAPSHOT.md"
        restored=$((restored + 1))
    fi
    if [ -f "$last_backup/manifest.md" ]; then
        cp "$last_backup/manifest.md" "manifest.md"
        log_success "Restored: manifest.md"
        restored=$((restored + 1))
    fi
    if [ -f "$last_backup/.gitignore" ]; then
        cp "$last_backup/.gitignore" ".gitignore"
        log_success "Restored: .gitignore"
        restored=$((restored + 1))
    fi

    log_success "Rollback complete — restored $restored file(s)"
    log_info "Backup directory preserved: $last_backup"
}

# Применяет CLAUDE.md.merge-proposal.md.
# MVP: вызывает merger Python с режимом apply-proposal, если он поддерживает,
# иначе печатает инструкцию для ручного резолвинга.
apply_proposal() {
    local proposal=".claude/CLAUDE.md.merge-proposal.md"
    local merger
    merger="$(merger_py)"

    if [ ! -f "$proposal" ]; then
        log_error "Proposal file not found: $proposal"
        exit 1
    fi

    if [ ! -f "$merger" ]; then
        log_warning "Merger script not available at $merger"
        log_info "Manual resolution needed: edit CLAUDE.md based on $proposal"
        return 0
    fi

    if python3 "$merger" apply-proposal "CLAUDE.md" "$proposal" > "CLAUDE.md.merged.tmp" 2>/dev/null; then
        # Бэкапим текущий CLAUDE.md в свежий backup
        BACKUP_DIR=".claude/backup-$BACKUP_TAG"
        mkdir -p "$BACKUP_DIR"
        [ -f "CLAUDE.md" ] && cp "CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
        mv "CLAUDE.md.merged.tmp" "CLAUDE.md"
        log_success "Applied proposal to CLAUDE.md (backup at $BACKUP_DIR)"
        rm -f "$proposal"
    else
        rm -f "CLAUDE.md.merged.tmp"
        log_warning "Merger does not support apply-proposal yet (MVP)"
        log_info "Manual resolution needed: edit CLAUDE.md based on $proposal"
    fi
}

# ============================================================================
# CLAUDE.md merging
# ============================================================================

# Аддитивно сливает существующий CLAUDE.md с template.
# При hard conflict генерирует merge-proposal и завершает работу с exit 2.
merge_claude_md() {
    local existing="$1"
    local template="$2"
    local merger
    merger="$(merger_py)"

    if [ ! -f "$template" ]; then
        log_warning "Template CLAUDE.md not found: $template (skipping)"
        return 0
    fi

    # Нет существующего — просто подставляем плейсхолдеры
    if [ ! -f "$existing" ]; then
        substitute_placeholders "$template" "$existing"
        log_success "Created: $existing"
        return 0
    fi

    # Если merger недоступен (параллельный агент ещё не отработал) — fallback
    if [ ! -f "$merger" ]; then
        log_warning "Merger not available — keeping existing $existing untouched"
        log_info "Template available at: $template"
        log_info "After $merger appears, rerun installer or merge manually"
        return 0
    fi

    # Проверка конфликтов
    if python3 "$merger" check "$existing" "$template" >/dev/null 2>&1; then
        # Чистый merge
        if python3 "$merger" merge "$existing" "$template" > "$existing.merged.tmp" 2>/dev/null; then
            substitute_placeholders "$existing.merged.tmp" "$existing.subst.tmp"
            mv "$existing.subst.tmp" "$existing"
            rm -f "$existing.merged.tmp"
            log_success "$existing merged additively"
        else
            rm -f "$existing.merged.tmp"
            log_warning "Merger failed — keeping existing $existing"
        fi
    else
        # Hard conflict — proposal
        mkdir -p ".claude"
        python3 "$merger" propose "$existing" "$template" \
            > ".claude/CLAUDE.md.merge-proposal.md" 2>/dev/null || true
        log_error "Hard conflict in CLAUDE.md detected."
        log_info "See .claude/CLAUDE.md.merge-proposal.md"
        log_info "To apply proposed resolution: rerun with --apply-proposal"
        log_info "To rollback all changes:    rerun with --rollback"
        log_info "Files NOT modified. Backup at $BACKUP_DIR"
        exit 2
    fi
}

# ============================================================================
# Manifest generation
# ============================================================================

# Генерирует manifest.md с расширенными полями (project_type, content_type).
generate_manifest() {
    local target="manifest.md"

    if [ -f "$target" ]; then
        log_warning "Exists:  $target (not overwritten)"
        return 0
    fi

    cat > "$target" <<EOF
project_name=$PROJECT_NAME
repo_access=private-solo
project_type=$PROJECT_TYPE
content_type=$CONTENT_TYPE
EOF
    log_success "Created: $target"
}

# ============================================================================
# Common installation (any project type)
# ============================================================================

# Устанавливает общие файлы — каркас, не зависящий от типа проекта.
install_common() {
    log_info "Installing common framework files..."

    # Каркас директорий
    create_dir ".claude"
    create_dir ".claude/rules"
    create_dir ".claude/hooks"
    create_dir ".claude/logs/sessions"
    create_dir ".claude/logs/migrations"
    create_dir ".claude/logs/errors"
    create_dir "scripts"

    # Hooks
    copy_if_missing "$TEMPLATE_DIR/.claude/hooks/pre-compact.sh"         ".claude/hooks/pre-compact.sh"
    copy_if_missing "$TEMPLATE_DIR/.claude/hooks/post-compact.sh"        ".claude/hooks/post-compact.sh"
    copy_if_missing "$TEMPLATE_DIR/.claude/hooks/post-tool-checkpoint.sh" ".claude/hooks/post-tool-checkpoint.sh"
    copy_if_missing "$TEMPLATE_DIR/.claude/hooks/subagent-done.sh"       ".claude/hooks/subagent-done.sh"
    chmod +x .claude/hooks/*.sh 2>/dev/null || true

    # Helper scripts
    copy_if_missing "$TEMPLATE_DIR/scripts/framework-state-mode.sh" "scripts/framework-state-mode.sh"
    copy_if_missing "$TEMPLATE_DIR/scripts/switch-repo-access.sh"   "scripts/switch-repo-access.sh"
    chmod +x scripts/*.sh 2>/dev/null || true

    # settings.json — copy / merge hooks
    install_settings_json

    # .gitignore — merge missing entries
    install_gitignore

    # Universal rules (всегда)
    for rule in autonomy delegation context-management production-safety local-first logging; do
        copy_if_missing "$TEMPLATE_DIR/.claude/rules/${rule}.md" ".claude/rules/${rule}.md"
    done
}

# Устанавливает settings.json: создаёт или мержит секцию hooks.
install_settings_json() {
    if [ ! -f ".claude/settings.json" ]; then
        if [ -f "$TEMPLATE_DIR/.claude/settings.json" ]; then
            cp "$TEMPLATE_DIR/.claude/settings.json" ".claude/settings.json"
            log_success "Created: .claude/settings.json"
        fi
        return 0
    fi

    local merge_needed
    merge_needed=$(python3 -c "
import json, sys
try:
    with open('.claude/settings.json') as f:
        existing = json.load(f)
    with open('$TEMPLATE_DIR/.claude/settings.json') as f:
        template = json.load(f)
    t_hooks = template.get('hooks', {})
    e_hooks = existing.get('hooks', {})
    missing = [k for k in t_hooks if k not in e_hooks]
    print('yes' if missing else 'no')
except Exception as e:
    print('error:' + str(e), file=sys.stderr)
    print('no')
" 2>/dev/null)

    if [ "$merge_needed" = "yes" ]; then
        python3 -c "
import json
with open('.claude/settings.json') as f:
    existing = json.load(f)
with open('$TEMPLATE_DIR/.claude/settings.json') as f:
    template = json.load(f)
t_hooks = template.get('hooks', {})
e_hooks = existing.get('hooks', {})
for key, val in t_hooks.items():
    if key not in e_hooks:
        e_hooks[key] = val
existing['hooks'] = e_hooks
with open('.claude/settings.json', 'w') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
" 2>/dev/null && log_success "Updated: .claude/settings.json (merged missing hooks)" \
        || log_error "Failed to merge hooks into .claude/settings.json"
    else
        log_warning "Exists:  .claude/settings.json (hooks up to date)"
    fi

    if [ ! -f ".claude/settings.local.json" ]; then
        log_info "Tip: For full autonomy, create .claude/settings.local.json with bypassPermissions:true"
    fi
}

# Устанавливает или обновляет .gitignore.
install_gitignore() {
    if [ ! -f ".gitignore" ]; then
        if [ -f "$TEMPLATE_DIR/.gitignore" ]; then
            cp "$TEMPLATE_DIR/.gitignore" ".gitignore"
            log_success "Created: .gitignore"
        fi
        return 0
    fi

    if [ ! -f "$TEMPLATE_DIR/.gitignore" ]; then
        return 0
    fi

    local added=0
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
}

# ============================================================================
# Code installation (стандартный путь, как раньше)
# ============================================================================

# Устанавливает code-template: code-rules, code-skills, code-agents.
install_code() {
    log_info "Installing code framework..."

    # Code skills
    create_dir ".claude/skills/start"
    create_dir ".claude/skills/finish"
    create_dir ".claude/skills/testing"
    create_dir ".claude/skills/playwright"
    create_dir ".claude/skills/db-migrate"
    create_dir ".claude/skills/housekeeping"

    # Code agents
    create_dir ".claude/agents/researcher"
    create_dir ".claude/agents/implementer"
    create_dir ".claude/agents/reviewer"

    # Code rules
    copy_if_missing "$TEMPLATE_DIR/.claude/rules/commit-policy.md" ".claude/rules/commit-policy.md"

    # Skills
    for skill in start finish testing playwright db-migrate housekeeping; do
        copy_if_missing "$TEMPLATE_DIR/.claude/skills/${skill}/SKILL.md" \
                        ".claude/skills/${skill}/SKILL.md"
    done

    # Agents
    for agent in researcher implementer reviewer; do
        copy_if_missing "$TEMPLATE_DIR/.claude/agents/${agent}/${agent}.md" \
                        ".claude/agents/${agent}/${agent}.md"
    done

    # SNAPSHOT.md
    if [ ! -f ".claude/SNAPSHOT.md" ]; then
        if [ -f "$TEMPLATE_DIR/.claude/SNAPSHOT.md" ]; then
            substitute_placeholders "$TEMPLATE_DIR/.claude/SNAPSHOT.md" ".claude/SNAPSHOT.md"
            log_success "Created: .claude/SNAPSHOT.md"
        fi
    else
        log_warning "Exists:  .claude/SNAPSHOT.md (not overwritten)"
    fi
}

# ============================================================================
# Content installation
# ============================================================================

# Устанавливает content-template: content-rules, content-skills, content-agents,
# content-templates, опциональный starter каркас по content_type.
install_content() {
    log_info "Installing content framework..."

    local ct
    ct="$(content_template_dir)"

    if [ ! -d "$ct" ]; then
        log_error "Content template directory not found: $ct"
        log_info "Make sure templates/content/ exists in framework checkout."
        log_info "If parallel installation is in progress — wait and rerun."
        exit 3
    fi

    # Skills и agents — структура
    for skill in research outline write-content review-content enrich content-index housekeeping; do
        create_dir ".claude/skills/${skill}"
    done

    for agent in researcher writer editor reviewer; do
        create_dir ".claude/agents/${agent}"
    done

    create_dir "templates"

    # Content rules
    if [ -d "$ct/rules" ]; then
        for rf in "$ct/rules"/*.md; do
            [ -f "$rf" ] || continue
            local base
            base=$(basename "$rf")
            # content-commit-policy → ставится как основной commit-policy в content-mode
            if [ "$base" = "content-commit-policy.md" ]; then
                copy_if_missing "$rf" ".claude/rules/commit-policy.md"
            else
                copy_if_missing "$rf" ".claude/rules/${base}"
            fi
        done
    fi

    # Content skills
    if [ -d "$ct/skills" ]; then
        for sdir in "$ct/skills"/*/; do
            [ -d "$sdir" ] || continue
            local sname
            sname=$(basename "$sdir")
            create_dir ".claude/skills/${sname}"
            if [ -f "$sdir/SKILL.md" ]; then
                # housekeeping в content-mode заменяет code-версию (с backup)
                if [ "$sname" = "housekeeping" ] && [ -f ".claude/skills/housekeeping/SKILL.md" ]; then
                    copy_with_backup "$sdir/SKILL.md" ".claude/skills/housekeeping/SKILL.md"
                else
                    copy_if_missing "$sdir/SKILL.md" ".claude/skills/${sname}/SKILL.md"
                fi
            fi
        done
    fi

    # Content agents — writer, editor, content-reviewer
    for agent in writer editor; do
        local src="$ct/agents/${agent}/${agent}.md"
        if [ -f "$src" ]; then
            copy_if_missing "$src" ".claude/agents/${agent}/${agent}.md"
        fi
    done

    # reviewer — content-версия (если есть конфликт с code-reviewer — backup)
    local content_reviewer_src="$ct/agents/reviewer/reviewer.md"
    if [ -f "$content_reviewer_src" ]; then
        if [ -f ".claude/agents/reviewer/reviewer.md" ] && [ "$FORCE" = "0" ]; then
            log_warning "Exists:  .claude/agents/reviewer/reviewer.md (content-mode)"
            log_info "Run with --force to replace code-reviewer with content-reviewer"
        else
            copy_with_backup "$content_reviewer_src" ".claude/agents/reviewer/reviewer.md"
        fi
    fi

    # researcher — generic (берём из code-template, он подходит content)
    if [ ! -f ".claude/agents/researcher/researcher.md" ]; then
        copy_if_missing "$TEMPLATE_DIR/.claude/agents/researcher/researcher.md" \
                        ".claude/agents/researcher/researcher.md"
    fi

    # Content templates → templates/ корня проекта
    if [ -d "$ct/content-templates" ]; then
        for tf in "$ct/content-templates"/*.md; do
            [ -f "$tf" ] || continue
            local base
            base=$(basename "$tf")
            copy_if_missing "$tf" "templates/${base}"
        done
    fi

    # Starter structure по content_type
    install_content_starter

    # SNAPSHOT.md (content version)
    if [ ! -f ".claude/SNAPSHOT.md" ]; then
        if [ -f "$ct/SNAPSHOT.md" ]; then
            substitute_placeholders "$ct/SNAPSHOT.md" ".claude/SNAPSHOT.md"
            log_success "Created: .claude/SNAPSHOT.md (content)"
        elif [ -f "$TEMPLATE_DIR/.claude/SNAPSHOT.md" ]; then
            substitute_placeholders "$TEMPLATE_DIR/.claude/SNAPSHOT.md" ".claude/SNAPSHOT.md"
            log_success "Created: .claude/SNAPSHOT.md (fallback)"
        fi
    else
        log_warning "Exists:  .claude/SNAPSHOT.md (not overwritten)"
    fi
}

# Копирует starter-структуру для конкретного content_type, если её ещё нет.
install_content_starter() {
    local ct
    ct="$(content_template_dir)"
    local starter_root="$ct/starter/$CONTENT_TYPE"
    if [ -z "$CONTENT_TYPE" ] || [ "$CONTENT_TYPE" = "mixed" ]; then
        log_info "Skipping starter (no content-type or mixed)"
        return 0
    fi

    if [ ! -d "$starter_root" ]; then
        log_warning "Starter directory not found: $starter_root (skipping)"
        return 0
    fi

    log_info "Installing starter structure for: $CONTENT_TYPE"

    # Сначала: создаём директории (включая пустые)
    (
        cd "$starter_root"
        find . -type d -not -name '.' 2>/dev/null
    ) | while IFS= read -r rel; do
        rel="${rel#./}"
        local dst="./$rel"
        if [ ! -d "$dst" ]; then
            mkdir -p "$dst"
            log_success "Created dir: $dst"
        fi
    done

    # Потом: копируем файлы, которых ещё нет
    (
        cd "$starter_root"
        find . -type f -not -name '.DS_Store' 2>/dev/null
    ) | while IFS= read -r rel; do
        rel="${rel#./}"
        local src="$starter_root/$rel"
        local dst="./$rel"
        if [ ! -f "$dst" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            log_success "Created: $dst"
        else
            log_warning "Exists:  $dst (not overwritten)"
        fi
    done
}

# ============================================================================
# Hybrid installation
# ============================================================================

# Устанавливает code framework + content overlay.
install_hybrid() {
    log_info "Installing hybrid framework (code + content overlay)..."

    local ct
    ct="$(content_template_dir)"

    # Сначала код — стандартный путь
    install_code

    if [ ! -d "$ct" ]; then
        log_warning "Content template not found: $ct"
        log_info "Hybrid mode skipped content overlay; install code-only."
        return 0
    fi

    # Теперь content overlay
    create_dir "templates"

    for skill in research outline write-content review-content enrich content-index; do
        create_dir ".claude/skills/${skill}"
    done

    for agent in writer editor content-reviewer; do
        create_dir ".claude/agents/${agent}"
    done

    # Content rules: ставим всё, кроме content-commit-policy — он остаётся как доп. файл
    if [ -d "$ct/rules" ]; then
        for rf in "$ct/rules"/*.md; do
            [ -f "$rf" ] || continue
            local base
            base=$(basename "$rf")
            # В hybrid: content-commit-policy сохраняется отдельно (как саплимент)
            copy_if_missing "$rf" ".claude/rules/${base}"
        done
    fi

    # Content skills, кроме housekeeping (housekeeping заменяет code-версию)
    if [ -d "$ct/skills" ]; then
        for sdir in "$ct/skills"/*/; do
            [ -d "$sdir" ] || continue
            local sname
            sname=$(basename "$sdir")
            create_dir ".claude/skills/${sname}"
            if [ -f "$sdir/SKILL.md" ]; then
                if [ "$sname" = "housekeeping" ]; then
                    # Hybrid: content-housekeeping универсальнее, заменяем code-версию (backup)
                    copy_with_backup "$sdir/SKILL.md" ".claude/skills/housekeeping/SKILL.md"
                else
                    copy_if_missing "$sdir/SKILL.md" ".claude/skills/${sname}/SKILL.md"
                fi
            fi
        done
    fi

    # Content agents: writer, editor — добавляем
    for agent in writer editor; do
        local src="$ct/agents/${agent}/${agent}.md"
        if [ -f "$src" ]; then
            copy_if_missing "$src" ".claude/agents/${agent}/${agent}.md"
        fi
    done

    # content-reviewer — НЕ заменяет code-reviewer, ставится как content-reviewer
    local content_reviewer_src="$ct/agents/reviewer/reviewer.md"
    if [ -f "$content_reviewer_src" ]; then
        copy_if_missing "$content_reviewer_src" ".claude/agents/content-reviewer/content-reviewer.md"
    fi

    # Content templates → templates/
    if [ -d "$ct/content-templates" ]; then
        for tf in "$ct/content-templates"/*.md; do
            [ -f "$tf" ] || continue
            local base
            base=$(basename "$tf")
            copy_if_missing "$tf" "templates/${base}"
        done
    fi

    # Starter (только если CONTENT_TYPE задан)
    install_content_starter
}

# ============================================================================
# Final summaries
# ============================================================================

# Выводит финальный отчёт об установке (init-project).
print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Готово. Тип: ${PROJECT_TYPE}${CONTENT_TYPE:+ ($CONTENT_TYPE)}. Mode: install.${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo "Backup: $BACKUP_DIR"
        echo "Откат:  bash $0 --rollback"
        echo ""
    fi

    echo "Next steps:"
    echo "  1. Edit CLAUDE.md — заполни плейсхолдеры (если есть)"
    echo "  2. Edit manifest.md — repo_access, project_type, content_type"
    if [ "$PROJECT_TYPE" = "code" ] || [ "$PROJECT_TYPE" = "hybrid" ]; then
        echo "  3. If repo_access is public/private-shared, run scripts/switch-repo-access.sh BEFORE first framework commit"
        echo "  4. Open in Claude Code: /start"
    else
        echo "  3. Open in Claude Code: /start"
    fi
    echo ""
}

# Анализирует существующий проект перед миграцией: показывает что найдено,
# что будет сохранено как есть, какие framework-элементы уже присутствуют.
analyze_existing_project() {
    # Count documentation files (untouched)
    local doc_count
    doc_count=$(find . -maxdepth 3 -type f \( -name '*.md' -o -name '*.txt' -o -name '*.rst' \) \
        -not -path './node_modules/*' -not -path './.venv/*' -not -path './.git/*' \
        -not -path './.claude/*' 2>/dev/null | wc -l | tr -d ' ')

    if [ "$doc_count" -gt 0 ]; then
        log_info "Found $doc_count documentation files (will not be touched)"
    fi

    # Detect existing framework elements
    local framework_elements=""
    [ -f "CLAUDE.md" ]                && framework_elements="$framework_elements CLAUDE.md"
    [ -f ".claude/SNAPSHOT.md" ]      && framework_elements="$framework_elements SNAPSHOT.md"
    [ -f ".claude/settings.json" ]    && framework_elements="$framework_elements settings.json"
    [ -d ".claude/rules" ]            && framework_elements="$framework_elements rules/"
    [ -d ".claude/skills" ]           && framework_elements="$framework_elements skills/"
    [ -d ".claude/agents" ]           && framework_elements="$framework_elements agents/"
    [ -d ".claude/hooks" ]            && framework_elements="$framework_elements hooks/"
    [ -f "manifest.md" ]              && framework_elements="$framework_elements manifest.md"

    if [ -n "$framework_elements" ]; then
        log_info "Existing framework elements:$framework_elements"
        log_info "These will be preserved; only missing pieces will be added"
    else
        log_info "No existing framework — fresh installation"
    fi
}

# Выводит финальный отчёт о миграции.
print_migration_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Migration complete. Type: ${PROJECT_TYPE}${CONTENT_TYPE:+ ($CONTENT_TYPE)}.${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    echo "Preserved (unchanged):"
    echo "  ✓ Existing CLAUDE.md content (merged additively)"
    echo "  ✓ Documentation files in project root"
    echo "  ✓ Project source files"
    echo ""

    echo "Added by framework:"
    echo "  + rules in .claude/rules/"
    echo "  + skills in .claude/skills/"
    echo "  + agents in .claude/agents/"
    echo "  + hooks  in .claude/hooks/"
    [ ! -f "manifest.md.was-here" ] && echo "  + manifest.md (project_type=$PROJECT_TYPE${CONTENT_TYPE:+, content_type=$CONTENT_TYPE})"
    echo ""

    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo "Backup: $BACKUP_DIR"
        echo "Откат:  bash $0 --rollback"
        echo ""
    fi

    echo "Next steps:"
    echo "  1. Review CLAUDE.md — заполни плейсхолдеры (если есть)"
    echo "  2. Edit manifest.md — repo_access"
    if [ "$PROJECT_TYPE" = "code" ] || [ "$PROJECT_TYPE" = "hybrid" ]; then
        echo "  3. If repo_access is public/private-shared, run scripts/switch-repo-access.sh BEFORE next framework commit"
        echo "  4. Open in Claude Code: /start"
    else
        echo "  3. Open in Claude Code: /start"
    fi
    echo ""
}
