# SNAPSHOT — Claude Code Starter Framework

*Last updated: 2025-12-07*

## Current State

**Version:** 2.0.0
**Status:** Restructuring complete
**Branch:** feat/framework-v2.0

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
├── Init/                  ✅ User templates (RU)
├── .claude/commands/      ✅ Framework commands
├── dialog/                ✅ Dev dialogs
│
├── package.json           ✅ NEW
├── tsconfig.json          ✅ NEW
├── ARCHITECTURE.md        ✅ NEW
├── CLAUDE.md              ✅ Updated
├── SNAPSHOT.md            ✅ This file
├── BACKLOG.md             ✅ Updated for v2.0
└── CHANGELOG.md           ✅
```

## Completed Tasks (Phase 1 & 2)

- [x] Restructure to src/, dist/, package.json
- [x] Update CLAUDE.md with full protocols
- [x] Verify Cold Start Protocol
- [x] Verify Completion Protocol (/fi)
- [x] Update BACKLOG.md for v2.0.0
- [x] Remove distribution files (Init/, init_eng/, zip)

## Next Phase

- [ ] Create new Init/ templates for v2.0
- [ ] init-project.sh — installation script
- [ ] README.md / README_RU.md documentation

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
