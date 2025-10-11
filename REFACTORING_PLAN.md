# Framework Deduplication Refactoring Plan

> **Version:** 1.2.0
> **Date:** 2025-01-11
> **Status:** 📋 READY TO EXECUTE

---

## 🎯 Refactoring Goals

### Primary Objectives
1. **Eliminate ~500+ lines of duplicated content**
2. **Establish Single Source of Truth** for each concept
3. **Reduce maintenance burden** by 70%
4. **Prevent future contradictions** through cross-references

### Success Metrics
- CLAUDE.md reduced from ~170 lines → ~80 lines
- AGENTS.md security rules removed (~31 instructions)
- Modularity philosophy consolidated (3 places → 1 authoritative + 2 links)
- All files have clear "Authoritative: Yes/No" markers

---

## 📋 Refactoring Sequence

### Phase 1: Critical Files (Priority 1)
1. ✅ CLAUDE.md - Remove duplications, add cross-references
2. ✅ AGENTS.md - Remove security rules, keep only project patterns
3. ✅ PROJECT_INTAKE.md - Replace modularity section with link

### Phase 2: Internal Cleanup (Priority 2)
4. ✅ SECURITY.md - Deduplicate internal repetitions
5. ✅ WORKFLOW.md - Add authoritative markers

### Phase 3: Documentation (Priority 3)
6. ✅ Create DOCS_MAP.md
7. ✅ Update CHANGELOG.md → v1.2.0
8. ✅ Update README badges if needed

---

## 📝 Detailed Changes by File

### 1. Init/CLAUDE.md - MAJOR REFACTORING

**Current:** 170+ lines, Navigator + Reference + Duplicated Rules

**Target:** 80-90 lines, Navigator ONLY with cross-references

#### Section-by-Section Changes:

**🚀 Быстрый старт** (lines 7-22)
- ✅ KEEP AS IS - good navigation

**📦 Bash-команды** (lines 24-44)
- ✅ KEEP AS IS - essential reference

**🎨 Кодстайл** (lines 46-65)
- ✅ KEEP AS IS - quick reference is OK

**🔐 Безопасность** (lines 67-80)
❌ REMOVE detailed rules
✅ REPLACE with:
```markdown
## 🔐 Безопасность (КРИТИЧНО!)

**📖 ПОЛНАЯ ПОЛИТИКА:** SECURITY.md

**⚠️ ВСЕГДА перед кодированием:**
1. Прочитай SECURITY.md полностью
2. Следуй чеклисту для текущей стадии разработки (SECURITY.md → Stage X)

**Ключевые правила (подробно в SECURITY.md):**
- ✅ Валидация входных данных → SECURITY.md Stage 3
- ✅ Секреты в .env → SECURITY.md "Secrets Management"
- ✅ Параметризованные запросы → SECURITY.md "SQL Injection Prevention"
- ❌ Никогда не hardcode секреты → SECURITY.md "NEVER DO" section
- ❌ Никогда не доверяй user input → SECURITY.md "Zero Trust"

**Для AI-агентов:** Запускай `/security` для автоматического audit
```

**🏗️ Флоу работы** (lines 82-109)
❌ REMOVE all detailed checklists
✅ REPLACE with:
```markdown
## 🏗️ Флоу работы

**📖 ПОЛНАЯ ДОКУМЕНТАЦИЯ:** WORKFLOW.md

**Быстрая навигация:**

### Перед началом задачи
→ См. WORKFLOW.md → "Sprint Start" section

### Во время разработки
→ См. WORKFLOW.md → "Implementation" section
→ См. AGENTS.md → Project-specific patterns

### После изменений
→ `make typecheck && make lint`

### Sprint завершение
→ См. WORKFLOW.md → "Sprint Completion Checklist" (29 пунктов!)
→ ⚠️ КРИТИЧНО: Не пропусти Security Requirements!

### Git workflow
→ См. WORKFLOW.md → "Git Workflow" section
→ Commit messages: См. WORKFLOW.md → "Commit Templates"
```

**🔧 Настройка окружения** (lines 111-135)
- ✅ KEEP AS IS - project-specific info

**📋 Важные детали** (lines 137-155)
- ✅ KEEP AS IS - [ЗАПОЛНИТЬ] sections

**🐛 Отладка** (lines 157-180)
- ✅ KEEP AS IS - helpful quick reference

**🎯 Приоритеты** (lines 182-189)
- ✅ KEEP AS IS - good summary

**📝 Slash-команды** (lines 191-210)
- ✅ KEEP AS IS - essential reference

**⚠️ Предупреждения** (lines 212-219)
- ✅ KEEP AS IS

**🔄 Интеграции** (lines 221-237)
- ✅ KEEP AS IS

**📚 Полезные ссылки** (lines 239-245)
- ✅ KEEP AS IS

**🎓 Для новых разработчиков** (lines 247-256)
- ✅ KEEP AS IS - good onboarding

**Expected Result:**
- Before: 170 lines
- After: ~85 lines
- Reduction: ~85 lines (50%)
- All references to WORKFLOW.md, SECURITY.md clear

---

### 2. Init/AGENTS.md - CRITICAL REFACTORING

**Current:** Contains ~31 security instructions duplicating SECURITY.md

**Target:** Project-specific patterns ONLY, security rules → links

#### Changes:

**🚫 NEVER DO → 🔐 Security (lines 143-154)**
❌ REMOVE all 10 NEVER DO security rules
✅ REPLACE with:
```markdown
### 🔐 Security (CRITICAL - READ SECURITY.md FIRST!)

**📖 ПОЛНАЯ ПОЛИТИКА БЕЗОПАСНОСТИ:** SECURITY.md

**ДО начала любой задачи с кодом:**
1. Прочитай SECURITY.md → Stage 1 (Planning)
2. Следуй чеклистам для текущей стадии
3. В случае сомнений → `/security` для audit

**Ключевые принципы (все детали в SECURITY.md):**
- 🔐 Secrets management → SECURITY.md "Environment Variables"
- 🔐 Input validation → SECURITY.md Stage 3
- 🔐 SQL injection prevention → SECURITY.md "Database Security"
- 🔐 XSS prevention → SECURITY.md "Output Sanitization"

**AGENTS.md содержит только project-specific security patterns!**
См. "Project Security Patterns" section ниже для специфичных правил этого проекта.
```

**✅ ALWAYS DO → 🔐 Security (lines 173-184)**
❌ REMOVE all 11 ALWAYS DO security rules
✅ Already covered by section above

**🔐 Security Review (lines 230-241)**
❌ REMOVE 10-step Security Review checklist
✅ REPLACE with:
```markdown
### 🔐 Security Review (Before Every Deploy)

**📖 ИСПОЛЬЗУЙ CHECKLIST ИЗ SECURITY.md:**
- См. SECURITY.md → Stage 5 (Pre-Deployment)
- См. SECURITY.md → "Security Sign-Off Template"

**Или используй автоматизацию:**
```bash
/security  # Запустить AI-guided security audit
```
```

**ADD NEW SECTION (для project-specific patterns):**
```markdown
---

## 🔐 Project Security Patterns

> **Важно:** Этот раздел для СПЕЦИФИЧНЫХ для ЭТОГО проекта security patterns.
> Общие правила безопасности см. SECURITY.md

[ЗАПОЛНИТЬ по мере разработки проекта]

### Pattern 1: [Project-Specific Security Rule]
[Описание специфичного для проекта security pattern]

**Template:**
```markdown
### Pattern N: [Name]
**Context:** [When this applies]
**Rule:** [What to do]
**Reason:** [Why this is important for THIS project]
**Example:**
[Code example]
```
```

**Expected Result:**
- Remove: ~31 security instructions
- Add: Clear references to SECURITY.md
- Keep: Space for project-specific patterns
- Reduction: ~25-30 lines

---

### 3. Init/PROJECT_INTAKE.md - MODULARITY DEDUPLICATION

**Current:** Lines 536-576 contain 40-line detailed modularity explanation

**Target:** Replace with link to ARCHITECTURE.md

#### Changes:

**Section 25a. Модульная структура** (lines 536-576)
❌ REMOVE detailed 40-line explanation
✅ REPLACE with:
```markdown
### 25a. Модульная структура (ОБЯЗАТЕЛЬНО!)

**Почему модульная архитектура критична для работы с ИИ:**

📖 **ПОЛНАЯ ФИЛОСОФИЯ:** ARCHITECTURE.md → "Module Architecture" section

**Краткое объяснение:**
1. **Экономия токенов:** ИИ загружает только нужный модуль (100-200 строк), а не весь проект (1000+ строк)
2. **Простота:** Каждый модуль = отдельная задача = легко проверить
3. **Скорость:** Можно делать разные модули параллельно

**Принцип:** Приложение = набор маленьких LEGO-кубиков

📖 **Детали, примеры, диаграммы:** См. ARCHITECTURE.md → "Module Architecture"

**Ваш подход к модульности:**

- [ ] Да, хочу модульную структуру (рекомендовано!)
- [ ] Нет, хочу монолитную структуру (НЕ рекомендуется для работы с ИИ)

**Selected:** [ОТВЕТИТЬ: Модульная (recommended)]

**Как будем разрабатывать модули:**
[ОТВЕТИТЬ: Например, "По одному модулю за раз. См. ARCHITECTURE.md для типичной последовательности"]
```

**Expected Result:**
- Before: 40 lines
- After: ~20 lines
- Reduction: ~20 lines
- Full philosophy in ARCHITECTURE.md only

---

### 4. Init/SECURITY.md - INTERNAL DEDUPLICATION

**Current:** "Input validation" mentioned 3 times

**Target:** Consolidate or clarify context

#### Analysis:

**Line 209 (Stage 3 - Development):**
```markdown
- [ ] Input validation implemented
```
Context: DEVELOPMENT checklist

**Line 485 (Stage 4 - Testing):**
```markdown
- [ ] Input validation on all inputs
```
Context: TESTING checklist

**Line 493 (Stage 4 - Testing details):**
```markdown
- [ ] Input validation tested
```
Context: Detailed testing steps

#### Decision:

✅ **KEEP ALL THREE** - contexts differ:
1. Line 209: "Implement validation" (dev)
2. Line 485: "Check it's implemented" (test checklist)
3. Line 493: "Actually test it" (test details)

❌ **NO CHANGES NEEDED** - these are different contexts, not duplications

**Alternative (if we want to optimize):**
- Keep lines 485 and 493 (testing)
- Line 209: Change to "See Stage 4 for validation checklist"

**Recommendation:** ✅ Keep as is - clarity > brevity for security

---

### 5. Init/WORKFLOW.md - ADD AUTHORITATIVE MARKER

**Current:** No indication this is the authoritative workflow source

**Target:** Add header marker

#### Changes:

**File Header** (after line 6)
ADD:
```markdown
> **📋 Authoritative Source:** This is the SINGLE SOURCE OF TRUTH for:
> - Sprint workflow and processes
> - Git workflow and commit templates
> - Sprint completion checklists
>
> Other files (CLAUDE.md, AGENTS.md) link here, don't duplicate.
```

**Expected Result:**
- Clear indication of authoritative status
- Other files should reference this, not duplicate

---

### 6. Create DOCS_MAP.md - NEW FILE

**Purpose:** Map all documentation files and their relationships

**Content:**
```markdown
# Documentation Map

> **Purpose:** Navigate the Claude Code Starter framework documentation
> **Version:** 1.2.0
> **Last Updated:** 2025-01-11

---

## 📚 Documentation Structure

### 🎯 Single Sources of Truth

These files are **authoritative** for their domains. Other files reference them.

| File | Domain | Lines | Role |
|------|--------|-------|------|
| **WORKFLOW.md** | Sprint processes, Git workflow | ~600 | Authoritative workflow |
| **SECURITY.md** | Security practices, checklists | ~500 | Authoritative security policy |
| **PROJECT_INTAKE.md** | Project requirements, User Personas | ~775 | Project definition template |
| **ARCHITECTURE.md** | Tech decisions, modularity philosophy | ~600 | Authoritative architecture |
| **BACKLOG.md** | Implementation status, roadmap | ~370 | Single source of truth for status |
| **AGENTS.md** | Project-specific AI patterns | ~465 | Project-specific patterns (NOT universal rules) |

### 🧭 Navigation Files

These files **link to** authoritative sources. They don't duplicate.

| File | Purpose | Target Audience |
|------|---------|----------------|
| **CLAUDE.md** | Auto-loads in Claude Code, navigation | AI agents (auto-loaded) |
| **README.md** | Project overview, getting started | Humans (first contact) |
| **README_RU.md** | Russian version | Russian-speaking users |

### 📖 Supporting Files

| File | Purpose |
|------|---------|
| **PLAN_TEMPLATE.md** | Template for planning tasks |
| **README-TEMPLATE.md** | Template for project README |
| **MIGRATION.md** | Guide for migrating legacy projects |
| **CHANGELOG.md** | Version history |
| **CONSISTENCY_AUDIT.md** | Audit report (v1.2.0) |
| **REFACTORING_PLAN.md** | This file |

---

## 🗺️ Concept Ownership Map

**When you need information about...**

| Concept | Authoritative File | Quick Reference |
|---------|-------------------|-----------------|
| Sprint completion checklist | WORKFLOW.md → "Sprint Completion" | CLAUDE.md → link |
| Security rules | SECURITY.md → stage checklists | CLAUDE.md → link |
| Git workflow | WORKFLOW.md → "Git Workflow" | CLAUDE.md → link |
| User Personas | PROJECT_INTAKE.md → "User Personas" | CLAUDE.md → mention |
| Modularity philosophy | ARCHITECTURE.md → "Module Architecture" | PROJECT_INTAKE.md → link |
| Project status | BACKLOG.md (single source of truth) | Always check first |
| Project-specific patterns | AGENTS.md (project-specific only!) | Filled during development |

---

## 🔄 Cross-Reference Rules

### For CLAUDE.md (Navigator)
- **DO:** Link to authoritative sources
- **DON'T:** Duplicate details from other files
- **Format:** "📖 См. WORKFLOW.md → Section Name"

### For AGENTS.md (Project Patterns)
- **DO:** Document project-specific patterns
- **DON'T:** Duplicate universal rules from SECURITY.md, WORKFLOW.md
- **Format:** Link to authoritative file for universal rules

### For Other Files
- **Always specify** if authoritative or reference
- **Link, don't duplicate** when referencing other concepts
- **Update DOCS_MAP.md** when adding new files

---

## 📝 Maintenance Guidelines

### When Adding New Concept
1. **Choose ONE authoritative file** for it
2. **Update this map** with the new concept
3. **Other files link** to the authoritative file

### When Updating Concept
1. **Update authoritative file** first
2. **Check DOCS_MAP.md** for files that reference it
3. **Update links** if section names changed

### Monthly Review
- Check for new duplications
- Verify links still valid
- Update this map if structure changed

---

## 🚫 Anti-Patterns to Avoid

❌ **DON'T duplicate detailed content** across files
❌ **DON'T create "summary" sections** that duplicate authoritative source
❌ **DON'T forget to update links** when moving/renaming sections
❌ **DON'T mix universal rules** (SECURITY.md) with project patterns (AGENTS.md)

✅ **DO link to authoritative sources**
✅ **DO keep CLAUDE.md as navigation only**
✅ **DO specify authoritative status** clearly
✅ **DO separate universal vs project-specific** content

---

*This map ensures consistency and prevents duplication across documentation*
*Last updated: 2025-01-11*
*Maintained by: Project Lead + AI Agents*
```

---

## ✅ Testing Plan

After refactoring, test that framework still works:

### 1. AI Agent Test
```
Prompt: "Прочитай CLAUDE.md и объясни как начать новый sprint"

Expected: AI finds link to WORKFLOW.md → reads Sprint Start section → explains correctly
```

### 2. Security Test
```
Prompt: "Какие security practices нужно соблюдать при разработке?"

Expected: AI points to SECURITY.md, mentions stages, explains key principles
```

### 3. Modularity Test
```
Prompt: "Объясни почему модульная архитектура важна"

Expected: AI finds link in CLAUDE.md → reads ARCHITECTURE.md Module section → explains with diagrams
```

### 4. Cross-Reference Test
- Manually check all links work
- Verify section names match
- Ensure no broken references

---

## 📊 Metrics

### Before Refactoring
- Total files with duplications: 6
- Duplicated lines: ~500+
- CLAUDE.md size: ~170 lines
- AGENTS.md security rules: ~31
- Modularity philosophy: 237 lines across 3 files

### After Refactoring (Target)
- Total files with duplications: 0
- Duplicated lines: ~50 (acceptable cross-references)
- CLAUDE.md size: ~85 lines
- AGENTS.md security rules: 0 (links only)
- Modularity philosophy: ~196 lines in 1 file + links

### Improvement
- Duplication reduction: 90%
- CLAUDE.md reduction: 50%
- Maintenance burden: -70%
- Contradiction risk: ELIMINATED

---

## 🎯 Execution Checklist

### Phase 1: Critical Files
- [ ] Refactor Init/CLAUDE.md
- [ ] Refactor init_eng/CLAUDE.md (English version)
- [ ] Refactor Init/AGENTS.md
- [ ] Refactor init_eng/AGENTS.md
- [ ] Refactor Init/PROJECT_INTAKE.md (modularity section)
- [ ] Refactor init_eng/PROJECT_INTAKE.md

### Phase 2: Markers & Documentation
- [ ] Add authoritative marker to Init/WORKFLOW.md
- [ ] Add authoritative marker to init_eng/WORKFLOW.md
- [ ] Add authoritative marker to Init/SECURITY.md
- [ ] Add authoritative marker to init_eng/SECURITY.md
- [ ] Add authoritative marker to Init/ARCHITECTURE.md
- [ ] Add authoritative marker to init_eng/ARCHITECTURE.md
- [ ] Create DOCS_MAP.md
- [ ] Update CHANGELOG.md → v1.2.0

### Phase 3: Testing & Validation
- [ ] Test AI agent with CLAUDE.md
- [ ] Test security references work
- [ ] Test modularity references work
- [ ] Manual check all cross-references
- [ ] Verify English versions match Russian

### Phase 4: Commit
- [ ] Git add all changes
- [ ] Create comprehensive commit message
- [ ] Tag as v1.2.0
- [ ] Push to remote

---

## 📝 Commit Message Template

```bash
git commit -m "$(cat <<'EOF'
refactor: Deduplicate framework meta-documentation (v1.2.0)

Eliminate ~500+ lines of duplicated content across 6 files.

## Changes

### CLAUDE.md (Russian & English)
- Reduced from ~170 → ~85 lines (50% reduction)
- Removed duplicated workflow/security rules
- Added cross-references to authoritative sources
- Now serves as navigator only

### AGENTS.md (Russian & English)
- Removed ~31 duplicated security instructions
- Added clear references to SECURITY.md
- Clarified purpose: project-specific patterns only
- Added template for project patterns

### PROJECT_INTAKE.md (Russian & English)
- Deduplicated modularity philosophy section
- Reduced from 40 → ~20 lines
- Added link to ARCHITECTURE.md for full philosophy

### Authoritative Markers
- Added to WORKFLOW.md, SECURITY.md, ARCHITECTURE.md
- Clarifies single source of truth status

### Documentation
- Created DOCS_MAP.md (navigation guide)
- Created CONSISTENCY_AUDIT.md (audit report)
- Created REFACTORING_PLAN.md (this file)
- Updated CHANGELOG.md → v1.2.0

## Impact

- Duplication reduced by 90%
- Maintenance burden reduced by 70%
- Contradiction risk eliminated
- Clear single source of truth for each concept

## Files Changed
- Init/CLAUDE.md, init_eng/CLAUDE.md
- Init/AGENTS.md, init_eng/AGENTS.md
- Init/PROJECT_INTAKE.md, init_eng/PROJECT_INTAKE.md
- Init/WORKFLOW.md, init_eng/WORKFLOW.md (+markers)
- Init/SECURITY.md, init_eng/SECURITY.md (+markers)
- Init/ARCHITECTURE.md, init_eng/ARCHITECTURE.md (+markers)
- DOCS_MAP.md (new)
- CONSISTENCY_AUDIT.md (new)
- REFACTORING_PLAN.md (new)
- CHANGELOG.md (v1.2.0)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

**Status:** 📋 READY TO EXECUTE
**Next Step:** Get user approval → Begin Phase 1

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
