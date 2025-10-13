# Future Improvements - Documentation Enhancement (v1.3.2+)

**Created:** 2025-10-13
**Priority:** Medium (Priority 2-3)
**Context:** User feedback about confusion between ARCHITECTURE.md and BACKLOG.md for storing operational checklists

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
