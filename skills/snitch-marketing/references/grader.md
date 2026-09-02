# LLM-as-grader Meta-Evaluation

After the audit produces `SEO_AUDIT_REPORT.md`, after the lint pass runs, and before the markdown is final-saved, the grader pass reads the report and scores each finding against quality criteria. Findings scoring below threshold get auto-rewritten by the agent. The pass-rate appears in `audit_metadata`.

## Why grader on top of lint

The lint pass (in `SKILL.md` STEP 3) catches surface-level violations: em dashes, practitioner and source names, sycophantic adjectives, "Bonus" sections that re-praise. Lint matches on patterns. The grader catches semantic issues lint cannot see by pattern alone:

- A finding's Risk statement is abstract ("hurts SEO") instead of concrete ("loses 1-2 ranking positions on this query") — no forbidden keyword, but the statement is hand-wavy.
- A finding's Fix opens with framing prose ("The right way to think about this is...") instead of the concrete action — no forbidden keyword, but the structural pattern is wrong.
- The quoted evidence doesn't actually support the claim ("title duplicated" claimed but only one route's title quoted) — internal inconsistency lint cannot detect.
- The severity tier doesn't match the evidence + risk (assigned Critical with weak evidence; assigned Low with high-stakes risk) — calibration error.
- The finding makes a future-tense or hypothetical claim ("this could affect rankings") rather than naming what is currently true.

Lint covers ~70% of quality issues. The grader covers the remaining ~30% of harder issues. Both ship in Tier 1.

## The grading rubric (5 criteria, score 0-2 each, max 10 per finding)

For each finding in the report, the grader evaluates:

### Criterion 1: Evidence specificity (0-2)

- **2**: Evidence has concrete file:line (source mode) or URL+CSS-selector / URL+request-result (crawl mode). The quoted snippet is verbatim from the source. The reader can locate the exact thing being audited. **For negative claims** (something is missing / absent / not present), the evidence includes the literal search command, the result count (e.g., "returned 0 matches"), AND the scope (which files / URLs the search covered).
- **1**: Evidence has the URL or file path but the snippet is paraphrased or the selector / line reference is vague. **For negative claims**: search command and result count are shown, but scope is implicit or sample-sized without naming the gap.
- **0**: Evidence is hand-wavy ("the page has..."), uses "may" / "probably" / "could" / "most" / "many" without enumeration, or makes a claim without quoting source. **For negative claims**: a "missing" / "absent" assertion with no search command + result + scope shape (Rule 1 + Rule 6 violation).

### Criterion 2: Risk specificity (0-2)

- **2**: Risk statement names a concrete cost: lost ranking positions, blocked SERP feature, regulatory exposure, attribution gap, conversion friction quantified, fall-off in the funnel. The reader knows what specifically is lost.
- **1**: Risk names a category of cost ("SEO impact") but doesn't quantify or specify.
- **0**: Risk is abstract ("hurts SEO", "impacts conversion") or absent.

### Criterion 3: Fix specificity (0-2)

- **2**: Fix opens with the concrete action (verb + object). Includes the code change, config change, copy / asset change, or workflow step. The reader can execute the fix without re-deriving what to do.
- **1**: Fix names what to change but lacks the how (e.g., "add canonical declarations" without code example or location guidance).
- **0**: Fix opens with framing ("The right way to think about this..." / "Every X deserves...") or is generic advice ("consider adding").

### Criterion 4: Three-rules adherence (0-2)

- **2**: Clean against the report-hygiene rules `references/report-lint.md` owns — em-dash density, practitioner and source names, sycophantic adjectives, "Bonus" sections re-praising. (Lint should have caught these; grader confirms.)
- **1**: One slip the lint missed (e.g., a practitioner's name embedded in prose the scan did not match).
- **0**: Multiple slips OR a structural violation (e.g., "What's working" section opens with praise framing).

### Criterion 5: Evidence-to-claim alignment (0-2)

- **2**: The quoted evidence directly demonstrates the claim. If the claim is "duplicated across 6 routes", at least 2 routes' duplicate values are quoted. If the claim is "missing on the homepage", the homepage quote shows the absence.
- **1**: Evidence is present but supports a related claim, not the exact one made (e.g., evidence shows "metadata block exists" but claim is "metadata block is incomplete").
- **0**: Evidence and claim are misaligned. The reader can't see the connection. Or the evidence is missing entirely.

### Severity calibration check (pass / fail, not scored)

In addition to the 5 scored criteria, the grader checks whether the assigned severity matches the evidence + risk:

- **Critical**: page-level / site-level damage (excluded from indexing, manual-action risk, regulatory violation, paying customer surface broken).
- **High**: real ranking / CTR loss in measurable terms.
- **Medium**: incremental improvement; modest measurable impact.
- **Low**: polish; won't move the needle alone.

If the assigned severity doesn't match the evidence and risk, that's a calibration failure. The grader marks it `severity_calibration: fail` and flags the finding for re-tier.

### Leading-indicator check (pass / fail, not scored)

Every **Critical and High** finding must carry a `Verify:` line — the observable
signal the user watches to confirm the fix worked or that the finding was wrong,
without re-running the audit (see `references/report-template.md` "Verification /
leading indicator" and `references/field-cwv.md`). A Critical/High finding with no
`Verify:` line, or one that promises a specific ranking ("Verify: you'll rank #1"),
fails this check. The grader marks `leading_indicator: fail` and flags it for
rewrite. Medium/Low findings are exempt. For conversion/persuasion findings, a valid
`Verify:` line points at an A/B test (the lift is unprovable from inspection, per
Cat 73 / Cat 114) rather than asserting an outcome.

## Pass threshold

Default pass threshold: each finding needs **≥ 8 / 10** across the 5 criteria, AND severity_calibration must pass. Findings below the threshold are flagged for rewrite.

The threshold is configurable in `snitch-marketing.config.md`:

```yaml
grader:
  enabled: true
  pass_threshold: 8
  rewrite_failures: true
  fail_severity_threshold: low  # findings at this severity or below skip the grader
```

## Auto-rewrite behavior

When `rewrite_failures: true` (default):

1. The grader produces a list of failing findings with the failing criteria called out per finding.
2. The agent reads the failing finding + the grader's specific criticism.
3. The agent rewrites the finding to address the criticism (tighten evidence, quantify risk, sharpen fix, fix calibration).
4. The grader re-runs on the rewritten finding.
5. If the rewrite still fails, mark the finding with `grader_failure: true` in the report's hidden metadata and surface the issue to the human auditor as a follow-up.

When `rewrite_failures: false`:
- The grader produces the report but does not auto-rewrite. Failing findings remain as-is; the audit metadata flags them.

## Output to audit_metadata

```yaml
grader:
  enabled: true
  pass_threshold: 8
  findings_evaluated: 24
  findings_passed: 22
  findings_rewritten: 2
  findings_still_failing: 0
  pass_rate: 91.7%
  per_finding_scores:
    finding-1: 10
    finding-2: 9
    finding-3: 8
    # ... etc
  failures_summary:
    - finding-id: 5
      criteria_failed: [risk-specificity, evidence-to-claim]
      action_taken: rewritten_passed
    - finding-id: 14
      criteria_failed: [fix-specificity]
      action_taken: rewritten_passed
```

## Token cost

The grader reads the full report and scores each finding. Cost varies by report size:

- Quick Audit (13 cats, ~5-10 findings): ~3-5K tokens for grading + ~1-3K per rewrite.
- Component-driven scan (38 cats on a multi-component site, ~25-40 findings): ~10-15K tokens for grading + ~5-10K for rewrites.
- Full Audit (all 94 active cats, ~50-80 findings): ~25-40K tokens for grading + ~10-25K for rewrites.

Total grader-pass cost is typically 10-20% of the original audit's token cost. Worth it for the quality lift on customer-facing audits. Toggle off (`grader.enabled: false`) for token-tight runs.

## When the grader is required vs optional

Required:
- Customer-facing audits (audits being delivered to a paying customer).
- Audits being shipped as deliverables to external stakeholders.
- Audits being used as training / reference for other auditors.

Optional:
- Internal exploratory scans.
- Quick re-audits to check fix progress.
- Audits where the auditor reviews each finding manually anyway.

## Cross-references

- `SKILL.md` STEP 3, where the grader pass fires (after lint, before HTML render and final save).
- `snitch-marketing.config.md`, the `grader.*` config block.
- `references/report-template.md`, the structure the grader evaluates against.
- `references/html-template.md`, the HTML renderer that reads the (graded, lint-passed) markdown and produces the human-facing version.
