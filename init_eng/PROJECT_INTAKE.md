# Project Intake Form

**Purpose:** Fill this document BEFORE starting development to provide AI agents with essential context
**Status:** [TEMPLATE - Fill before first sprint]
**Last Updated:** [DATE]

---

## 🎯 Project Overview

> **Important:** Design starts with the question "**WHY?**". Answer three key questions:

### 1. Core Idea (Elevator Pitch)
**Describe the essence of your app in ONE sentence:**

[ANSWER: For example, "A mobile app that helps find and book dog park playgrounds"]

---

### 2. The Problem
**What specific user problem are you solving?**

[ANSWER: For example, "Dog owners in large cities struggle to find safe, fenced areas for their pets to play. Public parks are dirty and don't guarantee safety"]

**Why don't existing solutions work?**

[ANSWER: For example, "Regular maps show parks but don't provide information about safety, cleanliness, or fencing. There's no way to book time slots"]

---

### 3. The Solution
**How EXACTLY does your app solve this problem?**

[ANSWER: For example, "We provide a map with verified playgrounds, owner reviews, photos, and the ability to book private fenced areas by the hour"]

**What unique value do you provide?**

[ANSWER: For example, "Guaranteed cleanliness and safety, verified locations, rating system, booking capability"]

---

### 4. Target Audience
**For WHOM are you creating this product?**

[ANSWER: For example, "Dog owners aged 25-45 living in major cities who value comfort and safety for their pets and are willing to pay for quality service"]

**Their characteristics:**
- Age: [ANSWER]
- Profession/occupation: [ANSWER]
- Tech literacy: [low/medium/high]
- Willingness to pay: [free/freemium/subscription/one-time payments]

---

## 👥 User Personas

> **Goal:** "Humanize" users for AI. Create 1-3 fictional characters - your ideal users.

### Persona 1: [Name and Age]

**Example:**
```
Name: Anna, 32
Role: Marketer, owner of an active beagle
Location: Moscow, lives in city center
```

**Your Persona 1:**
```
Name: [ANSWER]
Role: [ANSWER]
Location: [ANSWER]
```

**Goals:**
[ANSWER: For example, "Find a safe playground near work to play with dog during lunch break"]

**Pain Points:**
[ANSWER: For example, "Public parks are often dirty, other dogs may be aggressive. Need a secluded and clean place"]

**Tech Behavior:**
[ANSWER: For example, "Active mobile app user, loves convenient services, willing to pay for quality"]

---

### Persona 2: [Name and Age] (optional)

[ANSWER: Repeat structure for second persona if needed]

---

### Persona 3: [Name and Age] (optional)

[ANSWER: Repeat structure for third persona if needed]

---

## 🗺️ User Flows (Interaction Scenarios)

> **Goal:** Describe STEP-BY-STEP how users will interact with the app to achieve their goals.

### Key Scenario 1: [Name, e.g., "First Booking"]

**Example:**
```
1. User opens app and sees map with their location
2. They use filters to find highly-rated playgrounds
3. Tap on a playground, go to its detail page
4. Select available date and time, tap "Book"
5. Go to payment screen, enter card details
6. Confirm booking
7. Receive push notification with confirmation
```

**Your Scenario 1:**
```
1. [ANSWER: First step]
2. [ANSWER: Second step]
3. [ANSWER: Third step]
...
```

---

### Key Scenario 2: [Name] (optional)

[ANSWER: Describe second important use case]

---

### Key Scenario 3: [Name] (optional)

[ANSWER: Describe third important use case]

---

## 🛠️ Technology Stack

> **Important:** If you DON'T understand technology - don't fill this section. Write in section 5: "Suggest optimal stack yourself" - and AI will propose best options with rationale.

### 4. Frontend Framework
**Choose one and specify version if important:**

- [ ] React (with Next.js / Vite / CRA)
- [ ] Vue.js (with Nuxt / Vite)
- [ ] Angular
- [ ] Svelte / SvelteKit
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER: For example, "React 18 + Next.js 14 (App Router)"]

---

### 5. Language
**TypeScript or JavaScript?**

- [ ] TypeScript (recommended)
- [ ] JavaScript

**Selected:** [ANSWER]

---

### 6. Styling Solution

- [ ] Tailwind CSS (recommended for speed)
- [ ] CSS Modules
- [ ] Styled Components / Emotion
- [ ] Plain CSS / SCSS
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

---

### 7. Backend / Database

**Choose backend approach:**

- [ ] Supabase (recommended - auth + DB + real-time)
- [ ] Firebase
- [ ] Custom backend (Node.js / Python / Go)
- [ ] Serverless (AWS Lambda / Vercel Functions)
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

**Database type:**
- [ ] PostgreSQL (Supabase)
- [ ] MongoDB
- [ ] MySQL
- [ ] SQLite
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

---

### 8. Authentication

**How will users log in?**

- [ ] Email/Password
- [ ] OAuth (Google, GitHub, etc.)
- [ ] Magic Link (passwordless)
- [ ] Phone (SMS)
- [ ] No auth needed
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

**Auth provider:**
- [ ] Supabase Auth
- [ ] Firebase Auth
- [ ] Auth0
- [ ] NextAuth.js
- [ ] Custom
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

---

### 9. Hosting / Deployment

**Where will this be deployed?**

- [ ] Vercel (recommended for Next.js)
- [ ] Netlify
- [ ] AWS
- [ ] Google Cloud
- [ ] Self-hosted
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

---

## ✨ Core Features (MVP)

> **Important:** Separate features into **unique** (your value) and **standard** (ready-made services).
>
> **The 99% Rule:** Standard features are NEVER built from scratch - use existing services/libraries!

### 10a. Unique Features (Your Value)

**This is what makes your app different from others. What users will come to you for.**

**Priority order (most important first):**

1. [ANSWER: For example, "Interactive map with verified playgrounds and filters"]
2. [ANSWER: For example, "Rating and review system from dog owners"]
3. [ANSWER: For example, "Online booking system with calendar"]
4. [ANSWER: For example, "Playground profiles with photos, descriptions, rules"]
5. [ANSWER: For example, "Push notifications for booking confirmations"]

**What unique value do these features provide?**

[ANSWER: For example, "Safety guarantee through verification and ratings, booking convenience, time savings on search"]

---

### 10b. Standard Features (Ready-to-use)

**These features DON'T provide direct value, but are necessary for convenience. Use ready-made services!**

**Select needed ones:**

#### Authentication and Users:
- [ ] Registration / Login (email/password)
- [ ] OAuth (Google, Facebook, Apple)
- [ ] User Profile
- [ ] Password Recovery
- [ ] Service: [Supabase Auth / Firebase Auth / Clerk / Auth0]

#### Payments:
- [ ] Accept Payments (cards)
- [ ] Subscriptions
- [ ] Invoicing
- [ ] Service: [Stripe / Lemon Squeezy / PayPal]

#### Notifications:
- [ ] Email (transactional)
- [ ] SMS
- [ ] Push Notifications
- [ ] Service: [Resend / SendGrid / Firebase Cloud Messaging]

#### Storage:
- [ ] File Upload (photos, documents)
- [ ] Video Storage
- [ ] Service: [Supabase Storage / Cloudinary / AWS S3]

#### Analytics:
- [ ] User Tracking
- [ ] Behavior Analytics
- [ ] Service: [Plausible / Mixpanel / Google Analytics]

#### Communication:
- [ ] Support Chat
- [ ] Ticket System
- [ ] Service: [Zendesk / Intercom / Crisp]

#### Other:
- [ ] Geolocation / Maps
- [ ] Search
- [ ] AI/ML Features
- [ ] Service: [SPECIFY]

**Selected standard features:**

[ANSWER: List with service names, for example:
- Authentication - Supabase Auth
- Payments - Stripe
- Email - Resend
- Files - Cloudinary
- Analytics - Plausible]

---

### 11. User Roles

**Does the app have different user types?**

- [ ] No roles (all users equal)
- [ ] Yes, multiple roles

**If yes, list roles:**
- [ANSWER: For example, "Admin - full access"]
- [ANSWER: For example, "Team Member - can view and edit tasks"]
- [ANSWER: For example, "Viewer - read-only access"]

---

## 📊 Data Structure

### 12. Main Entities (Database Tables)

**List main data models and their key fields:**

**Example:**
```
Users
  - id, email, name, avatar, role, created_at

Projects
  - id, title, description, owner_id, created_at

Tasks
  - id, title, description, project_id, assignee_id, due_date, status
```

**Your entities:**
```
[ANSWER: List main tables and their fields]

Entity 1: [Name]
  - [field1], [field2], [field3]...

Entity 2: [Name]
  - [field1], [field2], [field3]...

Entity 3: [Name]
  - [field1], [field2], [field3]...
```

---

### 13. Relationships

**How are entities connected?**

[ANSWER: For example,
- "One User can own many Projects (1:N)"
- "One Project can have many Tasks (1:N)"
- "One Task belongs to one User (assignee) (N:1)"
- "Users and Projects - many-to-many (team members)"]

---

## 🔌 External Integrations

### 14. Third-Party Services

**Will the app integrate with external services?**

- [ ] Email service (SendGrid, Resend, Mailgun)
- [ ] Payment processing (Stripe, PayPal)
- [ ] File storage (AWS S3, Cloudinary)
- [ ] Analytics (Google Analytics, Plausible)
- [ ] AI/ML services (OpenAI, Anthropic)
- [ ] Other: [SPECIFY]

**Selected integrations:**
[ANSWER: List services with brief description of why]

---

### 15. API Requirements

**Does the app need to expose an API?**

- [ ] No, frontend only
- [ ] Yes, REST API
- [ ] Yes, GraphQL
- [ ] Yes, WebSocket / Real-time

**If yes, describe:**
[ANSWER: For example, "REST API for future mobile app"]

---

## 🎨 UI/UX Requirements

### 16. Design Reference

**Are there existing apps with similar UI?**

[ANSWER: For example,
- "Linear.app - minimalist, fast"
- "Notion - flexible, modular"
- "Slack - modern, friendly"]

---

### 17. Design Assets Available?

**Do you have designs ready?**

- [ ] Yes, Figma/Sketch designs available
  - Link: [INSERT LINK]
- [ ] Yes, screenshots/wireframes
  - Location: [SPECIFY WHERE]
- [ ] No, AI should propose basic UI
- [ ] No, will design as we go

**Selected:** [ANSWER]

---

### 18. Responsive Requirements

**Mobile support needed?**

- [ ] Desktop only
- [ ] Responsive (mobile + desktop)
- [ ] Mobile-first
- [ ] Native mobile app planned later

**Selected:** [ANSWER]

---

## 🔐 Security & Compliance

### 19. Security Requirements

**Any special security needs?**

- [ ] Standard web security (XSS, CSRF protection)
- [ ] GDPR compliance required
- [ ] HIPAA compliance (healthcare data)
- [ ] PCI compliance (payment data)
- [ ] Two-factor authentication (2FA)
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

---

### 20. Data Privacy

**Where should data be stored?**

- [ ] Any region (no restrictions)
- [ ] EU only (GDPR)
- [ ] US only
- [ ] Specific region: [SPECIFY]

**Selected:** [ANSWER]

---

## 📈 Scale & Performance

### 21. Expected Scale

**How many users expected in first year?**

- [ ] < 100 users (prototype/MVP)
- [ ] 100-1,000 users (small app)
- [ ] 1,000-10,000 users (growing app)
- [ ] 10,000+ users (production scale)

**Selected:** [ANSWER]

---

### 22. Performance Requirements

**Any critical performance needs?**

[ANSWER: For example,
- "Page load < 2 seconds"
- "Real-time updates < 500ms delay"
- "Support 1000 concurrent users"]

---

## 💰 Budget & Timeline

### 23. Development Timeline

**Expected timeline for MVP?**

- [ ] 1-2 weeks (simple MVP)
- [ ] 1 month (standard MVP)
- [ ] 2-3 months (complex MVP)
- [ ] Other: [SPECIFY]

**Selected:** [ANSWER]

---

### 24. Budget Constraints

**Any constraints on external services cost?**

[ANSWER: For example, "Try to use free tier services, paid only if critical"]

---

## 🔄 Development Approach

> **Philosophy:** Modular architecture is the key to fast and cost-effective AI-assisted development

### 25a. Modular Structure (MANDATORY!)

**Why modular architecture is critical:**

1. **Token Economy:** AI loads only needed module (100-200 lines), not entire project (1000+ lines)
2. **Easy Testing:** Each module = separate task = easy to verify
3. **Parallel Development:** Can work on different modules simultaneously
4. **Cost Savings:** Less context = lower cost of AI queries

**Principle:** Application = set of small building blocks (modules), each solving a narrow task

**Typical modules:**
- Authentication (separate module)
- Database (separate module)
- Each UI screen (separate module)
- Each business function (separate module)
- API / Backend (separate module)

**Your approach to modularity:**

- [ ] Yes, I want modular structure (recommended!)
- [ ] No, I want monolithic structure (NOT recommended for AI work)

**Selected:** [ANSWER: Modular (recommended)]

---

### 25b. Development Style

**Preferred approach:**

- [ ] Start with complete architecture planning, then code
- [ ] Iterative - build feature by feature (recommended for modular structure)
- [ ] Rapid prototyping - get working version fast, refine later

**Selected:** [ANSWER]

**How we'll develop modules:**

[ANSWER: For example, "One module at a time: first authentication, then database, then each screen separately. Test each module before moving to next"]

---

### 26. Testing Requirements

**Testing strategy:**

- [ ] Manual testing only (dev environment)
- [ ] Unit tests for critical functions
- [ ] Integration tests
- [ ] E2E tests (Playwright, Cypress)
- [ ] No tests for MVP

**Selected:** [ANSWER]

---

## 📚 Reference Materials

### 27. Similar Projects

**Are there similar projects for reference?**

[ANSWER: For example, "I have a MainChatMemory project at /path/to/project - can take patterns from there"]

---

### 28. Existing Codebase

**Starting from scratch or existing code?**

- [ ] From scratch (new project)
- [ ] Existing codebase to extend
  - Location: [SPECIFY PATH]
  - What needs to be added: [DESCRIBE]

**Selected:** [ANSWER]

---

## 🎯 Success Criteria

### 29. MVP Definition of Done

**What makes this MVP complete?**

[ANSWER: List of criteria, for example:
- [ ] User can register and log in
- [ ] User can create projects
- [ ] User can add tasks to projects
- [ ] User can invite team members
- [ ] Real-time updates work
- [ ] App deployed to production
- [ ] No critical bugs]

---

### 30. Post-MVP Plans

**What comes after MVP?**

[ANSWER: For example,
- "Add mobile app (React Native)"
- "Add advanced analytics"
- "Add integrations with Slack, Telegram"]

---

## 📝 Additional Notes

### 31. Special Requirements or Constraints

**Anything else AI should know?**

[ANSWER: Any additional requirements, constraints, wishes]

---

## ✅ Completion Checklist

**Before starting development, ensure:**

- [ ] All sections marked with [ANSWER] are filled
- [ ] Technology stack is clearly defined
- [ ] MVP features are prioritized
- [ ] Data structure is outlined
- [ ] Reference materials are provided (if any)
- [ ] This file is committed to git
- [ ] BACKLOG.md is updated with initial features
- [ ] ARCHITECTURE.md is updated with tech stack

---

## 🤖 AI Agent Interaction

> **Important:** After filling this file, dialogue with AI begins to clarify details

### Process of working with AI:

**Step 1: Load Context**
- AI reads this file (PROJECT_INTAKE.md)
- Analyzes your project vision
- May ask clarifying questions

**Step 2: Clarification and Refinement**
- AI asks questions about unclear points
- Suggests improvements
- Helps fill missing parts

**Questions AI might ask:**
```
- "Do you want to use Supabase or Firebase for database?"
- "Is real-time data synchronization needed?"
- "What's your monthly hosting budget?"
- "Planning a mobile app in the future?"
```

**Your answers:**
- If you DON'T know - say so: "I don't know, suggest best option"
- If it's IMPORTANT - specify: "Must be Supabase, already have experience"
- Be specific, but don't be afraid to admit ignorance

**Step 3: Confirm Understanding**
- After clarifications, ask AI: **"Explain how you understood the task"**
- Check its understanding
- Correct if needed

**Step 4: Development Plan**
- AI suggests plan: modules, sequence, technologies
- You approve or correct
- Development begins module by module

**Commands for AI at start:**

```
1. "Read PROJECT_INTAKE.md and ask all clarifying questions"

2. "Suggest 2-3 tech stack options with rationale"

3. "Create development plan by modules with priorities"

4. "Explain how you understood the task and what architecture you propose"
```

---

## 🚀 Next Steps After Filling This Form

**Immediate actions:**

1. **Save and commit this file** to git
   ```bash
   git add PROJECT_INTAKE.md
   git commit -m "docs: Fill PROJECT_INTAKE for [project name]"
   ```

2. **Load to AI agent** (Claude Code, Cursor, etc.)
   - Say: "Read PROJECT_INTAKE.md and SECURITY.md"
   - Say: "Ask clarifying questions"

3. **Dialogue with AI** - answer questions, clarify details

4. **Get plan** - ask AI to create development plan

5. **Start with first module** - usually authentication or database

**What AI will do next:**

1. Analyze PROJECT_INTAKE.md
2. Ask clarifying questions
3. Suggest tech stack (if you didn't choose)
4. Create development plan by modules
5. Suggest starting with first module
6. Iteratively develop module by module

**Your role:**

- ✅ Answer AI questions
- ✅ Check result of each module
- ✅ Give feedback: "works" or "needs fixing"
- ✅ Adjust course along the way
- ❌ DON'T try to write code yourself (if not a developer)
- ❌ DON'T skip module testing

---

## 📋 Template Version

**Version:** 2.0 (Enriched with "Process.md" methodology)
**Last Updated:** 2025-01-11
**Maintained by:** AI Agent + Project Lead

**Changelog:**
- v2.0: Added User Personas, User Flows, unique/standard features split, modular architecture emphasis, AI interaction guide
- v1.0: Initial template

---

*This intake form ensures AI agents have all necessary context to start development efficiently*
*Based on proven AI-assisted development methodology*
*Fill once per project, update as requirements evolve*
