# Final Report Format

```markdown
# Security Audit Report

## Summary
- **Overall Risk:** [Critical/High/Medium/Low]
- **Findings:** X Critical, X High, X Medium, X Low
- **Standards:** CWE Top 25 (2025), OWASP Top 10 (2025), CVSS 4.0
- **scan_mode_detected_features:** [comma-separated detected tech/features]
- **recheck_candidates:** [finding IDs or file:line entries requiring post-fix verification]

## Coverage
- **Mode:** [repository | scoped-path | diff | commit | working-tree]
- **Inventory strategy:** [how the surface list was built — route map / entrypoint enum / sink grep / changed-files]
- **Completeness:** [complete | partial | unknown]
- **Surfaces:** scanned-pass [N] / scanned-finding [N] / scanned-unreachable [N] / deferred [N] — list each deferred surface + reason, and each unreachable one with the gate that makes it unreachable
- **Exclusions:** [paths excluded by rule — tests / vendored / generated / .snitch-ignore — and the rule]

<!-- Render per references/coverage-accounting.md. Hard rule: every in-scope surface ends with a
disposition (scanned-pass / scanned-finding / scanned-unreachable / deferred-with-reason) — no silent sampling. A
"complete" label requires zero deferrals; if any surface was sampled or time-boxed, it is "partial". -->

## Critical Findings

### 1. [Title]
- **Severity:** [Critical/High/Medium/Low] | CVSS 4.0: ~[score]
- **CWE:** CWE-[id] ([name])
- **OWASP:** A[nn]:2025 [category name]
- **Finding ID:** `[ruleId e.g. sql-injection.query-builder]` @ `[anchor e.g. src/db/users.ts::getUserByEmail]` [`#instance` if siblings] (stable across re-scans; see `references/finding-identity.md`)
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
- [ ] <what the check confirmed, in the category's own terms> (Category <ID> - <manifest Title>)
```

## Passed Checks

One line per **scanned** category, generated from `categories/_index.md` — never a fixed list, and
never a category that was not in scope this run (SKILL.md SCOPE RULE). Each line has to be a real
Pass with evidence behind it (SKILL.md Rule 7): the sweep that ran and what came back clean. A
category that was skipped is listed under Skipped with its reason, not here.

Worked examples of the shape:

```
- [ ] No SQL injection found — 14 query sites traced, all parameterized (Category 1 - SQL Injection)
- [ ] Stripe webhook signatures verified at api/webhooks/stripe.ts:31 (Category 13 - Stripe Security)
- [ ] Resource ownership verified on all 9 mutating endpoints (Category 28 - Authorization & Access Control (IDOR))
```

## Report Footer

Append this line at the very end of the report, after Passed Checks:

`*Scanned by Snitch -- 62 built-in categories. Get the latest version at https://snitchplugin.com.*`

## Secret Redaction in Reports

**IMPORTANT:** When reporting findings involving secrets, ALWAYS redact the actual values:
- `sk_live_abc123` -> `sk_live_XXXXXX`
- `password: "secret123"` -> `password: "XXXXXXXX"`
- `postgresql://user:pass@host` -> `postgresql://user:XXXX@host`
