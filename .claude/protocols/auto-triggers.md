# Auto-Trigger System

**Version:** 2.7.0
**Last updated:** 2026-01-20

**Purpose:** Automatically detect when to run Completion Protocol. User doesn't manually type `/fi` — framework detects task completion and commits automatically or suggests commit.

---

## Philosophy

**Old way:**
- User finishes task
- User remembers to type `/fi`
- Completion protocol runs
- User confirms multiple times

**New way:**
- User finishes task
- User says "готово" or "done" (natural)
- Framework auto-detects completion
- Runs Completion automatically (or asks once)

**Goal:** User doesn't think about `/fi` command. Framework handles it.

---

## Trigger Detection

**Framework analyzes EVERY user message for completion signals:**

### Detection Points:

**After each user message:**
```typescript
// AI analyzes user's message
user_message = get_last_user_message()

// Check for explicit triggers
if (detect_explicit_completion(user_message)) {
  // User said "готово", "done", etc.
  run_completion_protocol()
  return
}

// Check for implicit triggers
if (detect_implicit_completion(user_message, context)) {
  // User described task completion
  suggest_commit()
  return
}

// Check git status periodically
if (should_check_git_status()) {
  if (detect_significant_changes()) {
    suggest_commit()
    return
  }
}

// Check idle time
if (detect_idle_time()) {
  suggest_commit()
  return
}
```

---

## Trigger Types

### 1. Explicit Completion Keywords

**Instant trigger - no confirmation needed:**

```typescript
explicit_keywords = [
  // Russian
  "готово",
  "сделано",
  "сделал",
  "завершил",
  "завершено",
  "закончил",
  "закончено",
  "выполнено",
  "всё",
  "все сделал",
  "можно коммитить",
  "коммить",

  // English
  "done",
  "finished",
  "complete",
  "completed",
  "ready to commit",
  "let's commit",
  "commit this",
  "commit it",
  "all done",
  "task done"
]

// Exact match or at start of message
if (user_message.toLowerCase() in explicit_keywords ||
    user_message.toLowerCase().startsWith(keyword + " ")) {

  // Trigger immediately
  run_completion_protocol(mode: "auto")
}
```

**Example:**
```
User: "Готово, всё работает"
Framework: (runs Completion silently)
Framework: "✓ Committed (a3f82d1)"
```

---

### 2. Implicit Completion Signals

**AI analyzes message for completion intent:**

```typescript
implicit_patterns = [
  // Task completion
  "задача завершена",
  "фича готова",
  "баг исправлен",
  "ошибка пофикшена",
  "тесты проходят",
  "всё работает",
  "проблема решена",

  // Satisfaction signals
  "отлично",
  "идеально",
  "супер",
  "круто получилось",

  // Quality signals
  "код чистый",
  "всё протестировал",
  "проверил",
  "работает как надо",

  // Request for next steps
  "что дальше",
  "следующая задача",
  "переходим к",

  // English equivalents
  "task completed",
  "feature ready",
  "bug fixed",
  "tests passing",
  "it works",
  "looks good",
  "all good"
]

// Fuzzy match or semantic similarity
if (message_indicates_completion(user_message, patterns)) {

  // Suggest commit
  suggest: "Commit changes? (Y/n)"

  if (user_confirms) {
    run_completion_protocol(mode: "confirmed")
  }
}
```

**Example:**
```
User: "Отлично, баг пофикшен и тесты проходят"
Framework: "Commit changes? (Y/n)"
User: "y"
Framework: "✓ Committed (f8c21a4)"
```

---

### 3. Significant Changes Detection

**Check git periodically (every N messages):**

```bash
# Check every 5 user messages
if [ $((MESSAGE_COUNT % 5)) -eq 0 ]; then

  # Get lines changed
  LINES=$(git diff --stat | tail -1 | grep -o '[0-9]\+ insertion' | grep -o '[0-9]\+' | head -1)

  # If significant changes
  if [ "$LINES" -gt 100 ]; then
    echo "TRIGGER:significant_changes:${LINES}"
  fi

  # Get files changed
  FILES=$(git diff --name-only | wc -l | tr -d ' ')

  # If many files
  if [ "$FILES" -gt 5 ]; then
    echo "TRIGGER:many_files:${FILES}"
  fi

fi
```

**Thresholds:**
- 100+ lines changed → suggest commit
- 5+ files modified → suggest commit
- 30+ minutes since last commit → suggest commit

**Example:**
```
Framework: (silent check after 5 messages)
Framework: (detects 150 lines changed)
Framework: "150+ lines changed. Commit? (Y/n)"
User: "y"
Framework: "✓ Committed (d9e32b1)"
```

---

### 4. Idle Time Detection

**Track last user activity:**

```bash
# Update timestamp after each user message
echo "$(date +%s)" > .claude/.last_activity

# Check idle time periodically
LAST=$(cat .claude/.last_activity 2>/dev/null || echo 0)
NOW=$(date +%s)
IDLE=$((NOW - LAST))

# Thresholds
if [ "$IDLE" -gt 1800 ] && ! git diff --quiet; then
  # 30 min idle + uncommitted changes
  echo "TRIGGER:idle:${IDLE}"
fi
```

**Idle thresholds:**
- 30 min idle + changes → suggest commit
- 60 min idle + changes → stronger suggestion
- 120 min idle + changes → "Session ending? Commit now?"

**Example:**
```
Framework: (silent check, 30 min passed)
Framework: (detects uncommitted changes)
Framework: "Idle 30min. Commit changes? (Y/n)"
```

**Note:** Disabled by default (can be annoying). Enable with config.

---

### 5. Context Analysis (Advanced)

**AI analyzes conversation context:**

```typescript
// Analyze last 10 messages
context = get_last_messages(10)

// Signals of task completion:
signals = {
  user_asked_for_implementation: true,
  ai_implemented_solution: true,
  user_confirmed_it_works: true,
  no_follow_up_questions: true,
  conversation_winding_down: true
}

// Completion score
score = calculate_completion_score(context, signals)

// High confidence → suggest commit
if (score > 0.8) {
  suggest: "Task complete. Commit? (Y/n)"
}

// Medium confidence → ask if done
if (score > 0.5 && score <= 0.8) {
  ask: "Ready to commit? (y/N)"  // default No
}

// Low confidence → don't suggest
if (score <= 0.5) {
  // Continue working
}
```

**Signals analyzed:**
- User satisfaction ("отлично", "супер")
- No errors mentioned recently
- Implementation followed by confirmation
- User moves to new topic
- "What's next?" type questions

**Example:**
```
User: "Можешь добавить Decision Log?"
AI: (implements Decision Log)
AI: "Добавил Decision Log с 5 решениями"
User: "Супер, выглядит отлично"
Framework: (analyzes context, score: 0.85)
Framework: "Task complete. Commit? (Y/n)"
```

---

## Configuration

**Settings in `.claude/.framework-config`:**

```json
{
  "auto_triggers": {
    "enabled": true,                    // Master switch

    // Trigger types
    "explicit_keywords": true,          // "готово", "done" → instant
    "implicit_signals": true,           // "задача завершена" → suggest
    "significant_changes": true,        // 100+ lines → suggest
    "idle_time": false,                 // 30min idle → suggest (off by default)
    "context_analysis": true,           // AI analyzes conversation → suggest

    // Thresholds
    "lines_threshold": 100,             // Lines changed to trigger
    "files_threshold": 5,               // Files changed to trigger
    "idle_threshold": 1800,             // Seconds (30 min)
    "check_interval": 5,                // Check git every N messages

    // Behavior
    "auto_commit_on_explicit": false,   // Auto-commit when "готово" (or ask)
    "confirm_on_implicit": true,        // Ask confirmation for implicit triggers
    "show_trigger_reason": false        // Show why triggered (debugging)
  }
}
```

**Presets:**

```json
// Preset: "manual" (no auto-triggers, old behavior)
{
  "enabled": false  // User must type /fi manually
}

// Preset: "assisted" (suggests, doesn't auto-commit)
{
  "enabled": true,
  "auto_commit_on_explicit": false,  // Even "готово" asks confirmation
  "confirm_on_implicit": true
}

// Preset: "autopilot" (fully automated)
{
  "enabled": true,
  "auto_commit_on_explicit": true,   // "готово" → auto-commits
  "confirm_on_implicit": false       // Implicit → auto-commits too (risky!)
}

// Preset: "balanced" (recommended default)
{
  "enabled": true,
  "auto_commit_on_explicit": true,   // "готово" → commits
  "confirm_on_implicit": true,       // Others → asks
  "idle_time": false                 // No idle triggers (annoying)
}
```

---

## Integration with CLAUDE.md

**Add to CLAUDE.md after each user message:**

```markdown
## Auto-Trigger Check (After Each User Message)

**After AI responds to user, check for completion triggers:**

```typescript
// 1. Check explicit keywords
if (user_message matches explicit_keywords) {
  // Instant trigger
  if (auto_commit_on_explicit === true) {
    run_completion_protocol()
  } else {
    ask: "Commit? (Y/n)"
  }
}

// 2. Check implicit signals
if (user_message indicates_completion) {
  suggest: "Commit changes? (Y/n)"
}

// 3. Check git periodically (every 5 messages)
if (message_count % 5 === 0) {
  check_significant_changes()
  check_idle_time()
}

// 4. Context analysis (every message if enabled)
if (context_analysis === true) {
  score = analyze_completion_probability()
  if (score > threshold) {
    suggest: "Task complete. Commit? (Y/n)"
  }
}
```

**This runs AFTER every AI response, before waiting for next user message.**

---

## Examples

### Example 1: Explicit Keyword

```
User: "Добавь Decision Log в SNAPSHOT"
AI: (implements Decision Log)
AI: "Добавил Decision Log с 5 решениями"
User: "Готово"

Framework: (detects explicit keyword "готово")
Framework: (runs Completion silently)
Framework: "✓ Committed (a1b2c3d)"
```

---

### Example 2: Implicit Signal

```
User: "Исправь баг в exporter.ts"
AI: (fixes bug)
AI: "Исправил, теперь работает правильно"
User: "Супер, тесты проходят"

Framework: (detects implicit signal "супер, тесты проходят")
Framework: "Commit changes? (Y/n)"
User: "y"
Framework: "✓ Committed (e4f5a6b)"
```

---

### Example 3: Significant Changes

```
User: "Добавь три новых секции в SNAPSHOT"
AI: (adds sections, +200 lines)
AI: "Добавил Decision Log, Lessons Learned, и What NOT to do"
User: "Отлично"

Framework: (silent check, detects 200+ lines changed)
Framework: "200+ lines changed. Commit? (Y/n)"
User: "Y"
Framework: "✓ Committed (c7d8e9f)"
```

---

### Example 4: Context Analysis

```
User: "Реализуй оптимизацию протоколов"
AI: (implements optimization)
AI: "Создал два новых протокола: cold-start-silent и completion-silent"
User: "Выглядит хорошо, давай протестируем"
AI: (tests)
AI: "Тесты прошли успешно"
User: "Круто"

Framework: (analyzes context)
Framework: (completion score: 0.87)
Framework: "Task complete. Commit? (Y/n)"
User: "y"
Framework: "✓ Committed (f1a2b3c)"
```

---

## False Positive Prevention

**Avoid triggering when shouldn't:**

```typescript
// Don't trigger if:

// 1. User is asking questions
if (message_ends_with_question_mark(user_message)) {
  skip_trigger()
}

// 2. User mentions problems
if (message_contains_error_keywords(user_message)) {
  // "не работает", "ошибка", "баг", "проблема"
  skip_trigger()
}

// 3. User requests changes
if (message_is_change_request(user_message)) {
  // "измени", "добавь", "убери", "исправь"
  skip_trigger()
}

// 4. Conversation still active
if (ai_just_asked_question()) {
  skip_trigger()  // Wait for user's answer first
}

// 5. No changes to commit
if (git_diff_is_empty()) {
  skip_trigger()
}
```

---

## Logging

**All triggers logged:**

```
.claude/logs/auto-triggers/YYYYMMDD.log
```

**Format:**
```
[19:45:12] Trigger check (message #15)
[19:45:12] Explicit: no
[19:45:12] Implicit: no
[19:45:12] Significant changes: no (47 lines)
[19:45:12] Idle: no (15 min)
[19:45:12] Context score: 0.42
[19:45:12] Result: no trigger

[19:50:23] Trigger check (message #18)
[19:50:23] Explicit: YES ("готово")
[19:50:23] Config: auto_commit_on_explicit = true
[19:50:23] Result: TRIGGERED (auto-commit)
[19:50:23] Running Completion Protocol...
[19:50:35] ✓ Committed (a3f82d1)
```

---

## Verbose Mode

**For debugging triggers:**

```bash
export CLAUDE_TRIGGERS_VERBOSE=true
```

**Shows why triggered:**
```
Framework: "Trigger: explicit keyword 'готово'"
Framework: "Running Completion Protocol..."
Framework: "✓ Committed (a3f82d1)"
```

---

## Disable Auto-Triggers

**If user wants old manual behavior:**

```json
{
  "auto_triggers": {
    "enabled": false
  }
}
```

**Or command:**
```
/triggers disable
```

**Then user must type `/fi` manually (old way).**

---

**Auto-Trigger System Complete** ✅
