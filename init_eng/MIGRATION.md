# Migration Guide to Claude Code Starter framework

> Complete guide for migrating existing projects with legacy meta-documentation to Claude Code Starter framework v1.0

---

## 📖 Table of Contents

1. [When Migration is Needed](#when-migration-is-needed)
2. [Process Overview](#process-overview)
3. [Migration Preparation](#migration-preparation)
4. [Stage 1: Analysis and Transfer](#stage-1-analysis-and-transfer)
5. [Review Pause](#review-pause)
6. [Stage 2: Finalization](#stage-2-finalization)
7. [Migration Examples](#migration-examples)
8. [Troubleshooting](#troubleshooting)
9. [FAQ](#faq)

---

## When Migration is Needed

### You Already Have a Project with Meta-Documentation

You are NOT starting from scratch, but have:
- Existing codebase
- Scattered meta-files (README, docs, notes, TODO, etc)
- Possibly outdated or incomplete documentation
- Desire to structure everything into a unified framework

### Signs That Migration is Needed

✅ **Migrate if:**
- You have a project with legacy documentation
- Documentation is in different places (docs/, notes/, project root)
- No single source of truth
- Want to use Claude Code Starter framework
- Need structure for working with AI agents

❌ **DON'T migrate if:**
- Starting a new project from scratch (just copy templates)
- You have no documentation at all (create from scratch)
- Project is very small (easier to write documentation anew)

---

## Process Overview

### Two-Stage Process with Pause

```
STAGE 1: Analysis and Transfer
├── Scanning legacy files
├── Analyzing content
├── Detecting conflicts
├── Migrating information to Init/
├── Archiving legacy files
├── Creating MIGRATION_REPORT.md
└── Creating CONFLICTS.md (if any)

⏸️ PAUSE FOR REVIEW
├── Read MIGRATION_REPORT.md
├── Resolve conflicts
├── Check Init/ files
├── Fill gaps
└── Make decision about finalization

STAGE 2: Finalization
├── Final checks
├── Archiving reports
├── Updating CLAUDE.md
├── Updating BACKLOG.md
├── Creating git commit
└── ✅ Migration completed
```

### Why Two Stages?

**Safety and Control:**
- Stage 1 collects information but doesn't make irreversible actions
- Pause gives time to verify the result
- You can fix errors before finalization
- Stage 2 completes the process only after your confirmation

---

## Migration Preparation

### Step 1: Copy Init/ to Project

```bash
# If you are in claude-code-starter repository
cd /path/to/your/project
cp -r /path/to/claude-code-starter/Init/* .
cp -r /path/to/claude-code-starter/Init/.claude .
```

### Step 2: Make Backup (optional but recommended)

```bash
# Create git commit before migration
git add .
git commit -m "Pre-migration snapshot"

# Or create backup manually
tar -czf backup-before-migration.tar.gz .
```

### Step 3: Prepare Project

**Make sure that:**
- [ ] Project is in git (recommended)
- [ ] All changes are committed
- [ ] You have access to project history
- [ ] You know where important documents are located

### Step 4: Launch Claude Code

```bash
# In your project root
claude
```

---

## Stage 1: Analysis and Transfer

### Starting Migration

```bash
/migrate
```

This command automatically:
1. Finds all legacy meta-files
2. Analyzes their content
3. Creates mapping between legacy and framework
4. Transfers information to Init/ files
5. Archives legacy files
6. Creates MIGRATION_REPORT.md
7. Creates CONFLICTS.md (if conflicts exist)
8. ⏸️ Stops for your review

### What Happens Automatically

#### 1. Scanning

AI will find files like:
- `README.md`, `DOCS.md`, `NOTES.md` in root
- Folders `docs/`, `documentation/`, `notes/`, `wiki/`
- `architecture.md`, `design.md`, `structure.md`
- `security.md`, `security.txt`
- `TODO.md`, `backlog.md`, `roadmap.md`
- Any other `.md` or `.txt` with meta-information

**Will NOT be affected:**
- Code (*.js, *.ts, *.py, etc)
- node_modules/, dist/, build/
- Init/ (new framework)
- Lock files

#### 2. Analysis and Mapping

AI will determine:
```
docs/README.md → PROJECT_INTAKE.md (Problem, Solution, Goals)
docs/architecture.md → ARCHITECTURE.md (Tech Stack, Decisions)
notes/security.txt → SECURITY.md (Security practices)
TODO.md → BACKLOG.md (Tasks, features)
api-docs.md → ARCHITECTURE.md (API Structure section)
```

#### 3. Conflict Detection

AI will identify:

**🔴 Critical:**
- Missing security documentation
- Architecture contradictions
- Outdated critical information

**🟡 Medium:**
- Information duplication
- Structural differences
- Data incompleteness

**🟢 Low:**
- Cosmetic differences
- Excessive detail

#### 4. Information Migration

AI will fill Init/ files:
- **CLAUDE.md** - Tech Stack, specific instructions
- **PROJECT_INTAKE.md** - Problem/Solution/Value, User Personas, User Flows, Features
- **SECURITY.md** - Security practices (or mark [CRITICAL: NEEDS FILLING])
- **ARCHITECTURE.md** - Tech Stack, Folder Structure, Module Architecture, API, DB
- **BACKLOG.md** - TODO items with updated statuses
- **AGENTS.md** - Patterns from code
- **WORKFLOW.md** - Existing workflows (or defaults)

#### 5. Archiving

All legacy files will move to:
```
archive/
├── README.md (explanation that this is archive)
├── docs/
│   ├── README.md
│   └── architecture.md
├── notes/
│   └── security.txt
└── other/
    └── TODO.md
```

#### 6. Reports

**MIGRATION_REPORT.md** will contain:
- Summary statistics
- Detailed mapping
- Migration logs for each file
- List of archived files
- Next steps

**CONFLICTS.md** (if conflicts exist):
- List of all conflicts
- Priorities (🔴🟡🟢)
- Resolution recommendations
- Action checklists

---

## Review Pause

### ⏸️ After Stage 1 Migration Stops

You will receive a message:
```
✅ Migration (Stage 1) completed!

📊 Results:
- Legacy files found: 8
- Transferred to Init/: 7
- Archived to archive/: 8
- Conflicts detected: 3 (🔴 1 🟡 1 🟢 1)

⏸️ MIGRATION PAUSED FOR REVIEW

📋 WHAT TO DO NEXT: ...
```

### What You Need to Do

#### 1. Read MIGRATION_REPORT.md

```bash
# Open in editor
code MIGRATION_REPORT.md

# Or ask AI
"Read MIGRATION_REPORT.md and tell me the main points"
```

**Check:**
- ✅ All legacy files are accounted for
- ✅ Mapping is correct
- ✅ Nothing important is lost
- ✅ Migration logs make sense

#### 2. If CONFLICTS.md Exists - Resolve Conflicts

##### Automatic Resolution via `/migrate-resolve`

**Recommended approach:**

```bash
/migrate-resolve
```

This command launches interactive conflict resolution process:

✅ **What it does:**
- Reads each conflict from CONFLICTS.md
- Analyzes legacy files and Init/ files
- Proposes smart solution (merge strategy)
- Asks for your confirmation for each conflict
- Applies changes automatically after [A]
- Creates detailed log in CONFLICT_RESOLUTION_LOG.md
- Creates backups before changes

✅ **Interactive choice for each conflict:**
```
Conflict #1: README.md vs PROJECT_INTAKE.md

🤖 Proposed solution (merge strategy):
1. Take "Architecture" section from archive/docs/README.md
2. Insert into Init/ARCHITECTURE.md after "## Core Principles"
...

Your choice:
[A] Auto-resolve - apply AI suggestion
[M] Manual resolution - I'll handle it myself later
[S] Skip - move to next conflict
[Q] Quit - finish working
```

✅ **Safety:**
- Backups in `.conflict_resolution_backup/`
- Can rollback via `/migrate-rollback --conflicts-only`
- Legacy files not modified
- Requires confirmation at each step

**Details:** See `.claude/commands/migrate-resolve.md`

---

##### Manual Conflict Resolution

If you prefer to resolve manually:

```bash
# Open CONFLICTS.md
code CONFLICTS.md

# Or ask AI for help
"Help resolve conflict #1 in CONFLICTS.md"
```

**Resolution order:**
1. Start with 🔴 critical conflicts (MUST resolve)
2. Then 🟡 medium (SHOULD resolve)
3. 🟢 low can be postponed

**Typical Conflicts and Solutions:**

##### Missing Security Documentation (🔴)
```
Problem: No security documentation in legacy
Solution:
1. "Analyze code for security patterns"
2. "Fill SECURITY.md based on code analysis"
3. "Run /security for audit"
```

##### Architecture Mismatch (🔴)
```
Problem: Legacy describes monolith, framework assumes modules
Solution:
1. "Analyze current project structure"
2. "Suggest modular separation"
3. "Update ARCHITECTURE.md with modularity plan"
```

##### Incomplete User Personas (🟡)
```
Problem: User Personas not found in legacy
Solution:
1. "Based on features and code create User Personas"
2. "Fill User Personas section in PROJECT_INTAKE.md"
```

#### 3. Check Init/ Files

**Open each file and verify:**

```bash
# PROJECT_INTAKE.md
code Init/PROJECT_INTAKE.md
```
- [ ] Problem/Solution/Value filled
- [ ] User Personas created (at least 1-2)
- [ ] User Flows described
- [ ] Features listed
- [ ] Modular Structure planned

```bash
# SECURITY.md
code Init/SECURITY.md
```
- [ ] Does NOT contain [CRITICAL: NEEDS FILLING]
- [ ] All sections filled
- [ ] Project-specific practices described

```bash
# ARCHITECTURE.md
code Init/ARCHITECTURE.md
```
- [ ] Tech Stack is current
- [ ] Folder Structure is correct
- [ ] Module Architecture planned
- [ ] Key Decisions preserved (WHY!)

```bash
# BACKLOG.md
code Init/BACKLOG.md
```
- [ ] TODO items transferred
- [ ] Statuses are current
- [ ] Priorities set

#### 4. Fill Gaps

Look for markers:
- `[NEEDS FILLING]` - section not filled
- `[NEEDS UPDATE]` - information incomplete
- `[CRITICAL: NEEDS FILLING]` - critical to fill

**Ask AI for help:**
```
"Find all [NEEDS FILLING] in Init/ files and help fill them"
"Fill User Flows section in PROJECT_INTAKE.md based on features"
"Update ARCHITECTURE.md with modular structure"
```

#### 5. Compare with archive/

```bash
# Check that nothing is lost
"Compare Init/ARCHITECTURE.md with archive/docs/architecture.md - is all information transferred?"
"Check that all TODOs from archive/other/TODO.md are in BACKLOG.md"
```

### When Ready for Finalization

**Readiness criteria:**
- ✅ MIGRATION_REPORT.md read and understood
- ✅ All 🔴 critical conflicts resolved
- ✅ SECURITY.md completely filled (this is critical!)
- ✅ PROJECT_INTAKE.md filled (minimum Problem/Solution/Value + Features)
- ✅ ARCHITECTURE.md is current
- ✅ BACKLOG.md updated
- ✅ You are confident nothing is lost

**If not ready - don't rush!**
- Can continue working on project
- Return to migration later
- Ask AI to help fill gaps

---

## Stage 2: Finalization

### Starting Finalization

```bash
/migrate-finalize
```

### What Happens

#### 1. Pre-checks

AI will verify:
- [ ] MIGRATION_REPORT.md exists
- [ ] archive/ created
- [ ] Init/ files filled
- [ ] SECURITY.md doesn't contain [CRITICAL: NEEDS FILLING]
- [ ] Conflicts resolved

**If checks fail:**
```
🛑 Finalization stopped

Reason: SECURITY.md contains [CRITICAL: NEEDS FILLING]

Actions:
1. Fill all SECURITY.md sections
2. Run /security for audit
3. Return to /migrate-finalize
```

#### 2. Finalizing Documents

- ✅ Adds final section to MIGRATION_REPORT.md
- ✅ Moves MIGRATION_REPORT.md to archive/
- ✅ Moves CONFLICTS.md to archive/ (if existed)

#### 3. Updating Files

**CLAUDE.md** receives migration notice:
```markdown
## 📝 Migration Notice

> This project was migrated to Claude Code Starter framework v1.0 on 2025-01-10

**Archive location:** `archive/`
**Migration report:** `archive/MIGRATION_REPORT.md`
**Framework version:** v1.0

**Single source of truth is now Init/ folder.**
Legacy documentation archived for reference only.
```

**BACKLOG.md** receives entry:
```markdown
### 2025-01-10 - Migrated to Claude Code Starter v1.0
**Status:** ✅ Complete
**Description:** Successfully migrated legacy documentation to structured framework
```

#### 4. Git Commit

AI creates commit:
```
chore: Finalize migration to Claude Code Starter framework v1.0

Successfully migrated legacy documentation to structured framework.

Changes:
- All legacy meta-files archived to archive/
- Documentation restructured into Init/ framework
- SECURITY.md, PROJECT_INTAKE.md, ARCHITECTURE.md updated
- BACKLOG.md updated with current status
- Single source of truth established

Migration report: archive/MIGRATION_REPORT.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

#### 5. Final Output

```
🎉 MIGRATION COMPLETED SUCCESSFULLY!

✅ Finalization performed:
- ✅ MIGRATION_REPORT.md archived
- ✅ CLAUDE.md updated
- ✅ BACKLOG.md updated
- ✅ Git commit created

📂 Project structure: ...

🎯 What's next: ...
```

### After Finalization

**Project structure:**
```
your-project/
├── Init/                    # ✅ SINGLE SOURCE OF TRUTH
│   ├── CLAUDE.md
│   ├── PROJECT_INTAKE.md
│   ├── SECURITY.md
│   ├── ARCHITECTURE.md
│   ├── BACKLOG.md
│   └── ...
├── archive/                 # For reference only
│   ├── README.md
│   ├── MIGRATION_REPORT.md
│   ├── CONFLICTS_RESOLVED.md (if existed)
│   ├── docs/...
│   ├── notes/...
│   └── other/...
└── src/                     # Code unchanged
```

**What to do next:**
1. Read updated CLAUDE.md
2. Use Init/ as single source of truth
3. Update documentation when changes occur
4. Use slash-commands for work
5. Ignore archive/ (for reference only)

---

## Migration Examples

### Example 1: Project with Minimal Documentation

**Before migration:**
```
project/
├── README.md (200 lines - everything mixed)
├── TODO.txt (task list)
└── src/
```

**Process:**
1. `/migrate` - analyzes README.md and TODO.txt
2. Creates PROJECT_INTAKE.md from README.md
3. Creates BACKLOG.md from TODO.txt
4. Marks SECURITY.md as [CRITICAL: NEEDS FILLING]
5. Suggests modular structure based on code
6. ⏸️ Pause
7. User fills SECURITY.md
8. `/migrate-finalize` - completes

**After migration:**
```
project/
├── Init/
│   ├── PROJECT_INTAKE.md (from README.md)
│   ├── SECURITY.md (filled manually)
│   ├── ARCHITECTURE.md (from code analysis)
│   ├── BACKLOG.md (from TODO.txt)
│   └── ...
├── archive/
│   ├── README.md
│   └── TODO.txt
└── src/
```

### Example 2: Project with Extensive Legacy Documentation

**Before migration:**
```
project/
├── docs/
│   ├── README.md
│   ├── architecture.md
│   ├── api-reference.md
│   ├── deployment.md
│   └── security-notes.txt
├── notes/
│   ├── user-research.md
│   ├── design-decisions.md
│   └── tech-debt.md
├── TODO.md
└── src/
```

**Process:**
1. `/migrate` - analyzes all docs/ and notes/
2. Creates mapping:
   - docs/README.md → PROJECT_INTAKE.md (Problem/Solution)
   - docs/architecture.md → ARCHITECTURE.md (Tech Stack, Decisions)
   - docs/api-reference.md → ARCHITECTURE.md (API section)
   - docs/security-notes.txt → SECURITY.md
   - notes/user-research.md → PROJECT_INTAKE.md (User Personas)
   - notes/design-decisions.md → ARCHITECTURE.md (Key Decisions - WHY!)
   - notes/tech-debt.md → BACKLOG.md (Technical Debt section)
   - TODO.md → BACKLOG.md (Tasks)
3. Detects conflict 🟡: API docs duplication in different places
4. ⏸️ Pause
5. User resolves: keep in ARCHITECTURE.md, remove duplicates
6. `/migrate-finalize` - completes

**After migration:**
```
project/
├── Init/
│   ├── PROJECT_INTAKE.md (from docs/README.md + notes/user-research.md)
│   ├── SECURITY.md (from docs/security-notes.txt)
│   ├── ARCHITECTURE.md (from docs/architecture.md + api-reference + notes/design-decisions)
│   ├── BACKLOG.md (from TODO.md + notes/tech-debt.md)
│   └── ...
├── archive/
│   ├── docs/...
│   ├── notes/...
│   └── TODO.md
└── src/
```

### Example 3: Project with Contradictory Documentation

**Before migration:**
```
project/
├── README.md (describes monolithic architecture)
├── docs/
│   └── new-architecture.md (plan to migrate to microservices)
├── TODO.md (old tasks, many already done)
└── src/ (actually code is partially modular)
```

**Process:**
1. `/migrate` - analyzes contradictions
2. Detects conflicts:
   - 🔴 Architecture: README.md says monolith, new-architecture.md microservices, code is modular
   - 🟡 BACKLOG: TODO.md is outdated
3. Creates CONFLICTS.md with detailed description
4. ⏸️ Pause
5. User:
   - Analyzes real code: "Analyze src/ and determine real architecture"
   - Decides: "We use modular monolith, not microservices"
   - Updates ARCHITECTURE.md with reality
   - Updates BACKLOG.md with statuses: "Check which tasks from TODO.md are already implemented"
6. Removes CONFLICTS.md
7. `/migrate-finalize` - completes

**After migration:**
```
project/
├── Init/
│   ├── ARCHITECTURE.md (real modular architecture)
│   ├── BACKLOG.md (current tasks with correct statuses)
│   └── ...
├── archive/
│   ├── README.md (outdated)
│   ├── docs/new-architecture.md (plan that wasn't implemented)
│   ├── TODO.md (outdated)
│   └── MIGRATION_REPORT.md (how conflicts were resolved)
└── src/
```

---

## Troubleshooting

### Problem: "AI didn't find some important files"

**Solution:**
```
1. After /migrate check MIGRATION_REPORT.md
2. If file is not accounted for:
   "Read docs/important-file.md and add information to Init/PROJECT_INTAKE.md"
3. Manually supplement Init/ files
4. Continue with /migrate-finalize
```

### Problem: "Too many conflicts, don't know where to start"

**Solution via `/migrate-resolve`:**
```bash
/migrate-resolve
```

This command:
- Walks you through each conflict interactively
- Proposes concrete solution for each
- You choose [A]uto/[M]anual/[S]kip/[Q]uit
- Creates backups and logs
- Can quit [Q] anytime and return later

**Manual solution:**
```
1. Open CONFLICTS.md
2. Focus only on 🔴 critical ones
3. Resolve one by one:
   "Help resolve critical conflict #1"
4. 🟡 and 🟢 can be postponed for later
```

### Problem: "SECURITY.md is empty, don't know what to write"

**Solution:**
```
1. "Analyze project code for security patterns"
2. "Find where auth, validation, sanitization are used"
3. "Based on analysis fill SECURITY.md"
4. "Run /security for final audit"
5. Supplement manually with project-specific rules
```

### Problem: "Legacy documentation is severely outdated"

**Solution:**
```
1. Don't blindly copy outdated information
2. "Analyze real code in src/ and update ARCHITECTURE.md"
3. "Compare legacy TODO.md with code and update statuses in BACKLOG.md"
4. Use legacy as reference, but trust the code
```

### Problem: "Want to rollback migration"

**Solution: Use `/migrate-rollback`**

```bash
/migrate-rollback
```

This command automatically:
- Determines migration status (before or after finalization)
- Restores legacy files from archive/
- Deletes or restores Init/
- Reverts git commit (if any)
- Creates backup copy in case of issues

**Supported scenarios:**

#### Before finalization (after `/migrate`)
```
✅ Quick rollback:
- Restores legacy from archive/
- Deletes Init/, MIGRATION_REPORT.md, CONFLICTS.md
- Deletes archive/ (optional)
```

#### After finalization (after `/migrate-finalize`)
```
✅ Rollback with git:
- Uses git revert to rollback commit
- Restores legacy from archive/
- Deletes or restores Init/ to pre-migration state
- Creates rollback commit
```

**Safety:**
- ⚠️ Backup copy created in `.rollback_backup/`
- ⚠️ Asks for confirmation before actions
- ⚠️ Can be interrupted at any stage

**Manual rollback:**

If command doesn't work, see details in `.claude/commands/migrate-rollback.md`

### Problem: "After migration team doesn't know where to look for information"

**Solution:**
```
1. Hold team meeting
2. Show new Init/ structure
3. Explain:
   - Init/ - single source of truth
   - archive/ - for reference only
   - Each file has clear purpose
4. Create "Where to find what" checklist:
   - Requirements → PROJECT_INTAKE.md
   - Architecture → ARCHITECTURE.md
   - Tasks → BACKLOG.md
   - Security → SECURITY.md
5. Update onboarding documentation
```

---

## FAQ

### Q: How long does migration take?

**A:** Depends on project size:
- Small project (1-3 legacy files): 15-30 minutes
- Medium project (5-10 legacy files): 1-2 hours
- Large project (10+ legacy files): 2-4 hours

Most time is your manual review and filling gaps.

### Q: Can migration be done gradually?

**A:** No, migration is atomic:
- Either fully migrate
- Or don't migrate at all

But after migration you can gradually improve Init/ files.

### Q: What to do with legacy files after migration?

**A:**
- DON'T delete archive/ (project history)
- DON'T update files in archive/
- Use only for reference
- Init/ - only source of truth

### Q: Should README.md be migrated?

**A:**
- Information from README.md migrates to PROJECT_INTAKE.md
- README.md itself remains (needed for GitHub)
- After migration update README.md using README-TEMPLATE.md from Init/

### Q: What if project already has CLAUDE.md?

**A:**
- AI will save your existing CLAUDE.md to archive/
- Creates new one from template
- Transfers specific instructions from old one
- You can manually supplement after migration

### Q: Is it safe to delete CONFLICTS.md?

**A:**
- Delete only after resolving ALL conflicts
- /migrate-finalize moves it to archive/CONFLICTS_RESOLVED.md
- Don't delete manually before finalization

### Q: Can /migrate be run multiple times?

**A:**
- No, /migrate works only once
- If need to restart:
  1. Delete Init/ and archive/
  2. Run /migrate again
- After /migrate-finalize repeated migration is impossible

### Q: What to do if AI transferred information to wrong file?

**A:**
```
1. After /migrate (before finalization):
   - Manually move information where needed
   - Update Init/ files
   - Continue with /migrate-finalize

2. After /migrate-finalize:
   - Just edit Init/ files
   - Init/ - these are regular markdown files
   - Create commit with corrections
```

### Q: Should CI/CD be updated after migration?

**A:** Possibly, if CI/CD used legacy files:
```yaml
# Before migration
- run: cat docs/version.txt

# After migration
- run: cat Init/BACKLOG.md | grep "Current Version"
```

Check all scripts that read legacy files.

---

## Successful Migration Checklist

### Before Migration
- [ ] Project in git
- [ ] All changes committed
- [ ] Backup made (optional)
- [ ] Init/ copied to project
- [ ] Claude Code launched

### After Stage 1
- [ ] MIGRATION_REPORT.md read
- [ ] All legacy files accounted for
- [ ] Mapping is correct
- [ ] All 🔴 conflicts resolved
- [ ] SECURITY.md filled
- [ ] PROJECT_INTAKE.md filled
- [ ] ARCHITECTURE.md is current
- [ ] BACKLOG.md updated
- [ ] No [NEEDS FILLING] in critical places

### After Stage 2
- [ ] /migrate-finalize executed
- [ ] Git commit created
- [ ] Init/ - single source of truth
- [ ] archive/ contains all history
- [ ] Team knows about new structure
- [ ] CI/CD updated (if needed)

---

## Useful Commands

```bash
# View migration report
cat archive/MIGRATION_REPORT.md

# Check that all legacy files in archive
ls -la archive/

# Compare Init/ with archive/
diff Init/ARCHITECTURE.md archive/docs/architecture.md

# Find [NEEDS FILLING] in Init/
grep -r "NEEDS FILLING" Init/

# Check that no secrets in Init/
grep -r "password\|api_key\|secret" Init/

# View change history
git log --oneline --follow Init/ARCHITECTURE.md
```

---

## Additional Resources

- **CLAUDE.md** - main context file after migration
- **PROJECT_INTAKE.md** - project requirements and goals
- **ARCHITECTURE.md** - architecture and technical decisions
- **BACKLOG.md** - current status and plans
- **SECURITY.md** - security rules
- **archive/MIGRATION_REPORT.md** - detailed migration report

---

**Successful migration! 🚀**

If you have questions - create [Issue on GitHub](https://github.com/alexeykrol/claude-code-starter/issues)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
