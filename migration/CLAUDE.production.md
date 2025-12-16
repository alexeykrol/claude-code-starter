# CLAUDE.md — AI Agent Instructions

**Framework:** Claude Code Starter v2.2
**Type:** Meta-framework extending Claude Code capabilities

## Triggers

**"start", "начать":**
→ Execute Cold Start Protocol

**"заверши", "завершить", "finish", "done":**
→ Execute Completion Protocol

---

## Cold Start Protocol

### Step 0.05: Migration Cleanup Recovery

Check for leftover migration files and clean them up:

```bash
# Check for production CLAUDE.md waiting to be swapped
if [ -f ".claude/CLAUDE.production.md" ]; then
  echo "⚠️  Found leftover migration files. Cleaning up..."

  # Swap CLAUDE.md if needed
  if grep -q "Migration Mode" CLAUDE.md 2>/dev/null; then
    cp .claude/CLAUDE.production.md CLAUDE.md
    echo "✓ Swapped CLAUDE.md to production version"
  fi

  # Remove all migration artifacts
  rm -f .claude/CLAUDE.production.md
  rm -f .claude/migration-context.json
  rm -f .claude/migration-log.json
  rm -f .claude/commands/migrate-legacy.md
  rm -f .claude/commands/upgrade-framework.md
  rm -f .claude/framework-pending.tar.gz

  echo "✓ Migration cleanup complete"
fi
```

If cleanup performed, continue to Step 0.1 (Crash Recovery).

---

### Step 0.1: Crash Recovery & Auto-Recovery
```bash
cat .claude/.last_session 2>/dev/null
```
- If `"status": "active"` → Check if real crash or just missing `/fi`:
  ```bash
  # Check for uncommitted changes
  if git diff --quiet && git diff --staged --quiet; then
    # Working tree clean - probably forgot /fi
    echo "ℹ️  Previous session didn't run /fi but working tree is clean."
    echo "Auto-recovering to clean state..."
    echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
    # Continue to Step 1
  else
    # True crash - has uncommitted changes
    echo "⚠️  Previous session crashed with uncommitted changes"
    git status
    # Read .claude/SNAPSHOT.md for context
    # Ask: "Continue or commit first?"
  fi
  ```
- If `"status": "clean"` → OK, continue to Step 1

### Step 1: Mark Session Active
```bash
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

### Step 2: Load Context (ALWAYS read — keep compact!)
- `.claude/SNAPSHOT.md` — current state (~30-50 lines)
- `.claude/BACKLOG.md` — current sprint tasks (~50-100 lines)
- `.claude/ARCHITECTURE.md` — code structure (~100-200 lines)

### Step 3: Context (ON DEMAND — read when needed)
- `.claude/ROADMAP.md` — strategic direction (when planning)
- `.claude/IDEAS.md` — ideas backlog (when exploring)
- `CHANGELOG.md` — version history (when need history)

### Step 4: Confirm
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Context loaded. Ready to work!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Directory: [pwd]
🔧 Framework: Claude Code Starter v2.2
📦 Project: [from SNAPSHOT.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> **Token Economy:** Step 2 files are read EVERY session — keep them compact.

---

## Completion Protocol

### 1. Build (if code changed)
```bash
npm run build
```

### 2. Update Metafiles
- `.claude/BACKLOG.md` — mark completed tasks `[x]`
- `.claude/SNAPSHOT.md` — update version and status
- `CHANGELOG.md` — add entry (if release)
- `.claude/ARCHITECTURE.md` — update if code structure changed

### 3. Git Commit
```bash
git add -A && git status
git commit -m "$(cat <<'EOF'
type: Brief description

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 4. Ask About Push & PR

**Push:**
- Ask user: "Push to remote?"
- If yes: `git push`

**Check PR status:**
```bash
git log origin/main..HEAD --oneline
```
- If **empty** → All merged, no PR needed
- If **has commits** → Ask: "Create PR?"

### 5. Mark Session Clean
```bash
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

---

## Slash Commands

**Core:** `/fi`, `/commit`, `/pr`
**Dev:** `/fix`, `/feature`, `/review`, `/test`, `/security`
**Quality:** `/explain`, `/refactor`, `/optimize`
**Database:** `/db-migrate`

## Key Principles

1. **Framework as AI Extension** — not just docs, but functionality
2. **Privacy by Default** — dialogs private in .gitignore
3. **Local Processing** — no external APIs
4. **Token Economy** — minimal context loading

## Warnings

- DO NOT skip Crash Recovery check
- DO NOT commit without updating metafiles
- ALWAYS mark session clean at completion

---
*Framework: Claude Code Starter v2.2*
