---
description: Create Claude Code Starter framework release
---

# Framework Release

> Use this command to create a new framework release with automatic version, CHANGELOG, README and archives updates.

## ⚠️ IMPORTANT

This command is **ONLY for claude-code-starter project**.
Don't use it in user projects!

---

## 🎯 What Command Does

1. **Analyzes changes** since last release
2. **Determines release type** (patch/minor/major)
3. **Updates version** everywhere
4. **Updates CHANGELOG.md** with change descriptions
5. **Updates README files** if needed
6. **Rebuilds zip archives**
7. **Creates release commit**
8. **Pushes to GitHub**

---

## 📋 Release Process

### Step 1: Determine Current Version

```bash
# Read current version from README.md
grep "badge/version" README.md
```

Current version in badge format: `version-1.2.5`

### Step 2: Analyze Changes

```bash
# Get all commits since last release commit
git log --oneline --grep="chore: Bump version" -1
# Get commits after last release
git log <last-release-commit>..HEAD --oneline
```

**Analyze commits:**
- Which files changed?
- New features or bugfixes?
- Breaking changes?
- Changes in templates (Init/, init_eng/)?

### Step 3: Determine Release Type

**Ask user:**

```
🎯 Change analysis since last release:

Commits found: X
Main changes:
- [brief list of changes from git log]

Which release type to create?

1. Patch (1.2.X) - bugfixes, documentation, minor improvements
2. Minor (1.X.0) - new features, backward compatible changes
3. Major (X.0.0) - breaking changes, major refactoring

Choose [1/2/3]:
```

**Versioning Rules (Semantic Versioning):**

- **Patch (X.X.N):**
  - Bug fixes
  - Documentation updates
  - Minor improvements without new features
  - Dependency updates
  
- **Minor (X.N.0):**
  - New features
  - New commands (slash commands)
  - New sections in templates
  - Backward compatible changes
  - Improvements to existing features
  
- **Major (N.0.0):**
  - Breaking changes
  - Deprecated function removal
  - File structure changes
  - Incompatible API changes

### Step 4: Calculate New Version

```bash
# Example: current 1.2.5
# Patch: 1.2.6
# Minor: 1.3.0
# Major: 2.0.0

CURRENT_VERSION="1.2.5"
# Parse into major.minor.patch
# Increment needed part
# Form NEW_VERSION
```

**Confirm with user:**
```
New version: ${NEW_VERSION}
Continue? [y/n]
```

### Step 5: Collect CHANGELOG Info

**For each commit since last release:**

1. Read commit message
2. Determine category:
   - `feat:` → Added
   - `fix:` → Fixed
   - `docs:` → Changed/Documentation
   - `refactor:` → Changed
   - `chore:` → (skip or Maintenance)
3. Extract key changes

**Group by categories:**
- Added (new features)
- Fixed (fixes)
- Changed (changes)
- Removed (removals)
- Deprecated (deprecated)

### Step 6: Create CHANGELOG Section

**Template:**

```markdown
## [${NEW_VERSION}] - $(date +%Y-%m-%d)

### [Brief release description]

**Goal:** [Main goal of this release]

### Added

- [New feature 1]
  - Description
  - Files: Init/file.md, init_eng/file.md
- [New feature 2]

### Fixed

- [Fix 1]
  - Problem: [description]
  - Solution: [description]
- [Fix 2]

### Changed

- [Change 1]
- [Change 2]

### Impact

**For Users:**
- ✅ [Benefit 1]
- ✅ [Benefit 2]

### Files Modified

**Templates:**
- Init/FILE.md (+X lines)
- init_eng/FILE.md (+X lines)

**Documentation:**
- README.md
- README_RU.md

**Archives:**
- init-starter.zip (recreated)
- init-starter-en.zip (recreated)

---
```

**Insert at beginning of CHANGELOG.md** (after header, before last version)

### Step 7: Update Version in README Files

**Files to update:**
1. README.md - badge line
2. README_RU.md - badge line

**Use Edit tool:**

```markdown
OLD:
[![Version](https://img.shields.io/badge/version-${CURRENT_VERSION}-orange.svg)]

NEW:
[![Version](https://img.shields.io/badge/version-${NEW_VERSION}-orange.svg)]
```

### Step 8: Check if README Updates Needed

**Ask user:**

```
Should README descriptions be updated?
(For example, add new feature to "The Solution" list)

[y/n]
```

If yes - suggest specific changes based on CHANGELOG.

### Step 9: Rebuild Zip Archives

```bash
# Rebuild both archives
cd Init && zip -r ../init-starter.zip . -x "*.DS_Store"
cd ../init_eng && zip -r ../init-starter-en.zip . -x "*.DS_Store"
cd ..
ls -lh init-starter*.zip
```

### Step 10: Create Release Commit

**Commit message template:**

```
chore: Release v${NEW_VERSION}

Release v${NEW_VERSION} includes [brief description].

## Highlights:

[2-3 key changes]

## Changes in this commit:

### Version Updates
- README.md: ${CURRENT_VERSION} → ${NEW_VERSION}
- README_RU.md: ${CURRENT_VERSION} → ${NEW_VERSION}

### CHANGELOG.md
Added v${NEW_VERSION} entry documenting:
- [Category 1]: [briefly]
- [Category 2]: [briefly]

### Archives Recreated
- init-starter.zip (updated with all changes)
- init-starter-en.zip (updated with all changes)

[If README changed - describe]

## Impact:

[Key impact metrics]

See CHANGELOG.md for full details.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Create commit:**

```bash
git add CHANGELOG.md README.md README_RU.md init-starter.zip init-starter-en.zip

# If other changes - add them too
git add [other files if needed]

git commit -m "[message from template]"
```

### Step 11: Show Diff for Verification

```bash
git show HEAD --stat
```

**Confirm with user:**
```
Commit created. Check changes above.

Push to GitHub? [y/n]
```

### Step 12: Push to GitHub

```bash
git push origin main
```

### Step 13: Create GitHub Release (optional)

**Ask user:**
```
Create GitHub Release?

This will create:
- Tag v${NEW_VERSION}
- Release page on GitHub
- Attach archives to release

[y/n]
```

**If yes:**

```bash
# Create tag
git tag -a "v${NEW_VERSION}" -m "Release v${NEW_VERSION}"
git push origin "v${NEW_VERSION}"

# Create GitHub Release using gh CLI
gh release create "v${NEW_VERSION}" \
  --title "v${NEW_VERSION}" \
  --notes "[Extract section for this version from CHANGELOG.md]" \
  init-starter.zip \
  init-starter-en.zip
```

### Step 14: Final Output

```
🎉 RELEASE v${NEW_VERSION} CREATED SUCCESSFULLY!

✅ What's done:
- ✅ CHANGELOG.md updated
- ✅ Version in README: ${CURRENT_VERSION} → ${NEW_VERSION}
- ✅ Archives rebuilt
- ✅ Commit created and pushed
[- ✅ GitHub Release created (if done)]

📊 Statistics:
- Commits since last release: X
- Files changed: Y
- Release type: [Patch/Minor/Major]

🔗 Links:
- Commit: https://github.com/alexeykrol/claude-code-starter/commit/[hash]
[- Release: https://github.com/alexeykrol/claude-code-starter/releases/tag/v${NEW_VERSION}]

📋 Next steps:
- Check CHANGELOG.md on GitHub
- Verify version updated in README
- If needed, update release description on GitHub

---

Release v${NEW_VERSION} ready to use! 🚀
```

---

## 🚫 Stop Conditions

Stop release if:

### Critical conditions:
- ❌ No new commits since last release
- ❌ Working directory not clean (uncommitted changes)
- ❌ Not in claude-code-starter folder
- ❌ No push permissions

### Warnings (ask user):
- ⚠️ Very few changes (1-2 trivial commits)
- ⚠️ No tests for new features
- ⚠️ Documentation not updated for new features

**In case of stop:**
```
🛑 Release stopped

Reason: [DESCRIPTION]

Actions to continue:
1. [Action 1]
2. [Action 2]
3. Run /release again
```

---

## 💡 Tips

### Good Release Practices:

1. **Regularity:**
   - Patch releases: as soon as bug fixed
   - Minor releases: every 1-2 weeks for new features
   - Major releases: rarely, only for breaking changes

2. **CHANGELOG Quality:**
   - Write for users, not developers
   - Explain WHY, not just WHAT
   - Include impact examples ("saves 60% tokens")
   - Add migration path for breaking changes

3. **Communication:**
   - Announce in Issues/Discussions for major releases
   - Highlight breaking changes
   - Provide upgrade guide

---

## 🔄 Integration with Other Commands

- After `/feature` → May need minor release
- After `/fix` → May need patch release
- After refactoring → Check if release needed

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
