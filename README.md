# Claude Code Starter

Meta-framework for structured AI-assisted development with Claude Code — now with code layer!

> **⚠️ Important Note:**
> This framework is designed for **beginners practicing vibe-coding**, not professional developers. It covers a tiny fraction of AI coding agents' capabilities and will evolve and be modified as practical experience accumulates.
>
> **🎓 Created to support students of the AI Agents course for beginners:**
> - Full course: [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
> - For complete beginners: [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-2.4.0-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **🇷🇺 Русская версия:** [README_RU.md](README_RU.md)

---

## 🚀 For Users: Want to Use This Framework?

### Before installing the framework, Node.js must be installed on your computer

1. Check if Node.js is installed by opening Terminal on your computer and entering the command:
```bash
node --version
```
If the terminal shows something like v20.19.4, or v20.4, then everything is fine - proceed directly to Framework Installation. If the terminal shows nothing or a lower version, you need to install the latest version of node.js.

**How to install Node.js** (if not already installed):
1. Download from https://nodejs.org/ (choose LTS version)

2. Install (just click "Next"/"Continue")

3. Restart your terminal and enter the command again:
```bash
node --version
```
The terminal should show the correct node.js version number.

### Installation

1. Create a project folder on your local computer (if not already created).

2. In the root of this GitHub repository, find the `init-project.sh` file, hover over it, and right-click. A menu will appear - select "Save Link As..." and specify your project folder. Make sure the `init-project.sh` file is copied to your folder. In short, your task is to save the `init-project.sh` file to the root of your project on your computer.

3. Open the project in VSCode. To do this:
   - Launch VSCode, then...
   - In the menu, click File → Open Folder
   - In the window that opens, select your project folder (where `init-project.sh` is located)
   - In the menu, click Terminal → New Terminal
   - In the terminal line, enter the command:
```bash
./init-project.sh
```

4. After init-project.sh completes, enter the command `claude` in the terminal to launch Claude Code, which will begin the installation. If you already have project code (legacy migration), Claude Code will ask clarifying questions, offering you to choose one option or another. You should select from the suggested options or choose the "Do what's best" option. If you have a new empty project - there will be no questions, the framework will immediately create templates. When the installer finishes, it will display the message "Migration complete, enter the command 'start' to launch the framework."

5. Enter the command "start", and Claude will perform a full cold start of the project. When it finishes, it will give you a brief summary of the current project state and enter waiting mode. After that, you can work on your project.

6. When you decide that your current sprint is complete, enter the `/fi` command, and Claude Code will execute the completion protocol so you can start from where you left off.

**Done!** Read `FRAMEWORK_GUIDE.md` in your project root to learn how to use the framework.

---

## 🛠️ For Developers: Want to Improve This Framework?

**This README is for you!** Below you'll find technical documentation, project structure, and how to contribute.

📋 **[Full version history →](CHANGELOG.md)**

---

## 📑 Table of Contents

- [The Problem & Solution](#the-problem--solution)
- [How It Works](#-how-it-works)
- [Quick Start (for framework development)](#-quick-start)
- [Framework Structure](#-framework-structure)
- [Token Economics & ROI](#-token-economics--roi)
- [Cold Start Protocol](#-cold-start-protocol-token-optimization)
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

**Root cause:** AI has no memory between sessions.

When you pause development for 2-3 days (or weeks), Claude forgets:
- What you already implemented
- Your architectural decisions
- Current project state and progress
- Security rules and constraints
- Module structure and dependencies

Result:
- You waste time re-explaining everything
- AI loads entire project to restore context → expensive
- Inconsistent decisions across sessions
- No single source of truth

### The Solution

The framework provides documentation templates and automation:
- ✅ **Auto-load** into Claude Code context (via `CLAUDE.md`)
- ✅ **Cold Start Protocol** — 85% token savings on session reloads
- ✅ **SNAPSHOT.md** — instant project state overview
- ✅ **BACKLOG.md** — tasks and implementation phases
- ✅ **ARCHITECTURE.md** — code structure and decisions
- ✅ **Dialog export** — save and view all development sessions
- ✅ **Slash commands** for automation (/commit, /pr, /fix, etc.)
- ✅ **Single source of truth** for AI and team
- ✅ **Standardized processes** — npm scripts for all operations

---

## 🔧 How It Works

The framework is built around two key protocols that structure your AI-assisted development workflow:

### Core Components

**CLAUDE.md** — Main instruction file that auto-loads into Claude Code:
- Contains Cold Start and Completion protocols
- Trigger commands: "start" / "начать" and "finish" / "завершить" / "/fi"
- Ensures consistent AI behavior across sessions

**SNAPSHOT.md** — Current project state file:
- Version number and current phase
- Active modules and their status
- What's completed, what's in progress
- AI reads this FIRST on every cold start

### Cold Start Protocol

**What happens when you type "start":**

1. **Crash Recovery Check** — reads `.claude/.last_session`
   - If previous session crashed → exports missed dialogs, checks git status
   - If clean → continues

2. **Export & Update** — saves previous work
   - Exports closed dialogs to `dialog/` folder
   - Generates `html-viewer/index.html` with all sessions
   - Auto-commits student UI so students see complete dialog history

3. **Mark Session Active** — prevents data loss
   - Sets session status to "active"
   - Next cold start will know to check for crashes

4. **Load Context** — reads SNAPSHOT.md
   - Current version and phase
   - Active modules only (not entire project!)
   - Saves 85% tokens by loading only what's needed

5. **Ready to Work** — AI confirms it's ready with current context

### Completion Protocol

**What happens when you type "finish" or "/fi":**

1. **Build** (if code changed) — `npm run build`

2. **Update Documentation**
   - Mark completed tasks in BACKLOG.md
   - Update version/status in SNAPSHOT.md
   - Add CHANGELOG.md entry (if release)
   - Update ARCHITECTURE.md (if structure changed)

3. **Export Dialogs** — `npm run dialog:export --no-html`
   - Saves current session to `dialog/` folder
   - Student UI will be updated on next "start"

4. **Git Commit** — structured commit with Co-Authored-By Claude

5. **Ask About Push & PR** — never pushes without permission

6. **Mark Session Clean** — sets status to "clean"
   - Next cold start will skip crash recovery

### Why This Matters

Without protocols:
- AI forgets what it was doing after restart
- You manually explain context every time
- Risk of lost work if session crashes
- Inconsistent workflow

With protocols:
- Type "start" → AI instantly knows where you left off
- Type "finish" → All work saved, documented, committed
- Crash recovery catches lost sessions
- Consistent, reproducible workflow

---

## 🚀 Quick Start (for framework development)

**Note:** This section is for developers who want to contribute to the framework itself. If you want to use the framework in your project, see [Installation Guide](#-for-users-want-to-use-this-framework) above.

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
│   ├── commands/           # Slash commands for automation
│   ├── SNAPSHOT.md         # Current project state
│   ├── ARCHITECTURE.md     # Code structure documentation
│   └── BACKLOG.md          # Tasks and roadmap
├── dialog/                 # Exported development dialogs
├── html-viewer/            # HTML file for viewing dialog history
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
| **.claude/commands/** | Slash commands for automation |
| **dialog/** | Exported development sessions (markdown) |
| **html-viewer/** | HTML file for viewing dialog history (no framework needed) |

#### ⚡ How Slash Commands Work

**Important to understand:** Slash commands in Claude Code are **prompt expansions**, not executable scripts.

**What happens when you use `/commit`:**
1. You type `/commit`
2. Claude reads `.claude/commands/commit.md` (detailed instructions)
3. Claude follows these instructions step-by-step automatically
4. You see progress as Claude executes the workflow

**Example:**
- `/commit` → Claude reads commit workflow → creates structured git commit
- `/pr` → Claude reads PR workflow → analyzes changes → creates pull request
- `/fix` → Claude reads debugging guide → helps find and fix bugs

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
- ❌ Other documentation files (only if user asks)

**See CLAUDE.md → "🔄 Cold Start Protocol" for full details**

---

## 🎓 How to Work with the Framework

The framework is a meta-layer on top of Claude Code that structures your development workflow.

### Starting a Session

1. Launch Claude Code in your project root:
   ```bash
   claude
   ```

2. Start working with the framework:
   ```
   start
   ```
   That's it! The framework handles everything automatically.

### Finishing a Session

When you complete a sprint or work session:
```
finish
```

Or use the slash command:
```
/fi
```

The framework will automatically:
- Build your code
- Update documentation
- Export dialogs
- Create git commit
- Ask about push/PR

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
- Don't ignore architectural decisions from ARCHITECTURE.md

### For security

✅ **ALWAYS:**
- Use `.env.example` → `.env.local`
- Validate all input data
- Use `/security` slash command for security audits

❌ **NEVER:**
- Commit `.env` files
- Hardcode secrets in code

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
│       ├── commands/               # Slash commands for automation
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

See detailed roadmap with all planned features and improvements: [.claude/ROADMAP.md](.claude/ROADMAP.md)

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
