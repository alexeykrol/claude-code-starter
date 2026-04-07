# Claude Code Starter v5

[![Version](https://img.shields.io/badge/version-v5.0.0-2563eb)](https://github.com/alexeykrol/claude-code-starter)
[![Status](https://img.shields.io/badge/status-active-16a34a)](https://github.com/alexeykrol/claude-code-starter)
[![Installer](https://img.shields.io/badge/installer-single--file-f59e0b)](https://github.com/alexeykrol/claude-code-starter/blob/main/init-project.sh)
[![Shell](https://img.shields.io/badge/shell-bash-111827?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Git](https://img.shields.io/badge/git-required-f05032?logo=git&logoColor=white)](https://git-scm.com/)
[![Python](https://img.shields.io/badge/python3-recommended-3776ab?logo=python&logoColor=white)](https://www.python.org/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-rules%2Bskills%2Bagents%2Bhooks-d97706)](https://www.anthropic.com/claude-code)
[![Repo Access](https://img.shields.io/badge/repo__access-private--solo%20%7C%20private--shared%20%7C%20public-7c3aed)](.claude/rules/commit-policy.md)

Продолжение `Claude Code Starter v4` с новым operational model для Claude Code.

Главное отличие от промежуточного template-style UX: публичный вход снова один. Пользователь работает с **одним файлом** `init-project.sh`, а не с набором внутренних `scripts/*`.

## Что Это

`Claude Code Starter v5` это не web framework и не application starter. Это framework управления проектной средой для Claude Code.

Старый `v4` не удалён. Он сохранён внутри этого же репозитория в `archive/v4-working-tree/`, а pre-migration `HEAD` дополнительно помечен тегом `archive-v4-head-2026-04-06`.

Он добавляет в проект:
- компактный `CLAUDE.md` как паспорт проекта;
- модульные `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/hooks/`;
- локальную рабочую память через `.claude/SNAPSHOT.md`;
- безопасную модель `repo_access`, чтобы framework state не утекал в shared/public git history;
- bootstrap, migration и mode-switch tooling.

Это прямой преемник `Claude Code Starter v4`, но с другой архитектурой:
- вместо монолитного `CLAUDE.md` используются native primitives Claude Code;
- вместо старого dual-runtime UX акцент сделан на автономную работу Claude Code;
- вместо “клонируй template repo и вызывай внутренний script” снова используется один launcher.

## Что Изменилось По UX

`v4` был удобнее в одном важном месте: там существовал один installer-файл, который можно было просто положить в корень любого проекта и запустить.

В `v5` этот UX возвращён:
- публичный entrypoint теперь снова `init-project.sh` в корне репозитория;
- один и тот же launcher работает для нового проекта, существующего проекта, legacy framework и частично установленного `v5`;
- внутренние `scripts/init-project.sh` и `scripts/migrate.sh` больше считаются implementation detail, а не пользовательским интерфейсом;
- standalone launcher умеет скачать framework payload сам.

## Быстрый Старт

### Вариант 1. Один файл `init-project.sh`

Возьми root launcher `init-project.sh` из этого репозитория любым удобным способом:
- скачай его из GitHub Release, когда релиз опубликован;
- забери из локального checkout этого репозитория;
- или просто скопируй файл вручную в корень целевого проекта.

После этого:

```bash
chmod +x init-project.sh
./init-project.sh
```

### Вариант 2. Запуск из локального checkout framework

Если framework уже скачан локально:

```bash
cd /path/to/your/project
bash /absolute/path/to/claude-code-starter/init-project.sh
```

### Что дальше

После установки:
1. Заполни [CLAUDE.md](CLAUDE.md) под свой проект.
2. Проверь `manifest.md`.
3. Если проект должен быть `public` или `private-shared`, переключи режим **до первого framework commit**:

```bash
scripts/switch-repo-access.sh public --commit
```

или

```bash
scripts/switch-repo-access.sh private-shared --commit
```

4. Открой проект в Claude Code и запусти `/start`.

## Единый Launcher

Публичный installer это [init-project.sh](init-project.sh) в корне репозитория.

Он умеет работать в двух режимах:

- **source mode**: если запускается из checkout этого репозитория, использует локальный payload;
- **standalone mode**: если файл скопирован отдельно в целевой проект, скачивает framework payload сам.

Download strategy:
- сначала пытается взять release archive;
- если release archive недоступен, пытается сделать `git clone` framework repo;
- если и это недоступно, падает назад на repository snapshot.

То есть UX уже один, даже если release pipeline ещё в процессе оформления.

## Какие Сценарии Launcher Определяет Сам

Launcher анализирует текущий каталог и выбирает сценарий:

- `new` — пустой или почти пустой проект, нужен bootstrap;
- `existing` — обычный существующий проект без framework markers;
- `legacy` — старый framework (`.claude/commands`, `.claude/protocols`, `.codex`, `.framework-config`);
- `upgrade` — частично установленный или уже существующий `v5`.

Routing:
- `new` → internal bootstrap payload;
- `existing` / `legacy` / `upgrade` → additive migration payload.

При необходимости сценарий можно принудительно задать:

```bash
./init-project.sh --mode init
./init-project.sh --mode migrate
```

## Параметры Launcher

```bash
./init-project.sh --name "My Project"
./init-project.sh --mode init
./init-project.sh --mode migrate
./init-project.sh --template /path/to/local/framework
```

Поддерживаются:
- `--name` — имя проекта для свежего bootstrap;
- `--mode init` — принудительный bootstrap;
- `--mode migrate` — принудительная additive migration;
- `--template` — использовать локальный checkout framework вместо download.

## Что Именно Устанавливается В Проект

Launcher и payload создают:

```text
.claude/
  rules/
  skills/
  agents/
  hooks/
  logs/
  SNAPSHOT.md
  settings.json
scripts/
  framework-state-mode.sh
  switch-repo-access.sh
CLAUDE.md
manifest.md
.gitignore
```

Содержимое:
- `CLAUDE.md` — паспорт проекта;
- `manifest.md` — `project_name` и `repo_access`;
- `.claude/rules/` — постоянные operational rules;
- `.claude/skills/` — повторяемые workflows;
- `.claude/agents/` — стандартные роли subagents;
- `.claude/hooks/` — background guardrails;
- `.claude/SNAPSHOT.md` — проектная память;
- `scripts/framework-state-mode.sh` — единая логика по `repo_access`;
- `scripts/switch-repo-access.sh` — безопасный switch между `private-solo`, `private-shared`, `public`.

## Технологический Стек

**Required**
- `bash`
- `git`
- Claude Code с поддержкой:
  - `.claude/rules/`
  - `.claude/skills/`
  - `.claude/agents/`
  - `.claude/hooks/`

**Recommended**
- `python3` для безопасного JSON merge в migration flow

**Optional**
- `node` / `npm` для JS/TS-проектов и Playwright
- `pytest` для Python-проектов
- `sqlite3`, `psql`, `supabase` CLI для DB workflows

## Repo Access И Git История

`repo_access` определяет, может ли framework state жить в git history.

Режимы:
- `private-solo` — framework files можно коммитить;
- `private-shared` — framework files должны оставаться локальными;
- `public` — framework files должны оставаться локальными.

Ключевой принцип:
- `SNAPSHOT.md` и остальная framework memory не должны попадать в shared/public branch history.

Поэтому:
- если проект shared/public с самого начала, переключай режим до первого framework commit;
- если framework state уже попал в git history, одного `.gitignore` недостаточно;
- для такого случая используй `scripts/switch-repo-access.sh`, а если файлы уже ушли в remote history, нужен history rewrite или новая ветка.

## Внутреннее Устройство

В репозитории есть два внутренних payload script'а:
- [scripts/init-project.sh](scripts/init-project.sh) — internal bootstrap payload;
- [scripts/migrate.sh](scripts/migrate.sh) — internal migration payload.

Они не считаются публичным UX. Публичный UX — только root [init-project.sh](init-project.sh).

Зачем такое разделение:
- launcher остаётся одним файлом и простым для пользователя;
- payload можно эволюционировать отдельно;
- release asset может содержать только launcher, а остальное он скачает сам.

## Ограничения И Известные Компромиссы

1. `switch-repo-access.sh` не переписывает git history.
   Если framework files уже успели попасть в upstream branch, скрипт остановится и потребует history rewrite или чистую shared/public branch.

2. `migrate.sh` additive по умолчанию, но safe JSON merge для `.claude/settings.json` зависит от `python3`.
   Если `python3` отсутствует или merge падает, остаётся fallback на replace с warning.

3. Standalone launcher сейчас сначала пробует release archive, потом `git clone`, и только затем repository snapshot.
   Это временный компромисс, пока release pipeline не оформлен как единственный distribution channel.

4. Хуки в `v5` это guardrails и reminders, а не абсолютный enforcement layer.
   Они помогают удерживать operational discipline, но не заменяют сознательную работу агента.

5. `CLAUDE.md` шаблона намеренно короткий.
   Он должен описывать конкретный проект, а не дублировать весь framework manual.

## Проверенные Сценарии

На текущем состоянии репозитория были проверены:
- bootstrap в новый каталог;
- additive migration существующего проекта;
- upgrade missing files в частично установленном `v5`;
- safe switch `private-solo -> public/private-shared`;
- blocking case, когда framework files уже попали в upstream history;
- merge hooks в existing `.claude/settings.json` с сохранением custom keys;
- корректная подстановка имени проекта с символом `&`.

## Когда Это Подходит

Используй `Claude Code Starter v5`, если тебе нужна:
- повторяемая operational среда для Claude Code;
- компактная проектная память без мегадокументов;
- единая модель bootstrap/migration/upgrade;
- явный контроль над тем, что framework memory делает с git history;
- автономная работа агента через rules, skills, agents, hooks.

## Когда Это Не Подходит

Не используй этот framework, если тебе нужен:
- обычный web framework starter;
- генератор прикладного кода без operational layer;
- полностью zero-tooling режим без `git`;
- shared/public workflow, где уже нельзя контролировать историю, но при этом framework state нужно тащить в основной branch.

## Ближайший Направленный Шаг

Следующий логичный этап после этого репозитория:
- оформить стабильный GitHub Release c versioned `init-project.sh` и `framework.tar.gz`;
- зафиксировать публичное имя и legacy-continuity окончательно;
- дальше уже мигрировать реальные host projects на этот single-entry UX.
