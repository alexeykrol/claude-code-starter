---
description: Migrate existing project to Claude Code Starter framework
---

# Migrating Legacy Project to Framework

> Use this command to migrate existing projects with legacy meta-documentation to Claude Code Starter framework v1.0

## 🎯 Goal

Transfer all valuable information from scattered meta-files into a structured framework, preserving history and ensuring a single source of truth.

## ⚠️ IMPORTANT

This command performs **Stage 1** of migration (analysis + transfer + archiving).
After completion **MANUAL REVIEW IS REQUIRED** before finalization.
Use `/migrate-finalize` to complete.

---

## 📋 Migration Process (Stage 1)

### Step 0: Check .migrationignore

**IMPORTANT:** Before scanning, check for `.migrationignore` file to exclude files from migration.

#### 0.1. Check .migrationignore existence

```bash
if [ -f ".migrationignore" ]; then
  echo "✅ Found .migrationignore - exclusions will be applied"
else
  echo "ℹ️  .migrationignore not found - offer to create"
fi
```

#### 0.2. If .migrationignore is missing - offer to create

**Automatic detection of exclusion candidates:**

Analyze files and identify potentially NON-meta files:

```
Exclusion criteria:
1. Files in folders: articles/, references/, research/, examples/
2. Files with patterns: meeting-*.md, brainstorm-*.md, temp-*.md
3. Files with dates in name: *-2024-*.md, *-2025-*.md
4. Large files (>50KB) with lots of code (likely articles)
5. Files in folders: old/, archive/, deprecated/
6. Binary files: *.pdf, *.docx, *.pptx
```

**Show user:**
```
🤔 Detected potentially NON-meta files:

📄 docs/articles/how-react-works.md (15KB, many code examples)
   Looks like: tutorial article
   Recommendation: exclude

📄 notes/meeting-2024-01-15.md (2KB, date in name)
   Looks like: meeting record
   Recommendation: exclude

📄 docs/architecture.md (8KB, describes project structure)
   Looks like: project meta-documentation
   Recommendation: migrate

Create .migrationignore with recommendations? [Y/n]
```

#### 0.3. Create .migrationignore if user agreed

If answer is "Y":
```bash
# Create .migrationignore based on recommendations
cat > .migrationignore <<EOF
# Auto-generated migration exclusions

# Reference articles
docs/articles/
docs/references/

# Meeting notes
notes/meeting-*.md

# Research
research/

# Old/archived
old/
archive/
docs/deprecated/

# Binary files
*.pdf
*.docx
EOF

echo "✅ Created .migrationignore"
echo "   Edit file if needed and run /migrate again"
exit 0
```

If answer is "n":
```
ℹ️  Skipping .migrationignore creation
   All found files will be processed
```

#### 0.4. Read and apply .migrationignore

If file exists:
```bash
# Read all patterns (ignoring comments and empty lines)
IGNORE_PATTERNS=$(grep -v '^#' .migrationignore | grep -v '^$')

# Save for use in Step 1
```

### Step 1: Project Scanning

Find all meta-files containing project documentation:

**With .migrationignore if exists:**

```bash
# Search in root and popular directories
find . -maxdepth 3 -type f \( \
  -name "*.md" -o \
  -name "*.txt" -o \
  -name "README*" -o \
  -name "DOCS*" -o \
  -name "NOTES*" -o \
  -name "TODO*" \
) | grep -v "node_modules\|dist\|build\|.next\|init_eng\|Init"
```

**Exclude:**
- node_modules/, dist/, build/, .next/
- Init/ and init_eng/ (this is our new framework)
- Code files (*.js, *.ts, *.py, etc)
- Lock files (package-lock.json, etc)

**Search in:**
- Root README.md, DOCS.md, NOTES.md
- Folders docs/, documentation/, notes/, wiki/
- Architecture files: architecture.md, design.md, structure.md
- Security files: security.md, security.txt
- Backlogs: backlog.md, todo.md, roadmap.md
- Any other .md/.txt with meta-information

### Step 2: Content Analysis

For each found file:
1. Read contents
2. Determine information type (architecture, requirements, processes, security, etc)
3. Create mapping: which legacy file → which init_eng/ file(s)

**Create MAPPING:**
```
Legacy file → Framework file(s)
-----------------------------------------
docs/README.md → PROJECT_INTAKE.md (sections: Overview, Goals)
docs/architecture.md → ARCHITECTURE.md
notes/security.txt → SECURITY.md
TODO.md → BACKLOG.md
api-docs.md → ARCHITECTURE.md (API Structure section)
workflow.md → WORKFLOW.md
...
```

### Step 3: Conflict Detection

Check for potential conflicts:

#### 🔴 Critical conflicts (require resolution):
- **Architectural contradictions**: legacy describes monolith, framework assumes modules
- **Missing critical information**: no security documentation
- **Contradictory requirements**: conflicting descriptions in different legacy files
- **Outdated information**: legacy contains clearly outdated data

#### 🟡 Medium priority:
- **Information duplication**: same information in multiple places
- **Structural differences**: legacy organized differently than framework
- **Incomplete data**: some framework sections cannot be filled from legacy

#### 🟢 Low priority:
- **Cosmetic differences**: naming conventions, formatting
- **Excessive detail**: legacy more detailed than framework needs

### Step 4: Information Migration

For each init_eng/ file:

#### CLAUDE.md
- Update "Tech Stack" section from legacy documentation
- Add project-specific instructions from legacy
- Update bash commands if they differ from defaults

#### PROJECT_INTAKE.md
- **Problem/Solution/Value** from legacy README or docs
- **User Personas** - if exists in legacy, otherwise mark [NEEDS UPDATE]
- **User Flows** - from legacy user stories or docs
- **Features** - from legacy roadmap, backlog, TODO
- **Modular Structure** - analyze current code and propose modular structure

#### SECURITY.md
- Transfer existing security practices from legacy
- If no legacy security docs - mark [CRITICAL: NEEDS FILLING]
- Analyze code for security patterns (auth, validation, etc)

#### ARCHITECTURE.md
- **Tech Stack** from legacy
- **Folder Structure** - current real project structure
- **Module Architecture** - analyze and propose modular division
- **API Structure** from legacy API docs
- **Database Schema** from legacy DB docs
- **Key Decisions** from legacy architecture docs (important to preserve WHY!)

#### BACKLOG.md
- Transfer TODO, roadmap items from legacy
- Analyze current code and update statuses (what's already implemented)
- Mark legacy items as "Migrated from legacy TODO.md"

#### AGENTS.md
- If legacy has specific development instructions - transfer
- Add patterns from codebase analysis

#### WORKFLOW.md
- Transfer existing workflow from legacy
- If none - keep defaults from template

#### PLAN_TEMPLATE.md
- Leave as is (this is template for future tasks)

#### README-TEMPLATE.md
- Don't touch (this is template for final project README)

### Step 5: Archiving Legacy Files

Create archive/ folder and move all legacy meta-files there:

```bash
# Create archive structure
mkdir -p archive/docs
mkdir -p archive/notes
mkdir -p archive/other

# Move files preserving structure
# For example:
mv docs/README.md archive/docs/
mv docs/architecture.md archive/docs/
mv notes/* archive/notes/ 2>/dev/null || true
mv TODO.md archive/other/ 2>/dev/null || true
```

**Create README.md in archive/:**
```markdown
# Archived Legacy Documentation

> These files were archived during migration to Claude Code Starter framework v1.0
> Date: [DATE]

## Migration
All information from these files has been migrated to init_eng/ framework files.
See MIGRATION_REPORT.md for details.

## DO NOT USE
These files are kept for historical reference only.
**Single source of truth is now init_eng/ folder.**
```

### Step 6: Creating MIGRATION_REPORT.md

Create detailed migration report in project root:

```markdown
# Migration Report

> Migration to Claude Code Starter framework v1.0
> Date: [DATE]
> Status: ⏸️ PENDING REVIEW (Step 1 complete)

## 📊 Summary

- **Total meta-files found:** [N]
- **Excluded (via .migrationignore):** [N]
- **Processed for migration:** [N]
- **Files migrated:** [N]
- **Files archived:** [N]
- **Critical conflicts:** [N]
- **Medium conflicts:** [N]
- **Low priority notes:** [N]

## 🚫 Excluded from Migration

The following files were excluded per `.migrationignore`:

### Pattern: `docs/articles/`
- docs/articles/how-jwt-works.md
- docs/articles/react-patterns.md
- docs/articles/graphql-intro.md
(22 more files...)

### Pattern: `notes/meeting-*.md`
- notes/meeting-2024-01-15.md
- notes/meeting-2024-02-20.md
(8 more files...)

**Reason:** These files are reference materials, not project documentation.
**Location:** Remain in original location. **NOT archived** - stay as-is.

**Note:** Excluded files are NOT migrated, NOT archived, and NOT modified.

## 🗂️ Migration Mapping

### Legacy → Framework

| Legacy File | Framework File(s) | Status | Notes |
|-------------|------------------|---------|-------|
| docs/README.md | PROJECT_INTAKE.md | ✅ Migrated | Sections: Overview, Goals |
| docs/architecture.md | ARCHITECTURE.md | ⚠️ Partial | Missing module structure |
| notes/security.txt | SECURITY.md | ❌ Conflict | See CONFLICTS.md #1 |
| TODO.md | BACKLOG.md | ✅ Migrated | Updated statuses based on code |
| ... | ... | ... | ... |

## 📝 Detailed Migration Log

### PROJECT_INTAKE.md
**Sources:**
- docs/README.md → Problem/Solution/Value
- TODO.md → Features list
- notes/user-research.txt → User Personas (partial)

**Added:**
- ✅ Problem statement (from docs/README.md)
- ✅ Solution description (from docs/README.md)
- ✅ Feature list (from TODO.md)
- ⚠️ User Personas (partial from notes, needs completion)
- ❌ User Flows (not found in legacy, marked [NEEDS FILLING])

### ARCHITECTURE.md
**Sources:**
- docs/architecture.md → Tech Stack, Decisions
- Code analysis → Current structure

**Added:**
- ✅ Tech Stack (from docs/architecture.md)
- ✅ Current folder structure (from code analysis)
- ⚠️ Module Architecture (proposed based on code, needs review)
- ✅ Key Decisions (from docs/architecture.md - preserved WHY!)

### SECURITY.md
**Sources:**
- No legacy security documentation found

**Added:**
- ⚠️ Analyzed code for security patterns
- ⚠️ Found: JWT auth, input validation in some routes
- ❌ Missing: comprehensive security policy
- 🔴 **CRITICAL: Requires manual filling**

### BACKLOG.md
**Sources:**
- TODO.md → Tasks
- Code analysis → Current implementation status

**Added:**
- ✅ All TODO items migrated
- ✅ Statuses updated based on code analysis
- ✅ Marked as "Migrated from legacy TODO.md"

### Other files
- AGENTS.md: ✅ Added project-specific patterns from code analysis
- WORKFLOW.md: ✅ Kept default (no legacy workflow found)
- CLAUDE.md: ✅ Updated with project tech stack

## 📦 Archived Files

All files moved to `archive/` directory:
- archive/docs/README.md
- archive/docs/architecture.md
- archive/notes/security.txt
- archive/other/TODO.md
- ... (see archive/README.md for full list)

## ⏭️ Next Steps

1. **REVIEW CONFLICTS**: Read CONFLICTS.md and resolve all issues
2. **REVIEW INIT FILES**: Check all init_eng/ files for accuracy and completeness
3. **FILL GAPS**: Complete sections marked [NEEDS FILLING] or [NEEDS UPDATE]
4. **VERIFY NOTHING LOST**: Compare init_eng/ with archive/ to ensure all critical info migrated
5. **FINALIZE**: Run `/migrate-finalize` when ready

## ⏸️ Migration Status: PAUSED

**Action required:** Review and resolve conflicts before finalizing.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Step 7: Creating CONFLICTS.md (if conflicts exist)

If conflicts are detected, create detailed file:

```markdown
# Migration Conflicts Report

> ⚠️ Review and resolve these conflicts before finalizing migration

**Status:** [N] critical, [N] medium, [N] low priority conflicts

---

## 🔴 Critical Conflicts (require resolution)

### 1. [Conflict Name]
**Priority:** 🔴 Critical
**Legacy:** [What legacy says]
**Framework:** [What framework assumes]
**Conflict:** [What's the contradiction]
**Impact:** [Why this is critical]

**Action Required:**
- [ ] [Specific action 1]
- [ ] [Specific action 2]
- [ ] Update affected files: [file list]

**Recommendation:** [Your recommendation for resolution]

---

### 2. Missing Security Documentation
**Priority:** 🔴 Critical
**Legacy:** No security documentation found in legacy files
**Framework:** SECURITY.md requires comprehensive security policy
**Conflict:** Critical security information missing
**Impact:** Cannot establish security baseline without this

**Action Required:**
- [ ] Review current code for security practices (auth, validation, sanitization)
- [ ] Interview team about security policies
- [ ] Fill all sections of SECURITY.md
- [ ] Run `/security` audit after filling

**Recommendation:** Treat as highest priority - security cannot be skipped.

---

## 🟡 Medium Priority (recommended to resolve)

### 3. [Conflict Name]
**Priority:** 🟡 Medium
**Legacy:** [What's in legacy]
**Framework:** [What's in framework]
**Conflict:** [Contradiction]
**Impact:** [Impact]

**Suggestion:**
- [ ] [Action]

---

## 🟢 Low Priority (can postpone)

### 4. [Conflict Name]
**Priority:** 🟢 Low
**Legacy:** [What's in legacy]
**Framework:** [What's in framework]
**Conflict:** [Contradiction]
**Impact:** Minimal - cosmetic/organizational

**Suggestion:** [Recommendation]

---

## Summary & Next Steps

**Before finalizing migration, you MUST:**
1. ✅ Resolve all 🔴 Critical conflicts
2. ⚠️ Review all 🟡 Medium conflicts (strongly recommended)
3. 📝 Document decisions in appropriate init_eng/ files

**After resolving conflicts:**
- Run `/migrate-finalize` to complete migration

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Step 8: Output Result

After completing all steps, output to user:

```
✅ Migration (Stage 1) complete!

📊 Results:
- Total meta-files found: [N]
- Excluded (.migrationignore): [N]
- Processed for migration: [N]
- Transferred to init_eng/: [N]
- Archived to archive/: [N]
- Conflicts detected: [N] (🔴 [critical] 🟡 [medium] 🟢 [low])

ℹ️  Excluded files:
- [N] files excluded via .migrationignore
- Remain in original location (NOT archived)
- See details in MIGRATION_REPORT.md section "Excluded from Migration"

📄 Created files:
- ✅ MIGRATION_REPORT.md - detailed migration report
- ⚠️ CONFLICTS.md - conflicts requiring resolution (if any)
- ✅ archive/README.md - archive explanation
- ✅ init_eng/ - all files filled from legacy

⏸️ MIGRATION PAUSED FOR REVIEW

📋 WHAT TO DO NEXT:

1. **Read MIGRATION_REPORT.md**
   - Check mapping: are all files accounted for
   - Ensure nothing important was lost

2. **If CONFLICTS.md exists - resolve conflicts**
   - Start with 🔴 critical ones
   - Update init_eng/ files accordingly
   - Delete CONFLICTS.md when all resolved

3. **Check init_eng/ files**
   - PROJECT_INTAKE.md - all sections filled?
   - SECURITY.md - critically important!
   - ARCHITECTURE.md - is architecture correct?
   - BACKLOG.md - are statuses current?

4. **Fill gaps**
   - Find [NEEDS FILLING] and fill
   - Find [NEEDS UPDATE] and update

5. **When ready - finalize migration**
   ```
   /migrate-finalize
   ```

⚠️ DO NOT DELETE:
- MIGRATION_REPORT.md (needed for finalization)
- CONFLICTS.md (if exists - resolve conflicts)
- archive/ (this is project history)

💡 You can ask AI for help:
- "Help resolve conflict #1 in CONFLICTS.md"
- "Fill User Flows section in PROJECT_INTAKE.md"
- "Check all init_eng/ files for completeness"
```

---

## 🔐 Important Checks

Before completing migration, verify:

### Security
- [ ] Didn't accidentally transfer secrets from legacy (API keys, passwords)
- [ ] archive/ contains no credential files
- [ ] SECURITY.md filled or marked as [CRITICAL]

### Completeness
- [ ] All critical legacy files accounted for in MIGRATION_REPORT.md
- [ ] Architectural decisions and their WHY preserved
- [ ] TODO items transferred
- [ ] Tech stack current

### Structure
- [ ] archive/ contains all legacy files
- [ ] archive/README.md created
- [ ] init_eng/ files correctly filled
- [ ] Conflicts documented

---

## 🚫 DON'T DO

- ❌ Don't delete legacy files (only move to archive/)
- ❌ Don't finalize migration automatically (user review needed)
- ❌ Don't skip CONFLICTS.md if critical conflicts exist
- ❌ Don't transfer secrets/credentials to init_eng/ files
- ❌ Don't ignore gaps in SECURITY.md

---

## 💡 Tips

1. **Preserve WHY, not just WHAT** - when migrating architectural decisions, it's critical to preserve rationale (why decision was made)

2. **Check code, not just documentation** - if legacy docs are outdated, analyze real code

3. **Modularity is key** - when migrating to framework, it's the perfect time to plan modular structure

4. **Legacy ≠ Truth** - if legacy contains clearly outdated information, update it, don't copy blindly

5. **Document decisions** - document all non-obvious migration decisions in MIGRATION_REPORT.md

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
