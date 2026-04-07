# Completion Protocol (Optimized)

**Version:** 2.6.0
**Last updated:** 2026-01-20

**Purpose:** Fast sprint finalization with background processing.

**Trigger:** User types "завершить", "заверши", "finish", or "done"

**Time:** 30-60 seconds (was 5-6 minutes)

---

## Design Philosophy

**Problems with v2.5.1:**
- 5-6 minutes to complete
- Blocks work during build (npm run build takes 10-30s)
- Excessive output (200+ lines)
- Step 0 (re-read protocol) wastes time — we JUST read it via Skill tool
- Too much ceremony for routine operations
- 20-30% of development time spent on protocol overhead

**Solutions in v2.6.0:**
- Build in background (non-blocking)
- Export & security in background
- Skip Step 0 (protocol already loaded by Skill tool)
- Compact output (10-15 lines vs 200+)
- Silent success, only show what matters
- Fast commit workflow

---

## Output Format

**Simple progress:**
```
🏁 Completion Protocol

⏳ Processing (background: build, export, cleanup)...
  ✓ Build (4.2s)
  ✓ Dialog export (3 sessions)
  ✓ Security (0 issues)

📝 Metafiles updated:
  • SNAPSHOT.md: Added Decision Log section
  • BACKLOG.md: Updated Phase 16 status
  • CHANGELOG.md: v2.6.0 entry

📦 Ready to commit (4 files changed, +331 lines)

Commit message:
"feat: Add Decision Log and Lessons Learned

- SNAPSHOT.md: Decision Log (5 decisions)
- SNAPSHOT.md: Lessons Learned (16 insights)
- BACKLOG.md: What NOT to do (6 items)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

✅ Commit? (Y/n):
```

**Error example:**
```
⚠️  Build failed
  → TypeScript error in src/exporter.ts:42
     Expected ';' but found '}'

Fix error and run /fi again
```

---

## Protocol Steps

### Phase 1: Background Processing (Parallel, 10-30s)

Launch ALL long-running tasks in background:

**Task 1: Build (if code changed)**
```bash
# Background agent: Bash specialist
# Check if any .ts files modified
if git diff --name-only | grep -q '\.ts$'; then
  npm run build 2>&1
  echo "BUILD_EXIT_CODE:$?"
else
  echo "BUILD_SKIPPED:no_typescript_changes"
fi
```

**Task 2: Dialog Export**
```bash
# Background agent: Bash specialist
npm run dialog:export --no-html 2>&1 | tail -5
echo "EXPORT_EXIT_CODE:$?"
```

**Task 3: Security Cleanup**
```bash
# Background agent: Bash specialist
if [ -f "security/cleanup-dialogs.sh" ]; then
  bash security/cleanup-dialogs.sh --last 2>&1
  echo "SECURITY_EXIT_CODE:$?"
else
  echo "SECURITY_SKIPPED:no_script"
fi
```

**Show initial status:**
```
🏁 Completion Protocol

⏳ Processing (background: build, export, cleanup)...
```

---

### Phase 2: Update Metafiles (AI work, can't background)

**While background tasks run, AI updates metafiles in parallel:**

**Files to update (AI reviews changes and updates):**
1. `.claude/BACKLOG.md` — Mark completed `[x]`, add new tasks
2. `.claude/SNAPSHOT.md` — Update version/status if needed
3. `CHANGELOG.md` — Add entry if creating release
4. `README.md` / `README_RU.md` — If major features added
5. `.claude/ARCHITECTURE.md` — If code structure changed

**Show what changed (compact):**
```
📝 Metafiles updated:
  • SNAPSHOT.md: Added Decision Log section
  • BACKLOG.md: Phase 16 completed
  • CHANGELOG.md: v2.6.0 entry
```

**If no changes needed:**
```
📝 Metafiles: no updates needed
```

---

### Phase 3: Wait for Background Tasks (<2s)

**Read background task outputs using TaskOutput**

**Show results:**
```
  ✓ Build (4.2s)
  ✓ Dialog export (3 sessions)
  ✓ Security (0 issues)
```

**If build failed:**
```
  ❌ Build failed
     → TypeScript error in src/exporter.ts:42
        Expected ';' but found '}'

Fix error and run /fi again
```
**STOP protocol if build failed** — user must fix error first.

**If security found credentials:**
```
  ⚠️  Security: 2 credentials redacted
     Details: .claude/logs/security/cleanup-*.txt
```

---

### Phase 4: Git Commit (Interactive, <5s)

**Check COMMIT_POLICY.md first (auto-create if missing):**
```bash
# Auto-create COMMIT_POLICY if missing (same as Cold Start)
if [ ! -f ".claude/COMMIT_POLICY.md" ]; then
  # Create from template or minimal version
  # (silent, no output)
fi
```

**Read COMMIT_POLICY.md and verify changes:**
- Check git status
- Read COMMIT_POLICY patterns
- Verify no forbidden files staged

**Prepare commit:**

1. **Run git status to see changes:**
```bash
git status
```

2. **Run git diff to see what changed:**
```bash
git diff
```

3. **Analyze changes and draft commit message:**
   - Summarize nature of changes (feat/fix/chore/docs)
   - Reference what was done (be specific)
   - Keep concise (1-2 sentences)
   - Always end with Co-Authored-By

**Show compact summary:**
```
📦 Ready to commit (4 files changed, +331 lines)

Files:
  M .claude/SNAPSHOT.md (+216)
  M .claude/BACKLOG.md (+115)
  M .gitignore (-4, +8)
  A .claude/ARCHITECTURE.md (+171)

Commit message:
"feat: Add framework metafiles + Memory Bank improvements

Decision Log, Lessons Learned, What NOT to do sections

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

✅ Commit? (Y/n):
```

**If user confirms (Y or Enter):**
```bash
# Add files
git add <files>

# Commit with message
git commit -m "$(cat <<'EOF'
<message here>
EOF
)"
```

**If user rejects (n):**
```
Commit cancelled. Make changes and run /fi again.
```

**Show result:**
```
  ✓ Committed (83e637a)
```

---

### Phase 5: Push & PR (Optional, <2s)

**Ask user (compact):**
```
🚀 Push to GitHub?
  1. Push now
  2. Skip (push later manually)

? (1/2):
```

**If choice 1:**
```bash
git push
```

**Then ask about PR:**
```
📋 Create PR?
  1. Yes (opens gh pr create)
  2. No

? (1/2):
```

**If PR requested:**
```bash
# Get branch info
CURRENT_BRANCH=$(git branch --show-current)
BASE_BRANCH="main"  # or detect from git config

# Get commit history for this branch
git log ${BASE_BRANCH}...HEAD --oneline

# Draft PR summary based on commits
# Then create PR:
gh pr create --title "..." --body "$(cat <<'EOF'
## Summary
...

## Test plan
...

🤖 Generated with Claude Code
EOF
)"
```

---

### Phase 6: Mark Session Clean (<1s)

```bash
# Mark session clean (silent)
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

**Show:**
```
  ✓ Session marked clean
```

---

### Phase 7: Bug Report (Optional, <2s)

**If bug reporting enabled, ask (compact):**
```
📊 Create telemetry report? (y/N)
   Anonymous session summary for framework improvements
```

**If yes:**
```bash
# Finalize completion log
if [ -n "$COMPLETION_LOG" ]; then
  echo "" >> "$COMPLETION_LOG"
  echo "## Summary" >> "$COMPLETION_LOG"
  echo "" >> "$COMPLETION_LOG"
  echo "**Status:** Success" >> "$COMPLETION_LOG"
  echo "**Duration:** ${SECONDS}s" >> "$COMPLETION_LOG"
  echo "**Files changed:** $(git diff HEAD~1 --name-only | wc -l)" >> "$COMPLETION_LOG"
  echo "" >> "$COMPLETION_LOG"
fi

# Ask if user wants to submit
read -p "Submit telemetry to GitHub? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Anonymize and submit (if gh available)
  bash .claude/scripts/submit-bug-report.sh "$COMPLETION_LOG"
fi
```

**If skipped or disabled:**
```
  ℹ️  Telemetry skipped
```

---

### Phase 8: Complete

**Show final summary:**
```
✅ Complete — Time: 42s

Next steps:
  • Continue working
  • Or type "exit" to end session
```

---

## Implementation Notes

**Background agents:**
- Use Task tool with `run_in_background=true`
- Launch build, export, security in parallel
- Use TaskOutput to read results
- Continue with metafile updates while waiting

**Removed:**
- Step 0 (Re-read protocol) — already loaded by Skill tool
- Excessive logging output
- Ceremonial confirmations
- Duplicate checks

**Compact output:**
- No ━━━ borders
- Emoji progress: ⏳ ✓ ⚠️ ❌ 📝 📦 🚀 ✅
- Group related info
- Show only actionable items

**Error handling:**
- Build failures STOP protocol immediately
- Security warnings shown but don't block
- Clear error messages with next steps
- No cryptic bash errors shown to user

**Commit workflow:**
- Fast review (git status + diff)
- AI drafts message automatically
- Single Y/n confirmation
- No multi-step ceremony

**Push/PR workflow:**
- Optional, asked after commit
- Compact choices (1/2 instead of long prompts)
- gh pr create with auto-generated summary
- User can skip and do manually

---

## Time Breakdown

**v2.5.1 (Sequential):**
- Step 0: Re-read protocol: 10-20s (read 696 lines)
- Step 0.1: Logging: 1s
- Step 1: Build: 10-30s (BLOCKS work)
- Step 2: Update metafiles: 30-60s (AI work)
- Step 3: Dialog export: 5-10s
- Step 3.5: Security cleanup: 2-5s
- Step 4: Git commit: 10-20s (review + commit)
- Step 5: Push/PR: 5-10s
- Step 6: Mark clean: 1s
- Step 6.5: Bug report: 5-10s
- **Total:** 79-166s (1.3-2.7 min)

**v2.6.0 (Parallel):**
- Phase 1: Launch background tasks: 1s
- Phase 2: Update metafiles (parallel): 30-40s
- Phase 3: Wait & check results: 2s
- Phase 4: Git commit: 5-10s
- Phase 5: Push/PR (optional): 3-5s
- Phase 6: Mark clean: 1s
- Phase 7: Bug report (optional): 2s
- **Total:** 44-60s

**Savings:** 40-60% faster + 90% less noise

---

## Logging

**All background tasks log to:**
```
.claude/logs/completion/session-YYYYMMDD-HHMMSS.log
```

**Compact log format:**
```
[HH:MM:SS] Phase 1: Background tasks started
[HH:MM:SS]   → Build, Export, Security
[HH:MM:SS] Phase 2: Updating metafiles
[HH:MM:SS]   → SNAPSHOT.md, BACKLOG.md
[HH:MM:SS] Phase 3: Background complete (18s)
[HH:MM:SS]   ✓ Build: success
[HH:MM:SS]   ✓ Export: 3 sessions
[HH:MM:SS]   ✓ Security: clean
[HH:MM:SS] Phase 4: Git commit (83e637a)
[HH:MM:SS] Phase 5: Push skipped
[HH:MM:SS] ✓ Protocol complete (42s total)
```

---

## Verbose Mode (Optional)

**For debugging:**
```bash
export CLAUDE_MODE=verbose
```

**Shows:**
- Full build output
- All bash commands
- Timing for each phase
- Background task details

---

## Version Bumping (Releases Only)

**If creating release, run BEFORE commit:**

```bash
# Ask if this is a release
read -p "Creating release? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Get current version
  CURRENT=$(grep "Framework: Claude Code Starter v" CLAUDE.md | sed 's/.*v//')
  echo "Current version: v$CURRENT"

  # Ask for new version
  read -p "New version (e.g., 2.6.0): v" NEW_VERSION

  # Update all version files (silent)
  bash migration/update-version.sh "$NEW_VERSION"

  echo "✓ Version bumped to v$NEW_VERSION"
fi
```

**Include in commit message:**
```
feat: Protocol optimization v2.6.0

Background agents reduce Cold Start time by 60%...
```

---

**Protocol Complete** ✅
