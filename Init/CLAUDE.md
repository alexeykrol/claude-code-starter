# CLAUDE.md — AI Agent Instructions

**Framework:** Claude Code Starter v2.0
**Purpose:** AI-assisted development with structured documentation

## Triggers

**"заверши", "завершить", "финиш", "закончи", "done", "finish":**
→ Execute Completion Protocol (section below)

**"start", "начать":**
→ Execute Cold Start Protocol (section below)

## Cold Start Protocol

### Step 0: Crash Recovery

Check `.claude/.last_session`:
```bash
cat .claude/.last_session
```

- If `"status": "active"` → Previous session crashed:
  1. Check `git status` for uncommitted changes
  2. Check BACKLOG.md for incomplete tasks
  3. Ask: "Continue or commit first?"
- If `"status": "clean"` → OK, continue

Mark session as active:
```bash
echo '{"status": "active", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

### Step 1: Quick Status

Read `SNAPSHOT.md` — current project state, phase, progress

### Step 2: Context (on demand)

- `PROJECT_INTAKE.md` — full requirements
- `BACKLOG.md` — tasks
- `ARCHITECTURE.md` — modules structure

### Step 3: Before Code

Read `SECURITY.md` — security rules are NOT optional

### Step 4: Confirm

```
Context loaded. Directory: [pwd]
Project: [name] (Phase X, Y%)
```

## Completion Protocol

Execute on trigger words. Steps:

### 1. Build
```bash
npm run build  # or make build
```

### 2. Update Metafiles

Required:
- `BACKLOG.md` — mark completed tasks `[x]`, update progress
- `SNAPSHOT.md` — update date, phase status, next steps
- `CHANGELOG.md` — add entry

If significant changes:
- `ARCHITECTURE.md` — if architecture changed

### 3. Git Commit
```bash
git add -A
git status
git commit -m "$(cat <<'EOF'
type: Brief description

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

Commit types: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`

### 4. Ask About Push

```
Commit created. Push to remote?
```

### 5. Mark Session Clean
```bash
echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
```

## Security Rules

**Full policy:** SECURITY.md

### Principles
- **Zero Trust** — never trust user input
- **Defense in Depth** — multiple security layers
- **Fail Securely** — errors don't expose secrets

### Never Do
- Hardcode secrets in code
- Trust user input without validation
- Expose sensitive data in errors
- Use `eval()` with user input
- Disable security features (CORS, CSP)
- Commit `.env` files

### Always Do
- Validate all input (type, format, length)
- Use environment variables for secrets
- Sanitize output (prevent XSS)
- Use parameterized queries (prevent SQL injection)
- Implement rate limiting
- Use HTTPS in production

## Migration Commands

For legacy projects:
- `/migrate` — start migration (Stage 1: scan, analyze, transfer)
- `/migrate-resolve` — resolve conflicts
- `/migrate-finalize` — complete migration
- `/migrate-rollback` — revert if needed

## Project Structure

```
.claude/
├── commands/         # Slash commands
└── .last_session     # Session status

Init/ (templates)
├── CLAUDE.md         # This file (auto-loaded)
├── SNAPSHOT.md       # Project state
├── BACKLOG.md        # Tasks
├── ARCHITECTURE.md   # Code structure
├── SECURITY.md       # Security policy
├── PROJECT_INTAKE.md # Requirements intake
└── .claude-export/   # Dialog export utility
```

## Commands

### Development
```bash
make dev          # Start dev server
make build        # Build for production
make test         # Run tests
make lint         # Check code
make typecheck    # TypeScript check
```

### Dialog Export
```bash
npm run dialog:export  # Export + HTML viewer
npm run dialog:ui      # Web interface
npm run dialog:watch   # Auto-export
```

## Code Style

- ES modules (import/export)
- Strict typing, avoid `any`
- camelCase functions/variables
- PascalCase interfaces/classes
- UPPER_SNAKE_CASE constants

## Slash Commands

Available in `.claude/commands/`:

### Core
`/fix`, `/feature`, `/review`, `/test`, `/security`, `/explain`, `/refactor`, `/optimize`, `/commit`, `/pr`

### Migration
`/migrate`, `/migrate-resolve`, `/migrate-finalize`, `/migrate-rollback`

### Framework
`/release`, `/db-migrate`, `/fi`

## State Files

| File | Purpose |
|------|---------|
| `SNAPSHOT.md` | Project state for cold start |
| `BACKLOG.md` | Tasks status |
| `ARCHITECTURE.md` | Code structure |
| `PROJECT_INTAKE.md` | Requirements |
| `SECURITY.md` | Security policy |
| `.last_session` | Session status (clean/active) |

## Priorities

1. **Security** — always first
2. **Documentation** — update on changes
3. **Tests** — for critical logic
4. **Performance** — optimize bottlenecks

## Warnings

- DO NOT skip security validation
- DO NOT delete functionality without asking
- DO NOT ignore TypeScript errors
- DO NOT commit commented code
- DO NOT proceed without reading SECURITY.md

---
*Framework: Claude Code Starter v2.0 | Updated: 2025-12-07*
