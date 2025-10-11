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

### 🔐 Security (CRITICAL - NEVER COMPROMISE)
- ❌ **NEVER hardcode secrets** (API keys, passwords, tokens) in code
- ❌ **NEVER commit `.env` or `.env.local`** to repository
- ❌ **NEVER trust user input** - always validate and sanitize
- ❌ **NEVER use `eval()` or `new Function()`** with user data
- ❌ **NEVER expose sensitive data** in error messages or logs
- ❌ **NEVER skip input validation** on server-side (client-side is not enough!)
- ❌ **NEVER create SQL queries** with string concatenation (use parameterized)
- ❌ **NEVER disable security features** (CORS, CSRF protection, etc)
- ❌ **NEVER deploy without** running security checks (npm audit, secret scan)
- ❌ **NEVER assume data is safe** - sanitize output to prevent XSS

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
- ✅ **READ SECURITY.md** before starting ANY coding task
- ✅ **Validate ALL user input** (type, format, length, range)
- ✅ **Sanitize ALL output** (prevent XSS attacks)
- ✅ **Use environment variables** for ALL secrets (never hardcode)
- ✅ **Use parameterized queries** for database (prevent SQL injection)
- ✅ **Check authentication** before accessing protected resources
- ✅ **Check authorization** (user has permission for this action?)
- ✅ **Handle errors securely** (log internally, show generic message to user)
- ✅ **Run npm audit** before committing changes
- ✅ **Review SECURITY.md checklist** for current development stage
- ✅ **Think like an attacker** - "How could I break this?"

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
```
1. Read SECURITY.md - Review all checklists
2. Run npm audit - Fix high/critical vulnerabilities
3. Scan for secrets - grep for API keys, tokens, passwords
4. Test authentication - Try bypassing auth if applicable
5. Test authorization - Try accessing other users' data
6. Test input validation - Send malicious input (XSS, injection)
7. Review error handling - Ensure no sensitive data exposed
8. Check environment variables - All secrets server-side only
9. Verify HTTPS enforced - Production uses HTTPS
10. Complete Security Sign-Off - Use template from SECURITY.md
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
