---
description: Migrate existing project to Claude Code Starter framework
---

# Project Migration to Claude Code Starter

## 🎯 What This Command Does

**Stage 1: Analysis and Transfer (automatic)**

1. Scans all project meta-files
2. Transfers information to Init/ structure
3. Archives legacy files to `archive/`
4. Creates `MIGRATION_REPORT.md`
5. Creates `CONFLICTS.md` (if conflicts exist)
6. ⏸️ **STOPS** for review

**After this command completes:**
- Use `/migrate-resolve` to resolve conflicts
- Use `/migrate-finalize` to complete migration
- Use `/migrate-rollback` to rollback

---

## 📋 Migration Process - Stage 1

### Step 1: Scan Meta-Files

**Task:** Find all existing project meta-files

**Action:**
\`\`\`bash
# Scan project root for meta-files
find . -maxdepth 1 -type f \( \
  -name "CLAUDE.md" -o \
  -name "PROJECT_INTAKE.md" -o \
  -name "SECURITY.md" -o \
  -name "ARCHITECTURE.md" -o \
  -name "BACKLOG.md" -o \
  -name "AGENTS.md" -o \
  -name "WORKFLOW.md" -o \
  -name "PLAN*.md" -o \
  -name "spec.md" -o \
  -name "project-requirements.md" -o \
  -name "NOTES.md" \
\)
\`\`\`

**Result:**
- List of found files
- Understanding of what needs migration

---

### Step 2: Create archive/ Structure

**Task:** Create folder for archiving legacy files

**Action:**
\`\`\`bash
# Create archive structure
mkdir -p archive/legacy-docs
mkdir -p archive/backup-\$(date +%Y%m%d-%H%M%S)
\`\`\`

**Result:**
\`\`\`
archive/
├── legacy-docs/          # For all old meta-files
└── backup-20241012-143022/  # Timestamped backup
\`\`\`

---

### Step 3: Analyze File Contents

**Task:** Read and analyze each found file

**For each file:**

1. **Read contents** using Read tool
2. **Determine information category:**
   - Project requirements → PROJECT_INTAKE.md
   - Security rules → SECURITY.md
   - Architecture decisions → ARCHITECTURE.md
   - Task backlog → BACKLOG.md
   - AI instructions → AGENTS.md
   - Workflow processes → WORKFLOW.md

3. **Identify duplicate information**
4. **Find contradictions** between files

---

### Step 4: Map legacy → Init/

**Task:** Create information transfer map

**Mapping table:**

| Legacy File | → | Init/ Target | Section |
|-------------|---|--------------|---------|
| \`spec.md\` | → | \`PROJECT_INTAKE.md\` | Problem/Solution/MVP |
| \`project-requirements.md\` | → | \`PROJECT_INTAKE.md\` | Requirements |
| \`SECURITY.md\` (old) | → | \`SECURITY.md\` (new) | Merge rules |
| \`ARCHITECTURE.md\` (old) | → | \`ARCHITECTURE.md\` (new) | Preserve decisions |
| \`BACKLOG.md\` (old) | → | \`BACKLOG.md\` (new) | Current status |
| \`CLAUDE.md\` (old) | → | \`AGENTS.md\` | Custom instructions |
| \`NOTES.md\` | → | \`AGENTS.md\` or \`WORKFLOW.md\` | Depends on content |
| \`PLAN*.md\` | → | \`archive/legacy-docs/\` | Reference only |

---

### Step 5: Transfer Information

**Task:** Fill Init/ files with information from legacy files

**For PROJECT_INTAKE.md:**
\`\`\`markdown
# Sources:
- spec.md → "Problem & Solution" section
- project-requirements.md → "Requirements" section
- README.md → "Project Overview" section

# Transfer logic:
1. Read spec.md
2. Extract problem, solution, MVP
3. Fill corresponding sections in PROJECT_INTAKE.md
4. Mark with [MIGRATED FROM: spec.md]
\`\`\`

**For SECURITY.md:**
\`\`\`markdown
# Logic:
1. If old SECURITY.md exists → compare with new template
2. Add project-specific rules to "Project-Specific Rules" section
3. Save original in archive/
\`\`\`

**For ARCHITECTURE.md:**
\`\`\`markdown
# Logic:
1. Extract all architectural decisions
2. Fill "Key Decisions" section
3. Update Tech Stack
4. Save legacy version in archive/
\`\`\`

**For AGENTS.md:**
\`\`\`markdown
# Logic:
1. Extract custom instructions from old CLAUDE.md
2. Add to "Custom Instructions" section
3. Extract patterns from NOTES.md
4. Fill "Common Patterns" section
\`\`\`

---

### Step 6: Detect Conflicts

**Task:** Find contradictions in information

**Conflict types:**

1. **Duplicates with different data**
   \`\`\`
   spec.md: "Database: PostgreSQL"
   ARCHITECTURE.md: "Database: MongoDB"
   \`\`\`

2. **Contradictory requirements**
   \`\`\`
   PROJECT_INTAKE.md: "Must support 1000 users"
   spec.md: "MVP for 100 users"
   \`\`\`

3. **Outdated information**
   \`\`\`
   BACKLOG.md: "Auth module: in progress"
   Git history: Auth module committed 2 months ago
   \`\`\`

**Action:**
- Record all conflicts in \`CONFLICTS.md\`
- Mark conflicted sections in Init/ files as \`[CONFLICT: see CONFLICTS.md]\`

---

### Step 7: Archive Legacy Files

**Task:** Move old files to archive/

**Action:**
\`\`\`bash
# For each legacy file:
mv CLAUDE.md archive/legacy-docs/CLAUDE.md.old
mv spec.md archive/legacy-docs/spec.md
mv project-requirements.md archive/legacy-docs/project-requirements.md
# etc...

# Create README in archive/
cat > archive/README.md << 'EOF'
# Legacy Documentation Archive

This folder contains old project meta-files before migration to Claude Code Starter framework.

## Migration date: \$(date +%Y-%m-%d)

## Archived files:
[file list]

## Do not delete these files!
They may be needed for resolving migration conflicts.

After successful migration (after 1-2 sprints) you can safely delete this folder.
EOF
\`\`\`

---

### Step 8: Create MIGRATION_REPORT.md

**Task:** Create migration report

**Report structure:**

\`\`\`markdown
# Migration Report - Stage 1

**Date:** \$(date +%Y-%m-%d %H:%M:%S)
**Framework Version:** 1.2.4

---

## 📊 Summary

- **Legacy files found:** [count]
- **Files migrated:** [count]
- **Files archived:** [count]
- **Conflicts detected:** [count]

---

## 📂 Files Processed

### Migrated to Init/:
- ✅ spec.md → PROJECT_INTAKE.md (Problem, Solution, MVP)
- ✅ SECURITY.md.old → SECURITY.md (merged rules)
- ✅ ARCHITECTURE.md.old → ARCHITECTURE.md (preserved decisions)
[... etc]

### Archived to archive/legacy-docs/:
- 📦 spec.md
- 📦 project-requirements.md
- 📦 CLAUDE.md.old
[... etc]

---

## ⚠️ Conflicts Detected

[If conflicts exist, list them here with references to CONFLICTS.md]

**Action required:** Run \`/migrate-resolve\` to resolve conflicts

---

## ✅ Next Steps

1. **Review migrated content:**
   - Read PROJECT_INTAKE.md
   - Read ARCHITECTURE.md
   - Read BACKLOG.md

2. **Resolve conflicts (if any):**
   \`\`\`
   /migrate-resolve
   \`\`\`

3. **Finalize migration:**
   \`\`\`
   /migrate-finalize
   \`\`\`

4. **OR rollback if needed:**
   \`\`\`
   /migrate-rollback
   \`\`\`

---

## 📋 Checklist Before Finalize

- [ ] PROJECT_INTAKE.md reviewed and accurate
- [ ] SECURITY.md contains all project-specific rules
- [ ] ARCHITECTURE.md reflects current architecture
- [ ] BACKLOG.md shows current project status
- [ ] All conflicts resolved (if any)
- [ ] Legacy files safely archived

---

*Generated by /migrate command*
\`\`\`

---

### Step 9: Create CONFLICTS.md (if conflicts exist)

**Task:** Document all found contradictions

**Structure:**

\`\`\`markdown
# Migration Conflicts

Contradictions found in legacy documentation. Manual resolution required.

---

## Conflict 1: Database Choice

**Location:** PROJECT_INTAKE.md - Tech Stack

**Sources:**
- \`spec.md\` line 45: "Database: PostgreSQL with Prisma ORM"
- \`ARCHITECTURE.md.old\` line 12: "Using MongoDB with Mongoose"

**Current state:** [CONFLICT]

**Options:**
1. Use PostgreSQL (spec.md)
2. Use MongoDB (ARCHITECTURE.md)
3. Specify different choice

**Resolution:** [FILL IN]

---

## Conflict 2: User Capacity

**Location:** PROJECT_INTAKE.md - Non-Functional Requirements

**Sources:**
- \`spec.md\`: "MVP should support 100 concurrent users"
- \`project-requirements.md\`: "Must support 1000+ concurrent users"

**Current state:** [CONFLICT]

**Options:**
1. MVP target: 100 users (spec.md)
2. Full target: 1000+ users (requirements)
3. Specify phased approach

**Resolution:** [FILL IN]

---

[... more conflicts]

---

## How to Resolve

1. For each conflict, choose one option or specify custom resolution
2. Update the corresponding Init/ file with chosen resolution
3. Run \`/migrate-resolve\` to mark conflicts as resolved
4. Run \`/migrate-finalize\` to complete migration
\`\`\`

---

## 🎯 Execution

**This command performs the following actions:**

1. **Scanning:**
   - Use \`find\` and \`Glob\` to find all meta-files
   - Use \`Read\` to read contents

2. **Analysis:**
   - Use \`Grep\` to search for key sections
   - Analyze structure and contents
   - Identify duplicates and contradictions

3. **Transfer:**
   - Use \`Read\` for legacy files
   - Use \`Edit\` to update Init/ files
   - Add markers \`[MIGRATED FROM: filename.md]\`

4. **Archiving:**
   - Use \`Bash\` to create archive/ structure
   - Move legacy files with \`mv\`
   - Create archive/README.md

5. **Reporting:**
   - Use \`Write\` to create MIGRATION_REPORT.md
   - Use \`Write\` to create CONFLICTS.md (if needed)

---

## ⏸️ Stop for Review

**After completing all steps, I will stop and provide:**

1. ✅ **MIGRATION_REPORT.md** - full report
2. ⚠️ **CONFLICTS.md** - conflict list (if any)
3. 📊 **Summary** - brief statistics

**You should:**
1. Read MIGRATION_REPORT.md
2. Check Init/ files
3. Resolve conflicts (if any) via \`/migrate-resolve\`
4. Run \`/migrate-finalize\` to complete

**Or:**
- Run \`/migrate-rollback\` to rollback migration

---

## 🚨 Safety

- ✅ All legacy files saved in \`archive/\`
- ✅ Timestamped backup created
- ✅ Can rollback via \`/migrate-rollback\`
- ✅ Git commit created only in \`/migrate-finalize\`

---

**Ready to start migration? Give the command and I'll begin Stage 1!**
