---
description: Finalize migration to Claude Code Starter framework
---

# Finalize Project Migration

> Use this command to complete migration after reviewing and resolving all conflicts

## ⚠️ IMPORTANT

This command performs **Stage 2** (finalization).
Before running, ensure:
- ✅ Read MIGRATION_REPORT.md
- ✅ Resolved all critical conflicts from CONFLICTS.md
- ✅ Checked all init_eng/ files for completeness
- ✅ Filled sections marked [NEEDS FILLING]

---

## 📋 Finalization Process (Stage 2)

### Step 1: Pre-checks

Before finalization, verify:

```bash
# Check required files exist
ls -la MIGRATION_REPORT.md
ls -la archive/

# Check init_eng/ files
ls -la init_eng/
```

**Required conditions:**
- [ ] MIGRATION_REPORT.md exists
- [ ] archive/ created and contains legacy files
- [ ] init_eng/ files filled
- [ ] Conflicts resolved (CONFLICTS.md deleted or empty)

### Step 2: Check Critical Files

Read and verify:

#### SECURITY.md
- [ ] Doesn't contain [CRITICAL: NEEDS FILLING]
- [ ] All sections filled
- [ ] Security practices documented

**If SECURITY.md not filled:**
```
🔴 CRITICAL ERROR:
SECURITY.md must be fully filled before finalization.
This is not optional!

Actions:
1. Fill all SECURITY.md sections
2. Run /security for audit
3. Return to /migrate-finalize
```

#### PROJECT_INTAKE.md
- [ ] Problem/Solution/Value filled
- [ ] User Personas created (minimum 1)
- [ ] User Flows described
- [ ] Features listed
- [ ] Modular Structure planned

**If critical sections not filled:**
```
⚠️ WARNING:
PROJECT_INTAKE.md contains unfilled critical sections.
Recommended to fill before finalization.

Continue? (y/n)
```

#### ARCHITECTURE.md
- [ ] Tech Stack current
- [ ] Folder Structure reflects reality
- [ ] Module Architecture planned
- [ ] Key Decisions documented

#### BACKLOG.md
- [ ] Task statuses current
- [ ] Priorities set

### Step 3: Check Conflicts

```bash
# Check if CONFLICTS.md exists
if [ -f "CONFLICTS.md" ]; then
  echo "⚠️ CONFLICTS.md still exists"
  echo "Read it and ensure all conflicts resolved"
fi
```

**If CONFLICTS.md exists:**
1. Read file
2. Verify all critical (🔴) conflicts resolved
3. Ask user: "All conflicts resolved? (y/n)"
4. If yes - continue
5. If no - stop and ask to resolve

### Step 4: Finalize Documents

#### Move MIGRATION_REPORT.md to archive/

```bash
# Add final section to MIGRATION_REPORT.md
cat >> MIGRATION_REPORT.md << 'EOF'

---

## ✅ Migration Finalized

**Date:** [DATE]
**Status:** COMPLETE

### Final Actions:
- All conflicts resolved
- All critical sections filled
- init_eng/ declared as single source of truth
- MIGRATION_REPORT.md archived

### Verification:
- [x] SECURITY.md complete
- [x] PROJECT_INTAKE.md complete
- [x] ARCHITECTURE.md complete
- [x] BACKLOG.md current
- [x] All conflicts resolved

Migration to Claude Code Starter framework v1.0 successfully completed.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF

# Move to archive
mv MIGRATION_REPORT.md archive/
```

#### Delete CONFLICTS.md (if exists and resolved)

```bash
if [ -f "CONFLICTS.md" ]; then
  mv CONFLICTS.md archive/CONFLICTS_RESOLVED.md
fi
```

### Step 5: Update CLAUDE.md

Add migration section at the beginning of CLAUDE.md:

```markdown
---

## 📝 Migration Notice

> This project was migrated to Claude Code Starter framework v1.0 on [DATE]

**Archive location:** `archive/`
**Migration report:** `archive/MIGRATION_REPORT.md`
**Framework version:** v1.0

**Single source of truth is now init_eng/ folder.**
Legacy documentation archived for reference only.

---
```

### Step 6: Update BACKLOG.md

Add at the beginning of BACKLOG.md:

```markdown
## 🎯 Recent Updates

### [DATE] - Migrated to Claude Code Starter v1.0
**Status:** ✅ Complete
**Description:** Successfully migrated legacy documentation to structured framework
**Details:**
- All legacy files archived to `archive/`
- Documentation restructured to init_eng/ framework
- Single source of truth established
- See `archive/MIGRATION_REPORT.md` for full report

---
```

### Step 7: Create Git Commit

```bash
# Check status
git status

# Add init_eng/ files
git add init_eng/

# Add archive/
git add archive/

# Add deleted legacy files (if were in git)
git add -A

# Create commit
git commit -m "$(cat <<'EOF'
chore: Finalize migration to Claude Code Starter framework v1.0

Successfully migrated legacy documentation to structured framework.

Changes:
- All legacy meta-files archived to archive/
- Documentation restructured into init_eng/ framework
- SECURITY.md, PROJECT_INTAKE.md, ARCHITECTURE.md updated
- BACKLOG.md updated with current status
- Single source of truth established

Migration report: archive/MIGRATION_REPORT.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# Show result
git log -1 --stat
```

### Step 8: Final Output

After completion, output:

```
🎉 MIGRATION COMPLETED SUCCESSFULLY!

✅ Finalization complete:
- ✅ MIGRATION_REPORT.md archived
- ✅ CONFLICTS.md processed (if existed)
- ✅ CLAUDE.md updated with migration notice
- ✅ BACKLOG.md updated
- ✅ Git commit created

📂 Project Structure:

project/
├── init_eng/                # ✅ SINGLE SOURCE OF TRUTH
│   ├── CLAUDE.md           (updated)
│   ├── PROJECT_INTAKE.md   (migrated)
│   ├── SECURITY.md         (migrated)
│   ├── ARCHITECTURE.md     (migrated)
│   ├── BACKLOG.md          (updated)
│   └── ...
├── archive/                 # Historical files
│   ├── README.md
│   ├── MIGRATION_REPORT.md
│   └── legacy files...
└── src/                     # Code unchanged

🎯 What's Next:

1. **Read updated CLAUDE.md**
   - It's now your main guide
   - Contains migration notice

2. **Use init_eng/ as single source of truth**
   - PROJECT_INTAKE.md - for requirements
   - ARCHITECTURE.md - for architecture
   - BACKLOG.md - for task status
   - SECURITY.md - for security

3. **archive/ for reference only**
   - DON'T update files in archive/
   - Refer to only when necessary

4. **Update documentation with changes**
   - After each sprint update BACKLOG.md
   - With architectural changes update ARCHITECTURE.md
   - With new patterns update AGENTS.md

5. **Use slash commands**
   - /commit - for commits
   - /pr - for Pull Requests
   - /security - for security audits
   - /feature - for new features
   - /db-migrate - for database migrations

📚 Useful Commands:

# View migration report
cat archive/MIGRATION_REPORT.md

# Check init_eng/ structure
ls -la init_eng/

# Start working with framework
claude

💡 Recommendations:

1. **Introduce team to new structure**
   - Show where to find information now
   - Explain that init_eng/ is single source of truth

2. **Update CI/CD if needed**
   - If CI/CD referenced old files - update paths

3. **Review documentation**
   - In a week check everyone uses new structure
   - Supplement documentation as needed

---

Migration to Claude Code Starter framework v1.0 complete!
Your project now uses structured meta-documentation.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## 🔐 Final Checks

Before completion, ensure:

### Structure
- [ ] init_eng/ contains all required files
- [ ] archive/ contains all legacy files
- [ ] archive/README.md created
- [ ] archive/MIGRATION_REPORT.md exists

### Documentation
- [ ] CLAUDE.md contains migration notice
- [ ] BACKLOG.md updated
- [ ] SECURITY.md fully filled
- [ ] PROJECT_INTAKE.md filled

### Git
- [ ] Commit created
- [ ] All changes included in commit
- [ ] Commit message descriptive

---

## 🚫 Stop Conditions

Stop finalization if:

### Critical conditions:
- ❌ SECURITY.md not filled
- ❌ MIGRATION_REPORT.md doesn't exist
- ❌ archive/ not created
- ❌ init_eng/ files not filled

### Warnings (ask user):
- ⚠️ CONFLICTS.md exists
- ⚠️ PROJECT_INTAKE.md contains many [NEEDS FILLING]
- ⚠️ ARCHITECTURE.md incomplete

**In case of stop:**
```
🛑 Finalization stopped

Reason: [DESCRIPTION]

Actions to continue:
1. [Action 1]
2. [Action 2]
3. Run /migrate-finalize again
```

---

## 💡 Rollback (if something goes wrong)

If error occurs during finalization:

```bash
# Rollback last commit (if created)
git reset --soft HEAD~1

# Restore MIGRATION_REPORT.md
mv archive/MIGRATION_REPORT.md ./ 2>/dev/null || true

# Restore CONFLICTS.md
mv archive/CONFLICTS_RESOLVED.md ./CONFLICTS.md 2>/dev/null || true

echo "Rollback complete. Fix issues and run /migrate-finalize again"
```

---

## 📝 Post-Migration Checklist

After successful finalization:

### Immediate
- [ ] Read CLAUDE.md
- [ ] Verify all files in init_eng/ are current
- [ ] Ensure team knows about new structure

### Week 1
- [ ] Update BACKLOG.md after first sprint
- [ ] Supplement AGENTS.md with new patterns
- [ ] Verify everyone uses init_eng/ as source of truth

### Week 2-4
- [ ] Review documentation - everything current?
- [ ] Supplement ARCHITECTURE.md if there were changes
- [ ] Update project README.md if needed

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
