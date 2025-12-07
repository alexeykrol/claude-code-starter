---
description: Sprint/Phase completion protocol
---

# Completion Protocol

Execute the Completion Protocol from `CLAUDE.md`:

1. `npm run build` (or `make build`) — verify build passes
2. Update versions if needed (grep for version strings)
3. Update metafiles:
   - `BACKLOG.md` — mark completed tasks `[x]`, update progress
   - `SNAPSHOT.md` — update date, phase status
   - `CHANGELOG.md` — add entry
   - `ARCHITECTURE.md` — if architecture changed
4. `git add -A && git commit`
5. Ask: "Push to remote?"
6. Mark session as clean: `echo '{"status": "clean"}' > .claude/.last_session`
