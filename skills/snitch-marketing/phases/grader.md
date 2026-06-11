# Phase: grader (LLM-as-grader meta-evaluation)

> Single source of truth for the grader phase. Streamed via
> `snitch marketing step --phase=grader`. Mirrors SKILL.md STEP 3 (grader pass)
> and `references/grader.md`. Opt-in: enabled via `grader.enabled` in
> `snitch-marketing.config.md`. Required for customer-facing audits; skip for
> token-tight internal scans.

Runs after the lint pass, before the markdown is final. Lint matches patterns; the
grader catches the semantic ~30% lint can't: abstract Risk statements, Fixes that open
with framing instead of action, evidence that doesn't support its claim, severity that
doesn't match evidence+risk, hypothetical ("could affect") claims.

Score each finding on 5 criteria, 0-2 each (max 10):

1. **Evidence specificity** — 2: concrete file:line or URL+selector, verbatim snippet
   (for negative claims: search command + result count + scope). 1: path/URL present
   but paraphrased/vague. 0: hand-wavy, "may/probably/most" without enumeration, or a
   missing-claim with no search+result+scope.
2. **Risk specificity** — 2: names a concrete cost (lost ranking positions, blocked
   SERP feature, regulatory exposure, quantified funnel fall-off). 1: a category of
   cost without quantifying. 0: abstract ("hurts SEO") or absent.
3. **Fix specificity** — 2: opens with verb+object and includes the code/config/copy
   change. 1: names what to change but not how. 0: opens with framing or generic
   "consider adding."
4. **Three-rules adherence** — 2: no em dashes, no practitioner names, no sycophancy,
   no re-praising "Bonus." 1: one slip lint missed. 0: multiple slips or a structural
   violation.
5. **Evidence-to-claim alignment** — 2: the quoted evidence directly demonstrates the
   claim (claim "duplicated across 6 routes" → ≥2 routes quoted). 1: supports a related
   claim, not the exact one. 0: misaligned or missing.

**Severity calibration** (pass/fail, unscored): Critical = page/site-level damage;
High = measurable ranking/CTR loss; Medium = incremental; Low = polish. Mismatch →
`severity_calibration: fail`, flag for re-tier.

**Pass threshold**: each finding needs ≥ 8/10 AND severity_calibration pass (threshold
configurable). When `rewrite_failures: true`, rewrite each failing finding addressing
the called-out criteria, then re-grade; if it still fails, mark `grader_failure: true`
and surface to the human auditor.

Record `audit_metadata.grader` (findings_evaluated/passed/rewritten/still_failing,
pass_rate, per_finding_scores, failures_summary). Typical cost: 10-20% of the audit.
