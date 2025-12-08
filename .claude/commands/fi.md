---
description: Sprint/Phase completion protocol
---

# Completion Protocol

Execute the Completion Protocol from `CLAUDE.md`:

1. `npm run build` — verify build passes
2. Update metafiles:
   - `.claude/BACKLOG.md` — mark completed tasks `[x]`
   - `.claude/SNAPSHOT.md` — update version and status
   - `CHANGELOG.md` — add entry (if release)
   - `README.md` + `README_RU.md` — update if major features added
   - `.claude/ARCHITECTURE.md` — update if code structure changed
3. Export dialogs:
   ```bash
   npm run dialog:export
   ```
4. Git commit:
   ```bash
   git add -A && git status
   git commit -m "type: description"
   ```
5. Push & PR check:
   - Ask: "Push to remote?"
   - If yes: `git push`
   - Check: `git log origin/main..HEAD --oneline`
   - If empty → All merged, no PR needed
   - If has commits → Ask: "Create PR?"
6. Mark session clean:
   ```bash
   echo '{"status": "clean", "timestamp": "'$(date -Iseconds)'"}' > .claude/.last_session
   ```
