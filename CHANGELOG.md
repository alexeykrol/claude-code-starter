# Changelog

All notable changes to `Claude Code Starter` are documented here.

## [6.2.0] - 2026-06-12

### Summary

`v6.2.0` restores the **two-axis memory model** the framework had in `v4` and lost in `v5`. Memory now lives on two distinct axes — **contracts** (what should be: `ARCHITECTURE.md`, `INVARIANTS.md`, `methodology/`) and **state** (what is now: `SNAPSHOT.md`, `BACKLOG.md`, `dialogs/`). Each axis has its own slot; collapsing them into a single SNAPSHOT — as v5 did — caused the agent to repeatedly violate project invariants because there was no place for the contract layer to live. A user regression report documented eight separate `DROP TABLE` antipattern reoccurrences directly caused by this collapse.

Also new: a **methodology layer** with explicit maturity ladder (draft → pattern → mature → crystallized) for methodologies consumed by automated pipelines (router → adapter → executor chains), and **dialog preservation** that protects Claude Code session JSONLs from retention cleanup so valuable methodological evolution is never lost.

### Added

- **Memory layers (restored / new):**
  - `.claude/ARCHITECTURE.md` (restored from v4) — system map: modules, layers, contracts, entry points, dependencies, open questions
  - `.claude/BACKLOG.md` (restored from v4) — Next / Soon / Later / Won't do plan
  - `.claude/INVARIANTS.md` (new) — hard rules whose violation is a bug, not a preference; categorized; example INV-001 pre-filled in both code and content variants
  - Both code-flavored (root `.claude/`) and content-flavored (`templates/content/`) versions; hybrid inherits content
- **Methodology layer (new):**
  - `methodology/_HOW-THIS-GROWS.md` — explains maturity ladder draft → pattern → mature → crystallized and Router → Adapter → Executor composition
  - `methodology/templates/{draft,pattern,mature,crystallized}.md` — format per stage; draft fillable in 2 minutes (low entry threshold by design)
  - `methodology/00-example-llm-as-component.md` — canonical mature example adapted from existing global rule
  - Subdirs `draft/ patterns/ mature/` with `.gitkeep`
  - Global layer copy in `~/.claude/methodology/` via `install-global.sh`
- **Dialog preservation (new):**
  - `rules/dialog-preservation.md` — explains why Claude Code session JSONLs must be saved before retention cleanup
  - `scripts/save-dialogs.sh` — idempotent copy of `~/.claude/projects/<encoded>/*.jsonl` into project `.claude/dialogs/<date>_<sid>.jsonl`, updates `INDEX.md`
  - `/save-dialog` skill — interactive entry point with optional note
  - `/finish` auto-calls `save-dialogs.sh` before commit
  - Privacy-first `.gitignore` — raw JSONL never accidentally committed even in `private-solo`
- **CLAUDE.md templates** — new "Слои памяти" section documenting the two-axis model so future "simplify" passes cannot quietly collapse it
- **`/start` skill** — now reads both axes (SNAPSHOT, BACKLOG, INVARIANTS, ARCHITECTURE) at session start
- **`/finish` skill** — updates all memory layers, not only SNAPSHOT; commits the whole bundle in `private-solo` mode
- **Tests** — 3 new regression tests (`memory_layers_code`, `memory_layers_content`, `save_dialogs_idempotent`); 11/11 passing

### Changed

- `install_common.sh` — new `install_methodology_scaffold()` and `install_memory_layers()` helpers; universal rules list now includes `dialog-preservation`; `backup_existing`/`rollback` include new memory files; `install_gitignore` always appends dialog-archive rules
- `install-global.sh` (6.2.0) — installs `templates/global/rules/`, `~/.claude/methodology/`, `/save-dialog` skill; backup/rollback include `methodology/`
- `build-release.sh` — bundles `templates/methodology/` into release tarball

### Why this matters

The v5 regression was not architectural taste — it was the agent forgetting project contracts and re-violating them between sessions. SNAPSHOT alone cannot hold contracts because it changes every session. ARCHITECTURE and INVARIANTS live on a different time scale and need their own files. This release makes that distinction physical and documents it in every CLAUDE.md so it cannot be quietly undone again.

### Upgrade Notes

The v6.2 installer treats existing v6.1 installs as `upgrade` scenario and runs additive migration. Existing custom `CLAUDE.md` content is preserved through the same merger as in v6.1. New memory files are created only if they don't already exist — the installer never overwrites user content.

## [6.1.0] - 2026-04-26

### Summary

`v6.1.0` adds an opt-in **global layer**: framework rules / skills / agents can be installed into `~/.claude/` so they are available in every project, with a `/setup-project` skill that bootstraps a project from inside Claude Code (no manual installer download required).

### Added

- `scripts/install-global.sh` — additive installer for `~/.claude/`:
  - Backups existing `~/.claude/` to `~/.claude/.backup-TIMESTAMP/`
  - Adds 5 content rules, 6 content skills, 2 content agents (`writer`, `editor`)
  - Adds `content-reviewer` as a separate agent (coexists with code `reviewer`)
  - Replaces `housekeeping` skill with content-aware universal version (old version backed up)
  - Adds code-only skills missing globally (`db-migrate`, `playwright`)
  - Records framework checkout location in `~/.claude/framework-source-path`
  - Additive merge of `~/.claude/CLAUDE.md` with framework addendum (preserves all custom user content)
  - `--rollback` restores latest backup
  - `--dry-run` previews changes
- `templates/global/skills/setup-project/SKILL.md` — Claude Code skill for one-command project bootstrap; auto-detects type and runs `init-project.sh` from the cached source path
- `templates/global/CLAUDE.addendum.md` — documentation block describing the global layer; merged into the user's existing global CLAUDE.md

### Changed

- README documents the new "global layer" install path (Variant 3)

## [6.0.0] - 2026-04-25

### Summary

`v6.0.0` introduces content-aware framework support with auto-detection of project type. Projects whose product is text — books, courses, knowledge bases, documents, transcripts — now get a dedicated framework layer (rules, skills, agents) without sacrificing the existing code-project flow. Default install requires no flags: `bash init-project.sh` detects project type, content type, and the appropriate scenario.

### Added

- **Content framework templates** in `templates/content/`:
  - `CLAUDE.md` and `SNAPSHOT.md` with content-specific structure (audience, source hierarchy, style/voice, workflow, formats)
  - 5 rules: `content-pipeline`, `content-quality`, `source-management`, `content-formats`, `content-commit-policy`
  - 7 skills: `research`, `outline`, `write-content`, `review-content`, `enrich`, `content-index`, `housekeeping` (content-adapted)
  - 3 agents: `writer`, `editor`, `reviewer` (content-focused, 28-point review checklist)
  - 5 content unit templates: `chapter.md`, `lesson.md`, `transcript.md`, `article.md`, `document.md`
  - Starter directory layouts for `book`, `course`, `knowledge-base`, `documents`, `transcripts`
- **Auto-detection of project type** (`code` / `content` / `hybrid` / `unknown`) by file extensions, directory signals, and manifest detection
- **Auto-detection of content type** (`book` / `course` / `knowledge-base` / `documents` / `transcripts` / `mixed`) by directory layout
- **Safe additive `CLAUDE.md` merge** via [scripts/lib/merge_claude_md.py](scripts/lib/merge_claude_md.py):
  - Parses by `## headings` with code-fence aware state machine
  - Similarity-based merge: identical kept, near-identical preserved, additive lists/tables merged, hard conflicts blocked
  - Three CLI modes: `merge`, `check` (exit 2 on conflict), `propose` (markdown report with concrete resolution)
  - 24 unit tests in [tests/test_merge_claude_md.py](tests/test_merge_claude_md.py)
- **Backup and rollback**:
  - Every install/migrate snapshots `CLAUDE.md`, `settings.json`, `SNAPSHOT.md`, `manifest.md`, `.gitignore` to `.claude/backup-TIMESTAMP/`
  - `bash init-project.sh --rollback` restores the latest backup
  - `bash init-project.sh --apply-proposal` applies a CLAUDE.md merge proposal after manual review
- **Shared install library** in [scripts/lib/install_common.sh](scripts/lib/install_common.sh) — single source of truth for `init-project.sh` and `migrate.sh`
- **Smoke tests** in [tests/test-content-install.sh](tests/test-content-install.sh) covering install/migrate/rollback paths
- **New CLI flags**: `--type`, `--content-type`, `--rollback`, `--apply-proposal`, `--force`
- **Manifest extension**: `project_type` and `content_type` fields in `manifest.md`
- **Hybrid mode**: code framework + content overlay coexist; `code-reviewer` and `content-reviewer` kept separate; `content-housekeeping` replaces `code-housekeeping` (universal)

### Changed

- `init-project.sh` (root launcher) bumped to `v6.0.0`; passes new flags to internal scripts
- `scripts/init-project.sh` rewritten as thin parser + dispatcher over `install_common.sh`
- `scripts/migrate.sh` rewritten as additive migrator with auto-detection, backup, conflict-aware merge
- `scripts/build-release.sh` now bundles `templates/content/` and `scripts/lib/` into `framework.tar.gz`
- `manifest.md` template now includes `project_type` and `content_type`
- README updated with content framework documentation, new flags, content type heuristics

### Fixed

- Pre-existing `settings.json` (created manually or by another agent) now has its missing `hooks` section merged from the framework template instead of being silently skipped — previously left projects with a "dead" framework where no hooks fired (carried over from the v5 hotfix)

### Known Limitations

- `--apply-proposal` falls back to a manual instruction if the Python merger does not yet implement the apply-proposal subcommand (placeholder for future iteration)
- Auto-detection uses `find -maxdepth 4`; deeply nested content may be undercounted
- Hybrid mode picks the content `CLAUDE.md` template (broader); pure-code projects with hybrid signals may want to override via `--type code`

## [5.0.0] - 2026-04-06

### Summary

`v5.0.0` turns `Claude Code Starter` into a Claude Code native operational framework with a single public installer, modular `.claude/` primitives, explicit `repo_access`, and release-ready distribution assets.

### Added

- One public installer entrypoint: [init-project.sh](init-project.sh)
- Modular operating layer:
  - `.claude/rules/`
  - `.claude/skills/`
  - `.claude/agents/`
  - `.claude/hooks/`
- Persistent project memory through `.claude/SNAPSHOT.md`
- `repo_access` handling via [scripts/framework-state-mode.sh](scripts/framework-state-mode.sh)
- Safe mode switching via [scripts/switch-repo-access.sh](scripts/switch-repo-access.sh)
- Release tooling:
  - [scripts/validate-release.sh](scripts/validate-release.sh)
  - [scripts/build-release.sh](scripts/build-release.sh)
  - [RELEASING.md](RELEASING.md)
  - [release-notes/v5.0.0.md](release-notes/v5.0.0.md)
  - [release-notes/GITHUB_RELEASE_v5.0.0.md](release-notes/GITHUB_RELEASE_v5.0.0.md)

### Changed

- Public repository root now represents `v5`
- Installer UX returns to the `single file -> run in host project` model
- Standalone installer resolves payload in this order:
  - GitHub Release archive
  - `git clone`
  - repository snapshot fallback
- Documentation is now split by audience:
  - [README.md](README.md) for users
  - [CHANGELOG.md](CHANGELOG.md) for version history
  - [RELEASING.md](RELEASING.md) for maintainers

### Archived

- The old `v4` tree is preserved in [archive/v4-working-tree](archive/v4-working-tree)
- The pre-migration `v4` head is preserved as git tag `archive-v4-head-2026-04-06`

### Known Limitations

- `migrate.sh` still falls back to replacing `.claude/settings.json` if `python3` is unavailable or JSON merge fails
- Shared/public mode still requires switching before framework state reaches upstream history
- GitHub Release creation is still a manual publishing step

## [4.0.2]

Legacy `v4` state is preserved in [archive/v4-working-tree](archive/v4-working-tree).
