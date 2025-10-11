# Project Implementation Plan

**Project:** [PROJECT_NAME]
**Current Status:** [Current state description]
**Created:** [DATE]
**Last Updated:** [DATE]

> **Note:** Copy this file to project root as PLAN.md and fill in for specific task.

---

## 🎯 Goal

[FILL IN: Main development goal]

**Two independent success criteria:**
1. ✅ **Functionality** - Application works according to specifications
2. 🔐 **Security** - Application is secure

**Both must be satisfied!**

---

## 📋 Development Stages

### 🟦 Stage 1: PLANNING

**Functional part:**
- [ ] [Define what needs to be done]
- [ ] [Check current state]
- [ ] [Determine scope of work]

**🔐 Security part (in parallel):**
- [ ] Read SECURITY.md Stage 1 (Planning)
- [ ] Identify sensitive data (API keys, user data, etc)
- [ ] Identify attack surface (who can attack, from where)
- [ ] Define security requirements for this task

**Deliverable:** [What we get as output]

---

### 🟦 Stage 2: PREPARATION

**Functional part:**
- [ ] [Install dependencies if needed]
- [ ] [Configure environment]
- [ ] [Prepare tools]

**🔐 Security part (in parallel):**
- [ ] Check .gitignore - all secrets excluded?
- [ ] Scan code for secrets:
  ```bash
  grep -r "api" . --exclude-dir=node_modules
  grep -r "key" . --exclude-dir=node_modules
  grep -r "password" . --exclude-dir=node_modules
  ```
- [ ] npm audit - check dependencies for vulnerabilities
- [ ] Ensure existing code doesn't expose secrets

**Deliverable:** [What we get as output]

---

### 🟦 Stage 3: IMPLEMENTATION

**Functional part:**
- [ ] [Write code for feature/fix]
- [ ] [Integrate with existing code]
- [ ] [Configure UI/UX if needed]

**🔐 Security part (during coding):**
- [ ] ✅ Validate ALL input data (type, format, length, range)
- [ ] ✅ Don't hardcode secrets (use environment variables)
- [ ] ✅ Sanitize output (prevent XSS)
- [ ] ✅ Use parameterized queries (if DB)
- [ ] ✅ Check authentication/authorization (if needed)
- [ ] ✅ Handle errors securely (don't expose sensitive info)

**Deliverable:** [What we get as output]

---

### 🟦 Stage 4: FUNCTIONAL TESTING

**What to test:**
- [ ] [Application starts without errors]
- [ ] [Main functionality works (happy path)]
- [ ] [Edge cases handled]
- [ ] [UI looks correct]
- [ ] [No errors in console]

**Deliverable:** Application works functionally in dev environment

---

### 🟦 Stage 5: SECURITY TESTING 🔐 MANDATORY!

**Security checklist:**

#### 5.1 Dependency Audit
- [ ] Run npm audit
  ```bash
  npm audit --production
  ```
- [ ] No high/critical vulnerabilities (or documented)

#### 5.2 Secret Scanning
- [ ] Search for secrets in code
  ```bash
  # Adapt for your project
  grep -r "api_key" . --exclude-dir=node_modules
  grep -r "secret" . --exclude-dir=node_modules
  ```
- [ ] Open DevTools → Sources → verify no secrets in bundle

#### 5.3 Input Validation Testing
- [ ] Try sending empty values
- [ ] Try very long strings (1M+ characters)
- [ ] Try special characters: `<script>`, `'; DROP TABLE--`
- [ ] Try wrong data types

#### 5.4 XSS Testing (if user-generated content)
- [ ] Try inserting: `<script>alert('XSS')</script>`
- [ ] Try: `<img src=x onerror=alert(1)>`
- [ ] Ensure content is escaped

#### 5.5 Authentication/Authorization Testing (if applicable)
- [ ] Try accessing without authentication
- [ ] Try accessing someone else's data
- [ ] Try privilege escalation

#### 5.6 Error Handling
- [ ] Trigger errors (disconnect internet, wrong data)
- [ ] Ensure errors don't reveal sensitive information

**Deliverable:** Security audit passed, all issues documented or resolved

---

### 🟦 Stage 6: BUG FIXES ⚠️ RETEST SECURITY AFTER!

**If bugs found:**
- [ ] Document functional bugs
- [ ] Document security issues
- [ ] **🔐 MUST retest security** after changes
- [ ] Return to Stage 4 (functional testing)
- [ ] Return to Stage 5 (security testing)

**Deliverable:** Bugs fixed, tests passed

---

### 🟦 Stage 7: PRE-DEPLOYMENT SECURITY AUDIT 🔐

**Final check before deployment:**

- [ ] Read SECURITY.md Stage 5 (Pre-Deployment)

#### 7.1 Code Review
- [ ] No console.log() with sensitive data
- [ ] No commented out secrets
- [ ] No debug flags enabled in production
- [ ] Error messages don't expose stack traces in production

#### 7.2 Build Security Check (if build step exists)
- [ ] Create production build
- [ ] Verify build doesn't contain secrets

#### 7.3 Final Audit
- [ ] Final npm audit
- [ ] Ensure git history doesn't contain secrets
- [ ] .env.example contains only placeholders

#### 7.4 Environment Variables
- [ ] Prepare list of env vars for production
- [ ] Ensure all secrets are in environment variables

**Deliverable:** Application ready for production deployment

---

### 🟦 Stage 8: DEPLOYMENT

**Functional part:**
- [ ] Configure environment variables on hosting platform
- [ ] Deploy application
- [ ] Wait for successful deployment
- [ ] Record production URL

**🔐 Security part:**
- [ ] Verify env vars are set correctly
- [ ] Ensure HTTPS works
- [ ] Check security headers (if configured)

**Deliverable:** Application deployed to production

---

### 🟦 Stage 9: PRODUCTION TESTING

**Functional part:**
- [ ] Open production URL
- [ ] Test main flow
- [ ] Check on different devices/browsers

**🔐 Security part on production:**
- [ ] Open DevTools → Network → ensure HTTPS
- [ ] DevTools → Sources → verify no secrets
- [ ] Repeat main security tests on production

**Deliverable:** Production works and is secure

---

### 🟦 Stage 10: DOCUMENTATION UPDATE

**Mandatory updates:**
- [ ] BACKLOG.md - mark completed features
- [ ] ARCHITECTURE.md - document changes (if any)
- [ ] AGENTS.md - add found patterns/solutions
- [ ] README.md - update if user-facing changes

**Security documentation (if issues found):**
- [ ] SECURITY.md - document found vulnerabilities and solutions

**Git commit:**
- [ ] Create sprint completion commit (see WORKFLOW.md)

**Deliverable:** Documentation updated

---

## ⏱️ Overall Time Estimate

[FILL IN: Your estimate for specific task]

### Time distribution:
- Planning and preparation: [time]
- Implementation: [time]
- Functional testing: [time]
- **Security testing: [time]** (mandatory!)
- Bug fixes: [time]
- Pre-deployment audit: [time]
- Deployment: [time]
- Production testing: [time]
- Documentation: [time]

---

## 🚨 Critical Rules

### NEVER skip:
- ❌ Stage 5 (Security Testing) - **MANDATORY**
- ❌ Stage 7 (Pre-Deployment Security Audit) - **MANDATORY**
- ❌ Documentation after completion

### ALWAYS do:
- ✅ Security checks in parallel with functional development
- ✅ Retest security after ANY code changes
- ✅ Check that secrets aren't in code before every commit
- ✅ npm audit before deployment

### Two independent criteria:
1. **Functionality** ✅ - Application works
2. **Security** 🔐 - Application is secure

**Deploy ONLY when BOTH criteria are satisfied!**

---

## 📍 Current Status

**Last Updated:** [DATE]

### Completed:
- [ ] [List of completed stages]

### In Progress:
- [ ] [Current stage]

### Upcoming:
- [ ] [Future stages]

---

## 🔗 Related Documents

- [PROJECT_INTAKE.md](PROJECT_INTAKE.md) - Full project context
- [SECURITY.md](SECURITY.md) - Detailed security requirements
- [WORKFLOW.md](WORKFLOW.md) - Development processes
- [BACKLOG.md](BACKLOG.md) - Implementation status
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture

---

## 📝 Notes

[FILL IN: Any project-specific notes, risks, assumptions]

---

*Plan created according to WORKFLOW.md and SECURITY.md*
*Security integrated into every stage, not a separate phase*
