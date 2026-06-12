# Глобальные настройки Claude Code

## Доступные слои framework

В `~/.claude/` установлены универсальные правила, навыки и агенты Claude Code Starter. Они работают как **базовая сетка** во всех проектах. Когда в проекте есть свой `.claude/` — он перекрывает глобальный для своих файлов; всё остальное берётся из глобального.

### Правила (`~/.claude/rules/`)

Универсальные:
- `autonomy.md`, `delegation.md`, `context-management.md`, `commit-policy.md`, `production-safety.md`, `logging.md`, `local-first.md`, `dialog-preservation.md`

Контентные (для проектов с текстами/курсами/книгами):
- `content-pipeline.md` — Intake → Research → Outline → Write → Enrich → Review → Export
- `content-quality.md` — universal review checklist (28 точек)
- `source-management.md` — provenance, hierarchy, deficits
- `content-formats.md` — chapter/lesson/transcript/article/document форматы
- `content-commit-policy.md` — content-префиксы (`content:`, `chapter:`, `lesson:`, `research:`, `index:`)

Применяй контентные правила, если в проекте `manifest.md` имеет `project_type=content` или `project_type=hybrid`.

### Навыки (`~/.claude/skills/`)

Общие: `/start`, `/finish`, `/testing`, `/handoff`, `/housekeeping` (универсальная — проверяет и код, и контент), `/save-dialog` (архив сессионных JSONL)

Code: `/db-migrate`, `/playwright`

Content: `/research`, `/outline`, `/write-content`, `/review-content`, `/enrich`, `/content-index`

Bootstrap: `/setup-project` — устанавливает framework в текущую папку (auto-detect type). Это самописный skill из Claude Code Starter; не путай со встроенной командой `/init`, которая просто генерирует CLAUDE.md документацию.

### Dialog Preservation (`dialog-preservation.md` + `/save-dialog`)

Claude Code пишет JSONL текущей сессии в `~/.claude/projects/<encoded-cwd>/`. Эти файлы со временем подчищаются retention'ом. Глобальная сетка включает:

- правило `dialog-preservation.md` — куда копировать, как индексировать, политика по `repo_access`;
- скилл `/save-dialog` — явное сохранение текущей сессии в `.claude/dialogs/`;
- автоматическое сохранение при `/finish` (если в проекте установлен `scripts/save-dialogs.sh`).

Архив `.claude/dialogs/` коммитится только в `repo_access=private-solo`; в shared/public — остаётся локальным.

### Агенты (`~/.claude/agents/`)

- `researcher` — исследование (универсален: код и контент)
- `implementer` — реализация кода
- `reviewer` — code review
- `writer` — написание/адаптация content units
- `editor` — проверка стиля/голоса/формата контента (находит проблемы, не переписывает)
- `content-reviewer` — release review для контента (28-point checklist)

### Methodology layer (`~/.claude/methodology/`)

Глобальные методологии для пайплайнов (router → adapter → executor). Их потребители — автоматические LLM-цепочки, не интерактивный агент.

- `_HOW-THIS-GROWS.md` — объясняет лестницу зрелости draft → pattern → mature → crystallized
- `00-example-llm-as-component.md` — canonical mature example (LLM как ненадёжный компонент)

Проектные методологии в `<project>/methodology/` могут ссылаться на глобальные и уточнять их под локальный контекст. Подробнее — `_HOW-THIS-GROWS.md`.

### Слои памяти проекта

Проекты с фреймворком держат память на двух осях:

- **Контракты** (медленно меняются): `.claude/ARCHITECTURE.md`, `.claude/INVARIANTS.md`, `methodology/`
- **State** (быстро меняется): `.claude/SNAPSHOT.md`, `.claude/BACKLOG.md`, `.claude/dialogs/`

При старте сессии в проекте — читай обе оси. При завершении — обновляй обе. Не схлопывай контракты в SNAPSHOT (это известная регрессия v5).

### Протокол `/start` и три вида ограничений (v6.2.1+)

Skill `/start` в проектах v6.2.1+ работает по этим принципам:

1. **Читает обе оси памяти** (контракты + state) — обязательно.
2. **Заземляет карту в территорию** — `git log`, `wc -l` по основным каталогам, `grep` по TODO/FIXME/NotImplementedError. Метафайлы — это карта; если она разошлась с кодом, ты унаследуешь слепые пятна. Цена заземления — минута, ценность — представление, которому можно верить.
3. **Доклад масштабируется под запрос пользователя**, не фиксирован форматом. Рутинный «start» — компактно; «разберись с проектом» — полный аналитический разбор. Минимум — пол адекватности, потолка нет.
4. **Помнит, что после `/start` это карта, не территория** — перед правкой подсистемы читает её код и локальные docs.

Это исходит из принципа «три вида ограничений», задокументированного в шапке проектного `CLAUDE.md`:

| Вид ограничения | Норма |
|---|---|
| На действия (INVARIANTS, production-safety) | **жёстко** |
| На внимание (порядок чтения, две оси) | **полезно** |
| На глубину/выход доклада | **никогда не кэпить** |

Если в каком-либо протоколе появляется «доложи N строк» применительно к **пониманию** — это структурный баг, а не норма. См. [FRAMEWORK-CASE-ONBOARDING.md](https://github.com/alexeykrol/claude-code-starter/blob/main/FRAMEWORK-CASE-ONBOARDING.md) для разбора.

Параллельный `ONBOARDING.md` в проектах фреймворком не генерируется и запрещён валидатором: конституция живёт только в `CLAUDE.md`, который харнес автозагружает.

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
