# Claude Code Starter

> Meta-documentation framework for effective development with Claude Code and AI agents

> **⚠️ Important Note:**
> This framework is designed for **beginners practicing vibe-coding**, not professional developers. It covers a tiny fraction of AI coding agents' capabilities and will evolve and be modified as practical experience accumulates.
>
> **🎓 Created to support students of the AI Agents course for beginners:**
> - Full course: [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
> - For complete beginners: [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-1.2.4-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **🇷🇺 Русская версия:** [README_RU.md](README_RU.md)
>
> **📁 Шаблоны доступны на двух языках:**
> - `Init/` — русские шаблоны (Russian templates)
> - `init_eng/` — английские шаблоны (English templates)

---

## 🆕 What's New in v1.2.4

**NEW:** Clear protocol to initialize AI dialogue!

**After running `claude`, type:**
```
start
```

**Then AI automatically:**
- ✅ Confirms CLAUDE.md loaded into context
- ✅ Shows current directory
- ✅ Reads key files (PROJECT_INTAKE.md, BACKLOG.md, SECURITY.md)
- ✅ Analyzes project and identifies gaps
- ✅ Asks 3-5 clarifying questions
- ✅ Suggests next steps

**Why "start" command:**
Claude Code CLI waits for first user input (technical limitation). Type `start` to initialize proactive AI analysis.

📋 **[Full version history →](CHANGELOG.md)**

---

## 🎯 What is this?

**NEW:** AI agents now proactive and interactive from the first message!

**When you run `claude`, AI now automatically:**
- ✅ Confirms CLAUDE.md loaded into context
- ✅ Shows current directory
- ✅ Reads key files (PROJECT_INTAKE.md, BACKLOG.md, SECURITY.md)
- ✅ Analyzes project and identifies gaps
- ✅ Asks 3-5 clarifying questions
- ✅ Suggests next steps

**Before:** Silent auto-loading, blank prompt, user uncertain if framework active
**After:** Immediate confirmation, project analysis, interactive engagement

📋 **[Full version history →](CHANGELOG.md)**

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

> **New in v1.2.0:** Super-simple installation with smart script! Just 3 steps.

### 1. Download Files

Download from [Releases](https://github.com/alexeykrol/claude-code-starter/releases):
- **`init-starter.zip`** - Russian templates
- **`init-starter-en.zip`** - English templates
- **`init-project.sh`** - Smart installation script

### 2. Copy to Your Project

Copy both files to your project folder:
- **New project:** Create a folder and copy there
- **Existing project:** Copy to project root

```bash
# Example for new project
mkdir my-new-project
cd my-new-project
# Copy init-starter.zip and init-project.sh here
```

### 3. Run Installation

Open terminal **IN YOUR PROJECT FOLDER** and run:

```bash
bash init-project.sh
```

**That's it!** The script will:
- ✅ Ask confirmation you're in the right folder
- ✅ Extract templates
- ✅ Detect if it's a new or existing project
- ✅ **New project:** Auto-install templates
- ✅ **Legacy project:** Prepare for migration

### 4. Next Steps

After installation:

```bash
# Launch Claude Code
claude

# Initialize AI dialogue (IMPORTANT!)
start
# AI will analyze your project and guide you through next steps
```

**That's it!** AI will determine project state and suggest appropriate actions.

---

## 🔄 For Existing Projects

> **Already have a project with code and scattered documentation?**

The installation process is **exactly the same**:
1. Copy `init-starter-en.zip` and `init-project.sh` to your project root
2. Run `bash init-project.sh`
3. Launch `claude` and type `start`

**AI will guide you through migration automatically!**

Full migration guide: `init_eng/MIGRATION.md`

### Excluding Files from Migration (Optional)

**Problem:** Your project may have reference articles, meeting notes, or research documents that are NOT project meta-documentation.

**Solution:** Create `.migrationignore` (similar to `.gitignore`):

```bash
# Copy example and customize
cp init_eng/.migrationignore.example .migrationignore
```

**What to exclude:**
- Reference articles (docs/articles/, docs/references/)
- Meeting notes (notes/meeting-*.md)
- Temporary notes (notes/temp*.md)
- Research documents (research/)
- Old versions (old/, archive/)
- Binary files (*.pdf, *.docx)

**Result:**
- Excluded files stay in original location (not migrated, not archived)
- MIGRATION_REPORT.md shows what was excluded
- AI can auto-detect and suggest exclusions during `/migrate`

### Two-Stage Process with Pause

**Stage 1: Analysis and Transfer (automatic)**
- Scans all your meta-files
- Transfers information to init_eng/ structure
- Archives legacy files
- Creates report and conflict list
- ⏸️ **Pauses for your review**

**Pause: Your Review**
- Read MIGRATION_REPORT.md
- Resolve conflicts with `/migrate-resolve` (interactive AI-guided process)
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
- `/migrate-rollback` - automatic rollback at any stage

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
