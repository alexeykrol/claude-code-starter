# Claude Code Starter v6.2.1

Patch release fixing structural defects in session onboarding. Reported by the same Saved Downloader project owner whose regression report drove v6.2.

## Three defects identified

1. **Duplicate of auto-loaded CLAUDE.md** — two sources of truth, drift inevitable
2. **Cap on report length** — "доложи 3–5 строк" read as ceiling on depth, not floor on brevity
3. **Map without territory** — reading only metafiles inherits the project's self-description blind spots

Our `/start` skill had defects 2 and 3 verbatim. Every new project would inherit them.

## What's fixed

- **`/start` skill rewritten**: depth of report scales to the user's request (compact for routine start, full analytical breakdown for "разберись с проектом"); mandatory grounding step (git log / wc / grep against metafile claims); explicit "карта ≠ территория" marker
- **CLAUDE.md templates** get a "Назначение этого файла" section codifying three kinds of constraints (actions: hard, attention: helpful, depth: **never capped**) so future "simplify" edits can't quietly reintroduce a cap
- **`validate-release.sh`** refuses to release if any `ONBOARDING.md` ships — constitution lives only in CLAUDE.md (auto-loaded by the harness)
- **`methodology/draft/onboarding-protocols-must-not-cap-depth.md`** captures the case for future reference

## Install

```bash
curl -fsSL https://github.com/alexeykrol/claude-code-starter/releases/download/v6.2.1/init-project.sh -o init-project.sh
bash init-project.sh
```

## Upgrade

- v6.2.0 → v6.2.1: additive migration; `/start` skill is replaced only if untouched; manual edits preserved. CLAUDE.md "Назначение" section merged additively.

## Release Assets

- `init-project.sh`
- `framework.tar.gz`
- `checksums.txt`
- `RELEASE_NOTES.md`

## References

- [Full release notes](https://github.com/alexeykrol/claude-code-starter/blob/main/release-notes/v6.2.1.md)
- [CHANGELOG](https://github.com/alexeykrol/claude-code-starter/blob/main/CHANGELOG.md)
- Case report on which this patch is based: `FRAMEWORK-CASE-ONBOARDING.md` (Saved Downloader project)
