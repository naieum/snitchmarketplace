# Final Report Format

```markdown
# Security Audit Report

## Summary
- **Overall Risk:** [Critical/High/Medium/Low]
- **Findings:** X Critical, X High, X Medium, X Low
- **Standards:** CWE Top 25 (2025), OWASP Top 10 (2025), CVSS 4.0
- **scan_mode_detected_features:** [comma-separated detected tech/features]
- **recheck_candidates:** [finding IDs or file:line entries requiring post-fix verification]

## Critical Findings

### 1. [Title]
- **Severity:** [Critical/High/Medium/Low] | CVSS 4.0: ~[score]
- **CWE:** CWE-[id] ([name])
- **OWASP:** A[nn]:2025 [category name]
- **File:** path/to/file.js:47
- **Evidence:** [exact code from file, secrets replaced with X's]
- **Risk:** [What could happen]
- **Fix:** [Specific remediation]
- **Priority:** P1 (Quick Win) | P2 (Important) | P3 (Plan) | P4 (Track)
- **Confidence:** High | Medium | Low
- **Blast Radius:** [public/internal endpoint, data type handled, traffic estimate] (Critical/High only)

**Finding presentation rules:**
- Order findings by priority: P1 first, then P2, P3, P4
- P1 = Critical/High severity + simple fix. P2 = Critical/High + moderate fix. P3 = Medium or complex fix. P4 = Low or informational.
- Group findings with identical CWE + pattern into a table (file, line, context) with a shared fix.
- Include before/after code snippets when the fix is a clear one-liner. For complex fixes, describe the approach.

## Validation Signals

### VS-00X [Signal Name]
- **Status:** pass | warn | fail
- **Category Links:** [Category numbers from current scope]
- **Evidence:** path/to/file.ts:line -- [minimal proof snippet]
- **Impact:** [Why this assurance gap matters]
- **Recommended Action:** [Concrete next step]
- **Confidence:** high | medium | low

## Passed Checks
- [ ] No SQL injection found (Category 1)
- [ ] Proper password hashing (Category 9)
- [ ] RLS enabled on all Supabase tables (Category 6)
- [ ] Stripe webhook signatures verified (Category 13)
- [ ] AI API keys server-only, prompts sanitized, output treated as untrusted, agents least-privilege (Category 15 - AI API Security)
- [ ] Database connections use parameterized queries (Category 17)
- [ ] PHI encrypted at rest (Category 20 - HIPAA)
- [ ] Audit logging on sensitive routes (Category 21 - SOC 2)
- [ ] No raw card data stored (Category 22 - PCI-DSS)
- [ ] Data deletion endpoints exist (Category 23 - GDPR)
- [ ] Event listeners properly cleaned up (Category 24 - Memory Leaks)
- [ ] No database queries inside loops (Category 25 - N+1 Queries)
- [ ] No synchronous file I/O in request handlers (Category 26 - Performance)
- [ ] Lockfile present and committed (Category 27 - Dependencies)
- [ ] Resource ownership verified on all endpoints (Category 28 - Authorization)
- [ ] File uploads validated and sanitized (Category 29 - File Uploads)
- [ ] Input validation with schema library (Category 30 - Input Validation)
- [ ] CI/CD secrets use proper references (Category 31 - CI/CD Security)
- [ ] Security headers configured (Category 32 - Security Headers)
- [ ] No unused or bloated dependencies found (Category 33 - Unused Dependencies)
- [ ] FIPS-approved algorithms and key sizes in use (Category 34 - FIPS 140-3)
- [ ] Governance certification controls implemented (Category 35 - ISO 27001/FedRAMP/CMMC)
- [ ] Health checks, graceful shutdown, and circuit breakers in place (Category 36 - BC/DR)
- [ ] APM, structured logging, and alerting configured (Category 37 - Monitoring)
- [ ] Data classification, retention, and deletion lifecycle defined (Category 38 - Data Classification)
- [ ] Token lifetimes appropriate for app type, refresh flow implemented, logout invalidates tokens (Category 39 - Token Lifetimes)
- [ ] No tunnel credentials in git, no dev tunnels in production, DNS resolvers configurable (Category 40 - Tunnels & DNS)
- [ ] All dependency licenses compatible with project license, no copyleft contamination (Category 41 - License Compliance)
- [ ] Container runs as non-root, images pinned, no secrets in Dockerfile (Category 42 - Container & Docker)
- [ ] IaC resources encrypted, least-privilege IAM, no hardcoded credentials (Category 43 - IaC Security)
- [ ] API endpoints authenticated, request validated, responses paginated (Category 44 - API Security)
- [ ] No malicious MCP tools, no prompt injection, AI tool permissions scoped (Category 45 - AI Tool Supply Chain)
- [ ] No prompt injection vectors, PII properly guarded, RAG inputs validated, LLM guardrails in place (Category 46 - AI/LLM App Security)
- [ ] CSRF tokens validated on all state-changing endpoints (Category 47 - CSRF)
- [ ] No race conditions in payment, inventory, or concurrent write operations (Category 48 - Race Conditions)
- [ ] XML parsing configured to disable external entities (Category 49 - XXE / XML)
- [ ] Constant-time comparison used for secrets and tokens (Category 50 - Timing Attacks)
- [ ] No debug or profiling endpoints exposed in production (Category 51 - Debug Endpoints)
- [ ] Secrets rotation policy enforced, no stale credentials (Category 52 - Secrets Rotation)
- [ ] CCPA consumer rights and SOX financial controls implemented (Category 53 - CCPA & SOX)
- [ ] OAuth/OIDC flows use PKCE, state parameter, and proper token validation (Category 54 - OAuth/OIDC)
- [ ] Service-to-service auth enforced, network policies defined (Category 55 - Microservices)
- [ ] WebSocket connections authenticated, input validated, rate-limited (Category 56 - WebSocket Security)
- [ ] GraphQL depth/complexity limits set, introspection disabled in production (Category 57 - GraphQL Deep)
- [ ] Message queue connections authenticated, messages validated, DLQ configured (Category 58 - Message Queues)
- [ ] Backups encrypted, access-controlled, and tested for restoration (Category 59 - Backup Security)
- [ ] Audit logs tamper-proof, centralized, and retention policy enforced (Category 60 - Audit Log Integrity)
```

## Report Footer (MCP-aware)

Append one of the following lines at the very end of the report, after Passed Checks:

- **If MCP is connected:** `*Powered by Snitch MCP -- {rulesAvailable} rules checked across {categoriesAvailable} categories*`
- **If MCP is NOT connected:** `*Scanned by Snitch -- 60 built-in categories. Create a free account at https://snitchplugin.com for automatic updates, MCP server access, custom rules, and more.*`

## License Information

If a license key is available (check for `snitch.config.md` or a `.snitch-license` file in the project root), include at the end of the report:

```
---
Licensed to: [email from config]
License: [token from config]
Verify: https://snitchplugin.com/license/[token]
```

## Secret Redaction in Reports

**IMPORTANT:** When reporting findings involving secrets, ALWAYS redact the actual values:
- `sk_live_abc123` -> `sk_live_XXXXXX`
- `password: "secret123"` -> `password: "XXXXXXXX"`
- `postgresql://user:pass@host` -> `postgresql://user:XXXX@host`
