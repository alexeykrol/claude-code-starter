# Security Guidelines

**Project:** [PROJECT_NAME]
**Purpose:** Security-first development practices across all project stages
**Last Updated:** [DATE]

> ⚠️ **CRITICAL PRINCIPLE**
>
> Security is NOT a separate phase at the end.
> Security must be considered at EVERY stage: Planning → Design → Development → Testing → Deployment


> **🔐 Authoritative Source:** This is the SINGLE SOURCE OF TRUTH for:
> - Security practices and guidelines
> - Security checklists for all stages
> - Secure coding standards
> - Vulnerability prevention
>
> Other files (CLAUDE.md, AGENTS.md, WORKFLOW.md) link here, don't duplicate.
---

## 🎯 Security Philosophy

### Two Independent Requirements

Every application must satisfy **TWO** independent criteria:

1. ✅ **Functional Requirements** - Application works according to specifications
2. 🔐 **Security Requirements** - Application is protected against threats

**BOTH must be satisfied. One without the other is unacceptable.**

---

## 📋 Security Checklist by Stage

### 🟦 Stage 1: PLANNING

**Before writing any code, identify:**

#### Threat Modeling
- [ ] Who are potential attackers? (Anonymous users, competitors, malicious insiders)
- [ ] What data needs protection? (User data, API keys, business logic)
- [ ] What are attack surfaces? (Public APIs, forms, file uploads, etc)
- [ ] What's the worst-case scenario if compromised?

#### Security Requirements
- [ ] Authentication needed? What type?
- [ ] Authorization/roles required?
- [ ] Sensitive data to encrypt?
- [ ] Compliance requirements? (GDPR, HIPAA, PCI-DSS)
- [ ] Rate limiting needed?
- [ ] Audit logging required?

#### Data Classification
- [ ] **Public** - Can be freely shared (marketing content)
- [ ] **Internal** - Company use only (internal docs)
- [ ] **Confidential** - Restricted access (user PII)
- [ ] **Secret** - Highest protection (API keys, passwords)

**Deliverable:** Security requirements section in PROJECT_INTAKE.md

---

### 🟦 Stage 2: ARCHITECTURE & DESIGN

**Design security into the system from the start**

#### Secure Architecture Principles
- [ ] **Principle of Least Privilege** - Users/services get minimum required permissions
- [ ] **Defense in Depth** - Multiple layers of security (not just one firewall)
- [ ] **Fail Securely** - Errors don't expose sensitive info or bypass security
- [ ] **Separation of Concerns** - Frontend can't access secrets, backend validates everything
- [ ] **Zero Trust** - Never trust input, always validate

#### Architecture Decisions
- [ ] Secrets stored server-side ONLY (never in frontend code)
- [ ] API endpoints require authentication (unless explicitly public)
- [ ] Sensitive operations require additional verification
- [ ] Database access restricted to backend only
- [ ] Third-party services vetted for security

#### Data Flow Security
```
User Input → Validation → Sanitization → Processing → Output Encoding
                ↓              ↓             ↓            ↓
           (Reject bad)   (Clean data)  (Business)  (Prevent XSS)
```

**Deliverable:** Security architecture section in ARCHITECTURE.md

---

### 🟦 Stage 3: DEVELOPMENT

**Write secure code from the first line**

#### 🔴 NEVER DO (Critical Security Violations)

1. **❌ NEVER hardcode secrets in code**
   ```javascript
   // ❌ WRONG
   const apiKey = "sk-proj-abc123..."

   // ✅ CORRECT
   const apiKey = process.env.API_KEY
   ```

2. **❌ NEVER trust user input**
   ```javascript
   // ❌ WRONG - SQL Injection vulnerability
   db.query(`SELECT * FROM users WHERE id = ${userId}`)

   // ✅ CORRECT - Parameterized query
   db.query('SELECT * FROM users WHERE id = ?', [userId])
   ```

3. **❌ NEVER expose sensitive data in errors**
   ```javascript
   // ❌ WRONG
   res.status(500).json({ error: error.stack, dbPassword: process.env.DB_PASS })

   // ✅ CORRECT
   console.error(error) // Log internally
   res.status(500).json({ error: 'Internal server error' })
   ```

4. **❌ NEVER use `eval()` or similar with user input**
   ```javascript
   // ❌ WRONG - Code injection
   eval(userInput)
   new Function(userInput)()

   // ✅ CORRECT - Use safe alternatives
   JSON.parse(userInput) // If expecting JSON
   ```

5. **❌ NEVER disable security features**
   ```javascript
   // ❌ WRONG
   app.use(cors({ origin: '*' })) // Allows any origin

   // ✅ CORRECT
   app.use(cors({ origin: process.env.FRONTEND_URL }))
   ```

#### ✅ ALWAYS DO (Essential Security Practices)

1. **✅ ALWAYS validate input**
   ```typescript
   // Validate type, format, length, range
   function sanitizeEmail(email: string): string {
     if (typeof email !== 'string') throw new Error('Invalid type')
     if (email.length > 255) throw new Error('Too long')
     if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new Error('Invalid format')
     return email.toLowerCase().trim()
   }
   ```

2. **✅ ALWAYS use environment variables for secrets**
   ```bash
   # .env.local (NEVER commit this file)
   OPENAI_API_KEY=sk-proj-...
   DATABASE_URL=postgresql://...
   JWT_SECRET=random-long-string
   ```

3. **✅ ALWAYS sanitize output (prevent XSS)**
   ```javascript
   // React does this automatically for JSX
   <div>{userContent}</div> // ✅ Safe

   // Be careful with dangerouslySetInnerHTML
   <div dangerouslySetInnerHTML={{__html: userContent}} /> // ❌ Dangerous

   // If you must use HTML, sanitize first
   import DOMPurify from 'dompurify'
   <div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(userContent)}} />
   ```

4. **✅ ALWAYS use HTTPS in production**
   ```javascript
   // Redirect HTTP to HTTPS
   if (process.env.NODE_ENV === 'production' && req.protocol === 'http') {
     return res.redirect(301, `https://${req.hostname}${req.url}`)
   }
   ```

5. **✅ ALWAYS implement rate limiting**
   ```javascript
   import rateLimit from 'express-rate-limit'

   const limiter = rateLimit({
     windowMs: 15 * 60 * 1000, // 15 minutes
     max: 100 // limit each IP to 100 requests per windowMs
   })

   app.use('/api/', limiter)
   ```

#### Common Vulnerabilities to Prevent

| Vulnerability | Prevention |
|---------------|-----------|
| **SQL Injection** | Use parameterized queries, ORMs |
| **XSS (Cross-Site Scripting)** | Sanitize output, use React/Vue (auto-escaping) |
| **CSRF (Cross-Site Request Forgery)** | Use CSRF tokens, SameSite cookies |
| **Authentication bypass** | Never trust client-side auth, validate server-side |
| **Broken Access Control** | Check permissions on EVERY request |
| **Sensitive Data Exposure** | Encrypt at rest, in transit, never log secrets |
| **Security Misconfiguration** | Review default configs, disable debug in prod |
| **Insecure Dependencies** | Regular `npm audit`, update packages |

#### Secure Coding Checklist

**For Every Feature:**
- [ ] Input validation implemented
- [ ] Output sanitization applied
- [ ] Authentication checked (if required)
- [ ] Authorization verified (user has permission)
- [ ] Errors handled securely (no sensitive data leaked)
- [ ] Secrets in environment variables (not code)
- [ ] SQL queries parameterized (if using SQL)
- [ ] CORS configured correctly
- [ ] Rate limiting applied (for APIs)

**Deliverable:** Secure code following AGENTS.md security rules

---

### 🟦 Stage 4: TESTING

**Test security, not just functionality**

#### Security Testing Checklist

##### 4.1 Dependency Audit
```bash
# Check for known vulnerabilities
npm audit

# Auto-fix if possible
npm audit fix

# Review high/critical vulnerabilities
npm audit --audit-level=high
```

##### 4.2 Secret Scanning
- [ ] No API keys in code (search for common patterns)
- [ ] No passwords in code
- [ ] No tokens in git history
- [ ] `.env` files in `.gitignore`
- [ ] Secrets in `.env.example` are placeholders only

**Tools:**
```bash
# Manual check
grep -r "sk-proj" . --exclude-dir=node_modules
grep -r "AIza" . --exclude-dir=node_modules

# Or use automated tools
npm install -g secretlint
secretlint "**/*"
```

##### 4.3 Authentication & Authorization Testing
- [ ] Try accessing protected routes without auth
- [ ] Try accessing other users' data
- [ ] Try privilege escalation (user → admin)
- [ ] Test password reset flow
- [ ] Test session expiration

##### 4.4 Input Validation Testing
- [ ] Send empty values
- [ ] Send extremely long strings (1M+ characters)
- [ ] Send special characters: `<script>`, `'; DROP TABLE--`, `../../../etc/passwd`
- [ ] Send wrong data types (string instead of number)
- [ ] Send negative numbers where positive expected
- [ ] Send future dates where past expected

##### 4.5 API Security Testing
- [ ] Test without authentication token
- [ ] Test with expired token
- [ ] Test with manipulated token
- [ ] Test rate limiting (send 1000 requests rapidly)
- [ ] Test CORS (request from unauthorized origin)

##### 4.6 Frontend Security Testing
- [ ] Open DevTools → Check for secrets in source code
- [ ] Check Network tab → Ensure no secrets in requests
- [ ] Check Local Storage → No sensitive data stored
- [ ] Check Cookies → HttpOnly, Secure, SameSite set correctly
- [ ] Test XSS: Input `<img src=x onerror=alert(1)>`

##### 4.7 Environment Variables Testing
- [ ] App fails gracefully if required env vars missing
- [ ] Env vars never logged to console
- [ ] Different env vars for dev/staging/production
- [ ] Production env vars never committed to git

**Deliverable:** Security test results documented, all issues fixed

---

### 🟦 Stage 5: PRE-DEPLOYMENT

**Final security verification before going live**

#### Production Readiness Security Checklist

##### 5.1 Code Review
- [ ] No `console.log()` with sensitive data
- [ ] No commented-out secrets
- [ ] No debug flags enabled
- [ ] No test users/passwords in production DB
- [ ] Error messages don't expose stack traces in production

##### 5.2 Configuration Review
- [ ] HTTPS enforced
- [ ] Security headers set (CSP, HSTS, X-Frame-Options)
- [ ] CORS restricted to known origins
- [ ] Rate limiting enabled
- [ ] File upload restrictions in place (if applicable)

##### 5.3 Secrets Management
- [ ] All secrets in hosting platform environment variables (Netlify/Vercel/AWS)
- [ ] API keys rotated from defaults
- [ ] Database credentials strong and unique
- [ ] No secrets in git history
- [ ] `.env` files never deployed

##### 5.4 Dependency Security
```bash
# Final audit before deploy
npm audit --production

# Check for outdated packages with vulnerabilities
npm outdated
```

##### 5.5 Access Control
- [ ] Admin panels protected
- [ ] Database not publicly accessible
- [ ] Backend APIs not directly exposed (if using serverless)
- [ ] SSH keys rotated (if using VPS)

##### 5.6 Monitoring & Logging Setup
- [ ] Error tracking configured (Sentry, etc)
- [ ] Access logs enabled
- [ ] Anomaly detection alerts set up
- [ ] Backup strategy in place

**Deliverable:** Production deployment security approval

---

### 🟦 Stage 6: POST-DEPLOYMENT

**Security is ongoing, not one-time**

#### Continuous Security Practices

##### Regular Maintenance
- [ ] **Weekly:** Check error logs for anomalies
- [ ] **Monthly:** Run `npm audit` and update dependencies
- [ ] **Quarterly:** Review access controls and permissions
- [ ] **Annually:** Full security audit and penetration test

##### Incident Response Plan
1. **Detect** - Monitor logs, set up alerts
2. **Respond** - Have runbook for common incidents
3. **Recover** - Backup/restore procedures documented
4. **Learn** - Post-mortem after incidents

##### Security Updates
- [ ] Subscribe to security advisories for dependencies
- [ ] Auto-update non-breaking security patches
- [ ] Test and deploy critical patches within 48 hours

---

## 🛠️ Security Tools

### Automated Scanning
```bash
# Dependency vulnerabilities
npm audit

# Secret detection
npx secretlint "**/*"

# Static code analysis
npx eslint . --ext .ts,.tsx

# License compliance
npx license-checker
```

### Manual Testing Tools
- **Browser DevTools** - Check network, storage, console
- **Postman/Insomnia** - API security testing
- **OWASP ZAP** - Web application security scanner
- **Burp Suite** - Advanced penetration testing

---

## 🚨 Common Security Anti-Patterns

### ❌ "Security Theatre" (Looks secure, isn't)
```javascript
// Client-side only validation - attacker can bypass
if (password.length < 8) return "Too short"

// ✅ MUST validate on server too
```

### ❌ "Security by Obscurity"
```javascript
// Hiding API endpoint doesn't make it secure
// /api/secret-admin-endpoint-xyz123 ← still vulnerable

// ✅ Use proper authentication
```

### ❌ "Trust the Frontend"
```javascript
// ❌ Frontend says user is admin, backend believes it
const isAdmin = req.body.isAdmin // Attacker can set this!

// ✅ Backend checks user role from authenticated session
const isAdmin = await checkUserRole(req.userId)
```

---

## 📚 Security Resources

### Learning
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) - Most critical web security risks
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

### Tools
- [npm audit](https://docs.npmjs.com/cli/v8/commands/npm-audit)
- [Snyk](https://snyk.io/) - Dependency vulnerability scanning
- [OWASP ZAP](https://www.zaproxy.org/) - Security testing

### Checklists
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [Security Checklist by OWASP](https://owasp.org/www-project-web-security-testing-guide/)

---

## 🎯 Security Culture

### For Developers
- **Think like an attacker** - "How would I break this?"
- **Security is everyone's job** - Not just security team
- **When in doubt, ask** - Better to ask than create vulnerability
- **Document security decisions** - Why we chose approach X over Y

### For AI Agents
- **Read SECURITY.md before coding** - Security rules are not optional
- **Flag security concerns immediately** - Don't proceed if unsure
- **Never optimize by removing security** - Performance < Security
- **Document security assumptions** - What threats are we protecting against?

---

## ✅ Security Sign-Off Template

Before deploying to production, complete this checklist:

```markdown
## Security Review - [DATE]

**Reviewed by:** [Name/AI Agent]
**Application:** [Name] v[Version]

### Planning
- [ ] Threat model documented
- [ ] Security requirements defined
- [ ] Data classification completed

### Architecture
- [ ] Security architecture reviewed
- [ ] Secrets managed server-side only
- [ ] Defense in depth implemented

### Development
- [ ] No hardcoded secrets
- [ ] Input validation on all inputs
- [ ] Output sanitization implemented
- [ ] Secure coding practices followed

### Testing
- [ ] npm audit passed (no high/critical)
- [ ] No secrets in codebase
- [ ] Authentication/authorization tested
- [ ] Input validation tested
- [ ] API security tested

### Deployment
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] CORS properly restricted
- [ ] Rate limiting enabled
- [ ] Environment variables secured
- [ ] Monitoring/logging enabled

**Status:** ✅ APPROVED / ❌ BLOCKED
**Blocker issues:** [List if blocked]
**Sign-off:** [Name] [Date]
```

---

*Security is not a feature. Security is a requirement.*
*Last updated: [DATE]*
