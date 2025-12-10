# CLAUDE.md — Migration Mode

**Framework:** Claude Code Starter v2.2
**Mode:** Migration (temporary — will be replaced after migration completes)

---

## Step 0: Migration Recovery Check

**First, check for interrupted migration:**
```bash
cat .claude/migration-log.json 2>/dev/null
```

### If migration-log.json exists:

**status: "in_progress"** → Previous migration was interrupted
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Migration Interrupted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Previous migration was interrupted at step: [current_step_name]

Completed steps:
[list steps_completed]

Options:
1. Continue from step [X] (Recommended)
2. Restart migration from beginning
3. Cancel and keep current state
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**status: "completed"** → Migration finished but swap didn't happen
→ Execute swap automatically:
```bash
cp .claude/CLAUDE.production.md CLAUDE.md
rm .claude/CLAUDE.production.md
rm .claude/migration-log.json
rm .claude/migration-context.json 2>/dev/null
```
→ Show: "Migration recovered. Ready to work!"

**status: "failed"** → Show error and options to retry or cancel

### If migration-log.json does not exist:

Continue to Step 1.

---

## Step 1: Check Migration Context

```bash
cat .claude/migration-context.json 2>/dev/null
```

**If file exists:**
- `"mode": "legacy"` → Execute Legacy Migration (see below)
- `"mode": "upgrade"` → Execute Framework Upgrade (see below)

**If file does not exist:**
→ Error: No migration context found
→ Show: "Run init-project.sh first to set up migration"

---

## Legacy Migration Protocol

**Triggered when:** `migration-context.json` has `"mode": "legacy"`

**Purpose:** Analyze existing project and generate Framework files.

### Initialize Migration Log

```bash
echo '{
  "status": "in_progress",
  "mode": "legacy",
  "started": "'$(date -Iseconds)'",
  "updated": "'$(date -Iseconds)'",
  "current_step": 1,
  "current_step_name": "discovery",
  "steps_completed": [],
  "last_error": null
}' > .claude/migration-log.json
```

### Execute Migration

Run `/migrate-legacy` command which will:
1. Discovery — find existing files
2. Analysis — deep project analysis
3. Questions — ask qualifying questions
4. Report — generate analysis report
5. Generate — create meta files (SNAPSHOT, BACKLOG, ROADMAP, ARCHITECTURE, IDEAS)
6. Install — extract remaining framework files
7. Verify — check all files created
8. Complete — swap CLAUDE.md to production version

Each step updates `.claude/migration-log.json` with progress.

### On Completion

The `/migrate-legacy` command will:
```bash
# Mark completed
# Swap CLAUDE.md
cp .claude/CLAUDE.production.md CLAUDE.md
# Cleanup
rm .claude/CLAUDE.production.md
rm .claude/migration-log.json
rm .claude/migration-context.json
```

---

## Framework Upgrade Protocol

**Triggered when:** `migration-context.json` has `"mode": "upgrade"`

**Purpose:** Migrate from old Framework version to v2.2.

### Initialize Migration Log

```bash
echo '{
  "status": "in_progress",
  "mode": "upgrade",
  "old_version": "[from migration-context.json]",
  "started": "'$(date -Iseconds)'",
  "updated": "'$(date -Iseconds)'",
  "current_step": 1,
  "current_step_name": "detect",
  "steps_completed": [],
  "last_error": null
}' > .claude/migration-log.json
```

### Execute Migration

Run `/upgrade-framework` command which will:
1. Detect — determine old version
2. Read — read existing files
3. Plan — create migration plan
4. Backup — create backup
5. Execute — perform migration
6. Install — extract remaining framework files
7. Verify — check migration success
8. Complete — swap CLAUDE.md to production version

Each step updates `.claude/migration-log.json` with progress.

### On Completion

The `/upgrade-framework` command will:
```bash
# Mark completed
# Swap CLAUDE.md
cp .claude/CLAUDE.production.md CLAUDE.md
# Cleanup
rm .claude/CLAUDE.production.md
rm .claude/migration-log.json
rm .claude/migration-context.json
```

---

## Error Handling

If any step fails:
1. Update migration-log.json with `"status": "failed"` and `"last_error"`
2. Show error message with options:
   - Retry current step
   - Skip step (if safe)
   - Cancel migration

---

*Framework: Claude Code Starter v2.2 — Migration Mode*
