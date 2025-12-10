# Legacy Project Migration Protocol

**Purpose:** Analyze existing project without Framework and generate Framework files based on deep analysis.

**When to use:** Legacy project with code but no `.claude/` directory.

---

## Core Principles

1. ❌ **NEVER modify existing project files** - only create `.claude/` files
2. 🎓 **User is not technical** - explain everything in simple terms
3. 🤝 **Qualifying questions** - always provide options with clear recommendations
4. 📊 **Detailed report first** - show analysis before generating files
5. 💰 **Token transparency** - track and report token usage

---

## Step 1: Initial Context

Check if migration context exists:
```bash
cat .claude/migration-context.json 2>/dev/null
```

If exists, you're in legacy migration mode. If not, ask user to run `./init-project.sh` first.

---

## Step 2: Discovery Phase

Search for potential analog files and project info.

### 2.1 Find Documentation Files

```bash
# Search for potential analogs (max depth 3 to avoid node_modules)
find . -maxdepth 3 -type f \( \
  -name "README*" -o \
  -name "TODO*" -o \
  -name "TASKS*" -o \
  -name "BACKLOG*" -o \
  -name "ROADMAP*" -o \
  -name "ARCHITECTURE*" -o \
  -name "DESIGN*" -o \
  -name "CHANGELOG*" \
\) 2>/dev/null | grep -v node_modules | grep -v .git
```

### 2.2 Check Project Metadata

```bash
# Package info
cat package.json 2>/dev/null | head -20

# Git history
git log --oneline --all -50 2>/dev/null

# GitHub Issues (if available)
gh issue list --limit 50 --state all 2>/dev/null
```

### 2.3 Report Discovery Results

Show user what you found:
```
🔍 Discovery Results:

📁 Found Documentation:
  ✅ README.md (has roadmap section)
  ✅ TODO.md (23 tasks)
  ✅ docs/architecture.md
  ❌ CHANGELOG.md (not found)

📦 Project Info:
  • Name: [from package.json]
  • Version: [version]
  • Type: [React/Node.js/etc]

📊 History:
  • Total commits: 237
  • Recent activity: 15 commits last week
  • Contributors: 3

🐛 Issues:
  • Open: 8
  • Closed: 45
```

---

## Step 3: Deep Analysis Phase

**IMPORTANT:** Use Task tool with Explore agent for thorough analysis.

```markdown
Use Task tool:
  subagent_type: "Explore"
  thoroughness: "very thorough"
  prompt: "Analyze this project structure and identify:
    1. Main modules and their purposes
    2. Tech stack and dependencies
    3. Current development phase
    4. Key architectural patterns
    5. Active development areas from recent commits"
```

After Explore agent completes, read found documentation files:

```bash
# Read analog files in detail
cat README.md
cat TODO.md
cat docs/architecture.md
# etc for each found file
```

Synthesize findings into project understanding.

---

## Step 4: Qualifying Questions

For each ambiguity or choice point, ask using this format:

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❓ Question: [Clear question about what needs decision]

I found multiple options:

┌─ 📌 Option 1: [Name]
│
│  What it means:
│  [Simple explanation in 1-2 sentences]
│
│  Pros:
│  • [Benefit 1]
│  • [Benefit 2]
│
│  Cons:
│  • [Drawback if any]
└─

┌─ 📌 Option 2: [Name]
│
│  What it means:
│  [Simple explanation in 1-2 sentences]
│
│  Pros:
│  • [Benefit 1]
│
│  Cons:
│  • [Drawback 1]
│  • [Drawback 2]
└─

⭐ My Recommendation: Option 1

Why I recommend this:
[Clear 2-3 sentence explanation of reasoning based on analysis]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Your choice?
  • 1 - Choose Option 1
  • 2 - Choose Option 2
  • best (or press Enter) - Сделай, как лучше (Use my recommendation)
````

**Example Questions to Ask:**

1. **BACKLOG Source:**
   - Option 1: Use TODO.md (23 tasks) as base
   - Option 2: Use GitHub Issues (8 open) as base
   - Recommendation: Based on which is more complete

2. **Development Phase:**
   - Option 1: Early Development (< v1.0)
   - Option 2: Production (≥ v1.0)
   - Recommendation: Based on version number and git history

3. **Module Priority:**
   Show 5 main modules found, ask which to focus on in SNAPSHOT

4. **Documentation Approach:**
   - Option 1: Preserve existing style from found docs
   - Option 2: Use Framework standard templates
   - Recommendation: Hybrid approach

---

## Step 5: Generate Project Report

Create comprehensive analysis report and show to user BEFORE generating files.

````markdown
# 📊 Legacy Project Analysis Report

*Generated: [timestamp]*
*Token Usage: ~[estimate]k tokens*

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📦 Project Overview

| Property | Value |
|----------|-------|
| **Name** | [from package.json] |
| **Version** | [version] |
| **Tech Stack** | React 18, TypeScript, Node.js |
| **Lines of Code** | ~15,000 |
| **Development Phase** | [Early/Beta/Production] |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📁 Project Structure

```
[project-name]/
├── src/
│   ├── components/     # React components (35 files)
│   │   ├── Auth/       # Authentication UI
│   │   ├── Dashboard/  # Main dashboard
│   │   └── Common/     # Shared components
│   ├── services/       # API services (8 files)
│   │   ├── api.ts      # HTTP client
│   │   └── auth.ts     # Auth service
│   ├── utils/          # Helper functions (12 files)
│   ├── types/          # TypeScript types
│   └── index.tsx       # Entry point
├── tests/              # Test files
└── docs/               # Documentation
```

**Key Modules:**
1. **Authentication** - Login, signup, session management
2. **Dashboard** - Main user interface
3. **API Layer** - Backend communication
4. **Common Components** - Reusable UI elements
5. **Utils** - Helper functions and utilities

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 Current Development State

**Phase:** Production (v2.3.1)

**Recent Activity (last 30 days):**
- Total commits: 47
- Active areas:
  • Authentication refactoring (15 commits)
  • API v2 migration (12 commits)
  • UI improvements (20 commits)

**Active Contributors:** 3 developers

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📚 Found Documentation

### README.md ✅
- **Size:** 156 lines
- **Contains:**
  • Installation instructions
  • API documentation
  • Roadmap section (v3.0 plans)
- **Quality:** Good, well-maintained
- **Will use for:** ROADMAP.md base

### TODO.md ✅
- **Size:** 45 lines
- **Contains:** 23 active tasks
- **Categories:**
  • Bugs: 3 items
  • Features: 15 items
  • Refactoring: 5 items
- **Quality:** Up-to-date (last modified 2 days ago)
- **Will use for:** BACKLOG.md base

### docs/architecture.md ✅
- **Size:** 89 lines
- **Contains:**
  • Component hierarchy
  • State management approach
  • Missing: service layer docs
- **Quality:** Good but incomplete
- **Will use for:** ARCHITECTURE.md base

### CHANGELOG.md ❌
- **Status:** Not found
- **Impact:** Will extract version history from git log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Recommendations for Framework Files

### .claude/SNAPSHOT.md

**Based on:**
- package.json v2.3.1
- Git log (recent commits)
- README.md overview

**Will contain:**
```markdown
Current Version: 2.3.1
Development Phase: Production

Current Sprint: API v2 Migration
Progress: ~60%

Active Modules:
- Authentication (refactoring)
- API Services (v2 migration)
- Dashboard UI (improvements)

Recent Achievements:
- Completed: User profile redesign
- Completed: Database optimization
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/BACKLOG.md

**Based on:**
- TODO.md (23 tasks)
- GitHub Issues (8 open)

**Will contain:**
```markdown
## Phase: API v2 Migration
- [ ] Complete auth endpoints migration
- [ ] Update API documentation
- [ ] Add error handling for edge cases

## Priority Bugs
- [ ] Fix login redirect loop (#45)
- [ ] Resolve token refresh race condition (#48)

## Planned Features
- [ ] Add password reset flow
- [ ] Implement 2FA
...
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/ROADMAP.md

**Based on:**
- README.md roadmap section

**Will contain:**
```markdown
## v2.4 (Q1 2025)
- Complete API v2 migration
- Add 2FA support

## v3.0 (Q2 2025)
- GraphQL API layer
- Real-time notifications
- Mobile app support
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/ARCHITECTURE.md

**Based on:**
- docs/architecture.md
- Code structure analysis

**Will contain:**
```markdown
## Architecture Overview
[React + TypeScript + REST API]

## Component Hierarchy
[Detailed structure]

## Service Layer (NEW)
[Documented from code analysis]

## Data Flow
[Request → Service → API → Store → UI]
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/IDEAS.md

**Status:** Empty template

Will be used for future spontaneous ideas.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💰 Estimated Cost

**Token Usage:**
- Discovery: ~5k tokens
- Analysis: ~15k tokens
- Report generation: ~3k tokens
- File generation: ~8k tokens
**Total: ~31k tokens (~$0.09 USD)**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````

After showing report, ask:
```
✅ Ready to generate Framework files based on this analysis.

Does this analysis look correct?

Options:
1. Yes, generate files (recommended)
2. No, let me provide corrections
3. Show me the analysis for specific section first

Your choice? (1/2/3)
```

---

## Step 6: Generate Framework Files

Based on approved report, use TodoWrite to track progress:

```markdown
Create todos:
- [ ] Generate .claude/SNAPSHOT.md
- [ ] Generate .claude/BACKLOG.md
- [ ] Generate .claude/ROADMAP.md
- [ ] Generate .claude/ARCHITECTURE.md
- [ ] Generate .claude/IDEAS.md
```

For each file:
1. Mark todo as in_progress
2. Generate file using Write tool
3. Mark todo as completed
4. Show preview to user

**File Generation Guidelines:**

### SNAPSHOT.md
- Use actual version from package.json
- Reference real modules from analysis
- Include actual recent achievements from git log
- Set realistic progress percentages

### BACKLOG.md
- Extract real tasks from TODO.md/Issues
- Preserve original task descriptions
- Organize into phases based on analysis
- Link to GitHub Issues if applicable

### ROADMAP.md
- Use roadmap from README if exists
- Otherwise, infer from TODO.md categories
- Preserve user's original vision
- Add version numbers from git history

### ARCHITECTURE.md
- Document actual structure from code analysis
- Preserve existing architecture.md content
- Add missing sections (service layer, data flow)
- Use real file/folder names from project

### IDEAS.md
- Create empty template
- Can optionally add "rejected" ideas from old TODO comments

---

## Step 7: Final Verification

After generating all files, run verification:

```bash
# Check all files created
ls -lh .claude/

# Show file sizes
du -sh .claude/*.md

# Quick content preview
head -5 .claude/SNAPSHOT.md
head -5 .claude/BACKLOG.md
head -5 .claude/ROADMAP.md
```

---

## Step 8: Migration Summary

Show simple completion message:

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Миграция завершена!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Framework Files Created:

  ✅ .claude/SNAPSHOT.md
  ✅ .claude/BACKLOG.md
  ✅ .claude/ROADMAP.md
  ✅ .claude/ARCHITECTURE.md
  ✅ .claude/IDEAS.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Analysis Summary:

  • Files analyzed: [count]
  • Token usage: ~[count]k tokens (~$[cost] USD)
  • Your existing files: ✅ NOT modified

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Next Step:

  Введите команду "start" или "начать", чтобы фреймворк запустился.
  (Type "start" or "начать" to launch the framework)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````

---

## Error Handling

### If discovery finds no documentation:

```
⚠️ Warning: No existing documentation found

I can still create Framework files, but they will be based primarily on:
- Code structure analysis
- Git history
- package.json metadata

Options:
1. Continue with code-based analysis (will be less detailed)
2. Cancel and let you create basic docs first (README, TODO)

Recommendation: Option 1 - Framework can help you build docs

Your choice?
```

### If analysis is incomplete:

```
⚠️ Analysis incomplete

Could not access:
- GitHub Issues (gh command not available)
- Some files (permission denied)

What I was able to analyze:
- Project structure: ✅
- README.md: ✅
- TODO.md: ✅
- Git history: ✅

Continue with partial analysis? (y/N)
```

### If token budget concerns:

```
⚠️ Large project detected

Estimated token usage: ~50k tokens (~$0.15 USD)

This is higher than typical because:
- Large codebase (30k+ lines)
- Many documentation files
- Long git history

Options:
1. Continue with full analysis (recommended for quality)
2. Use quick analysis (skip detailed code analysis, ~20k tokens)

Your choice?
```

---

## Important Notes

- **Never modify existing project files**
- **Always explain in simple terms**
- **Always provide recommendations, not just options**
- **Track token usage and report at end**
- **Show report before generating files**
- **Use TodoWrite to track generation progress**
- **Verify all files created successfully**

---

*This protocol ensures high-quality Framework integration into existing projects while preserving all original work.*
