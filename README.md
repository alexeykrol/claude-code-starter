# Claude Code Starter

Meta-framework for structured AI-assisted development with Claude Code.

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

📋 **[Full version history →](CHANGELOG.md)**

---

## Installation

### Before Installation

**Install Node.js** (if not already installed):
1. Download from https://nodejs.org/ (choose LTS version)
2. Install (just click "Next"/"Continue")
3. Restart your terminal

**Check if Node.js is installed:**
```bash
node --version
```

---

### Installation Steps

**1. Create your project folder** (if it doesn't exist yet)

**2. Download the installer file** ([init-project.sh](init-project.sh)) to the root of your project folder

**3. Open VSCode:**
   - File → Open Folder
   - Select your project folder (the one with `init-project.sh`)

**4. Open Terminal in VSCode:**
   - Menu: Terminal → New Terminal

**5. Run the installer:**
```bash
./init-project.sh
```

**Done!** The framework will install automatically.

---

### After Installation

Read how to use the framework in **FRAMEWORK_GUIDE.md** (in the root of your project).

Files in root after installation:
- `CLAUDE.md` — AI instructions
- `FRAMEWORK_GUIDE.md` — Usage guide

---

## What This Framework Does

**The Problem:**
- 🔥 AI doesn't understand project context → makes wrong decisions
- 💸 Loads entire project → wastes tokens and money
- 🔄 You explain the same things repeatedly

**The Solution:**
- ✅ **Auto-load** project context into Claude Code
- ✅ **Save 85% tokens** with Cold Start Protocol
- ✅ **Single source of truth** for AI and team
- ✅ **Slash commands** for automation (/commit, /pr, etc.)
- ✅ **Dialog export** — save conversations to markdown

---

## Problems?

**"not a git repository"** → Run: `git init && git add . && git commit -m "Initial commit"`

**"command not found"** → Make file executable: `chmod +x init-project.sh`

**"node: command not found"** → Install Node.js from https://nodejs.org/

**Other questions:** https://github.com/alexeykrol/claude-code-starter/issues

---

## License

MIT © Alexey Krol

---

*Framework version: 2.1.0 | Updated: 2025-12-08*
