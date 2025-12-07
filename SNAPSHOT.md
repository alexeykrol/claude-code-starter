# SNAPSHOT — Claude Code Starter Framework

*Last updated: 2025-12-07*

## Current State

**Version:** 2.0.0 (Released: 2025-12-07)
**Status:** PR #28 ready for merge
**Branch:** feat/framework-v2.0

## What's New in v2.0

| Change | Result |
|--------|--------|
| CLAUDE.md + PROCESS.md | → single CLAUDE.md (427→221 lines, -48%) |
| PROJECT_SNAPSHOT.md | → SNAPSHOT.md (shorter name) |
| Crash Recovery | .claude/.last_session status tracking |
| Dialog Export | .claude-export/ utility integrated |
| /fi command | Completion Protocol trigger |
| npm scripts | Auto-injection of dialog:* commands |

## Key Files Changed

```
Init/
├── CLAUDE.md           ✅ Rewritten (v2.0 format)
├── SNAPSHOT.md         ✅ Renamed from PROJECT_SNAPSHOT.md
├── PROCESS.md          ❌ Deleted (merged into CLAUDE.md)
├── .claude/
│   ├── commands/fi.md  ✅ New (completion protocol)
│   └── .last_session   ✅ New (crash recovery)
└── .claude-export/     ✅ New (dialog export utility)

init-project.sh         ✅ Updated to v2.0.0
init-starter.zip        ✅ Regenerated (316KB)
```

## Pending Tasks

- [ ] Merge PR #28 to main
- [ ] Sync init_eng/ (English version)
- [ ] Update README.md / README_RU.md
- [ ] Regenerate init-starter-en.zip

## Protocols

### Cold Start
1. Check `.claude/.last_session` for crash recovery
2. Read `SNAPSHOT.md` for current state
3. Read `BACKLOG.md` for tasks (on demand)

### Completion (triggers: "finish", "done", "заверши")
1. Build project
2. Update metafiles (BACKLOG.md, SNAPSHOT.md, CHANGELOG.md)
3. Git commit
4. Ask about push
5. Mark session clean

## Links

- **PR #28:** https://github.com/alexeykrol/claude-code-starter/pull/28
- **Repository:** https://github.com/alexeykrol/claude-code-starter

---

*This file is the quick-start context for AI sessions*
