# Scan Planning

Before scanning begins, output a brief scan plan explaining the strategy.

## When to Show

- Always show for Quick Scan (it IS the smart detection output, enhanced)
- Show for preset scans (explain why this preset makes sense for the detected stack)
- Show for full scans (informational -- "scanning everything, but here's what to watch")
- For diff scans, list the changed files **plus any sibling instances the change pulls into scope** (see "Diff scans" below)

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

## Diff scans: anchor + sibling expansion

A diff scan stays **anchored to the changed files/hunks**, but a change rarely affects only the
line it touches. Expand discovery to the **sibling instances** the change reaches — otherwise one
representative sink hides the others the same patch introduced or exposed:

- **Changed shared code → fan out to its callers.** If the diff edits a shared helper, guard,
  validator, sanitizer, query builder, or template, the change can make previously-safe call sites
  vulnerable (e.g., a guard weakened, an escape removed). Pull those call sites into scope and
  assess each.
- **New sink pattern → find its siblings the diff touches/newly reaches.** If the patch adds a
  sink (e.g., a new string-built query), check sibling sinks of the same pattern that the diff also
  changes or newly makes reachable.
- **Each affected sibling is its own finding.** Give it a distinct `instance` per
  `references/finding-identity.md` — don't collapse independently-attackable siblings into one.
- **Unchanged siblings are negative controls.** Only report a sibling when *the diff* makes it
  vulnerable; an unchanged-and-still-safe sibling is context, not a finding (avoids dragging the
  whole repo into a diff review).
- **Bound the expansion.** Follow the changed shared symbol's call graph one or two hops — the
  anchor stays the diff, not a full-repo scan. Anything beyond that is a separate full scan.
- **Coverage.** The diff-scan Coverage section (`references/coverage-accounting.md`) lists the
  changed files scanned + the sibling instances expanded into + anything deferred with a reason.

## Rules
- Plan must be based on actual detected dependencies, not assumptions
- Keep it concise (10-15 lines max)
- Don't scan for the plan -- just read manifests and config files
- The plan is informational -- it doesn't restrict what categories are scanned
