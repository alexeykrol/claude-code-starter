#!/bin/bash
# Pre-Compaction Hook
# Вызывается автоматически перед compaction контекста.
# Коммитит tracked изменения и обновляет timestamp в SNAPSHOT.
# НЕ обновляет содержательные секции SNAPSHOT — это ответственность агента.

# НЕ используем set -e — скрипт должен выполняться до конца даже при ошибках

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SNAPSHOT="$PROJECT_DIR/.claude/SNAPSHOT.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_HELPER="$PROJECT_DIR/scripts/framework-state-mode.sh"

# Guard: если не git-репо — просто выйти, нечего сохранять через git
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "pre-compact: not a git repo, skipping"
    exit 0
fi

# Shared/public mode is only safe when framework files are already untracked.
# If they are still tracked, stop and surface the blocker instead of creating
# more framework-history commits on the main branch.
if [ -x "$STATE_HELPER" ]; then
    if ! "$STATE_HELPER" check-safe-mode; then
        echo "pre-compact: framework-state mode is unsafe, skipping auto-commit"
        exit 0
    fi
fi

# 1. Коммит изменений в уже отслеживаемых файлах (git add -u).
#    Untracked файлы НЕ добавляются автоматически — это осознанное решение:
#    слепое git add . в хуке может захватить секреты, артефакты сборки и т.д.
#    Агент должен добавлять новые файлы осознанно в рабочем процессе.
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -u
    # Inline git config на случай если у пользователя не настроен user.name/email
    git -c user.name="Claude" -c user.email="claude@local" \
        commit -m "auto: pre-compaction save ($TIMESTAMP)" 2>/dev/null || true
fi

# 2. Обновить timestamp в SNAPSHOT (файл всегда обновляется локально)
if [ -f "$SNAPSHOT" ]; then
    sed -i.bak "s/\*\*Последнее обновление:\*\*.*/\*\*Последнее обновление:\*\* $TIMESTAMP (pre-compaction)/" "$SNAPSHOT" 2>/dev/null || true
    rm -f "$SNAPSHOT.bak"

    if [ -x "$STATE_HELPER" ] && [ "$("$STATE_HELPER" should-commit-framework-state)" = "false" ]; then
        echo "pre-compact: SNAPSHOT kept local due repo_access=$("$STATE_HELPER" repo-access)"
    else
        git add "$SNAPSHOT" 2>/dev/null || true
        git -c user.name="Claude" -c user.email="claude@local" \
            commit -m "auto: update SNAPSHOT before compaction" 2>/dev/null || true
    fi
fi

echo "pre-compact: state saved at $TIMESTAMP"
