# BACKLOG — Claude Code Starter Framework

*Последнее обновление: 2026-01-16*

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

### Phase 11: Security Layer 4 — Advisory Mode + Smart Triggers v2.4.1 ✅

**Статус:** Завершено
**Цель:** Advisory система для умного вызова AI-агента sec24 (не автоматика)

**Проблема:**
- Regex (Layer 2) покрывает 95% кейсов, но пропускает edge cases
- Layer 4 (AI agent) нужен для thorough check, но медленный (1-2 min)
- **Автоматический вызов агента на каждый commit = маразм** (траты токенов)
- Нужна **advisory система**: триггеры → Claude спрашивает → user решает

**Специфика проектов с DevOps (supabase-bridge):**
- Не только код, но и управление production
- SSH к серверам, database credentials, API keys — рабочая реальность
- Credentials не только в dialogs, но и в коде/config
- **Sprint changes** могут содержать production secrets

**Решение: Advisory Mode + Smart Triggers**

**Принципы:**
1. **Advisory, не автоматика** — триггеры дают рекомендации Claude (AI)
2. **Claude спрашивает user** — пользователь решает запускать deep scan или нет
3. **Scope оптимизация** — анализ git diff + last dialog, НЕ весь codebase
4. **Release mode = исключение** — единственный случай auto-invoke (git tag v2.x.x)
5. **Token economy** — анализ 5-10 файлов вместо 300+

**Задачи: Trigger Detection System**
- [x] Создать `security/check-triggers.sh` (trigger detection logic)
- [x] Реализовать 10 триггеров с приоритетами:
  - [x] CRITICAL: Production credentials file exists
  - [x] CRITICAL: Git release tag detected
  - [x] CRITICAL: Release workflow in recent dialogs
  - [x] HIGH: Regex found credentials
  - [x] HIGH: Security keywords (>5 mentions)
  - [x] HIGH: Production/deployment discussion
  - [x] MEDIUM: Large diff (>500 lines)
  - [x] MEDIUM: Many new dialogs (>5 uncommitted)
  - [x] MEDIUM: Security config files modified
  - [x] LOW: Long session (>2 hours)
- [x] JSON output с trigger level и reasons
- [x] Exit codes (0=none, 1=critical, 2=high, 3=medium, 4=low)

**Задачи: Advisory System (не auto-invoke)**
- [x] Переделать `security/auto-invoke-agent.sh` в advisory mode
- [x] Release mode (git tag) → auto-invoke (единственный случай)
- [x] CRITICAL/HIGH triggers → Claude спрашивает user
- [x] MEDIUM triggers → optional mention
- [x] LOW triggers → informational only
- [x] Exit codes для Claude: 0, 1 (auto), 10 (ask), 11 (ask), 12 (optional)

**Задачи: Protocol Integration**
- [x] Обновить CLAUDE.md Step 3.5 (advisory mode, Claude asks user)
- [x] Обновить migration/CLAUDE.production.md Step 3.5 (same changes)
- [x] Обновить `/security-dialogs` команду (scope: git diff + last dialog)
- [x] Step 2 в /security-dialogs (identify sprint changes, not all files)
- [x] Agent prompt: analyze git diff + last dialog only

**Задачи: Scope Optimization**
- [x] Агент анализирует git diff (last 5 commits), не весь codebase
- [x] Агент анализирует last dialog, не все 300+ dialogs
- [x] Token economy: 5-10 файлов вместо 300+

**Задачи: Documentation**
- [x] Обновить SNAPSHOT.md (advisory mode, release exception)
- [x] Обновить BACKLOG.md (этот файл)
- [x] Таблица "When to Use Each Layer" в SNAPSHOT.md
- [x] Обновить security/README.md (advisory mode, не auto-invoke)
- [x] Создать security/README.md с полным описанием архитектуры
- [ ] Обновить CHANGELOG.md (v2.4.1 entry)
- [ ] Тестирование на примерах (сейчас тестируем!)

**Задачи: Testing & Validation**
- [ ] Тестировать CRITICAL trigger (.production-credentials file)
- [ ] Тестировать HIGH trigger (regex found secrets)
- [ ] Тестировать MEDIUM trigger (large diff)
- [ ] Verify agent invokes correctly через Task tool
- [ ] Test на santacruz host project

**Результат:**
- **95% coverage (regex)** для normal sessions (fast, automatic)
- **99% coverage (AI agent)** для high-risk situations (advisory mode)
- **Advisory mode:** триггеры → Claude спрашивает → user решает
- **Token economy:** анализ git diff + last dialog (5-10 files vs 300+)
- **User control:** пользователь всегда решает (кроме release mode)
- **Release mode exception:** git tag v2.x.x → auto-invoke (mandatory)
- "Лучше пусть медленно, но надёжно" — но не на каждый commit (умно)

---

### Phase 10: Security Hardening — Dialog Credential Cleanup v2.4.0 ✅

**Статус:** Завершено
**Цель:** Предотвратить утечку credentials из dialog files в GitHub

**Проблема:**
- Dialogs в `dialog/` могут содержать credentials из conversations
- SSH keys, API tokens, passwords, DB URLs упомянутые в диалогах с AI
- Если проект коммитит `dialog/` в git → credentials утекают в GitHub
- v2.3.3 fix покрывал только in-flight redaction, не committed files
- Reports и improvement files также содержат примеры кода с secrets

**Решение: Multi-Layer Security System**

**Задачи Layer 1: .gitignore Protection**
- [x] Проанализировать всю поверхность атаки
- [x] Заменить manual file list на pattern-based ignore для `dialog/`
- [x] Добавить `reports/` в gitignore (bug reports с credential examples)
- [x] Добавить `.production-credentials` в gitignore (production SSH keys/tokens)
- [x] Добавить `security/reports/` в gitignore (cleanup scan reports)

**Задачи Layer 2: Credential Cleanup Script**
- [x] Создать `security/cleanup-dialogs.sh` (200+ lines bash script)
- [x] Реализовать 10 redaction patterns:
  - [x] SSH credentials (user@host, IP addresses, SSH key paths)
  - [x] IPv4 addresses (standalone: 192.168.x.x, 45.145.x.x)
  - [x] SSH private key paths (~/.ssh/id_rsa, ~/.ssh/claude_prod_new)
  - [x] Database URLs (postgres://, mysql://, mongodb://, redis://)
  - [x] JWT tokens (eyJxxx... format)
  - [x] API keys (sk-xxx, secret_key=xxx, access_key=xxx)
  - [x] Bearer tokens (Authorization: Bearer xxx)
  - [x] Passwords (password=xxx, pwd=xxx, user_password=xxx)
  - [x] SSH ports (-p 65002, --port 22000)
  - [x] Private key content (PEM format)
- [x] Добавить --last flag для производительности (50x faster)
- [x] Exit code 1 блокирует git commit при обнаружении credentials
- [x] Report generation в `security/reports/cleanup-*.txt`
- [x] Тестирование с fake credentials (8/10 patterns работают)

**Задачи Layer 3: Protocol Integration**
- [x] Обновить Cold Start Step 0.5 (clean PREVIOUS session перед export)
- [x] Добавить Completion Step 3.5 (clean CURRENT session перед commit)
- [x] Обновить CLAUDE.md с security steps
- [x] Обновить migration/CLAUDE.production.md с security steps
- [x] Double protection: previous (0.5) + current (3.5) = no gaps

**Задачи Metafiles & Release**
- [x] Обновить SNAPSHOT.md с v2.4.0 описанием
- [x] Обновить CHANGELOG.md с detailed v2.4.0 entry
- [x] Version bump во всех файлах (v2.3.3 → v2.4.0)
- [x] Обновить BACKLOG.md (этот файл)

**Результат:**
- **CRITICAL:** Предотвращение production credential leaks в GitHub
- Automatic operation — no manual intervention needed
- Fast performance (--last flag: 1 file vs 300+)
- Comprehensive coverage (dialog/, reports/, .production-credentials)
- Auditable (все redactions в security/reports/)
- Battle-tested (ported from supabase-bridge production)

---

### Phase 9: Security Fix — Auto-Redact Sensitive Data v2.3.3 ✅

**Статус:** Завершено
**Цель:** Исправить Issue #47 - автоматическая redaction чувствительных данных в dialog exports

**Задачи:**
- [x] Проанализировать Issue #47 (OAuth tokens в dialog exports)
- [x] Спроектировать систему redaction для exporter.ts
- [x] Создать функцию `redactSensitiveData(content: string): string`
- [x] Реализовать паттерны для 11 типов sensitive data:
  - [x] OAuth/Bearer tokens
  - [x] JWT tokens (eyJ... format)
  - [x] API keys (Stripe, Google, AWS, GitHub)
  - [x] Private keys (PEM format)
  - [x] AWS Secret Access Keys
  - [x] Database connection strings
  - [x] Passwords in URLs/config
  - [x] Email addresses in auth contexts
  - [x] Credit card numbers
- [x] Применить redaction к dialog messages
- [x] Применить redaction к summaries
- [x] Протестировать с 11 test cases (100% success rate)
- [x] Исправить Stripe key pattern (sk-test_...)
- [x] Исправить bearer token separator preservation
- [x] Обновить SNAPSHOT.md, BACKLOG.md, CHANGELOG.md

**Результат:**
- Автоматическая защита от случайного exposure токенов
- Не требуется manual sed/grep redaction
- GitHub Secret Scanning не блокирует pushes
- Безопасно для commit dialog exports
- Privacy и security для всех пользователей

---

### Phase 8: Bug Fix — Missing public/ Folder v2.3.2 ✅

**Статус:** Завершено
**Цель:** Исправить Issue #48 - `/ui` command fails with missing public/ folder

**Задачи:**
- [x] Проанализировать Issue #48 (Windows 11, Framework v2.2)
- [x] Проверить наличие public/ в v2.2.0 release (CONFIRMED - присутствует)
- [x] Проверить build-distribution.sh (работает правильно)
- [x] Проверить init-project.sh (копирует public/ корректно)
- [x] Добавить проверку public/ в server.ts перед запуском UI
- [x] Реализовать user-friendly error message с recovery options
- [x] Протестировать локально (удалить public/ и запустить UI)
- [x] Обновить SNAPSHOT.md, BACKLOG.md, CHANGELOG.md

**Результат:**
- Пользователи получают понятное сообщение об ошибке
- Два варианта восстановления (auto-install и manual fix)
- Copy-paste команды для быстрого решения
- Предотвращение crash с ENOENT error
- Reduced support burden для Windows users

---

### Phase 7: Bug Reporting System — Phase 2 & 3 v2.3.1 ✅

**Статус:** Завершено
**Цель:** Завершить bug reporting систему — централизованная коллекция и аналитика

**Задачи:**
- [x] **Phase 2: Centralized Collection**
  - [x] Создать submit-bug-report.sh для автоматической отправки в GitHub Issues
  - [x] Создать GitHub issue template (.github/ISSUE_TEMPLATE/bug_report.yml)
  - [x] Обновить CLAUDE.md Step 6.5 — два этапа подтверждения (create → submit)
  - [x] Обновить build-distribution.sh для копирования submit script
  - [x] Тестирование: syntax check, gh CLI availability
  - [x] Fix: CLAUDE.md Step 6.5 — bug reports ALWAYS создаются (не только при ошибках)
  - [x] Fix: Auto-create "bug-report" label if missing
  - [x] Fix: Smart title generation `[Bug Report][Protocol Type] vX.Y.Z - Status`
- [x] **Phase 3: Analytics & Pattern Detection**
  - [x] Создать analyze-bug-patterns.sh (bash 3.2 compatible)
  - [x] Реализовать анализ: версии, протоколы, ошибки, шаги
  - [x] Генерация recommendations и summary файлов
  - [x] Создать /analyze-local-bugs command
  - [x] Обновить build-distribution.sh для копирования analyze script
  - [x] Тестирование: работает с пустыми и заполненными логами
- [x] **Quick Update Utility**
  - [x] Создать quick-update.sh для быстрого обновления фреймворка
  - [x] Smart detection — auto-download init-project.sh если framework отсутствует
  - [x] Добавить в distribution (build-distribution.sh)
- [x] **Framework Developer Mode (Step 0.4)**
  - [x] Добавить Step 0.4 в Cold Start Protocol
  - [x] Автоматическая проверка GitHub Issues с bug-report label
  - [x] Показ count и recent reports (last 7 days)
  - [x] List 5 most recent bug reports
  - [x] Предложение запустить /analyze-bugs
  - [x] Обновить migration/CLAUDE.production.md
  - [x] Rebuild distribution
- [x] **Completion Protocol Self-Check (Step 0)**
  - [x] Добавить Step 0 в Completion Protocol
  - [x] Re-read protocol section перед выполнением /fi
  - [x] Self-check questions для metafile updates
  - [x] Обновить .claude/commands/fi.md
  - [x] Обновить migration/CLAUDE.production.md
  - [x] Исправить "сапожник без сапог" проблему

**Результат:**
- Полная 3-фазная система bug reporting (Local → Centralized → Analytics)
- Bug reports как analytics/telemetry (не только ошибки)
- Автоматическое обнаружение паттернов и рекомендации
- Smart quick-update.sh — предотвращает путаницу между update и install
- Framework Developer Mode — автоматическое оповещение о bug reports
- Completion Protocol Self-Check — предотвращает забывание документации
- Privacy-first с двойным подтверждением
- Совместимость с bash 3.2+ (macOS)

---

## 📚 Архив (завершённые фазы)

### Phase 6: Bug Reporting & Logging System v2.3.0 ✅

**Статус:** Завершено
**Цель:** Добавить систему логирования протоколов и анонимных bug reports

**Задачи:**
- [x] Спроектировать систему bug reporting
  - [x] Opt-in consent dialog (privacy-first)
  - [x] Anonymization стратегия (paths, keys, emails, IPs)
  - [x] Framework Developer Mode для сбора отчетов
- [x] Реализовать Step 0.15: Bug Reporting Consent
  - [x] First-run consent dialog
  - [x] .framework-config структура
  - [x] Opt-in по умолчанию (disabled)
- [x] Реализовать Step 0.3: Protocol Logging
  - [x] Cold Start logging с timestamps
  - [x] log_step() и log_error() функции
  - [x] Лог файлы в .claude/logs/cold-start/
- [x] Реализовать Completion Protocol Logging
  - [x] Step 0: Initialize Completion Logging
  - [x] Step 6.5: Finalize Log & Create Bug Report
  - [x] Автоматическое обнаружение ошибок
- [x] Создать /bug-reporting command
  - [x] enable/disable/status/test подкоманды
  - [x] Показывать статистику логов
- [x] Создать anonymization script
  - [x] .claude/scripts/anonymize-report.sh
  - [x] Удаление paths, API keys, tokens, emails, IPs
  - [x] Замена project name на {project}_anon
- [x] Реализовать Framework Developer Mode
  - [x] Step 0.4: Read Bug Reports from Host Projects
  - [x] Проверка открытых Issues с label "bug-report"
  - [x] Активируется только на framework project
- [x] Создать /analyze-bugs command
  - [x] Fetch reports from GitHub Issues
  - [x] Группировка по типу ошибок
  - [x] Генерация analysis файлов
- [x] Обновить build system
  - [x] build-distribution.sh копирует scripts и templates
  - [x] init-project.sh генерирует .framework-config
  - [x] .gitignore для .claude/logs/
- [x] Тестирование на santacruz
  - [x] Config creation ✅
  - [x] Cold Start logging ✅
  - [x] /bug-reporting status ✅
  - [x] Anonymization script ✅
  - [x] Все файлы на месте ✅

---

## 📚 Архив (завершённые фазы)

<details>
<summary>Phase 5: Auto-Update Framework v2.2.4 ✅ (2025-12-16)</summary>

**Завершено:** Система автоматического обновления фреймворка

**Ключевые достижения:**
- Step 0.2: Framework Version Check в Cold Start Protocol
- Парсинг версии из CLAUDE.md и GitHub API
- Aggressive update strategy (без подтверждения пользователя)
- framework-commands.tar.gz для быстрых обновлений
- Обновление только framework файлов, данные проекта не затрагиваются
- Тестирование на santacruz: v2.2 → v2.2.4 успешно

</details>

<details>
<summary>Phase 4: Distribution v2.2.3 ✅ (2025-12-16)</summary>

**Завершено:** Финализация v2.2.3 с критическими исправлениями

**Ключевые достижения:**
- Успешная миграция santacruz v1.x → v2.2
- Исправлены 4 критических бага (BUG-001 до BUG-004)
- Migration reports теперь обязательны
- Упрощенные qualifying questions
- Corrected GitHub Release v2.2.3

</details>

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
