# Releasing Claude Code Starter

This repository now has a concrete release asset strategy.

## Release Assets

Each tagged release should publish:
- `init-project.sh`
- `framework.tar.gz`
- `checksums.txt`
- `RELEASE_NOTES.md`

## Asset Roles

### `init-project.sh`

Public single-file installer.

Use cases:
- copied directly into a host project
- downloaded from a GitHub Release
- run from a local checkout of this repository

### `framework.tar.gz`

Payload archive for standalone installs.

It should contain one top-level folder:

```text
claude-code-starter/
  .claude/
  scripts/
  CLAUDE.md
  manifest.md
  .gitignore
  README.md
  CHANGELOG.md
```

The root installer expects to find:
- `scripts/init-project.sh`
- `scripts/migrate.sh`

inside that archive payload.

### `checksums.txt`

SHA-256 checksums for release verification.

### `RELEASE_NOTES.md`

Human-readable notes copied from `release-notes/v<version>.md`.

## Build

Validate release inputs:

```bash
scripts/validate-release.sh
```

Build release assets:

```bash
scripts/build-release.sh
```

Or explicitly:

```bash
scripts/build-release.sh 5.0.0
```

Output location:

```text
dist-release/<version>/
```

## Publish Checklist

1. Ensure `main` is clean.
2. Ensure `CHANGELOG.md` has an entry for the target version.
3. Ensure `release-notes/v<version>.md` exists.
4. Run `scripts/validate-release.sh`.
5. Run `scripts/build-release.sh`.
6. Create a Git tag `v<version>`.
7. Create GitHub Release from that tag.
8. Upload:
   - `dist-release/<version>/init-project.sh`
   - `dist-release/<version>/framework.tar.gz`
   - `dist-release/<version>/checksums.txt`
   - `dist-release/<version>/RELEASE_NOTES.md`
9. Verify that standalone `init-project.sh` can install from the published release assets.

## Current Manual Part

The GitHub Release creation step is still manual.

What is already scripted:
- validating release inputs
- building release artifacts
- generating checksums
- copying versioned release notes into release assets

What remains manual:
- creating the GitHub Release
- attaching built assets
- publishing the release
