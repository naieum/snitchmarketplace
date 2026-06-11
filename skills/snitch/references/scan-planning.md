# Scan Planning

Before scanning begins, output a brief scan plan explaining the strategy.

## When to Show

- Always show for Quick Scan (it IS the smart detection output, enhanced)
- Show for preset scans (explain why this preset makes sense for the detected stack)
- Show for full scans (informational -- "scanning everything, but here's what to watch")
- Skip for diff scans (just list the changed files)

## Process

1. Read package.json / go.mod / requirements.txt / Gemfile / Cargo.toml
2. Detect: framework, database, auth system, payment processor, cloud provider, API style, containerization
3. Analyze: what's highest risk for this specific stack?
4. Output the plan BEFORE scanning begins

## Plan Format

```
## Scan Plan

**Stack:** [framework] + [database] + [auth] + [other key deps]
**Risk profile:** [1-sentence summary of what kind of app this is and its risk level]

**High priority (scanning first):**
- [Category] -- [why this matters for this stack]
- [Category] -- [why this matters for this stack]

**Medium priority:**
- [Category] -- [brief reason]

**Lower priority:**
- [Category] -- [checking but likely safe because ...]

**Not applicable (skipping):**
- [Category] -- [not detected in stack]

**Estimated categories:** [N] | **Estimated scan time:** [rough estimate]
```

## Examples

**Next.js + Prisma + Stripe + Clerk:**
> High priority: Secrets (payment keys), Stripe webhook verification, Clerk auth config, XSS (checking dangerouslySetInnerHTML)
> Medium: SQL injection (Prisma auto-parameterizes but checking raw queries), CORS, security headers
> Lower: SSRF (no direct HTTP calls found), rate limiting
> Skipping: SMS, Redis, HIPAA, container security

**Express + MongoDB + JWT:**
> High priority: Secrets (JWT signing key), NoSQL injection, auth bypass (JWT verification), SSRF
> Medium: Rate limiting, input validation, CORS
> Lower: Security headers (check if helmet installed)
> Skipping: Stripe, Supabase, cloud-specific

## Rules
- Plan must be based on actual detected dependencies, not assumptions
- Keep it concise (10-15 lines max)
- Don't scan for the plan -- just read manifests and config files
- The plan is informational -- it doesn't restrict what categories are scanned
