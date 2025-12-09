# Framework Upgrade Protocol

**Purpose:** Migrate project from old Framework version (v1.x or v2.0) to current version (v2.1+).

**When to use:** Project already has `.claude/` directory with older Framework structure.

---

## Core Principles

1. 💾 **Preserve ALL existing data** - never lose user's work
2. 🔄 **Incremental migration** - step by step with verification
3. 📋 **Show migration plan** before executing
4. 🎓 **Explain changes** in simple terms
5. ✅ **Backup first** - create safety backup before changes

---

## Step 1: Detect Old Framework Version

### 1.1 Check Framework Markers

```bash
# Check for v2.x markers
if [ -f ".claude/SNAPSHOT.md" ]; then
  grep "Framework:" .claude/SNAPSHOT.md | awk '{print $2}'
fi

# Check for v1.x markers (old structure)
if [ -f "Init/PROJECT_SNAPSHOT.md" ]; then
  echo "v1.x (legacy structure)"
fi

# Check BACKLOG structure
if [ -f ".claude/BACKLOG.md" ]; then
  # v2.0 if no ROADMAP.md
  if [ ! -f ".claude/ROADMAP.md" ]; then
    echo "v2.0 (missing ROADMAP/IDEAS)"
  fi
fi
```

### 1.2 Report Detected Version

Show user what was detected:

````
🔍 Framework Version Detection

Found: Framework v[VERSION]

Structure detected:
[v1.x]
  ✅ Init/PROJECT_SNAPSHOT.md
  ✅ Init/BACKLOG.md
  ✅ Init/ARCHITECTURE.md
  ❌ .claude/ (missing)

[v2.0]
  ✅ .claude/SNAPSHOT.md
  ✅ .claude/BACKLOG.md
  ✅ .claude/ARCHITECTURE.md
  ❌ ROADMAP.md (missing)
  ❌ IDEAS.md (missing)

[v2.1+] TARGET
  ✅ .claude/SNAPSHOT.md
  ✅ .claude/BACKLOG.md
  ✅ .claude/ROADMAP.md (new)
  ✅ .claude/IDEAS.md (new)
  ✅ .claude/ARCHITECTURE.md

Migration required: [VERSION] → v2.1
````

---

## Step 2: Read Existing Files

Read all existing Framework files to preserve data.

### 2.1 For v1.x Projects

```bash
# Old structure
cat Init/PROJECT_SNAPSHOT.md
cat Init/BACKLOG.md
cat Init/ARCHITECTURE.md
cat Init/CHANGELOG.md 2>/dev/null
cat Init/docs/MIGRATION_GUIDE.md 2>/dev/null

# Check for migration/ folder
ls -la migration/ 2>/dev/null
```

### 2.2 For v2.0 Projects

```bash
# Current structure
cat .claude/SNAPSHOT.md
cat .claude/BACKLOG.md
cat .claude/ARCHITECTURE.md

# Check what's missing
[ -f ".claude/ROADMAP.md" ] || echo "ROADMAP.md missing"
[ -f ".claude/IDEAS.md" ] || echo "IDEAS.md missing"
```

### 2.3 Extract Key Information

From read files, extract:
- **Current version** (from SNAPSHOT)
- **Active tasks** (from BACKLOG)
- **Project structure** (from ARCHITECTURE)
- **Development phase** (from SNAPSHOT)
- **Recent achievements** (from SNAPSHOT)

---

## Step 3: Create Migration Plan

Based on detected version, create detailed migration plan.

### Migration: v1.x → v2.1

````markdown
# 📋 Migration Plan: v1.x → v2.1

## Overview
Upgrade from legacy Init/ structure to modern .claude/ structure.

## Changes Required:

### 1. File Relocations
```
Init/PROJECT_SNAPSHOT.md  →  .claude/SNAPSHOT.md
Init/BACKLOG.md           →  .claude/BACKLOG.md
Init/ARCHITECTURE.md      →  .claude/ARCHITECTURE.md
Init/                     →  [archived]
```

### 2. New Files to Create
```
.claude/ROADMAP.md   (NEW) - Strategic planning
.claude/IDEAS.md     (NEW) - Spontaneous ideas
```

### 3. BACKLOG.md Restructure
**Current format:**
```markdown
## Tasks
- [ ] Task 1
- [ ] Task 2
```

**New format (3-level):**
```markdown
## Phase X: [Current Sprint]
- [ ] Task 1
  - [ ] Subtask

Priority 1 moved to → ROADMAP.md
Ideas moved to → IDEAS.md
```

### 4. SNAPSHOT.md Updates
**Add new sections:**
- Link to ROADMAP.md
- Link to IDEAS.md
- Framework version marker

### 5. migration/ Folder
```
Keep migration/ folder (contains templates)
Add init-project.sh if missing
```

## What Will NOT Change:
✅ All your task data preserved
✅ All your architecture notes preserved
✅ All your project information preserved
✅ Git history untouched
✅ Code untouched

## Backup Strategy:
Before making changes:
```bash
cp -r Init/ Init-backup-$(date +%Y%m%d)
cp -r .claude/ .claude-backup-$(date +%Y%m%d) 2>/dev/null
```

## Estimated Time: 2-3 minutes
## Estimated Tokens: ~5k tokens
````

### Migration: v2.0 → v2.1

````markdown
# 📋 Migration Plan: v2.0 → v2.1

## Overview
Add new 3-level planning structure (IDEAS → ROADMAP → BACKLOG).

## Changes Required:

### 1. Extract from Current BACKLOG

Analyze current `.claude/BACKLOG.md`:
- **Concrete tasks** → stay in BACKLOG.md
- **Priority 1 ideas** → move to ROADMAP.md
- **Unstructured ideas** → move to IDEAS.md

### 2. Create New Files
```
.claude/ROADMAP.md (NEW)
  - Extract from BACKLOG Priority 1
  - Extract from README roadmap section if exists
  - Organize by versions (v2.2, v2.3, v3.0)

.claude/IDEAS.md (NEW)
  - Create empty template
  - Optionally extract "good to have" from BACKLOG
```

### 3. Restructure BACKLOG.md

**Current:**
```markdown
## Phase X
- tasks

## Priority 1
- ideas
```

**New:**
```markdown
## Phase X
- only concrete tasks

[Priority 1 moved to ROADMAP.md]
```

### 4. Update SNAPSHOT.md

Add references:
```markdown
> **Planning:**
> - Current tasks: [BACKLOG.md](./BACKLOG.md)
> - Strategic plan: [ROADMAP.md](./ROADMAP.md)
> - Ideas: [IDEAS.md](./IDEAS.md)
```

### 5. Update README.md

Replace full roadmap with link:
```markdown
## Roadmap
See [.claude/ROADMAP.md](.claude/ROADMAP.md)
```

## What Will NOT Change:
✅ All your tasks preserved
✅ All your ideas preserved (just reorganized)
✅ SNAPSHOT content intact
✅ ARCHITECTURE content intact

## Backup Strategy:
```bash
cp .claude/BACKLOG.md .claude/BACKLOG-backup-$(date +%Y%m%d).md
```

## Estimated Time: 1-2 minutes
## Estimated Tokens: ~3k tokens
````

Show migration plan to user and ask:

```
✅ Migration plan ready

This upgrade will:
1. [List key changes]
2. [List key changes]
3. [List key changes]

All existing data will be preserved.
Backup will be created before changes.

Proceed with migration? (y/N)
```

---

## Step 4: Execute Migration

Use TodoWrite to track migration progress.

### For v1.x → v2.1:

```markdown
Create todos:
- [ ] Create backup of Init/ folder
- [ ] Create .claude/ directory structure
- [ ] Migrate SNAPSHOT.md (Init/ → .claude/)
- [ ] Migrate BACKLOG.md with restructuring
- [ ] Migrate ARCHITECTURE.md
- [ ] Create ROADMAP.md (extract from BACKLOG)
- [ ] Create IDEAS.md (empty template)
- [ ] Update CLAUDE.md (if needed)
- [ ] Verify migration completed
- [ ] Archive Init/ folder
```

### For v2.0 → v2.1:

```markdown
Create todos:
- [ ] Create backup of BACKLOG.md
- [ ] Analyze current BACKLOG structure
- [ ] Extract Priority 1 items for ROADMAP
- [ ] Create ROADMAP.md
- [ ] Create IDEAS.md
- [ ] Restructure BACKLOG.md (remove Priority 1)
- [ ] Update SNAPSHOT.md (add links)
- [ ] Update README.md (roadmap → link)
- [ ] Verify migration completed
```

---

## Step 5: Migration Execution Details

### 5.1 Create Backup

```bash
# For v1.x
BACKUP_DIR="Init-backup-$(date +%Y%m%d-%H%M%S)"
cp -r Init/ "$BACKUP_DIR"
echo "Backup created: $BACKUP_DIR"

# For v2.0
cp .claude/BACKLOG.md ".claude/BACKLOG-backup-$(date +%Y%m%d-%H%M%S).md"
```

### 5.2 Migrate SNAPSHOT.md (v1.x only)

```bash
# Read old file
OLD_CONTENT=$(cat Init/PROJECT_SNAPSHOT.md)

# Add Framework version marker
NEW_CONTENT="# SNAPSHOT — [Project Name]

*Framework: Claude Code Starter v2.1*
*Last Updated: $(date +%Y-%m-%d)*

$OLD_CONTENT
"

# Write to new location
echo "$NEW_CONTENT" > .claude/SNAPSHOT.md
```

### 5.3 Extract and Create ROADMAP.md

**For v1.x:** Analyze BACKLOG.md, extract future plans

**For v2.0:** Extract Priority 1 section from BACKLOG.md

Use Read tool to read current BACKLOG, then use pattern matching:

```markdown
Find sections like:
- ## Priority 1
- ## Future
- ## v3.0
- ## Ideas

Extract these → ROADMAP.md
Organize by versions (v2.2, v2.3, v3.0)
```

### 5.4 Create IDEAS.md

Use Write tool to create empty template:

```markdown
# IDEAS — [Project Name]

*Last Updated: $(date +%Y-%m-%d)*

> 💡 Spontaneous ideas and thoughts
>
> **Workflow:** IDEAS.md → ROADMAP.md → BACKLOG.md

## 💭 Unstructured Ideas

- ...

## 🤔 Ideas on Review

- ...

## ❌ Rejected Ideas

- ...
```

### 5.5 Restructure BACKLOG.md

For v2.0 → v2.1:
1. Read current BACKLOG.md
2. Extract Priority 1 section
3. Remove Priority 1 from BACKLOG
4. Update header to reference ROADMAP/IDEAS
5. Write updated BACKLOG.md

### 5.6 Update SNAPSHOT.md

Add planning references:

```markdown
> **Planning Documents:**
> - 🎯 Current tasks: [BACKLOG.md](./BACKLOG.md)
> - 🗺️ Strategic roadmap: [ROADMAP.md](./ROADMAP.md)
> - 💡 Ideas: [IDEAS.md](./IDEAS.md)
> - 📊 Architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)
```

### 5.7 Archive Old Structure (v1.x only)

```bash
# Move Init/ to archive
mkdir -p .archive
mv Init/ .archive/Init-v1-archived-$(date +%Y%m%d)/

echo "Old Init/ folder archived to .archive/"
echo "You can safely delete .archive/ later if migration successful"
```

---

## Step 6: Verification

Verify migration completed successfully:

```bash
# Check all new files exist
echo "Checking new structure..."

[ -f ".claude/SNAPSHOT.md" ] && echo "✅ SNAPSHOT.md" || echo "❌ SNAPSHOT.md MISSING"
[ -f ".claude/BACKLOG.md" ] && echo "✅ BACKLOG.md" || echo "❌ BACKLOG.md MISSING"
[ -f ".claude/ROADMAP.md" ] && echo "✅ ROADMAP.md" || echo "❌ ROADMAP.md MISSING"
[ -f ".claude/IDEAS.md" ] && echo "✅ IDEAS.md" || echo "❌ IDEAS.md MISSING"
[ -f ".claude/ARCHITECTURE.md" ] && echo "✅ ARCHITECTURE.md" || echo "❌ ARCHITECTURE.md MISSING"

# Check file sizes (should not be empty)
echo ""
echo "File sizes:"
ls -lh .claude/*.md

# Show first few lines of each
echo ""
echo "Quick preview:"
head -3 .claude/SNAPSHOT.md
head -3 .claude/BACKLOG.md
head -3 .claude/ROADMAP.md
```

---

## Step 7: Migration Summary

Show comprehensive completion report:

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Framework Upgrade Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Migration Summary:

  From: Framework v[OLD_VERSION]
  To:   Framework v2.1.1

  Duration: [time elapsed]
  Token Usage: ~[count]k tokens

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Files Migrated:

  [For v1.x → v2.1]
  ✅ Init/PROJECT_SNAPSHOT.md → .claude/SNAPSHOT.md
  ✅ Init/BACKLOG.md → .claude/BACKLOG.md (restructured)
  ✅ Init/ARCHITECTURE.md → .claude/ARCHITECTURE.md
  ✨ Created .claude/ROADMAP.md (extracted from BACKLOG)
  ✨ Created .claude/IDEAS.md (new template)

  [For v2.0 → v2.1]
  ✅ .claude/BACKLOG.md (restructured)
  ✨ Created .claude/ROADMAP.md (extracted Priority 1)
  ✨ Created .claude/IDEAS.md (new template)
  ✅ Updated .claude/SNAPSHOT.md (added links)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 New 3-Level Planning Structure:

  Level 1: IDEAS.md
    • Spontaneous, unstructured ideas
    • "Good to have" thoughts
    • ❌ NOT read during Cold Start

  Level 2: ROADMAP.md
    • Structured features (v2.2, v2.3, v3.0)
    • Strategic planning
    • ✅ READ during Cold Start

  Level 3: BACKLOG.md
    • Concrete tasks (current sprint)
    • Agreed work items
    • ✅ READ during Cold Start

  Workflow: IDEAS → ROADMAP → BACKLOG → Done

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💾 Backups Created:

  [For v1.x]
  ✅ Init-backup-[timestamp]/
  ✅ Init/ archived to .archive/

  [For v2.0]
  ✅ .claude/BACKLOG-backup-[timestamp].md

  Backups can be deleted after verifying migration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Data Integrity:

  ✅ All tasks preserved
  ✅ All ideas preserved (reorganized)
  ✅ All architecture notes intact
  ✅ All project info intact
  ✅ Git history untouched
  ✅ Code untouched

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 What Changed:

  BACKLOG.md:
    • Removed Priority 1 section → moved to ROADMAP.md
    • Now focuses only on current sprint tasks
    • Added workflow documentation at top

  SNAPSHOT.md:
    • Added planning document links
    • Updated Framework version marker

  README.md:
    • Roadmap section replaced with link to .claude/ROADMAP.md

  NEW FILES:
    • ROADMAP.md - strategic planning
    • IDEAS.md - idea collection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Next Steps:

  1. Review migrated files:
     cat .claude/ROADMAP.md
     cat .claude/IDEAS.md

  2. Verify your tasks still there:
     cat .claude/BACKLOG.md

  3. Start working with new structure:
     Type: start

  4. Cold Start will now read ROADMAP.md automatically!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 New Features Available:

  • 3-level idea maturation (IDEAS → ROADMAP → BACKLOG)
  • Strategic planning in ROADMAP.md
  • Cleaner BACKLOG (only current work)
  • Better token economy (IDEAS not loaded)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Framework v2.1 is ready!

Type "start" to begin. 🚀

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````

---

## Error Handling

### If backup fails:

```
❌ Error: Could not create backup

This is unusual. Possible causes:
- Disk full
- Permission issues

Cannot proceed without backup for safety.

Please check:
1. Disk space: df -h
2. Permissions: ls -la Init/

Then try again.
```

### If file migration fails:

```
⚠️ Warning: Migration partially complete

Completed:
✅ Backup created
✅ SNAPSHOT.md migrated
❌ BACKLOG.md migration failed

Error: [error message]

Options:
1. Retry migration from this point
2. Restore from backup and cancel
3. Fix manually (I'll guide you)

Your choice?
```

### If verification fails:

```
⚠️ Warning: Verification found issues

Missing files:
❌ .claude/ROADMAP.md (failed to create)

Present files:
✅ .claude/SNAPSHOT.md
✅ .claude/BACKLOG.md

Backup is safe at: [path]

Options:
1. Retry creating missing files
2. Restore from backup
3. Continue anyway (files can be created manually later)

Your choice?
```

---

## Rollback Procedure

If user wants to rollback migration:

```bash
# For v1.x → v2.1 rollback
echo "Rolling back migration..."

# Restore from backup
rm -rf .claude/
cp -r Init-backup-[timestamp]/ Init/

echo "✅ Rollback complete"
echo "Restored to: Framework v1.x"

# For v2.0 → v2.1 rollback
rm .claude/ROADMAP.md .claude/IDEAS.md
cp .claude/BACKLOG-backup-[timestamp].md .claude/BACKLOG.md

echo "✅ Rollback complete"
echo "Restored to: Framework v2.0"
```

---

## Important Notes

- **Always create backup before changes**
- **Preserve all existing data - never lose work**
- **Show migration plan before executing**
- **Verify each step completes successfully**
- **Provide clear rollback option if needed**
- **Track progress with TodoWrite**
- **Report token usage**

---

*This protocol ensures safe, reversible Framework upgrades while preserving all user work.*
