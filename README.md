# Claude Code Starter v6

[![Version](https://img.shields.io/badge/version-v6.2.1-2563eb)](https://github.com/alexeykrol/claude-code-starter)
[![Status](https://img.shields.io/badge/status-active-16a34a)](https://github.com/alexeykrol/claude-code-starter)
[![Installer](https://img.shields.io/badge/installer-single--file-f59e0b)](https://github.com/alexeykrol/claude-code-starter/blob/main/init-project.sh)
[![Shell](https://img.shields.io/badge/shell-bash-111827?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/git-required-f05032?logo=git&logoColor=white)](https://git-scm.com/)
[![Python](https://img.shields.io/badge/python3-recommended-3776ab?logo=python&logoColor=white)](https://www.python.org/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-rules%2Bskills%2Bagents%2Bhooks-d97706)](https://www.anthropic.com/claude-code)

`Claude Code Starter` — это готовая управляющая среда для проектов, в которых основной рабочий агент — Claude Code.

Он нужен не для генерации приложения, а для того, чтобы быстро добавить в любой проект:
- понятный `CLAUDE.md` вместо мегадокумента;
- модульные `rules`, `skills`, `agents`, `hooks`;
- **двух-осевую проектную память** — контракты (`ARCHITECTURE.md`, `INVARIANTS.md`, `methodology/`) и state (`SNAPSHOT.md`, `BACKLOG.md`, `dialogs/`);
- **methodology layer** с лестницей зрелости (draft → pattern → mature → crystallized) для пайплайнов с автоматическими LLM-вызовами;
- **dialog preservation** — JSONL текущей сессии сохраняется в `.claude/dialogs/` до того, как Claude Code сделает retention cleanup;
- единый installer для нового, существующего и legacy-проекта;
- явный контроль над тем, что framework state делает с git-историей.

**Новое в v6.2.1:** `/start` skill переписан — убран кэп «доложи 3-5 строк» (он читался моделью как потолок глубины, а не пол краткости), добавлен обязательный шаг **заземления карты в территорию** (git log + wc + grep против заявлений метафайлов), пометка «карта ≠ территория». В шапке `CLAUDE.md` — новая секция «Назначение этого файла» с **тремя видами ограничений** (действия / внимание / глубина): первые два — нормальны, кэп на глубину — структурный баг. В `validate-release.sh` — запрет на параллельный `ONBOARDING.md` (конституция только в `CLAUDE.md`). См. [release-notes/v6.2.1.md](release-notes/v6.2.1.md).

**Новое в v6.2.0:** восстановлены слои памяти `ARCHITECTURE.md` и `BACKLOG.md`, добавлены `INVARIANTS.md` и каталог `methodology/` с лестницей зрелости (draft → pattern → mature → crystallized). Добавлен механизм dialog preservation (`scripts/save-dialogs.sh`, skill `/save-dialog`, авто-сохранение при `/finish`).

**Новое в v6.0–6.1:** автоматическое определение типа проекта (code / content / hybrid). Контентные проекты — книги, курсы, базы знаний, документы, транскрипты — получают свой набор правил, навыков и агентов (writer, editor, content-reviewer). Опциональный глобальный слой `~/.claude/` с `/setup-project` skill. Установка без флагов: `bash init-project.sh` сам поймёт, где находится, и поставит подходящий слой.

## Зачем Это Нужно

Обычно при работе с агентом проект быстро расползается:
- инструкции живут в одном длинном `CLAUDE.md`;
- правила смешаны с контекстом проекта;
- старт нового проекта и миграция старого проекта делаются по-разному;
- агентная память теряется между сессиями;
- внутренние framework-файлы случайно попадают в shared/public git history.

`Claude Code Starter` решает эти проблемы:
- отделяет проектный паспорт от operational logic;
- даёт стандартную структуру `.claude/`;
- добавляет reusable workflows через `skills`;
- добавляет background guardrails через `hooks`;
- поддерживает single-file installation;
- вводит `repo_access`, чтобы память агента не утекала туда, где ей не место.

## Что Устанавливается В Проект

После установки в хост-проекте появляется такая база:

```text
.claude/
  rules/                # операционные правила (autonomy, delegation, dialog-preservation, ...)
  skills/               # /start, /finish, /save-dialog, /testing, ...
  agents/               # researcher, implementer, reviewer (+ writer/editor для content)
  hooks/                # фоновые guardrails (pre-compact, post-compact, ...)
  logs/                 # сессии, миграции, ошибки (gitignored)
  dialogs/              # архив JSONL сессий (по умолчанию gitignored)
  SNAPSHOT.md           # state: текущая точка работы
  BACKLOG.md            # state: Next / Soon / Later / Won't do
  ARCHITECTURE.md       # contract: карта системы
  INVARIANTS.md         # contract: жёсткие правила, нарушение = баг
  settings.json
methodology/            # contract: методологии для пайплайнов
  _HOW-THIS-GROWS.md
  templates/            # draft / pattern / mature / crystallized
  draft/ patterns/ mature/
  00-example-llm-as-component.md
scripts/
  framework-state-mode.sh
  switch-repo-access.sh
  save-dialogs.sh
CLAUDE.md
manifest.md
.gitignore
```

**Двух-осевая память** (см. CLAUDE.md секция «Слои памяти»):
- **Контракты — что должно быть** (медленно меняется): `ARCHITECTURE.md`, `INVARIANTS.md`, `methodology/`
- **State — что есть сейчас** (быстро меняется): `SNAPSHOT.md`, `BACKLOG.md`, `dialogs/`

Ключевые файлы:
- `CLAUDE.md` — паспорт проекта;
- `manifest.md` — `project_name`, `repo_access`, `project_type`, `content_type`;
- `.claude/SNAPSHOT.md` — что в работе прямо сейчас;
- `.claude/BACKLOG.md` — план: Next / Soon / Later / Won't do;
- `.claude/ARCHITECTURE.md` — карта модулей, контрактов, зависимостей;
- `.claude/INVARIANTS.md` — правила, нарушение которых — баг, не предпочтение;
- `.claude/dialogs/` — архив сессионных JSONL для последующего анализа;
- `methodology/` — методологии с лестницей зрелости (draft → pattern → mature → crystallized);
- `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/hooks/` — operational слой;
- `scripts/save-dialogs.sh` — идемпотентное сохранение JSONL сессии;
- `scripts/switch-repo-access.sh` — безопасное переключение между `private-solo`, `private-shared`, `public`.

## Требования

Обязательно:
- `bash`
- `git`
- Claude Code с поддержкой:
  - `.claude/rules/`
  - `.claude/skills/`
  - `.claude/agents/`
  - `.claude/hooks/`

Рекомендуется:
- `python3`

Опционально:
- `node` / `npm`
- `pytest`
- `sqlite3`
- `psql`
- `supabase`

`python3` нужен не для bootstrap, а для безопасного merge `settings.json` в migration flow.

## Установка

### Вариант 1. Один файл

Возьми root installer `init-project.sh`, положи его в корень целевого проекта и запусти:

```bash
chmod +x init-project.sh
./init-project.sh
```

Никаких флагов не нужно. Launcher сам определит:

**Сценарий установки:**
- `new` — новый проект;
- `existing` — существующий без framework;
- `legacy` — старый framework;
- `upgrade` — частично установленный.

**Тип проекта** (по содержимому файлов и папок):
- `code` — обычный software-проект;
- `content` — книги, курсы, KB, документы, транскрипты;
- `hybrid` — и код, и контент.

**Тип контента** для контентных проектов:
- `book` — папки `chapters/`, `briefs/`, `bible/`;
- `course` — папки `modules/`, `lessons/`;
- `knowledge-base` — `articles/`, `INDEX.md`;
- `documents` — `docs/`;
- `transcripts` — `Section-*/`, `*-Lecture-*`;
- `mixed` — несколько сразу.

Если установка затрагивает существующий `CLAUDE.md`, он мержится **аддитивно** через `scripts/lib/merge_claude_md.py` — кастомные секции пользователя сохраняются, фреймворк добавляет только недостающее. При жёстком конфликте установка останавливается и в `.claude/CLAUDE.md.merge-proposal.md` пишется конкретное предложение разрешения.

### Вариант 2. Из локального checkout

```bash
cd /path/to/your/project
bash /absolute/path/to/claude-code-starter/init-project.sh
```

### Вариант 3. Глобальный слой + skill `/setup-project`

Если хочешь, чтобы framework был доступен **в любой папке** без скачивания каждый раз — поставь его в `~/.claude/`:

```bash
bash /path/to/claude-code-starter/scripts/install-global.sh
```

Это аддитивно копирует rules / skills / agents в `~/.claude/`, не трогая существующие настройки. Делает backup в `~/.claude/.backup-TIMESTAMP/`. После этого:

```bash
mkdir my-new-project && cd my-new-project
# Открой Claude Code в этой папке и скажи:
# /setup-project   — или просто: «новый проект» / «поставь фреймворк»
```

Skill `/setup-project` сам найдёт checkout, определит тип проекта и поставит framework. Никакой ручной загрузки `init-project.sh` не требуется.

Откат: `bash scripts/install-global.sh --rollback`.

### Полезные параметры

```bash
./init-project.sh --name "My Project"
./init-project.sh --type content --content-type book
./init-project.sh --mode init
./init-project.sh --mode migrate
./init-project.sh --template /path/to/local/framework
./init-project.sh --rollback
./init-project.sh --apply-proposal
./init-project.sh --force
```

Поддерживаются:
- `--name` — имя проекта для свежего bootstrap;
- `--type code|content|hybrid|auto` — override автодетекта типа проекта;
- `--content-type book|course|knowledge-base|documents|transcripts|mixed` — override автодетекта типа контента;
- `--mode init` — принудительный bootstrap;
- `--mode migrate` — принудительная migration/integration;
- `--template` — использовать локальный checkout framework вместо download;
- `--rollback` — восстановить файлы из последнего `.claude/backup-*/` snapshot;
- `--apply-proposal` — применить предложение из `.claude/CLAUDE.md.merge-proposal.md`;
- `--force` — перезаписать существующие файлы (для разработчиков фреймворка).

## Что Делать После Установки

1. Заполнить `CLAUDE.md` под конкретный проект.
2. Проверить `manifest.md`.
3. Если проект shared/public, переключить режим до первого framework commit:

```bash
scripts/switch-repo-access.sh public --commit
```

или

```bash
scripts/switch-repo-access.sh private-shared --commit
```

4. Открыть проект в Claude Code и запустить `/start`.

## Repo Access

`repo_access` задаётся в `manifest.md`.

Режимы:
- `private-solo` — framework files можно хранить в git;
- `private-shared` — framework files должны оставаться локальными;
- `public` — framework files должны оставаться локальными.

Практический смысл:
- если репозиторий личный, можно хранить framework state в истории;
- если репозиторий общий или публичный, память агента не должна попадать в branch history.

Если framework state уже успел попасть в remote history, одного `.gitignore` недостаточно. Для таких случаев и существует `scripts/switch-repo-access.sh`.

## Как Устроен Этот Репозиторий

Публичный вход:
- [init-project.sh](init-project.sh) — единственный installer entrypoint

Внутренний payload:
- [scripts/init-project.sh](scripts/init-project.sh) — bootstrap payload
- [scripts/migrate.sh](scripts/migrate.sh) — migration payload
- [scripts/framework-state-mode.sh](scripts/framework-state-mode.sh) — логика `repo_access`
- [scripts/switch-repo-access.sh](scripts/switch-repo-access.sh) — safe mode switch

Документация:
- [CHANGELOG.md](CHANGELOG.md) — история версий и изменений
- [RELEASING.md](RELEASING.md) — как собирать и публиковать релиз
- [release-notes/v6.2.1.md](release-notes/v6.2.1.md) — notes для текущего release
- [release-notes/GITHUB_RELEASE_v6.2.1.md](release-notes/GITHUB_RELEASE_v6.2.1.md) — готовый body для GitHub Release

Архив:
- [archive/V4_ARCHIVE_NOTE.md](archive/V4_ARCHIVE_NOTE.md) — что именно сохранено от `v4`
- [archive/v4-working-tree](archive/v4-working-tree) — архивное дерево `v4`

## Ограничения

1. `switch-repo-access.sh` не переписывает git history.
2. `migrate.sh` зависит от `python3`, если нужен безопасный merge `.claude/settings.json`.
3. Standalone installer лучше всего работает через GitHub Release assets.
4. Hooks здесь — это guardrails, а не абсолютный enforcement layer.

## Быстрые Ссылки

- Установить framework: [init-project.sh](init-project.sh)
- Прочитать историю версий: [CHANGELOG.md](CHANGELOG.md)
- Собрать release: [RELEASING.md](RELEASING.md)
- Посмотреть notes текущего релиза: [release-notes/v6.2.1.md](release-notes/v6.2.1.md)
- Взять текст GitHub Release: [release-notes/GITHUB_RELEASE_v6.2.1.md](release-notes/GITHUB_RELEASE_v6.2.1.md)

## Эволюция версий

| Тема | v5 | v6.0–6.1 | v6.2.0 | v6.2.1 |
|------|----|----|------|--------|
| Тип проекта | только code | code / content / hybrid с автодетектом | + явная двух-осевая модель памяти | то же |
| Слои памяти | `SNAPSHOT.md` (всё в одном) | `SNAPSHOT.md` | `SNAPSHOT.md` + `BACKLOG.md` (state) + `ARCHITECTURE.md` + `INVARIANTS.md` (contracts) | то же |
| Контентные проекты | нет | книги, курсы, KB, документы, транскрипты | + content-flavored memory layers | то же |
| Methodology layer | нет | нет | `methodology/` с лестницей зрелости draft → pattern → mature → crystallized | + canonical draft про onboarding-cap |
| Dialog preservation | TypeScript-стек в v4, выкинут в v5 | нет | bash-скрипт + `/save-dialog` skill + auto-save при `/finish` | то же |
| `/start` skill | базовый | базовый | читает обе оси памяти | + grounding (git log/wc/grep против метафайлов), масштабируемый доклад, «карта ≠ территория» |
| `CLAUDE.md` шапка | passport-only | passport-only | + «Слои памяти» | + «Назначение» с тремя видами ограничений (действия / внимание / глубина), кэп глубины запрещён |
| `CLAUDE.md` при миграции | merge только `settings.json` hooks | полный аддитивный merge секций через Python helper | + документация двух-осевой памяти | то же |
| Конфликты | overwrite или skip | детектятся, останавливают установку, пишут конкретное предложение | то же | то же |
| Backup | нет | автоматический `.claude/backup-TIMESTAMP/` | + backup новых memory files | то же |
| Откат | manual | `init-project.sh --rollback` | + восстанавливает новые memory files | то же |
| Глобальный слой | нет | опциональный `~/.claude/` через `install-global.sh` | + глобальный `methodology/`, `/save-dialog` skill | то же |
| Drift guards | нет | нет | нет | `validate-release.sh` проверяет README badge + release-notes link + script headers, запрещает `ONBOARDING.md` |
| Шаблоны контента | нет | `chapter.md`, `lesson.md`, `transcript.md`, `article.md`, `document.md` | то же | то же |

Подробности по эволюции версий смотри в [CHANGELOG.md](CHANGELOG.md).
