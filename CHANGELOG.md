# Changelog

All notable changes to `Claude Code Starter` are documented in this file.

The format is intentionally simple:
- released versions first;
- operationally meaningful changes only;
- release asset expectations called out when distribution changes.

## [5.0.0] - 2026-04-06

### Added
- Single public installer entrypoint via [init-project.sh](init-project.sh).
- Modular Claude Code operating layer:
  - `.claude/rules/`
  - `.claude/skills/`
  - `.claude/agents/`
  - `.claude/hooks/`
- `repo_access` model with helper logic in [scripts/framework-state-mode.sh](scripts/framework-state-mode.sh).
- Safe mode-switch script in [scripts/switch-repo-access.sh](scripts/switch-repo-access.sh).
- Release build tooling in [scripts/build-release.sh](scripts/build-release.sh).
- Release validation tooling in [scripts/validate-release.sh](scripts/validate-release.sh).
- Versioned release notes in [release-notes/v5.0.0.md](release-notes/v5.0.0.md).

### Changed
- Public repository root migrated from `v4` layout to `v5` operational layout.
- Root branding restored to `Claude Code Starter`.
- Installer UX returned to the `single file -> run in host project` model.
- Standalone installer now resolves payload in this order:
  - GitHub Release archive
  - `git clone` fallback
  - repository snapshot fallback

### Archived
- Full `v4` working tree preserved in [archive/v4-working-tree](archive/v4-working-tree).
- Pre-migration `v4` head preserved as git tag `archive-v4-head-2026-04-06`.

### Known Limitations
- `migrate.sh` still uses a destructive fallback for `.claude/settings.json` if `python3` is unavailable or JSON merge fails.
- Shared/public mode still requires switching before framework state reaches remote history.

## [4.0.2] - 2025-??-??

Legacy `v4` line preserved in [archive/v4-working-tree](archive/v4-working-tree).
See the archived repository state for the original runtime, dual-agent adapters, Python core, commands, and protocol files.
