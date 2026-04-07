# Changelog

All notable changes to `Claude Code Starter` are documented here.

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
