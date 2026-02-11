# Shared State Contract (Agent-Agnostic)

Primary shared memory files:
- Software profile:
  - `.claude/SNAPSHOT.md`
  - `.claude/BACKLOG.md`
  - `.claude/ARCHITECTURE.md`
- Content profile:
  - `.claude/content/SNAPSHOT.md`
  - `.claude/content/BACKLOG.md`
  - `.claude/content/ARCHITECTURE.md`
- `CHANGELOG.md` (when release-level changes occur)

Contract rules:
1. Any agent may read these files.
2. Writes must preserve semantic structure and section intent.
3. Agent-specific runtime state must not be stored in business memory files.
4. Migration/update operations must preserve existing project data.
5. Concurrent sessions must use `.claude/.session-owner` lock with fields: `agent`, `pid`, `timestamp`.
6. Lock TTL is 30 minutes; stale lock may be recovered automatically.
7. Completion flow should release lock and mark session clean.
