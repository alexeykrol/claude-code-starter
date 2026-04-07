# Python Framework Core - Architecture Design

**Version:** v3.0.0 proposal
**Created:** 2026-01-20
**Purpose:** Replace bash commands with Python utility for silent, fast execution

---

## Problem Statement

**Current (v2.7.0):**
- 10 bash commands run in background
- Terminal noise (task-notification spam)
- Bash-specific (platform issues)
- Hard to control output

**Goal:**
- Silent execution (zero terminal noise)
- Fast (seconds, not minutes)
- Structured output (JSON)
- Easy to debug and maintain

---

## Architecture

### Project Structure

```
src/framework-core/
├── __init__.py
├── main.py              # CLI entry point
├── commands/
│   ├── __init__.py
│   ├── cold_start.py    # Cold start implementation
│   └── completion.py    # Completion implementation
├── tasks/
│   ├── __init__.py
│   ├── git.py           # Git operations (status, diff, commit)
│   ├── config.py        # Config management (.framework-config)
│   ├── security.py      # Security checks (cleanup dialogs)
│   ├── version.py       # Version checks (GitHub API)
│   ├── session.py       # Session management (.last_session)
│   └── hooks.py         # Git hooks installation
├── utils/
│   ├── __init__.py
│   ├── logger.py        # Logging to .claude/logs/
│   ├── result.py        # JSON result formatting
│   └── parallel.py      # Parallel task execution
└── requirements.txt     # Dependencies
```

---

## CLI Interface

```bash
# Cold Start
python3 src/framework-core/main.py cold-start

# Completion
python3 src/framework-core/main.py completion

# Version
python3 src/framework-core/main.py --version
```

**Output:** JSON to stdout

---

## Output Format

### Success

```json
{
  "status": "success",
  "command": "cold-start",
  "tasks": [
    {
      "name": "migration_cleanup",
      "status": "success",
      "result": "CLEANUP:done",
      "duration_ms": 45
    },
    {
      "name": "crash_detection",
      "status": "success",
      "result": "CRASH:none",
      "duration_ms": 120
    },
    {
      "name": "version_check",
      "status": "success",
      "result": "UPDATE:none:2.7.0",
      "duration_ms": 850
    }
  ],
  "warnings": [],
  "errors": [],
  "duration_total_ms": 1234,
  "timestamp": "2026-01-20T18:42:21Z"
}
```

### Error

```json
{
  "status": "error",
  "command": "cold-start",
  "tasks": [...],
  "errors": [
    {
      "task": "git_hooks",
      "message": "Failed to install git hooks",
      "details": "Permission denied: .git/hooks/pre-commit"
    }
  ],
  "warnings": [],
  "duration_total_ms": 456,
  "timestamp": "2026-01-20T18:42:21Z"
}
```

### Critical (needs user input)

```json
{
  "status": "needs_input",
  "command": "cold-start",
  "reason": "crash_detected",
  "data": {
    "uncommitted_files": 5,
    "message": "Previous session crashed with uncommitted changes"
  }
}
```

---

## Cold Start Tasks (10)

Replaces bash commands from `.claude/protocols/cold-start-silent.md`:

| Task | Current (bash) | New (Python) |
|------|---------------|--------------|
| 1. Migration cleanup | Check/delete files | `tasks.config.migration_cleanup()` |
| 2. Crash detection | Parse .last_session, git status | `tasks.session.check_crash()` |
| 3. Version check | curl GitHub API | `tasks.version.check_update()` |
| 4. Security cleanup | bash script | `tasks.security.cleanup_dialogs()` |
| 5. Dialog export | npm run | `subprocess.run(['npm', 'run', 'dialog:export'])` |
| 6. COMMIT_POLICY | Check/create file | `tasks.config.ensure_commit_policy()` |
| 7. Git hooks | bash script | `tasks.hooks.install()` |
| 8. Config init | Check/create .framework-config | `tasks.config.init()` |
| 9. Load context | Echo file paths | Return `["SNAPSHOT.md", "BACKLOG.md", ...]` |
| 10. Mark active | Write .last_session | `tasks.session.mark_active()` |

**Execution:** All tasks run in parallel (Python threading/asyncio)

---

## Completion Tasks

| Task | Description |
|------|-------------|
| Build check | Run npm build, check exit code |
| Security cleanup | Same as cold-start |
| Dialog export | Same as cold-start |
| Git status | List staged/unstaged files |
| Git diff | Show changes |
| Metafile updates | AI does this (not utility) |
| Git commit | Execute commit with message |
| Push/PR | Optional, user confirms |

---

## Parallel Execution

```python
import concurrent.futures

def run_tasks_parallel(tasks):
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(task): task for task in tasks}
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())
    return results
```

---

## Error Handling

**Levels:**
1. **Critical** - stops execution, needs user input (crash with uncommitted)
2. **Error** - task failed, report but continue (git hooks failed)
3. **Warning** - informational (security cleanup found credentials)
4. **Success** - task completed

**Logging:**
- All tasks logged to `.claude/logs/framework-core/`
- Format: `cold-start-YYYYMMDD-HHMMSS.log`
- Structured: timestamp, task, status, duration

---

## Dependencies

```
# requirements.txt
requests>=2.31.0    # For GitHub API calls
```

**No other dependencies** - use stdlib for everything else.

---

## Integration with CLAUDE.md

**Before (bash):**
```bash
# 10 separate bash commands
bash -c "cleanup..."
bash -c "crash detection..."
...
```

**After (Python):**
```bash
# Single Python call
python3 src/framework-core/main.py cold-start
```

**AI reads JSON result:**
- If `status: "success"` → continue silently
- If `status: "error"` → show error to user
- If `status: "needs_input"` → ask user question

---

## Benefits

1. **Silent execution** - no terminal spam
2. **Fast** - parallel execution, native performance
3. **Structured output** - JSON for AI consumption
4. **Cross-platform** - Python works everywhere
5. **Easy debugging** - can run/test manually
6. **Maintainable** - proper code structure

---

## Migration Path

**Phase 1 (v3.0.0):**
- Implement Python utility
- Keep bash as fallback
- Test in parallel

**Phase 2 (v2.8.1):**
- Replace bash in protocols
- Production testing

**Phase 3 (v2.9.0):**
- Remove bash scripts
- Python as primary

**Phase 4 (v3.0):**
- Rewrite in Go (when stable)

---

## Next Steps

1. Create `src/framework-core/` structure
2. Implement `main.py` CLI
3. Implement cold-start tasks
4. Test on real project
5. Update CLAUDE.md protocols

---

*Design complete. Ready for implementation.*
