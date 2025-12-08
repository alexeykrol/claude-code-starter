# BACKLOG — Claude Code Starter Framework

*Последнее обновление: 2025-12-07*

> 📋 **SINGLE SOURCE OF TRUTH для задач фреймворка**

---

## 🎯 Текущая фаза: v2.0.0 — Framework Restructuring

**Цель:** Превратить фреймворк из набора документов в мета-слой над Claude Code с кодом

**Статус:** ✅ Структура готова, проверяем протоколы

---

## Phase 1: Framework Restructuring ✅

### Выполнено:
- [x] Добавить src/claude-export/ — исходный код
- [x] Создать package.json — npm scripts
- [x] Создать tsconfig.json — конфигурация TypeScript
- [x] Создать ARCHITECTURE.md — документация кода
- [x] Обновить CLAUDE.md — полные протоколы Cold Start и Completion
- [x] Обновить SNAPSHOT.md — текущее состояние
- [x] Удалить дистрибутивные файлы (init-starter.zip, init_eng/, Init/)
- [x] Архивировать устаревшие файлы

### Проверено:
- [x] `npm run build` — компиляция работает
- [x] `npm run dialog:list` — список сессий
- [x] Slash commands (19) — все на месте
- [x] `.claude/.last_session` — crash recovery работает

---

## Phase 2: Protocol Verification ✅

### Cold Start Protocol:
- [x] Step 0: Crash Recovery (check .last_session)
- [x] Step 1: Mark Session Active
- [x] Step 2: Load Context (SNAPSHOT.md)
- [x] Step 3: Context on demand (BACKLOG.md, ARCHITECTURE.md)
- [x] Step 4: Confirm

### Completion Protocol (/fi):
- [x] Step 1: npm run build
- [x] Step 2: Update metafiles
- [x] Step 3: npm run dialog:export
- [x] Step 4: Git commit
- [x] Step 5: Ask about push
- [x] Step 6: Mark session clean

### Dialog Export UI:
- [x] Teacher UI (localhost:3333) — управление видимостью
- [x] Force Sync — синхронизация текущей сессии
- [x] Student UI (html-viewer/index.html) — статический просмотр

### Fixes Applied:
- [x] Template replacement order (Student UI) — DIALOGS_DATA last
- [x] Path encoding variations (findClaudeProjectDir) — underscore/dash support
- [x] Force Sync, Watcher, CLI Export — автоматически исправлены
- [x] **Dialog export sync bug** — runExport не вызывал syncCurrentSession (2025-12-07)

### Testing Completed:
- [x] Manual summaries — 6 dialogs (SUMMARY_SHORT/FULL)
- [x] CLI commands — list, export, init, watch
- [x] Privacy management — .gitignore → Student UI sync
- [x] Recovery — directory deletion incident resolved
- [x] Export sync fix — текущий диалог обновляется при завершении спринта
- [x] Summary parsing — simplified, marker-based (PENDING/ACTIVE)
- [x] UI auto-refresh — 10-second data polling
- [x] Documentation — README.md + README_RU.md updated for v2.0
- [x] File organization — AI metafiles moved to .claude/

---

## Phase 3: Installation System ⏳

**Статус:** Планируется после завершения Phase 2

### Задачи:
- [ ] Создать новые шаблоны Init/ для v2.0
- [ ] init-project.sh — установочный скрипт
- [ ] Миграция legacy проектов
- [ ] Тестирование на реальных проектах

---

## Phase 4: Distribution ⏳

### Задачи:
- [ ] init-starter.zip (русская версия)
- [ ] init-starter-en.zip (английская версия)
- [ ] README.md / README_RU.md
- [ ] GitHub Release

---

## 📊 Структура v2.0.0

```
claude-code-starter/
├── src/claude-export/     ✅ Исходный код
├── dist/claude-export/    ✅ Скомпилировано
├── .claude/
│   ├── commands/          ✅ 19 slash commands
│   ├── SNAPSHOT.md        ✅ Состояние проекта
│   ├── ARCHITECTURE.md    ✅ Документация кода
│   └── BACKLOG.md         ✅ Этот файл
├── dialog/                ✅ Экспорт диалогов
│
├── package.json           ✅ npm scripts
├── tsconfig.json          ✅ TypeScript config
├── CLAUDE.md              ✅ Протоколы AI
├── CHANGELOG.md           ⏳ Обновить при релизе
└── README.md / README_RU.md
```

---

## ✅ История версий

### v2.0.0 (2025-12-07) — Framework Restructuring
- Добавлен код (src/, dist/)
- npm project structure
- Полные протоколы Cold Start и Completion
- Crash Recovery

### v1.4.3 (2025-10-23) — Sprint Completion
- 5-уровневая система напоминаний
- Dogfooding (фреймворк использует себя)

### v1.4.0 (2025-10-11) — Cold Start
- PROJECT_SNAPSHOT.md template
- 85% экономия токенов

---

## 🔗 Связанные документы

- [SNAPSHOT.md](./.claude/SNAPSHOT.md) — текущее состояние
- [ARCHITECTURE.md](./.claude/ARCHITECTURE.md) — структура кода
- [CLAUDE.md](../CLAUDE.md) — протоколы AI
- [CHANGELOG.md](../CHANGELOG.md) — полная история

---

*Обновляй после каждой завершенной задачи!*
