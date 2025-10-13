# AI Agent Instructions

**Project:** [PROJECT_NAME]
**Purpose:** Meta-instructions for effective AI-assisted development
**Created:** [DATE]
**Last Updated:** [DATE]

> **Note:** This file is optimized for AI assistants (Claude Code, Cursor, Copilot, etc.) working with this codebase.

---

## 🎯 Quick Start for AI Agents

### Required Reading (in order):
1. **SECURITY.md** - Security requirements and practices (READ FIRST!)
2. **ARCHITECTURE.md** - System architecture and technical decisions
3. **BACKLOG.md** - Current implementation status and roadmap (SINGLE SOURCE OF TRUTH)
4. **README.md** - User-facing project information
5. **WORKFLOW.md** - Development processes and sprint workflow

### ⚠️ SINGLE SOURCE OF TRUTH:
**BACKLOG.md** is the ONLY authoritative source for:
- Current implementation status
- Feature priorities
- Development roadmap

### Key Files Quick Reference:
```bash
# Architecture & Planning
ARCHITECTURE.md                # System design and patterns
BACKLOG.md                     # Implementation status (SINGLE SOURCE OF TRUTH)
WORKFLOW.md                    # Development processes
README.md                      # User-facing documentation
CLAUDE.md                      # Auto-loaded context for Claude Code

# Core Application
[FILL IN: main project files]
# Example:
# src/store/useStore.ts        # State management
# src/lib/api.ts               # API service
# src/components/Main.tsx      # Main component

# Configuration
Makefile                       # Standard commands (make dev, make build, etc)
.env.example                   # Environment variables template
.claude/commands/              # Custom slash commands for Claude Code
.claude/settings.json          # Claude Code permissions
.claudeignore                  # Files to ignore in AI context
```

### 📦 Standard Commands (Makefile):
The project uses Makefile to standardize commands:

```bash
# Development
make dev          # Start development server
make build        # Build for production
make start        # Start production server

# Quality Checks
make lint         # Run code linter
make fix-lint     # Auto-fix linter issues
make typecheck    # Check TypeScript types
make test         # Run tests
make test-watch   # Tests in watch mode

# Security & Dependencies
make security     # npm audit check
make security-fix # Auto-fix vulnerabilities
make audit        # Full check (lint+typecheck+test+security)

# Database (when used)
make db-migrate   # Apply database migrations
make db-reset     # Reset database
make db-seed      # Seed with test data

# Utility
make install      # Install dependencies
make clean        # Clean build artifacts
make reinstall    # Reinstall dependencies
make doctor       # Diagnose environment
make help         # Show all commands

# Pre-commit/push checks
make pre-commit   # lint + typecheck
make pre-push     # audit + build
```

**IMPORTANT:** Always use `make <command>` instead of direct `npm run <command>`
- Makefile controls what exactly gets executed
- Easier for Claude Code to automate (via .claude/settings.json)
- Consistent commands across projects

---

## 📚 Technology Stack

### Frontend
[FILL IN: Frontend technologies]
```
- Framework: [React/Vue/Angular/Next.js/etc]
- Language: [TypeScript/JavaScript]
- State Management: [Redux/Zustand/Context/etc]
- Styling: [Tailwind/CSS Modules/Styled Components/etc]
- Build Tool: [Vite/Webpack/Next.js/etc]
```

### Backend & Infrastructure
[FILL IN: Backend technologies]
```
- Database: [PostgreSQL/MySQL/MongoDB/etc]
- Authentication: [Supabase Auth/Auth0/Firebase/etc]
- API: [REST/GraphQL/tRPC/etc]
- Hosting: [Vercel/AWS/etc]
```

### Key Dependencies
```json
{
  "[FILL IN]": "version and purpose",
}
```

---

## 🚫 NEVER DO

### Code & Architecture
- ❌ **[FILL IN: project-specific rules]**
- ❌ **Update database structure** without migration script
- ❌ **Use `any` type** without explicit justification (TypeScript projects)
- ❌ **Create multiple components in one file** (if using component approach)
- ❌ **Duplicate API calls** (especially in polling loops)
- ❌ **Ignore security best practices** (SQL injection, XSS, CSRF)

### Process & Documentation
- ❌ **Skip documentation updates** after sprint completion
- ❌ **Modify BACKLOG.md** without completing actual implementation
- ❌ **Create commits** without meaningful messages
- ❌ **Update dependencies** without testing
- ❌ **Push to main/master** without review (if team workflow requires it)

### 🔐 Security (CRITICAL - READ SECURITY.md FIRST!)

**📖 FULL SECURITY POLICY:** SECURITY.md

**BEFORE starting any coding task:**
1. Read SECURITY.md → Stage 1 (Planning)
2. Follow checklists for current stage
3. If in doubt → `/security` for audit

**Key principles (all details in SECURITY.md):**
- 🔐 Secrets management → SECURITY.md "Environment Variables"
- 🔐 Input validation → SECURITY.md Stage 3
- 🔐 SQL injection prevention → SECURITY.md "Database Security"
- 🔐 XSS prevention → SECURITY.md "Output Sanitization"

**AGENTS.md contains only project-specific security patterns!**
See "Project Security Patterns" section below for project-specific rules.

---

## ✅ ALWAYS DO

### Before Making Changes
- ✅ **Read ARCHITECTURE.md** for architectural decisions
- ✅ **Check BACKLOG.md** for current status
- ✅ **Review related documentation** before making changes
- ✅ **Test in development** environment first

### During Development
- ✅ **Use existing patterns** from codebase
- ✅ **Follow TypeScript strict mode** (type everything properly)
- ✅ **Write migration scripts** for database changes
- ✅ **Update types** after schema changes
- ✅ **Test thoroughly** before marking tasks as complete
- ✅ **Use TodoWrite tool** to track progress

### 🔐 Security (Every Single Time)

**📖 USE CHECKLISTS FROM SECURITY.md:**
- See SECURITY.md → Stage-specific checklists
- See SECURITY.md → "Security Requirements by Stage"

**Quick check:**
```bash
/security  # Run AI-guided security audit
make security  # npm audit check
```

### After Completion
- ✅ **Update BACKLOG.md** with implementation status
- ✅ **Update ARCHITECTURE.md** if architectural changes made
- ✅ **Update AGENTS.md** if new patterns/rules discovered
- ✅ **Update README.md** if user-facing changes
- ✅ **Create meaningful git commit** (see WORKFLOW.md for template)
- ✅ **Mark all TodoWrite tasks** as completed

---

## 🔧 Standard Workflows

### Database Changes
```
1. Analysis → Read current database schema/documentation
2. Planning → Create migration script
3. Testing → Apply migration in development
4. Type Update → Update TypeScript types (if applicable)
5. Documentation → Update ARCHITECTURE.md or database docs
6. Code → Implement feature using new schema
7. Sprint Completion → Update BACKLOG.md and AGENTS.md
```

### New Feature Development
```
1. Read ARCHITECTURE.md (understand patterns)
2. Check BACKLOG.md (current status)
3. Plan with TodoWrite tool
4. Implement following existing patterns
5. Test thoroughly
6. Update documentation (BACKLOG.md, AGENTS.md, README.md)
7. Create sprint completion commit
```

### Bug Fix
```
1. Diagnose root cause
2. Check if similar issue exists in AGENTS.md "Common Issues"
3. Fix following existing patterns
4. Test fix
5. Add to "Common Issues" section if applicable
6. Update version in README.md if necessary
```

### 🔐 Security Review (Before Every Deploy)

**📖 USE CHECKLIST FROM SECURITY.md:**
- See SECURITY.md → Stage 5 (Pre-Deployment)
- See SECURITY.md → "Security Sign-Off Template"

**Or use automation:**
```bash
/security  # Run AI-guided security audit
```

---

## 🏗️ Architectural Patterns

[FILL IN: Project-specific architectural decisions]

### Pattern examples to fill in:

#### State Management Pattern
**Decision:** [Redux/Zustand/Context/etc]
**Reason:**
- [Reason 1]
- [Reason 2]

**Example:**
```typescript
// Usage example
```

#### API Integration Pattern
**Decision:** [How API requests are organized]
**Reason:**
- [Reason 1]

#### File/Data Structure Pattern
**Decision:** [How data is organized]
**Reason:**
- [Reason 1]

---

## 🔐 Project Security Patterns

> **Important:** This section is for SPECIFIC security patterns for THIS project.
> General security rules see SECURITY.md

[FILL IN as project develops]

### Pattern 1: [Project-Specific Security Rule]
[Description of project-specific security pattern]

**Template:**
```markdown
### Pattern N: [Name]
**Context:** [When this applies]
**Rule:** [What to do]
**Reason:** [Why this is important for THIS project]
**Example:**
[Code example]
```

---

## 🐛 Common Issues & Solutions

[FILL IN as issues are discovered]

### Issue: [Issue Name]
**Symptom:** [Symptom description]
**Root Cause:** [Cause]
**Solution:** [Solution]
**File:** [Where to fix]

### Template for adding:
```markdown
### Issue: [Name]
**Symptom:** [What user/developer sees]
**Root Cause:** [Why it happens]
**Solution:** [How to fix]
**File:** [Where the code is]
```

---

## 📋 Task Checklists

### Adding New Feature
- [ ] Read ARCHITECTURE.md and BACKLOG.md
- [ ] Create TodoWrite task list
- [ ] Implement following existing patterns
- [ ] Write/update tests
- [ ] Update TypeScript types (if applicable)
- [ ] Update UI components
- [ ] Update BACKLOG.md status
- [ ] Update ARCHITECTURE.md (if architectural changes)
- [ ] Update README.md (if user-facing changes)
- [ ] Create sprint completion commit

### Database Schema Change
- [ ] Create migration script
- [ ] Test in development environment
- [ ] Update TypeScript types/interfaces
- [ ] Update database documentation
- [ ] Update related code
- [ ] Test all affected features
- [ ] Update ARCHITECTURE.md
- [ ] Update BACKLOG.md status
- [ ] Create sprint completion commit

### Bug Fix
- [ ] Reproduce and document bug
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Test fix thoroughly
- [ ] Check for similar issues elsewhere
- [ ] Add to "Common Issues" (if applicable)
- [ ] Update BACKLOG.md (if tracked)
- [ ] Create fix commit

---

## 🎯 Custom Slash Commands

The project includes custom slash commands to automate typical tasks:

### Main commands:
- `/security` - conduct security audit (see SECURITY.md)
- `/test` - write tests for code
- `/feature` - plan and implement new feature
- `/review` - conduct code review of recent changes
- `/optimize` - optimize code performance
- `/refactor` - help with code refactoring
- `/explain` - explain how code works
- `/fix` - find and fix bug

### New commands for workflow:
- `/commit` - create git commit with proper message
  - Analyzes changes
  - Checks for secrets
  - Creates meaningful message (why, not what)
  - Adds Co-Authored-By: Claude

- `/pr` - create Pull Request
  - Analyzes ALL commits (not just the last one!)
  - Creates detailed description
  - Includes test plan and checklist
  - Uses gh CLI

- `/migrate` - create database migration
  - Analyzes current schema
  - Creates safe migration
  - Updates TypeScript types
  - Sets up RLS policies

**Usage:**
```bash
# In Claude Code just type:
/commit
/pr
/migrate
```

---

## 🚀 Release Management (for claude-code-starter project)

> **⚠️ IMPORTANT:** This section applies **ONLY to the claude-code-starter project**
> DO NOT apply these rules to user projects!

### Proactive Release Checking

**Context:** When working with the `claude-code-starter` framework (path `/Users/alexeykrolmini/Downloads/Code/Project_init`), you MUST automatically offer creating a release after substantial changes.

**Why this matters:**
```
The framework's purpose is helping other projects not miss anything.
We ourselves shouldn't forget to update README and CHANGELOG!
("Shoemaker without shoes" problem)
```

### Definition of "Substantial Changes"

**Substantial changes include:**

1. **New features:**
   - New slash commands added to `.claude/commands/`
   - New sections in templates (Init/, init_eng/)
   - New protocols (e.g., Cold Start Protocol)
   - New documentation files

2. **Bug fixes:**
   - Critical errors fixed in commands
   - Migration logic errors fixed
   - Template errors fixed

3. **Documentation improvements:**
   - Substantial sections added to README
   - New best practices added
   - Usage examples added

**NOT substantial:**
- Typos
- Formatting without content changes
- Code comments
- Minor text edits

### Proactive Suggestion Rules

**After committing substantial changes:**

1. **Analyze recent commits:**
   ```bash
   git log --oneline -n 5
   ```

2. **Assess significance:**
   - IF new files in .claude/commands/ → Substantial
   - IF changes in Init/ templates → Substantial
   - IF new sections in README → Substantial
   - IF bugfixes in commands → Substantial

3. **Automatically suggest release:**
   ```
   ✅ Changes committed.

   🎯 Substantial changes detected:
   - [list of changes]

   💡 Recommended to create release to update CHANGELOG and README.

   Create release?
   1. Patch (X.X.N) - bugfixes, documentation
   2. Minor (X.N.0) - new features
   3. Major (N.0.0) - breaking changes

   Choose [1/2/3] or "skip":
   ```

4. **IF user chose 1/2/3:**
   - Run `/release` automatically
   - Pass selected release type

5. **IF user chose "skip":**
   - Don't suggest again in this session
   - But suggest again in next session if release not created

### Slash Command `/release`

**Purpose:** Automates release process

**What it does:**
1. Analyzes changes since last release
2. Determines release type (patch/minor/major)
3. Updates version in README.md and README_RU.md
4. Creates CHANGELOG.md entry
5. Rebuilds zip archives (init-starter.zip, init-starter-en.zip)
6. Creates release commit
7. Pushes to GitHub
8. Optionally creates GitHub Release

**Usage:**
```bash
/release
```

**When to use:**
- After completing new feature
- After fixing critical bug
- After substantial documentation changes
- Before announcing updates

### Release Check On "Cold Start"

**On session reload (Cold Start):**

1. **Read first 20 lines of README.md**
   ```bash
   head -n 20 README.md
   ```

2. **Extract current version:**
   ```markdown
   [![Version](https://img.shields.io/badge/version-1.2.5-orange.svg)]
   ```

3. **Check last commit:**
   ```bash
   git log -1 --oneline
   ```

4. **IF last commit NOT "chore: Release v..." AND there are new commits:**
   ```bash
   git log --oneline --grep="chore: Release" -1  # last release
   git log <last-release>..HEAD --oneline        # commits after release
   ```

5. **IF substantial changes found without release:**
   - Suggest creating release (see template above)
   - BUT only once, not on every message

### Integration with TodoWrite

**If working on feature/bugfix:**

1. Add to todo list:
   ```
   - Implement feature X
   - Test feature X
   - Update documentation
   - Create release  # ← Add automatically for substantial changes
   ```

2. After completing all tasks → automatically suggest `/release`

### Examples

**Example 1: New command added**
```
✅ New slash command /release created

🎯 This is substantial change:
- Added Init/.claude/commands/release.md
- Added init_eng/.claude/commands/release.md
- Updated AGENTS.md and WORKFLOW.md

💡 Recommended to create Minor release (new feature).

Create release 1.3.0? [y/n]
```

**Example 2: Critical bugfix**
```
✅ Critical error in /migrate command fixed

🎯 This is substantial change:
- Fixed 8 bugs in migrate.md
- Updated archiving logic

💡 Recommended to create Patch release.

Create release 1.2.6? [y/n]
```

### ⚠️ CRITICAL: After EVERY Commit

**MANDATORY after creating ANY commit:**

1. **Check README.md and README_RU.md:**
   - [ ] Features list reflects changes
   - [ ] Template count is accurate (e.g., "14 templates" if added 3 files)
   - [ ] Version badge is current (if release)
   - [ ] Cold Start Protocol description is accurate (% token savings)
   - [ ] "What's in Init/" table contains all new files

2. **Check CHANGELOG.md:**
   - [ ] Entry added for current version
   - [ ] All substantial changes described
   - [ ] Number of changed lines/files indicated
   - [ ] "Why This Matters" section added

**Why this is CRITICAL:**
```
The framework's purpose is helping other projects not miss anything.
We ourselves MUST NOT forget to update README and CHANGELOG!
("Shoemaker without shoes" problem v2.0)
```

**Example of what we forgot in v1.4.0:**
- ❌ README said "11 templates" instead of "14 templates"
- ❌ Features list said "60% savings" instead of "85% savings (5x cheaper!)"
- ❌ Didn't mention PROJECT_SNAPSHOT.md and modular focus in features

**How to check:**
```bash
# After each commit:
git diff HEAD~1 README.md       # Check README was updated
git diff HEAD~1 CHANGELOG.md    # Check CHANGELOG was updated
```

**Rule for AI:**
After EVERY commit AI MUST:
1. Read README.md (features section, file count)
2. Read CHANGELOG.md (latest version)
3. Verify consistency with commit
4. If inconsistent → fix immediately

---

### Checklist Before Release

Before running `/release` ensure:
- [ ] All changes committed
- [ ] Working directory clean
- [ ] New features tested
- [ ] Documentation updated
- [ ] **README.md and CHANGELOG.md verified (see above)**
- [ ] No git conflicts

---

## 🔍 Debugging Quick Reference

### [FILL IN: Project-specific debugging commands]

```bash
# Database debugging
[commands to check DB]

# API debugging
[commands to check API]

# State debugging
[commands to check state]
```

---

## 📊 Performance Guidelines

### [FILL IN: Project-specific]

**API Optimization:**
- [Rule 1]
- [Rule 2]

**Database Performance:**
- [Rule 1]
- [Rule 2]

**Frontend Performance:**
- [Rule 1]
- [Rule 2]

---

## 🚀 Code Templates

### [FILL IN: Project code templates]

#### New Component Template
```typescript
// Component template example
```

#### New API Route Template
```typescript
// API route template example
```

#### New Service Method Template
```typescript
// Service method template example
```

---

## 📝 Sprint Workflow

See **WORKFLOW.md** for detailed sprint processes, including:
- Sprint structure and phases
- Completion checklists
- Commit message templates
- Documentation update requirements

**Key Rule:** NEVER end a sprint without updating all relevant documentation files.

---

## 📋 Where to Get Checklists and Tasks

**CRITICAL for AI:**

**When user asks:**
- "Show me checklist for current phase"
- "What's left to do?"
- "What are the tasks in Sprint 1?"
- "Give me work plan"

**✅ CORRECT:**
1. Read **BACKLOG.md** → detailed plan with checklists is there
2. Show statuses: ✅ DONE / 🚧 IN PROGRESS / ⏳ TODO
3. BACKLOG.md = single source of truth for tasks
4. If architectural reference needed → then ARCHITECTURE.md

**❌ WRONG:**
- ❌ Don't read ARCHITECTURE.md for operational checklists
- ❌ ARCHITECTURE.md = reference about WHY (technologies, principles), not about WHAT to do now
- ❌ Don't generate checklist "from scratch" if BACKLOG.md exists
- ❌ Don't try to extract tasks from "Phase 1, Phase 2" sections in ARCHITECTURE.md

**Why this matters:**
If detailed tasks are stored in ARCHITECTURE.md, AI may skip nested items
due to large file size. BACKLOG.md = structured task list, AI reads all items.

**Example of correct response:**
```
User: "Show what's left to do in Sprint 1"

AI Response:
1. ✅ Reading BACKLOG.md...
2. Show "Sprint 1" section with checklists
3. Explain status of each task
4. If implementation details needed → check ARCHITECTURE.md
```

**Exception:**
If BACKLOG.md is empty/not filled → can use general plan
from ARCHITECTURE.md as fallback, but suggest user to create BACKLOG.md
with detailed tasks.

---

## 🔄 Version History

- **[DATE]:** Initial template created
- [Add entries as project evolves]

---

## 📝 Notes for Customization

When filling out this file for a specific project:

1. **Replace [FILL IN]** with actual information
2. **Delete this section** after completion
3. **Add new sections** as needed
4. **Update** after every sprint
5. **Document patterns** that emerge in the project
6. **Add to Common Issues** solved problems

---

*This file should be updated after every sprint completion*
*Goal: Maintain living documentation for effective AI-assisted development*
*Compatible with: Claude Code, Cursor, GitHub Copilot, and other AI coding assistants*
