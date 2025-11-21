# Claude Code Starter (test) + test2 + t3

Ready-to-use meta-documentation framework for structured AI-assisted development with Claude Code.

> **⚠️ Important Note:**
> This framework is designed for **beginners practicing vibe-coding**, not professional developers. It covers a tiny fraction of AI coding agents' capabilities and will evolve and be modified as practical experience accumulates.
>
> **🎓 Created to support students of the AI Agents course for beginners:**
> - Full course: [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
> - For complete beginners: [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-1.4.2-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **🇷🇺 Русская версия:** [README_RU.md](README_RU.md)
>
> **📁 Шаблоны доступны на двух языках:**
> - `Init/` — русские шаблоны (Russian templates)
> - `init_eng/` — английские шаблоны (English templates)

📋 **[Full version history →](CHANGELOG.md)**

---

## 📑 Table of Contents

- [The Problem & Solution](#the-problem--solution)
- [Installation](#-installation)
- [What's in init_eng/](#-whats-in-init_eng)
- [Token Economics & ROI](#-token-economics--roi)
- [Cold Start Protocol](#-cold-start-protocol-token-optimization)
- [Philosophy: Modular Architecture](#-philosophy-modular-architecture)
- [How to Work with the Framework](#-how-to-work-with-the-framework)
- [Best Practices](#-best-practices)
- [Project Structure](#-project-structure-with-framework)
- [Framework Updates](#-framework-updates)
- [Contributing](#-contributing)
- [Useful Links](#-useful-links)
- [Roadmap](#-roadmap)

---

## The Problem & Solution

### The Problem

When working with Claude Code or other AI agents:
- 🔥 AI doesn't understand project context → makes wrong architectural decisions
- 💸 Loads entire project into context → wastes tokens and money
- 🔄 You explain the same things repeatedly → waste time
- 🎲 Unpredictable results → no single source of truth
- 🚫 Security issues → AI doesn't know the rules

### The Solution

The framework provides **14 ready-made documentation templates** that:
- ✅ **Auto-load** into Claude Code context (via `CLAUDE.md`)
- ✅ **Save tokens** through modular architecture
- ✅ **Cold Start Protocol v1.4.0** - 85% token savings (5x cheaper!) on session reloads
- ✅ **PROJECT_SNAPSHOT.md** - instant project state overview
- ✅ **Modular focus** - loads only current module
- ✅ **Single source of truth** for AI and team
- ✅ **Built-in security** (SECURITY.md)
- ✅ **Slash commands** for automation (/commit, /pr, /migrate, etc.)
- ✅ **Standardized processes** via Makefile


## 🚀 Installation

1. **Download files** from [Releases](https://github.com/alexeykrol/claude-code-starter/releases):
   - `init-starter.zip` (Russian) or `init-starter-en.zip` (English)
   - `init-project.sh`

2. **Copy both files** to your project folder

3. **Run installation** (open terminal in your project folder):
   ```bash
   bash init-project.sh
   ```

4. **Launch Claude Code:**
   ```bash
   claude
   ```

5. **Exit and restart** (to load slash commands):
   ```bash
   exit
   claude
   ```

6. **Start the framework:**
   ```
   start
   ```

**Done!** AI will analyze your project and guide you through next steps.


**For projects with existing documentation:** Full migration guide in `init_eng/MIGRATION.md`

---

## 📦 What's in init_eng/

### Main Documentation Files

| File | Purpose | ✅ FOR WHAT | ❌ NOT FOR WHAT |
|------|---------|------------|----------------|
| **CLAUDE.md** | 🤖 Auto-loads in Claude Code | Navigation, quick links to other docs | ❌ Duplicating detailed rules |
| **PROJECT_INTAKE.md** | ⭐ START HERE - project requirements | User Personas, User Flows, requirements | ❌ Implementation tasks, code details |
| **SECURITY.md** | 🔐 Security best practices | Security rules, guidelines, checklists | ❌ Project-specific patterns (→ AGENTS.md) |
| **ARCHITECTURE.md** | 🏗️ WHY of architectural decisions | Technology choices, design principles, module structure | ❌ Operational checklists, current tasks |
| **BACKLOG.md** | 📋 Detailed plan + status | Implementation phases with checklists, task status, roadmap | ❌ WHY explanations (→ ARCHITECTURE.md) |
| **PROJECT_SNAPSHOT.md** | 📸 Project snapshot | Current phase, progress (%), module status - for Cold Start | ❌ Detailed tasks (→ BACKLOG.md) |
| **PROCESS.md** | 🔄 Reminders to update meta-files | Checklist for AI after each phase | ❌ Development processes (→ WORKFLOW.md) |
| **DEVELOPMENT_PLAN_TEMPLATE.md** | 📐 Planning methodology | HOW to plan modular development | ❌ Specific project plan (→ BACKLOG.md) |
| **AGENTS.md** | 🎯 Project-specific AI patterns | Patterns unique to THIS project | ❌ Universal rules (→ SECURITY.md, WORKFLOW.md) |
| **WORKFLOW.md** | 🔄 Development processes | Sprint workflows, git processes, commit templates | ❌ Project-specific patterns |
| **PLAN_TEMPLATE.md** | 📝 Planning template | Use as template for feature planning | Use as-is, fill when needed |
| **README-TEMPLATE.md** | 📖 README template for project | Fill and rename to README.md | Keep as template until ready |

### Automation

| File/Folder | Purpose |
|------------|---------|
| **Makefile** | Standardized commands (`make dev`, `make build`, etc) |
| **.claude/commands/** | Slash commands: `/commit`, `/pr`, `/migrate`, `/security`, etc |
| **.claude/settings.json** | Access permissions for Claude Code |
| **.env.example** | Environment variables template |

#### ⚡ How Slash Commands Work

**Important to understand:** Slash commands in Claude Code are **prompt expansions**, not executable scripts.

**What happens when you use `/migrate`:**
1. You type `/migrate`
2. Claude reads `.claude/commands/migrate.md` (detailed instructions)
3. Claude follows these instructions step-by-step automatically
4. You see progress as Claude executes the workflow

**Example:**
- `/migrate` → Claude reads 612-line migration guide → executes automatically
- `/commit` → Claude reads commit workflow → creates structured git commit
- `/pr` → Claude reads PR workflow → analyzes changes → creates pull request

**Key insight:** Commands ARE instructions for Claude, not shell scripts. This means:
- ✅ Claude executes them intelligently based on context
- ✅ You can interrupt and guide the process
- ✅ Commands adapt to your project structure
- ❌ They're not instant like shell commands (Claude thinks first!)

---

## 💰 Token Economics & ROI

### Understanding the Investment

**First-Time Setup (One-Time Cost):**
```
Initial framework read: ~15-20k tokens (~$0.15-0.20)
+ Project setup and template deployment
+ Optional: Legacy project migration
= One-time investment that pays for itself quickly
```

**Every Cold Start After (Ongoing Savings):**
```
Without framework: ~15-20k tokens (~$0.15) per restart
With framework: ~2-3k tokens (~$0.03) per restart
Savings per restart: ~$0.12 (80%!)
```

### ROI Calculation

**30 Cold Starts Per Month (typical for active project):**
```
Without optimization: 30 × $0.15 = $4.50/month
With framework: 30 × $0.03 = $0.90/month
---
Monthly savings: $3.60
Annual savings: $43.20 per project!
```

**Payback Period:** Just 2-3 cold starts! 🚀

**After that:** Pure savings on every session restart.

### Why Modular Focus Matters

The framework's modular approach provides continuous benefits:

✅ **Fewer Tokens** - Load only what you need (Auth module, not entire project)
✅ **Fewer Errors** - AI doesn't get confused in large context
✅ **Faster Responses** - Less to read and analyze
✅ **Better Accuracy** - Focused context = focused answers

**Example:**
- Monolithic: Load entire 5000-line project = ~8k tokens + higher error rate
- Modular: Load Auth module (200 lines) = ~1k tokens + precise answers

The investment pays for itself almost immediately, then continues saving on every session.

---

## ⚡ Cold Start Protocol: Token Optimization

### Problem: Session Reloads Waste Tokens

Every time Claude Code restarts:
- **Without optimization:** Reads ALL files → ~15-20k tokens (~$0.15-0.20)
- **With basic protocol:** Reads ONLY needed files → ~6-8k tokens (~$0.05-0.08)
- **With PROJECT_SNAPSHOT.md + modular focus:** ~2-3k tokens (~$0.02-0.03)
- **Result:** **~85% token savings = 5x cheaper!** 🚀

### How It Works

**Stage 1: PROJECT_SNAPSHOT.md - instant start (~500 tokens)**
1. AI reads PROJECT_SNAPSHOT.md FIRST
2. Sees: Phase 3 (45%), Auth Module in development
3. Loads ONLY Auth Module from BACKLOG.md and ARCHITECTURE.md
4. **~2-3k tokens instead of ~10k = 75% savings!**

**Stage 2: Modular context loading (~2-3k tokens)**
- Reads ONLY current module from BACKLOG.md
- Reads ONLY module section from ARCHITECTURE.md
- Loads ONLY current module files
- Skips other modules until needed

**Stage 3: Never Unless Asked**
- ❌ Other modules (only on request)
- ❌ MIGRATION_REPORT.md (only if user asks)
- ❌ WORKFLOW.md (only if user asks)
- ❌ archive/* (only on request)

### Automatic After Migration

When you run `/migrate-finalize`:
1. Migration Status automatically set to `✅ COMPLETED (YYYY-MM-DD)`
2. Next session AI sees this status
3. Skips reading migration report
4. **~5k tokens saved on every reload** going forward

**See CLAUDE.md → "🔄 Cold Start Protocol" for full details**

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

### Working with Claude Code

1. **Launch** `claude` in project root
2. **CLAUDE.md auto-loads** into context
3. **Ask AI to read PROJECT_INTAKE.md** and ask questions
4. **Work modularly**: one module → testing → next module

### Maintenance and Evolution

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
