# Go/No-Go Protocol Template (Parallel -> Core Refactor)

Date:
Decision owner:
Scope version:

## 1. Checks Executed

- [ ] Cold start parity
- [ ] Completion parity
- [ ] Migration routing parity
- [ ] Version-check/update parity
- [ ] Security-chain parity
- [ ] Claude contour smoke regression check

## 2. Go Criteria Status

1. Codex contour runs independently (`AGENTS.md` + `.codex/`) without touching Claude contour
Status:
Evidence:

2. Lifecycle scenarios pass in Codex mode (cold start, completion, migration, update, security)
Status:
Evidence:

3. Parity artifacts confirmed
Status:
Evidence:

4. No Claude regressions
Status:
Evidence:

5. No open P0/P1 defects in Codex contour
Status:
Evidence:

6. Mapping and known limitations documented
Status:
Evidence:

## 3. No-Go Triggers

- [ ] Unstable lifecycle scenario in Codex contour
- [ ] Unresolved parity mismatch in mandatory artifacts
- [ ] Claude contour regression detected
- [ ] Security-chain blocking issue unresolved
- [ ] Missing acceptance report

## 4. Decision

- Decision: `GO` / `NO-GO`
- Effective date:
- Notes:
- Required follow-up actions:
