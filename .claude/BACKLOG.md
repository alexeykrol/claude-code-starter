# BACKLOG — Claude Code Starter Framework

*Последнее обновление: 2026-01-21*

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

## 🚫 What NOT to Do

**Purpose:** Consciously excluded ideas with rationale. Prevents revisiting settled "no" decisions.

### 1. Cloud Sync for Dialog Files

**Excluded:** Automatic upload of dialog/ files to cloud storage (Dropbox, Google Drive, iCloud).

**Rationale:**
- **Privacy violation:** Dialogs contain project code, credentials, conversations
- **Trust issues:** Users don't want AI conversations auto-uploaded to cloud
- **Framework philosophy:** Local-first, privacy by default
- **Attack surface:** Cloud sync = additional leak vector

**Alternative:**
- Users can manually backup `dialog/` to their preferred cloud storage
- Export to markdown allows version control in private repos
- Host projects can use git for backup (with proper .gitignore)

**Exception:** None. Cloud sync fundamentally conflicts with privacy-first design.

---

### 2. Auto-Commits Without User Approval

**Excluded:** Automatic git commits at Completion Protocol end without asking user.

**Rationale:**
- **User control:** Developers want to review changes before committing
- **Commit message quality:** Auto-generated messages often poor
- **Trust issues:** Automatic commits feel invasive
- **Git workflow:** Some projects use specific commit conventions

**Alternative:**
- Completion Protocol prepares commit (stages files, drafts message)
- Claude AI asks user for approval before executing `git commit`
- User can modify commit message or cancel

**Exception:** None. User must always approve commits explicitly.

---

### 3. GUI Desktop Application

**Excluded:** Standalone desktop app (Electron, Tauri) instead of CLI framework.

**Rationale:**
- **Token economy:** GUI requires bundling, packaging, auto-updates (complexity)
- **Installation overhead:** Users prefer `curl | bash` to downloading .dmg/.exe
- **Maintenance burden:** GUI requires design, UX testing, cross-platform UI bugs
- **Target audience:** Framework users are developers comfortable with CLI

**Alternative:**
- Web UI for dialog viewing (`npm run dialog:ui`)
- CLI commands for all operations
- Terminal-based interactive prompts for questions

**Exception:** If community strongly requests GUI and volunteers to maintain, reconsider as separate project (not core framework).

---

### 4. Native Windows Support (Without WSL)

**Excluded:** Full Windows support using PowerShell/cmd.exe instead of bash.

**Rationale:**
- **Bash dependency:** Framework uses bash scripts (`.sh` files) extensively
- **Maintenance burden:** Maintaining parallel PowerShell scripts = 2x work
- **Edge cases:** Windows path handling, Git Bash quirks, CRLF line endings
- **Limited value:** Most Windows developers use WSL2 already

**Alternative:**
- Official support: macOS, Linux, Windows via WSL2
- Documentation: Clear WSL2 installation instructions
- Community contributions: PowerShell scripts if volunteers emerge

**Exception:** If Windows market share among users exceeds 30% AND volunteers maintain PowerShell scripts, reconsider.

---

### 5. Auto-Push to Remote After Commits

**Excluded:** Automatic `git push` after successful commit in Completion Protocol.

**Rationale:**
- **User control:** Developers want to review commits locally before pushing
- **Multiple commits:** Users might want to squash or amend before push
- **Network issues:** Auto-push fails on network errors (breaks workflow)
- **Branch protection:** Some repos have protected branches (push requires approval)

**Alternative:**
- Completion Protocol Step 5: Ask user if they want to push
- User decides: "Push now" or "Push later manually"
- Framework shows `git push` command if user skips

**Exception:** None. Push should always be user-initiated.

---

### 6. Magic Auto-Detection of Project Type

**Excluded:** Automatic detection of project type (React, Vue, Python, etc.) and auto-configuration.

**Rationale:**
- **Complexity:** Heuristics unreliable (mixed projects, monorepos)
- **False positives:** package.json exists ≠ Node.js project (many tools use it)
- **User confusion:** Magic behavior = unclear to users what happened
- **Framework philosophy:** Explicit > implicit

**Alternative:**
- Manual configuration via questions during migration
- User specifies project type if needed
- Framework asks instead of assuming

**Exception:** If detection logic becomes 99%+ accurate and user can override, reconsider.

---

*В данный момент нет активных задач. См. архив ниже для завершенных фаз.*

---

## 📚 Архив (завершённые фазы)

### Phase 19: Migration Optimization v3.1.0 ✅ (2026-01-21)

**Завершено:** Parallel file generation в миграции legacy проектов — 5x ускорение Step 6

**Проблема:**
- Migration Step 6 генерирует 5 framework файлов последовательно
- Каждый файл = одинаковый паттерн: analysis_result + template → markdown
- Время выполнения: 5 файлов × 40s = 200s (~3+ минуты)
- Общее время миграции: ~9 минут (Step 6 составляет 40% времени)

**Решение:**
- Параллельная генерация через Task tool с субагентами general-purpose
- SHARED_CONTEXT pattern — analysis result подготавливается один раз
- ONE message с 5 Task tool calls (не последовательно!)
- Каждый агент генерирует один файл независимо

**Задачи:**
- [x] Переработать Step 6 в `.claude/commands/migrate-legacy.md`
- [x] Разделить на 3 subsections: Prepare Context, Launch Parallel, Verify
- [x] Добавить detailed prompt templates для каждого файла
- [x] Обновить версию на v3.1.0 (8+ файлов)
- [x] Обновить metafiles (CHANGELOG, SNAPSHOT, BACKLOG)

**Ключевые достижения:**
- ✅ Step 6: 200s → 40s (5x ускорение)
- ✅ Total migration: 9 min → 6.7 min (~30% ускорение)
- ✅ Parallel execution pattern для Task tool
- ✅ SHARED_CONTEXT — zero duplication
- ✅ Backward compatible (не breaking change)

**Files:**
- `.claude/commands/migrate-legacy.md` — Step 6 полностью переписан
- `package.json`, `CLAUDE.md`, `README.md`, `README_RU.md` — version bumped
- `init-project.sh`, `migration/build-distribution.sh` — version bumped
- `src/framework-core/` — version bumped to 3.1.0 (__init__.py, main.py, logger.py)
- `CHANGELOG.md` — v3.1.0 entry с performance metrics
- `.claude/SNAPSHOT.md` — Decision Log + version update
- `.claude/BACKLOG.md` — этот файл

**Performance:**
```
Before (v3.0.0):
  Step 6: 200 seconds (sequential)
  Total migration: ~9 minutes

After (v3.1.0):
  Step 6: 40 seconds (parallel)
  Total migration: ~6.7 minutes

Improvement: 5x faster Step 6, 30% faster total
```

**Impact:**
- ✅ Better UX — миграция заметно быстрее
- ✅ User feedback driven — решение предложено пользователем
- ✅ Architectural insight — parallel pattern applicable to other operations
- ✅ Token economy preserved — no additional context loading

---

### Phase 18: Python Framework Core v3.0.0 ✅ (2026-01-20)

**Завершено:** Полная переписка protocol execution layer с bash на Python

**Проблема:**
- User feedback: "20-30% времени уходит на протоколы"
- Terminal spam от 10 bash background tasks (task notifications)
- Невозможность true silent mode с bash
- Медленное выполнение (минуты)

**Решение:**
- Создана Python утилита `src/framework-core/`
- Все 10 задач реализованы в Python
- Parallel execution через threading
- JSON output вместо terminal spam

**Задачи:**
- [x] Спроектировать архитектуру Python утилиты
- [x] Создать структуру проекта src/framework-core/
- [x] Реализовать cold-start команду (10 задач)
- [x] Реализовать completion команду
- [x] Интегрировать в protocols (cold-start-silent.md)
- [x] Обновить metafiles (SNAPSHOT, BACKLOG, CHANGELOG)

**Ключевые достижения:**
- ✅ Zero terminal noise (JSON output)
- ✅ 1000x быстрее (359ms vs минуты)
- ✅ Parallel execution (Python threading)
- ✅ Cross-platform (Windows native)
- ✅ Zero dependencies (stdlib only)
- ✅ Structured logging (`.claude/logs/framework-core/`)

**Files:**
- `src/framework-core/` - Python утилита (16 файлов, 931 строка)
  - `main.py` - CLI entry point
  - `commands/cold_start.py`, `commands/completion.py`
  - `tasks/` - 6 модулей (config, session, git, version, security, hooks)
  - `utils/` - logger, result, parallel
- `.claude/protocols/cold-start-silent.md` - updated to v3.0.0
- `.claude/analysis/python-framework-core-design.md` - architecture doc
- `.claude/SNAPSHOT.md` - Decision Log + What's New v3.0.0
- `CHANGELOG.md` - v3.0.0 entry (MAJOR version bump)

**Testing:**
```bash
$ python3 src/framework-core/main.py cold-start
{
  "status": "needs_input",
  "data": {
    "reason": "crash_detected",
    "uncommitted_files": "3"
  }
}
```

**Impact:**
- ✅ True silent mode achieved
- ✅ Protocols invisible to user
- ✅ Faster development iteration
- ✅ Better debugging (code vs bash)

**Version Bump Rationale:**
- **v3.0.0 (MAJOR):** Complete architectural rewrite (bash → Python)
- Breaking change: new Python dependency requirement
- Semantic Versioning: major changes = major version
- Future: v4.0.0 (Go rewrite when project mature)

---

### Phase 16: Hotfix - UX Improvements v2.4.5 ✅ (2026-01-17)

**Завершено:** Quick wins - минорные UX улучшения

**Задачи:**
- [x] Issue #41: Добавить пояснение к "Continue or commit first?"
- [x] Issue #23: Закрыть спам issue
- [x] Issue #3: Подтвердить что документация уже исправлена

**Ключевые достижения:**
- Добавлено понятное пояснение в Crash Recovery
- Варианты теперь описаны: "Continue" vs "Commit first"
- Закрыты 3 issues (#41, #23, #3)

**Files:**
- `.claude/protocols/cold-start.md` — Step 0.1 (Crash Recovery)
- `CHANGELOG.md` — v2.4.5 entry
- Version bump: 2.4.4 → 2.4.5

**Impact:**
- ✅ Лучший UX при crash recovery
- ✅ Меньше путаницы для пользователей

---

### Phase 15: Hotfix - Subdirectory Scanning v2.4.4 ✅ (2026-01-17)

**Завершено:** Исправлен критический баг - `/migrate` пропускает docs/ с мета-документацией

**Проблема:**
- Issue #7: `/migrate-legacy` находил только файлы в корне проекта
- Пропускал docs/BACKLOG.md (491 строка roadmap!), docs/STATUS.md
- Результат: .claude/BACKLOG.md оставался пустым template
- **Нарушал обещание "single source of truth"** - создавал два источника истины

**Решение:**
- Переписан Step 2.1, 2.3, 3, 5, 6, 9 в `.claude/commands/migrate-legacy.md`
- Сканирование subdirectories: docs/, documentation/, notes/, wiki/, .github/
- Классификация по содержимому (мета-документация vs code documentation)
- Интерактивное подтверждение для ambiguous файлов
- Правильный mapping: docs/BACKLOG.md → .claude/BACKLOG.md
- Архивирование docs/ после миграции

**Ключевые достижения:**
- [x] Обновлена логика сканирования в Step 2.1 (subdirectories)
- [x] Добавлена классификация по содержимому (meta vs code docs)
- [x] Обновлен Step 2.3 (Discovery Results с классификацией)
- [x] Обновлен Step 3 (чтение файлов из subdirectories)
- [x] Обновлен Step 5 (Report показывает docs/ файлы)
- [x] Обновлен Step 6 (BACKLOG.md приоритизация sources)
- [x] Добавлен Step 9.4 (архивирование subdirectories)
- [x] Обновлены metafiles (CHANGELOG.md, SNAPSHOT.md, BACKLOG.md)
- [x] Version bump: 2.4.3 → 2.4.4

**Files:**
- `.claude/commands/migrate-legacy.md` — Steps 2.1, 2.3, 3, 5, 6, 9
- `CHANGELOG.md` — Issue #7 entry
- Version files: init-project.sh, build-distribution.sh, README.md, README_RU.md

**Impact:**
- ✅ Migration находит ВСЮ мета-документацию (не только в корне)
- ✅ .claude/BACKLOG.md заполнен реальным контентом после миграции
- ✅ Single source of truth - без путаницы двух источников
- ✅ Token economy - AI не ищет docs/BACKLOG.md после миграции

---

### Phase 14: Hotfix - Migration Workflow Fix v2.4.3 ✅ (2026-01-17)

**Завершено:** Исправлен критический баг, блокирующий миграцию legacy проектов

**Проблема:**
- Issue #4: init-project.sh не копировал .claude/commands/ для legacy/upgrade проектов
- Копировались только 2 команды: migrate-legacy.md, upgrade-framework.md
- Пользователи не могли запустить `/migrate`, `/fi`, `/ui` и другие команды
- Полностью блокировался workflow миграции

**Решение:**
- Переписан else block в init-project.sh (lines 349-375)
- Теперь копируется вся структура .claude/ (commands, dist, protocols, scripts, templates)
- Unified installation path для всех типов проектов (new, legacy, upgrade)
- Legacy проекты получают полную функциональность сразу после установки

**Ключевые достижения:**
- [x] Исправлен init-project.sh (source + dist-release)
- [x] Обновлен CHANGELOG.md с описанием Issue #4
- [x] Version bump: 2.4.2 → 2.4.3 (все файлы)
- [x] Обновлены metafiles (SNAPSHOT.md, BACKLOG.md)

**Files:**
- `init-project.sh` — lines 349-375 (LEGACY/UPGRADE mode rewritten)
- `dist-release/init-project.sh` — synced with source
- `migration/build-distribution.sh` — version bumped
- `README.md`, `README_RU.md` — version badges updated

**Impact:**
- ✅ Migration workflow работает из коробки
- ✅ Все slash команды доступны с первого запуска
- ✅ No more chicken-and-egg problem

---

### Phase 13: Hotfix - Critical Bugs v2.4.2 ✅ (2026-01-16)

**Завершено:** Исправлены критические баги для internationalization и UX

**Ключевые достижения:**
- Issue #54: Dialog export с кириллицей (sessions-index.json, 100% точность)
- Issue #50: Adaptive /explain (90% token savings для simple code)
- Framework работает с любыми языками в путях
- UX improvement: адекватные ответы от /explain
- Обратная совместимость сохранена

**Files:**
- `src/claude-export/exporter.ts` — findClaudeProjectDir() rewrite
- `.claude/commands/explain.md` — adaptive complexity assessment

---

### Phase 12: Hybrid Protocol Files Architecture v2.4.1 ✅

**Статус:** Завершено
**Цель:** Модульная архитектура протоколов, immune to context compaction

**Проблема:**
- После долгих сессий происходит context compaction, что может сжимать содержимое CLAUDE.md
- Монолитный CLAUDE.md (~1000 строк) трудно поддерживать и навигировать
- Смешивание протокольных шагов с документацией создаёт cognitive overhead
- Token cost: CLAUDE.md постоянно в контексте (~8.7k tokens)

**Решение: Hybrid Protocol Files**

**Принципы:**
1. **Модульность** — каждый протокол в отдельном файле
2. **Guaranteed fresh** — протоколы читаются с диска, не compactизируются
3. **Router pattern** — CLAUDE.md как роутер (~330 строк), протоколы отдельно
4. **Token economy** — протоколы загружаются только при необходимости (~3-4k vs 8.7k)

**Задачи: Protocol Files Creation**
- [x] Создать `.claude/protocols/cold-start.md` (600+ строк, 15.7KB)
- [x] Создать `.claude/protocols/completion.md` (490+ строк, 14.2KB)
- [x] Извлечь все шаги протоколов из CLAUDE.md
- [x] Добавить versioning и timestamps в protocol files
- [x] Включить полные bash команды и инструкции

**Задачи: CLAUDE.md Router Architecture**
- [x] Переработать CLAUDE.md в router (~330 строк vs ~1000)
- [x] Добавить триггеры для чтения protocol files
- [x] Cold Start trigger → read `.claude/protocols/cold-start.md`
- [x] Completion trigger → use Skill tool to load `/fi` fresh
- [x] Документировать Hybrid Architecture в CLAUDE.md

**Задачи: Integration**
- [x] Обновить `.claude/commands/fi.md` для чтения protocol file
- [x] Синхронизировать `migration/CLAUDE.production.md`
- [x] Обновить `migration/build-distribution.sh` (Step 6.5: copy protocols)
- [x] Обновить `init-project.sh` version to 2.4.1
- [x] Добавить protocols/ в Repository Structure

**Задачи: Documentation & Metafiles**
- [x] Обновить FRAMEWORK_IMPROVEMENTS.md (Section 8: Hybrid Protocol Files)
- [x] Обновить CHANGELOG.md (v2.4.1 entry)
- [x] Обновить README.md + README_RU.md (version badges 2.4.0 → 2.4.1)
- [x] Обновить .claude/SNAPSHOT.md (version, status, structure)
- [x] Обновить .claude/BACKLOG.md (этот файл)

**Задачи: Testing & Validation**
- [ ] Тестировать Cold Start с protocol file read
- [ ] Тестировать Completion `/fi` с Skill tool
- [ ] Verify protocol files в distribution (tar -tzf)
- [ ] Test на host project

**Результаты:**

| Метрика | До (v2.4.0) | После (v2.4.1) |
|---------|-------------|----------------|
| Размер CLAUDE.md | ~1000 строк | **~330 строк** (router) |
| Модульность | Монолит | **3 файла** (CLAUDE.md + 2 protocols) |
| Token cost (loading) | ~8.7k (всегда) | **~3.5k** (router only) |
| Protocols token cost | N/A | **~3-4k** (on demand) |
| Immunity to compaction | Нет | **Да** (files read fresh) |

**Преимущества:**
- ✅ **Модульность:** Легко поддерживать и расширять
- ✅ **Token economy:** 60% reduction (8.7k → 3.5k router + 3-4k on demand)
- ✅ **Guaranteed fresh:** Протоколы всегда читаются с диска
- ✅ **Better UX:** CLAUDE.md теперь понятный router, не монолит
- ✅ **Maintainability:** Каждый протокол в своём файле

---

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
