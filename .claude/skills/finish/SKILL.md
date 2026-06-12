---
name: finish
description: "Завершение рабочей сессии. Тесты, коммит, обновление SNAPSHOT, отчёт."
allowed-tools: Read Edit Write Glob Grep Bash
disable-model-invocation: true
---

# Skill: Finish Session

## Что делать

### 1. Запустить тесты

Если в проекте есть тесты:
```bash
# Определить тип проекта и запустить тесты
if [ -f "package.json" ]; then
  npm test 2>&1 || true
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || [ -d "tests" ]; then
  python3 -m pytest tests/ 2>&1 || true
fi
```

Если тесты падают:
- Попробовать починить (до 3 попыток, автономно)
- Если не удалось — коммитить код, но записать в SNAPSHOT.md что тесты красные и что конкретно падает
- Не блокировать весь finish из-за упавшего теста

### 2. Проверить git status

```bash
git status --short
git diff --stat
```

### 3. Коммит изменений (по Commit Policy)

Если есть незакоммиченные изменения — следовать правилу `commit-policy.md`:

1. Для каждого файла определить категорию:
   - **Запрещено** (.env, *.key, *.db, node_modules/ и т.д.) → убедиться что в `.gitignore`, если нет — добавить автоматически
   - **Разрешено** (src/, tests/, CLAUDE.md, package.json и т.д.) → stage
   - **Остальное** → решить по контексту, не спрашивая пользователя
2. `git add` только разрешённых файлов (поимённо, не `git add .`)
3. Сформировать описательное commit message
4. git commit

### 4. Обновить слои памяти

**SNAPSHOT.md** — что есть сейчас:
- **Что сделано** — добавить записи о работе этой сессии
- **В процессе** — очистить или обновить
- **Следующие шаги** — что осталось
- **Известные проблемы** — если обнаружены
- **Дата** — обновить timestamp

**BACKLOG.md** (если есть) — что планируется:
- Перенести закрытые задачи из Next в done
- Добавить новые обнаруженные задачи (Next/Soon/Later)
- Если решение «не делаем» — переместить в Won't do с одной строкой причины

**INVARIANTS.md** (если есть) — если в сессии возник новый инвариант или нашли нарушение существующего:
- Добавить новый INV-NNN с описанием правила, причины, проверки
- Это сигнал зрелости — не пропускать

**ARCHITECTURE.md** (если есть) — если в сессии изменилась карта системы (новый модуль, новые границы):
- Обновить соответствующую секцию

### 4b. Сохранить диалог сессии

Защита от retention cleanup Claude Code — диалог может содержать ценные методологические находки:
```bash
[ -f scripts/save-dialogs.sh ] && bash scripts/save-dialogs.sh || true
```
Без note (быстрый автосейв). Если в сессии было что-то особенно ценное — пользователь может вручную запустить `/save-dialog` с note до или после `/finish`.

### 5. Закоммитить обновлённые слои

```bash
# Проверить режим framework state
scripts/framework-state-mode.sh check-safe-mode

# Только private-solo коммитит memory layers в git-историю.
if [ "$(scripts/framework-state-mode.sh should-commit-framework-state)" = "true" ]; then
  for f in .claude/SNAPSHOT.md .claude/BACKLOG.md .claude/INVARIANTS.md .claude/ARCHITECTURE.md; do
    [ -f "$f" ] && git add "$f"
  done
  git diff --cached --quiet || git commit -m "docs: update memory layers after session"
else
  echo "Memory layers kept local due repo_access=$(scripts/framework-state-mode.sh repo-access)"
fi
```

В режиме `public`/`private-shared` SNAPSHOT остаётся локальным файлом и не коммитится. Если helper сообщает blocker из-за tracked framework files, сначала запусти `scripts/switch-repo-access.sh <mode>`.

### 6. Завершить лог сессии

Дописать в текущий файл `.claude/logs/sessions/YYYY-MM-DD_HH-MM.md`:
- Итоги тестов (passed/failed/skipped)
- Список коммитов сессии
- Ошибки (если были)
- Duration сессии

### 7. Отчёт пользователю

Кратко (5-7 строк):
- Что сделано за сессию
- Результаты тестов
- Хэши коммитов
- Что осталось на следующую сессию

## Чего НЕ делать

- Не пушить автоматически (push — отдельное решение)
- Не коммитить файлы из списка «Запрещено всегда» (см. commit-policy.md)
- Не затягивать finish дольше 2 минут
