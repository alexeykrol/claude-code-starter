# Claude Code Starter v5

[![Version](https://img.shields.io/badge/version-v5.0.0-2563eb)](https://github.com/alexeykrol/claude-code-starter)
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
- устойчивую проектную память через `.claude/SNAPSHOT.md`;
- единый installer для нового, существующего и legacy-проекта;
- явный контроль над тем, что framework state делает с git-историей.

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

Ключевые файлы:
- `CLAUDE.md` — паспорт проекта;
- `manifest.md` — `project_name` и `repo_access`;
- `.claude/SNAPSHOT.md` — текущая память проекта;
- `.claude/rules/` — постоянные operational правила;
- `.claude/skills/` — стандартные workflows;
- `.claude/agents/` — типовые subagent roles;
- `.claude/hooks/` — фоновые guardrails;
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

Этот launcher сам определит сценарий:
- `new` — новый проект;
- `existing` — существующий проект без framework;
- `legacy` — старый framework;
- `upgrade` — частично установленный `v5`.

### Вариант 2. Из локального checkout

```bash
cd /path/to/your/project
bash /absolute/path/to/claude-code-starter/init-project.sh
```

### Полезные параметры

```bash
./init-project.sh --name "My Project"
./init-project.sh --mode init
./init-project.sh --mode migrate
./init-project.sh --template /path/to/local/framework
```

Поддерживаются:
- `--name` — имя проекта для свежего bootstrap;
- `--mode init` — принудительный bootstrap;
- `--mode migrate` — принудительная migration/integration;
- `--template` — использовать локальный checkout framework вместо download.

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
- [release-notes/v5.0.0.md](release-notes/v5.0.0.md) — notes для текущего release
- [release-notes/GITHUB_RELEASE_v5.0.0.md](release-notes/GITHUB_RELEASE_v5.0.0.md) — готовый body для GitHub Release

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
- Посмотреть notes текущего релиза: [release-notes/v5.0.0.md](release-notes/v5.0.0.md)
- Взять текст GitHub Release: [release-notes/GITHUB_RELEASE_v5.0.0.md](release-notes/GITHUB_RELEASE_v5.0.0.md)

## v4 vs v5

| Тема | v4 | v5 |
|------|----|----|
| Installer UX | installer + старый runtime слой | один публичный `init-project.sh` |
| Основная модель | commands + protocols + adapters | rules + skills + agents + hooks |
| Проектная память | shared state, но тяжёлый operational overhead | компактный `CLAUDE.md` + `SNAPSHOT.md` |
| Работа с git | менее явная модель framework state | явный `repo_access` и mode switching |
| Текущий статус | архивирован внутри repo | основная активная версия |

Подробности по эволюции версий смотри в [CHANGELOG.md](CHANGELOG.md).
