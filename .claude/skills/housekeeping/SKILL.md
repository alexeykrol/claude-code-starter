---
name: housekeeping
description: "Фоновое обслуживание проекта: актуальность README, CHANGELOG, версии, .gitignore, метафайлов."
allowed-tools: Read Edit Write Glob Grep Bash
disable-model-invocation: true
---

# Skill: Housekeeping

Запускается по запросу пользователя или агента. Агент **должен вызывать housekeeping перед `git push`** — это его ответственность, не автоматический хук. Проверяет и приводит в порядок всё, что могло устареть.

## Что проверять

### 1. README.md

Прочитать README.md и сравнить с реальным состоянием проекта:

- **Описание проекта** — соответствует ли текущему функционалу?
- **Инструкция по установке** — `npm install` / `pip install` актуальны? Зависимости не изменились?
- **API / usage** — описанные endpoints, функции, CLI-команды существуют в коде?
- **Примеры** — работают ли примеры кода?

Если README устарел — обновить автоматически. Не спрашивать пользователя.

### 2. CHANGELOG.md

Если в проекте есть CHANGELOG.md:

```bash
# Коммиты после последней записи в CHANGELOG
git log --oneline $(grep -m1 -oP '\d+\.\d+\.\d+' CHANGELOG.md 2>/dev/null | head -1)..HEAD
```

Если есть незадокументированные коммиты — дописать секцию с новыми изменениями. Формат: Keep a Changelog (Added, Changed, Fixed, Removed).

Если CHANGELOG.md нет — создать, если в проекте больше 10 коммитов.

### 3. Версия

Если в проекте есть `package.json` или `pyproject.toml`:

- Проверить: были ли breaking changes (новые/удалённые API, изменение интерфейсов)?
- Если да → bump minor или major
- Если только fixes → bump patch
- Обновить версию в package.json / pyproject.toml

Не публиковать. Только обновить номер.

### 4. .gitignore audit

Проверить `git status` на наличие файлов, которые по commit-policy должны быть в `.gitignore`:

```bash
# Проверить на запрещённые паттерны в tracked files
git ls-files | grep -E '\.(env|key|pem|db|sqlite)$'
git ls-files | grep -E '^(node_modules|__pycache__|dist|build)/'
```

Если найдены — `git rm --cached`, добавить в `.gitignore`.

### 5. Метафайлы фреймворка

- `.claude/SNAPSHOT.md` — дата обновления не старше последнего коммита?
- `manifest.md` — заполнены ли project_name и repo_access?

Если SNAPSHOT устарел — обновить. Если manifest пустой — заполнить на основе анализа проекта (basename → project_name, git remote → repo_access).

### 6. Drift detection

Сравнить то, что описано в документации, с тем, что реально есть в коде:

```bash
# Пример: функции упомянутые в README но отсутствующие в коде
# Endpoints описанные в docs/ но не существующие в src/
```

Если обнаружен drift — исправить документацию автоматически.

## Когда запускать

- **Перед push** — агент обязан вызвать housekeeping перед `git push` (это правило агента, не автоматический хук)
- **По запросу** — пользователь говорит «наведи порядок» или «housekeeping»
- **При /finish** — если finish включает push

## Чего НЕ делать

- Не менять код проекта — только документацию и метафайлы
- Не пушить автоматически
- Не удалять файлы пользователя
- Не тратить больше 3 минут на housekeeping
