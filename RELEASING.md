# Releasing Claude Code Starter

This file is the maintainer playbook for shipping a GitHub Release.

## Release Assets

Every release should publish:
- `init-project.sh`
- `framework.tar.gz`
- `checksums.txt`
- `RELEASE_NOTES.md`

## What Is Scripted

Already automated:
- release input validation
- asset build
- checksum generation
- copying versioned release notes into the release bundle

Still manual:
- creating the Git tag if needed
- creating the GitHub Release
- attaching built assets
- publishing the release

## Validate

```bash
scripts/validate-release.sh
```

This checks:
- required files exist
- bash scripts parse
- `CHANGELOG.md` contains the current version
- `release-notes/v<version>.md` exists and matches the current version

## Build

```bash
scripts/build-release.sh
```

Or explicitly:

```bash
scripts/build-release.sh 6.3.0
```

Output:

```text
dist-release/<version>/
  init-project.sh
  framework.tar.gz
  checksums.txt
  RELEASE_NOTES.md
```

## Publish Checklist

1. Ensure `main` is clean.
2. **Refresh descriptive docs** so they don't drift behind the code:
   - `README.md` — version badge, "Что устанавливается в проект", links to current release notes
   - `RELEASING.md` — current version examples
   - `templates/global/CLAUDE.addendum.md` — new global rules / skills / methodology
   - `CHANGELOG.md` — entry for the new version
   `scripts/validate-release.sh` enforces the version-badge + release-notes link checks and refuses to pass if a descriptive file is behind.
3. Run `scripts/validate-release.sh`.
4. Run `scripts/build-release.sh`.
5. Review `dist-release/<version>/RELEASE_NOTES.md`.
6. Create tag `v<version>` if it does not already exist.
7. Create GitHub Release from `v<version>`.
8. Use the latest versioned body — for example [release-notes/GITHUB_RELEASE_v6.3.0.md](release-notes/GITHUB_RELEASE_v6.3.0.md) — as the release body template, and adjust the version if needed.
9. Upload:
   - `dist-release/<version>/init-project.sh`
   - `dist-release/<version>/framework.tar.gz`
   - `dist-release/<version>/checksums.txt`
   - `dist-release/<version>/RELEASE_NOTES.md`
10. Verify a standalone install from the published release assets.

## Asset Roles

### `init-project.sh`

The public single-file installer.

### `framework.tar.gz`

The payload archive for standalone installs. It must contain one top-level folder named `claude-code-starter/` and include:
- `.claude/` — rules, skills, agents, hooks, dialogs/, memory layers (SNAPSHOT, BACKLOG, ARCHITECTURE, INVARIANTS)
- `scripts/` — `init-project.sh`, `migrate.sh`, `save-dialogs.sh`, `install-global.sh`, `framework-state-mode.sh`, `switch-repo-access.sh`, `lib/`
- `templates/` — `content/`, `global/`, `methodology/`
- `CLAUDE.md`
- `manifest.md`
- `.gitignore`
- `README.md`
- `CHANGELOG.md`

### `checksums.txt`

SHA-256 checksums for release verification.

### `RELEASE_NOTES.md`

The versioned note that ships with the assets.
