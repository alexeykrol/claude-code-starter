# Changelog

All notable changes to `Claude Code Starter` are documented here.

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
