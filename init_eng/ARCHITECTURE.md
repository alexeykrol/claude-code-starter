# Project Architecture

**Project:** [PROJECT_NAME]
**Version:** [0.1.0]
**Last Updated:** [DATE]

---

> **🏗️ Authoritative Source:** This is the SINGLE SOURCE OF TRUTH for:
> - WHY we chose specific technologies (technology choices, design principles)
> - HOW the system is structured (modules, layers, components)
> - Modularity philosophy and patterns
> - Design principles and architecture patterns
>
> **⚠️ NOT for operational checklists:**
> ❌ Don't store detailed implementation tasks here (→ BACKLOG.md)
> ❌ Don't store sprint checklists here (→ BACKLOG.md)
> ❌ Don't store "Phase 1: do X, Y, Z" task lists here (→ BACKLOG.md)
>
> **This file = Reference (WHY & HOW)**
> **BACKLOG.md = Action Plan (WHAT to do now)**
>
> Other files (CLAUDE.md, PROJECT_INTAKE.md) link here, don't duplicate.

## 📊 Technology Stack

### Frontend
[FILL IN: Frontend stack details]
```
- Framework: [React/Vue/Angular/Svelte/Next.js/etc]
- Language: [TypeScript/JavaScript]
- Build Tool: [Vite/Webpack/Next.js/Turbopack/etc]
- State Management: [Redux/Zustand/Context API/Pinia/etc]
- UI/CSS: [Tailwind/CSS Modules/Styled Components/MUI/etc]
- Icons: [Lucide/Heroicons/FontAwesome/etc]
- Routing: [React Router/Next Router/Vue Router/etc]
```

### Backend & Infrastructure
[FILL IN: Backend stack details]
```
- Database: [PostgreSQL/MySQL/MongoDB/Supabase/Firebase/etc]
- Authentication: [Supabase Auth/Auth0/Firebase Auth/NextAuth/etc]
- API Type: [REST/GraphQL/tRPC/etc]
- File Storage: [S3/Supabase Storage/Cloudinary/etc]
- Hosting: [Vercel/AWS/Netlify/Railway/etc]
```

### Key Dependencies
```json
{
  "[package-name]": "^version - [purpose]",
  "Examples:": "",
  "react": "^18.3.1 - UI library",
  "@supabase/supabase-js": "^2.x.x - Database client",
  "zustand": "^5.x.x - State management"
}
```

---

## 🗂️ Project Structure

```
[PROJECT_NAME]/
├── [FILL IN: directory structure]
│
│ Example structure:
├── src/                      # Source code
│   ├── components/           # React/Vue components
│   │   ├── ui/              # Reusable UI components
│   │   └── features/        # Feature-specific components
│   ├── lib/                 # Libraries and utilities
│   │   ├── api.ts           # API client
│   │   ├── db.ts            # Database client
│   │   └── utils.ts         # Helper functions
│   ├── hooks/               # Custom hooks
│   ├── store/               # State management
│   ├── types/               # TypeScript types
│   ├── pages/               # Pages/Routes
│   └── App.tsx              # Root component
│
├── public/                   # Static files
├── [database-folder]/        # Database migrations/schemas
├── .env.example             # Environment variables template
├── package.json             # Dependencies
└── tsconfig.json            # TypeScript configuration
```

---

## 🏗️ Core Architecture Decisions

### 1. [Architecture Decision #1]

**Decision:** [What was decided]
**Reasoning:**
- ✅ [Reason 1]
- ✅ [Reason 2]
- ✅ [Reason 3]

**Alternatives considered:**
- ❌ [Alternative 1] - [why rejected]
- ❌ [Alternative 2] - [why rejected]

**Implementation:**
```typescript
// Implementation example
```

### 2. [Architecture Decision #2]

**Decision:** [What was decided]
**Reasoning:**
- ✅ [Reason 1]
- ✅ [Reason 2]

**Alternatives considered:**
- ❌ [Alternative] - [why rejected]

---

### Template for new decisions:

```markdown
### N. [Decision Name]

**Decision:** [Brief description of the decision]
**Reasoning:**
- ✅ [Advantage 1]
- ✅ [Advantage 2]

**Alternatives considered:**
- ❌ [Rejected alternative] - [reason]

**Data structure/Implementation:**
[Code or data structure]
```

---

## 🔧 Key Services & Components

### [Service/Component #1]
**Purpose:** [Purpose]
**Location:** `[file path]`

**Key methods/features:**
```typescript
- method1() → description
- method2() → description
- feature1 → description
```

**Architectural features:**
- [Feature 1]
- [Feature 2]

**Example usage:**
```typescript
// Usage example
```

---

### Template for documenting services:

```markdown
### [Service Name]
**Purpose:** [What it does]
**Location:** `[file path]`

**Key methods:**
- method() → [description]

**Features:**
- [Feature]

**Example:**
[code]
```

---

## 📡 Data Flow & Integration Patterns

### 1. [User Flow #1 - e.g. "User Login"]
```
User Action →
├── Step 1
├── Step 2
├── Step 3
└── Final Result
```

**Detailed flow:**
1. [Step 1 in detail]
2. [Step 2 in detail]
3. [Step 3 in detail]

### 2. [User Flow #2]
```
[Flow diagram]
```

---

### Template for documenting flows:

```markdown
### N. [Flow Name]
[ASCII diagram]

**Detailed:**
1. [Step]
2. [Step]
```

---

## 🎯 Development Standards

### Code Organization
- [FILL IN: code organization standards]
- **1 component = 1 file** (if applicable)
- **Services in lib/** for reusability
- **TypeScript strict mode** - no `any` (except justified exceptions)
- **Naming:** [naming conventions]

### Database Patterns
[FILL IN: if database is used]
- **Primary Keys:** [UUID/Auto-increment/etc]
- **Relationships:** [how relationships are organized]
- **Migrations:** [how migrations are applied]
- **Security:** [RLS/Permissions/etc]

### Error Handling
- **Try/catch** in async functions
- **User-friendly** error messages (in Russian/English)
- **Console logging** for debugging
- **Fallback states** in UI

### Performance Optimizations
- [FILL IN: project-specific optimizations]
- **[Optimization 1]**
- **[Optimization 2]**
- **[Optimization 3]**

---

## 🧩 Module Architecture

> **Philosophy:** Modular architecture is the foundation of effective development with AI agents

### Why modularity is needed?

**Critical advantages for working with AI:**

1. **Token and cost savings**
   - AI loads only the needed module (100-200 lines)
   - Instead of entire project (1000+ lines)
   - Requests execute faster and cheaper

2. **Simplicity in development and testing**
   - Each module = separate task
   - Easy to test module in isolation
   - AI better understands narrow tasks

3. **Parallel work**
   - Can develop different modules simultaneously
   - Speeds up iteration

4. **Project manageability**
   - Easy to find and fix errors
   - Clear structure for team
   - Simple addition of new features

### Modularity principle

**Application = Set of small blocks (LEGO)**

```
┌─────────────────────────────────────────────┐
│           Application                        │
├─────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   Auth   │  │ Database │  │   API    │ │
│  │  Module  │  │  Module  │  │  Module  │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │  Screen  │  │  Screen  │  │  Screen  │ │
│  │    1     │  │    2     │  │    3     │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│                                             │
│  ┌──────────┐  ┌──────────┐                │
│  │ Business │  │ Business │                │
│  │  Logic 1 │  │  Logic 2 │                │
│  └──────────┘  └──────────┘                │
└─────────────────────────────────────────────┘
```

Each module:
- Solves **one narrow task**
- Has **clear input and output**
- Works as a **"black box"** for other modules
- Can be **tested separately**

---

### Typical project modules

[FILL IN as development progresses, but here's a typical structure:]

#### 1. Authentication Module
**Purpose:** Registration, login, password recovery
**Location:** `src/lib/auth/` or `src/features/auth/`
**Independence:** Fully independent, doesn't depend on business logic
**Integration:** Through Auth Provider or Context

**Components:**
- LoginForm
- RegisterForm
- PasswordResetForm
- AuthProvider

---

#### 2. Database Module
**Purpose:** Working with database
**Location:** `src/lib/db/` or `src/lib/supabase/`
**Independence:** Isolated database operations
**Integration:** Through client (Supabase/Firebase/Prisma)

**Functions:**
- Database connection
- CRUD operations
- Queries and mutations

---

#### 3. Screen/Page Modules
**Purpose:** Separate screen = separate module
**Location:** `src/pages/` or `src/app/`
**Independence:** Each page is independent

**Examples:**
- HomePage
- DashboardPage
- SettingsPage
- ProfilePage

---

#### 4. Business Logic Modules
**Purpose:** Your application's unique logic
**Location:** `src/features/` or `src/lib/business/`

**Examples:**
- PaymentProcessor
- BookingSystem
- RatingCalculator
- NotificationManager

---

#### 5. Backend/API Module
**Purpose:** Bridge between frontend and database
**Location:** `src/app/api/` or `src/lib/api/`
**Independence:** Independent layer between UI and DB

**Functions:**
- API routes/endpoints
- Server-side business logic
- Data validation

---

### Development process by modules

**Sequence (recommended):**

1. **Database** → Schema, tables, relationships
2. **Authentication** → Registration, login
3. **Backend/API** → Endpoints for data operations
4. **Screens one by one** → HomePage → Dashboard → Settings...
5. **Business Logic** → Your application's unique features

**Rule:** One module → Testing → Next module

---

### Module example (Documentation)

### [Module Name - e.g. "User Authentication"]
**Purpose:** [What the module does]

**Location:** `[path to module files]`

**Components:**
- `Component1.tsx` - [description]
- `Component2.tsx` - [description]
- `service.ts` - [module logic]

**Dependencies:**
- [External dependencies: libraries, services]

**Integration with other modules:**
- [How this module interacts with others]

**Input/Output:**
```typescript
// Input
interface ModuleInput {
  // ...
}

// Output
interface ModuleOutput {
  // ...
}
```

**Example usage:**
```typescript
// Module usage example
import { useAuth } from './auth-module';

const { user, login, logout } = useAuth();
```

**Testing:**
- [How the module is tested]

---

### Your project modules

[FILL IN as development progresses - add each module here]

#### Module 1: [Name]
[Documentation]

#### Module 2: [Name]
[Documentation]

---

## 🗄️ Database Schema

[FILL IN: database structure]

### Tables Overview
```
[table_name_1]
├── id: uuid (PK)
├── field1: type
└── field2: type

[table_name_2]
├── id: uuid (PK)
└── foreign_key: uuid (FK → table_name_1)
```

### Relationships
- [Description of relationships between tables]

### Indexes
- [Which indexes are created and why]

### Security
- [RLS policies or other security measures]

---

## 🔐 Security Architecture

[FILL IN: security measures]

### Authentication
- **Method:** [OAuth/JWT/Session/etc]
- **Provider:** [Auth0/Supabase/Custom/etc]
- **Flow:** [Description of authentication process]

### Authorization
- **Model:** [RBAC/ABAC/Custom/etc]
- **Implementation:** [How access rights are checked]

### Data Protection
- **At Rest:** [Data encryption]
- **In Transit:** [HTTPS/TLS]
- **API Keys:** [How they are stored]
- **Sensitive Data:** [How it's handled]

### Security Headers
```javascript
// Example security headers configuration
```

---

## 🚀 Deployment Architecture

[FILL IN: deployment architecture]

### Environments
- **Development:** [localhost/dev server]
- **Staging:** [URL/description]
- **Production:** [URL/description]

### CI/CD Pipeline
```
[Description of deployment process]
Code → Tests → Build → Deploy
```

### Environment Variables
```env
# Required
VAR_NAME=description

# Optional
OPTIONAL_VAR=description
```

---

## 📊 State Management Architecture

[FILL IN: how state management is organized]

### Global State
```typescript
// Global state structure
interface AppState {
  [FILL IN]
}
```

### Local State
[When to use local state]

### State Update Patterns
```typescript
// State update pattern examples
```

---

## 🔄 Evolution & Migration Strategy

### Approach to Changes
1. **Document decision** in this file
2. **Database changes** → Create migration script
3. **Backward compatibility** when possible
4. **Feature flags** for experimental functionality

### Migration Pattern
```
Planning → Implementation → Testing → Documentation → Deployment
    ↓           ↓              ↓           ↓            ↓
ARCHITECTURE  Code+Tests    Manual QA   Update docs   Git push
```

### Version History
- **[VERSION]** - [DATE] - [Changes summary]
- [Add as project evolves]

---

## 🧪 Module Testing - Isolated Testing

> **Why:** Each module should work independently of others. This saves time and tokens when developing with AI.

### Module testing principle:

**❌ Bad:**
```
Test entire project at once →
Unclear where error is →
AI loads all code →
Slow, expensive
```

**✅ Good:**
```
Test one module →
Error localized →
AI sees only 1 module →
Fast, cheap
```

### How to test module in isolation:

#### Step 1: Create test page

```typescript
// src/test/[ModuleName]Test.tsx
import { [ModuleName] } from '../modules/[module-name]/[ModuleName]';

function [ModuleName]Test() {
  return (
    <div className="p-8">
      <h1>Testing: [ModuleName]</h1>
      <[ModuleName] />
    </div>
  );
}

export default [ModuleName]Test;
```

#### Step 2: Temporarily connect in App

```typescript
// src/App.tsx (temporary)
import [ModuleName]Test from './test/[ModuleName]Test';

function App() {
  return <[ModuleName]Test />;
}
```

#### Step 3: Check functionality

**Module testing checklist:**
- [ ] Module displays without errors
- [ ] Core functionality works
- [ ] Edge cases handled
- [ ] Error states displayed correctly
- [ ] Loading states work
- [ ] UI responsive (if applicable)

#### Step 4: Restore App to original

After testing:
- Restore `App.tsx`
- Delete test file or keep for documentation
- Make commit with results

### Module readiness criteria:

A module is considered **ready** when:

#### Basic criteria:
- [ ] All module files created (component, hook, types)
- [ ] Code compiles without TypeScript errors
- [ ] No ESLint warnings (or justified)
- [ ] Module tested in isolation

#### Functional criteria:
- [ ] Core functionality implemented
- [ ] Edge cases handled
- [ ] Error handling added
- [ ] Loading states implemented
- [ ] Data validation works

#### Documentation:
- [ ] Module interface documented
- [ ] Dependencies specified
- [ ] Usage examples provided (if needed)

#### Meta-files:
- [ ] BACKLOG.md — tasks marked ✅
- [ ] PROJECT_SNAPSHOT.md — module added
- [ ] PROCESS.md — checklist completed

### Module dependency graph:

**Important:** Develop modules in correct order!

```
Independent modules (first):
├─ UI Components (Button, Input, etc.)
├─ Utility Modules (encryption, validation)
└─ API Clients (no UI)

Dependent modules (later):
├─ Feature Modules
│   └─ depends on: UI Components, Utilities
└─ Integration Modules
    └─ depends on: Feature Modules
```

**How to determine order:**
1. Draw dependency graph
2. Start with modules having no incoming arrows
3. Move to next level only after previous is ready

### Token savings through modular testing:

**Example:** Project with 5 modules

**Without isolation:**
```
Testing entire project:
→ AI reads all 5 modules (2000 lines)
→ ~8000 tokens × 3 iterations = 24k tokens
→ Cost: ~$0.24
```

**With isolation:**
```
Testing each module separately:
→ AI reads 1 module (400 lines)
→ ~1500 tokens × 3 iterations × 5 modules = 22.5k tokens
→ BUT! Fewer iterations (faster bug finding)
→ Actually: ~1500 × 2 × 5 = 15k tokens
→ Cost: ~$0.15

Savings: ~40%! + Faster development!
```

### Template for documenting tests:

```markdown
## Testing [Module Name]

### Test 1: [Functionality name]
- **Action:** [what we do]
- **Expected result:** [what should happen]
- **Status:** [x] Passed / [ ] Failed
- **Bugs:** [if found]

### Test 2: [Edge case]
- **Action:** [what we do]
- **Expected result:** [what should happen]
- **Status:** [x] Passed / [ ] Failed

### Summary:
- ✅ Module ready for integration
- ⏸️ Requires work: [list]
```

---

## 📚 Related Documentation

- **BACKLOG.md** - Current implementation status and roadmap
- **PROJECT_SNAPSHOT.md** - Current project state snapshot
- **PROCESS.md** - Documentation update process after each phase
- **DEVELOPMENT_PLAN_TEMPLATE.md** - Planning methodology
- **AGENTS.md** - AI assistant working instructions
- **WORKFLOW.md** - Development processes and sprint workflow
- **README.md** - User-facing project information

---

## 📝 Architecture Decision Records (ADR)

[Optional: for documenting important architectural decisions]

### ADR-001: [Decision Title]
**Date:** [DATE]
**Status:** [Accepted/Deprecated/Superseded]
**Context:** [Why a decision was needed]
**Decision:** [What was decided]
**Consequences:** [What this led to]

---

## 🎨 Design Patterns Used

[FILL IN: which design patterns are used]

- **[Pattern Name]** - [Where used and why]
- Examples:
  - **Repository Pattern** - in `lib/repositories/`
  - **Factory Pattern** - in `lib/factories/`
  - **Observer Pattern** - in state management

---

## 📝 Notes for Customization

When filling out this file for a specific project:

1. **Replace all [FILL IN]** with actual information
2. **Remove sections** that don't apply to your project
3. **Add new sections** specific to your project
4. **Update document** with each architectural change
5. **Use diagrams** where needed (Mermaid/ASCII)
6. **Delete this section** after initial setup

---

*This document maintained in current state for effective development*
*Last updated: [DATE]*
