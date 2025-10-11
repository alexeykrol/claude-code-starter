---
description: Conduct code security audit
---

Conduct detailed code security audit according to SECURITY.md.

**IMPORTANT:** First read SECURITY.md for full context!

**Check the following:**

## 1. Input Data Validation

- [ ] All user inputs validated on server
- [ ] Type-safe validation used (Zod or similar)
- [ ] String lengths checked
- [ ] Data types verified
- [ ] Formats checked (email, URL, etc)

## 2. Authentication and Authorization

- [ ] Authentication check in every Server Action
- [ ] Authorization check (user can perform operation)
- [ ] JWT tokens verified
- [ ] Session management correct
- [ ] No hardcoded credentials

## 3. SQL Injection

- [ ] Parameterized queries used
- [ ] No SQL string concatenation
- [ ] ORM/Query Builder used (Supabase)
- [ ] Input sanitization present

## 4. XSS (Cross-Site Scripting)

- [ ] No use of `dangerouslySetInnerHTML`
- [ ] React used (auto-escaping)
- [ ] Markdown rendered safely (react-markdown)
- [ ] No `eval()` or `Function()`

## 5. CSRF (Cross-Site Request Forgery)

- [ ] Server Actions automatically protected by Next.js
- [ ] API routes use correct methods
- [ ] Critical operations require confirmation

## 6. Data Leaks

- [ ] Secrets not in code (using .env)
- [ ] .env in .gitignore
- [ ] Errors don't reveal sensitive information
- [ ] Logging doesn't contain secrets
- [ ] API doesn't return unnecessary data

## 7. Rate Limiting

- [ ] Public endpoints have rate limiting
- [ ] Brute force protection
- [ ] DoS protection

## 8. HTTPS and Headers

- [ ] HTTPS used
- [ ] Security headers configured (next.config.js)
- [ ] HSTS enabled
- [ ] CSP configured

## 9. Dependencies

- [ ] No known vulnerabilities (`npm audit`)
- [ ] Dependencies updated
- [ ] Trusted packages used

## 10. Supabase Security

- [ ] Row Level Security (RLS) enabled
- [ ] Policies correct
- [ ] Users see only their data
- [ ] Anon key used correctly

**For each found problem indicate:**
- ❌ Vulnerability description
- 🎯 Severity (Critical/High/Medium/Low)
- 💡 Fix recommendation
- ✅ Example of correct code

**At the end provide:**
- Overall security assessment
- Top-5 critical problems (if any)
- Recommendations for improvement
