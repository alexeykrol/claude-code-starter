---
description: Rollback migration to Claude Code Starter framework
---

# Project Migration Rollback

> Use this command to rollback migration at any stage

## ⚠️ IMPORTANT

This command rollbacks the migration and restores legacy files.
Use with caution!

**Supported scenarios:**
1. Rollback after `/migrate` (before finalization)
2. Rollback after `/migrate-finalize` (after finalization)

---

## 📋 Rollback Process

### Step 1: Determine migration status

Check what exists:

```bash
# Check migration files
ls -la MIGRATION_REPORT.md 2>/dev/null
ls -la CONFLICTS.md 2>/dev/null
ls -la archive/ 2>/dev/null

# Check git log for migration commit
git log -1 --grep="migrate" --oneline 2>/dev/null
```

**Determine status:**

**Status A: After /migrate (before finalization)**
- ✅ MIGRATION_REPORT.md exists (in root)
- ✅ archive/ exists
- ✅ Init/ is updated
- ❌ No migration commit in git

**Status B: After /migrate-finalize**
- ✅ archive/MIGRATION_REPORT.md (in archive, not in root)
- ✅ archive/ exists
- ✅ Init/ is updated
- ✅ Migration commit in git log
- ✅ CLAUDE.md contains migration notice

### Step 2: User warning

Show current status and ask for confirmation:

```
⚠️ MIGRATION ROLLBACK

Current status: [Status A or B]

What will be done:
- Restore legacy files from archive/
- Remove Init/ files (or restore to pre-migration state)
- Remove migration reports
[- Revert git commit (if Status B)]

⚠️ ALL CHANGES IN Init/ FILES AFTER MIGRATION WILL BE LOST!

Are you sure? (yes/no)
```

If answer is not "yes" - stop execution.

### Step 3: Save backup (optional)

```bash
# Create backup of current Init/ state
mkdir -p .rollback_backup
cp -r Init/ .rollback_backup/Init_$(date +%Y%m%d_%H%M%S)

echo "Backup created in .rollback_backup/"
```

### Step 4: Rollback depending on status

#### For Status A (before finalization):

```bash
# 1. Restore legacy files from archive/
if [ -d "archive/docs" ]; then
  mkdir -p docs
  cp -r archive/docs/* docs/ 2>/dev/null || true
fi

if [ -d "archive/notes" ]; then
  mkdir -p notes
  cp -r archive/notes/* notes/ 2>/dev/null || true
fi

if [ -d "archive/other" ]; then
  cp -r archive/other/* . 2>/dev/null || true
fi

# 2. Restore root legacy files
for file in archive/*.md; do
  if [ -f "$file" ] && [ "$(basename $file)" != "README.md" ]; then
    cp "$file" .
  fi
done

# 3. Remove Init/ (if this was a new project)
# OR restore original Init/ files (if they existed)
read -p "Remove Init/ completely? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf Init/
else
  echo "Init/ left as is"
fi

# 4. Remove migration files
rm -f MIGRATION_REPORT.md
rm -f CONFLICTS.md

# 5. Remove archive/
read -p "Remove archive/? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf archive/
else
  echo "archive/ left for reference"
fi

echo "✅ Rollback completed (Status A)"
```

#### For Status B (after finalization):

```bash
# 1. Find migration commit
MIGRATION_COMMIT=$(git log --grep="Finalize migration" --format="%H" -1)

if [ -z "$MIGRATION_COMMIT" ]; then
  echo "⚠️ Migration commit not found"
  echo "Try manual rollback"
  exit 1
fi

echo "Found migration commit: $MIGRATION_COMMIT"

# 2. Check that commit can be reverted
git show $MIGRATION_COMMIT --stat

read -p "Revert this commit? (yes/no) " -r
if [ "$REPLY" != "yes" ]; then
  echo "Rollback cancelled"
  exit 0
fi

# 3. Create new commit that reverts the migration
# (use revert, not reset, to preserve history)
git revert $MIGRATION_COMMIT --no-edit -m 1

# 4. Restore legacy files from archive/
# (they should be in git after revert)
if [ -d "archive/docs" ]; then
  mkdir -p docs
  cp -r archive/docs/* docs/ 2>/dev/null || true
fi

if [ -d "archive/notes" ]; then
  mkdir -p notes
  cp -r archive/notes/* notes/ 2>/dev/null || true
fi

if [ -d "archive/other" ]; then
  cp -r archive/other/* . 2>/dev/null || true
fi

# 5. Remove Init/ or restore
read -p "Remove Init/ completely? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf Init/
  git add -A
else
  # Restore original Init/ files before migration
  git show $MIGRATION_COMMIT^:Init/ > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    git checkout $MIGRATION_COMMIT^ -- Init/
    echo "Init/ restored to pre-migration state"
  fi
fi

# 6. Create rollback commit
git add -A
git commit -m "$(cat <<'EOF'
chore: Rollback migration to Claude Code Starter framework

Reverted migration due to [REASON - fill in].

Restored:
- Legacy files from archive/
- Project to pre-migration state

Original migration commit: $MIGRATION_COMMIT

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "✅ Rollback completed (Status B) with git commit"
```

### Step 5: Verify result

```bash
# Show current state
git status

# Show structure
ls -la

echo ""
echo "📊 Rollback result:"
echo ""
echo "Legacy files:"
find . -maxdepth 2 -name "*.md" -not -path "./Init/*" | head -10

echo ""
echo "Init/:"
ls -la Init/ 2>/dev/null || echo "Init/ removed"

echo ""
echo "Git status:"
git log -3 --oneline
```

### Step 6: Final output

```
🎉 MIGRATION ROLLBACK COMPLETED!

✅ What was done:
- Restored legacy files from archive/
- [Init/ removed / Init/ restored to pre-migration]
- [Git commit reverted (Status B)]
- Backup created in .rollback_backup/

📁 Current structure:
[show tree or ls]

⚠️ What's next:

1. **Check restored files**
   - Make sure everything is in place
   - Verify contents

2. **If you need Init/ back**
   - Can copy from .rollback_backup/
   - Or run /migrate again

3. **Delete .rollback_backup/**
   - When you're sure everything is okay:
   ```bash
   rm -rf .rollback_backup/
   ```

4. **archive/ directory**
   - [Left for reference / Removed]
   - Can delete manually if not needed

💡 If you want to try migration again:
```bash
/migrate
```

---

Migration successfully rolled back. Project returned to legacy state.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## 🔐 Security

Before rollback, check:

### Data
- [ ] Backup created
- [ ] archive/ exists and contains legacy files
- [ ] No critical changes in Init/ that need to be saved

### Git
- [ ] All changes committed (if need to preserve them)
- [ ] Checked list of commits that will be reverted
- [ ] Consequences of revert are understood

### Project
- [ ] Team knows about rollback
- [ ] Nobody is working with Init/ files in parallel

---

## 🚫 Stop Conditions

Stop rollback if:

### Critical conditions:
- ❌ archive/ doesn't exist or is empty
- ❌ archive/ doesn't contain legacy files
- ❌ Git has uncommitted changes that will be lost
- ❌ Migration commit has dependent commits on top

### Warnings (ask user):
- ⚠️ Init/ has changes after migration
- ⚠️ archive/ looks incomplete
- ⚠️ Migration commit is older than 1 day

**In case of stop:**
```
🛑 Rollback stopped

Reason: [DESCRIPTION]

Actions:
1. [Action 1]
2. [Action 2]
3. Try /migrate-rollback again

Or perform rollback manually:
- Restore files from archive/
- Remove Init/ (or restore to pre-migration)
- Revert git commit: git revert [commit-hash]
```

---

## 💡 Manual rollback

If command doesn't work, do it manually:

### For Status A (before finalization):

```bash
# 1. Restore legacy
cp -r archive/docs/* docs/
cp -r archive/notes/* notes/
cp archive/other/* .

# 2. Remove Init/
rm -rf Init/

# 3. Remove reports
rm -f MIGRATION_REPORT.md CONFLICTS.md

# 4. Remove archive/
rm -rf archive/
```

### For Status B (after finalization):

```bash
# 1. Find commit
git log --grep="Finalize migration" --oneline

# 2. Revert
git revert [commit-hash] -m 1

# 3. Restore legacy
cp -r archive/docs/* docs/
cp -r archive/notes/* notes/
cp archive/other/* .

# 4. Remove Init/
rm -rf Init/

# 5. Commit
git add -A
git commit -m "chore: Rollback migration"
```

---

## 📝 After Rollback

### Understand why you rolled back

Document the reason:
- What went wrong?
- What conflicts couldn't be resolved?
- What didn't you like about the new structure?

### Decide whether to continue or not

**If you want to try again:**
1. Fix problems in legacy before migration
2. Prepare better (fill in more information)
3. Run `/migrate` again

**If you stay with legacy:**
1. Continue working as before
2. Perhaps the framework doesn't fit your project
3. That's okay - not all projects need structuring

---

## 🔍 Troubleshooting

### Problem: "archive/ not found"

**Cause:** archive/ was deleted or moved

**Solution:**
```bash
# Check git history
git log --all --full-history -- archive/

# Restore from git
git checkout [commit] -- archive/
```

### Problem: "Can't revert git commit"

**Cause:** There are conflicts or dependent commits

**Solution:**
```bash
# Use reset instead of revert (dangerous!)
git reset --hard [commit-before-migration]

# Or rollback manually without git
# and create new commit with fixes
```

### Problem: "Init/ contains important changes"

**Cause:** Changes were made after migration

**Solution:**
```bash
# Save changes before rollback
cp -r Init/ ../Init_backup_$(date +%Y%m%d)

# Then perform rollback

# After rollback you can selectively restore
```

---

**Rollback is not a failure. It's a safe way to go back if something didn't fit.**

🤖 Generated with [Claude Code](https://claude.com/claude-code)
