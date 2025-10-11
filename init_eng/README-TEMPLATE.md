# [PROJECT_NAME]

**Version:** [0.1.0]
**Last Updated:** [DATE]

[Brief project description in 1-2 sentences]

---

## 📚 Documentation

### For Developers & AI Agents
- **[CLAUDE.md](CLAUDE.md)** - 🤖 **AUTO-LOADED** - Context for Claude Code (always read first!)
- **[PROJECT_INTAKE.md](PROJECT_INTAKE.md)** - ⭐ **START HERE** - Project requirements and context (fill before development)
- **[PLAN_TEMPLATE.md](PLAN_TEMPLATE.md)** - 📋 **CREATE PLAN.md** - Implementation plan template with security integration
- **[SECURITY.md](SECURITY.md)** - 🔐 **CRITICAL** - Security requirements for all development stages
- **[AGENTS.md](AGENTS.md)** - AI agent instructions and development guidelines
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and technical decisions
- **[BACKLOG.md](BACKLOG.md)** - Implementation status and roadmap (**SINGLE SOURCE OF TRUTH**)
- **[WORKFLOW.md](WORKFLOW.md)** - Development workflows and sprint processes

### Configuration Files
- **[Makefile](Makefile)** - Standard commands (`make dev`, `make build`, etc)
- **[.env.example](.env.example)** - Environment variables template
- **[.claude/settings.json](.claude/settings.json)** - Claude Code permissions
- **[.claude/commands/](.claude/commands/)** - Custom slash commands (`/commit`, `/pr`, `/migrate`)

### Quick Start for AI Agents
1. Read [CLAUDE.md](CLAUDE.md) - **Auto-loaded context** for Claude Code
2. Read [PROJECT_INTAKE.md](PROJECT_INTAKE.md) - **Fill this first!** Essential project context
3. Read [SECURITY.md](SECURITY.md) - **Read before ANY coding!** Security requirements
4. Read [AGENTS.md](AGENTS.md) - Core instructions and patterns
5. Read [ARCHITECTURE.md](ARCHITECTURE.md) - System design
6. Read [BACKLOG.md](BACKLOG.md) - Current status and priorities
7. Read [WORKFLOW.md](WORKFLOW.md) - Sprint processes

---

## ✨ Features

[FILL IN: Main project features]

- [✅/🚧/📋] **Feature 1** - Description
- [✅/🚧/📋] **Feature 2** - Description
- [✅/🚧/📋] **Feature 3** - Description

**Legend:**
- ✅ Completed
- 🚧 In Progress
- 📋 Planned

---

## 🛠️ Technology Stack

### Frontend
- **Framework:** [React/Vue/Angular/etc]
- **Language:** [TypeScript/JavaScript]
- **Styling:** [Tailwind CSS/etc]
- **Build:** [Vite/Webpack/etc]

### Backend & Infrastructure
- **Database:** [PostgreSQL/MongoDB/etc]
- **Auth:** [Supabase/Auth0/etc]
- **Hosting:** [Vercel/AWS/etc]

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed technical stack.

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ ([download](https://nodejs.org/))
- npm or pnpm
- [Other prerequisites]

### Installation

```bash
# 1. Clone repository
git clone [repository-url]
cd [project-name]

# 2. Install dependencies
npm install

# 3. Setup environment
cp .env.example .env.local
# Edit .env.local with your credentials

# 4. Start development server
npm run dev
```

### First Run
1. Open http://localhost:[PORT]
2. [Next steps for first time setup]

---

## 📦 Available Commands

The project uses **Makefile** to standardize commands:

### Development
```bash
make dev          # Start development server
make build        # Build for production
make start        # Start production server
```

### Quality & Testing
```bash
make lint         # Run linter
make fix-lint     # Auto-fix linting issues
make typecheck    # Check TypeScript types
make test         # Run tests
make test-watch   # Run tests in watch mode
```

### Security & Dependencies
```bash
make security     # Run npm audit
make security-fix # Auto-fix vulnerabilities
make audit        # Full check (lint + typecheck + test + security)
```

### Database (when applicable)
```bash
make db-migrate   # Run database migrations
make db-reset     # Reset database
make db-seed      # Seed with test data
```

### Utility
```bash
make install      # Install dependencies
make clean        # Clean build artifacts
make reinstall    # Reinstall all dependencies
make doctor       # Diagnose environment
make help         # Show all available commands
```

### Alternative: Direct npm commands
If you prefer npm directly:
```bash
npm run dev       # Same as make dev
npm run build     # Same as make build
# ... and so on
```

**Recommendation:** Use `make` commands - they are simpler and standardized.

---

## 🔑 Environment Variables

Create `.env.local` file in project root:

```env
# [Required variables]
VAR_NAME=your_value_here
VAR_NAME_2=your_value_here

# [Optional variables]
OPTIONAL_VAR=value
```

See `.env.example` for all available variables.

---

## 📂 Project Structure

```
[project-name]/
├── src/                  # Source code
│   ├── components/       # React components
│   ├── lib/             # Utilities and services
│   ├── hooks/           # Custom hooks
│   └── [...]
├── public/              # Static files
├── [config-files]       # Configuration files
├── AGENTS.md            # AI instructions
├── ARCHITECTURE.md      # Architecture docs
├── BACKLOG.md          # Project status
├── WORKFLOW.md         # Development process
└── README.md           # This file
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed structure.

---

## 🔐 Security

[FILL IN: Security information]

### Best Practices
- Never commit `.env` files
- Use environment variables for secrets
- [Project-specific security notes]

See [ARCHITECTURE.md](ARCHITECTURE.md#security-architecture) for security architecture.

---

## 🐛 Known Issues

See [BACKLOG.md](BACKLOG.md#known-issues) for current bugs and issues.

---

## 📝 Development Workflow

1. Check [BACKLOG.md](BACKLOG.md) for tasks
2. Create feature branch: `git checkout -b feature/your-feature`
3. Follow patterns in [AGENTS.md](AGENTS.md)
4. Complete sprint checklist in [WORKFLOW.md](WORKFLOW.md)
5. Create PR with documentation updates

See [WORKFLOW.md](WORKFLOW.md) for detailed workflow.

---

## 🤝 Contributing

[FILL IN: Contribution rules]

1. Read [AGENTS.md](AGENTS.md) for development guidelines
2. Follow [WORKFLOW.md](WORKFLOW.md) for sprint process
3. Update [BACKLOG.md](BACKLOG.md) with your changes
4. Ensure all tests pass
5. Update documentation

---

## 📋 Roadmap

See [BACKLOG.md](BACKLOG.md) for detailed roadmap and priorities.

### Next Milestones
- [ ] [Milestone 1] - [ETA]
- [ ] [Milestone 2] - [ETA]

---

## 🔄 Version History

### [0.1.0] - [DATE]
- Initial project setup
- Documentation structure
- [Initial features]

See [BACKLOG.md](BACKLOG.md#change-log) for full change history.

---

## 📞 Support

[FILL IN: Contacts and support]

- **Issues:** [GitHub Issues URL]
- **Email:** [contact@email.com]
- **Docs:** [Documentation URL]

---

## 📄 License

[FILL IN: Project license]

[License type] - See [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **[Author Name]** - [Role] - [Contact]
- [Additional contributors]

---

## 🙏 Acknowledgments

- [Credits and acknowledgments]
- Built with [Claude Code](https://claude.com/claude-code)

---

## 📝 Notes for First-Time Setup

When using this README for a new project:

1. **Replace all [FILL IN]** with actual information
2. **Update URLs** (repository, issues, documentation)
3. **Fill in Technology Stack** from actual project
4. **Add screenshots** (if needed)
5. **Specify real commands** (npm run dev → correct command)
6. **Update structure** for actual directories
7. **Delete this section** after initial setup

---

*Developed with ❤️ using [Claude Code](https://claude.com/claude-code)*
