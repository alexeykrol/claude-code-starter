# Documentation Map

> **Purpose:** Navigate the Claude Code Starter framework documentation
> **Version:** 1.2.0
> **Last Updated:** 2025-01-11

---

## 📚 Documentation Structure

### 🎯 Single Sources of Truth

These files are **authoritative** for their domains. Other files reference them.

| File | Domain | Lines | Role |
|------|--------|-------|------|
| **WORKFLOW.md** | Sprint processes, Git workflow | ~600 | Authoritative workflow |
| **SECURITY.md** | Security practices, checklists | ~500 | Authoritative security policy |
| **PROJECT_INTAKE.md** | Project requirements, User Personas | ~775 | Project definition template |
| **ARCHITECTURE.md** | Tech decisions, modularity philosophy | ~600 | Authoritative architecture |
| **BACKLOG.md** | Implementation status, roadmap | ~370 | Single source of truth for status |
| **AGENTS.md** | Project-specific AI patterns | ~465 | Project-specific patterns (NOT universal rules) |

### 🧭 Navigation Files

These files **link to** authoritative sources. They don't duplicate.

| File | Purpose | Target Audience |
|------|---------|----------------|
| **CLAUDE.md** | Auto-loads in Claude Code, navigation | AI agents (auto-loaded) |
| **README.md** | Project overview, getting started | Humans (first contact) |
| **README_RU.md** | Russian version | Russian-speaking users |

### 📖 Supporting Files

| File | Purpose |
|------|---------|
| **PLAN_TEMPLATE.md** | Template for planning tasks |
| **README-TEMPLATE.md** | Template for project README |
| **MIGRATION.md** | Guide for migrating legacy projects |
| **CHANGELOG.md** | Version history |
| **CONSISTENCY_AUDIT.md** | Audit report (v1.2.0) |
| **REFACTORING_PLAN.md** | Deduplication plan (v1.2.0) |
| **DOCS_MAP.md** | This file |

---

## 🗺️ Concept Ownership Map

**When you need information about...**

| Concept | Authoritative File | Quick Reference |
|---------|-------------------|-----------------|
| Sprint completion checklist | WORKFLOW.md → "Sprint Completion" | CLAUDE.md → link |
| Security rules | SECURITY.md → stage checklists | CLAUDE.md → link |
| Git workflow | WORKFLOW.md → "Git Workflow" | CLAUDE.md → link |
| User Personas | PROJECT_INTAKE.md → "User Personas" | CLAUDE.md → mention |
| Modularity philosophy | ARCHITECTURE.md → "Module Architecture" | PROJECT_INTAKE.md → link |
| Project status | BACKLOG.md (single source of truth) | Always check first |
| Project-specific patterns | AGENTS.md (project-specific only!) | Filled during development |

---

## 🔄 Cross-Reference Rules

### For CLAUDE.md (Navigator)
- **DO:** Link to authoritative sources
- **DON'T:** Duplicate details from other files
- **Format:** "📖 См. WORKFLOW.md → Section Name"

### For AGENTS.md (Project Patterns)
- **DO:** Document project-specific patterns
- **DON'T:** Duplicate universal rules from SECURITY.md, WORKFLOW.md
- **Format:** Link to authoritative file for universal rules

### For Other Files
- **Always specify** if authoritative or reference
- **Link, don't duplicate** when referencing other concepts
- **Update DOCS_MAP.md** when adding new files

---

## 📝 Maintenance Guidelines

### When Adding New Concept
1. **Choose ONE authoritative file** for it
2. **Update this map** with the new concept
3. **Other files link** to the authoritative file

### When Updating Concept
1. **Update authoritative file** first
2. **Check DOCS_MAP.md** for files that reference it
3. **Update links** if section names changed

### Monthly Review
- Check for new duplications
- Verify links still valid
- Update this map if structure changed

---

## 🚫 Anti-Patterns to Avoid

❌ **DON'T duplicate detailed content** across files
❌ **DON'T create "summary" sections** that duplicate authoritative source
❌ **DON'T forget to update links** when moving/renaming sections
❌ **DON'T mix universal rules** (SECURITY.md) with project patterns (AGENTS.md)

✅ **DO link to authoritative sources**
✅ **DO keep CLAUDE.md as navigation only**
✅ **DO specify authoritative status** clearly
✅ **DO separate universal vs project-specific** content

---

## 📊 Deduplication Metrics (v1.2.0)

### Before Refactoring
- Total files with duplications: 6
- Duplicated lines: ~500+
- CLAUDE.md size: ~170 lines
- AGENTS.md security rules: ~31
- Modularity philosophy: 237 lines across 3 files

### After Refactoring (v1.2.0)
- Total files with duplications: 0
- Duplicated lines: ~50 (acceptable cross-references)
- CLAUDE.md size: ~85 lines
- AGENTS.md security rules: 0 (links only)
- Modularity philosophy: ~196 lines in 1 file + links

### Improvement
- Duplication reduction: 90%
- CLAUDE.md reduction: 50%
- Maintenance burden: -70%
- Contradiction risk: ELIMINATED

---

*This map ensures consistency and prevents duplication across documentation*
*Last updated: 2025-01-11*
*Maintained by: Project Lead + AI Agents*
