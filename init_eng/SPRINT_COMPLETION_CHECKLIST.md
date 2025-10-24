# 🏁 Sprint Completion Checklist

**Purpose:** Ensure all meta-files are updated before ending a sprint/phase
**Last Updated:** [DATE]

> **🚨 For AI Agents:** Read this BEFORE saying "done" or finishing the session!

---

## 🎯 When to Use This Checklist

**MUST use when:**
- ✅ Last task of the phase completed (TodoWrite → completed)
- ✅ User says "done", "finished", "let's wrap up"
- ✅ You're about to say "all tasks completed"
- ✅ Planning to end the session

**⚠️ EVEN IF the user doesn't remind you - YOU MUST DO THIS!**

---

## 📋 Mandatory Steps

### Step 1: Update BACKLOG.md

- [ ] Mark completed tasks with `[x]`
- [ ] Update phase status (In Progress → ✅ Complete)
- [ ] Recalculate progress table (%)
- [ ] Add any new tasks discovered during implementation
- [ ] Update "Current Focus" section

**Example:**
```markdown
- [x] **Task 1.1** Setup authentication
- [x] **Task 1.2** Implement login
- [ ] **Task 1.3** Add tests (moved to next sprint)

**Phase 1: Auth Module** [status: ✅ Complete]
```

---

### Step 2: Update PROJECT_SNAPSHOT.md

- [ ] Update "Last Updated" date at the top
- [ ] Change phase status to ✅
- [ ] Add completed tasks to "✅ Completed Tasks" section
- [ ] Update "🔜 Next Stage" with next phase
- [ ] Update "🔄 Update History" with summary
- [ ] Update progress percentage if applicable

**Example:**
```markdown
*Last Updated: 2025-10-23*

**Phase 1: Auth Module** [status: ✅ Complete]

### 2025-10-23 - Phase 1 completed
- Implemented: Authentication, login, JWT tokens
- Progress: 100% Phase 1
- Next stage: Phase 2 (Authorization)
```

---

### Step 3: Update CLAUDE.md

- [ ] Find or create section "🔄 Current Project State"
- [ ] List completed tasks from this sprint
- [ ] Update current phase status
- [ ] Specify next steps
- [ ] Update version number if applicable
- [ ] Note any known bugs or blockers

**Example:**
```markdown
## 🔄 Current Project State

### Version: 0.2.0 (2025-10-23)

**Recently Completed:**
- ✅ Authentication module complete
- ✅ Login/logout implemented
- ✅ JWT token management

**Current Phase:** Phase 2 (Authorization)

**Next Steps:**
- Implement role-based access control
- Add permission system

**Known Bugs:** 0
```

---

### Step 4: Git Commit

```bash
# Add all meta-files
git add BACKLOG.md PROJECT_SNAPSHOT.md CLAUDE.md

# Create commit with descriptive message
git commit -m "docs: complete Phase X - sprint meta-files update

Updated meta-files after completing Phase X (Auth Module):
- BACKLOG.md: Marked tasks as completed, updated progress
- PROJECT_SNAPSHOT.md: Updated status, date, next phase
- CLAUDE.md: Updated current state section

Phase X Progress: 100% (5/5 tasks)
Next Phase: Phase Y (Authorization)
"
```

---

### Step 5: Inform User

**Template message:**
```
✅ Phase X completed!

📋 Updated meta-files:
   - BACKLOG.md (tasks, progress: 100%)
   - PROJECT_SNAPSHOT.md (status, date, next tasks)
   - CLAUDE.md (current state)

📊 Progress: X/X tasks completed

🎯 Next Stage: Phase Y ([description])

Git commit created. Ready for next stage!
```

---

## 🚫 Common Mistakes to Avoid

### ❌ DON'T:
- Skip updating meta-files "to save time" (this is NOT saving!)
- Update only one file (all 3 must be synchronized)
- Forget to update dates and progress percentages
- Leave old "In Progress" statuses
- Say "done" before updating files

### ✅ DO:
- Always update all 3 files (BACKLOG, SNAPSHOT, CLAUDE)
- Be specific about what was completed
- Update dates to today
- Test that git commit includes all meta-files
- Ask user "Meta-files updated. Ready to proceed?"

---

## 🎯 Quick Access Commands

### Use `/finalize` Slash Command (if available)

The `/finalize` command automates this checklist:
```bash
/finalize
```

**What it does:**
- Checks BACKLOG.md for completed tasks
- Prompts you to update PROJECT_SNAPSHOT.md
- Reminds about CLAUDE.md update
- Helps create git commit
- Validates all files are updated

**Status:** [COMING SOON] - See GitHub Issue #11 for /finalize implementation

---

## 📖 Related Documents

- **PROCESS.md** - Full process documentation (lines 78-110)
- **WORKFLOW.md** - Sprint workflow details
- **CLAUDE.md** - Context for AI agents (includes trigger)
- **AGENTS.md** - Sprint Completion Protocol section

---

## ⚠️ Critical Reminder

**Meta-files are NOT optional documentation!**

They are ESSENTIAL for:
- Next session context (Cold Start Protocol)
- Team collaboration (everyone sees current status)
- Token economy (avoid re-reading entire codebase)
- Project continuity (you or another developer can continue)

**5 minutes updating meta-files = 30 minutes saved on next session startup! 💰**

---

*This checklist is part of the Claude Code Starter framework*
*Always keep meta-files synchronized!*
