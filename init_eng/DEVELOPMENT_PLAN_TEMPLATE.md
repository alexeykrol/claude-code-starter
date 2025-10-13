# DEVELOPMENT PLAN TEMPLATE — Planning Methodology

> 📋 **Purpose:** This file contains recommendations for planning modular project development
>
> **⚠️ IMPORTANT:** This is a TEMPLATE, not a concrete plan. Fill it in for your project!

---

## 🎯 Overall Strategy

### Planning Principles:

1. **Bottom-up approach** — independent modules first, then dependent ones, integration last
2. **Modular development** — one module = one focus = token savings
3. **Testing at each stage** — don't proceed to next until current works
4. **Commit after each stage** — save progress
5. **Document as you go** — update BACKLOG.md and PROJECT_SNAPSHOT.md after each phase

### Development Sequence:

```
Phase 1: Foundation (Basic Infrastructure)
  ↓ Independent modules first
Phase 2: Core Modules (Independent modules)
  ↓ Dependent modules after
Phase 3: Dependent Modules
  ↓ Integration at the end
Phase 4: Integration (Module integration)
  ↓ Polish and deploy
Phase 5: Polish & Deploy
```

---

## 🧩 Modular Architecture — Key to Efficiency

### Why modules are critical:

**❌ Problem without modules:**
```
AI: "Okay, let's work on the project..."
→ Loads entire src/ (5000 lines)
→ Spends ~10k tokens reading code
→ Gets confused in dependencies
→ Slow, expensive, errors
```

**✅ Solution through modules:**
```
SNAPSHOT: "Currently working on Auth Module"
    ↓
BACKLOG: "Phase 3: Auth Module - tasks 1-5"
    ↓
ARCHITECTURE: "Auth Module = 3 files, 200 lines, dependencies: Supabase"
    ↓
AI: Loads ONLY Auth Module
    ↓
Work: ~1k tokens, focused, fast!
```

**Savings: ~90% tokens!** 🚀

---

## 📋 Phase Planning Template

### Phase X: [Phase Name]

**Goal:** [What should be ready after this phase]

**Modules:** [List of modules to be developed]

**Dependencies:** [Which modules/phases this depends on]

**Tasks:**
1. [Task 1 - specific action]
2. [Task 2 - specific action]
3. [Task 3 - specific action]

**Completion Criteria:**
- [ ] All tasks completed
- [ ] Code compiles without errors
- [ ] Module tested in isolation
- [ ] No critical TODOs in code
- [ ] Meta-files updated (BACKLOG, SNAPSHOT, CLAUDE)

**Estimated time:** ~[X] hours

**Commit message:**
```bash
git commit -m "feat: complete Phase X - [brief description]"
```

---

## 🧪 How to Test Module in Isolation

### Principle:

Each module should work **independently** of others.

### Example: Auth Module

**1. Create test page:**

```typescript
// src/test/AuthTest.tsx
import { AuthModule } from '../modules/auth/AuthModule';

function AuthTest() {
  return <AuthModule />;
}

export default AuthTest;
```

**2. Temporarily connect in App.tsx:**

```typescript
// src/App.tsx
import AuthTest from './test/AuthTest';

function App() {
  return <AuthTest />;
}
```

**3. Check functionality:**
- [ ] Form displays
- [ ] Validation works
- [ ] Errors are handled
- [ ] Success flow works

**4. After testing:**
- Restore App.tsx to original
- Remove test file (or keep for documentation)
- Make commit

### Testing Template:

```markdown
## Testing [Module Name]

### Test 1: [Name]
- **Action:** [what we do]
- **Expected result:** [what should happen]
- **Status:** [ ] / [x]

### Test 2: [Name]
- **Action:** [what we do]
- **Expected result:** [what should happen]
- **Status:** [ ] / [x]
```

---

## 📊 Module Dependency Graph

### Development Order:

```
1. Independent modules:
   ├─ Encryption Module (no dependencies)
   ├─ UI Components (no dependencies)
   └─ API Proxy Module (no dependencies)

2. Dependent modules:
   ├─ Auth Module
   │   └─ depends on: Supabase, UI Components
   ├─ Settings Module
   │   └─ depends on: Auth, Encryption, UI Components
   └─ Chat Module
       └─ depends on: Auth, Settings, API Proxy

3. Integration:
   └─ App.tsx
       └─ assembles all modules together
```

### How to determine order:

1. Draw dependency graph
2. Start with modules having no incoming arrows (independent)
3. Move to next level only after previous is ready

---

## 🎯 Module Readiness Criteria

A module is considered **ready** when:

### Basic criteria:
- [ ] All module files created (component, hook, types)
- [ ] Code compiles without TypeScript errors
- [ ] No ESLint warnings (or justified)

### Functional criteria:
- [ ] Core functionality works
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] Loading states added

### Testing:
- [ ] Module tested in isolation
- [ ] Manual tests passed
- [ ] (Optional) Unit tests written and passed

### Documentation:
- [ ] Module interface documented in ARCHITECTURE.md
- [ ] Dependencies specified
- [ ] Usage examples added (if needed)

### Meta-files:
- [ ] BACKLOG.md — tasks marked as ✅
- [ ] PROJECT_SNAPSHOT.md — module added to structure
- [ ] CLAUDE.md — status updated

---

## 🔄 Workflow for Each Phase

### 1. Phase Planning

```markdown
1. Read BACKLOG.md → next phase
2. Read ARCHITECTURE.md → modules for this phase
3. Determine dependencies
4. Estimate time
5. Create task checklist
```

### 2. Phase Development

```markdown
1. Create branch (optional):
   git checkout -b feature/phase-X

2. For each task:
   - Implement
   - Test
   - Mark in TodoWrite

3. After last task:
   - Final phase testing
   - Check completion criteria
```

### 3. Phase Completion

```markdown
1. Update meta-files (see PROCESS.md):
   - BACKLOG.md
   - PROJECT_SNAPSHOT.md
   - CLAUDE.md

2. Commit:
   git add .
   git commit -m "feat: complete Phase X - [description]"

3. (Optional) Merge branch:
   git checkout main
   git merge feature/phase-X

4. Ask user:
   "Phase X completed. Proceed to Phase X+1?"
```

---

## 💰 Token Savings Through Modular Approach

### Calculation Example:

**Project: Chat App with 4 modules**

#### Without modular approach:
```
AI reads entire src/:
- Auth (500 lines)
- Settings (400 lines)
- Chat (800 lines)
- Encryption (300 lines)
---
Total: 2000 lines ≈ 8000 tokens
Cost: ~$0.08 per request
```

#### With modular approach:
```
Phase 2: Working on Auth Module
AI reads only Auth:
- Auth (500 lines)
---
Total: 500 lines ≈ 2000 tokens
Cost: ~$0.02 per request

Savings: 75%! 🚀
```

#### With 10 session restarts:
```
Without modules: 10 × $0.08 = $0.80
With modules: 10 × $0.02 = $0.20
---
Savings: $0.60 = 75%
```

**Conclusion:** Modular approach pays off after just a few restarts!

---

## 🎓 Best Practices

### DO:
- ✅ Plan phases from simple to complex (bottom-up)
- ✅ Test each module in isolation
- ✅ Update PROJECT_SNAPSHOT.md after each phase
- ✅ Commit after each phase
- ✅ Use modular focus to save tokens

### DON'T:
- ❌ Start dependent modules before independent ones are ready
- ❌ Skip module testing
- ❌ Forget to update meta-files
- ❌ Load entire project into AI context at once
- ❌ Proceed to next phase with existing blockers

---

## 📝 Phase Examples for Typical Projects

### Web App (React + Backend):

**Phase 1:** Foundation (setup, dependencies, structure)
**Phase 2:** UI Components (independent components)
**Phase 3:** Core Modules (Auth, API client)
**Phase 4:** Feature Modules (depend on Core)
**Phase 5:** Integration & Polish

### API Service (Node.js):

**Phase 1:** Foundation (Express setup, DB connection)
**Phase 2:** Core Utilities (logging, validation, error handling)
**Phase 3:** Data Layer (models, migrations)
**Phase 4:** API Endpoints (routes, controllers)
**Phase 5:** Testing & Documentation

---

## 🔗 Related Files

- **BACKLOG.md** — filled based on this plan (concrete tasks)
- **PROJECT_SNAPSHOT.md** — updated after each phase
- **ARCHITECTURE.md** — defines module structure
- **PROCESS.md** — documentation update process
- **CLAUDE.md** — context for AI agent

---

## 📖 How to Use This Template

1. **Copy this file** → Create your `DEVELOPMENT_PLAN.md`
2. **Fill in phases** for your project (replace placeholders)
3. **Define modules** and their dependencies
4. **Transfer to BACKLOG.md** concrete tasks for each phase
5. **Follow the plan** and update PROJECT_SNAPSHOT.md after each phase

---

*This template helps structure development and save tokens*
*Use modular approach and your AI assistant will work more efficiently!*
