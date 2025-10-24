# PROCESS.md — Development Process and Documentation Updates

> 📋 **Purpose:** This file ensures AI and developers update meta-files after each phase/sprint

---

## 🔄 Checklist After Completing Each Phase (Sprint)

### ✅ Mandatory Steps After Phase Completion:

1. **Update BACKLOG.md**
   - [ ] Mark all completed tasks of current phase (`[x]`)
   - [ ] Update phase status from 🔄 to ✅
   - [ ] Update progress table (percentage and number of stages)

2. **Update PROJECT_SNAPSHOT.md**
   - [ ] Update date (*Last updated*)
   - [ ] Change phase status to ✅ COMPLETED
   - [ ] Update "Overall Progress"
   - [ ] Add new files/modules to project structure
   - [ ] Update "✅ Completed Tasks" section
   - [ ] Update "🔜 Next Stage" section
   - [ ] Add new dependencies (if installed)

3. **Update CLAUDE.md**
   - [ ] Update "🔄 Current State" section
   - [ ] Mark completed tasks
   - [ ] Specify next step/phase

4. **Git commit (recommended)**
   - [ ] Make commit describing completed phase
   - [ ] Use format: `feat: complete Phase X - [description]`

---

## 📋 Template for Post-Phase Update

```markdown
## After completing Phase X:

### BACKLOG.md:
- Mark Phase X as ✅
- Recalculate progress: Y% (completed/total stages)

### PROJECT_SNAPSHOT.md:
- Date: [current date]
- Phase X: ✅ COMPLETED
- Overall progress: Y%
- Project structure: add new files
- Completed tasks: list from Phase X
- Next stage: description of Phase X+1

### CLAUDE.md:
- Current state: add completed tasks from Phase X
- Next step: Phase X+1

### Git:
git add .
git commit -m "feat: complete Phase X - [brief description]"
```

---

## 🎯 Phase Completion Criteria

A phase is considered complete when:

1. ✅ All tasks from BACKLOG.md for this phase are done
2. ✅ Code compiles without errors (`npm run build` or equivalent)
3. ✅ Module/component is tested (manually or automatically)
4. ✅ No critical bugs or TODOs in code
5. ✅ Meta-files are updated (BACKLOG, SNAPSHOT, CLAUDE)

---

## 📝 🚨🚨🚨 CRITICAL FOR AI ASSISTANT 🚨🚨🚨

> **For AI agents:** Read this BEFORE completing any phase/sprint!

### 🎯 Trigger: When to read this checklist?

**MANDATORY to read when:**
- ✅ Last task of phase completed (TodoWrite → completed)
- ✅ User says "done", "finishing", "let's wrap up"
- ✅ You're about to say "all tasks completed"
- ✅ Planning to end the session

**⚠️ EVEN IF user doesn't remind - YOU MUST DO THIS YOURSELF!**

---

### After completing each phase:

1. **DO NOT PROCEED TO NEXT PHASE** without updating meta-files
2. **ALWAYS ASK** user: "Phase completed. Update meta-files before next phase?"
3. **USE THE CHECKLIST** above to verify all updates

### Automatic Reminder:

When last task of phase is marked as completed in TodoWrite:

```
⚠️ ATTENTION: Phase completed!
📋 Meta-files need updating:
   1. BACKLOG.md — mark phase ✅, recalculate progress
   2. PROJECT_SNAPSHOT.md — update status, structure, tasks
   3. CLAUDE.md — update current state

❓ Update meta-files now? (Recommended YES)
```

### AI Action Sequence:

1. ✅ Completed task → TodoWrite marked as completed
2. ✅ Checked: is this the last task of phase?
3. ✅ If YES → show reminder above
4. ✅ Ask user
5. ✅ After approval → update BACKLOG, SNAPSHOT, CLAUDE
6. ✅ Suggest git commit
7. ✅ ONLY THEN → proceed to next phase

---

## ⚠️ CRITICAL: After EVERY Commit (for claude-code-starter framework)

> **Applies ONLY to the claude-code-starter project!**
> DO NOT apply to user projects!

**MANDATORY after creating ANY commit in claude-code-starter:**

### 1. Check README.md and README_RU.md:
- [ ] Features list reflects changes
- [ ] Template count is accurate (e.g., "14 templates" if added 3 files)
- [ ] Version badge is current (if release)
- [ ] Cold Start Protocol description is accurate (% token savings)
- [ ] "What's in Init/" table contains all new files

### 2. Check CHANGELOG.md:
- [ ] Entry added for current version
- [ ] All substantial changes described
- [ ] Number of changed lines/files indicated
- [ ] "Why This Matters" section added

### Why this is CRITICAL:
```
The framework's purpose is helping other projects not miss anything.
We ourselves MUST NOT forget to update README and CHANGELOG!
("Shoemaker without shoes" problem v2.0)
```

### Rule for AI:
After EVERY commit in claude-code-starter AI MUST:
1. Read README.md (features section, file count)
2. Read CHANGELOG.md (latest version)
3. Verify consistency with commit
4. If inconsistent → fix immediately

**Instructions:** See AGENTS.md → "Release Management" → "CRITICAL: After EVERY Commit"

---

## 🔧 How to Use This File

### For AI Assistant:

- **Read this file** when starting new session (part of Cold Start Protocol)
- **Follow the checklist** after each phase
- **Don't forget to update meta-files** before moving to next phase

### For Developer:

- **Verify** that AI updated all files after phase
- **Request meta-file update** if AI forgot
- **Use as checklist** for self-updates

---

## 📊 Meta-Files Update Log

### Entry Template:

```markdown
### Phase X: [Phase Name] (YYYY-MM-DD)
- ✅ BACKLOG.md updated
- ✅ PROJECT_SNAPSHOT.md updated
- ✅ CLAUDE.md updated
- ✅ Progress: X% (Y/Z stages)
- ✅ Commit: feat: complete Phase X
```

### Example:

```markdown
### Phase 1: Foundation (2025-10-13)
- ✅ BACKLOG.md updated
- ✅ PROJECT_SNAPSHOT.md created
- ✅ CLAUDE.md updated
- ✅ Progress: 10% (1/10 stages)
- ✅ Commit: feat: complete Phase 1 - project foundation
```

---

## 🎓 Best Practices

1. **Update meta-files immediately after phase completion**, don't postpone
2. **Check progress percentage** — it should grow after each phase
3. **Cross-reference with completed tasks list** in BACKLOG.md
4. **Commit after updating meta-files** to record progress
5. **Ask user for confirmation** before proceeding to next phase

---

## ⚠️ Common Mistakes

### ❌ What NOT to do:

- Proceed to next phase without updating meta-files
- Forget to recalculate progress
- Not update PROJECT_SNAPSHOT.md (most important for Cold Start!)
- Update only one file (need all three: BACKLOG, SNAPSHOT, CLAUDE)

### ✅ What to do:

- Follow checklist sequentially
- Update ALL three files
- Ask user before proceeding
- Commit changes

---

## 🔗 Related Files

- **BACKLOG.md** — operational task plan (WHAT to do)
- **PROJECT_SNAPSHOT.md** — current project state (WHAT is done)
- **CLAUDE.md** — AI context (how to work with project)
- **DEVELOPMENT_PLAN_TEMPLATE.md** — planning methodology (HOW to plan)

---

*This file ensures documentation and code stay synchronized*
*Use it as a checklist after each sprint!*
