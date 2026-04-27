# Глобальные настройки Claude Code

## Доступные слои framework

В `~/.claude/` установлены универсальные правила, навыки и агенты Claude Code Starter. Они работают как **базовая сетка** во всех проектах. Когда в проекте есть свой `.claude/` — он перекрывает глобальный для своих файлов; всё остальное берётся из глобального.

### Правила (`~/.claude/rules/`)

Универсальные:
- `autonomy.md`, `delegation.md`, `context-management.md`, `commit-policy.md`, `production-safety.md`, `logging.md`, `local-first.md`

Контентные (для проектов с текстами/курсами/книгами):
- `content-pipeline.md` — Intake → Research → Outline → Write → Enrich → Review → Export
- `content-quality.md` — universal review checklist (28 точек)
- `source-management.md` — provenance, hierarchy, deficits
- `content-formats.md` — chapter/lesson/transcript/article/document форматы
- `content-commit-policy.md` — content-префиксы (`content:`, `chapter:`, `lesson:`, `research:`, `index:`)

Применяй контентные правила, если в проекте `manifest.md` имеет `project_type=content` или `project_type=hybrid`.

### Навыки (`~/.claude/skills/`)

Общие: `/start`, `/finish`, `/testing`, `/handoff`, `/housekeeping` (универсальная — проверяет и код, и контент)

Code: `/db-migrate`, `/playwright`

Content: `/research`, `/outline`, `/write-content`, `/review-content`, `/enrich`, `/content-index`

Bootstrap: `/setup-project` — устанавливает framework в текущую папку (auto-detect type). Это самописный skill из Claude Code Starter; не путай со встроенной командой `/init`, которая просто генерирует CLAUDE.md документацию.

### Агенты (`~/.claude/agents/`)

- `researcher` — исследование (универсален: код и контент)
- `implementer` — реализация кода
- `reviewer` — code review
- `writer` — написание/адаптация content units
- `editor` — проверка стиля/голоса/формата контента (находит проблемы, не переписывает)
- `content-reviewer` — release review для контента (28-point checklist)

## Поведение при старте сессии

1. **Если в текущей папке нет проектного `.claude/`** — это вероятно новая папка. Предложи пользователю запустить `/setup-project`, который установит framework. Не запускай молча — это создаёт файлы в его проекте.

2. **Если есть проектный `.claude/`** — нормальная работа. Выполни обычный cold-start: прочитай `CLAUDE.md`, `.claude/SNAPSHOT.md`, доложи готовность.

3. **Если есть проектный `.claude/`, но устаревший** (например, содержит `.claude/commands/` или `.claude/protocols/` — артефакты старых версий) — это legacy framework. Предложи запустить `/setup-project` для безопасной аддитивной миграции.

## Как определить тип текущего проекта

Если есть `manifest.md` → читай `project_type` и `content_type`. Если нет — определяй по содержимому:

- Папки `chapters/`, `briefs/`, `bible/` → книга
- `modules/`, `lessons/` → курс
- `articles/`, `INDEX.md` → knowledge base
- `Section-*/`, `*-Lecture-*` → транскрипты
- `package.json`/`pyproject.toml` + content folders → hybrid
- Только `package.json`/`pyproject.toml` без content folders → code

При неоднозначности — спроси одним вопросом.

## Источник framework

Путь к framework checkout записан в `~/.claude/framework-source-path`. Скилл `/setup-project` использует его для запуска установщика. Если файла нет — скилл сам найдёт checkout в стандартных местах или склонирует из GitHub.
