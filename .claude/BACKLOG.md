# BACKLOG — Claude Code Starter Framework

*Последнее обновление: 2025-12-09*

> 📋 **SINGLE SOURCE OF TRUTH для текущих задач**
>
> Этот файл содержит только конкретные согласованные задачи, которые точно делаем.
>
> **Workflow:**
> - 💡 Сырые идеи → [IDEAS.md](./IDEAS.md)
> - 🗺️ Структурированные фичи (v2.2+) → [ROADMAP.md](./ROADMAP.md)
> - 🎯 Конкретные задачи (сейчас) → **BACKLOG.md** (этот файл)
> - ✅ Завершенное → Архив (внизу)

---

## 🎯 Текущие задачи (приоритизированные)

### Phase 4: Distribution v2.1.1 ⏳

**Статус:** В работе
**Цель:** Финализировать v2.1.1 и создать релиз

**Задачи:**
- [ ] Тестирование init-project.sh на legacy проектах
  - [ ] chatRAG (уже протестировано, найдены баги)
  - [ ] Другие проекты с Framework v1.x
- [x] Создать GitHub Release v2.1.1
  - [x] Загрузить init-project.sh (16KB)
  - [x] Загрузить framework.tar.gz (64KB)
  - [x] Написать Release Notes
- [x] Обновить README.md с инструкциями по установке
  - [x] Упрощенная секция установки (6 шагов)
  - [x] Уточнение про qualifying questions (legacy vs новый)
  - [x] Упрощенный roadmap (только ссылка)
  - [x] Единая процедура для всех сценариев
- [x] Реализовать автоматическую установку для нового проекта
  - [x] init-project.sh создает migration-context.json для всех режимов
  - [x] CLAUDE.md обрабатывает "mode": "new"
  - [x] Единое сообщение "Миграция завершена!"
- [x] Упростить qualifying questions
  - [x] Добавить явную опцию "Сделай, как лучше"
  - [x] Упростить migration summary (краткая сводка вместо больших таблиц)
- [ ] Объявить релиз пользователям

**GitHub Issues:**
- Связанные: #4 (init-project.sh не копирует .claude/commands/)

---

## 📚 Архив (завершённые фазы)

<details>
<summary>Phase 3.5: Bug Fixes v2.1.1 ✅ (2025-12-08)</summary>

### Исправленные баги:
1. **watcher.ts parasitic folders** — Fixed cwd to prevent `project-name-dialog` folders
2. **sed escaping** — Added `sed_escape()` function for special characters
3. **Token economy** — Redesigned to loader pattern (88KB → 5.3KB, 16.6x!)
4. **Legacy metafile preservation** — Don't overwrite existing SNAPSHOT/BACKLOG/ARCHITECTURE

**Source:** BUG_REPORT_FRAMEWORK.md from chatRAG production testing

</details>

<details>
<summary>Phase 3: Installation System ✅ (2025-12-08)</summary>

- [x] migration/templates/ structure
- [x] init-project.sh loader (5.3KB)
- [x] build-distribution.sh
- [x] README cleanup
- [x] dist-release/ gitignored

</details>

<details>
<summary>Phase 2: Protocol Verification ✅</summary>

- [x] Cold Start Protocol implemented
- [x] Completion Protocol (/fi) implemented
- [x] Dialog Export UI (Teacher + Student)
- [x] Crash Recovery tested

</details>

<details>
<summary>Phase 1: Framework Restructuring ✅ (v2.0.0)</summary>

- [x] src/claude-export/ TypeScript source
- [x] dist/claude-export/ compiled
- [x] npm project structure
- [x] Full protocols in CLAUDE.md

</details>

<details>
<summary>v1.4.3 — Sprint Completion ✅ (2025-10-23)</summary>

- 5-layer reminder system
- Sprint Completion Protocol
- Dogfooding (framework uses itself)

</details>

<details>
<summary>v1.4.0 — Cold Start ✅ (2025-10-11)</summary>

- PROJECT_SNAPSHOT.md template
- 85% token economy improvement

</details>

---

## 📊 Структура текущей версии (v2.1.1)

```
claude-code-starter/
├── src/claude-export/     # TypeScript source
├── dist/claude-export/    # Compiled JS
├── .claude/
│   ├── commands/          # 19 slash commands
│   ├── SNAPSHOT.md        # Current state
│   ├── ARCHITECTURE.md    # Code structure
│   └── BACKLOG.md         # THIS FILE
├── migration/
│   ├── init-project.sh    # Installer template (5.3KB)
│   ├── build-distribution.sh
│   └── templates/         # Meta file templates
├── dialog/                # Dialog exports
├── package.json           # npm scripts
├── CLAUDE.md              # AI protocols
├── CHANGELOG.md           # Version history
└── README.md / README_RU.md
```

---

## 🔗 Связанные документы

- [SNAPSHOT.md](./.claude/SNAPSHOT.md) — текущее состояние
- [ARCHITECTURE.md](./.claude/ARCHITECTURE.md) — структура кода
- [CLAUDE.md](../CLAUDE.md) — протоколы AI
- [CHANGELOG.md](../CHANGELOG.md) — полная история
- [GitHub Issues](https://github.com/alexeykrol/claude-code-starter/issues) — детальные обсуждения

---

## 📝 Процесс работы с BACKLOG

### Для разработчика:
1. **Начало работы:** Проверить "Текущие задачи"
2. **Новая идея:** Добавить в "Идеи и пожелания"
3. **Приоритизация:** Переместить из идей в задачи когда готовы
4. **Завершение:** Переместить в архив, обновить CHANGELOG

### Для AI:
1. **Cold Start:** Читать "Текущие задачи" для контекста
2. **Planning:** Превращать идеи в конкретные задачи по запросу
3. **Completion:** Обновлять статусы, переносить в архив

---

*Обновляй после каждой завершенной задачи или новой идеи!*
