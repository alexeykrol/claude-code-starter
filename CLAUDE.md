# CLAUDE.md — AI Agent Instructions

**Framework:** Claude Code Starter v2.0
**Type:** Meta-framework extending Claude Code capabilities

## Triggers

**"start", "начать":**
→ Execute Cold Start Protocol

**"заверши", "завершить", "finish", "done":**
→ Execute Completion Protocol

---

## Cold Start Protocol

### Step 0: First Launch Detection

**Check for migration context first:**
```bash
cat .claude/migration-context.json 2>/dev/null
```

If file exists, this is first launch after installation.

**Read context and route:**
- If `"mode": "legacy"` → Execute Legacy Migration workflow (see below)
- If `"mode": "upgrade"` → Execute Framework Upgrade workflow (see below)

After completing migration, delete marker:
```bash
rm .claude/migration-context.json
```

If no migration context, continue to Step 0.1 (Crash Recovery).

---

### Step 0.1: Crash Recovery
```bash
cat .claude/.last_session
```
- If `"status": "active"` → Previous session crashed:
  1. `git status` — check uncommitted changes
  2. `npm run dialog:export --no-html` — export missed dialogs
  3. Read `.claude/SNAPSHOT.md` for context
  4. Ask: "Continue or commit first?"
- If `"status": "clean"` → OK, continue to Step 0.5

### Step 0.5: Export Closed Sessions & Update Student UI
```bash
npm run dialog:export --no-html
node dist/claude-export/cli.js generate-html
git add html-viewer/index.html && git commit -m "chore: Update student UI with latest dialogs"
```
- Exports any closed sessions from previous work (without HTML generation)
- Syncs current active session (if exists)
- Generates html-viewer/index.html with ALL closed sessions (including last closed one)
- Auto-commits student UI so students see complete dialog history
- This ensures students see the most recent closed session

### Step 1: Mark Session Active
```bash
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

### Step 2: Load Context
Read `.claude/SNAPSHOT.md` — current version, what's in progress

### Step 3: Context (on demand)
- `.claude/BACKLOG.md` — current sprint tasks (always read)
- `.claude/ROADMAP.md` — strategic direction (v2.2+, always read to understand context)
- `.claude/ARCHITECTURE.md` — code structure (read if working with code)

### Step 4: Confirm
```
Context loaded. Directory: [pwd]
Framework: Claude Code Starter v2.0
Ready to work!
```

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
- `README.md` + `README_RU.md` — update if major features added
- `.claude/ARCHITECTURE.md` — update if code structure changed

### 3. Export Dialogs
```bash
npm run dialog:export --no-html
```
- Exports dialog sessions without generating html-viewer
- Student UI (html-viewer) is NOT updated here (current session still active)
- Student UI will be updated on next Cold Start (Step 0.5)

### 4. Git Commit
```bash
git add -A && git status
git commit -m "$(cat <<'EOF'
type: Brief description

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 5. Ask About Push & PR

**Push:**
- Ask user: "Push to remote?"
- If yes: `git push`

**Check PR status:**
```bash
git log origin/main..HEAD --oneline
```
- If **empty** → All merged, no PR needed
- If **has commits** → Ask: "Create PR?"

### 6. Mark Session Clean
```bash
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

---

## Repository Structure

```
claude-code-starter/
├── src/claude-export/      # Source code (TypeScript)
├── dist/claude-export/     # Compiled JavaScript
├── .claude/
│   ├── commands/           # 19 slash commands
│   ├── SNAPSHOT.md         # Current state
│   ├── ARCHITECTURE.md     # Code structure
│   └── BACKLOG.md          # Tasks
├── dialog/                 # Development dialogs
│
├── package.json            # npm scripts
├── tsconfig.json           # TypeScript config
├── CLAUDE.md               # THIS FILE
├── CHANGELOG.md            # Version history
├── README.md / README_RU.md
└── init-project.sh         # Installer (for distribution)
```

## npm Scripts

```bash
npm run build           # Compile TypeScript
npm run dialog:export   # Export dialogs to dialog/
npm run dialog:ui       # Web UI on :3333
npm run dialog:watch    # Auto-export watcher
npm run dialog:list     # List sessions
```

## Slash Commands

**Core:** `/fi`, `/commit`, `/pr`, `/release`
**Dev:** `/fix`, `/feature`, `/review`, `/test`, `/security`
**Quality:** `/explain`, `/refactor`, `/optimize`
**Installation:** `/migrate-legacy`, `/upgrade-framework`
**Legacy v1.x:** `/migrate`, `/migrate-resolve`, `/migrate-finalize`, `/migrate-rollback`

## Key Principles

1. **Framework as AI Extension** — not just docs, but functionality
2. **Privacy by Default** — dialogs private in .gitignore
3. **Local Processing** — no external APIs
4. **Token Economy** — minimal context loading

## Warnings

- DO NOT skip Crash Recovery check
- DO NOT forget `npm run build` after code changes
- DO NOT commit without updating metafiles
- ALWAYS mark session clean at completion

---

## Legacy Migration Protocol

**Triggered when:** `.claude/migration-context.json` exists with `"mode": "legacy"`

**Purpose:** Analyze existing project and generate Framework files.

**Workflow:**

1. **Read migration context:**
   ```bash
   cat .claude/migration-context.json
   ```

2. **Execute `/migrate-legacy` command:**
   - Follow instructions in `.claude/commands/migrate-legacy.md`
   - Discovery → Deep Analysis → Questions → Report → Generate Files

3. **After completion:**
   - Verify all Framework files created
   - Delete migration marker:
     ```bash
     rm .claude/migration-context.json
     ```
   - Show success summary

4. **Next session:**
   - Use normal Cold Start Protocol

---

## Framework Upgrade Protocol

**Triggered when:** `.claude/migration-context.json` exists with `"mode": "upgrade"`

**Purpose:** Migrate from old Framework version to v2.1.

**Workflow:**

1. **Read migration context:**
   ```bash
   cat .claude/migration-context.json
   ```
   Extract `old_version` field.

2. **Execute `/upgrade-framework` command:**
   - Follow instructions in `.claude/commands/upgrade-framework.md`
   - Detect Version → Migration Plan → Backup → Execute → Verify

3. **After completion:**
   - Verify migration successful
   - Delete migration marker:
     ```bash
     rm .claude/migration-context.json
     ```
   - Show success summary

4. **Next session:**
   - Use normal Cold Start Protocol with new structure

---
*Framework: Claude Code Starter v2.1.1 | Updated: 2025-12-09*
