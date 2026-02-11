# Claude Code Starter

Dual-agent meta-framework for structured AI-assisted development with **Claude Code** and **Codex**.

> Repository name remains `claude-code-starter` for backward compatibility.

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-4.0.1-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **RU version:** [README_RU.md](README_RU.md)

## What Is New In v4.0.0

- Full **dual-agent runtime**: Claude adapter + Codex adapter in one framework.
- Shared state contract via `.claude/SNAPSHOT.md`, `.claude/BACKLOG.md`, `.claude/ARCHITECTURE.md`.
- Additive installation flow: existing Claude structure is preserved; Codex support added in parallel.
- Codex start flow supports auto-routing of migration/upgrade and automatic framework update.
- Migration quality improved: legacy/upgrade paths can generate real memory content from project materials.

## For Users

### Requirements

- Node.js 18+
- Python 3.x

Check:

```bash
node --version
python3 --version
```

### Installation Into Any Host Project

1. Download `init-project.sh` to the root of your host project.
2. Run installer:

```bash
./init-project.sh
```

3. Launch your preferred agent in that project:
- `codex`
- `claude`

4. Start protocol in chat:
- `start`

5. Finish protocol in chat:
- `/fi`

## User Workflow

### Start

`start` runs cold start protocol:

- migration/upgrade routing (first run only),
- crash/session checks,
- shared context load,
- framework version check (auto-update path when available).

### Finish

`/fi` runs completion protocol:

- security/export checks,
- git status/diff checks,
- session finalization output.

## Framework Structure

```text
claude-code-starter/
├── CLAUDE.md                    # Claude adapter entry
├── AGENTS.md                    # Codex adapter entry
├── init-project.sh              # Installer for host projects
├── CHANGELOG.md
├── README.md
├── README_RU.md
├── .claude/
│   ├── commands/                # Claude workflows/prompts
│   ├── protocols/               # Silent protocol specs
│   ├── scripts/quick-update.sh  # Claude updater entry
│   └── templates/               # State/config templates
├── .codex/
│   ├── commands/                # Executable Codex workflows
│   │   └── quick-update.sh      # Codex updater entry
│   └── contracts/
├── src/framework-core/          # Shared Python runtime (cold-start/completion)
├── security/                    # Security scan and cleanup scripts
└── migration/                   # Distribution/release tooling
```

## Migration Modes

Installer auto-detects host project type:

- `new` — clean project bootstrap,
- `legacy` — framework migration into existing project,
- `upgrade` — upgrade from previous framework generation.

All modes are designed to be non-destructive to host business code.

## Update Model

- `start` includes version check.
- If newer framework version is found and updater exists, update is applied automatically.
- Update payload includes both adapter tracks (Claude and Codex) to keep parity.

## For Framework Developers

### Setup

```bash
git clone https://github.com/alexeykrol/claude-code-starter.git
cd claude-code-starter
npm install
npm run build
```

### Build Distribution

```bash
bash migration/build-distribution.sh
```

Artifacts are created in `dist-release/`:

- `init-project.sh`
- `framework.tar.gz`
- `framework-commands.tar.gz`

## Versioning

- Semantic Versioning is used.
- `4.0.0` is a major release because runtime model shifted from single-agent to dual-agent framework contract.

See full details in [CHANGELOG.md](CHANGELOG.md).

## Contributing

1. Create branch
2. Make changes
3. Run local checks/build
4. Open PR

---

Framework goal: let users choose their coding agent while keeping one shared project state and one lifecycle protocol model.
