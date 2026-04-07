# Claude Code Starter v5.0.0

`Claude Code Starter v5.0.0` is the new public baseline for installing a Claude Code operating environment into any host project.

## Highlights

- Single public installer: `init-project.sh`
- One launcher for:
  - new projects
  - existing projects
  - legacy framework installs
  - partial `v5` installs
- Native Claude Code operating model:
  - `rules`
  - `skills`
  - `agents`
  - `hooks`
- Explicit `repo_access` handling for private, shared, and public repositories
- Release-ready asset distribution through `framework.tar.gz`

## Install

Download `init-project.sh`, place it in the root of the target project, then run:

```bash
chmod +x init-project.sh
./init-project.sh
```

The launcher detects the host scenario automatically and routes to bootstrap or migration as needed.

## Release Assets

This release publishes:
- `init-project.sh`
- `framework.tar.gz`
- `checksums.txt`
- `RELEASE_NOTES.md`

## Notes For Existing Users

- The repository root now represents `v5`
- The old `v4` framework tree is preserved in `archive/v4-working-tree/`
- The pre-migration `v4` head is preserved as tag `archive-v4-head-2026-04-06`

## Known Limitations

- `migrate.sh` still relies on `python3` for safe JSON merge of `.claude/settings.json`
- Shared/public mode still requires switching before framework state reaches remote history

## References

- User docs: `README.md`
- Version history: `CHANGELOG.md`
- Release process: `RELEASING.md`
