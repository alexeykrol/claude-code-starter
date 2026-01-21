# Bug Report: COMMIT_POLICY Missing reports/ Pattern + Not Auto-Created

**Reported:** 2026-01-17T15:45:00-08:00
**Project:** ai-test01_anon
**Framework Version:** v2.5.0
**Severity:** High (Security/Privacy Risk)
**Category:** Security / Commit Policy / Installation

---

## Summary

1. Template `.claude/templates/COMMIT_POLICY.template.md` is missing `reports/` directory in forbidden patterns
2. `COMMIT_POLICY.md` is not auto-created during framework installation
3. Claude AI violated Completion Protocol Step 4 by not checking COMMIT_POLICY before commit
4. Result: Bug reports with potentially sensitive information were committed to git

---

## What Happened

### Timeline

1. User triggered Cold Start Protocol
2. Framework updated from v2.4.3 → v2.5.0 (version loop bug occurred)
3. User requested bug report creation for version loop issue
4. Claude AI created bug report: `reports/bug-reports/framework-version-loop-20260117.md`
5. Bug report successfully submitted to GitHub Issues #57
6. **ERROR:** Claude AI committed the local bug report copy to git:
   ```bash
   git add reports/bug-reports/
   git commit -m "chore: Update framework to v2.5.0..."
   git push
   ```
7. User noticed the error and requested rollback
8. Commit was rolled back, COMMIT_POLICY.md created, and corrected commit made

### What Was Committed (Should NOT Have Been)

```
reports/bug-reports/framework-version-loop-20260117.md
```

**Why this is problematic:**
- Bug reports are already submitted to GitHub Issues
- Local copies are for reference only
- May contain project-specific information
- Duplicates data (already in GitHub)
- Violates privacy-by-default principle

---

## Root Cause Analysis

### Issue 1: Missing Pattern in Template

**File:** `.claude/templates/COMMIT_POLICY.template.md`

**Current state (lines 22-29):**
```markdown
### 2. Framework логи и диалоги (КРИТИЧНО!)

```
dialog/                 # Claude диалоги (могут содержать credentials!)
.claude/logs/           # Framework execution logs
*.debug.log             # Debug логи
debug/                  # Debug файлы
```
```

**Missing pattern:**
```markdown
reports/                # Bug reports и migration logs
```

**Impact:**
- Bug reports not recognized as forbidden files
- Migration logs not recognized as forbidden files
- Leads to accidental commits

### Issue 2: COMMIT_POLICY.md Not Auto-Created

**Expected behavior:**
- Framework installation should create `.claude/COMMIT_POLICY.md` automatically
- Should be part of initial framework setup

**Actual behavior:**
- Only template exists: `.claude/templates/COMMIT_POLICY.template.md`
- Projects must manually create COMMIT_POLICY.md
- Many projects will miss this step

**Evidence:**
```bash
$ ls -la .claude/COMMIT_POLICY.md
ls: .claude/COMMIT_POLICY.md: No such file or directory

$ ls -la .claude/templates/COMMIT_POLICY.template.md
-rw-r--r--  1 user  staff  1441 Jan 17 13:52 .claude/templates/COMMIT_POLICY.template.md
```

**Where it should be created:**
- During `init-project.sh` execution
- During framework installation (v2.2 installer)
- During Cold Start if missing (auto-recovery)

### Issue 3: Protocol Violation by Claude AI

**Protocol:** `.claude/protocols/completion.md` Step 4 (lines 307-465)

**Required steps:**
1. Load COMMIT_POLICY.md
2. Get changed files (git status)
3. Analyze each file against policy patterns
4. Show what will be staged
5. Stage ONLY approved files (NOT `git add -A`!)
6. Ask user confirmation
7. Create commit

**What Claude AI did instead:**
```bash
git add .gitignore CLAUDE.md .claude/commands/framework-commands/ reports/bug-reports/
```

**Why this happened:**
- COMMIT_POLICY.md didn't exist
- Claude AI didn't check for file existence
- No fallback behavior defined for missing policy
- Assumed all files safe to commit
- Violated "policy-first" principle

**Expected behavior when COMMIT_POLICY.md missing:**
```
⚠️ COMMIT_POLICY.md not found. Update framework or add manually.
Fallback to cautious mode: only stage src/, tests/, README.md, package.json
```

---

## Security Impact

### Information Leaked in Bug Report

The committed bug report contained:
- Project name (anonymized, but still)
- Framework version details
- Command execution patterns
- Directory structure hints
- Git workflow details

**Severity:** Low (information already public via GitHub Issue)

### Potential for Future Leaks

If pattern continues:
- Migration reports with project details
- Bug reports with error messages containing paths
- Stack traces with file structure
- Environment-specific information

**Severity:** Medium-High (could leak sensitive data)

---

## Frequency & Impact

**User quote:**
> "Тебе надо откатить коммит и сделать исправление"

This suggests:
- User immediately noticed the error
- User understands security implications
- Framework security model not working as expected

**Estimated impact:**
- Affects all host projects using framework
- Any project creating bug reports
- Any project running migrations
- Potentially hundreds of installations

---

## Reproduction Steps

1. Install framework v2.5.0 on fresh project
2. Verify COMMIT_POLICY.md does NOT exist:
   ```bash
   ls .claude/COMMIT_POLICY.md
   # Result: No such file
   ```
3. Create a file in `reports/` directory:
   ```bash
   mkdir -p reports/bug-reports
   echo "test" > reports/bug-reports/test.md
   ```
4. Ask Claude AI to commit changes
5. **BUG:** Claude AI commits `reports/` without checking policy

**Expected:** Claude AI should either:
- Refuse to commit (COMMIT_POLICY.md missing)
- Auto-create COMMIT_POLICY.md from template
- Use hardcoded fallback rules

**Actual:** Commits without policy check

---

## Recommended Fixes

### Fix 1: Update Template (Immediate)

**File:** `.claude/templates/COMMIT_POLICY.template.md`

**Add to line 29 (after `debug/`):**
```markdown
reports/                # Bug reports и migration logs (уже в GitHub Issues)
```

**Full section becomes:**
```markdown
### 2. Framework логи и диалоги (КРИТИЧНО!)

```
dialog/                 # Claude диалоги (могут содержать credentials!)
.claude/logs/           # Framework execution logs
*.debug.log             # Debug логи
debug/                  # Debug файлы
reports/                # Bug reports и migration logs (уже в GitHub Issues)
```
```

### Fix 2: Auto-Create COMMIT_POLICY.md (Critical)

**Option A: During Installation**

Update `init-project.sh` (line ~180):
```bash
# Create COMMIT_POLICY.md from template
echo "  Creating COMMIT_POLICY.md..."
sed "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
  .claude/templates/COMMIT_POLICY.template.md > .claude/COMMIT_POLICY.md
```

**Option B: During Cold Start (Auto-Recovery)**

Add to `.claude/protocols/cold-start.md` Step 0.5:
```bash
# Auto-create COMMIT_POLICY.md if missing
if [ ! -f ".claude/COMMIT_POLICY.md" ]; then
  echo "⚠️  COMMIT_POLICY.md missing, creating from template..."
  PROJECT_NAME=$(basename "$(pwd)")
  sed "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
    .claude/templates/COMMIT_POLICY.template.md > .claude/COMMIT_POLICY.md
  echo "✅ COMMIT_POLICY.md created"
fi
```

**Option C: During Completion (Fail-Safe)**

Add to `.claude/protocols/completion.md` Step 4.1:
```bash
# Check if COMMIT_POLICY.md exists
if [ ! -f ".claude/COMMIT_POLICY.md" ]; then
  echo "⚠️  CRITICAL: COMMIT_POLICY.md not found!"
  echo ""
  echo "Creating from template..."
  PROJECT_NAME=$(basename "$(pwd)")
  sed "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
    .claude/templates/COMMIT_POLICY.template.md > .claude/COMMIT_POLICY.md
  echo ""
  echo "✅ COMMIT_POLICY.md created. Please review before committing."
  echo ""
  read -p "Continue with commit? (y/N) " -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Commit cancelled. Review .claude/COMMIT_POLICY.md"
    exit 1
  fi
fi
```

**Recommendation:** Implement ALL THREE for defense in depth.

### Fix 3: Update Completion Protocol (Critical)

**File:** `.claude/protocols/completion.md` Step 4.1

**Current (lines 313-320):**
```markdown
### Step 4.1: Load COMMIT_POLICY

**Action:** Read `.claude/COMMIT_POLICY.md` to understand what can be committed.

**If file doesn't exist:**
- Project uses old framework version
- Warn user: "⚠️ COMMIT_POLICY.md not found. Update framework or add manually."
- Fallback to cautious mode: only stage src/, tests/, README.md, package.json
```

**Problem:** This is guidance for Claude AI, but AI didn't follow it.

**Proposed fix:**
```markdown
### Step 4.1: Load COMMIT_POLICY (MANDATORY)

**Action:** Read `.claude/COMMIT_POLICY.md` BEFORE proceeding.

**CRITICAL: If file doesn't exist:**
1. **STOP** - Do NOT proceed with commit
2. Auto-create from template (see Fix 2 Option C)
3. Show warning to user
4. Ask user to review policy
5. Only proceed after user confirmation

**Fallback rules (if template also missing):**
Only stage these patterns:
- `src/`, `lib/`, `tests/`
- `README.md`, `CHANGELOG.md`, `LICENSE`
- `package.json`, `tsconfig.json`
- `.claude/SNAPSHOT.md`, `.claude/BACKLOG.md`, `.claude/ARCHITECTURE.md`

**Never stage these patterns (hardcoded):**
- `dialog/`, `.claude/logs/`, `reports/`
- `notes/`, `scratch/`, `experiments/`
- `secrets/`, `credentials/`, `*.key`, `*.pem`
- `.vscode/`, `.idea/`, `*.local.*`
```

### Fix 4: Add reports/ to .gitignore Template

**File:** `init-project.sh` or framework installation script

**Ensure .gitignore includes:**
```gitignore
# Claude Code Framework - Private files
.claude/.framework-config
.claude/.last_session
.claude/logs/
reports/
```

### Fix 5: Pre-commit Hook Validation

**Strengthen:** `.claude/scripts/pre-commit-hook.sh`

**Add hardcoded forbidden patterns:**
```bash
# Hardcoded forbidden patterns (last line of defense)
FORBIDDEN_PATTERNS=(
  "dialog/"
  ".claude/logs/"
  "reports/"
  "notes/"
  "scratch/"
  "secrets/"
  "credentials/"
)

# Check staged files
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if git diff --cached --name-only | grep -q "^${pattern}"; then
    echo "❌ COMMIT BLOCKED: Forbidden pattern detected: ${pattern}"
    echo ""
    echo "Staged files matching pattern:"
    git diff --cached --name-only | grep "^${pattern}"
    echo ""
    echo "Review .claude/COMMIT_POLICY.md"
    exit 1
  fi
done
```

---

## Testing Checklist

**Before releasing any version:**

- [ ] Template includes `reports/` pattern
- [ ] COMMIT_POLICY.md auto-created during installation
- [ ] COMMIT_POLICY.md auto-created during Cold Start if missing
- [ ] COMMIT_POLICY.md auto-created during Completion if missing
- [ ] Claude AI reads COMMIT_POLICY.md before every commit
- [ ] Fallback rules work if COMMIT_POLICY.md missing
- [ ] Pre-commit hook blocks forbidden patterns
- [ ] Test on fresh project installation
- [ ] Test on framework upgrade from v2.4.x
- [ ] Verify `reports/` never committed

---

## Expected Behavior (After Fix)

### Scenario 1: Fresh Installation
```bash
$ bash init-project.sh
Creating framework structure...
  ✅ .claude/COMMIT_POLICY.md created
  ✅ All metafiles created
```

### Scenario 2: Cold Start (Missing Policy)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  COMMIT_POLICY.md missing, creating from template...
✅ COMMIT_POLICY.md created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Scenario 3: Completion with reports/ Changes
```
Claude AI checks COMMIT_POLICY.md:
  ✅ COMMIT_POLICY.md found
  ✅ Parsing forbidden patterns...
  ❌ reports/bug-reports/test.md matches forbidden pattern: reports/

Changes NOT staged:
  • reports/bug-reports/test.md (forbidden)

Changes staged:
  • src/components/Quiz.tsx
  • README.md

Proceed with commit? (y/N)
```

### Scenario 4: Pre-commit Hook (Last Defense)
```bash
$ git commit -m "test"
❌ COMMIT BLOCKED by pre-commit hook

Forbidden files detected:
  • reports/bug-reports/test.md

Review .claude/COMMIT_POLICY.md
```

---

## Additional Context

### User Experience

User immediately caught the error:
> "обнаружена ошибка, потому что все, что касается баг-репортов, любых проектов, мы не должны коммитить"

This shows:
- Security-conscious user
- Framework failed to prevent mistake
- Manual intervention required (should be automatic)

### Framework Philosophy

From CLAUDE.md:
> "Privacy by Default — dialogs private in .gitignore"

**Problem:** This principle extends beyond dialogs:
- Bug reports are private (project-specific)
- Migration logs are private (project-specific)
- Framework logs are private (execution details)

**COMMIT_POLICY.md should enforce this automatically.**

---

## Priority Recommendation

**Critical:** Fix immediately in v2.5.1 because:
1. Security/privacy risk
2. Affects all projects
3. Easy to reproduce
4. Easy to fix
5. Already caused one leak (this bug report itself!)

**Suggested timeline:**
- Fix 1 (template): 1 hour
- Fix 2 (auto-create): 2 hours
- Fix 3 (protocol): 1 hour
- Fix 4 (gitignore): 30 minutes
- Fix 5 (hook): 1 hour
- Testing: 2 hours
- **Total:** 1 day

**Release as:** v2.5.1 (hotfix)

---

## Files Affected

- `.claude/templates/COMMIT_POLICY.template.md` (add reports/ pattern)
- `.claude/protocols/cold-start.md` (auto-create policy)
- `.claude/protocols/completion.md` (strengthen Step 4.1)
- `init-project.sh` (create policy during install)
- `.claude/scripts/pre-commit-hook.sh` (add hardcoded forbidden patterns)
- `.gitignore` template (add reports/)

---

## Related Issues

- Issue #57: Framework Version Update Loop
  - That bug report should NOT have been committed
  - This bug report documents why it happened

---

**Report generated by:** Claude Code Framework Bug Reporting
**Host project:** ai-test01 (anonymized)
**Framework:** Claude Code Starter v2.5.0

**Meta-note:** This bug report itself demonstrates the issue - it's being created in `reports/bug-reports/` and should NOT be committed to git. It will be submitted to GitHub Issues only.
