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
scripts/build-release.sh 5.0.0
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
2. Run `scripts/validate-release.sh`.
3. Run `scripts/build-release.sh`.
4. Review `dist-release/<version>/RELEASE_NOTES.md`.
5. Create tag `v<version>` if it does not already exist.
6. Create GitHub Release from `v<version>`.
7. Use [release-notes/GITHUB_RELEASE_v5.0.0.md](release-notes/GITHUB_RELEASE_v5.0.0.md) as the release body template and adjust the version if needed.
8. Upload:
   - `dist-release/<version>/init-project.sh`
   - `dist-release/<version>/framework.tar.gz`
   - `dist-release/<version>/checksums.txt`
   - `dist-release/<version>/RELEASE_NOTES.md`
9. Verify a standalone install from the published release assets.

## Asset Roles

### `init-project.sh`

The public single-file installer.

### `framework.tar.gz`

The payload archive for standalone installs. It must contain one top-level folder named `claude-code-starter/` and include:
- `.claude/`
- `scripts/`
- `CLAUDE.md`
- `manifest.md`
- `.gitignore`
- `README.md`
- `CHANGELOG.md`

### `checksums.txt`

SHA-256 checksums for release verification.

### `RELEASE_NOTES.md`

The versioned note that ships with the assets.
