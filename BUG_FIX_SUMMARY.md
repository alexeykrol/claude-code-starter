# Bug Fix Summary: Framework Version Loop

**Issue:** #framework-version-loop-20260117
**Fixed:** 2026-01-17
**Severity:** High (Blocked normal framework startup)
**Status:** ✅ Resolved

---

## Problem Summary

Framework update check entered infinite loop when GitHub release contained CLAUDE.md file with incorrect version number inside. Users got stuck in update loop across session restarts.

**Root Cause:** GitHub release v2.5.0 contained `CLAUDE.md` with version string `v2.4.3` instead of `v2.5.0`, causing repeated update attempts.

---

## Solutions Implemented

### 1. ✅ Self-Healing Mechanism (Immediate Fix)

**File:** `.claude/protocols/cold-start.md` (Step 0.2)

**What it does:**
- Automatically detects version mismatch in downloaded CLAUDE.md
- Auto-corrects version string to match GitHub release tag
- Prevents version loop from occurring

**Implementation:**
```bash
# After downloading CLAUDE.md from GitHub release
DOWNLOADED_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md.new | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

if [ "$DOWNLOADED_VERSION" != "$LATEST_VERSION" ]; then
  echo "⚠️  Downloaded CLAUDE.md has wrong version (v$DOWNLOADED_VERSION)"
  echo "   Auto-correcting to v$LATEST_VERSION..."

  # Fix version (handles both Darwin/BSD and GNU sed)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/v$DOWNLOADED_VERSION/v$LATEST_VERSION/g" CLAUDE.md.new
  else
    sed -i "s/v$DOWNLOADED_VERSION/v$LATEST_VERSION/g" CLAUDE.md.new
  fi

  echo "   ✓ Version corrected in CLAUDE.md"
fi
```

**Benefits:**
- Protects users from bad releases
- Self-healing, no manual intervention needed
- Works around release process bugs

**Trade-offs:**
- Masks underlying problem (but better UX than infinite loop)
- Silent correction (but logged to user)

---

### 2. ✅ Pre-Release Validation Script (Long-term Fix)

**File:** `migration/validate-release.sh`

**What it does:**
- Validates version consistency across ALL framework files before release
- Checks: CLAUDE.md, protocols, package.json, CHANGELOG.md, git tags
- Prevents bad releases from being created

**Validation Checks:**

| Check | Description | Example |
|-------|-------------|---------|
| CLAUDE.md consistency | All version references match | `v2.5.0` everywhere |
| Protocol versions | cold-start.md, completion.md match | `**Version:** 2.5.0` |
| CHANGELOG entry | Release notes exist | `## [2.5.0] - 2026-01-17` |
| package.json | npm version matches | `"version": "2.5.0"` |
| Git tag | Tag matches expected version | `v2.5.0` |
| Distribution files | All required files present | CLAUDE.md, commands, etc. |

**Smart Features:**
- Excludes historical references (e.g., "NEW in v2.4.1")
- Handles CHANGELOG format without "v" prefix
- Clear error messages with actionable feedback

**Usage:**
```bash
bash migration/validate-release.sh
```

**Output Example:**
```
✅ All validation checks passed for v2.5.0

Ready to release!

Next steps:
  1. Run: bash migration/build-distribution.sh
  2. Create release: gh release create v2.5.0 ...
```

---

### 3. ✅ Version Update Script

**File:** `migration/update-version.sh`

**What it does:**
- Updates version across all framework files in one command
- Ensures consistency before creating release

**Usage:**
```bash
bash migration/update-version.sh 2.5.1
```

**Updates:**
- CLAUDE.md
- .claude/protocols/cold-start.md
- .claude/protocols/completion.md
- migration/build-distribution.sh
- package.json
- migration/CLAUDE.production.md (template)

**Features:**
- OS-aware (handles macOS BSD sed and GNU sed)
- Shows before/after versions
- Validates version format (x.y.z)

---

### 4. ✅ Automated Release Script

**File:** `migration/create-release.sh`

**What it does:**
- Automates entire release process with validation
- Creates GitHub release with correct artifacts

**Workflow:**
1. Extract version from CLAUDE.md
2. **Run validation** (validate-release.sh)
3. Check for uncommitted changes
4. Handle existing tag conflicts
5. Build distribution (build-distribution.sh)
6. Create framework-commands.tar.gz
7. Copy CLAUDE.md to dist/
8. Verify all artifacts present
9. Create and push git tag
10. Create GitHub release with artifacts

**Usage:**
```bash
bash migration/create-release.sh
```

**Safety Features:**
- Pre-release validation (can skip with `--skip-validation`)
- Uncommitted changes warning
- Existing tag conflict resolution
- Artifact verification before release
- Auto-extracts CHANGELOG notes

**Output:**
```
✅ Release v2.5.0 completed successfully!

Release URL: https://github.com/alexeykrol/claude-code-starter/releases/tag/v2.5.0

Distribution artifacts:
  • init-project.sh
  • framework-commands.tar.gz
  • CLAUDE.md
```

---

## Testing Results

### Self-Healing Test

Simulated version mismatch scenario:
```
Downloaded version: v2.4.3
Expected version: v2.5.0

⚠️  Downloaded CLAUDE.md has wrong version (v2.4.3)
   Auto-correcting to v2.5.0...
   ✓ Version corrected in CLAUDE.md

After self-healing: v2.5.0
✅ Self-healing successful! Version loop prevented.
```

### Validation Test

All checks passed:
```
✅ Expected version: v2.5.0
✅ All version references in CLAUDE.md are consistent
✅ cold-start.md version matches: v2.5.0
✅ completion.md version matches: v2.5.0
✅ CHANGELOG.md contains entry for v2.5.0
✅ package.json version matches: v2.5.0
✅ Git tag matches: v2.5.0
✅ All critical distribution files present
```

---

## Files Changed

### Modified Files

1. `.claude/protocols/cold-start.md`
   - Added self-healing in Step 0.2
   - Auto-corrects version mismatches

2. `CLAUDE.md`
   - Updated version to v2.5.0

3. `.claude/protocols/completion.md`
   - Updated version to v2.5.0

4. `package.json`
   - Updated version to 2.5.0

5. `migration/build-distribution.sh`
   - Updated version to v2.5.0

6. `migration/CLAUDE.production.md`
   - Updated version to v2.5.0

### New Files

1. `migration/validate-release.sh` ⭐ NEW
   - Pre-release validation script
   - Prevents version inconsistencies

2. `migration/update-version.sh` ⭐ NEW
   - Bulk version update utility
   - Ensures consistency across files

3. `migration/create-release.sh` ⭐ NEW
   - Automated release workflow
   - Integrates validation + build + release

---

## Impact

### User Experience

**Before Fix:**
- ❌ Users stuck in infinite update loop
- ❌ Required manual CLAUDE.md editing
- ❌ Confusing error messages
- ❌ Session restart didn't help

**After Fix:**
- ✅ Self-healing prevents loop automatically
- ✅ Users see clear message about auto-correction
- ✅ One session restart completes update
- ✅ No manual intervention needed

### Development Process

**Before Fix:**
- ❌ Manual version updates (error-prone)
- ❌ No validation before release
- ❌ Version inconsistencies common
- ❌ Release process fragile

**After Fix:**
- ✅ Automated version updates
- ✅ Validation catches errors early
- ✅ Consistent versions guaranteed
- ✅ Reliable release process

---

## Recommendations for Next Release

### Before Creating Release

1. **Update version:**
   ```bash
   bash migration/update-version.sh 2.5.1
   ```

2. **Update CHANGELOG.md manually:**
   - Add entry: `## [2.5.1] - YYYY-MM-DD`
   - Document changes

3. **Validate:**
   ```bash
   bash migration/validate-release.sh
   ```

4. **Commit changes:**
   ```bash
   git commit -am "chore: Bump version to v2.5.1"
   ```

5. **Create release:**
   ```bash
   bash migration/create-release.sh
   ```

### Optional: CI/CD Integration

Consider adding GitHub Actions workflow:
```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  validate-and-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate version consistency
        run: bash migration/validate-release.sh
      - name: Build distribution
        run: bash migration/build-distribution.sh
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            CLAUDE.md
            framework-commands.tar.gz
            init-project.sh
```

---

## Lessons Learned

1. **Single Source of Truth:**
   - Version appears in multiple files
   - Manual updates are error-prone
   - Automation prevents mistakes

2. **Validation is Critical:**
   - Catch errors before release
   - Prevents user-facing issues
   - Small investment, big payoff

3. **Self-Healing is Powerful:**
   - Protects users from bad releases
   - Better UX than error messages
   - Defensive programming wins

4. **Release Process Matters:**
   - Manual processes fail eventually
   - Scripts ensure consistency
   - Documentation helps future you

---

## Status: Ready for v2.5.1 Release

All fixes implemented and tested. Framework is ready for next release with:
- ✅ Self-healing mechanism active
- ✅ Validation scripts in place
- ✅ Automated release workflow ready
- ✅ Version consistency guaranteed

**Recommended next version:** v2.5.1 (includes these bug fixes)

---

**Report generated:** 2026-01-17
**Framework version:** v2.5.0
**Fixed by:** Claude Code Framework Bug Fix Protocol
