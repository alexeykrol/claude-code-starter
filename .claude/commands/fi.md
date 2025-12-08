---
description: Sprint/Phase completion protocol
---

# Completion Protocol

Execute the Completion Protocol from `CLAUDE.md`:

1. `npm run build` — verify build passes
2. Update metafiles:
   - `BACKLOG.md` — mark completed tasks `[x]`
   - `SNAPSHOT.md` — update date and status
   - `CHANGELOG.md` — add entry (if release)
   - `ARCHITECTURE.md` — if architecture changed
3. Export dialogs:
   ```bash
   npm run dialog:export
   ```
4. Git commit:
   ```bash
   git add -A && git status
   git commit -m "type: description"
   ```
5. Ask: "Push to remote?"
6. Mark session clean:
   ```bash
   echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
   ```
