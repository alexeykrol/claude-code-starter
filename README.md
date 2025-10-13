# Claude Code Starter

Ready-to-use meta-documentation framework for structured AI-assisted development with Claude Code.

> **⚠️ Important Note:**
> This framework is designed for **beginners practicing vibe-coding**, not professional developers. It covers a tiny fraction of AI coding agents' capabilities and will evolve and be modified as practical experience accumulates.
>
> **🎓 Created to support students of the AI Agents course for beginners:**
> - Full course: [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
> - For complete beginners: [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-1.3.1-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **🇷🇺 Русская версия:** [README_RU.md](README_RU.md)
>
> **📁 Шаблоны доступны на двух языках:**
> - `Init/` — русские шаблоны (Russian templates)
> - `init_eng/` — английские шаблоны (English templates)

📋 **[Full version history →](CHANGELOG.md)**

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
- ✅ **Cold Start Protocol** - 60% token savings on session reloads
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

---

## ⚡ Cold Start Protocol: Token Optimization

### Problem: Session Reloads Waste Tokens

Every time Claude Code restarts:
- **Without protocol:** Reads ALL files → ~15-20k tokens (~$0.15-0.20)
- **With protocol:** Reads ONLY needed files → ~6-8k tokens (~$0.05-0.08)
- **Result:** **~60% token savings** on every reload! 🚀

### How It Works

**Stage 1: Quick Status Check (~500 tokens)**
1. Reads PROJECT_INTAKE.md (first 20 lines only)
2. Checks: `Status`, `Migration Status`, Project Name
3. Decides what to read next based on status

**Stage 2: Context Loading (~5-7k tokens)**
- IF project filled → Read full PROJECT_INTAKE.md + BACKLOG.md
- IF user needs code → Read ARCHITECTURE.md + SECURITY.md
- IF migration completed → **Skip MIGRATION_REPORT.md** automatically

**Stage 3: Never Unless Asked**
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
