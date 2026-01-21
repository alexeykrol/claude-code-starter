# Legacy Project Migration Protocol

**Purpose:** Analyze existing project without Framework and generate Framework files based on deep analysis.

**When to use:** Legacy project with code but no `.claude/` directory.

---

## Step 0: Initialize Migration Log

Before starting, create migration log for crash recovery:

```bash
echo '{
  "status": "in_progress",
  "mode": "legacy",
  "started": "'$(date -Iseconds)'",
  "updated": "'$(date -Iseconds)'",
  "current_step": 1,
  "current_step_name": "discovery",
  "steps_completed": [],
  "last_error": null
}' > .claude/migration-log.json
```

**Update log after each step:**
```bash
# Template for updating log (replace STEP_NUM and STEP_NAME)
echo '{
  "status": "in_progress",
  "mode": "legacy",
  "started": "[keep original]",
  "updated": "'$(date -Iseconds)'",
  "current_step": STEP_NUM,
  "current_step_name": "STEP_NAME",
  "steps_completed": ["discovery", "analysis", ...],
  "last_error": null
}' > .claude/migration-log.json
```

---

## Core Principles

1. ❌ **NEVER modify existing project files** - only create `.claude/` files
2. 🎓 **User is not technical** - explain everything in simple terms
3. 🤝 **Qualifying questions** - always provide options with clear recommendations
4. 📊 **Detailed report first** - show analysis before generating files
5. 💰 **Token transparency** - track and report token usage

---

## Step 1: Initial Context

Check if migration context exists:
```bash
cat .claude/migration-context.json 2>/dev/null
```

If exists, you're in legacy migration mode. If not, ask user to run `./init-project.sh` first.

---

## Step 2: Discovery Phase

Search for potential analog files and project info.

### 2.1 Find Documentation Files

**IMPORTANT:** Scan both root AND subdirectories (docs/, documentation/, notes/, wiki/, .github/)

```bash
# Step 2.1.1: Search root directory for common meta-documentation files
echo "🔍 Scanning root directory..."
ROOT_DOCS=$(find . -maxdepth 1 -type f \( \
  -name "README*" -o \
  -name "TODO*" -o \
  -name "TASKS*" -o \
  -name "BACKLOG*" -o \
  -name "ROADMAP*" -o \
  -name "ARCHITECTURE*" -o \
  -name "DESIGN*" -o \
  -name "STATUS*" -o \
  -name "CHANGELOG*" \
\) 2>/dev/null)

# Step 2.1.2: Search subdirectories for meta-documentation
echo "🔍 Scanning subdirectories (docs/, documentation/, notes/, wiki/, .github/)..."

SUBDIRS_DOCS=""

# Scan each subdirectory if it exists
for DIR in docs documentation notes wiki .github; do
  if [ -d "$DIR" ]; then
    # Find ALL .md files in subdirectory
    SUBDIR_MD=$(find "$DIR" -type f -name "*.md" 2>/dev/null | grep -v node_modules | grep -v .git)

    if [ -n "$SUBDIR_MD" ]; then
      SUBDIRS_DOCS="$SUBDIRS_DOCS
$SUBDIR_MD"
    fi
  fi
done

# Combine results
ALL_DOCS="$ROOT_DOCS
$SUBDIRS_DOCS"
```

**Step 2.1.3: Classify by Content (Meta-documentation vs Code docs)**

For each found .md file, read first 50 lines and classify:

```bash
# Function to classify file by content
classify_doc() {
  FILE=$1
  CONTENT=$(head -50 "$FILE" 2>/dev/null)

  # Meta-documentation indicators
  META_SCORE=0
  echo "$CONTENT" | grep -qi "roadmap\|backlog\|todo\|status\|project intake\|requirements\|we decided\|our project\|architecture decision\|design decision\|security policy\|workflow\|meeting notes" && META_SCORE=$((META_SCORE + 1))

  # Code documentation indicators
  CODE_SCORE=0
  echo "$CONTENT" | grep -qi "api reference\|api documentation\|function reference\|class documentation\|how to use\|tutorial\|example:\|usage:" && CODE_SCORE=$((CODE_SCORE + 1))

  # Classify
  if [ $META_SCORE -gt $CODE_SCORE ]; then
    echo "meta"
  elif [ $CODE_SCORE -gt $META_SCORE ]; then
    echo "code"
  else
    # Ambiguous - default to meta if contains certain keywords in filename
    if echo "$FILE" | grep -qi "backlog\|roadmap\|status\|architecture\|design\|requirements"; then
      echo "meta"
    else
      echo "ambiguous"
    fi
  fi
}

# Classify all found docs
META_DOCS=""
CODE_DOCS=""
AMBIGUOUS_DOCS=""

while IFS= read -r FILE; do
  [ -z "$FILE" ] && continue

  CLASSIFICATION=$(classify_doc "$FILE")

  case $CLASSIFICATION in
    meta)
      META_DOCS="$META_DOCS
$FILE"
      ;;
    code)
      CODE_DOCS="$CODE_DOCS
$FILE"
      ;;
    ambiguous)
      AMBIGUOUS_DOCS="$AMBIGUOUS_DOCS
$FILE"
      ;;
  esac
done <<< "$ALL_DOCS"
```

### 2.2 Check Project Metadata

```bash
# Package info
cat package.json 2>/dev/null | head -20

# Git history
git log --oneline --all -50 2>/dev/null

# GitHub Issues (if available)
gh issue list --limit 50 --state all 2>/dev/null
```

### 2.3 Report Discovery Results

Show user what you found with classification:

````
🔍 Discovery Results:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 META-DOCUMENTATION (will be migrated)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Root directory:
  ✅ README.md (145 lines, has roadmap section)
  ✅ TODO.md (23 tasks)

docs/ subdirectory:
  ✅ docs/BACKLOG.md (491 lines, roadmap v0.2-v1.3) ← CRITICAL!
  ✅ docs/STATUS.md (273 lines, project status v0.3.3)
  ✅ docs/ARCHITECTURE.md (89 lines)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 CODE DOCUMENTATION (will be skipped)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

docs/ subdirectory:
  🟡 docs/api-reference.md (API documentation)
  🟡 docs/installation.md (user guide)
  🟡 docs/tutorial.md (how-to guide)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❓ AMBIGUOUS (need your input)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

docs/ subdirectory:
  ⚪ docs/project-notes.md (87 lines)
     Reason: Contains both project decisions and usage examples

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Project Info:
  • Name: [from package.json]
  • Version: [version]
  • Type: [React/Node.js/etc]

📊 History:
  • Total commits: 237
  • Recent activity: 15 commits last week
  • Contributors: 3

🐛 Issues:
  • Open: 8
  • Closed: 45

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````

**If ambiguous files found, ask user:**

````
❓ Question: How to handle ambiguous files?

I found docs/project-notes.md which contains both:
• Project decisions (meta-documentation)
• Usage examples (code documentation)

Options:
1. Migrate it (include in .claude/)
2. Skip it (leave in docs/)
3. Show me first 20 lines to decide

My recommendation: Option 3 (show content first)

Your choice? (1/2/3 or 'best')
````

---

## Step 2.5: MANDATORY Security Scan 🔒

**CRITICAL:** Before proceeding with migration, scan existing project for credentials.

**Why mandatory:**
- Legacy projects often have hardcoded secrets
- .env files may be committed
- Credentials in old commits/documentation
- **First integration = last chance to catch issues**

### 2.5.1: Run Initial Security Scan

```bash
# Run comprehensive security scan
bash security/initial-scan.sh
SCAN_EXIT=$?
```

**Exit codes:**
- `0` = Clean (no issues)
- `1` = HIGH severity issues
- `2` = CRITICAL severity issues
- `3` = MEDIUM severity issues

### 2.5.2: Handle Scan Results

**If exit code = 0 (CLEAN):**
```
✅ Security scan passed! No credentials detected.

Proceeding with migration...
```

**If exit code = 1, 2, or 3 (ISSUES FOUND):**

```
🚨 SECURITY ISSUES DETECTED

Migration STOPPED for safety.

Report: security/reports/initial-scan-[timestamp].txt
```

**STOP migration and present user with 3 options:**

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 Security Issues Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The security scan found potential credentials in your project.
For your safety, migration has been STOPPED.

Please choose how to proceed:

┌─ 📌 Option A: Create Security Report + Reminder
│
│  What it does:
│  • Saves detailed security report
│  • Creates GitHub issue as reminder
│  • You fix issues manually later
│  • Migration continues without cleanup
│
│  Pros:
│  • Quick (no changes to your project)
│  • You maintain full control
│
│  Cons:
│  • Issues remain in project until you fix them
│  • Risk of forgetting to fix
│
│  Recommended for: Experienced developers who want manual control
└─

┌─ 📌 Option B: Automatic Cleanup (Framework Handles It) ⭐ RECOMMENDED
│
│  What it does:
│  • Runs full credential cleanup (regex + AI agent)
│  • Creates .env.example template
│  • Moves secrets to .env (you fill real values later)
│  • Adds security patterns to .gitignore
│  • Creates backup before changes
│
│  Pros:
│  • Thorough and automatic
│  • Uses all security layers (regex + AI)
│  • Creates proper .env setup
│  • Safe (creates backup first)
│
│  Cons:
│  • Takes 2-3 minutes (AI scan)
│  • Makes changes to your project (with backup)
│
│  Recommended for: Most users, especially if unfamiliar with security
└─

┌─ 📌 Option C: Manual Fix + .env Setup
│
│  What it does:
│  • Shows you security report
│  • Guides you to create .env file
│  • Helps move secrets manually
│  • Updates .gitignore
│  • You control every step
│
│  Pros:
│  • Full transparency
│  • Learn security best practices
│  • No automated changes
│
│  Cons:
│  • Takes longer (manual work)
│  • Requires security knowledge
│
│  Recommended for: Developers who want to learn and control everything
└─

⭐ My Recommendation: Option B (Automatic Cleanup)

Why: Framework has battle-tested security tools (from production use).
Automatic cleanup is safe, thorough, and saves your time.

What would you like to do? (A/B/C)
````

### 2.5.3: Execute User Choice

**Option A: Security Report + Reminder**

```bash
# 1. Report already created by initial-scan.sh
REPORT=$(ls -t security/reports/initial-scan-*.txt | head -1)

echo "✅ Security report saved: $REPORT"

# 2. Create GitHub issue (if gh CLI available)
if command -v gh &> /dev/null && gh auth status &> /dev/null 2>&1; then
  gh issue create \
    --title "🔒 Security: Credentials detected during migration" \
    --body "$(cat <<EOF
## Security Scan Results

Initial security scan detected potential credentials in the project.

**Report:** $REPORT

## Action Required

Review the security report and fix the following:
- [ ] Move hardcoded credentials to .env
- [ ] Remove .env files from git history if committed
- [ ] Add security patterns to .gitignore
- [ ] Verify no secrets in documentation

## Next Steps

1. Read full report: \`$REPORT\`
2. Fix each issue listed
3. Run \`/security-dialogs\` for verification
4. Close this issue when complete

**Priority:** HIGH
**Created by:** Claude Code Starter Framework
EOF
)" \
    --label "security" \
    --label "high-priority"

  echo "✅ GitHub issue created as reminder"
else
  echo "ℹ️  Install gh CLI to auto-create reminder issues"
fi

# 3. Continue migration (issues remain)
echo ""
echo "⚠️  Continuing migration with security issues present."
echo "   Remember to fix them before committing to git!"
echo ""
```

**Option B: Automatic Cleanup** ⭐

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Automatic Security Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Create backup
BACKUP_DIR="security/backups/migration-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup..."
git ls-files | cpio -pdm "$BACKUP_DIR" 2>/dev/null
echo "✅ Backup created: $BACKUP_DIR"
echo ""

# 2. Run comprehensive cleanup (Layer 2: regex)
echo "Step 1/3: Running regex-based cleanup..."
bash security/cleanup-dialogs.sh  # All files, not --last
echo ""

# 3. Run AI-based deep scan (Layer 4)
echo "Step 2/3: Running AI agent deep scan (1-2 minutes)..."
echo "This ensures we catch obfuscated/context-dependent credentials..."
echo ""

# Invoke /security-dialogs for deep scan
# Agent will analyze all files (not just dialogs in this case)
# Will create detailed security report

# 4. Create .env setup
echo "Step 3/3: Setting up .env file..."

# Check if .env.example exists
if [ ! -f ".env.example" ]; then
  cat > .env.example <<'ENVEOF'
# Environment Variables Template
# Copy this file to .env and fill in your actual values
# NEVER commit .env to git!

# Database
# DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# API Keys
# API_KEY=your_api_key_here
# SECRET_KEY=your_secret_key_here

# Authentication
# JWT_SECRET=your_jwt_secret_here

# External Services
# STRIPE_KEY=your_stripe_key_here
# SENDGRID_API_KEY=your_sendgrid_key_here

ENVEOF
  echo "✅ Created .env.example template"
fi

# Create .env from example if doesn't exist
if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "✅ Created .env file (fill in your actual values)"
else
  echo "ℹ️  .env already exists (not overwriting)"
fi

# Update .gitignore
if [ -f ".gitignore" ]; then
  # Add security patterns if missing
  if ! grep -q "^\.env$" .gitignore; then
    cat >> .gitignore <<'GITEOF'

# Security: Environment variables and credentials
.env
.env.*
!.env.example
*credentials*
*secret*
*.pem
*.key
security/reports/
GITEOF
    echo "✅ Updated .gitignore with security patterns"
  else
    echo "✓ .gitignore already has security patterns"
  fi
else
  # Create new .gitignore
  cat > .gitignore <<'GITEOF'
# Security: Environment variables and credentials
.env
.env.*
!.env.example
*credentials*
*secret*
*.pem
*.key
security/reports/

# Dependencies
node_modules/

# Build output
dist/
build/
GITEOF
  echo "✅ Created .gitignore with security patterns"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Automatic Cleanup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "What was done:"
echo "  ✅ Created backup: $BACKUP_DIR"
echo "  ✅ Ran regex cleanup (10 credential patterns)"
echo "  ✅ Ran AI deep scan (context-aware detection)"
echo "  ✅ Created .env.example template"
echo "  ✅ Created .env file (fill in real values)"
echo "  ✅ Updated .gitignore (security patterns)"
echo ""
echo "⚠️  IMPORTANT: Edit .env and fill in your actual credentials!"
echo ""
echo "If anything went wrong, restore from backup:"
echo "  cp -r $BACKUP_DIR/* ."
echo ""
```

**Option C: Manual Fix + Guidance**

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 Manual Security Fix Guide"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show report
REPORT=$(ls -t security/reports/initial-scan-*.txt | head -1)
cat "$REPORT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step-by-Step Fix Instructions:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Create .env file:"
echo "   touch .env"
echo ""
echo "2. Move each credential from code to .env:"
echo "   Example:"
echo "   Before: const API_KEY = \"abc123\""
echo "   After in code: const API_KEY = process.env.API_KEY"
echo "   In .env: API_KEY=abc123"
echo ""
echo "3. Update .gitignore:"
echo "   echo '.env' >> .gitignore"
echo "   echo '*credentials*' >> .gitignore"
echo "   echo '*.pem' >> .gitignore"
echo ""
echo "4. Remove .env from git history (if already committed):"
echo "   git filter-branch --force --index-filter \\"
echo "     'git rm --cached --ignore-unmatch .env' \\"
echo "     --prune-empty --tag-name-filter cat -- --all"
echo ""
echo "5. Verify cleanup:"
echo "   Run: /security-dialogs"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Press Enter when you've fixed all issues to continue migration..."
```

### 2.5.4: Update Migration Log

After user choice is executed:

```bash
# Update migration log
echo '{
  "status": "in_progress",
  "mode": "legacy",
  "started": "[keep original]",
  "updated": "'$(date -Iseconds)'",
  "current_step": 3,
  "current_step_name": "deep_analysis",
  "steps_completed": ["discovery", "security_scan"],
  "security_issues_found": true,
  "security_action": "[A/B/C]",
  "last_error": null
}' > .claude/migration-log.json
```

---

## Step 3: Deep Analysis Phase

**IMPORTANT:** Use Task tool with Explore agent for thorough analysis.

```markdown
Use Task tool:
  subagent_type: "Explore"
  thoroughness: "very thorough"
  prompt: "Analyze this project structure and identify:
    1. Main modules and their purposes
    2. Tech stack and dependencies
    3. Current development phase
    4. Key architectural patterns
    5. Active development areas from recent commits"
```

After Explore agent completes, read found meta-documentation files:

```bash
# Read ALL classified meta-documentation files
# Root directory
cat README.md
cat TODO.md

# Subdirectories (docs/, documentation/, notes/)
cat docs/BACKLOG.md        # ← CRITICAL: Don't skip this!
cat docs/STATUS.md
cat docs/ARCHITECTURE.md
cat documentation/design-decisions.md
cat notes/roadmap.md
# etc for EACH file classified as "meta"
```

**IMPORTANT:** Read files from BOTH root and subdirectories.

**Specific subdirectory handling:**

| Subdirectory | Typical files | Priority |
|--------------|---------------|----------|
| `docs/` | BACKLOG.md, STATUS.md, ARCHITECTURE.md | **HIGH** |
| `documentation/` | Design decisions, requirements | HIGH |
| `notes/` | Meeting notes, project notes | MEDIUM |
| `wiki/` | Project wiki pages | MEDIUM |
| `.github/` | CONTRIBUTING.md, SECURITY.md | LOW |

Synthesize findings into project understanding.

---

## Step 4: Qualifying Questions

For each ambiguity or choice point, ask using this format:

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❓ Question: [Clear question about what needs decision]

I found multiple options:

┌─ 📌 Option 1: [Name]
│
│  What it means:
│  [Simple explanation in 1-2 sentences]
│
│  Pros:
│  • [Benefit 1]
│  • [Benefit 2]
│
│  Cons:
│  • [Drawback if any]
└─

┌─ 📌 Option 2: [Name]
│
│  What it means:
│  [Simple explanation in 1-2 sentences]
│
│  Pros:
│  • [Benefit 1]
│
│  Cons:
│  • [Drawback 1]
│  • [Drawback 2]
└─

⭐ My Recommendation: Option 1

Why I recommend this:
[Clear 2-3 sentence explanation of reasoning based on analysis]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Your choice?
  • 1 - Choose Option 1
  • 2 - Choose Option 2
  • best (or press Enter) - Сделай, как лучше (Use my recommendation)
````

**Example Questions to Ask:**

1. **BACKLOG Source:**
   - Option 1: Use TODO.md (23 tasks) as base
   - Option 2: Use GitHub Issues (8 open) as base
   - Recommendation: Based on which is more complete

2. **Development Phase:**
   - Option 1: Early Development (< v1.0)
   - Option 2: Production (≥ v1.0)
   - Recommendation: Based on version number and git history

3. **Module Priority:**
   Show 5 main modules found, ask which to focus on in SNAPSHOT

4. **Documentation Approach:**
   - Option 1: Preserve existing style from found docs
   - Option 2: Use Framework standard templates
   - Recommendation: Hybrid approach

---

## Step 5: Generate Project Report

Create comprehensive analysis report and show to user BEFORE generating files.

````markdown
# 📊 Legacy Project Analysis Report

*Generated: [timestamp]*
*Token Usage: ~[estimate]k tokens*

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📦 Project Overview

| Property | Value |
|----------|-------|
| **Name** | [from package.json] |
| **Version** | [version] |
| **Tech Stack** | React 18, TypeScript, Node.js |
| **Lines of Code** | ~15,000 |
| **Development Phase** | [Early/Beta/Production] |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📁 Project Structure

```
[project-name]/
├── src/
│   ├── components/     # React components (35 files)
│   │   ├── Auth/       # Authentication UI
│   │   ├── Dashboard/  # Main dashboard
│   │   └── Common/     # Shared components
│   ├── services/       # API services (8 files)
│   │   ├── api.ts      # HTTP client
│   │   └── auth.ts     # Auth service
│   ├── utils/          # Helper functions (12 files)
│   ├── types/          # TypeScript types
│   └── index.tsx       # Entry point
├── tests/              # Test files
└── docs/               # Documentation
```

**Key Modules:**
1. **Authentication** - Login, signup, session management
2. **Dashboard** - Main user interface
3. **API Layer** - Backend communication
4. **Common Components** - Reusable UI elements
5. **Utils** - Helper functions and utilities

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 Current Development State

**Phase:** Production (v2.3.1)

**Recent Activity (last 30 days):**
- Total commits: 47
- Active areas:
  • Authentication refactoring (15 commits)
  • API v2 migration (12 commits)
  • UI improvements (20 commits)

**Active Contributors:** 3 developers

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📚 Found Documentation

### Root Directory

#### README.md ✅
- **Location:** Root
- **Size:** 156 lines
- **Contains:**
  • Installation instructions
  • API documentation
  • Roadmap section (v3.0 plans)
- **Quality:** Good, well-maintained
- **Will use for:** ROADMAP.md base

#### TODO.md ✅
- **Location:** Root
- **Size:** 45 lines
- **Contains:** 23 active tasks
- **Categories:**
  • Bugs: 3 items
  • Features: 15 items
  • Refactoring: 5 items
- **Quality:** Up-to-date (last modified 2 days ago)
- **Will use for:** BACKLOG.md base (partial)

### docs/ Subdirectory ⭐ NEW SCAN

#### docs/BACKLOG.md ✅ ← CRITICAL!
- **Location:** docs/
- **Size:** 491 lines (!)
- **Contains:**
  • Complete roadmap (v0.2.0 → v1.3.0)
  • 87 active tasks across 12 phases
  • Architecture migration plan
- **Quality:** Comprehensive, actively maintained
- **Priority:** **HIGH** - This is the actual project roadmap!
- **Will use for:** BACKLOG.md + ROADMAP.md (primary source)

#### docs/STATUS.md ✅
- **Location:** docs/
- **Size:** 273 lines
- **Contains:**
  • Current project status (v0.3.3)
  • Recent achievements
  • Ongoing work breakdown
- **Quality:** Detailed, up-to-date
- **Will use for:** SNAPSHOT.md (current state)

#### docs/ARCHITECTURE.md ✅
- **Location:** docs/
- **Size:** 89 lines
- **Contains:**
  • Component hierarchy
  • State management approach
  • Missing: service layer docs
- **Quality:** Good but incomplete
- **Will use for:** ARCHITECTURE.md base

### Not Found

#### CHANGELOG.md ❌
- **Status:** Not found in root or docs/
- **Impact:** Will extract version history from git log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Recommendations for Framework Files

### .claude/SNAPSHOT.md

**Based on:**
- package.json v2.3.1
- Git log (recent commits)
- README.md overview

**Will contain:**
```markdown
Current Version: 2.3.1
Development Phase: Production

Current Sprint: API v2 Migration
Progress: ~60%

Active Modules:
- Authentication (refactoring)
- API Services (v2 migration)
- Dashboard UI (improvements)

Recent Achievements:
- Completed: User profile redesign
- Completed: Database optimization
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/BACKLOG.md

**Based on:**
- TODO.md (23 tasks)
- GitHub Issues (8 open)

**Will contain:**
```markdown
## Phase: API v2 Migration
- [ ] Complete auth endpoints migration
- [ ] Update API documentation
- [ ] Add error handling for edge cases

## Priority Bugs
- [ ] Fix login redirect loop (#45)
- [ ] Resolve token refresh race condition (#48)

## Planned Features
- [ ] Add password reset flow
- [ ] Implement 2FA
...
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/ROADMAP.md

**Based on:**
- README.md roadmap section

**Will contain:**
```markdown
## v2.4 (Q1 2025)
- Complete API v2 migration
- Add 2FA support

## v3.0 (Q2 2025)
- GraphQL API layer
- Real-time notifications
- Mobile app support
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/ARCHITECTURE.md

**Based on:**
- docs/architecture.md
- Code structure analysis

**Will contain:**
```markdown
## Architecture Overview
[React + TypeScript + REST API]

## Component Hierarchy
[Detailed structure]

## Service Layer (NEW)
[Documented from code analysis]

## Data Flow
[Request → Service → API → Store → UI]
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### .claude/IDEAS.md

**Status:** Empty template

Will be used for future spontaneous ideas.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💰 Estimated Cost

**Token Usage:**
- Discovery: ~5k tokens
- Analysis: ~15k tokens
- Report generation: ~3k tokens
- File generation: ~8k tokens
**Total: ~31k tokens (~$0.09 USD)**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````

After showing report, ask:
```
✅ Ready to generate Framework files based on this analysis.

Does this analysis look correct?

Options:
1. Yes, generate files (recommended)
2. No, let me provide corrections
3. Show me the analysis for specific section first

Your choice? (1/2/3)
```

---

## Step 6: Generate Framework Files (Parallel - v3.1.0)

**NEW in v3.1.0:** Parallel file generation using Task tool for 5x speedup.

**Before (v3.0.0):** Sequential generation - 5 files × 40s = 200s (~3 minutes)
**After (v3.1.0):** Parallel generation - max(40s) = 40s (~5x faster!)

Based on approved report, use TodoWrite to track progress:

```markdown
Create todos:
- [ ] Generate .claude/SNAPSHOT.md
- [ ] Generate .claude/BACKLOG.md
- [ ] Generate .claude/ROADMAP.md
- [ ] Generate .claude/ARCHITECTURE.md
- [ ] Generate .claude/IDEAS.md
```

**CRITICAL:** Launch ALL 5 agents in PARALLEL using single message with multiple Task calls.

### 6.1: Prepare Shared Context

Before launching agents, prepare shared analysis context that all agents will use:

```markdown
SHARED_CONTEXT = {
  "project_name": "[from package.json]",
  "version": "[from package.json]",
  "tech_stack": "[React/Node.js/etc]",
  "modules": ["Module1", "Module2", ...],
  "found_docs": {
    "README": "path and summary",
    "TODO": "path and summary",
    "BACKLOG": "path and summary or 'not found'",
    "ARCHITECTURE": "path and summary or 'not found'"
  },
  "git_stats": {
    "total_commits": 237,
    "recent_activity": "15 commits last week",
    "contributors": 3
  },
  "active_tasks": ["Task 1", "Task 2", ...],
  "current_phase": "Phase 4: Authentication refactoring"
}
```

### 6.2: Launch Parallel File Generation

**IMPORTANT:** Send ONE message with 5 Task tool calls (not 5 separate messages!)

```markdown
Launch 5 agents in parallel:

Task(
  subagent_type: "general-purpose",
  description: "Generate SNAPSHOT.md",
  prompt: "Generate .claude/SNAPSHOT.md based on analysis context.

  CONTEXT:
  {SHARED_CONTEXT}

  REQUIREMENTS:
  - Target size: 30-50 lines
  - Include: version, current phase, active modules, recent achievements
  - Use ACTUAL data from context (not placeholders)
  - Keep concise - this is read EVERY Cold Start!

  TEMPLATE:
  # SNAPSHOT — [project_name]

  **Version:** [version] | **Phase:** [current_phase] | **Progress:** [X]%

  ## Active Modules
  [List 3-5 main modules from context]

  ## Recent Achievements
  [Extract from git_stats]

  ## Current Focus
  [Extract from active_tasks]

  Use Write tool to create .claude/SNAPSHOT.md"
)

Task(
  subagent_type: "general-purpose",
  description: "Generate BACKLOG.md",
  prompt: "Generate .claude/BACKLOG.md based on analysis context.

  CONTEXT:
  {SHARED_CONTEXT}

  REQUIREMENTS:
  - Target size: 50-100 lines
  - Include ONLY active tasks (current sprint)
  - Extract from found_docs['BACKLOG'] or found_docs['TODO']
  - Future features → will go to ROADMAP.md (not here)
  - This is read EVERY Cold Start - keep lean!

  PRIORITY OF SOURCES:
  1. docs/BACKLOG.md (if exists) - extract current sprint only
  2. TODO.md (root) - extract active tasks
  3. GitHub Issues - use open issues

  Use Write tool to create .claude/BACKLOG.md"
)

Task(
  subagent_type: "general-purpose",
  description: "Generate ROADMAP.md",
  prompt: "Generate .claude/ROADMAP.md based on analysis context.

  CONTEXT:
  {SHARED_CONTEXT}

  REQUIREMENTS:
  - Target size: 50-150 lines
  - Include: future phases, strategic plans
  - Extract from README roadmap section or docs/BACKLOG.md future phases
  - This is read ON DEMAND (not every session) - can be more detailed

  SOURCES:
  - README.md roadmap section
  - docs/BACKLOG.md Phase 5+ (planned/future)
  - TODO.md future features

  Use Write tool to create .claude/ROADMAP.md"
)

Task(
  subagent_type: "general-purpose",
  description: "Generate ARCHITECTURE.md",
  prompt: "Generate .claude/ARCHITECTURE.md based on analysis context.

  CONTEXT:
  {SHARED_CONTEXT}

  REQUIREMENTS:
  - Target size: 100-200 lines
  - Document: modules, folder structure, tech stack, patterns
  - Preserve content from docs/ARCHITECTURE.md if exists
  - Add missing sections (service layer, data flow)
  - Use REAL file/folder names from project

  SOURCES:
  - docs/ARCHITECTURE.md (if exists) - use as base
  - Code analysis from modules
  - package.json dependencies

  Use Write tool to create .claude/ARCHITECTURE.md"
)

Task(
  subagent_type: "general-purpose",
  description: "Generate IDEAS.md",
  prompt: "Generate .claude/IDEAS.md based on analysis context.

  CONTEXT:
  {SHARED_CONTEXT}

  REQUIREMENTS:
  - Target size: 30-50 lines
  - Empty template OR extract 'rejected' ideas from TODO comments
  - This is brainstorming space for future improvements

  Use Write tool to create .claude/IDEAS.md"
)
```

### 6.3: Wait for All Agents to Complete

All 5 agents run in parallel. Wait for all to finish before proceeding.

### 6.4: Verify Results

After all agents complete:

```bash
# Check all files created
ls -lh .claude/*.md

# Show file sizes (should match targets)
du -sh .claude/SNAPSHOT.md    # ~30-50 lines
du -sh .claude/BACKLOG.md     # ~50-100 lines
du -sh .claude/ROADMAP.md     # ~50-150 lines
du -sh .claude/ARCHITECTURE.md # ~100-200 lines
du -sh .claude/IDEAS.md       # ~30-50 lines

# Quick preview
head -10 .claude/SNAPSHOT.md
head -10 .claude/BACKLOG.md
```

Mark all todos as completed.

**File Generation Guidelines:**

> **Token Economy Principle:**
> Some files are read EVERY Cold Start session — keep them compact!
> Historical/strategic content goes to on-demand files.

| File | Read When | Target Size |
|------|-----------|-------------|
| `SNAPSHOT.md` | ALWAYS (Cold Start) | ~30-50 lines |
| `BACKLOG.md` | ALWAYS (Cold Start) | ~50-100 lines |
| `ARCHITECTURE.md` | ALWAYS (Cold Start) | ~100-200 lines |
| `ROADMAP.md` | On demand | ~50-150 lines |
| `IDEAS.md` | On demand | ~30-50 lines |
| `CHANGELOG.md` | On demand | No limit |

### SNAPSHOT.md (~30-50 lines)
- Use actual version from package.json
- Reference real modules from analysis
- Include actual recent achievements from git log
- Set realistic progress percentages
- Keep concise — this is read every session!

### BACKLOG.md

**Philosophy:** BACKLOG.md should be lean (~50-100 lines max), containing ONLY current sprint tasks.

**Content distribution:**

| Source Content | Goes To |
|----------------|---------|
| Active tasks / Current sprint | → `BACKLOG.md` |
| Future features / Planned | → `ROADMAP.md` |
| Resolved / Completed issues | → DELETE (not needed) |
| Release history | → `CHANGELOG.md` or skip |

**IMPORTANT: Check subdirectories first!**

**Priority of sources:**

1. **docs/BACKLOG.md** (if exists) ← **HIGHEST PRIORITY**
   - If found: Use as primary source
   - Extract ONLY active tasks (current sprint)
   - Move strategic plans to ROADMAP.md
   - Compress to ~100 lines max

2. **TODO.md** (root) ← Secondary
   - If no docs/BACKLOG.md found
   - Extract active tasks only

3. **GitHub Issues** ← Tertiary
   - If neither found
   - Use open issues as tasks

**Guidelines:**
- **Always scan docs/ FIRST** before using root TODO.md
- Extract ONLY active tasks from source
- Do NOT copy resolved issues or historical content
- Strategic plans → ROADMAP.md (not BACKLOG)
- Target size: < 100 lines
- Link to GitHub Issues if applicable

**Example: When docs/BACKLOG.md exists (491 lines)**

```markdown
# Original: docs/BACKLOG.md (491 lines)
## Phase 1 [DONE]
## Phase 2 [DONE]
## Phase 3 [DONE]
## Phase 4 [IN PROGRESS]
- [ ] Task A
- [ ] Task B
## Phase 5 [PLANNED]
## Phase 6-12 [FUTURE]

# After migration: .claude/BACKLOG.md (~100 lines)
## Current Sprint (Phase 4)
- [ ] Task A
- [ ] Task B

# After migration: .claude/ROADMAP.md
## Phase 5 (Q1 2025)
## Phase 6-12 (Future)
```

**Example structure:**
```markdown
# BACKLOG — [Project Name]

*Current Sprint: [date]*
*Source: docs/BACKLOG.md (extracted active tasks)*

> 📋 Active tasks only. Strategic planning → [ROADMAP.md](./ROADMAP.md)

## Current Sprint
- [ ] Task 1
- [ ] Task 2

## Bugs
- [ ] Bug to fix
```

### ROADMAP.md
- Use roadmap from README if exists
- Otherwise, infer from TODO.md categories
- Preserve user's original vision
- Add version numbers from git history

### ARCHITECTURE.md
- Document actual structure from code analysis
- Preserve existing architecture.md content
- Add missing sections (service layer, data flow)
- Use real file/folder names from project

### IDEAS.md
- Create empty template
- Can optionally add "rejected" ideas from old TODO comments

---

## Step 7: Final Verification

After generating all files, run verification:

```bash
# Check all files created
ls -lh .claude/

# Show file sizes
du -sh .claude/*.md

# Quick content preview
head -5 .claude/SNAPSHOT.md
head -5 .claude/BACKLOG.md
head -5 .claude/ROADMAP.md
```

---

## Step 7.5: Install Remaining Framework Files

After analysis and meta file generation, install remaining Framework files:

```bash
# Extract staged framework files
if [ -f ".claude/framework-pending.tar.gz" ]; then
    tar -xzf .claude/framework-pending.tar.gz -C /tmp/

    # Copy ALL new commands (use -n to not overwrite existing)
    cp -n /tmp/framework/.claude/commands/*.md .claude/commands/ 2>/dev/null || true

    # Copy dist (CLI tools)
    cp -r /tmp/framework/.claude/dist .claude/ 2>/dev/null || true

    # Copy templates
    cp -r /tmp/framework/.claude/templates .claude/ 2>/dev/null || true

    # Copy FRAMEWORK_GUIDE.md
    cp /tmp/framework/FRAMEWORK_GUIDE.md . 2>/dev/null || true

    # Install npm dependencies for CLI tools
    if [ -f ".claude/dist/claude-export/package.json" ]; then
        echo "📦 Installing framework dependencies..."
        if command -v npm &> /dev/null; then
            (cd .claude/dist/claude-export && npm install --silent 2>&1 | grep -v "^npm WARN" || true) && \
                echo "✅ Framework dependencies installed" || \
                echo "⚠️  Failed to install dependencies (run manually: cd .claude/dist/claude-export && npm install)"
        else
            echo "⚠️  npm not found - install it, then run: cd .claude/dist/claude-export && npm install"
        fi
    fi

    # Cleanup temp
    rm .claude/framework-pending.tar.gz
    rm -rf /tmp/framework
fi
```

### 7.5.1 Remove Old v1.x Migration Commands

Old migration commands from v1.x are not compatible with v2.2:

```bash
# Remove obsolete v1.x migration commands
rm .claude/commands/migrate.md 2>/dev/null
rm .claude/commands/migrate-finalize.md 2>/dev/null
rm .claude/commands/migrate-resolve.md 2>/dev/null
rm .claude/commands/migrate-rollback.md 2>/dev/null
echo "✅ Removed obsolete v1.x migration commands"
```

### 7.5.2 Verify New Commands Installed

```bash
# Check essential new commands exist
ls -la .claude/commands/fi.md
ls -la .claude/commands/ui.md
ls -la .claude/commands/watch.md
```

This installs:
- All slash commands (fi, ui, watch, etc.)
- CLI tools for dialog export
- Templates for future use
- Framework guide

---

## Step 8: Migration Summary

Show simple completion message:

````
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Миграция завершена!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Framework Files Created:

  ✅ .claude/SNAPSHOT.md
  ✅ .claude/BACKLOG.md
  ✅ .claude/ROADMAP.md
  ✅ .claude/ARCHITECTURE.md
  ✅ .claude/IDEAS.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Analysis Summary:

  • Files analyzed: [count]
  • Token usage: ~[count]k tokens (~$[cost] USD)
  • Your existing files: ✅ NOT modified

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````

---

## Step 9: Finalize Migration

### 9.1 Save Migration Artifacts

Get project name and save migration artifacts with unique names:

```bash
PROJECT_NAME=$(basename "$(pwd)")

# Create reports directory
mkdir -p reports

# Save migration log with project name
cp .claude/migration-log.json "reports/${PROJECT_NAME}-migration-log.json"
echo "✅ Migration log saved: reports/${PROJECT_NAME}-migration-log.json"
```

**CRITICAL: Generate Migration Report NOW**

Before proceeding to cleanup, you MUST create the migration report:

1. Read `.claude/migration-log.json` to get migration details
2. Create `reports/${PROJECT_NAME}-MIGRATION_REPORT.md` with:
   - **Summary:** Migration type, versions, status, duration
   - **Files Migrated/Created:** List all files with sizes
   - **Changes Made:** Key restructuring, optimizations
   - **Verification Results:** All checks passed
   - **Errors/Warnings:** Any issues encountered (or "None")
   - **Post-Migration Actions:** What user needs to do next
   - **Rollback Procedure:** If needed
   - **Success Criteria:** Checklist of what was accomplished

3. **Verify report created:**
   ```bash
   ls -lh "reports/${PROJECT_NAME}-MIGRATION_REPORT.md"
   ```

4. **ONLY AFTER** confirming report exists, proceed to Step 9.2

**DO NOT proceed to cleanup until migration report is created and verified!**

### 9.2 Swap CLAUDE.md to Production

```bash
# Swap migration CLAUDE.md with production version
if [ -f ".claude/CLAUDE.production.md" ]; then
    cp .claude/CLAUDE.production.md CLAUDE.md
    rm .claude/CLAUDE.production.md
    echo "✅ Swapped CLAUDE.md to production mode"
fi
```

### 9.3 Remove Migration Commands

Migration commands are not needed in host projects after migration:

```bash
rm .claude/commands/migrate-legacy.md 2>/dev/null
rm .claude/commands/upgrade-framework.md 2>/dev/null
echo "✅ Removed migration commands"
```

### 9.4 Archive Migrated Subdirectories

**IMPORTANT:** Move migrated meta-documentation subdirectories to archive.

**Purpose:** Establish .claude/ as single source of truth.

```bash
# Archive docs/ if meta-documentation was migrated from there
if [ -d "docs" ]; then
  # Check if docs/ contains migrated meta-docs
  META_MIGRATED=false

  # Check if any meta-docs were found in docs/
  for FILE in BACKLOG.md STATUS.md ARCHITECTURE.md ROADMAP.md; do
    if [ -f "docs/$FILE" ]; then
      META_MIGRATED=true
      break
    fi
  done

  if [ "$META_MIGRATED" = true ]; then
    echo "📦 Archiving docs/ directory..."
    mkdir -p archive/legacy-docs
    mv docs archive/legacy-docs/docs-$(date +%Y%m%d)
    echo "✅ Migrated docs/ archived to: archive/legacy-docs/docs-$(date +%Y%m%d)"
    echo ""
    echo "⚠️  IMPORTANT: .claude/ is now the single source of truth"
    echo "   - Use .claude/BACKLOG.md (not docs/BACKLOG.md)"
    echo "   - Use .claude/SNAPSHOT.md (not docs/STATUS.md)"
    echo ""
  else
    echo "ℹ️  docs/ contains only code documentation - keeping in place"
  fi
fi

# Archive other subdirectories if needed
for DIR in documentation notes wiki; do
  if [ -d "$DIR" ]; then
    # Similar check and archive logic
    # ...
  fi
done
```

**What gets archived:**

| Subdirectory | When to archive | Why |
|--------------|-----------------|-----|
| `docs/` | Contains migrated meta-docs (BACKLOG, STATUS, etc.) | Prevent confusion - .claude/ is source of truth |
| `documentation/` | Contains migrated meta-docs | Same reason |
| `notes/` | Contains migrated project notes | Same reason |
| `wiki/` | Contains migrated wiki pages | Same reason |

**What stays:**

| Subdirectory | Keep if contains | Why |
|--------------|-----------------|-----|
| `docs/` | Only code documentation (API reference, tutorials) | Not meta-docs, still useful |
| `.github/` | CONTRIBUTING.md, SECURITY.md | Active files, not archived |

### 9.5 Cleanup Temporary Files

```bash
rm .claude/migration-log.json 2>/dev/null
rm .claude/migration-context.json 2>/dev/null
rm .claude/framework-pending.tar.gz 2>/dev/null
echo "✅ Migration cleanup complete"
```

### 9.6 Commit Migration Changes

Commit all migration changes so next Cold Start is clean:

```bash
git add -A
git commit -m "$(cat <<'EOF'
chore: Migrate to Claude Code Starter Framework v2.2

- Migrated metafiles to .claude/ structure
- Added SNAPSHOT.md, BACKLOG.md, ROADMAP.md, IDEAS.md, ARCHITECTURE.md
- Installed Framework commands and CLI tools
- Archived old Init/ folder to .archive/

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
echo "✅ Migration changes committed"
```

### 9.7 Show Final Message

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Migration Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Framework is now in production mode.

📁 Migration artifacts saved:
  • reports/[PROJECT]-migration-log.json
  • reports/[PROJECT]-MIGRATION_REPORT.md

📦 Archived subdirectories (if applicable):
  • archive/legacy-docs/docs-[DATE]/ (old meta-documentation)

⭐ Single Source of Truth:
  • Use .claude/BACKLOG.md (NOT docs/BACKLOG.md)
  • Use .claude/SNAPSHOT.md (NOT docs/STATUS.md)
  • Use .claude/ARCHITECTURE.md (NOT docs/ARCHITECTURE.md)

⚠️ IMPORTANT: Restart terminal for new commands!

  New slash commands (/fi, /ui, /watch) won't work
  until you restart the terminal or Claude session.

🚀 Next Steps:

  1. Exit terminal (Ctrl+C or type "exit")
  2. Start new Claude session: claude
  3. Type "start" to begin working

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Error Handling

### If discovery finds no documentation:

```
⚠️ Warning: No existing documentation found

I can still create Framework files, but they will be based primarily on:
- Code structure analysis
- Git history
- package.json metadata

Options:
1. Continue with code-based analysis (will be less detailed)
2. Cancel and let you create basic docs first (README, TODO)

Recommendation: Option 1 - Framework can help you build docs

Your choice?
```

### If analysis is incomplete:

```
⚠️ Analysis incomplete

Could not access:
- GitHub Issues (gh command not available)
- Some files (permission denied)

What I was able to analyze:
- Project structure: ✅
- README.md: ✅
- TODO.md: ✅
- Git history: ✅

Continue with partial analysis? (y/N)
```

### If token budget concerns:

```
⚠️ Large project detected

Estimated token usage: ~50k tokens (~$0.15 USD)

This is higher than typical because:
- Large codebase (30k+ lines)
- Many documentation files
- Long git history

Options:
1. Continue with full analysis (recommended for quality)
2. Use quick analysis (skip detailed code analysis, ~20k tokens)

Your choice?
```

---

## Important Notes

- **Never modify existing project files**
- **Always explain in simple terms**
- **Always provide recommendations, not just options**
- **Track token usage and report at end**
- **Show report before generating files**
- **Use TodoWrite to track generation progress**
- **Verify all files created successfully**

---

*This protocol ensures high-quality Framework integration into existing projects while preserving all original work.*
