---
name: setup-project
description: "Установить Claude Code Starter framework в текущую папку. Авто-определение типа проекта (code/content/hybrid). Вызывается фразами: /setup-project, setup project, начать проект, инициализация, новый проект, поставь фреймворк, установи фреймворк, bootstrap framework. (Не путать с встроенной /init, которая только генерирует CLAUDE.md.)"
allowed-tools: Read Write Edit Bash Glob Grep
disable-model-invocation: false
---

# Skill: Setup Project (Framework Bootstrap)

## Назначение

Установить Claude Code Starter framework в текущую рабочую папку. Авто-определяет, что это за проект (код, контент, гибрид), создаёт минимально необходимую структуру, не повреждая существующие файлы.

## Когда применяется

- Пользователь сказал `/setup-project`, `setup project`, `bootstrap`, `поставь фреймворк`, `установи фреймворк`, `начать проект`, `инициализировать проект`, `новый проект`
- Пользователь работает в свежесозданной папке без `CLAUDE.md` и `.claude/`, и просит начать работу
- В проекте есть устаревший framework и пользователь хочет обновиться

**НЕ путать** со встроенной командой Claude Code `/setup-project` — та делает совсем другое (генерирует документационный CLAUDE.md). Этот skill — про установку framework инфраструктуры (rules, skills, agents, hooks, manifest).

## Алгоритм

### 1. Найти framework source

Проверь по порядку:

```bash
# Step 1: cached source path
if [ -f ~/.claude/framework-source-path ]; then
    FRAMEWORK_PATH=$(cat ~/.claude/framework-source-path)
fi

# Step 2: common locations
for candidate in "$FRAMEWORK_PATH" "$HOME/Code/Project_init" "$HOME/Code/claude-code-starter" "$HOME/.claude/framework-source"; do
    if [ -n "$candidate" ] && [ -f "$candidate/init-project.sh" ] && [ -f "$candidate/scripts/lib/install_common.sh" ]; then
        FRAMEWORK_PATH="$candidate"
        break
    fi
done

# Step 3: clone if missing
if [ -z "$FRAMEWORK_PATH" ]; then
    git clone https://github.com/alexeykrol/claude-code-starter.git ~/.claude/framework-source/
    FRAMEWORK_PATH=~/.claude/framework-source
fi
```

Запиши найденный путь обратно: `echo "$FRAMEWORK_PATH" > ~/.claude/framework-source-path`.

### 2. Проверить состояние текущей папки

```bash
PROJECT_DIR="$(pwd)"
HAS_FRAMEWORK="no"
[ -d ".claude" ] && [ -d ".claude/rules" ] && HAS_FRAMEWORK="yes"
HAS_CLAUDE_MD="no"
[ -f "CLAUDE.md" ] && HAS_CLAUDE_MD="yes"
TOTAL_FILES=$(find . -maxdepth 2 -type f -not -path './.git/*' 2>/dev/null | wc -l | tr -d ' ')
```

### 3. Запустить установщик

Просто вызови основной installer — он сам делает auto-detect, backup и safe merge:

```bash
bash "$FRAMEWORK_PATH/init-project.sh"
```

Если установка хочет имя проекта (свежая папка) — installer возьмёт имя текущей директории. Тип проекта определит автоматически по содержимому.

### 4. После установки

Прочитай `manifest.md` и сообщи пользователю одной строкой что получилось:

```text
✅ Framework установлен: <project_type> / <content_type>
   Backup в .claude/backup-<TIMESTAMP>/
   Откат: bash init-project.sh --rollback
   Дальше: отредактируй CLAUDE.md под проект и скажи /start
```

## Граничные случаи

### Папка уже с framework

Если `HAS_FRAMEWORK=yes`, не запускай install заново молча. Спроси одним вопросом:
- «В папке уже стоит framework. Обновить аддитивно (migrate)? [Y/n]»
- При Y — запусти `bash "$FRAMEWORK_PATH/scripts/migrate.sh" --template "$FRAMEWORK_PATH"`
- При n — ничего не делай, отчитайся

### Тяжёлый конфликт CLAUDE.md

Если установщик завершился с exit 2 — он уже записал `.claude/CLAUDE.md.merge-proposal.md` и НЕ менял файлы. Покажи пользователю короткое резюме предложения и команду применения:
```text
⚠️ Установка остановлена — конфликт в CLAUDE.md.
Я подготовил решение в .claude/CLAUDE.md.merge-proposal.md.
Применить:  bash init-project.sh --apply-proposal
```

### Не нашли git

Installer сам предлагает `git init` если репо нет. Это OK — пропусти, продолжи.

### Чего НЕ делать

- Не запускай установку молча в большом проекте, где много файлов и нет .git — сначала покажи что собираешься делать
- Не переписывай существующий CLAUDE.md «вручную» — это работа `merge_claude_md.py`
- Не задавай больше одного вопроса. Auto-detect должен покрывать 95% случаев. Если не уверен — выбери сам и скажи пользователю что выбрал

## Output

Всегда коротко: что было до, что добавлено, путь к backup, следующее действие.
