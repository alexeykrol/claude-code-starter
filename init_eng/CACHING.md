# Caching in Claude Code and Framework Workflow

> Technical documentation on how caching works in Claude Code CLI and why it's not a problem for claude-code-starter

---

## 🤔 Initial Concern

**User's question:**

> Another issue I encountered - Claude Code caches file contents. It's not guaranteed that when accessing the same file, Claude Code will update the information from that file. Even with explicit instruction "this is an updated file, read it again".

**Concerns:**
- CLAUDE.md loads into context → gets cached
- User edits PROJECT_INTAKE.md
- AI reads PROJECT_INTAKE.md → gets old version from cache?
- Even explicit "read again" doesn't help?

---

## 🔍 How Caching Works in Claude Code

### 1. Prompt Caching (API level)

Claude API caches the **prompt prefix**:
- System instructions (AI instructions)
- Context loaded at session start
- **Lifetime:** ~5 minutes from last use
- **Purpose:** Token savings and performance

### 2. What Gets Cached in Claude Code

**Cached:**
- System prompts (built-in AI instructions)
- **CLAUDE.md** - auto-loaded at session start
- Previous message context within session

**NOT cached:**
- **Read tool results** - each Read call reads fresh from disk
- User messages (new user messages)
- Tool calls (each tool invocation executes fresh)

### 3. Important Clarification

**Read tool ALWAYS reads from disk!**

If Read tool returns old file version even after explicit "read again" - this is a **bug in Claude Code CLI**, not normal cache behavior.

**AI does NOT control cache directly.** If this issue reproduces - report to https://github.com/anthropics/claude-code/issues

---

## ✅ Why This is NOT a Problem for the Framework

### Real Development Workflow

#### Foundation Files (cached at session start):

| File | Change Frequency | When Changed |
|------|------------------|--------------|
| `CLAUDE.md` | Once a month | Framework updates |
| `PROJECT_INTAKE.md` | Once → rarely corrected | Project start, between sprints |
| `SECURITY.md` | Stable | Rare, policy changes |
| `ARCHITECTURE.md` | Rarely | Between sprints, architectural decisions |
| `BACKLOG.md` | After features | After module completion |

**These files are edited when:**
- ✅ Project is at rest (no active development)
- ✅ Can safely restart `claude`
- ✅ Logical to start new session with updated context

#### Working Files (NOT cached, read from disk):

- `src/components/Button.tsx` - changes constantly during development
- `src/features/auth/login.ts` - active module development
- `tests/auth.test.ts` - writing tests
- Any other project files

**These files:**
- ✅ Read tool reads from disk every time
- ✅ Always fresh data
- ✅ Cache doesn't affect their reading

---

## 🎯 When Caching is an ADVANTAGE

### Typical Auth Module Development Session:

```
1. Session start
   → claude + start
   → CLAUDE.md loaded into context (cache created)
   → PROJECT_INTAKE.md read
   → Context stable

2. Developing auth/login.ts (2 hours work)
   → Read tool always reads fresh file version
   → Edits, tests, fixes
   → CLAUDE.md unchanged → cache works correctly
   → 💰 Saves tokens! (not reloading CLAUDE.md every time)

3. Module complete
   → /commit
   → Git commit created

4. Update meta-files
   → Updated BACKLOG.md (Auth module completed)
   → exit (quit claude)
   → claude + start (new session)
   → Updated BACKLOG.md loaded
```

### Token Savings

**Without cache (every message):**
```
System prompt (5000 tokens) +
CLAUDE.md (2000 tokens) +
PROJECT_INTAKE.md (1500 tokens) +
User message (100 tokens) =
8600 tokens * 50 messages = 430,000 tokens
```

**With cache:**
```
First message: 8600 tokens (cache created)
Remaining 49 messages: 100 tokens each = 4,900 tokens
Total: 13,500 tokens (97% savings!)
```

---

## 📋 Best Practices: When to Update Meta-Files

### ✅ Good Time to Update:

1. **After completing module/feature:**
   ```bash
   # Module ready
   /commit

   # Update BACKLOG.md
   code BACKLOG.md  # mark module as complete

   # Restart session
   exit
   claude
   start
   ```

2. **Between sprints:**
   ```bash
   # Sprint complete
   # Update ARCHITECTURE.md, BACKLOG.md, AGENTS.md

   # New sprint - new session
   claude
   start
   ```

3. **Architectural decisions:**
   ```bash
   # Made architectural decision
   # Updated ARCHITECTURE.md

   # Restart for new context
   exit
   claude
   start
   ```

### ❌ Bad Time to Update:

1. **Middle of module development:**
   ```
   ❌ Developing auth/login.ts
   ❌ Updated BACKLOG.md (why?)
   ❌ Continue development
   → Cache outdated, but functionally doesn't interfere
   ```

2. **Between minor edits:**
   ```
   ❌ Wrote function
   ❌ Updated AGENTS.md
   ❌ Wrote another function
   ❌ Updated AGENTS.md
   → Pointless work
   ```

---

## 🛠️ Workaround if Need to Update Meta-File Urgently

If for some reason you need to update BACKLOG.md / ARCHITECTURE.md mid-session:

### Option 1: Restart Session (recommended)
```bash
exit
claude
start
```
**Pros:** Clean context, guaranteed fresh data
**Cons:** Loses current session history

### Option 2: Explicit Read via Bash
```bash
cat BACKLOG.md
```
**Pros:** Doesn't lose session
**Cons:** Workaround, doesn't add to cache

### Option 3: Explicit AI Instruction
```
Read BACKLOG.md again, I just updated it.
Use Read tool to get fresh version.
```
**Pros:** Simple
**Cons:** Depends on whether AI listens :)

---

## 🎓 Conclusions

### Caching Meta-Files is Correct:

✅ **Stable files** - change rarely
✅ **Saves tokens** - huge savings on long sessions
✅ **Doesn't interfere with work** - working files always fresh
✅ **Matches workflow** - natural update points

### There is NO Problem!

Framework designed for this workflow:
- Meta-files stable → cache correctly
- Code changes constantly → always read fresh from disk
- Natural update points → session restart logical

### If Read Tool Caches Frequently-Changing Files:

**This is a Claude Code CLI bug!**

Report here: https://github.com/anthropics/claude-code/issues

Read tool should ALWAYS read from disk, prompt prefix caching should not affect tool results.

---

## 📚 See Also

- **WORKFLOW.md** - development processes and when to update documentation
- **CLAUDE.md** - what auto-loads at startup
- **AGENTS.md** - patterns for working with AI

---

*Document created based on real framework usage experience and Claude Code CLI technical limitations.*
