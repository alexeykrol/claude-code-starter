# Claude Code Starter

Meta-framework for structured AI-assisted development with Claude Code — now with code layer!

> **⚠️ Important Note:**
> This framework is designed for **beginners practicing vibe-coding**, not professional developers. It covers a tiny fraction of AI coding agents' capabilities and will evolve and be modified as practical experience accumulates.
>
> **🎓 Created to support students of the AI Agents course for beginners:**
> - Full course: [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
> - For complete beginners: [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-2.1.0-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **🇷🇺 Русская версия:** [README_RU.md](README_RU.md)

---

## 🚀 For Users: Want to Use This Framework?

**Installation is simple - one file, 5 minutes:**

1. Download [`init-project.sh`](init-project.sh) to your project folder
2. Run: `./init-project.sh`
3. Done! Read `FRAMEWORK_GUIDE.md` in your project root

👉 **[Detailed Installation Guide →](migration/INSTALLATION_GUIDE.md)**

**What you get:**
- ✅ 85% token savings on every Claude session
- ✅ Auto-install with project detection
- ✅ Safe migration with automatic backup

---

## 🛠️ For Developers: Want to Improve This Framework?

**This README is for you!** Below you'll find technical documentation, project structure, and how to contribute.

📋 **[Full version history →](CHANGELOG.md)**

---

## 📑 Table of Contents

- [Want to Use This Framework in YOUR Project?](#-want-to-use-this-framework-in-your-project)
- [The Problem & Solution](#the-problem--solution)
- [Quick Start (for framework development)](#-quick-start)
- [Framework Structure](#-framework-structure)
- [Token Economics & ROI](#-token-economics--roi)
- [Cold Start Protocol](#-cold-start-protocol-token-optimization)
- [Philosophy: Modular Architecture](#-philosophy-modular-architecture)
- [How to Work with the Framework](#-how-to-work-with-the-framework)
- [Best Practices](#-best-practices)
- [Framework Architecture](#-framework-architecture)
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
- ✅ **Cold Start Protocol** — 85% token savings (5x cheaper!) on session reloads
- ✅ **SNAPSHOT.md** - instant project state overview
- ✅ **Modular focus** - loads only current module
- ✅ **Single source of truth** for AI and team
- ✅ **Built-in security** (SECURITY.md)
- ✅ **Slash commands** for automation (/commit, /pr, /migrate, etc.)
- ✅ **Standardized processes** — npm scripts for all operations


## 🚀 Quick Start (for framework development)

**Note:** This section is for developers who want to contribute to the framework itself. If you want to use the framework in your project, see [Installation Guide](migration/MIGRATION_GUIDE.md) above.

### Clone the repository:
```bash
git clone https://github.com/alexeykrol/claude-code-starter.git
cd claude-code-starter
```

### Install dependencies:
```bash
npm install
```

### Build the project:
```bash
npm run build
```

### Launch Claude Code:
```bash
claude
```

### Start working:
```
start
```

**Done!** The framework is ready to use.

### Available Commands

```bash
npm run build           # Compile TypeScript
npm run dialog:export   # Export dialogs to markdown
npm run dialog:ui       # Launch Web UI (localhost:3333)
npm run dialog:watch    # Auto-export watcher
npm run dialog:list     # List all sessions
```

---

## 📦 Framework Structure

```
claude-code-starter/
├── src/claude-export/      # TypeScript source code
├── dist/claude-export/     # Compiled JavaScript
├── .claude/
│   ├── commands/           # 19 slash commands
│   ├── SNAPSHOT.md         # Current project state
│   ├── ARCHITECTURE.md     # Code structure documentation
│   └── BACKLOG.md          # Tasks and roadmap
├── dialog/                 # Exported development dialogs
│
├── package.json            # npm scripts
├── tsconfig.json           # TypeScript config
├── CLAUDE.md               # AI agent protocols
├── CHANGELOG.md            # Version history
└── README.md / README_RU.md
```

### Core Components

| Component | Purpose |
|-----------|---------|
| **CLAUDE.md** | Auto-loads in Claude Code — protocols and triggers |
| **.claude/SNAPSHOT.md** | Current state for quick context loading |
| **.claude/ARCHITECTURE.md** | Code structure and design decisions |
| **.claude/BACKLOG.md** | Implementation phases and tasks |
| **src/claude-export/** | Dialog export system source code |
| **.claude/commands/** | 19 slash commands for automation |

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
- **With SNAPSHOT.md + modular focus:** ~2-3k tokens (~$0.02-0.03)
- **Result:** **~85% token savings = 5x cheaper!** 🚀

### How It Works

**Stage 1: SNAPSHOT.md - instant start (~500 tokens)**
1. AI reads SNAPSHOT.md FIRST
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

Read more in `.claude/ARCHITECTURE.md` (section "Module Architecture")

---

## 🎓 How to Work with the Framework

### Working with Claude Code

1. **Launch** `claude` in project root
2. **CLAUDE.md auto-loads** into context
3. **Ask AI to read SNAPSHOT.md** for current project state
4. **Work modularly**: one module → testing → next module

### Maintenance and Evolution

1. **Update BACKLOG.md** after each sprint
2. **Enhance ARCHITECTURE.md** with architectural decisions
3. **Expand AGENTS.md** with new patterns
4. **Use slash commands** to automate routine tasks

---

## 💡 Best Practices

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

## 📊 Framework Architecture

The framework follows a **meta-layer** approach:

```
Framework (this repo)
├── Core System
│   ├── src/claude-export/          # Dialog export engine
│   ├── dist/claude-export/         # Compiled code
│   └── package.json                # npm scripts
│
├── AI Protocols
│   ├── CLAUDE.md                   # Cold Start & Completion
│   └── .claude/
│       ├── commands/               # 19 slash commands
│       ├── SNAPSHOT.md             # Current state
│       ├── ARCHITECTURE.md         # Code structure
│       └── BACKLOG.md              # Tasks and roadmap
```

**Key principle:** Framework uses itself for development (dogfooding)

---

## 🔄 Framework Updates

The framework is alive and evolving. To get updates:

```bash
# In claude-code-starter folder
git pull origin main

# Compare changes and update your projects manually
diff CLAUDE.md your-project/CLAUDE.md
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

### v2.0.2 (Current)
- ✅ TypeScript codebase with npm project structure
- ✅ Dialog export system (CLI, Web UI, auto-watch)
- ✅ Crash recovery and completion protocols
- ✅ Summary parsing with marker system
- ✅ Privacy management (Teacher/Student UI)
- ✅ Simplified architecture

### v2.1 (In Progress)
- [ ] Auto-generate summaries for PENDING dialogs
- [ ] Enhanced Web UI with filtering and search
- [ ] Export to multiple formats (PDF, HTML)
- [ ] Migration tools for legacy projects

### v3.0 (Future)
- [ ] VS Code extension
- [ ] Multi-project workspace support
- [ ] Team collaboration features
- [ ] AI-powered insights from dialog history

---

## 💬 Questions?

If something is unclear:
1. Read `CLAUDE.md` - Cold Start and Completion protocols
2. Study `.claude/ARCHITECTURE.md` - code structure and design
3. Check `.claude/SNAPSHOT.md` - current project state
4. Open [Issue](https://github.com/alexeykrol/claude-code-starter/issues)

---

**Happy coding with Claude! 🤖✨**

*This framework turns AI-assisted development from chaos into a structured process.*
