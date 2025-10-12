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

## 🎯 Execution Mode

**CRITICAL: Stage 1 executes FULLY AUTOMATICALLY without stops!**

### Execution Rules:

1. **Group changes:**
   - ONE `Edit` call per Init/ file (not multiple Updates)
   - Collect ALL changes for file into one diff
   - Example: All PROJECT_INTAKE.md updates → one Edit call

2. **Don't wait for confirmations:**
   - Execute all tool calls without pauses between them
   - Edit → Edit → Edit → Bash → Write
   - Don't wait for user response between steps

3. **Required files:**
   - MIGRATION_REPORT.md - ALWAYS create
   - CONFLICTS.md - create for ANY conflicts (including 🟢 low priority)
   - archive/README.md - ALWAYS create
   - SECURITY.md - ALWAYS update project-specific rules

4. **Stop ONLY after:**
   - ✅ All Init/ files updated (including SECURITY.md!)
   - ✅ All legacy files in archive/legacy-docs/
   - ✅ archive/backup-YYYYMMDD-HHMMSS/ created with copies
   - ✅ MIGRATION_REPORT.md created
   - ✅ CONFLICTS.md created (if conflicts exist)
   - ✅ PAUSE message shown

**DO NOT add recommendations, commit messages, or additional instructions in final output!**

---

## 💡 Token Usage Optimization

To save tokens during migration:

1. **Group changes:**
   - Collect ALL changes for one Init/ file
   - Use ONE `Edit` call per file (not multiple Updates)
   - Example: 6 updates to PROJECT_INTAKE.md → 1 large Edit

2. **Targeted reading:**
   - Don't re-read entire template file (775 lines)
   - Use targeted edit with explicit line numbers
   - Read only necessary sections from legacy files

3. **Batch operations:**
   - Group multiple tool calls in one message where possible
   - Example: Edit PROJECT_INTAKE + Edit ARCHITECTURE + Bash mkdir in one message

4. **Simplify report:**
   - MIGRATION_REPORT detailed but not excessive
   - Final message brief (only 4 actions)

**Goal:** Migration of 2-3 legacy files = ~40-50k tokens (not 87k+)

---

## 📋 Migration Process - Stage 1

### Step 1: Scan Meta-Files

**Task:** Find all existing project meta-files

**Action:**
```bash
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
```

**Result:**
- List of found files
- Understanding of what needs migration

---

### Step 2: Create archive/ Structure

**Task:** Create folder for archiving legacy files

**Action:**
```bash
# Create archive structure
mkdir -p archive/legacy-docs
mkdir -p archive/backup-$(date +%Y%m%d-%H%M%S)
```

**Result:**
```
archive/
├── legacy-docs/          # For all old meta-files
└── backup-20241012-143022/  # Timestamped backup
```

**IMPORTANT:** Must create BOTH folders:
- `archive/legacy-docs/` - for main archive
- `archive/backup-YYYYMMDD-HHMMSS/` - for timestamped backup

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
| `spec.md` | → | `PROJECT_INTAKE.md` | Problem/Solution/MVP |
| `project-requirements.md` | → | `PROJECT_INTAKE.md` | Requirements |
| `SECURITY.md` (old) | → | `SECURITY.md` (new) | Merge rules |
| `ARCHITECTURE.md` (old) | → | `ARCHITECTURE.md` (new) | Preserve decisions |
| `BACKLOG.md` (old) | → | `BACKLOG.md` (new) | Current status |
| `CLAUDE.md` (old) | → | `AGENTS.md` | Custom instructions |
| `NOTES.md` | → | `AGENTS.md` or `WORKFLOW.md` | Depends on content |
| `PLAN*.md` | → | `archive/legacy-docs/` | Reference only |

---

### Step 5: Transfer Information

**Task:** Fill Init/ files with information from legacy files

**For PROJECT_INTAKE.md:**
```markdown
# Sources:
- spec.md → "Problem & Solution" section
- project-requirements.md → "Requirements" section
- README.md → "Project Overview" section

# Transfer logic:
1. Read spec.md
2. Extract problem, solution, MVP
3. Fill corresponding sections in PROJECT_INTAKE.md
4. Add marker: <!-- MIGRATED FROM: spec.md -->
```

**Add source markers:**

At the beginning of each updated section in Init/ files add comment:

```markdown
<!-- MIGRATED FROM: README.md -->
## Tech Stack
...

<!-- MIGRATED FROM: spec.md -->
## Security Architecture
...
```

This helps track where information came from.

---

**For SECURITY.md:**

**CRITICAL: ALWAYS update SECURITY.md!**

Even if template is comprehensive - add project-specific rules:

```markdown
# Logic:
1. Read legacy files and search for security-related information:
   - How API keys are stored
   - Security architecture (serverless/backend/etc)
   - Client vs Server secrets
   - Environment variables
   - Special project security practices

2. Find section "## 🔒 Project-Specific Security Rules" in Init/SECURITY.md

3. Add project-specific rules

4. Save original to archive/legacy-docs/ (if existed)
```

**Example addition to SECURITY.md:**

```markdown
## 🔒 Project-Specific Security Rules

### API Key Management
- ✅ API keys NEVER passed to client
- ✅ Serverless backend creates sessions with API key
- ✅ Client receives only `client_secret` for connection
- ❌ NEVER store `OPENAI_API_KEY` in frontend code

### Architecture Security
- ✅ Backend: Vite middleware (dev) + Netlify Functions (prod)
- ✅ Environment: `.env` file for secrets (DON'T commit!)
- ✅ Client: Receives only safe credentials via API call

<!-- MIGRATED FROM: spec.md, README.md -->
```

**DON'T SKIP updating SECURITY.md!** Even if legacy files have little security info - add what you found.

---

**For ARCHITECTURE.md:**
```markdown
# Logic:
1. Extract all architectural decisions
2. Fill "Key Decisions" section with reasoning (WHY!)
3. Update Tech Stack
4. Add marker: <!-- MIGRATED FROM: architecture.md -->
5. Save legacy version to archive/legacy-docs/
```

---

**For AGENTS.md:**
```markdown
# Logic:
1. Extract custom instructions from old CLAUDE.md
2. Add to "Custom Instructions" section
3. Extract patterns from NOTES.md
4. Fill "Common Patterns" section
5. Add marker: <!-- MIGRATED FROM: CLAUDE.md, NOTES.md -->
```

---

### Step 6: Detect Conflicts

**Task:** Find contradictions in information

**Conflict types:**

1. **Duplicates with different data**
   ```
   spec.md: "Database: PostgreSQL"
   ARCHITECTURE.md: "Database: MongoDB"
   ```

2. **Contradictory requirements**
   ```
   PROJECT_INTAKE.md: "Must support 1000 users"
   spec.md: "MVP for 100 users"
   ```

3. **Outdated information**
   ```
   BACKLOG.md: "Auth module: in progress"
   Git history: Auth module committed 2 months ago
   ```

4. **🟢 Low priority notes:**
   ```
   Typo in filename: scpec.md → should be spec.md
   Outdated comments
   Formatting inconsistencies
   ```

**Action:**
- Record ALL conflicts in `CONFLICTS.md` (including low priority!)
- Mark conflicted sections in Init/ files as `[CONFLICT: see CONFLICTS.md]`

---

### Step 7: Archive Legacy Files

**Task:** Move old files to archive/

**Action:**
```bash
# For each legacy file:
mv README.md archive/legacy-docs/README.md
mv spec.md archive/legacy-docs/spec.md
mv project-requirements.md archive/legacy-docs/project-requirements.md
# etc...

# IMPORTANT: Copy to backup
cp -r archive/legacy-docs/* archive/backup-$(date +%Y%m%d-%H%M%S)/

# Create README in archive/
cat > archive/README.md << 'EOF'
# Legacy Documentation Archive

This folder contains old project meta-files before migration to Claude Code Starter framework.

## Migration date: $(date +%Y-%m-%d)

## Archived files:
[file list]

## Do not delete these files!
They may be needed for resolving migration conflicts.

After successful migration (after 1-2 sprints) you can safely delete this folder.
EOF
```

---

### Step 8: Create MIGRATION_REPORT.md

**Task:** Create migration report

**Required header format:**

```markdown
# Migration Report - Stage 1

**Date:** $(date +%Y-%m-%d %H:%M:%S)  ← MUST INCLUDE TIME
**Framework Version:** 1.2.4

---

## 📊 Summary

- **Legacy files found:** [count]
- **Files migrated:** [count]
- **Files archived:** [count]
- **Conflicts detected:** [count] (🔴 X 🟡 Y 🟢 Z)

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

**Action required:** Run `/migrate-resolve` to resolve conflicts

---

## ✅ Next Steps

1. **Review migrated content:**
   - Read PROJECT_INTAKE.md
   - Read ARCHITECTURE.md
   - Read BACKLOG.md

2. **Resolve conflicts (if any):**
   ```
   /migrate-resolve
   ```

3. **Finalize migration:**
   ```
   /migrate-finalize
   ```

4. **OR rollback if needed:**
   ```
   /migrate-rollback
   ```

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
```

**DON'T use:**
- Blockquote `>` for header
- "Status: COMPLETED" in header
- Additional fields in Summary (only 4 main + conflicts breakdown)

**Use exactly this format** as in template above.

---

### Step 9: Create CONFLICTS.md (if conflicts exist)

**Task:** Document all found contradictions

**Create CONFLICTS.md if there are ANY conflicts, including:**
- 🔴 Critical conflicts (MUST resolve)
- 🟡 Medium conflicts (SHOULD resolve)
- 🟢 **Low priority notes** ← INCLUDING notes about typo, naming, etc!

**Creation criteria:** If there is ANYTHING that requires user attention - create CONFLICTS.md.

**Examples of low priority conflicts:**
- Typo in filename (scpec.md → spec.md)
- Outdated comments
- Formatting inconsistencies
- Minor detail duplications

Even if it's not a "conflict" in strict sense - document in CONFLICTS.md for completeness.

**Structure:**

```markdown
# Migration Conflicts

Contradictions found in legacy documentation. Manual resolution required.

---

## Conflict 1: Database Choice (🔴 Critical)

**Location:** PROJECT_INTAKE.md - Tech Stack

**Sources:**
- `spec.md` line 45: "Database: PostgreSQL with Prisma ORM"
- `ARCHITECTURE.md.old` line 12: "Using MongoDB with Mongoose"

**Current state:** [CONFLICT]

**Options:**
1. Use PostgreSQL (spec.md)
2. Use MongoDB (ARCHITECTURE.md)
3. Specify different choice

**Resolution:** [FILL IN]

---

## Conflict 2: Filename Typo (🟢 Low Priority)

**Issue:** Legacy file named `scpec.md` (typo - should be `spec.md`)

**Location:** archive/legacy-docs/scpec.md

**Impact:** None (file already archived)

**Options:**
1. Leave as-is in archive (recommended)
2. Rename to spec.md in archive
3. Ignore

**Resolution:** [FILL IN]

---

[... more conflicts]

---

## How to Resolve

1. For each conflict, choose one option or specify custom resolution
2. Update the corresponding Init/ file with chosen resolution
3. Run `/migrate-resolve` to mark conflicts as resolved
4. Run `/migrate-finalize` to complete migration
```

---

## 🎯 Execution

**This command performs the following actions:**

1. **Scanning:**
   - Use `find` and `Glob` to find all meta-files
   - Use `Read` to read contents

2. **Analysis:**
   - Use `Grep` to search for key sections
   - Analyze structure and contents
   - Identify duplicates and contradictions

3. **Transfer:**
   - Use `Read` for legacy files
   - Use `Edit` to update Init/ files (ONE Edit per file!)
   - Add markers `<!-- MIGRATED FROM: filename.md -->`

4. **Archiving:**
   - Use `Bash` to create archive/ structure
   - Create BOTH folders: legacy-docs/ and backup-YYYYMMDD/
   - Move legacy files with `mv`
   - Copy to backup with `cp -r`
   - Create archive/README.md

5. **Reporting:**
   - Use `Write` to create MIGRATION_REPORT.md (exact format!)
   - Use `Write` to create CONFLICTS.md (if needed)

---

## ⏸️ Stop for Review

**After completing ALL steps, show ONLY this message:**

```
⏸️ MIGRATION STAGE 1 COMPLETED - PAUSED FOR REVIEW

📊 Results:
- Legacy files found: [count]
- Migrated to Init/: [count]
- Archived to archive/legacy-docs/: [count]
- Conflicts detected: [count] (🔴 X 🟡 Y 🟢 Z)

📋 NEXT ACTIONS:

1. **Read report:**
   cat MIGRATION_REPORT.md

2. **Resolve conflicts** (if any):
   /migrate-resolve

3. **Finalize migration:**
   /migrate-finalize

4. **Rollback** (if needed):
   /migrate-rollback

---

See MIGRATION_REPORT.md for migration details
```

**IMPORTANT:**
- DON'T add commit message examples
- DON'T add improvement recommendations
- DON'T add README creation instructions
- DON'T add token statistics
- DON'T add additional advice
- **ONLY 4 actions above + report link**

User can ask questions after reading report.

---

## 🚨 Safety

- ✅ All legacy files saved in `archive/legacy-docs/`
- ✅ Timestamped backup created in `archive/backup-YYYYMMDD/`
- ✅ Can rollback via `/migrate-rollback`
- ✅ Git commit created only in `/migrate-finalize`

---

**Ready to start migration? Give the command and I'll begin Stage 1!**
