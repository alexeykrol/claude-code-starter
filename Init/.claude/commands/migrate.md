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

## 🎯 Execution Mode

**КРИТИЧНО: Stage 1 выполняется ПОЛНОСТЬЮ АВТОМАТИЧЕСКИ без остановок!**

### Правила выполнения:

1. **Группируй изменения:**
   - ОДИН `Edit` call на Init/ файл (не множественные Updates)
   - Собери ВСЕ изменения для файла в один diff
   - Пример: Все обновления PROJECT_INTAKE.md → один Edit call

2. **Не жди подтверждений:**
   - Выполняй все tool calls без пауз между ними
   - Edit → Edit → Edit → Bash → Write
   - Не ожидай ответа пользователя между шагами

3. **Обязательные файлы:**
   - MIGRATION_REPORT.md - ВСЕГДА создавай
   - CONFLICTS.md - создавай при ЛЮБЫХ conflicts (включая 🟢 low priority)
   - archive/README.md - ВСЕГДА создавай
   - SECURITY.md - ВСЕГДА обновляй project-specific rules

4. **Останавливайся ТОЛЬКО после:**
   - ✅ Все Init/ файлы обновлены (включая SECURITY.md!)
   - ✅ Все legacy файлы в archive/legacy-docs/
   - ✅ archive/backup-YYYYMMDD-HHMMSS/ создан с копиями
   - ✅ MIGRATION_REPORT.md создан
   - ✅ CONFLICTS.md создан (если есть конфликты)
   - ✅ Показано PAUSE сообщение

**НЕ добавляй рекомендации, commit messages, или дополнительные инструкции в финальном выводе!**

---

## 💡 Оптимизация использования токенов

Для экономии токенов при миграции:

1. **Группируй изменения:**
   - Собери ВСЕ изменения для одного Init/ файла
   - Используй ОДИН `Edit` call на файл (не множественные Updates)
   - Пример: 6 updates PROJECT_INTAKE.md → 1 большой Edit

2. **Целевое чтение:**
   - Не читай весь template файл повторно (775 строк)
   - Используй targeted edit с явными line numbers
   - Читай только необходимые секции legacy файлов

3. **Батчинг операций:**
   - Группируй несколько tool calls в один message где возможно
   - Пример: Edit PROJECT_INTAKE + Edit ARCHITECTURE + Bash mkdir в одном message

4. **Упрощение репорта:**
   - MIGRATION_REPORT детальный, но не избыточный
   - Финальное сообщение краткое (только 4 действия)

**Цель:** Миграция 2-3 legacy файлов = ~40-50k токенов (не 87k+)

---

## 📋 Процесс миграции - Stage 1

### Шаг 1: Сканирование meta-файлов

**Задача:** Найти все существующие meta-файлы проекта

**Действие:**
```bash
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
```

**Результат:**
- Список найденных файлов
- Понимание, какие файлы нужно мигрировать

---

### Шаг 2: Создание структуры archive/

**Задача:** Создать папку для архивирования legacy файлов

**Действие:**
```bash
# Создаем структуру для архива
mkdir -p archive/legacy-docs
mkdir -p archive/backup-$(date +%Y%m%d-%H%M%S)
```

**Результат:**
```
archive/
├── legacy-docs/          # Для всех старых meta-файлов
└── backup-20241012-143022/  # Timestamped backup
```

**ВАЖНО:** Обязательно создавай ОБЕ папки:
- `archive/legacy-docs/` - для основного архива
- `archive/backup-YYYYMMDD-HHMMSS/` - для timestamped backup

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
| `spec.md` | → | `PROJECT_INTAKE.md` | Problem/Solution/MVP |
| `project-requirements.md` | → | `PROJECT_INTAKE.md` | Requirements |
| `SECURITY.md` (old) | → | `SECURITY.md` (new) | Merge rules |
| `ARCHITECTURE.md` (old) | → | `ARCHITECTURE.md` (new) | Preserve decisions |
| `BACKLOG.md` (old) | → | `BACKLOG.md` (new) | Current status |
| `CLAUDE.md` (old) | → | `AGENTS.md` | Custom instructions |
| `NOTES.md` | → | `AGENTS.md` or `WORKFLOW.md` | Depends on content |
| `PLAN*.md` | → | `archive/legacy-docs/` | Reference only |

---

### Шаг 5: Перенос информации

**Задача:** Заполнить Init/ файлы информацией из legacy файлов

**Для PROJECT_INTAKE.md:**
```markdown
# Источники:
- spec.md → секция "Problem & Solution"
- project-requirements.md → секция "Requirements"
- README.md → секция "Project Overview"

# Логика переноса:
1. Читаем spec.md
2. Извлекаем проблему, решение, MVP
3. Заполняем соответствующие секции PROJECT_INTAKE.md
4. Добавляем маркер: <!-- MIGRATED FROM: spec.md -->
```

**Добавляй маркеры источников:**

В начале каждой обновленной секции Init/ файла добавляй комментарий:

```markdown
<!-- MIGRATED FROM: README.md -->
## Tech Stack
...

<!-- MIGRATED FROM: spec.md -->
## Security Architecture
...
```

Это поможет отслеживать откуда пришла информация.

---

**Для SECURITY.md:**

**КРИТИЧНО: ВСЕГДА обновляй SECURITY.md!**

Даже если template comprehensive - добавь project-specific rules:

```markdown
# Логика:
1. Читай legacy файлы и ищи security-related информацию:
   - Как хранятся API ключи
   - Архитектура безопасности (serverless/backend/etc)
   - Client vs Server secrets
   - Environment variables
   - Особые security practices проекта

2. Найди секцию "## 🔒 Project-Specific Security Rules" в Init/SECURITY.md

3. Добавь специфичные правила проекта

4. Сохрани оригинал в archive/legacy-docs/ (если был)
```

**Пример добавления в SECURITY.md:**

```markdown
## 🔒 Project-Specific Security Rules

### API Key Management
- ✅ API ключи НИКОГДА не передаются на клиент
- ✅ Serverless backend создает сессии с API key
- ✅ Клиент получает только `client_secret` для подключения
- ❌ НИКОГДА не храни `OPENAI_API_KEY` в frontend коде

### Architecture Security
- ✅ Backend: Vite middleware (dev) + Netlify Functions (prod)
- ✅ Environment: `.env` файл для секретов (НЕ коммитить!)
- ✅ Client: Получает только safe credentials через API call

<!-- MIGRATED FROM: spec.md, README.md -->
```

**НЕ ПРОПУСКАЙ обновление SECURITY.md!** Даже если в legacy файлах мало security info - добавь что нашел.

---

**Для ARCHITECTURE.md:**
```markdown
# Логика:
1. Извлечь все архитектурные решения
2. Заполнить секцию "Key Decisions" с обоснованием (WHY!)
3. Обновить Tech Stack
4. Добавить маркер: <!-- MIGRATED FROM: architecture.md -->
5. Сохранить legacy версию в archive/legacy-docs/
```

---

**Для AGENTS.md:**
```markdown
# Логика:
1. Извлечь кастомные инструкции из старого CLAUDE.md
2. Добавить в секцию "Custom Instructions"
3. Извлечь паттерны из NOTES.md
4. Заполнить секцию "Common Patterns"
5. Добавить маркер: <!-- MIGRATED FROM: CLAUDE.md, NOTES.md -->
```

---

### Шаг 6: Детекция конфликтов

**Задача:** Найти противоречия в информации

**Типы конфликтов:**

1. **Дубликаты с разными данными**
   ```
   spec.md: "Database: PostgreSQL"
   ARCHITECTURE.md: "Database: MongoDB"
   ```

2. **Противоречивые требования**
   ```
   PROJECT_INTAKE.md: "Must support 1000 users"
   spec.md: "MVP for 100 users"
   ```

3. **Устаревшая информация**
   ```
   BACKLOG.md: "Auth module: in progress"
   Git history: Auth module committed 2 months ago
   ```

4. **🟢 Low priority notes:**
   ```
   Typo в названии файла: scpec.md → должно быть spec.md
   Устаревшие комментарии
   Несоответствия в formatting
   ```

**Действие:**
- Записать ВСЕ конфликты в `CONFLICTS.md` (включая low priority!)
- Пометить conflicted секции в Init/ файлах как `[CONFLICT: see CONFLICTS.md]`

---

### Шаг 7: Архивирование legacy файлов

**Задача:** Перенести старые файлы в archive/

**Действие:**
```bash
# Для каждого legacy файла:
mv README.md archive/legacy-docs/README.md
mv spec.md archive/legacy-docs/spec.md
mv project-requirements.md archive/legacy-docs/project-requirements.md
# etc...

# ВАЖНО: Копируем в backup
cp -r archive/legacy-docs/* archive/backup-$(date +%Y%m%d-%H%M%S)/

# Создаем README в archive/
cat > archive/README.md << 'EOF'
# Legacy Documentation Archive

Эта папка содержит старые meta-файлы проекта до миграции на Claude Code Starter framework.

## Дата миграции: $(date +%Y-%m-%d)

## Архивированные файлы:
[список файлов]

## Не удаляйте эти файлы!
Они могут понадобиться для разрешения конфликтов миграции.

После успешной миграции (через 1-2 спринта) можно безопасно удалить эту папку.
EOF
```

---

### Шаг 8: Создание MIGRATION_REPORT.md

**Задача:** Создать отчет о миграции

**Обязательный формат заголовка:**

```markdown
# Migration Report - Stage 1

**Date:** $(date +%Y-%m-%d %H:%M:%S)  ← ОБЯЗАТЕЛЬНО С ВРЕМЕНЕМ
**Framework Version:** 1.2.4

---

## 📊 Summary

- **Legacy files found:** [count]
- **Files migrated:** [count]
- **Files archived:** [count]
- **Conflicts detected:** [count] (🔴 X 🟡 Y 🟢 Z)

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

**Action required:** Run `/migrate-resolve` to resolve conflicts

---

## ✅ Next Steps

1. **Review migrated content:**
   - Read PROJECT_INTAKE.md
   - Read ARCHITECTURE.md
   - Read BACKLOG.md

2. **Resolve conflicts (if any):**
   ```
   /migrate-resolve
   ```

3. **Finalize migration:**
   ```
   /migrate-finalize
   ```

4. **OR rollback if needed:**
   ```
   /migrate-rollback
   ```

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
```

**НЕ используй:**
- Blockquote `>` для заголовка
- "Status: COMPLETED" в заголовке
- Дополнительные поля в Summary (только 4 основных + conflicts breakdown)

**Используй точно такой формат** как в шаблоне выше.

---

### Шаг 9: Создание CONFLICTS.md (если есть конфликты)

**Задача:** Документировать все найденные противоречия

**Создавай CONFLICTS.md если есть ЛЮБЫЕ конфликты, включая:**
- 🔴 Critical conflicts (MUST resolve)
- 🟡 Medium conflicts (SHOULD resolve)
- 🟢 **Low priority notes** ← ВКЛЮЧАЯ заметки о typo, naming, etc!

**Критерий создания:** Если есть ЧТО УГОДНО что требует внимания пользователя - создавай CONFLICTS.md.

**Примеры low priority conflicts:**
- Typo в названии файла (scpec.md → spec.md)
- Устаревшие комментарии
- Несоответствия в formatting
- Дублирование мелких деталей

Даже если это не "конфликт" в строгом смысле - документируй в CONFLICTS.md для полноты.

**Структура:**

```markdown
# Migration Conflicts

Обнаружены противоречия в legacy документации. Требуется ручное разрешение.

---

## Conflict 1: Database Choice (🔴 Critical)

**Location:** PROJECT_INTAKE.md - Tech Stack

**Sources:**
- `spec.md` line 45: "Database: PostgreSQL with Prisma ORM"
- `ARCHITECTURE.md.old` line 12: "Using MongoDB with Mongoose"

**Current state:** [CONFLICT]

**Options:**
1. Use PostgreSQL (spec.md)
2. Use MongoDB (ARCHITECTURE.md)
3. Specify different choice

**Resolution:** [FILL IN]

---

## Conflict 2: Filename Typo (🟢 Low Priority)

**Issue:** Legacy file named `scpec.md` (typo - should be `spec.md`)

**Location:** archive/legacy-docs/scpec.md

**Impact:** None (file already archived)

**Options:**
1. Leave as-is in archive (recommended)
2. Rename to spec.md in archive
3. Ignore

**Resolution:** [FILL IN]

---

[... more conflicts]

---

## How to Resolve

1. For each conflict, choose one option or specify custom resolution
2. Update the corresponding Init/ file with chosen resolution
3. Run `/migrate-resolve` to mark conflicts as resolved
4. Run `/migrate-finalize` to complete migration
```

---

## 🎯 Execution

**Эта команда выполняет следующие действия:**

1. **Сканирование:**
   - Использую `find` и `Glob` для поиска всех meta-файлов
   - Использую `Read` для чтения содержимого

2. **Анализ:**
   - Использую `Grep` для поиска ключевых секций
   - Анализирую структуру и содержание
   - Выявляю дубликаты и противоречия

3. **Перенос:**
   - Использую `Read` для legacy файлов
   - Использую `Edit` для обновления Init/ файлов (ОДИН Edit на файл!)
   - Добавляю маркеры `<!-- MIGRATED FROM: filename.md -->`

4. **Архивирование:**
   - Использую `Bash` для создания archive/ структуры
   - Создаю ОБЕ папки: legacy-docs/ и backup-YYYYMMDD/
   - Перемещаю legacy файлы с помощью `mv`
   - Копирую в backup с помощью `cp -r`
   - Создаю archive/README.md

5. **Отчетность:**
   - Использую `Write` для создания MIGRATION_REPORT.md (точный формат!)
   - Использую `Write` для создания CONFLICTS.md (если нужно)

---

## ⏸️ Остановка для проверки

**После выполнения ВСЕХ шагов, покажи ТОЛЬКО это сообщение:**

```
⏸️ МИГРАЦИЯ STAGE 1 ЗАВЕРШЕНА - ПРИОСТАНОВКА ДЛЯ ПРОВЕРКИ

📊 Результаты:
- Legacy files found: [count]
- Migrated to Init/: [count]
- Archived to archive/legacy-docs/: [count]
- Conflicts detected: [count] (🔴 X 🟡 Y 🟢 Z)

📋 СЛЕДУЮЩИЕ ДЕЙСТВИЯ:

1. **Прочитать отчет:**
   cat MIGRATION_REPORT.md

2. **Разрешить конфликты** (если есть):
   /migrate-resolve

3. **Финализировать миграцию:**
   /migrate-finalize

4. **Откатить** (если нужно):
   /migrate-rollback

---

Детали миграции смотри в MIGRATION_REPORT.md
```

**ВАЖНО:**
- НЕ добавляй commit message примеры
- НЕ добавляй рекомендации по улучшению
- НЕ добавляй инструкции по созданию README
- НЕ добавляй токен-статистику
- НЕ добавляй дополнительные советы
- **ТОЛЬКО 4 действия выше + ссылка на репорт**

Пользователь может задать вопросы после прочтения репорта.

---

## 🚨 Safety

- ✅ Все legacy файлы сохранены в `archive/legacy-docs/`
- ✅ Timestamped backup создан в `archive/backup-YYYYMMDD/`
- ✅ Можно откатить через `/migrate-rollback`
- ✅ Git commit создается только в `/migrate-finalize`

---

**Готов начать миграцию? Дай команду, и я начну Stage 1!**
