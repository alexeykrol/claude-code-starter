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

### Step 0: Crash Recovery
```bash
cat .claude/.last_session 2>/dev/null
```
- If `"status": "active"` → Previous session crashed:
  1. `git status` — check uncommitted changes
  2. Read `.claude/SNAPSHOT.md` for context
  3. Ask: "Continue or commit first?"
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
