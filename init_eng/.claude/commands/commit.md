---
description: Create git commit with proper message
---

Create git commit following best practices.

**IMPORTANT: Don't use git add . blindly!**

## Process:

### 1. Analyze changes
Execute in parallel:
- `git status` - see all changed files
- `git diff` - see unstaged changes
- `git diff --staged` - see staged changes
- `git log --oneline -n 5` - see recent commits for style

### 2. Check what should NOT be committed
❌ DON'T add to commit:
- `.env` or `.env.local` (secrets!)
- `node_modules/`
- `dist/`, `build/`, `.next/` (build artifacts)
- Files with secrets (credentials.json, secrets.yaml, etc.)
- Temporary files (*.log, *.tmp, .DS_Store)

⚠️ If user explicitly asks to commit these files - warn about risks!

### 3. Add needed files
Add files **individually** or in groups, NOT `git add .`:
```bash
git add path/to/file1.ts path/to/file2.ts
```

Or by pattern:
```bash
git add src/**/*.ts
```

### 4. Compose commit message

**Format:**
```
<type>: <brief description> (up to 50 characters)

<detailed description - WHY, not WHAT>
- Reason for change
- What problem it solves
- Important details

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:**
- `feat`: new functionality
- `fix`: bug fix
- `refactor`: refactoring without functionality change
- `docs`: documentation
- `style`: formatting, semicolons
- `test`: adding tests
- `chore`: dependency updates, CI configuration

**Examples of good messages:**
```
feat: add user authentication with JWT

Implement JWT-based authentication to secure API endpoints.
- Add login/logout endpoints
- Create auth middleware for protected routes
- Store tokens in httpOnly cookies for security

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
fix: prevent memory leak in useEffect cleanup

Users reported app slowdown after long sessions. Root cause
was missing cleanup in dashboard useEffect hook.
- Add cleanup function to WebSocket subscription
- Clear intervals on component unmount

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 5. Create commit
Use HEREDOC for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>: <brief description>

<detailed description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 6. Check result
```bash
git log -1 --stat
```

## ⚠️ Pre-commit hook
If commit failed due to pre-commit hook:
1. See what changes hook made
2. If hook only formatted code - do amend:
   ```bash
   git add <changed files>
   git commit --amend --no-edit
   ```

## 🔐 Security check
Before commit ALWAYS check:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] .env files in .gitignore
- [ ] No confidential data in logs/comments
- [ ] Environment variables used for secrets

## 📋 Checklist
- [ ] `git status` - checked changes
- [ ] `git diff` - understand what changed
- [ ] Checked style of recent commits
- [ ] Added ONLY needed files (not `git add .`)
- [ ] Checked for secrets
- [ ] Created meaningful message (why, not what)
- [ ] Added Co-Authored-By: Claude
- [ ] `git log -1` - verified result

## 🚫 DON'T:
- ❌ `git add .` without checking what you're adding
- ❌ Commit .env files
- ❌ Vague messages ("fix", "update", "changes")
- ❌ Commit commented code
- ❌ Commit TODO comments without context
- ❌ `--no-verify` (skip hooks) without explicit user instruction

**If user didn't specify what to commit - ask them!**
