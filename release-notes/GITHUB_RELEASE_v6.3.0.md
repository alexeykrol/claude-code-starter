# Claude Code Starter v6.3.0

Minor release embedding the **orchestrator model**: the owner stays in the product seat above production; the agent becomes the orchestrator and lead developer that spawns and coordinates its own workers.

## The shift

Before: the agent is a "project manager" with subagents, and the **owner** personally launches every parallel session, pastes handoffs between them, and acts as the integration bus.

Now — three levels by default:

- **Owner** — product/methodologist *above* production: goal, authority envelope, outcome review, stop-point decisions. Not a dispatcher, not a bus.
- **Orchestrator (the agent)** — decomposes work into streams, spawns its own workers (subagents / isolated git worktrees / deterministic workflows), integrates by dependency order, verifies independently, commits. Wakes the owner only at stop-points (prod deploys, external effects, irreversible actions, runtime-data deletion).
- **Workers** — ephemeral executors in their own fresh contexts; invisible to the owner.

Second axis: **bounded continuity**. Cross-session context is carried by the two-axis memory (contracts ⟂ state) plus a thin, verifiable handoff pointer — never by an ever-growing context megafile (unbounded continuity files are bugs: they drown the session they were meant to save).

## What's new

- **`orchestration-model.md`** — portable rule set (principles O1–O12: single-writer via worktree isolation, worker charters, four evidence statuses with an independent verifier, authority envelope, fan-out vs solo judgment, incremental legacy adoption path) — now ships with the framework and installs into `~/.claude/rules/`
- **`/handoff` skill now in the install set** — carrier of the continuity axis: role-typed session handoffs, grounding discipline, verification-report handshake (previously referenced by the addendum but not shipped — dangling for fresh installs)
- **`autonomy.md` evolved** — the three-level frame stated explicitly; "don't pull the owner in" extended to the whole production layer
- **`delegation.md` evolved** — charters, fan-out vs solo, single writer per shared contract, evidence without optimistic renaming, saved workflows
- **Global addendum documents the model** so merged `CLAUDE.md` files carry it

## Install

```bash
curl -fsSL https://github.com/alexeykrol/claude-code-starter/releases/download/v6.3.0/init-project.sh -o init-project.sh
bash init-project.sh
```

## Upgrade

All changes are additive: `install-global.sh` adds the new rule and skill only if absent; customized copies are never overwritten. Existing projects keep working under the flat model until adopted — the rule includes an explicit incremental path (wrap the manual handoff model, don't tear it down).

## Release Assets

- `init-project.sh`
- `framework.tar.gz`
- `checksums.txt`
- `RELEASE_NOTES.md`

## References

- [Full release notes](https://github.com/alexeykrol/claude-code-starter/blob/main/release-notes/v6.3.0.md)
- [CHANGELOG](https://github.com/alexeykrol/claude-code-starter/blob/main/CHANGELOG.md)
