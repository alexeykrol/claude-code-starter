---
description: Миграция существующего проекта на Claude Code Starter framework
---

# Миграция проекта на Claude Code Starter

## 🎯 Что делает эта команда

**Этап 1: Анализ и перенос (автоматически)**

1. Сканирует все meta-файлы проекта
2. Переносит информацию в Init/ структуру
3. Архивирует legacy файлы в `archive/`
4. Создает `MIGRATION_REPORT.md`
5. Создает `CONFLICTS.md` (если есть конфликты)
6. ⏸️ **ОСТАНАВЛИВАЕТСЯ** для проверки

**После выполнения этой команды:**
- Используй `/migrate-resolve` для разрешения конфликтов
- Используй `/migrate-finalize` для завершения миграции
- Используй `/migrate-rollback` для отката

---

## 📋 Процесс миграции - Stage 1

### Шаг 1: Сканирование meta-файлов

**Задача:** Найти все существующие meta-файлы проекта

**Действие:**
\`\`\`bash
# Сканируем корень проекта на предмет meta-файлов
find . -maxdepth 1 -type f \( \
  -name "CLAUDE.md" -o \
  -name "PROJECT_INTAKE.md" -o \
  -name "SECURITY.md" -o \
  -name "ARCHITECTURE.md" -o \
  -name "BACKLOG.md" -o \
  -name "AGENTS.md" -o \
  -name "WORKFLOW.md" -o \
  -name "PLAN*.md" -o \
  -name "spec.md" -o \
  -name "project-requirements.md" -o \
  -name "NOTES.md" \
\)
\`\`\`

**Результат:**
- Список найденных файлов
- Понимание, какие файлы нужно мигрировать

---

### Шаг 2: Создание структуры archive/

**Задача:** Создать папку для архивирования legacy файлов

**Действие:**
\`\`\`bash
# Создаем структуру для архива
mkdir -p archive/legacy-docs
mkdir -p archive/backup-\$(date +%Y%m%d-%H%M%S)
\`\`\`

**Результат:**
\`\`\`
archive/
├── legacy-docs/          # Для всех старых meta-файлов
└── backup-20241012-143022/  # Timestamped backup
\`\`\`

---

### Шаг 3: Анализ содержимого файлов

**Задача:** Прочитать и проанализировать каждый найденный файл

**Для каждого файла:**

1. **Прочитать содержимое** с помощью Read tool
2. **Определить категорию информации:**
   - Project requirements → PROJECT_INTAKE.md
   - Security rules → SECURITY.md
   - Architecture decisions → ARCHITECTURE.md
   - Task backlog → BACKLOG.md
   - AI instructions → AGENTS.md
   - Workflow processes → WORKFLOW.md

3. **Выявить дубликаты информации**
4. **Найти противоречия** между файлами

---

### Шаг 4: Маппинг legacy → Init/

**Задача:** Создать карту переноса информации

**Mapping table:**

| Legacy File | → | Init/ Target | Section |
|-------------|---|--------------|---------|
| \`spec.md\` | → | \`PROJECT_INTAKE.md\` | Problem/Solution/MVP |
| \`project-requirements.md\` | → | \`PROJECT_INTAKE.md\` | Requirements |
| \`SECURITY.md\` (old) | → | \`SECURITY.md\` (new) | Merge rules |
| \`ARCHITECTURE.md\` (old) | → | \`ARCHITECTURE.md\` (new) | Preserve decisions |
| \`BACKLOG.md\` (old) | → | \`BACKLOG.md\` (new) | Current status |
| \`CLAUDE.md\` (old) | → | \`AGENTS.md\` | Custom instructions |
| \`NOTES.md\` | → | \`AGENTS.md\` or \`WORKFLOW.md\` | Depends on content |
| \`PLAN*.md\` | → | \`archive/legacy-docs/\` | Reference only |

---

### Шаг 5: Перенос информации

**Задача:** Заполнить Init/ файлы информацией из legacy файлов

**Для PROJECT_INTAKE.md:**
\`\`\`markdown
# Источники:
- spec.md → секция "Problem & Solution"
- project-requirements.md → секция "Requirements"
- README.md → секция "Project Overview"

# Логика переноса:
1. Читаем spec.md
2. Извлекаем проблему, решение, MVP
3. Заполняем соответствующие секции PROJECT_INTAKE.md
4. Помечаем [MIGRATED FROM: spec.md]
\`\`\`

**Для SECURITY.md:**
\`\`\`markdown
# Логика:
1. Если старый SECURITY.md существует → сравнить с новым шаблоном
2. Добавить специфичные для проекта правила в секцию "Project-Specific Rules"
3. Сохранить оригинал в archive/
\`\`\`

**Для ARCHITECTURE.md:**
\`\`\`markdown
# Логика:
1. Извлечь все архитектурные решения
2. Заполнить секцию "Key Decisions"
3. Обновить Tech Stack
4. Сохранить legacy версию в archive/
\`\`\`

**Для AGENTS.md:**
\`\`\`markdown
# Логика:
1. Извлечь кастомные инструкции из старого CLAUDE.md
2. Добавить в секцию "Custom Instructions"
3. Извлечь паттерны из NOTES.md
4. Заполнить секцию "Common Patterns"
\`\`\`

---

### Шаг 6: Детекция конфликтов

**Задача:** Найти противоречия в информации

**Типы конфликтов:**

1. **Дубликаты с разными данными**
   \`\`\`
   spec.md: "Database: PostgreSQL"
   ARCHITECTURE.md: "Database: MongoDB"
   \`\`\`

2. **Противоречивые требования**
   \`\`\`
   PROJECT_INTAKE.md: "Must support 1000 users"
   spec.md: "MVP for 100 users"
   \`\`\`

3. **Устаревшая информация**
   \`\`\`
   BACKLOG.md: "Auth module: in progress"
   Git history: Auth module committed 2 months ago
   \`\`\`

**Действие:**
- Записать все конфликты в \`CONFLICTS.md\`
- Пометить conflicted секции в Init/ файлах как \`[CONFLICT: see CONFLICTS.md]\`

---

### Шаг 7: Архивирование legacy файлов

**Задача:** Перенести старые файлы в archive/

**Действие:**
\`\`\`bash
# Для каждого legacy файла:
mv CLAUDE.md archive/legacy-docs/CLAUDE.md.old
mv spec.md archive/legacy-docs/spec.md
mv project-requirements.md archive/legacy-docs/project-requirements.md
# etc...

# Создаем README в archive/
cat > archive/README.md << 'EOF'
# Legacy Documentation Archive

Эта папка содержит старые meta-файлы проекта до миграции на Claude Code Starter framework.

## Дата миграции: \$(date +%Y-%m-%d)

## Архивированные файлы:
[список файлов]

## Не удаляйте эти файлы!
Они могут понадобиться для разрешения конфликтов миграции.

После успешной миграции (через 1-2 спринта) можно безопасно удалить эту папку.
EOF
\`\`\`

---

### Шаг 8: Создание MIGRATION_REPORT.md

**Задача:** Создать отчет о миграции

**Структура отчета:**

\`\`\`markdown
# Migration Report - Stage 1

**Date:** \$(date +%Y-%m-%d %H:%M:%S)
**Framework Version:** 1.2.4

---

## 📊 Summary

- **Legacy files found:** [count]
- **Files migrated:** [count]
- **Files archived:** [count]
- **Conflicts detected:** [count]

---

## 📂 Files Processed

### Migrated to Init/:
- ✅ spec.md → PROJECT_INTAKE.md (Problem, Solution, MVP)
- ✅ SECURITY.md.old → SECURITY.md (merged rules)
- ✅ ARCHITECTURE.md.old → ARCHITECTURE.md (preserved decisions)
[... etc]

### Archived to archive/legacy-docs/:
- 📦 spec.md
- 📦 project-requirements.md
- 📦 CLAUDE.md.old
[... etc]

---

## ⚠️ Conflicts Detected

[If conflicts exist, list them here with references to CONFLICTS.md]

**Action required:** Run \`/migrate-resolve\` to resolve conflicts

---

## ✅ Next Steps

1. **Review migrated content:**
   - Read PROJECT_INTAKE.md
   - Read ARCHITECTURE.md
   - Read BACKLOG.md

2. **Resolve conflicts (if any):**
   \`\`\`
   /migrate-resolve
   \`\`\`

3. **Finalize migration:**
   \`\`\`
   /migrate-finalize
   \`\`\`

4. **OR rollback if needed:**
   \`\`\`
   /migrate-rollback
   \`\`\`

---

## 📋 Checklist Before Finalize

- [ ] PROJECT_INTAKE.md reviewed and accurate
- [ ] SECURITY.md contains all project-specific rules
- [ ] ARCHITECTURE.md reflects current architecture
- [ ] BACKLOG.md shows current project status
- [ ] All conflicts resolved (if any)
- [ ] Legacy files safely archived

---

*Generated by /migrate command*
\`\`\`

---

### Шаг 9: Создание CONFLICTS.md (если есть конфликты)

**Задача:** Документировать все найденные противоречия

**Структура:**

\`\`\`markdown
# Migration Conflicts

Обнаружены противоречия в legacy документации. Требуется ручное разрешение.

---

## Conflict 1: Database Choice

**Location:** PROJECT_INTAKE.md - Tech Stack

**Sources:**
- \`spec.md\` line 45: "Database: PostgreSQL with Prisma ORM"
- \`ARCHITECTURE.md.old\` line 12: "Using MongoDB with Mongoose"

**Current state:** [CONFLICT]

**Options:**
1. Use PostgreSQL (spec.md)
2. Use MongoDB (ARCHITECTURE.md)
3. Specify different choice

**Resolution:** [FILL IN]

---

## Conflict 2: User Capacity

**Location:** PROJECT_INTAKE.md - Non-Functional Requirements

**Sources:**
- \`spec.md\`: "MVP should support 100 concurrent users"
- \`project-requirements.md\`: "Must support 1000+ concurrent users"

**Current state:** [CONFLICT]

**Options:**
1. MVP target: 100 users (spec.md)
2. Full target: 1000+ users (requirements)
3. Specify phased approach

**Resolution:** [FILL IN]

---

[... more conflicts]

---

## How to Resolve

1. For each conflict, choose one option or specify custom resolution
2. Update the corresponding Init/ file with chosen resolution
3. Run \`/migrate-resolve\` to mark conflicts as resolved
4. Run \`/migrate-finalize\` to complete migration
\`\`\`

---

## 🎯 Execution

**Эта команда выполняет следующие действия:**

1. **Сканирование:**
   - Использую \`find\` и \`Glob\` для поиска всех meta-файлов
   - Использую \`Read\` для чтения содержимого

2. **Анализ:**
   - Использую \`Grep\` для поиска ключевых секций
   - Анализирую структуру и содержание
   - Выявляю дубликаты и противоречия

3. **Перенос:**
   - Использую \`Read\` для legacy файлов
   - Использую \`Edit\` для обновления Init/ файлов
   - Добавляю маркеры \`[MIGRATED FROM: filename.md]\`

4. **Архивирование:**
   - Использую \`Bash\` для создания archive/ структуры
   - Перемещаю legacy файлы с помощью \`mv\`
   - Создаю archive/README.md

5. **Отчетность:**
   - Использую \`Write\` для создания MIGRATION_REPORT.md
   - Использую \`Write\` для создания CONFLICTS.md (если нужно)

---

## ⏸️ Остановка для проверки

**После выполнения всех шагов, я остановлюсь и предоставлю:**

1. ✅ **MIGRATION_REPORT.md** - полный отчет
2. ⚠️ **CONFLICTS.md** - список конфликтов (если есть)
3. 📊 **Summary** - краткая статистика

**Ты должен:**
1. Прочитать MIGRATION_REPORT.md
2. Проверить Init/ файлы
3. Разрешить конфликты (если есть) через \`/migrate-resolve\`
4. Запустить \`/migrate-finalize\` для завершения

**Или:**
- Запустить \`/migrate-rollback\` для отката миграции

---

## 🚨 Safety

- ✅ Все legacy файлы сохранены в \`archive/\`
- ✅ Timestamped backup создан
- ✅ Можно откатить через \`/migrate-rollback\`
- ✅ Git commit создается только в \`/migrate-finalize\`

---

**Готов начать миграцию? Дай команду, и я начну Stage 1!**
