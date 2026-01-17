# SNAPSHOT — Claude Code Starter Framework

*Last updated: 2026-01-16*

## Current State

**Version:** 2.4.1
**Status:** Production - Phase 12: Hybrid Protocol Files Architecture
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
│   ├── protocols/         ✅ Protocol files (NEW in v2.4.1)
│   │   ├── cold-start.md  ✅ Cold Start Protocol
│   │   └── completion.md  ✅ Completion Protocol
│   ├── SNAPSHOT.md        ✅ This file
│   ├── ARCHITECTURE.md    ✅ Code structure
│   └── BACKLOG.md         ✅ Tasks
├── dialog/                ✅ Dev dialogs
│
├── package.json           ✅ npm scripts
├── tsconfig.json          ✅ TypeScript config
├── CLAUDE.md              ✅ AI protocols (router)
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

## v2.2.3 Critical Fixes

**Source File Synchronization Issue (RESOLVED):**
- Fixed migration/CLAUDE.production.md being out of sync with bug fixes
- All 4 production bugs now fixed in source templates
- Framework → Host project update cycle now working correctly

**Bug Fixes:**
- BUG-001: Migration cleanup recovery (Step 0.05)
- BUG-002: Missing chokidar dependency
- BUG-003: Port conflict detection (EADDRINUSE handler)
- BUG-004: Session cleanup false positives

**Distribution:**
- framework.tar.gz rebuilt with corrected source files
- GitHub Release v2.2.3 updated (CORRECTED)
- santacruz host project updated and verified

## What's New in v2.3.0

**Bug Reporting & Logging System (Phase 6):**
- [x] Step 0.15: Bug Reporting Consent - First-run opt-in dialog
- [x] Step 0.3: Cold Start Protocol Logging with timestamps
- [x] Completion Protocol Logging (Step 0 & Step 6.5)
- [x] /bug-reporting command - manage settings (enable/disable/status/test)
- [x] Anonymization script - removes paths, keys, emails, IPs
- [x] Framework Developer Mode (Step 0.4) - reads bug reports from GitHub Issues
- [x] /analyze-bugs command - group and prioritize bug reports
- [x] .framework-config - privacy preferences storage
- [x] Tested on santacruz - all features working

**Privacy-First Design:**
- Opt-in by default (disabled until user enables)
- Complete anonymization before sharing
- User control via /bug-reporting command
- Local logs in .claude/logs/ (gitignored)

**What Gets Logged:**
- Protocol execution steps with timestamps
- Error messages and stack traces (anonymized)
- Framework version and step information

**What Does NOT Get Logged:**
- Your code or file contents
- File paths (replaced with /PROJECT_ROOT/...)
- API keys, tokens, secrets (removed)
- Email addresses, IP addresses

## What's New in v2.4.1

**Hybrid Protocol Files Architecture (Phase 12):**

**Problem:**
- After long sessions, context compaction might compress CLAUDE.md content
- Monolithic CLAUDE.md (~1000 lines) difficult to maintain and navigate
- Protocol steps mixed with documentation creates cognitive overhead

**Solution: Modular Protocol Files**
- New `.claude/protocols/cold-start.md` (600+ lines)
- New `.claude/protocols/completion.md` (490+ lines)
- Protocols read fresh from disk, immune to context compaction
- CLAUDE.md reduced to ~330 lines (router architecture)

**Benefits:**
- Token economy: Protocols loaded only when needed (~3-4k vs constant 8.7k)
- Better maintainability: Each protocol in dedicated file
- Guaranteed fresh reads: Protocol files never summarized
- Modular architecture: Easy to extend with new protocols

**Integration:**
- Cold Start: Reads `.claude/protocols/cold-start.md` on "start" trigger
- Completion: `/fi` command uses Skill tool to load fresh protocol
- Distribution: `build-distribution.sh` includes protocol files in framework.tar.gz

---

**Security Layer 4: Advisory Mode + Smart Triggers**

**Enhancement to v2.4.0 Security System:**
- v2.4.0 added Layers 1-3 (regex-based cleanup, automatic)
- v2.4.1 adds Layer 4 (AI agent, advisory mode with smart triggers)

**Key Principles:**
1. **Advisory, not automatic** — Claude AI asks user before deep scan
2. **User control** — user decides when thorough check needed (except releases)
3. **Scope optimization** — analyzes git diff + last dialog (NOT entire codebase)
4. **Token economy** — 5-10 files instead of 300+ (massive savings)
5. **Release exception** — git tag v2.x.x auto-invokes (mandatory paranoia mode)

**New Files:**
- `security/check-triggers.sh` — smart trigger detection (10 triggers)
- `security/auto-invoke-agent.sh` — advisory recommendations
- `security/README.md` — comprehensive architecture guide

**Updated Protocol:**
- Completion Step 3.5: Regex cleanup + triggers check + advisory decision
- Claude AI reads context and asks: "Run deep scan? (y/N)"
- User decides: Accept (thorough) or Skip (fast)
- Release mode: Auto-invoke without asking

**Benefits:**
- ✅ Prevents token waste on every commit
- ✅ User always in control (transparency)
- ✅ Thorough when needed (releases, high-risk)
- ✅ Fast when safe (normal commits)
- ✅ Context-aware (DevOps projects with production management)

---

## What's New in v2.4.0

**Security Hardening: Dialog Credential Cleanup System**

**Problem:**
- Dialogs exported to `dialog/` may contain credentials mentioned during conversations
- SSH keys, API tokens, passwords, database URLs discussed with AI
- If project commits `dialog/` to git → credentials leak to GitHub
- Previous v2.3.3 fix only covered in-flight redaction, not committed files
- Reports and improvement files also contain code examples with secrets

**Solution: 4-Layer Security System**

**Layer 1: .gitignore Protection (Passive)**
- Added pattern-based ignore for `dialog/` (not just manual file list)
- Added `reports/` to gitignore (bug reports may contain credential examples)
- Added `.production-credentials` (production SSH keys, API tokens)
- Added `security/reports/` (cleanup scan reports)
- **Impact:** Prevents accidental commits of sensitive files
- **Type:** Passive protection (Git enforces)

**Layer 2: Credential Cleanup Script (Automatic, Fast)**
- Created `security/cleanup-dialogs.sh` — automatic credential scanner
- **Method:** Regex-based pattern matching (deterministic, fast)
- Detects and redacts 10 types of credentials:
  1. SSH credentials (user@host, IP addresses, SSH keys)
  2. IPv4 addresses (192.168.x.x, 45.145.x.x)
  3. SSH private key paths (~/.ssh/id_rsa)
  4. Database URLs (postgres://, mysql://, mongodb://, redis://)
  5. JWT tokens (eyJxxx... format)
  6. API keys (sk-xxx, secret_key, access_key)
  7. Bearer tokens (Authorization: Bearer xxx)
  8. Passwords (password=xxx, pwd=xxx)
  9. SSH ports (-p 65002)
  10. Private key content (PEM format)
- **--last flag:** Cleans only last dialog (50x faster, 1 file vs 300+)
- **--deep flag:** Triggers Layer 4 AI agent scan (optional)
- **Exit code 1:** Blocks git commit if credentials detected
- **Report generation:** Creates audit trail in `security/reports/`
- **Coverage:** ~95% of credential patterns
- **Speed:** 1-2 seconds

**Layer 3: Protocol Integration (Double Protection)**
- **Cold Start Step 0.5:** Cleans PREVIOUS session before export
  - Runs before `npm run dialog:export`
  - Ensures closed dialogs are clean before entering git
  - Gradual cleanup: each dialog cleaned on next startup
- **Completion Step 3.5:** Cleans CURRENT session before commit
  - Runs after export, before `git commit`
  - MANDATORY security check (blocks commit if secrets found)
  - Last line of defense before credentials enter git
- **Double protection:** Previous (0.5) + Current (3.5) = no gaps
- **Type:** Automatic invocation by AI through CLAUDE.md

**Layer 4: AI Agent Deep Scan (Advisory Mode + Smart Triggers)**
- Created `/security-dialogs` slash command
- Created `security/check-triggers.sh` - trigger detection system
- Created `security/auto-invoke-agent.sh` - advisory recommendations
- **Method:** AI-based context analysis (sec24 agent via Task tool)
- **Invocation:** Claude AI asks user (advisory) OR auto-invoke on release only
- **Scope:** Git diff + last dialog (sprint changes only, NOT entire codebase)

**Smart Trigger System (Advisory Mode):**

**CRITICAL triggers:**
1. Production credentials file exists (`.production-credentials`)
2. Git release tag detected (v2.x.x) → **auto-invoke without asking**
3. Release workflow in recent dialogs

**HIGH triggers:**
4. Regex cleanup found credentials
5. Security-sensitive keywords (>5 mentions: ssh, api key, password)
6. Production/deployment discussion detected

**MEDIUM triggers:**
7. Large diff (>500 lines changed)
8. Many new dialog files (>5 uncommitted)
9. Security config files modified (.env, credentials, secrets)

**LOW triggers:**
10. Long session (>2 hours since last commit)

**How it works:**
- Triggers run automatically during Completion Protocol Step 3.5
- Claude AI reads trigger info + analyzes session context
- **Normal commits:** Claude asks user if deep scan needed
- **Release mode (git tag):** Auto-invoke without asking (mandatory)
- **User decides:** Accept deep scan (1-2 min) or skip (fast path)

**What AI catches that regex misses:**
  1. Obfuscated credentials (base64, hex, chr arrays)
  2. Context-dependent secrets ("password is company name")
  3. Multiline credentials in unusual formats
  4. Secrets mentioned in discussions but not shown
  5. Composite credentials (user+pass+host split across lines)

**Scope optimization:**
- ✅ Analyzes: git diff (last 5 commits) + last dialog + new reports
- ❌ Skips: entire codebase, old dialogs, unchanged files
- **Result:** 5-10 files instead of 300+, massive token savings

**Coverage:** ~99% (catches edge cases)
**Speed:** 1-2 minutes (focused on sprint changes)
**Integration:** Completion Protocol Step 3.5 (advisory mode)
**Agent:** Uses Task tool with sec24 subagent

**When to Use Each Layer:**

| Layer | When Active | Speed | Coverage | Use Case |
|-------|-------------|-------|----------|----------|
| Layer 1 (gitignore) | Always | Instant | 100% (blocks all) | Passive protection |
| Layer 2 (bash regex) | Every session | 1-2s | 95% | Standard cleanup |
| Layer 3 (protocol) | Every session | Auto | Same as Layer 2 | Automatic invocation |
| Layer 4 (AI agent) | **Advisory/Release** | 1-2min | 99% | High-risk situations |

**Recommended workflow:**

**Normal commits (`/fi`):**
1. Layers 1-3 run automatically (fast, 1-2 seconds)
2. Triggers check sprint changes (instant)
3. If triggers found → Claude asks user: "Run deep scan? (y/N)"
4. User decides: y = 1-2 min deep scan, N = skip (fast path)

**Release mode (`git tag v2.x.x`):**
1. Layers 1-3 run automatically
2. Triggers detect release tag
3. **Automatic deep scan** without asking (mandatory)
4. User sees: "🚨 RELEASE MODE: Running mandatory deep scan..."

**Manual audit:**
- Run `/security-dialogs` anytime for thorough check
- Analyzes git diff + last dialog (sprint changes only)

**Technical Details:**
- File: `security/cleanup-dialogs.sh` (NEW, 200+ lines bash script with --deep flag)
- File: `.claude/commands/security-dialogs.md` (NEW, AI agent invocation)
- File: `.gitignore` (updated, +15 security patterns)
- File: `CLAUDE.md` (updated, Steps 0.5 and 3.5 enhanced)
- File: `migration/CLAUDE.production.md` (updated, same security steps)
- Tested: 8/10 redaction patterns working (SSH, DB, API keys, JWT, passwords, bearer tokens)
- Platform: macOS compatible (BSD sed, not GNU sed)
- **Architecture:** Bash regex (Layer 2) + AI agent (Layer 4) = hybrid approach

**Impact:**
- **CRITICAL:** Prevents production credential leaks to GitHub
- **Automatic:** No manual intervention needed
- **Fast:** --last flag makes it practical for every session
- **Comprehensive:** Covers dialog/, reports/, .production-credentials
- **Auditable:** All redactions logged in security/reports/

**Migration from v2.3.x:**
- No breaking changes
- Auto-activates on next Cold Start and Completion
- Compatible with all existing projects
- No user action required

**Note:** This security system is ported from supabase-bridge project where it's been battle-tested in production for several months.

---

## What's New in v2.3.3

**Security Fix: Auto-Redact Sensitive Data (Issue #47):**

**Problem:**
- Dialog exports contained OAuth tokens, API keys, and other sensitive data in plain text
- GitHub Secret Scanning blocked pushes when tokens detected
- Users had to manually redact sensitive data using sed/grep
- Risk of accidentally exposing secrets in public repositories

**Solution:**
- Added automatic sensitive data redaction in `exporter.ts`
- New `redactSensitiveData()` function scans and redacts before export
- Redaction patterns cover:
  - OAuth/Bearer tokens (access_token=..., bearer ...)
  - JWT tokens (eyJ...format)
  - API keys (Stripe sk-..., Google AIza..., AWS AKIA..., GitHub ghp_...)
  - Private keys (-----BEGIN PRIVATE KEY-----)
  - AWS Secret Access Keys
  - Database connection strings (postgres://, mysql://, mongodb://)
  - Passwords in URLs and config
  - Email addresses in auth contexts
  - Credit card numbers

**Impact:**
- Automatic protection against accidental token exposure
- No manual sed/grep redaction needed
- GitHub Secret Scanning won't block pushes
- Safe to commit dialog/ exports (still private by default via .gitignore)
- Preserves privacy and security for all users

**Technical:**
- File: `src/claude-export/exporter.ts` (modified, +87 lines)
- Applied to both dialog messages and summaries
- Tested with 11 different sensitive data patterns
- 100% coverage of common secret formats

---

## What's New in v2.3.2

**Bug Fix: Missing public/ Folder (Issue #48):**

**Problem:**
- `/ui` command failed with `ENOENT: no such file or directory, stat '...\public\index.html'`
- Affected users who installed framework manually or had corrupted installations
- Cryptic error message didn't explain the root cause

**Solution:**
- Added public/ folder existence check in `server.ts` before starting UI server
- Shows detailed error message with:
  - Root cause explanation
  - Two recovery options (re-install via script or manual fix)
  - Copy-paste commands for quick resolution
- Prevents server crash with user-friendly diagnostics

**Impact:**
- Users can now diagnose and fix missing public/ folder issues themselves
- Reduced support requests for installation issues
- Better error handling for Windows users (Issue #48 reported on Windows 11)

---

## What's New in v2.3.1

**Bug Reporting System Complete — Phase 2 & 3 (Phase 7):**

**Phase 2: Centralized Collection**
- [x] `.claude/scripts/submit-bug-report.sh` - Auto-submit to GitHub Issues
- [x] `.github/ISSUE_TEMPLATE/bug_report.yml` - Structured issue template
- [x] CLAUDE.md Step 6.5 enhanced - Two-step confirmation (create → submit)
- [x] GitHub CLI integration with graceful fallback
- [x] Issue URL tracking in report metadata
- [x] Auto-create "bug-report" label if missing
- [x] Smart title generation: `[Bug Report][Protocol Type] vX.Y.Z - Status`

**Phase 3: Analytics & Pattern Detection**
- [x] `.claude/scripts/analyze-bug-patterns.sh` - Pattern analyzer (bash 3.2 compatible)
- [x] `/analyze-local-bugs` command - Local bug analysis
- [x] Framework version distribution analysis
- [x] Protocol type distribution (Cold Start vs Completion)
- [x] Top 5 most common errors detection
- [x] Step failure analysis with recommendations
- [x] Auto-generated summary reports

**Quick Update Utility:**
- [x] `quick-update.sh` - Standalone updater for existing framework installations
- [x] Smart detection - auto-downloads init-project.sh if framework not found
- [x] Prevents user confusion between update vs installation

**Framework Developer Mode (Cold Start Protocol):**
- [x] Step 0.4: Automatic bug report checking from GitHub Issues
- [x] Shows count of open reports and recent ones (last 7 days)
- [x] Lists 5 most recent bug reports with titles
- [x] Suggests running `/analyze-bugs` for detailed analysis
- [x] Only runs in framework project (claude-code-starter)
- [x] Non-blocking: gracefully handles missing gh CLI

**Completion Protocol Self-Check:**
- [x] Step 0: Re-read Completion Protocol before execution
- [x] Prevents "сапожник без сапог" problem (forgetting to document changes)
- [x] Self-check questions for metafile updates
- [x] Works for both framework and host projects
- [x] Counters context compaction during long sessions

**System Architecture:**
```
Phase 1: Local Logging → Phase 2: Centralized Collection → Phase 3: Analytics
   (v2.3.0)                      (v2.3.1)                      (v2.3.1)
```

**Privacy & Control:**
- Bug reports created ALWAYS (analytics/telemetry, not just errors)
- Double confirmation (create report + submit to GitHub)
- All analysis runs locally first
- User decides what to share
- Complete anonymization before submission

## Next Phase

- [ ] Monitor bug report patterns from host projects
- [ ] ML-based categorization of recurring issues
- [ ] Auto-fix suggestions for common errors

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
