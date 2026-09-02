# LLM-as-grader Meta-Evaluation

After the audit assembles its findings, after the Coverage section (`references/coverage-accounting.md`) and stable finding identity (`references/finding-identity.md`) are attached, and before `SECURITY_AUDIT_REPORT.md` is saved, the grader pass reads the report and scores each finding against quality criteria. Findings scoring below threshold get auto-rewritten by the agent. The pass-rate appears in `audit_metadata.grader`.

A separate, non-optional redaction hard-fail gate (see below) runs before the grader and blocks saving on its own, independent of whether the grader itself is enabled.

## Why grader on top of the anti-hallucination rules

Rules 1-7 and the False Positive Prevention section in SKILL.md are the existing contract. They catch syntactic/structural violations: no file:line means no finding (Rule 1), a real secret value or a literal dangerous-pattern name in the output (Rule 5), a fix applied before the report is shown (Rule 6). Those rules are checkable by pattern or by presence/absence. The grader catches what those rules can't mechanically enforce — semantic and calibration issues:

- A finding claims "sink reached, tainted input" without actually walking the Rule 7 chain (current function → caller → middleware/validator) — nothing stops the model from writing a trace-shaped sentence that skipped the actual work.
- Confidence is marked High or Medium on a trace that only reached the fourth Rule 7 bucket (can't reach a definitive source) — a quiet violation of Rule 7's own hard rule, since nothing else re-checks it after the fact.
- Severity is one tier higher than the evidence + risk narrative supports (High assigned to a finding whose blast radius reads as Medium) — a calibration error, not a missing-evidence error.
- The CWE ID is from the right vulnerability family but the wrong specific ID (e.g., CWE-89 used for a NoSQL injection that should be CWE-943).
- The Fix opens with framing prose ("consider improving input handling") instead of the concrete remediation.
- A dangerous-pattern name slips into prose in a way that's specific enough to defeat Rule 5's intent without being the exact literal forbidden string.

Rules 1-7 cover the mechanical failures — the ones a pattern or a presence check can catch. The grader covers the rest: calibration and semantics, where a finding is correctly shaped and still wrong.

## The grading rubric (5 criteria, score 0-2 each, max 10 per finding)

### Criterion 1: Evidence specificity + redaction correctness (0-2)
- **2** — File:line cited; code quoted verbatim from an actual Read/Grep result (not paraphrased); for a Pass claim, every reached sink in the category carries file:line + trace classification (not a bare count); AND redaction is correct per Rule 5 — any secret shown only as `prefix_XXXXXXXX` style padding (never the real value), and any dangerous pattern described generically rather than named.
- **1** — File:line + quoted code present, but one redaction nit: the X-padding reveals more of the secret than necessary, or the finding's prose is more specific about a dangerous-pattern name than the Evidence block itself, or a Pass claim is missing trace evidence for one of several sinks the category reached.
- **0** — No file:line or no verbatim quote (a Rule 1 violation that should have been caught before grading); OR the redaction failure is a live leak (an actual secret value fully or partially recoverable, or a dangerous-pattern name spelled out literally). **A score of 0 here for a live leak also trips the REDACTION HARD-FAIL below and is handled by that gate, not by criterion scoring alone.**

### Criterion 2: Data-flow trace rigor (0-2)
The "did they actually do the work" criterion: whether Rule 7's trace was genuinely performed, or only written about.
- **2** — For sink-pattern findings, the trace names the variable's origin in the current function, the caller/call-site one or two levels up, and any middleware/validator/schema check examined, landing in one of Rule 7's four buckets with a named classification. For non-sink findings (config, header, dependency), the evidence directly supports the claim without a spurious trace assertion.
- **1** — A trace is present but shallow: names the immediate source ("comes from req.body.q") without showing what was checked at the caller/middleware layer, or asserts "unsanitized" without naming what was examined and found absent.
- **0** — The finding asserts "sink reached" / "tainted" / "user-controlled" with no trace chain shown at all — a bare classification with no evidence, which is itself a Rule 7 violation the grader is catching after the fact.

### Criterion 3: Fix specificity (0-2)
- **2** — Fix opens with the concrete remediation (parameterize this query with X, add `DOMPurify.sanitize()` at this call, replace this pattern with Y) and the fix actually targets the specific gap the trace identified.
- **1** — Names what to change ("add input validation", "sanitize this parameter") but not the concrete mechanism or library — a developer still has to figure out how.
- **0** — Generic/framing prose ("review your security posture", "consider hardening this area") with no concrete action, or a fix that addresses a different problem than the one the trace actually found.

### Criterion 4: Rule adherence (0-2)
Covers Rule 5 (dangerous-pattern naming outside Evidence), Rule 6 (never-auto-fix), and the SCOPE RULE together.
- **2** — No literal dangerous-pattern name anywhere in finding prose outside a scoped Evidence quote; no language implying a fix was already applied during the scan/report phase; the finding stays strictly within the selected-category scope.
- **1** — One soft slip: prose names a pattern more specifically than Rule 5 intends without using the literal forbidden string, or a stray aside references an out-of-scope category without becoming a full finding/passed-check.
- **0** — A literal dangerous-pattern name spelled out in prose (distinct from criterion 1, which covers the Evidence block itself), OR text implying a fix was attempted/applied during the read-only scan phase, OR a finding or passed-check for a category outside the selected scan scope (a SCOPE RULE violation).

### Criterion 5: Evidence-to-claim alignment (0-2)
Checks whether the assigned CWE / severity / confidence actually match what the trace showed.
- **2** — CWE matches the specific vulnerability class shown in evidence; severity is consistent with the risk narrative and blast radius; confidence is consistent with how far the trace actually reached.
- **1** — One mismatch that's a matter of degree, not a categorical error: severity one tier higher than evidence+risk supports, or the right CWE family but the wrong specific ID.
- **0** — Categorical mismatch: CWE doesn't match the vulnerability at all, severity is wildly out of line with the trace (e.g., Critical on an admin-only, internal, already-mitigated path), or the finding's narrative contradicts its own Evidence block.

## Confidence-trace calibration check (pass/fail, not scored)

Directly enforces Rule 7's existing hard rule: *"Do not promote to High confidence on incomplete traces."* Read the finding's Input trace and its four-bucket classification.

- If the trace landed in bucket 4 (**trace can't reach a definitive source — tagged `needs human verification`**) and the finding's `Confidence` field reads **High** or **Medium** → `confidence_trace_calibration: fail`. Flag for immediate re-tier: confidence must drop to Low with the `needs human verification` tag present.
- If the trace is already Low + tagged correctly for a bucket-4 classification → pass.
- If the trace reached one of the three definitive buckets (literal, validated-upstream, or user-controlled-unsanitized), any confidence level is permitted based on evidence strength — this check only fails on **overstatement** of an incomplete trace, matching Rule 7's rule precisely (Rule 7 never says a complete trace must be High confidence, only that an incomplete one must not be promoted).

## REDACTION hard-fail (blocking gate — NOT a scored criterion, NOT a normal pass/fail check)

This is categorically different from every other check in this document and is evaluated first, across the **entire drafted report** — findings, Passed Checks, Coverage section, everywhere — not per finding.

**Trigger conditions:**
- Any string matching a live-secret shape that is not fully X-redacted per Rule 5 (e.g., `sk_live_`, `AKIA`, `ghp_`, a connection-string password segment) followed by what looks like real remaining characters rather than a run of X's.
- Any literal dangerous-pattern name (the exact function/method/property names Rule 5 says never to write literally — DOM write methods, raw HTML property assignment, shell-exec calls, dynamic code evaluation, deserialization calls, OS command functions) appearing anywhere in report prose outside a describe-generically context.

**On trigger:**
1. Set `redaction_hard_fail: true`.
2. **Do not save the report.** This blocks STEP 3's save action outright — it is not "flag and continue," it is stop-the-line. A leaked live credential in a saved artifact is itself a new security exposure (the report becomes something that needs its own incident response), not merely a lower-quality finding, so it cannot be handled by the normal score-and-maybe-rewrite loop.
3. Perform a **narrow, mechanical redaction-only rewrite**: replace only the offending span (the leaked characters with X's, or the literal pattern name with its Rule-5-approved generic description). Do not touch the rest of the finding's content — this is not a quality rewrite.
4. Re-scan immediately. Repeat until `redaction_hard_fail: false`.
5. Only then does the per-finding 5-criteria + confidence-trace-calibration scoring pass proceed toward save.

**This gate runs unconditionally, regardless of `grader.enabled`.** Even when the LLM-as-grader pass is toggled off for a token-tight Quick Scan, the redaction hard-fail scan still runs, because it enforces Rule 5 — an always-on anti-hallucination rule — not the optional quality bar the rest of this document describes.

## Pass threshold

Default: each finding needs **>= 8/10** across the 5 criteria, AND `confidence_trace_calibration` must pass. Findings in a `Type: compliance` category (per `categories/_index.md`) need **>= 9/10** — evidence-package findings clear a higher bar. Configurable in `snitch-security.config.md`:

```yaml
grader:
  enabled: true
  pass_threshold: 8
  compliance_pass_threshold: 9     # for Type: compliance categories per categories/_index.md
  rewrite_failures: true
  fail_severity_threshold: low
  auto_skip_scan_modes: quick, diff
  required_scan_modes: compliance, full, ultra
```

## Auto-rewrite behavior

When `rewrite_failures: true` (default):
1. Grader produces a list of failing findings with the specific failing criteria called out per finding.
2. Agent reads the failing finding + the grader's specific criticism.
3. Agent rewrites the finding to address the criticism (this is a quality rewrite — distinct from the redaction gate's narrow rewrite).
4. Grader re-runs on the rewritten finding, including the confidence-trace calibration check.
5. If the rewrite still fails, mark `grader_failure: true` in the report's hidden metadata and surface it to the human as a follow-up — never silently ship a failing finding as if it passed.

When `rewrite_failures: false`: the report is produced but not auto-rewritten; failures are recorded in metadata only.

## Output to `audit_metadata`

```yaml
grader:
  enabled: true
  pass_threshold: 8
  compliance_pass_threshold: 9
  findings_evaluated: 11
  findings_passed: 10
  findings_rewritten: 1
  findings_still_failing: 0
  pass_rate: 90.9%
  confidence_trace_calibration_failures: 1
  redaction_hard_fail: false
  redaction_rewrites: 0
  per_finding_scores:
    sql-injection.query-builder@src/db/users.ts::getUserByEmail: 10
    xss.dangerously-set-html@app/components/Comment.tsx::render#innerHtml: 7
  failures_summary:
    - finding: xss.dangerously-set-html@app/components/Comment.tsx::render#innerHtml
      criteria_failed: [trace-rigor, evidence-to-claim]
      confidence_trace_calibration: fail
      action_taken: rewritten_passed
```

`per_finding_scores` and `failures_summary` key on the same `ruleId@anchor#instance` identity from `references/finding-identity.md`, not a positional index — this keeps grader scores reconcilable across re-scans, the same way the scan-comparison delta and `.snitch-ignore` triage carry-forward already work.

## Token cost

Typically **15-25%** of the original scan's token cost. It runs at the higher end of a writing-quality rubric because Criterion 2 (data-flow trace rigor) requires the grader to independently re-verify the Rule 7 chain rather than only judge prose quality, which is additional reasoning work beyond a pure writing-quality rubric. For Full System / Ultra scans producing dozens of findings, grading cost scales roughly linearly with finding count; raise `fail_severity_threshold` to `medium` on very large scans to grade only Medium+ findings and contain cost. Toggle off entirely via `grader.enabled: false`, or rely on `auto_skip_scan_modes` for Quick/Diff scans, when token budget is tight. The redaction hard-fail gate is unaffected by any of these toggles and always runs.

## When the grader is required vs optional

**Required:** compliance evidence-package audits (`Type: compliance` categories), customer-facing audits, pre-deploy security checks, and modes `full` and `ultra` — any scan whose output is meant to stand as an artifact someone besides the auditor relies on.

**Optional:** modes `quick` and `diff`, or any scan where the auditor reviews each finding manually right after — auto-skipped by default via `auto_skip_scan_modes` even when `grader.enabled: true` globally.

The REDACTION hard-fail gate is never optional, in either case.

## Forbidden claims

- A `confidence_trace_calibration: pass` on a finding whose trace evidence actually shows bucket 4 (can't reach a definitive source) — this is the exact overstatement Rule 7 already forbids; the grader must catch it, not rubber-stamp it.
- Treating the redaction hard-fail gate as "just another criterion" that can be scored 0/1/2 and deferred to the normal rewrite loop — a live leak blocks the save outright.
- A `pass_rate` computed by excluding findings that failed and were never successfully rewritten (`findings_still_failing` must be counted against the denominator, not dropped).
- Grading a finding's severity/CWE calibration (Criterion 5) as a substitute for the severity × likelihood fix-ordering overlay in `references/risk-prioritization.md` — that overlay answers "which to fix first"; this criterion answers "is this finding's write-up internally consistent." Keep both; do not collapse one into the other.
