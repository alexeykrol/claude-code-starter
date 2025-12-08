# Future Improvements - Sprint Completion & Documentation

**Created:** 2025-10-13
**Last Updated:** 2025-10-23
**Priority:** High (Priority 1 - Sprint Completion) + Medium (Priority 2-3 - Documentation)
**Context:** User feedback about AI forgetting to update meta-files after sprint completion

---

## 🚨 Priority 1: Sprint Completion Enforcement (NEW - 2025-10-23)

### Issue Identified

**Real-world case (supabase-bridge project):**

AI agent completed Phase 4 tasks but:
1. ❌ Did NOT update PROJECT_SNAPSHOT.md
2. ❌ Did NOT update CLAUDE.md
3. ✅ Partially updated BACKLOG.md
4. ❌ Only updated after user reminder: "А в каких мета файлах описан твой цикл?"

**Root Cause:**

- Instructions exist in PROCESS.md (lines 78-110)
- But AI doesn't proactively read them
- No automatic trigger "now you should update meta-files"
- User must remind AI every time

### Security Issue (Related)

AI created .gitignore with wrong pattern:
```
.gitignore:     wp-config_*.php  (underscore)
Real files:     wp-config-*.php  (dash)
Result: Credentials NOT ignored! Security risk!
```

AI didn't validate .gitignore against real files.

---

## ✅ v1.4.3 Solution (Priority 1 - IMPLEMENTED - 2025-10-23)

### Documentation Improvements (5 files updated):

1. **Init/CLAUDE.md** - Added "🚨 ТРИГГЕР: Перед завершением работы"
   - Clear trigger when to read checklist
   - Reference to PROCESS.md and `/finalize` command

2. **Init/AGENTS.md** - Added "🏁 Sprint Completion Protocol"
   - Step-by-step mandatory checklist
   - Template message for user

3. **Init/PROCESS.md** - Strengthened warning
   - Added "🚨🚨🚨" triple emphasis
   - Clear triggers: when to read checklist
   - "ДАЖЕ ЕСЛИ пользователь не напоминает - ТЫ ДОЛЖЕН САМ!"

4. **Init/SECURITY.md** - Added ".gitignore Validation Checklist"
   - 4-step validation process
   - Check pattern matching (dash vs underscore!)
   - Test with `git status --ignored`
   - Verify no secrets in git history

5. **Init/SPRINT_COMPLETION_CHECKLIST.md** - NEW FILE
   - Standalone short checklist (easy to find)
   - Step-by-step guide for all 3 meta-files
   - Git commit template
   - Common mistakes to avoid

---

## 🎯 Priority 1: `/finalize` Slash Command (PROPOSED - Not Yet Implemented)

### Rationale

**Even with documentation improvements, AI may still forget!**

Need "safety net" slash command that:
- User or AI can invoke manually
- Checks if meta-files are up to date
- Prompts to update if missing
- Guides through the update process

### Proposed Implementation

**Command:** `/finalize` or `/sprint-complete`

**What it does:**

1. **Checks BACKLOG.md:**
   - Are there tasks marked [x] but phase still "In Progress"?
   - Prompt: "Phase X has completed tasks. Mark as ✅ Complete?"

2. **Checks PROJECT_SNAPSHOT.md:**
   - Is "Last Updated" date old?
   - Prompt: "Update PROJECT_SNAPSHOT.md with current date and completed tasks?"

3. **Checks CLAUDE.md:**
   - Does "🔄 Текущее состояние" section exist?
   - Prompt: "Update CLAUDE.md current state?"

4. **Offers git commit:**
   - Template: "docs: complete Phase X - sprint meta-files update"
   - Shows diff before committing

5. **Final validation:**
   - "All meta-files updated! ✅"
   - Or: "Still missing: [list] ⚠️"

### Slash Command Specification

**File:** `Init/.claude/commands/finalize.md`

```markdown
# /finalize - Sprint/Phase Completion Helper

Check if all meta-files are updated after completing a sprint/phase.

## Behavior:

1. Read BACKLOG.md → check for completed tasks without phase marked ✅
2. Read PROJECT_SNAPSHOT.md → check if date is current
3. Read CLAUDE.md → check if "Текущее состояние" exists
4. For each missing update → prompt user
5. Offer to create git commit with all updates

## Output:

Show checklist:
- [ ] BACKLOG.md updated
- [ ] PROJECT_SNAPSHOT.md updated
- [ ] CLAUDE.md updated
- [ ] Git commit created

Guide through each unchecked item.
```

### Benefits

- ✅ Works even if AI forgets documentation
- ✅ User can invoke proactively: `/finalize` before ending session
- ✅ AI can invoke as reminder: "Should I run `/finalize`?"
- ✅ Consistent process every time
- ✅ Reduces human error (forgot to update X)

### Implementation Priority

**Priority:** High (Priority 1)
**Effort:** ~3-4 hours
**Impact:** Prevents meta-file desync on EVERY project
**Risk:** Low (doesn't change existing functionality)

**Proposed for:** v1.5.0 or v1.4.4 (minor release)

---

## 🎯 Priority 1B: Post-Compact Hook - Auto Context Restoration (PROPOSED)

### Rationale

**Critical discovery: v1.4.3 has a weakness!**

The 5-layer reminder system (v1.4.3) works perfectly UNTIL the first compaction happens.

**Problem identified:**
- Claude Code compacts context at ~95% capacity
- During compaction, CLAUDE.md instructions may be lost/compressed
- After compaction, AI "forgets" the Sprint Completion Protocol
- User must manually remind AI (as happened in supabase-bridge project)

**Root cause:**
1. CLAUDE.md loaded at session start ✅
2. AI works with instructions ✅
3. Context fills up → compaction triggered 🚨
4. CLAUDE.md instructions compressed/lost in summary ❌
5. AI continues with reduced context ❌
6. **CLAUDE.md is NOT automatically re-read after compaction** ❌

**Evidence:** User analysis + research shows this is a known Claude Code issue.

### Proposed Implementation

**Solution:** Post-Compaction Hook that restores critical context

**Hook name:** `post-compact` or `after-compact`

**What it does:**

1. **Detects compaction event:**
   - Hook triggers after compaction completes
   - Or: workaround using `PreToolUse` + log analysis

2. **Restores context:**
   ```bash
   #!/bin/bash
   # Post-Compact Hook - Restore Sprint Completion Context

   echo "🔄 Compaction occurred. Restoring sprint context..."

   # Force re-read CLAUDE.md
   echo "📖 Re-reading CLAUDE.md for instructions..."

   # Check BACKLOG.md for incomplete tasks
   echo "📋 Checking BACKLOG.md status..."

   # Remind about Sprint Completion Checklist
   echo "⚠️ REMINDER: If phase complete, read SPRINT_COMPLETION_CHECKLIST.md"

   # Suggest /finalize if tasks done
   echo "💡 TIP: Use /finalize to check meta-files"
   ```

3. **Displays reminder:**
   ```
   🔄 Context restored after compaction!

   ✅ CLAUDE.md re-read
   📋 Sprint Completion Protocol active

   If you've completed tasks, remember to:
   - Update BACKLOG.md
   - Update PROJECT_SNAPSHOT.md
   - Update CLAUDE.md
   - Or use /finalize for automatic check
   ```

### Technical Approach

**Challenge:** Claude Code doesn't have direct `PostCompact` hook yet.

**Workarounds (from research):**

1. **Advanced:** Use `PreToolUse` hook + session log analysis
   - Hook checks log file for recent compaction event
   - If detected → force CLAUDE.md re-read
   - Complex but very effective

2. **Simple:** Use `PreCompact` hook to save state
   - Before compaction: save critical instructions to temp file
   - User manually triggers re-read after compaction
   - Less automated but simpler

3. **Wait for official hook:** Request `PostCompact` hook from Anthropic
   - File feature request
   - May be added in future Claude Code versions

### Integration with Existing Solutions

**Complete protection = v1.4.3 + v1.5.0 + v1.6.0:**

```
Session Start:
├─ v1.4.3: 5-layer reminders loaded ✅
│
├─ Work continues... ✅
│
├─ 🚨 COMPACTION at 95%
│  └─ v1.6.0: Post-Compact Hook restores context ✅
│     └─ CLAUDE.md re-read
│     └─ Checklist reminder displayed
│
├─ Work continues with restored context ✅
│
└─ Sprint complete:
   ├─ v1.4.3: Reminders still active ✅
   ├─ v1.5.0: /finalize available as manual fallback ✅
   └─ v1.6.0: Hook ensures reminders not lost ✅
```

### Benefits

**For AI:**
- ✅ Context restored automatically after compaction
- ✅ No reliance on compressed summary
- ✅ Sprint Completion Protocol always active

**For Users:**
- ✅ Don't need to manually remind AI after compaction
- ✅ Consistent behavior throughout long sessions
- ✅ Fewer forgotten meta-file updates

**For Framework:**
- ✅ Closes critical gap in v1.4.3
- ✅ Makes 5-layer system truly robust
- ✅ Combines automation (hooks) + fallbacks (/finalize)

### Implementation Priority

**Priority:** High (Priority 1B - Critical enhancement)
**Effort:** ~4-6 hours
- 2 hours: Research Claude Code hooks API
- 2 hours: Implement hook script
- 1 hour: Testing with real compaction scenarios
- 1 hour: Documentation (README, templates)

**Dependencies:**
- v1.4.3 (already released)
- v1.5.0 (/finalize command) - complementary, not blocking

**Risk:** Medium (depends on hook API availability/stability)

**Proposed for:** v1.6.0

**Alternative if hooks not available:** Document manual compaction workflow in PROCESS.md

---

## 🚀 v2.0.0: Modular Context Management - Professional-Grade Workflow (PROPOSED)

### Vision

**Next evolution of the framework:** From "project-level" to "module-level" context management.

**Core philosophy shift:**
- Projects can be huge → AI doesn't need to remember ALL
- Work happens on specific modules → AI should focus on RELEVANT parts only
- Sprints create checkpoints → No need to remember intermediate dialogs
- Memory = Architecture + Current Focus + Checkpoint

**Problem this solves:**
- Large projects (50k+ lines) overwhelm context window
- AI wastes tokens on irrelevant code
- Lack of clear focus → scattered attention
- No clear "resume point" after compaction/breaks

### Key Insights from Research

**Insight 1: Sprint-based development**
- Work happens in cycles (sprints)
- Each successful sprint = checkpoint
- Intermediate dialogs not important → only final state matters
- Current system: PROJECT_SNAPSHOT.md already provides this! ✅

**Insight 2: Modular focus**
- At any moment, work on ONE module
- Don't need AI to "remember" entire codebase
- Need AI to deeply understand CURRENT module
- Rest of project = high-level architecture reference only

**Insight 3: Context hierarchy**
- Level 1: Project-wide (CLAUDE.md, PROJECT_SNAPSHOT, BACKLOG)
- Level 2: Module-specific (module/CLAUDE.md, focused files)
- Level 3: Sprint-runtime (TodoWrite, /add files, checkpoints)

### Proposed Architecture

#### 1. Hierarchical CLAUDE.md System

**Structure:**
```
project/
├── CLAUDE.md (root - general architecture)
├── PROJECT_SNAPSHOT.md (checkpoint state)
├── BACKLOG.md (all phases + current focus)
│
├── src/
│   ├── auth/
│   │   ├── CLAUDE.md (module - auth specific)
│   │   ├── service.ts
│   │   └── controller.ts
│   │
│   ├── api/
│   │   ├── CLAUDE.md (module - api specific)
│   │   └── routes.ts
│   │
│   └── ui/
│       ├── CLAUDE.md (module - ui specific)
│       └── components/
```

**How it works:**
- Claude Code automatically reads ALL applicable CLAUDE.md files
- Root CLAUDE.md → general project rules, architecture overview
- Module CLAUDE.md → specific implementation details, focused context
- Together → complete but focused picture

**Benefits:**
- ✅ Minimal token usage (only relevant context)
- ✅ Deep module understanding
- ✅ Clear separation of concerns
- ✅ Easy to maintain (update module, not entire doc)

#### 2. Sprint Focus Declaration

**Add to BACKLOG.md:**
```markdown
## 🎯 Current Sprint Focus

**Module:** Auth Module
**Location:** `src/auth/`
**Context:** `src/auth/CLAUDE.md`

**Relevant files (use /add):**
- src/auth/service.ts
- src/auth/controller.ts
- src/user/model.ts

**NOT relevant (ignore):**
- src/api/* (different module)
- src/ui/* (different module)

**Scope:** Only authentication logic
```

**Root CLAUDE.md instruction:**
```markdown
## 🎯 Working with Modules

**BEFORE starting work:**
1. Check BACKLOG.md → "Current Sprint Focus"
2. Read the module's CLAUDE.md
3. Use /add ONLY for relevant files
4. IGNORE files outside focus scope
```

**Benefits:**
- ✅ Explicit focus declaration
- ✅ AI knows what to load
- ✅ AI knows what to ignore
- ✅ User controls scope

#### 3. Module CLAUDE.md Template

**File:** `Init/templates/MODULE_CLAUDE.md`

**Template structure:**
```markdown
# [MODULE_NAME] Module Context

**Purpose:** [What this module does]

## 🏗️ Architecture
- Component 1: [Description]
- Component 2: [Description]

## 📂 File Structure
- service.ts: Core logic
- controller.ts: API endpoints

## 🔧 Current Tasks
See BACKLOG.md for complete list

## 📝 Module-specific Rules
- Coding standards
- Testing approach
- Dependencies

## 🔗 Related Modules
- Module X: For Y functionality
```

**Benefits:**
- ✅ Consistent module documentation
- ✅ Easy to create new modules
- ✅ Self-documenting codebase

#### 4. Checkpoint Workflow Integration

**Add to PROCESS.md:**
```markdown
## 📸 Sprint Checkpoints

### After successful sprint:
1. Update meta-files (BACKLOG, SNAPSHOT, CLAUDE)
2. Git commit
3. 📸 Note checkpoint number for rollback

### If something goes wrong:
/rewind  # Return to last checkpoint
```

**Benefits:**
- ✅ Clear resume points
- ✅ Safety net for experiments
- ✅ No need to "remember" failed attempts

#### 5. Best Practices Documentation

**New file:** `Init/MODULAR_WORKFLOW.md`

**Content:**
- How to structure large projects
- When to create module CLAUDE.md
- How to declare sprint focus
- Managing context in 100k+ line codebases
- Examples from real projects

### Implementation Roadmap

**Broken down into phases for gradual adoption:**

#### v2.0.0 - Foundation (Core Concepts)
**Goal:** Enable basic modular context support

**Deliverables:**
- [ ] Module CLAUDE.md template
- [ ] Update root CLAUDE.md with modular instructions
- [ ] Document hierarchical CLAUDE.md in README
- [ ] Add examples to templates

**Effort:** ~6-8 hours
**Impact:** Foundation for all future modular features

#### v2.1.0 - Sprint Focus System
**Goal:** Formalize focus declaration

**Deliverables:**
- [ ] Add "Current Sprint Focus" section to BACKLOG.md template
- [ ] Update AGENTS.md with focus management instructions
- [ ] Create MODULAR_WORKFLOW.md guide
- [ ] Add /add file examples

**Effort:** ~4-6 hours
**Impact:** Clear focus = better token efficiency

#### v2.2.0 - Checkpoint Integration
**Goal:** Integrate checkpoint workflow

**Deliverables:**
- [ ] Add checkpoint workflow to PROCESS.md
- [ ] Document /rewind usage
- [ ] Add checkpoint best practices
- [ ] Create checkpoint examples

**Effort:** ~3-4 hours
**Impact:** Safety net for experimentation

#### v2.3.0 - Advanced Features
**Goal:** Professional-grade tooling

**Deliverables:**
- [ ] Sub-agent templates (optional)
- [ ] Multi-module coordination guide
- [ ] Token optimization strategies
- [ ] Large codebase case studies

**Effort:** ~8-10 hours
**Impact:** Scales to enterprise projects

### Success Metrics

**How to know v2.0 is successful:**
1. Users can work on 100k+ line projects without context issues
2. Token usage per sprint reduced by 40-60%
3. AI maintains focus on relevant code only
4. Clear resume points after breaks/compaction
5. Positive user feedback on large project management

### Migration Path

**For existing projects:**
1. Start with root CLAUDE.md (already have)
2. Identify main modules
3. Create module CLAUDE.md for largest/most active modules
4. Add Sprint Focus to BACKLOG.md
5. Gradually adopt checkpoint workflow

**No breaking changes** - all features are additive!

### Related Issues

**To be created:**
- Issue #13: Hierarchical CLAUDE.md support
- Issue #14: Sprint Focus Declaration system
- Issue #15: Module CLAUDE.md template
- Issue #16: Checkpoint workflow integration
- Issue #17: Best practices for modular projects

### Philosophy

**Quote from user:**
> "Проблема философски тоже баг"
> (A problem philosophically is also a bug)

**Application:**
- Bug: Context overflow on large projects
- Fix: Modular context management
- Bug: AI loses focus
- Fix: Sprint Focus Declaration
- Bug: No clear resume point
- Fix: Checkpoint workflow

**v2.0 = Systematic solution to philosophical problems**

---

## Background

### Issue Identified

User reported that Claude AI was skipping nested checklist items when they stored detailed project phases (Phase 1, Phase 2, etc.) in ARCHITECTURE.md. This is a semantic confusion problem - AI treats ARCHITECTURE.md as a reference document (WHY), not as an action list (WHAT).

### Root Cause

Framework didn't explicitly prevent users from storing operational checklists in ARCHITECTURE.md. Natural logic: "Project phases are architecture" led users to put task breakdowns in the wrong file.

### v1.3.1 Solution (Priority 1 - IMPLEMENTED)

Added explicit guidance to prevent this confusion:
1. README tables now have ✅ FOR WHAT / ❌ NOT FOR WHAT columns
2. BACKLOG.md has authoritative header explaining its purpose
3. ARCHITECTURE.md has warning against operational checklists
4. AGENTS.md has explicit instructions about where to get checklists
5. CLAUDE.md Cold Start Protocol clarified BACKLOG.md role

---

## Priority 2 Improvements (Future Releases)

### 1. DOCS_MAP.md - Add "Common Mistakes" Section

**File:** DOCS_MAP.md (new section at the end)

**Content:**
```markdown
## ⚠️ Common Mistakes (Anti-Patterns)

### ❌ Mistake 1: Storing Operational Checklists in ARCHITECTURE.md

**Problem:**
User creates detailed "Phase 1, Phase 2, Phase 3" with task checklists in ARCHITECTURE.md.
AI may skip nested items when reading large architecture file.

**Why It Happens:**
- Sounds logical: "project phases = architecture"
- Standard practice in non-AI projects
- But creates semantic confusion for AI

**Correct Approach:**
```markdown
ARCHITECTURE.md (WHY):
└─ "We use modular architecture because [reasons]"

BACKLOG.md (WHAT):
├─ Phase 1: Auth Module
│   ├─ [ ] Task 1.1: Setup
│   ├─ [ ] Task 1.2: Implement login
│   └─ [ ] Task 1.3: Tests
```

**Solution:**
Move detailed task checklists to BACKLOG.md.
Keep only high-level architectural overview in ARCHITECTURE.md.
```

**Impact:** Prevents future users from making the same mistake

---

### 2. Best Practices Section in README - Add Example

**Files:** README.md and README_RU.md

**Section:** "💡 Best Practices" → "For working with Claude Code"

**Add:**
```markdown
✅ **DO:**
- Store detailed project phases with checklists in BACKLOG.md
- Update BACKLOG.md after each task
- ARCHITECTURE.md only for WHY (technology decisions)

❌ **DON'T:**
- Don't store operational checklists in ARCHITECTURE.md
- Don't mix WHY (architecture) and WHAT (tasks) in one file
```

**Impact:** Clear guidance for new users

---

## Priority 3 Improvements (Lower Priority)

### 3. Video Tutorial or GIF

Create visual guide showing:
- ✅ Correct: BACKLOG.md with task checklists
- ❌ Wrong: ARCHITECTURE.md with operational phases

**Format:** GIF animation or short video (30-60 seconds)
**Location:** Add to README.md in "How to Work with the Framework" section

---

### 4. Template Improvement

**File:** Init/ARCHITECTURE.md and init_eng/ARCHITECTURE.md

**Add after "Module Architecture" section:**
```markdown
## ⚠️ Where NOT to Document

**DO NOT use this file for:**
- ❌ Sprint-by-sprint task breakdowns (→ BACKLOG.md)
- ❌ "Phase 1: Do X, Y, Z" operational checklists (→ BACKLOG.md)
- ❌ Current implementation status (→ BACKLOG.md)
- ❌ Daily/weekly tasks (→ BACKLOG.md)

**Use BACKLOG.md instead for operational plans!**
```

---

## Implementation Plan

### Phase 1 (v1.3.2 - Quick wins)
- [ ] Add "Common Mistakes" section to DOCS_MAP.md (2 hours)
- [ ] Update Best Practices in README files (1 hour)
- [ ] Test with users

### Phase 2 (v1.4.0 - Enhanced guidance)
- [ ] Create GIF/video tutorial
- [ ] Add to README
- [ ] Collect user feedback

### Phase 3 (v2.0.0 - Major revision)
- [ ] Based on accumulated user feedback
- [ ] Review all anti-patterns discovered
- [ ] Major documentation restructuring if needed

---

## Success Metrics

**How to know if improvements work:**
1. No more reports of AI skipping nested items in checklists
2. Users naturally use BACKLOG.md for operational plans
3. ARCHITECTURE.md remains clean with only WHY information

---

## Notes

- Wait for more user feedback before implementing Priority 2-3
- Collect real-world use cases
- Avoid hypothetical solutions without validation

---

*This document tracks future improvements based on real user feedback*
*Update after each major user report or pattern identified*
