# Bug Report: Framework Version Update Loop

**Reported:** 2026-01-17T15:30:00-08:00
**Project:** ai-test01_anon
**Framework Version:** v2.5.0
**Severity:** High (Blocks normal framework startup)
**Category:** Release Process / Version Management

---

## Summary

Framework update check enters infinite loop when GitHub release contains CLAUDE.md file with incorrect version number inside. This causes repeated update attempts across session restarts.

---

## Problem Description

### What Happened

1. User runs Cold Start Protocol (`start` command)
2. Step 0.2 (Framework Version Check) executes:
   - Parses local version from `CLAUDE.md`: **v2.4.3**
   - Fetches latest release from GitHub API: **v2.5.0**
   - Detects version mismatch
   - Downloads CLAUDE.md from v2.5.0 release
   - Replaces local CLAUDE.md
   - Instructs user to restart session
3. User exits and starts new session
4. Step 0.2 executes again:
   - Parses local version from newly downloaded `CLAUDE.md`: **still v2.4.3** ❌
   - Fetches latest release: **v2.5.0**
   - Detects version mismatch again
   - **Loop continues indefinitely**

### Root Cause

The GitHub release **v2.5.0** contains `CLAUDE.md` file where the version string inside was not updated:

```markdown
*Framework: Claude Code Starter v2.4.3 | Updated: 2026-01-17*
```

Should be:

```markdown
*Framework: Claude Code Starter v2.5.0 | Updated: 2026-01-17*
```

### Verification

```bash
# Verify the problem
curl -sL "https://github.com/alexeykrol/claude-code-starter/releases/download/v2.5.0/CLAUDE.md" | grep "Framework: Claude Code Starter v"
# Output: *Framework: Claude Code Starter v2.4.3 | Updated: 2026-01-17*

# GitHub API correctly reports v2.5.0
curl -s https://api.github.com/repos/alexeykrol/claude-code-starter/releases/latest | jq -r '.tag_name'
# Output: v2.5.0
```

---

## Impact

### User Experience
- User stuck in update loop
- Cannot proceed with normal Cold Start workflow
- Requires manual intervention to fix
- Confusing error state ("why does it keep updating?")

### Frequency
User reports this has happened "несколько раз" (several times), indicating this is a **recurring release process issue**.

---

## Workaround Applied

Manual fix was required:

```bash
# Edit CLAUDE.md to correct version
sed -i '' 's/v2.4.3/v2.5.0/g' CLAUDE.md

# Verify fix
grep "Framework: Claude Code Starter v" CLAUDE.md
```

After manual correction, Cold Start completed successfully.

---

## Technical Details

### Affected Code

**File:** `.claude/protocols/cold-start.md`
**Step:** 0.2 (Framework Version Check)

```bash
# Line ~131
LOCAL_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

# Line ~134
LATEST_VERSION=$(curl -s https://api.github.com/repos/alexeykrol/claude-code-starter/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')

# Line ~137 - Comparison triggers on mismatch
if [ "$LOCAL_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "" ]; then
```

### Version Sources

The framework version appears in **multiple places**:

1. **GitHub Release Tag** → `v2.5.0` ✅ (correct)
2. **CLAUDE.md footer** → `v2.4.3` ❌ (incorrect in release artifact)
3. Possibly other locations in framework files

---

## Root Cause Analysis

This is a **build/release process bug**, not a runtime bug.

### Why This Happens

1. Developer updates version in some files but not all
2. Release created from incorrect working tree state
3. No automated version consistency check before release
4. Manual version updates are error-prone

### Why This Recurs

User reports "уже повторялось несколько раз" suggests:
- No pre-release validation script
- Manual release process
- No CI/CD checks for version consistency

---

## Recommended Fix

### Short-term (v2.5.1 Hotfix)

1. **Immediate:** Re-release v2.5.0 with corrected CLAUDE.md:
   ```bash
   # Update all version strings in CLAUDE.md
   sed -i 's/v2.4.3/v2.5.0/g' CLAUDE.md

   # Delete old release and re-create
   gh release delete v2.5.0
   gh release create v2.5.0 --title "v2.5.0" ...
   ```

2. **OR:** Release v2.5.1 with version fix:
   - Corrects CLAUDE.md version strings
   - Updates CHANGELOG noting the fix

### Long-term (Process Improvement)

1. **Single Source of Truth:**
   ```bash
   # Create VERSION file
   echo "2.5.0" > VERSION

   # Reference in all files
   VERSION=$(cat VERSION)
   ```

2. **Pre-release Validation Script:**
   ```bash
   #!/bin/bash
   # migration/validate-release.sh

   VERSION=$(cat VERSION)

   # Check CLAUDE.md
   CLAUDE_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

   if [ "$CLAUDE_VERSION" != "$VERSION" ]; then
     echo "❌ Version mismatch in CLAUDE.md: $CLAUDE_VERSION != $VERSION"
     exit 1
   fi

   # Check CHANGELOG.md
   if ! grep -q "## \[v$VERSION\]" CHANGELOG.md; then
     echo "❌ Version v$VERSION not found in CHANGELOG.md"
     exit 1
   fi

   echo "✅ All version checks passed for v$VERSION"
   ```

3. **Automated Release Script:**
   ```bash
   # migration/create-release.sh
   VERSION=$(cat VERSION)

   # Run validation first
   bash migration/validate-release.sh || exit 1

   # Update all version references
   sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v$VERSION/g" CLAUDE.md
   sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v$VERSION/g" cold-start.md

   # Build distribution
   bash migration/build-distribution.sh

   # Create GitHub release
   gh release create "v$VERSION" \
     --title "Claude Code Starter v$VERSION" \
     --notes-file RELEASE_NOTES.md \
     CLAUDE.md \
     framework-commands.tar.gz \
     init-project.sh
   ```

4. **GitHub Actions CI/CD:**
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

## Alternative: Add Self-Healing to Cold Start

Add version correction to Cold Start protocol as safety net:

```bash
# Step 0.2: After successful update download
if [ -f "CLAUDE.md.new" ] && [ -f "/tmp/fw-cmd.tar.gz" ]; then
  # Verify downloaded version matches expected
  DOWNLOADED_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md.new | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

  if [ "$DOWNLOADED_VERSION" != "$LATEST_VERSION" ]; then
    echo "⚠️  Downloaded CLAUDE.md has wrong version ($DOWNLOADED_VERSION)"
    echo "   Auto-correcting to v$LATEST_VERSION..."

    # Fix version in downloaded file
    sed -i "s/v$DOWNLOADED_VERSION/v$LATEST_VERSION/g" CLAUDE.md.new
  fi

  # Replace local file
  mv CLAUDE.md.new CLAUDE.md
  # ... rest of update logic
fi
```

**Pros:**
- Self-healing, works around bad releases
- Protects users from release process bugs

**Cons:**
- Masks underlying problem
- Silent correction could hide issues
- Doesn't fix root cause

---

## Testing Checklist

Before releasing any version:

- [ ] VERSION file contains correct version
- [ ] CLAUDE.md contains matching version (all occurrences)
- [ ] cold-start.md contains matching version (if referenced)
- [ ] completion.md contains matching version (if referenced)
- [ ] CHANGELOG.md contains version entry
- [ ] package.json version matches (if applicable)
- [ ] Git tag matches version
- [ ] Release artifacts tested on clean host project
- [ ] Update loop does not occur on fresh install

---

## Expected Behavior

After fix, Cold Start should:

1. Detect version mismatch (v2.4.x → v2.5.0)
2. Download CLAUDE.md from v2.5.0 release
3. Downloaded file contains: `*Framework: Claude Code Starter v2.5.0*`
4. Update completes successfully
5. User restarts session
6. Version check parses: `LOCAL_VERSION=2.5.0`
7. Version check fetches: `LATEST_VERSION=2.5.0`
8. No mismatch detected → "Framework v2.5.0 is up to date"
9. Cold Start continues normally

---

## Additional Context

### User Quote
> "я вижу проблему: ты вошел в какой-то цикл, потому что мы уже сделали один проход, в котором фреймворк был обновлён, и ты уже сказал, что надо сделать выход, потом запуск новой сессии. Я это уже сделал, и ты повторно меня просишь делать то же самое. Где-то ошибка в логике."

> "эта ошибка, как я видел, уже повторялась несколько раз"

This indicates:
- Problem has occurred in multiple releases
- User frustration with repeated issue
- Need for systematic fix, not one-off patch

---

## Priority Recommendation

**Critical:** This should be fixed immediately as:
1. Blocks all users on v2.4.x from successfully updating
2. Creates confusing user experience
3. Has recurred multiple times
4. Easy to fix with process improvements

**Suggested timeline:**
- Hotfix release v2.5.1: Within 24 hours
- Process improvements: Within 1 week
- Automated validation: Within 2 weeks

---

## Files Affected

- `CLAUDE.md` (incorrect version in v2.5.0 release)
- `.claude/protocols/cold-start.md` (could add self-healing)
- `migration/build-distribution.sh` (needs version validation)
- GitHub release v2.5.0 artifacts

---

**Report generated by:** Claude Code Framework Bug Reporting
**Host project:** ai-test01 (anonymized)
**Framework:** Claude Code Starter v2.5.0
