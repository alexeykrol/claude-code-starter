# SNAPSHOT — Claude Code Starter Framework

*Last updated: 2025-12-15*

## Current State

**Version:** 2.2.2
**Status:** Production release - Automatic dependency installation
**Branch:** main

## What's New in v2.0

### Structural Changes
| Before | After |
|--------|-------|
| Docs only | Docs + Code |
| `.claude-export/` (hidden) | `src/claude-export/` (visible) |
| No package.json | Full npm project |
| No ARCHITECTURE.md | Documented code structure |

### New Files
- `package.json` — npm scripts and dependencies
- `tsconfig.json` — TypeScript configuration
- `ARCHITECTURE.md` — code documentation
- `src/claude-export/` — source code

### Removed
- `init_eng/` — will be regenerated
- `init-starter.zip` — will be regenerated
- `init-starter-en.zip` — will be regenerated
- `dev/`, `test/`, `t2.md` — temporary files
- Historical files → `archive/`

## Current Structure

```
claude-code-starter/
├── src/claude-export/     ✅ Source code
├── dist/claude-export/    ✅ Compiled
├── .claude/
│   ├── commands/          ✅ Framework commands
│   ├── SNAPSHOT.md        ✅ This file
│   ├── ARCHITECTURE.md    ✅ Code structure
│   └── BACKLOG.md         ✅ Tasks
├── dialog/                ✅ Dev dialogs
│
├── package.json           ✅ npm scripts
├── tsconfig.json          ✅ TypeScript config
├── CLAUDE.md              ✅ AI protocols
├── CHANGELOG.md           ✅ Version history
└── README.md / README_RU.md
```

## Completed Tasks (Phase 1 & 2)

- [x] Restructure to src/, dist/, package.json
- [x] Update CLAUDE.md with full protocols
- [x] Verify Cold Start Protocol
- [x] Verify Completion Protocol (/fi)
- [x] Update BACKLOG.md for v2.0.0
- [x] Remove distribution files (Init/, init_eng/, zip)
- [x] Teacher UI — Force Sync working
- [x] Student UI — template replacement fixed
- [x] Path encoding — underscore/dash variations support
- [x] Manual summaries — 6 dialogs (SUMMARY_SHORT/FULL format)
- [x] CLI testing — list, export, init, watch verified
- [x] Privacy management — Teacher UI → Student UI sync tested
- [x] **Dialog export sync bug** — fixed runExport to call syncCurrentSession
- [x] **Summary parsing** — simplified from 37 to 17 lines (-54% code)
- [x] **Marker system** — SUMMARY: PENDING/ACTIVE for generation tracking
- [x] **UI auto-refresh** — 10-second interval for data updates
- [x] **README updates** — both EN and RU versions updated for v2.0
- [x] **File reorganization** — AI metafiles moved to .claude/
- [x] **Completion Protocol** — enhanced to include README.md + README_RU.md
- [x] **Cold Start Protocol** — added Step 0.5 for closed session export
- [x] **Student UI sync** — html-viewer now updates on Cold Start (not Completion)
- [x] **CLI --no-html flag** — export without HTML generation
- [x] **CLI generate-html command** — separate HTML generation for students
- [x] **Migration system** — complete system for installing FW into projects
- [x] **Meta file templates** — SNAPSHOT, BACKLOG, ARCHITECTURE templates
- [x] **init-project.sh** — self-extracting installer (88KB)
- [x] **build-distribution.sh** — distribution package builder
- [x] **README.md restructure** — Installation integrated, "How It Works" added
- [x] **Documentation cleanup** — removed outdated file references
- [x] **dist-release/** — removed from git tracking
- [x] **Bug #2 Fix (Parasitic folders)** — watcher.ts now uses project root cwd
- [x] **sed escaping fix** — init-project.sh handles special chars in descriptions
- [x] **Token economy fix** — init-project.sh architecture redesigned (88KB → 5.3KB, 16.6x smaller!)
- [x] **Loader pattern** — init-project.sh now downloads framework.tar.gz separately from GitHub Releases
- [x] **Installation UX** — unified workflow for all scenarios (new/legacy/upgrade)
- [x] **New project setup** — CLAUDE.md handles "mode": "new" with welcome message
- [x] **Qualifying questions** — added explicit "Сделай, как лучше" option
- [x] **Migration summary** — simplified to concise message instead of large tables
- [x] **README updates** — simplified installation instructions for beginners
- [x] **Two-phase CLAUDE.md** — CLAUDE.migration.md + CLAUDE.production.md
- [x] **Migration crash recovery** — migration-log.json for interrupted migrations
- [x] **Step 0/9 migrate-legacy** — log init and CLAUDE.md swap on completion
- [x] **Step 0/8 upgrade-framework** — log init and CLAUDE.md swap on completion
- [x] **Production testing** — santacruz project successfully migrated v1.x → v2.2
- [x] **Migration reports bug fix** — Made MIGRATION_REPORT.md generation mandatory before cleanup

## Next Phase

- [ ] Create GitHub Release v2.2.0
- [ ] Announce release to users

## npm Commands

```bash
npm install              # Install dependencies
npm run build            # Compile TypeScript
npm run dialog:export    # Export dialogs
npm run dialog:ui        # Web UI :3333
npm run dialog:watch     # Auto-export
```

## Key Concept

Framework is now a **meta-layer over Claude Code** that:
1. Adds structured protocols (Cold Start, Completion)
2. Provides crash recovery
3. Enables dialog export
4. Standardizes documentation

---
*Quick-start context for AI sessions*
