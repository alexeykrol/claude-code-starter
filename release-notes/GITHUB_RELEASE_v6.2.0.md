# Claude Code Starter v6.2.0

`Claude Code Starter v6.2.0` restores the **two-axis memory model** the framework had in v4 and lost in v5. Memory now lives on two distinct axes — contracts (what should be) and state (what is now) — with one file per layer.

Driven by a user regression report: collapsing memory into a single `SNAPSHOT.md` caused the agent to repeatedly violate project invariants (eight `DROP TABLE` antipattern reoccurrences in one codebase). The agent had no slot to remember "this is a contract, not a session note."

## Highlights

- **Restored from v4**: `ARCHITECTURE.md`, `BACKLOG.md`
- **New**: `INVARIANTS.md` — hard rules whose violation is a bug
- **New methodology layer** with explicit maturity ladder (draft → pattern → mature → crystallized) for methodologies consumed by automated pipelines (Router → Adapter → Executor)
- **New dialog preservation**: Claude Code session JSONLs are copied into `.claude/dialogs/` before retention cleanup; `/finish` auto-saves
- **Documented in CLAUDE.md** — "Слои памяти" section so future "simplify" passes can't quietly collapse the model again
- **`/start` and `/finish` updated** to read/update both axes

Verified by 11 smoke tests (8 inherited + 3 new v6.2 regression tests). All pass.

## Install

### Quick

```bash
curl -fsSL https://github.com/alexeykrol/claude-code-starter/releases/download/v6.2.0/init-project.sh -o init-project.sh
bash init-project.sh
```

### Global layer

```bash
git clone https://github.com/alexeykrol/claude-code-starter.git
bash claude-code-starter/scripts/install-global.sh
```

After install, `/setup-project` (or "новый проект") in any folder bootstraps the framework with no download.

## Memory Layers

| Axis | File | Purpose |
|------|------|---------|
| Contract | `.claude/ARCHITECTURE.md` | System map: modules, layers, contracts |
| Contract | `.claude/INVARIANTS.md` | Hard rules: violation = bug |
| Contract | `methodology/` | Pipeline methodologies with maturity ladder |
| State | `.claude/SNAPSHOT.md` | Current point of work |
| State | `.claude/BACKLOG.md` | Next / Soon / Later / Won't do |
| State | `.claude/dialogs/` | Session JSONL archive |

## Methodology Maturity Ladder

```
draft     — 5-line observation, fillable in 2 minutes
   ↓ when seen in 3+ places
pattern   — concept + anti-patterns
   ↓ when prompt skeleton stabilizes
mature    — full spec: routing signals, decomposition, prompt skeleton
   ↓ when called consistently
crystallized — part moved to code, methodology = spec
```

Low entry threshold by design — better unpolished draft than lost insight.

## Notes For v6.1 Users

The v6.2 installer detects existing v6.1 installs as `upgrade` and runs additive migration. Custom `CLAUDE.md` content is preserved by the merger. New memory files are created only if missing — no overwrite of existing content.

## Release Assets

- `init-project.sh` — single-file public installer
- `framework.tar.gz` — full payload (`.claude/`, `templates/`, `scripts/`, `CLAUDE.md`, `manifest.md`, `README.md`, `CHANGELOG.md`)
- `checksums.txt` — SHA-256 checksums
- `RELEASE_NOTES.md` — versioned notes

## References

- User docs: [README.md](https://github.com/alexeykrol/claude-code-starter/blob/main/README.md)
- Full version history: [CHANGELOG.md](https://github.com/alexeykrol/claude-code-starter/blob/main/CHANGELOG.md)
- Detailed release notes: [release-notes/v6.2.0.md](https://github.com/alexeykrol/claude-code-starter/blob/main/release-notes/v6.2.0.md)
