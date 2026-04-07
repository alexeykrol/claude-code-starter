#!/bin/bash
# Post-Tool-Use Checkpoint
# Запускается после каждого tool call.
# Считает вызовы. Каждые 20 — проверяет незакоммиченные изменения.
# Лёгкий: если порог не достигнут — выход за <10ms.

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
COUNTER_FILE="$PROJECT_DIR/.claude/.tool-counter"
CHECKPOINT_INTERVAL=20

# Инкремент счётчика (атомарно через файл в проекте, не /tmp)
if [ -f "$COUNTER_FILE" ]; then
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
    COUNT=$((COUNT + 1))
else
    mkdir -p "$(dirname "$COUNTER_FILE")"
    COUNT=1
fi
echo "$COUNT" > "$COUNTER_FILE"

# Проверка порога
if [ $((COUNT % CHECKPOINT_INTERVAL)) -ne 0 ]; then
    exit 0
fi

# === Checkpoint reached ===

# Проверить git только если это git-репо
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$DIRTY" -gt 0 ]; then
    echo ""
    echo "⚡ CHECKPOINT ($COUNT tool calls): $DIRTY uncommitted files."
    echo "→ Commit changes now and update SNAPSHOT.md"
    echo ""
fi
