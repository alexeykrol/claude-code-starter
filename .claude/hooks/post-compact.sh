#!/bin/bash
# Post-Compaction Recovery Hook
# Вызывается автоматически после compaction контекста.
# Выводит содержимое SNAPSHOT и последние коммиты, чтобы агент восстановил контекст.

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SNAPSHOT="$PROJECT_DIR/.claude/SNAPSHOT.md"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"

echo ""
echo "═══════════════════════════════════════"
echo "  CONTEXT COMPACTED — RECOVERY MODE"
echo "═══════════════════════════════════════"
echo ""

# 1. Вывести SNAPSHOT (агент увидит это в stdout)
if [ -f "$SNAPSHOT" ]; then
    echo "── SNAPSHOT.md ──"
    cat "$SNAPSHOT"
    echo ""
    echo "── end SNAPSHOT ──"
else
    echo "⚠ SNAPSHOT.md not found"
fi

echo ""

# 2. Последние коммиты
echo "── Recent commits ──"
git log --oneline -15 2>/dev/null || echo "(not a git repo)"
echo "── end commits ──"

echo ""

# 3. Текущий git status
DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$DIRTY" -gt 0 ]; then
    echo "⚠ $DIRTY uncommitted files:"
    git status --short 2>/dev/null
    echo ""
fi

echo "NEXT: Read CLAUDE.md to restore project context."
echo "Do NOT start new work until context is restored."
echo "═══════════════════════════════════════"
echo ""
