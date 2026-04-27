# Claude Code Starter v6.1.0

`Claude Code Starter v6.1.0` is the first published release of the v6 series. It adds **content-aware framework support** and an **optional global layer** so you can bootstrap any project from inside Claude Code without downloading anything.

## Highlights

- **Auto-detection** of project type (`code` / `content` / `hybrid`) and content type (`book` / `course` / `knowledge-base` / `documents` / `transcripts` / `mixed`)
- **Content framework**: 5 rules, 7 skills, 3 agents (`writer`, `editor`, content `reviewer` with 28-point checklist), 5 content unit templates, starter directory layouts
- **Safe additive `CLAUDE.md` merge** — custom user content always preserved; hard conflicts produce a concrete resolution proposal instead of breaking
- **Backup & rollback** — every install/migrate snapshots files to `.claude/backup-TIMESTAMP/`; one command to restore
- **Hybrid mode** — code and content layers coexist for projects that have both
- **Global layer** — install once into `~/.claude/`, then use `/setup-project` skill in any new folder

Verified on 16 real projects (books, courses, knowledge bases, documents, transcripts, hybrids): every custom user section preserved across migration, no data loss.

## Install

### Quick

```bash
curl -fsSL https://github.com/alexeykrol/claude-code-starter/releases/download/v6.1.0/init-project.sh -o init-project.sh
bash init-project.sh
```

The launcher auto-detects scenario and project type, then bootstraps or migrates as needed.

### Global layer (recommended for power users)

```bash
git clone https://github.com/alexeykrol/claude-code-starter.git
bash claude-code-starter/scripts/install-global.sh
```

After that, in any new project folder you can just open Claude Code and say `/setup-project` (or "новый проект", "поставь фреймворк") — the framework installs itself with no download.

## Release Assets

- `init-project.sh` — single-file public installer
- `framework.tar.gz` — full payload (`.claude/`, `templates/`, `scripts/`, `CLAUDE.md`, `manifest.md`, `README.md`, `CHANGELOG.md`)
- `checksums.txt` — SHA-256 checksums
- `RELEASE_NOTES.md` — versioned notes

## New CLI Surface

- `--type code|content|hybrid|auto` (default: auto)
- `--content-type book|course|knowledge-base|documents|transcripts|mixed`
- `--rollback` — restore latest backup
- `--apply-proposal` — apply CLAUDE.md merge proposal
- `--force` — overwrite existing files (developer use)
- All v5 flags (`--name`, `--mode`, `--template`) still work

## Notes For v5 Users

The v6.1.0 installer detects v5 installs as `upgrade` scenario and runs additive migration. Custom `CLAUDE.md` content is preserved by the new merger. No data loss expected — verified on real-world v5 projects.

## Known Limitations

- Auto-detection uses `find -maxdepth 4`; deeply nested content may be undercounted
- Hybrid projects with strong code-only signals may want to override via `--type code`
- `migrate.sh` still relies on `python3` for `.claude/settings.json` JSON merge

## References

- User docs: [README.md](https://github.com/alexeykrol/claude-code-starter/blob/main/README.md)
- Full version history: [CHANGELOG.md](https://github.com/alexeykrol/claude-code-starter/blob/main/CHANGELOG.md)
- Detailed release notes: [release-notes/v6.1.0.md](https://github.com/alexeykrol/claude-code-starter/blob/main/release-notes/v6.1.0.md)
- Release process: [RELEASING.md](https://github.com/alexeykrol/claude-code-starter/blob/main/RELEASING.md)
