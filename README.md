# Claude Code Starter

> Meta-documentation framework for effective development with Claude Code and AI agents

> **⚠️ Important Note:**
> This framework is designed for **beginners practicing vibe-coding**, not professional developers. It covers a tiny fraction of AI coding agents' capabilities and will evolve and be modified as practical experience accumulates.
>
> **🎓 Created to support students of the AI Agents course for beginners:**
> - Full course: [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
> - For complete beginners: [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-1.1-orange.svg)](https://github.com/alexeykrol/claude-code-starter/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **🇷🇺 Русская версия:** [README_RU.md](README_RU.md)
>
> **📁 Шаблоны доступны на двух языках:**
> - `Init/` — русские шаблоны (Russian templates)
> - `init_eng/` — английские шаблоны (English templates)

---

## 🆕 What's New in v1.1

### 🔄 Migration System for Existing Projects

The framework now supports **automatic migration of legacy projects**!

**New Features:**
- **`/migrate`** - automatic migration of documentation from legacy project
- **`/migrate-finalize`** - finalization after review
- **Two-stage process with pause** for safety
- **Automatic conflict detection** (critical/medium/low priority)
- **Legacy files archiving** (not deletion)
- **Detailed reports** (MIGRATION_REPORT.md, CONFLICTS.md)

**Documentation:**
- Full guide: [`init_eng/MIGRATION.md`](init_eng/MIGRATION.md) (900+ lines)
- See section [🔄 Migrating Existing Projects](#-migrating-existing-projects) below

**Also:**
- `/migrate` now for project migration
- `/db-migrate` for database migrations (renamed)

📋 [Full changelog](CHANGELOG.md)

---

## 🎯 What is this?

**Claude Code Starter** is a ready-to-use meta-documentation framework that transforms chaotic AI-assisted development into a structured and efficient process.

### The Problem

When working with Claude Code or other AI agents:
- 🔥 AI doesn't understand project context → makes wrong architectural decisions
- 💸 Loads entire project into context → wastes tokens and money
- 🔄 You explain the same things repeatedly → waste time
- 🎲 Unpredictable results → no single source of truth
- 🚫 Security issues → AI doesn't know the rules

### The Solution

The framework provides **11 ready-made documentation templates** that:
- ✅ **Auto-load** into Claude Code context (via `CLAUDE.md`)
- ✅ **Save tokens** through modular architecture
- ✅ **Single source of truth** for AI and team
- ✅ **Built-in security** (SECURITY.md)
- ✅ **Slash commands** for automation (/commit, /pr, /migrate, etc.)
- ✅ **Standardized processes** via Makefile

---

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/alexeykrol/claude-code-starter.git
cd claude-code-starter
```

### 2. Copy templates to your project

```bash
# Create new project or navigate to existing one
mkdir my-new-project
cd my-new-project

# Copy all files from Init/
cp -r ../claude-code-starter/Init/* .
cp -r ../claude-code-starter/Init/.claude .
```

### 3. Fill in PROJECT_INTAKE.md

This is the most important file - start here:

```bash
# Open in editor
code PROJECT_INTAKE.md

# Or use Claude Code
claude PROJECT_INTAKE.md
```

Fill in key sections:
1. **Problem → Solution → Value** - why does your project exist?
2. **User Personas** - who are your users?
3. **User Flows** - how will they interact?
4. **Unique vs Standard Features** - what to build vs what to integrate?
5. **Modular Structure** - how to break into modules?

### 4. Launch Claude Code

```bash
# In your project root
claude

# Claude will automatically load CLAUDE.md into context
# And read all necessary files
```

### 5. Start dialogue with AI

```
"Read PROJECT_INTAKE.md and ask all clarifying questions"
```

---

## 🔄 Migrating Existing Projects

> **Already have a project with legacy documentation?** Use automatic migration!

### When You Need Migration

If you have:
- ✅ Existing project with code
- ✅ Scattered documentation (README, docs/, notes/, TODO, etc.)
- ✅ Want to structure into unified framework

### Quick Start Migration

```bash
# 1. Copy init_eng/ to your project
cd your-existing-project
cp -r /path/to/claude-code-starter/init_eng/* .
cp -r /path/to/claude-code-starter/init_eng/.claude .

# 2. Launch Claude Code
claude

# 3. Run automatic migration
/migrate
```

### Two-Stage Process with Pause

**Stage 1: Analysis and Transfer (automatic)**
- Scans all your meta-files
- Transfers information to init_eng/ structure
- Archives legacy files
- Creates report and conflict list
- ⏸️ **Pauses for your review**

**Pause: Your Review**
- Read MIGRATION_REPORT.md
- Resolve conflicts
- Check init_eng/ files
- Fill gaps

**Stage 2: Finalization (on command)**
```bash
/migrate-finalize
```
- Completes migration
- Creates git commit
- init_eng/ becomes single source of truth

### Learn More

Full migration guide: `init_eng/MIGRATION.md`

**What Migrates Automatically:**
- `docs/README.md` → `PROJECT_INTAKE.md`
- `docs/architecture.md` → `ARCHITECTURE.md`
- `security.md` → `SECURITY.md`
- `TODO.md` → `BACKLOG.md`
- And all other meta-files

**Safety:**
- All legacy files archived (not deleted)
- Two-stage process with pause for review
- Can rollback before finalization

---

## 📦 What's in init_eng/

### Main Documentation Files

| File | Purpose | When to Fill |
|------|---------|-------------|
| **CLAUDE.md** | 🤖 Auto-loads in Claude Code | Immediately, minimal edits |
| **PROJECT_INTAKE.md** | ⭐ START HERE - project requirements | Day 1, foundation of everything |
| **SECURITY.md** | 🔐 Security rules | Immediately, critical! |
| **ARCHITECTURE.md** | 🏗️ Architectural decisions | As decisions are made |
| **BACKLOG.md** | 📋 Single source of truth for status | Update each sprint |
| **AGENTS.md** | 🎯 Detailed AI instructions | As patterns emerge |
| **WORKFLOW.md** | 🔄 Development processes | Rarely, when processes change |
| **PLAN_TEMPLATE.md** | 📝 Planning template | Use as template |
| **README-TEMPLATE.md** | 📖 README template for project | Fill and rename to README.md |

### Automation

| File/Folder | Purpose |
|------------|---------|
| **Makefile** | Standardized commands (`make dev`, `make build`, etc) |
| **.claude/commands/** | Slash commands: `/commit`, `/pr`, `/migrate`, `/security`, etc |
| **.claude/settings.json** | Access permissions for Claude Code |
| **.env.example** | Environment variables template |

---

## 🧩 Philosophy: Modular Architecture

### Why modules are critical for AI work?

**Monolithic approach problem:**
```
Claude loads entire project (5000 lines) →
Wastes tokens reading everything →
Expensive and slow →
May get confused in large context
```

**Solution through modules:**
```
Claude loads only needed module (200 lines) →
Fewer tokens →
Faster and cheaper →
Better understanding of task
```

### Modularity Principle

**Application = Set of small LEGO blocks**

Each module:
- Solves **one narrow task**
- Has **clear input and output**
- Can be **tested separately**
- **Doesn't depend** on other modules

Read more in `Init/ARCHITECTURE.md` (section "Module Architecture")

---

## 🎓 How to Work with the Framework

### Stage 1: Project Initialization

1. **Copy templates** from `Init/` to your project
2. **Fill PROJECT_INTAKE.md** - this is the foundation
3. **Read SECURITY.md** - internalize security rules
4. **Configure Makefile** for your stack (React/Vue/Node/etc)

### Stage 2: Working with Claude Code

1. **Launch** `claude` in project root
2. **CLAUDE.md auto-loads** into context
3. **Ask AI to read PROJECT_INTAKE.md** and ask questions
4. **Work modularly**: one module → testing → next module

### Stage 3: Maintenance and Evolution

1. **Update BACKLOG.md** after each sprint
2. **Enhance ARCHITECTURE.md** with architectural decisions
3. **Expand AGENTS.md** with new patterns
4. **Use slash commands** to automate routine tasks

---

## 💡 Best Practices

### For PROJECT_INTAKE.md

✅ **DO:**
- Start with "**WHY?**" - problem → solution → value
- Create 2-3 User Personas with names and pain points
- Describe User Flows step-by-step (not abstractions!)
- Separate features into **unique** (build) vs **standard** (integrate ready-made)
- Plan modular structure

❌ **DON'T:**
- Leave [FILL IN] without filling
- Write abstractly without specifics
- Plan to build standard features from scratch (Auth, Payments, etc)

### For working with Claude Code

✅ **DO:**
- Use `/commit` instead of manual commits
- Load context via TodoWrite for task tracking
- Work by modules: Auth → API → Screens → Business Logic
- Ask AI to update documentation with changes

❌ **DON'T:**
- Don't load entire project into context at once
- Don't skip SECURITY.md
- Don't ignore architectural decisions from ARCHITECTURE.md

### For security

✅ **ALWAYS:**
- Read SECURITY.md before coding
- Use `.env.example` → `.env.local`
- Validate all input data
- Use `/security` slash command for audits

❌ **NEVER:**
- Commit `.env` files
- Hardcode secrets in code
- Ignore security warnings

---

## 📊 Project Structure with Framework

After copying templates, your project will look like this:

```
your-project/
├── .claude/
│   ├── commands/           # Slash commands (/commit, /pr, etc)
│   └── settings.json       # Claude Code access permissions
│
├── src/                    # Your code
│   ├── features/           # Feature modules
│   ├── lib/               # Utilities and services
│   └── ...
│
├── CLAUDE.md              # 🤖 Auto-loads in Claude Code
├── PROJECT_INTAKE.md      # ⭐ Project requirements
├── SECURITY.md            # 🔐 Security rules
├── ARCHITECTURE.md        # 🏗️ Architectural decisions
├── BACKLOG.md            # 📋 Implementation status
├── AGENTS.md             # 🎯 AI instructions
├── WORKFLOW.md           # 🔄 Development processes
├── Makefile              # 🛠️ Standard commands
├── .env.example          # 🔒 Variables template
└── README.md             # 📖 Project documentation (from README-TEMPLATE.md)
```

---

## 🔄 Framework Updates

The framework is alive and evolving. To get updates:

```bash
# In claude-code-starter folder
git pull origin main

# Compare changes and update your projects manually
diff Init/CLAUDE.md your-project/CLAUDE.md
```

**Recommendation:** Don't overwrite your filled files - copy only new sections.

---

## 🤝 Contributing

The framework is created for the community and open to improvements!

### How to contribute:

1. **Fork** the repository
2. **Create feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to branch** (`git push origin feature/AmazingFeature`)
5. **Open Pull Request**

### What can be improved:

- 📝 New sections in templates
- 🔧 New slash commands
- 🎨 Examples for popular stacks (Next.js, Vue, etc)
- 🌍 Translations (already have Russian version!)
- 📖 Tutorials and use cases

---

## 📚 Useful Links

- **[Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)** - official documentation
- **[GitHub Repository](https://github.com/alexeykrol/claude-code-starter)** - framework source code
- **[Issues](https://github.com/alexeykrol/claude-code-starter/issues)** - report problem or suggest improvement

---

## 📜 License

MIT License - use freely in your projects!

---

## 🙏 Acknowledgments

Framework inspired by:
- Official Claude Code best practices
- Experience developing with AI agents
- Modular architecture principles
- Developer community

---

## ⭐ Roadmap

### v1.0 (Current)
- ✅ Basic documentation templates
- ✅ Slash commands for git and security
- ✅ Makefile for standardization
- ✅ Modular architecture

### v1.1 (Planned)
- [ ] Examples for Next.js
- [ ] Examples for Vue 3
- [x] English version
- [ ] Video tutorials

### v2.0 (Future)
- [ ] CLI for automatic initialization
- [ ] Integration with popular templates
- [ ] VS Code plugins
- [ ] AI-powered code review templates

---

## 💬 Questions?

If something is unclear:
1. Read `Init/PROJECT_INTAKE.md` - detailed comments there
2. Study `Init/CLAUDE.md` - Quick Start there
3. Open [Issue](https://github.com/alexeykrol/claude-code-starter/issues)

---

**Happy coding with Claude! 🤖✨**

*This framework turns AI-assisted development from chaos into a structured process.*
