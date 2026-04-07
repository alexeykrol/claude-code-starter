#!/bin/bash
# Subagent Done Hook
# Запускается автоматически после завершения любого субагента.
# Это НАПОМИНАНИЕ, не команда. Логика в rules/delegation.md.

# Guard: если не git-репо — не проверять
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$DIRTY" -gt 0 ]; then
    echo ""
    echo "⚡ Subagent done. $DIRTY uncommitted files."
    echo "→ Commit subagent result, update SNAPSHOT.md (see delegation.md)"
    echo ""
fi
