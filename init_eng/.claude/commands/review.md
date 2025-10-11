---
description: Conduct code review of recent changes
---

Conduct detailed code review of recent changes in the project.

**What to check:**

1. **Security:**
   - Validation of all user inputs
   - Authorization check in Server Actions
   - No SQL injections
   - XSS protection
   - No leaked secrets

2. **Code quality:**
   - Follows coding standards (.claude/coding-standards.md)
   - TypeScript types correct and strict
   - No use of `any`
   - Clear variable and function names
   - Comments for complex logic

3. **Architecture:**
   - Follows project patterns (.claude/architecture.md)
   - Proper Client/Server Components separation
   - Correct use of Server Actions
   - No code duplication

4. **Performance:**
   - No unnecessary re-renders
   - Memoization used where needed
   - DB queries optimized
   - No blocking operations

5. **Testability:**
   - Code easy to test
   - Functions not too complex
   - Logic separated from UI

**Response format:**

For each file indicate:
- ✅ What is done well
- ⚠️ What can be improved (with code examples)
- ❌ Critical problems (require fixing)

At the end provide overall assessment and top-3 recommendations.
