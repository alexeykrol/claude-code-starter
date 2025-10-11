# Changelog

All notable changes to Claude Code Starter framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.1] - 2025-01-11

### Added

#### 🔄 Migration Rollback Command
- **Slash Command:**
  - `/migrate-rollback` - Rollback migration at any stage (before or after finalization)

#### Rollback Features
- **Automatic Status Detection:**
  - Detects whether migration is before or after finalization
  - Different rollback strategies for each status
- **Safety Features:**
  - Creates backup copy in `.rollback_backup/`
  - Asks for confirmation before destructive actions
  - Can be interrupted at any stage
- **Two Rollback Scenarios:**
  - **Before finalization**: Quick rollback (delete Init/, restore from archive/)
  - **After finalization**: Git-aware rollback (revert commit, restore files)
- **Restoration:**
  - Restores all legacy files from archive/
  - Deletes or restores Init/ to pre-migration state
  - Cleans up migration reports

### Changed
- Updated `CLAUDE.md` (both languages) with `/migrate-rollback` command reference
- Updated `MIGRATION.md` (both languages) with rollback section
- Updated README files with rollback safety note

### Documentation
- Added comprehensive rollback guide in `.claude/commands/migrate-rollback.md`
- Updated "Troubleshooting" section in MIGRATION.md to reference `/migrate-rollback`
- Examples of rollback scenarios and safety checks

### Why This Matters
Provides safe exit strategy from migration at any point, increasing confidence when trying the framework on existing projects.

---

## [1.1.0] - 2025-01-11

### Added

#### 🔄 Migration System for Existing Projects
- **Slash Commands:**
  - `/migrate` - Migrate legacy project to framework (Stage 1: Analysis & Transfer)
  - `/migrate-finalize` - Complete migration (Stage 2: Finalization)
  - `/db-migrate` - Database migrations (renamed from `/migrate`)

- **Documentation:**
  - `Init/MIGRATION.md` - Comprehensive migration guide (900+ lines, Russian)
  - `init_eng/MIGRATION.md` - Full English translation
  - Migration sections in README.md and README_RU.md

#### Migration Features
- **Two-Stage Process with Pause:**
  - Stage 1: Automatic scanning, analysis, conflict detection, archiving
  - Pause for manual review and conflict resolution
  - Stage 2: Finalization with git commit
- **Conflict Detection:**
  - Critical (🔴), Medium (🟡), Low (🟢) priority levels
  - Detailed conflict descriptions with resolution recommendations
- **Safety Features:**
  - All legacy files archived (not deleted)
  - Rollback possible before finalization
  - Preserves WHY from architectural decisions
- **Automated Reports:**
  - MIGRATION_REPORT.md with detailed mapping and logs
  - CONFLICTS.md with actionable conflict resolution steps

### Changed
- `/migrate` command now refers to project migration (was database migration)
- Updated CLAUDE.md (both languages) with new slash commands reference

### Use Cases
Now supports:
- ✅ New projects (copy templates and fill)
- ✅ Existing projects with legacy documentation (automatic migration)

---

## [1.0.0] - 2025-01-10

### Added

#### 🎉 Initial Release

- **Core Framework Files:**
  - `CLAUDE.md` - Auto-loads into Claude Code context
  - `PROJECT_INTAKE.md` - Project requirements with User Personas, User Flows, modularity
  - `SECURITY.md` - Security best practices
  - `ARCHITECTURE.md` - Architectural decisions with modularity philosophy
  - `BACKLOG.md` - Single source of truth for project status
  - `AGENTS.md` - Detailed instructions for AI agents
  - `WORKFLOW.md` - Development processes
  - `PLAN_TEMPLATE.md` - Planning template
  - `README-TEMPLATE.md` - README template for user projects

- **Automation:**
  - `Makefile` - Standardized commands (dev, build, test, lint, etc)
  - `.env.example` - Environment variables template
  - `.claude/settings.json` - Claude Code access permissions

- **Slash Commands:**
  - `/commit` - Create git commit with proper message
  - `/pr` - Create Pull Request with detailed description
  - `/security` - Conduct security audit
  - `/test` - Help write tests
  - `/feature` - Plan and implement new feature
  - `/review` - Conduct code review
  - `/optimize` - Optimize performance
  - `/refactor` - Help with refactoring
  - `/explain` - Explain code
  - `/fix` - Find and fix bugs
  - `/migrate` - Create database migration (later renamed to `/db-migrate`)

- **Bilingual Support:**
  - `Init/` - Russian templates (23 files)
  - `init_eng/` - English templates (23 files)
  - `README.md` - English framework documentation
  - `README_RU.md` - Russian framework documentation

- **Philosophy & Documentation:**
  - Modular architecture approach (LEGO-block principle)
  - Token economy through modularity
  - Single source of truth concept
  - Security-first approach

### Target Audience
- Beginners practicing vibe-coding
- Students of AI Agents courses
- Developers working with Claude Code and AI agents

### Features
- Auto-loading context via CLAUDE.md
- Token savings through modular architecture
- Built-in security practices
- Standardized workflows
- Custom slash commands for automation

---

## Release Notes

### Version Numbering
- **Major (X.0.0)**: Breaking changes or fundamental redesign
- **Minor (1.X.0)**: New features, backward-compatible
- **Patch (1.0.X)**: Bug fixes, documentation updates

### Links
- [GitHub Repository](https://github.com/alexeykrol/claude-code-starter)
- [Issues](https://github.com/alexeykrol/claude-code-starter/issues)
- [Releases](https://github.com/alexeykrol/claude-code-starter/releases)

### Support
Created to support students of:
- [AI Agents Full Course](https://alexeykrol.com/courses/ai_full/) (Russian)
- [Free AI Intro Course](https://alexeykrol.com/courses/ai_intro/) (Russian)

---

**Happy coding with Claude! 🤖✨**
