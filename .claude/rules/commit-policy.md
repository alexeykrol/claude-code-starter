# Правило: Commit Policy

## Принцип

Агент решает сам, что коммитить. Не спрашивай пользователя. Используй `git add` конкретных файлов — никогда `git add .` или `git add -A`.

Политика коммитов зависит от типа проекта. Тип указан в `manifest.md` → `repo_access`.

## Три режима

### 1. `repo_access=public` или `repo_access=private-shared`

Публичный репозиторий или приватный с внешними пользователями / командой. В remote попадает **только продукт**: чистый код, пользовательская документация, конфиги. Всё, что связано с процессом разработки — остаётся локально.

**Коммитить (продукт):**
- Исходный код (src/, lib/, app/, pages/)
- Пользовательская документация (README.md, CHANGELOG.md, docs/)
- Конфиги проекта (package.json, pyproject.toml, tsconfig.json)
- Миграции БД (migrations/, schema/)
- Production-тесты (tests/, e2e/)
- .gitignore, LICENSE

**НЕ коммитить (процесс разработки → .gitignore):**
- Эксперименты, прототипы, черновики (experiments/, drafts/, scratch/)
- Логи тестов, отчёты покрытия (test-results/, playwright-report/, coverage/, *.log)
- Утилиты разработки, вспомогательные скрипты (scripts/dev-*, tools/local-*)
- Анализ, исследования, заметки (analysis/, research/, notes/)
- Промежуточные данные, дампы (data/, dumps/, fixtures/)
- Метафайлы фреймворка (.claude/, CLAUDE.md, manifest.md, AGENTS.md)
- Любые размышления, протоколы, внутренняя документация процесса

**SNAPSHOT.md** в public/shared режиме — **локальный файл**, а не часть общей git-истории. Это безопасно только если framework files никогда не были закоммичены в эту ветку или были удалены из индекса через `scripts/switch-repo-access.sh`.

Если проект уже жил как `private-solo`, а потом стал shared/public:
- одного `.gitignore` недостаточно;
- tracked framework files надо удалить из индекса;
- если они уже были push'нуты в upstream, нужна history rewrite или новая shared/public branch.

**Аналогия:** на столе куча инструментов, справочников и черновиков, но пользователю отдаётся только готовое изделие.

### 2. `repo_access=private-solo`

Приватный проект, работает только один человек. Коммитится **всё** — код, эксперименты, метафайлы, заметки, анализ. Репозиторий — это полный слепок рабочего стола.

**Коммитить:**
- Всё, что не в списке «Запрещено всегда» (см. ниже)
- Включая: .claude/, CLAUDE.md, manifest.md, experiments/, notes/, analysis/

### 3. Не указан `repo_access`

По умолчанию: работать как `private-solo`. Если обнаружен публичный remote (github.com без /private/ в URL, или явно public) — переключиться на режим `public`.

## Запрещено всегда (любой режим)

Эти файлы не коммитятся **никогда**, в любом типе проекта. Если их нет в `.gitignore` — добавь автоматически:

- `.env`, `.env.*` — переменные окружения
- `*.key`, `*.pem`, `*.p12` — ключи и сертификаты
- `credentials.json`, `secrets/`, `*secret*` — credentials
- `.claude/settings.local.json` — личные настройки агента
- `CLAUDE.local.md` — личные заметки
- `*.db`, `*.sqlite`, `*.sqlite3` — локальные базы данных
- `node_modules/`, `__pycache__/`, `.venv/` — зависимости
- `dist/`, `build/`, `*.egg-info/` — артефакты сборки

## Формирование .gitignore

Шаблонный `.gitignore` содержит закомментированный блок для public/shared режима. Агент включает его через `scripts/switch-repo-access.sh`:

1. При bootstrap — базовый набор (зависимости, артефакты, .env, секреты, личные файлы)
2. До первого framework commit в режиме `public`/`private-shared` — запустить `scripts/switch-repo-access.sh public --commit` или `scripts/switch-repo-access.sh private-shared --commit`
3. Если проект уже переключается из `private-solo`, тот же скрипт удаляет framework files из индекса и останавливает процесс, если они уже есть в upstream history
4. Со временем стабилизируется — новые паттерны добавляются по мере обнаружения

## Проверка перед пушем

Перед `git push` — проверить `git diff --name-only origin/main..HEAD`:
- В любом режиме: нет ли файлов из «Запрещено всегда»
- В режиме `public`/`private-shared`: нет ли dev-артефактов

Если есть — `git rm --cached`, обновить `.gitignore`, предупредить пользователя.
