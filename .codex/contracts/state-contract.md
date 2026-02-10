# Shared State Contract (Agent-Agnostic)

Primary shared memory files:
- `.claude/SNAPSHOT.md`
- `.claude/BACKLOG.md`
- `.claude/ARCHITECTURE.md`
- `CHANGELOG.md` (when release-level changes occur)

Contract rules:
1. Any agent may read these files.
2. Writes must preserve semantic structure and section intent.
3. Agent-specific runtime state must not be stored in business memory files.
4. Migration/update operations must preserve existing project data.
