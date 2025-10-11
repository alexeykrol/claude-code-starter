---
description: Миграция существующего проекта на Claude Code Starter framework
---

# Миграция Legacy проекта на фреймворк

> Используйте эту команду для миграции существующих проектов с legacy мета-документацией на Claude Code Starter framework v1.0

## 🎯 Цель

Перенести всю ценную информацию из разрозненных мета-файлов в структурированный фреймворк, сохранив историю и обеспечив единый источник истины.

## ⚠️ ВАЖНО

Эта команда выполняет **Этап 1** миграции (анализ + перенос + архивирование).
После завершения **ТРЕБУЕТСЯ РУЧНАЯ ПРОВЕРКА** перед финализацией.
Для завершения используйте `/migrate-finalize`.

---

## 📋 Процесс миграции (Этап 1)

### Шаг 0: Проверка .migrationignore

**ВАЖНО:** Перед сканированием проверить наличие файла `.migrationignore` для исключения файлов из миграции.

#### 0.1. Проверить существование .migrationignore

```bash
if [ -f ".migrationignore" ]; then
  echo "✅ Найден .migrationignore - будут применены исключения"
else
  echo "ℹ️  .migrationignore не найден - предложить создать"
fi
```

#### 0.2. Если .migrationignore отсутствует - предложить создать

**Автоматическое определение кандидатов на исключение:**

Проанализировать файлы и определить потенциально НЕ-мета файлы:

```
Критерии для exclusion:
1. Файлы в папках: articles/, references/, research/, examples/
2. Файлы с паттернами: meeting-*.md, brainstorm-*.md, temp-*.md
3. Файлы с датами в названии: *-2024-*.md, *-2025-*.md
4. Большие файлы (>50KB) с много кода (вероятно статьи)
5. Файлы в папках: old/, archive/, deprecated/
6. Бинарные файлы: *.pdf, *.docx, *.pptx
```

**Показать пользователю:**
```
🤔 Обнаружены потенциально НЕ-мета файлы:

📄 docs/articles/how-react-works.md (15KB, много примеров кода)
   Похоже на: обучающая статья
   Рекомендация: exclude

📄 notes/meeting-2024-01-15.md (2KB, дата в названии)
   Похоже на: запись встречи
   Рекомендация: exclude

📄 docs/architecture.md (8KB, описывает структуру проекта)
   Похоже на: мета-документация проекта
   Рекомендация: migrate

Создать .migrationignore с рекомендациями? [Y/n]
```

#### 0.3. Создать .migrationignore если пользователь согласился

Если ответ "Y":
```bash
# Создать .migrationignore на основе рекомендаций
cat > .migrationignore <<EOF
# Auto-generated migration exclusions

# Reference articles
docs/articles/
docs/references/

# Meeting notes
notes/meeting-*.md

# Research
research/

# Old/archived
old/
archive/
docs/deprecated/

# Binary files
*.pdf
*.docx
EOF

echo "✅ Создан .migrationignore"
echo "   Отредактируйте файл если нужно и запустите /migrate снова"
exit 0
```

Если ответ "n":
```
ℹ️  Пропускаю создание .migrationignore
   Все найденные файлы будут обработаны
```

#### 0.4. Прочитать и применить .migrationignore

Если файл существует:
```bash
# Прочитать все паттерны (игнорируя комментарии и пустые строки)
IGNORE_PATTERNS=$(grep -v '^#' .migrationignore | grep -v '^$')

# Сохранить для использования в Шаге 1
```

### Шаг 1: Сканирование проекта

Найти все мета-файлы, которые содержат документацию проекта:

**С учетом .migrationignore если существует:**

```bash
# Искать в корне и популярных директориях
find . -maxdepth 3 -type f \( \
  -name "*.md" -o \
  -name "*.txt" -o \
  -name "README*" -o \
  -name "DOCS*" -o \
  -name "NOTES*" -o \
  -name "TODO*" \
) | grep -v "node_modules\|dist\|build\|.next\|Init\|init_eng"
```

**Исключить:**
- node_modules/, dist/, build/, .next/
- Init/ и init_eng/ (это наш новый фреймворк)
- Файлы кода (*.js, *.ts, *.py, etc)
- Lock файлы (package-lock.json, etc)

**Искать в:**
- Корневые README.md, DOCS.md, NOTES.md
- Папки docs/, documentation/, notes/, wiki/
- Файлы архитектуры: architecture.md, design.md, structure.md
- Файлы безопасности: security.md, security.txt
- Бэклоги: backlog.md, todo.md, roadmap.md
- Любые другие .md/.txt с мета-информацией

### Шаг 2: Анализ содержимого

Для каждого найденного файла:
1. Прочитать содержимое
2. Определить тип информации (архитектура, требования, процессы, безопасность, etc)
3. Создать mapping: какой legacy файл → какой Init/ файл(ы)

**Создать MAPPING:**
```
Legacy файл → Framework файл(ы)
-----------------------------------------
docs/README.md → PROJECT_INTAKE.md (секции: Overview, Goals)
docs/architecture.md → ARCHITECTURE.md
notes/security.txt → SECURITY.md
TODO.md → BACKLOG.md
api-docs.md → ARCHITECTURE.md (секция API Structure)
workflow.md → WORKFLOW.md
...
```

### Шаг 3: Обнаружение конфликтов

Проверить на потенциальные конфликты:

#### 🔴 Критические конфликты (требуют разрешения):
- **Архитектурные противоречия**: legacy описывает монолит, фреймворк предполагает модули
- **Отсутствие критичной информации**: нет документации по безопасности
- **Противоречивые требования**: в разных legacy файлах противоречащие друг другу описания
- **Устаревшая информация**: legacy содержит явно устаревшие данные

#### 🟡 Средний приоритет:
- **Дублирование информации**: одна и та же информация в нескольких местах
- **Структурные различия**: legacy организован иначе, чем фреймворк
- **Неполнота данных**: некоторые секции фреймворка невозможно заполнить из legacy

#### 🟢 Низкий приоритет:
- **Косметические различия**: naming conventions, форматирование
- **Избыточная детализация**: legacy более детален, чем нужно фреймворку

### Шаг 4: Миграция информации

Для каждого Init/ файла:

#### CLAUDE.md
- Обновить секцию "Tech Stack" из legacy документации
- Добавить специфичные для проекта инструкции из legacy
- Обновить bash-команды если они отличаются от дефолтных

#### PROJECT_INTAKE.md
- **Problem/Solution/Value** из legacy README или docs
- **User Personas** - если есть в legacy, иначе пометить [NEEDS UPDATE]
- **User Flows** - из legacy user stories или docs
- **Features** - из legacy roadmap, backlog, TODO
- **Modular Structure** - проанализировать текущий код и предложить модульную структуру

#### SECURITY.md
- Перенести существующие security practices из legacy
- Если нет legacy security docs - пометить [CRITICAL: NEEDS FILLING]
- Проанализировать код на security patterns (auth, validation, etc)

#### ARCHITECTURE.md
- **Tech Stack** из legacy
- **Folder Structure** - текущую реальную структуру проекта
- **Module Architecture** - проанализировать и предложить модульное разделение
- **API Structure** из legacy API docs
- **Database Schema** из legacy DB docs
- **Key Decisions** из legacy architecture docs (важно сохранить WHY!)

#### BACKLOG.md
- Перенести TODO, roadmap items из legacy
- Проанализировать текущий код и обновить статусы (что уже реализовано)
- Пометить legacy items как "Migrated from legacy TODO.md"

#### AGENTS.md
- Если в legacy есть специфичные инструкции для разработки - перенести
- Добавить паттерны из анализа кодовой базы

#### WORKFLOW.md
- Перенести существующие workflow из legacy
- Если нет - оставить дефолтные из шаблона

#### PLAN_TEMPLATE.md
- Оставить как есть (это шаблон для будущих задач)

#### README-TEMPLATE.md
- Не трогать (это шаблон для финального README проекта)

### Шаг 5: Архивирование legacy файлов

Создать папку archive/ и переместить туда все legacy мета-файлы:

```bash
# Создать структуру archive
mkdir -p archive/docs
mkdir -p archive/notes
mkdir -p archive/other

# Переместить файлы с сохранением структуры
# Например:
mv docs/README.md archive/docs/
mv docs/architecture.md archive/docs/
mv notes/* archive/notes/ 2>/dev/null || true
mv TODO.md archive/other/ 2>/dev/null || true
```

**В archive/ создать README.md:**
```markdown
# Archived Legacy Documentation

> These files were archived during migration to Claude Code Starter framework v1.0
> Date: [DATE]

## Migration
All information from these files has been migrated to Init/ framework files.
See MIGRATION_REPORT.md for details.

## DO NOT USE
These files are kept for historical reference only.
**Single source of truth is now Init/ folder.**
```

### Шаг 6: Создание MIGRATION_REPORT.md

Создать детальный отчет о миграции в корне проекта:

```markdown
# Migration Report

> Migration to Claude Code Starter framework v1.0
> Date: [DATE]
> Status: ⏸️ PENDING REVIEW (Step 1 complete)

## 📊 Summary

- **Total meta-files found:** [N]
- **Excluded (via .migrationignore):** [N]
- **Processed for migration:** [N]
- **Files migrated:** [N]
- **Files archived:** [N]
- **Critical conflicts:** [N]
- **Medium conflicts:** [N]
- **Low priority notes:** [N]

## 🚫 Excluded from Migration

The following files were excluded per `.migrationignore`:

### Pattern: `docs/articles/`
- docs/articles/how-jwt-works.md
- docs/articles/react-patterns.md
- docs/articles/graphql-intro.md
(22 more files...)

### Pattern: `notes/meeting-*.md`
- notes/meeting-2024-01-15.md
- notes/meeting-2024-02-20.md
(8 more files...)

**Reason:** These files are reference materials, not project documentation.
**Location:** Remain in original location. **NOT archived** - stay as-is.

**Note:** Excluded files are NOT migrated, NOT archived, and NOT modified.

## 🗂️ Migration Mapping

### Legacy → Framework

| Legacy File | Framework File(s) | Status | Notes |
|-------------|------------------|---------|-------|
| docs/README.md | PROJECT_INTAKE.md | ✅ Migrated | Sections: Overview, Goals |
| docs/architecture.md | ARCHITECTURE.md | ⚠️ Partial | Missing module structure |
| notes/security.txt | SECURITY.md | ❌ Conflict | See CONFLICTS.md #1 |
| TODO.md | BACKLOG.md | ✅ Migrated | Updated statuses based on code |
| ... | ... | ... | ... |

## 📝 Detailed Migration Log

### PROJECT_INTAKE.md
**Sources:**
- docs/README.md → Problem/Solution/Value
- TODO.md → Features list
- notes/user-research.txt → User Personas (partial)

**Added:**
- ✅ Problem statement (from docs/README.md)
- ✅ Solution description (from docs/README.md)
- ✅ Feature list (from TODO.md)
- ⚠️ User Personas (partial from notes, needs completion)
- ❌ User Flows (not found in legacy, marked [NEEDS FILLING])

### ARCHITECTURE.md
**Sources:**
- docs/architecture.md → Tech Stack, Decisions
- Code analysis → Current structure

**Added:**
- ✅ Tech Stack (from docs/architecture.md)
- ✅ Current folder structure (from code analysis)
- ⚠️ Module Architecture (proposed based on code, needs review)
- ✅ Key Decisions (from docs/architecture.md - preserved WHY!)

### SECURITY.md
**Sources:**
- No legacy security documentation found

**Added:**
- ⚠️ Analyzed code for security patterns
- ⚠️ Found: JWT auth, input validation in some routes
- ❌ Missing: comprehensive security policy
- 🔴 **CRITICAL: Requires manual filling**

### BACKLOG.md
**Sources:**
- TODO.md → Tasks
- Code analysis → Current implementation status

**Added:**
- ✅ All TODO items migrated
- ✅ Statuses updated based on code analysis
- ✅ Marked as "Migrated from legacy TODO.md"

### Other files
- AGENTS.md: ✅ Added project-specific patterns from code analysis
- WORKFLOW.md: ✅ Kept default (no legacy workflow found)
- CLAUDE.md: ✅ Updated with project tech stack

## 📦 Archived Files

All files moved to `archive/` directory:
- archive/docs/README.md
- archive/docs/architecture.md
- archive/notes/security.txt
- archive/other/TODO.md
- ... (see archive/README.md for full list)

## ⏭️ Next Steps

1. **REVIEW CONFLICTS**: Read CONFLICTS.md and resolve all issues
2. **REVIEW INIT FILES**: Check all Init/ files for accuracy and completeness
3. **FILL GAPS**: Complete sections marked [NEEDS FILLING] or [NEEDS UPDATE]
4. **VERIFY NOTHING LOST**: Compare Init/ with archive/ to ensure all critical info migrated
5. **FINALIZE**: Run `/migrate-finalize` when ready

## ⏸️ Migration Status: PAUSED

**Action required:** Review and resolve conflicts before finalizing.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Шаг 7: Создание CONFLICTS.md (если есть конфликты)

Если обнаружены конфликты, создать детальный файл:

```markdown
# Migration Conflicts Report

> ⚠️ Review and resolve these conflicts before finalizing migration

**Status:** [N] critical, [N] medium, [N] low priority conflicts

---

## 🔴 Critical Conflicts (require resolution)

### 1. [Название конфликта]
**Priority:** 🔴 Critical
**Legacy:** [Что сказано в legacy]
**Framework:** [Что предполагает фреймворк]
**Conflict:** [В чем противоречие]
**Impact:** [Почему это критично]

**Action Required:**
- [ ] [Конкретное действие 1]
- [ ] [Конкретное действие 2]
- [ ] Update affected files: [список файлов]

**Recommendation:** [Твоя рекомендация по разрешению]

---

### 2. Missing Security Documentation
**Priority:** 🔴 Critical
**Legacy:** No security documentation found in legacy files
**Framework:** SECURITY.md requires comprehensive security policy
**Conflict:** Critical security information missing
**Impact:** Cannot establish security baseline without this

**Action Required:**
- [ ] Review current code for security practices (auth, validation, sanitization)
- [ ] Interview team about security policies
- [ ] Fill all sections of SECURITY.md
- [ ] Run `/security` audit after filling

**Recommendation:** Treat as highest priority - security cannot be skipped.

---

## 🟡 Medium Priority (recommended to resolve)

### 3. [Название конфликта]
**Priority:** 🟡 Medium
**Legacy:** [Что в legacy]
**Framework:** [Что во фреймворке]
**Conflict:** [Противоречие]
**Impact:** [Влияние]

**Suggestion:**
- [ ] [Действие]

---

## 🟢 Low Priority (can postpone)

### 4. [Название конфликта]
**Priority:** 🟢 Low
**Legacy:** [Что в legacy]
**Framework:** [Что во фреймворке]
**Conflict:** [Противоречие]
**Impact:** Minimal - cosmetic/organizational

**Suggestion:** [Рекомендация]

---

## Summary & Next Steps

**Before finalizing migration, you MUST:**
1. ✅ Resolve all 🔴 Critical conflicts
2. ⚠️ Review all 🟡 Medium conflicts (strongly recommended)
3. 📝 Document decisions in appropriate Init/ files

**After resolving conflicts:**
- Run `/migrate-finalize` to complete migration

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Шаг 8: Вывод результата

После завершения всех шагов вывести пользователю:

```
✅ Миграция (Этап 1) завершена!

📊 Результаты:
- Всего найдено мета-файлов: [N]
- Исключено (.migrationignore): [N]
- Обработано для миграции: [N]
- Перенесено в Init/: [N]
- Архивировано в archive/: [N]
- Обнаружено конфликтов: [N] (🔴 [critical] 🟡 [medium] 🟢 [low])

ℹ️  Исключенные файлы:
- [N] файлов исключено через .migrationignore
- Остаются в исходном расположении (НЕ архивируются)
- См. детали в MIGRATION_REPORT.md секция "Excluded from Migration"

📄 Созданные файлы:
- ✅ MIGRATION_REPORT.md - детальный отчет о миграции
- ⚠️ CONFLICTS.md - конфликты требующие разрешения (если есть)
- ✅ archive/README.md - пояснение для архива
- ✅ Init/ - все файлы заполнены из legacy

⏸️ МИГРАЦИЯ ПРИОСТАНОВЛЕНА ДЛЯ ПРОВЕРКИ

📋 ЧТО ДЕЛАТЬ ДАЛЬШЕ:

1. **Прочитайте MIGRATION_REPORT.md**
   - Проверьте mapping: все ли файлы учтены
   - Убедитесь что ничего важного не потеряно

2. **Если есть CONFLICTS.md - разрешите конфликты**
   - Начните с 🔴 критических
   - Обновите Init/ файлы соответственно
   - Удалите CONFLICTS.md когда все разрешите

3. **Проверьте Init/ файлы**
   - PROJECT_INTAKE.md - все ли секции заполнены?
   - SECURITY.md - критично важно!
   - ARCHITECTURE.md - корректна ли архитектура?
   - BACKLOG.md - актуальны ли статусы?

4. **Заполните пробелы**
   - Найдите [NEEDS FILLING] и заполните
   - Найдите [NEEDS UPDATE] и обновите

5. **Когда все готово - финализируйте миграцию**
   ```
   /migrate-finalize
   ```

⚠️ НЕ УДАЛЯЙТЕ:
- MIGRATION_REPORT.md (нужен для финализации)
- CONFLICTS.md (если есть - разрешите конфликты)
- archive/ (это история проекта)

💡 Можно попросить AI помочь:
- "Помоги разрешить конфликт #1 в CONFLICTS.md"
- "Заполни секцию User Flows в PROJECT_INTAKE.md"
- "Проверь все Init/ файлы на полноту"
```

---

## 🔐 Важные проверки

Перед завершением миграции проверить:

### Безопасность
- [ ] Не перенесли ли случайно секреты из legacy (API keys, passwords)
- [ ] В archive/ нет файлов с credentials
- [ ] SECURITY.md заполнен или помечен как [CRITICAL]

### Полнота
- [ ] Все критичные legacy файлы учтены в MIGRATION_REPORT.md
- [ ] Архитектурные решения и их WHY сохранены
- [ ] TODO items перенесены
- [ ] Tech stack актуален

### Структура
- [ ] archive/ содержит все legacy файлы
- [ ] archive/README.md создан
- [ ] Init/ файлы корректно заполнены
- [ ] Конфликты документированы

---

## 🚫 НЕ ДЕЛАЙ

- ❌ Не удаляй legacy файлы (только перемещай в archive/)
- ❌ Не финализируй миграцию автоматически (нужна проверка пользователя)
- ❌ Не пропускай CONFLICTS.md если есть критичные конфликты
- ❌ Не переноси секреты/credentials в Init/ файлы
- ❌ Не игнорируй пробелы в SECURITY.md

---

## 💡 Tips

1. **Сохраняй WHY, не только WHAT** - при миграции архитектурных решений критично сохранить обоснование (почему было принято такое решение)

2. **Проверяй код, не только документацию** - если legacy docs устарели, анализируй реальный код

3. **Модульность - это ключ** - при миграции на фреймворк самое время спланировать модульную структуру

4. **Legacy ≠ Truth** - если legacy содержит явно устаревшую информацию, обнови её, не копируй слепо

5. **Документируй решения** - все неочевидные решения при миграции документируй в MIGRATION_REPORT.md

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
