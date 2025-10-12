# Project Context for Claude Code

> This file is automatically loaded into the context of each Claude Code session

---

## 🤖 IMPORTANT FOR AI AGENT

**On the FIRST user message in a new session, you MUST:**

1. ✅ **Confirm context loading:**
   ```
   ✅ CLAUDE.md loaded into context
   📂 Current directory: [show pwd]
   ```

2. ✅ **Proactively read key files:**
   - `PROJECT_INTAKE.md` - project requirements
   - `BACKLOG.md` - implementation status
   - `SECURITY.md` - security rules
   - `README.md` and `spec.md` - if available

3. ✅ **Brief analysis + assumptions:**
   - What you understand about the project (2-3 sentences)
   - Which meta-files are missing (no panic)
   - Make assumptions about the project based on code

4. ✅ **Ask 2-3 CRITICAL questions:**
   - Critical = affects next actions
   - Example: "Does .env file exist? Need to check .gitignore"
   - Example: "What do you want to do now: documentation or code?"

5. ⏸️ **IMPORTANT: Say explicitly:**
   ```
   ⏸️ If you're not ready to answer now - no problem!
   I'll use my assumptions, you can correct later.
   Just type "continue" or "next" when you're ready.
   ```

6. ⏳ **WAIT for user response!**
   - Don't suggest action options immediately
   - Don't overload with information
   - If user skips answers → use assumptions and offer them for approval

**DON'T wait for user to ask - be PROACTIVE, but WITHOUT information overload!**

---

## 🔄 "Cold Start" Protocol (Session Reload)

> **Goal:** Minimize tokens when restoring context after Claude Code restart

**On FIRST message after reload read IN THIS ORDER:**

### Stage 1: Quick Status Check (~500 tokens)

1. ✅ **Read PROJECT_INTAKE.md (first 20 lines)**
   - Check: `Status`, `Migration Status`, Project Name, Elevator Pitch

   **Conditions:**
   - IF `Status` = `"[TEMPLATE..."` → New project, suggest filling
   - IF `Status` = `"✅ FILLED"` → Project filled, continue reading
   - IF `Migration Status` = `"✅ COMPLETED (date)"` → DO NOT read MIGRATION_REPORT.md
   - IF `Migration Status` = `"[NOT MIGRATED]"` → Normal, project not migrated

### Stage 2: Context Loading (~5-7k tokens)

2. ✅ **IF Status = "✅ FILLED":**
   - Read full PROJECT_INTAKE.md (understand project)
   - Read BACKLOG.md (current tasks and status)

3. ⏸️ **IF user asks to write code:**
   - Read ARCHITECTURE.md (system structure)
   - Read SECURITY.md (security rules - CRITICAL!)

### Stage 3: Never Unless Asked

4. ❌ **DO NOT read automatically:**
   - MIGRATION_REPORT.md (only if user asks or rollback)
   - WORKFLOW.md (only if user asks about processes)
   - AGENTS.md (instructions already in this file)
   - archive/* (only on request)

### 💰 Token Savings:

- **Without protocol:** ~15-20k tokens (~$0.15-0.20) - read everything
- **With protocol:** ~6-8k tokens (~$0.05-0.08) - read only needed
- **Savings:** ~60% tokens on each cold start! 🚀

---

## 🚀 Quick Start

### First things to read:
1. **PROJECT_INTAKE.md** - ⭐ START HERE - project requirements (v2.0 with User Personas, User Flows, modularity)
2. **SECURITY.md** - 🔐 CRITICAL - read before any coding!
3. **ARCHITECTURE.md** - system architecture (enriched with modularity philosophy)
4. **BACKLOG.md** - SINGLE SOURCE OF TRUTH for project status
5. **AGENTS.md** - detailed instructions for AI

### Important sections in PROJECT_INTAKE.md:
- **Problem → Solution → Value** - understanding the "why"
- **User Personas** - user portraits for empathy
- **User Flows** - step-by-step interaction scenarios
- **Unique vs Standard Features** - what to build vs what to use off-the-shelf
- **Modular Structure** - critical for token economy and cost savings!

---

## 📦 Bash Commands

### Main commands via Makefile:
```bash
make dev          # Start development server
make build        # Build project for production
make test         # Run tests
make lint         # Check code with linter
make typecheck    # TypeScript type checking
make security     # Check npm audit
```

### Git commands:
```bash
git status                    # Check status
git diff                      # View changes
git log --oneline -n 10       # Last 10 commits
gh pr create                  # Create Pull Request
gh issue view <number>        # View issue
```

---

## 🎨 Code Style

### TypeScript/JavaScript:
- Use ES modules (import/export), not CommonJS (require)
- Destructure imports where possible: `import { foo } from 'bar'`
- Type everything strictly, avoid `any`
- Use functional style where appropriate

### Naming:
- camelCase for variables and functions
- PascalCase for components and classes
- UPPER_SNAKE_CASE for constants
- Descriptive names (no abbreviations)

### File Structure:
- One component = one file
- Group related files in folders
- index.ts for folder exports

---

## 🔐 Security (CRITICAL!)

**📖 FULL POLICY:** SECURITY.md

**⚠️ ALWAYS before coding:**
1. Read SECURITY.md completely
2. Follow the checklist for current development stage (SECURITY.md → Stage X)

**Key rules (details in SECURITY.md):**
- ✅ Input validation → SECURITY.md Stage 3
- ✅ Secrets in .env → SECURITY.md "Secrets Management"
- ✅ Parameterized queries → SECURITY.md "SQL Injection Prevention"
- ❌ Never hardcode secrets → SECURITY.md "NEVER DO" section
- ❌ Never trust user input → SECURITY.md "Zero Trust"

**For AI agents:** Run `/security` for automatic audit

---

## 🏗️ Workflow

**📖 FULL DOCUMENTATION:** WORKFLOW.md

**Quick navigation:**

### Before starting a task
→ See WORKFLOW.md → "Sprint Start" section

### During development
→ See WORKFLOW.md → "Implementation" section
→ See AGENTS.md → Project-specific patterns

### After changes
→ `make typecheck && make lint`

### Sprint completion
→ See WORKFLOW.md → "Sprint Completion Checklist" (29 items!)
→ ⚠️ CRITICAL: Don't skip Security Requirements!

### Git workflow
→ See WORKFLOW.md → "Git Workflow" section
→ Commit messages: See WORKFLOW.md → "Commit Templates"

---

## 🔧 Environment Setup

### Node.js and packages:
- Node.js version: 18+ (check with `node --version`)
- Package manager: npm (or pnpm/yarn)
- After git pull always: `npm install`

### Environment Variables:
- Copy `.env.example` to `.env.local`
- NEVER commit `.env` or `.env.local`
- All secrets only in .env, not in code!

### IDE settings:
- Recommended: VS Code or similar
- TypeScript: strict mode enabled
- ESLint: autofix on save
- Prettier: format on save

---

## 📋 Important Details

### Database:
- [FILL IN: DB type, ORM, important details]
- Use migrations for schema changes
- Update TypeScript types after schema changes

### API:
- [FILL IN: REST/GraphQL/tRPC, important details]
- Always validate input data on server
- Use correct HTTP methods (GET/POST/PUT/DELETE)

### State Management:
- [FILL IN: Redux/Zustand/Context, important details]
- Follow established patterns
- Don't duplicate state

---

## 🐛 Debugging

### Common problems:

**Problem:** TypeScript errors after git pull
**Solution:**
```bash
npm install
npm run typecheck
```

**Problem:** Build fails
**Solution:**
```bash
rm -rf .next node_modules
npm install
npm run build
```

**Problem:** Environment variables not working
**Solution:**
- Check that .env.local exists
- Restart dev server
- Check that variables start with NEXT_PUBLIC_ (for client)

---

## 🎯 Priorities

1. **Security** - always first
2. **Documentation** - update every sprint
3. **Tests** - write tests for critical logic
4. **Performance** - optimize bottlenecks
5. **UX** - think about the user

---

## 📝 Slash Commands (Custom Commands)

Use slash commands for typical tasks:

- `/security` - conduct security audit
- `/test` - write tests
- `/feature` - plan new feature
- `/review` - conduct code review
- `/optimize` - optimize performance
- `/refactor` - conduct refactoring
- `/explain` - explain code
- `/fix` - find and fix bug
- `/commit` - create git commit
- `/pr` - create Pull Request
- `/migrate` - migrate legacy project to framework
- `/migrate-resolve` - interactive migration conflict resolution
- `/migrate-finalize` - finalize migration
- `/migrate-rollback` - rollback migration
- `/db-migrate` - create database migration

---

## ⚠️ Warnings

- DON'T delete existing functionality without explicit instruction
- DON'T change architectural decisions without discussion
- DON'T commit commented code (delete it)
- DON'T duplicate code - use functions/components
- DON'T ignore TypeScript errors - fix them

---

## 🔄 Integrations

### GitHub:
- Use `gh` CLI for GitHub operations
- Issues, PRs, comments - all through gh
- Automate routine with gh

### MCP servers:
- [FILL IN: list of installed MCP servers]
- Use MCP for extended functionality

---

## 📚 Useful Links

- **Project documentation:** [URL]
- **API documentation:** [URL]
- **Design system:** [URL]
- **CI/CD:** [URL]

---

## 🎓 For New Developers

1. Start by reading PROJECT_INTAKE.md
2. Study ARCHITECTURE.md to understand the system
3. Check BACKLOG.md for current tasks
4. Follow WORKFLOW.md for development processes
5. Use AGENTS.md as reference
6. Always read SECURITY.md before coding!

---

*This file is updated as the project evolves*
*Use the `#` key in Claude Code for quick instruction additions*
