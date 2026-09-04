# LLM-as-grader Meta-Evaluation

After the audit assembles its findings, after the Coverage section (`references/coverage-accounting.md`) and stable finding identity (`references/finding-identity.md`) are attached, and before `SECURITY_AUDIT_REPORT.md` is saved, the grader pass reads the report and scores each finding against quality criteria. Findings scoring below threshold get auto-rewritten by the agent. The pass-rate appears in `audit_metadata.grader`.

A separate, non-optional redaction hard-fail gate (see below) runs before the grader and blocks saving on its own, independent of whether the grader itself is enabled.

## What to verify

Check the report against the actual source reads, not just against its prose. Reopen code when
a trace or protection claim is unsupported. A well-shaped trace is not proof that the control
works: verify its effect at the specific sink and argument position. Grade evidenced Passes as
well as Findings for trace rigor and evidence alignment; only Findings enter the per-finding
score totals below. The grader is a quality check, not a claim of independent verification.

## The grading rubric (5 criteria, score 0-2 each, max 10 per finding)

### Criterion 1: Evidence specificity + redaction correctness (0-2)
- **2** — File:line plus an exact source quote, with sensitive values redacted per Rule 5. Ordinary code identifiers remain intact. Any host-required omission is explicitly labeled and the remaining evidence still proves the claim.
- **1** — Source and location are present but the excerpt omits relevant non-sensitive context; the claim needs another source read.
- **0** — No checkable source evidence, a paraphrase presented as a quote, or a leaked sensitive value. A leak also triggers the blocking redaction gate below.

### Criterion 2: Data-flow trace rigor (0-2)
The "did they actually do the work" criterion: whether Rule 7's trace was genuinely performed, or only written about.
- **2** — For sink-pattern findings, the trace names source, callers, relevant controls, and the argument or effect reached, with Rule 7's classification. It evaluates what each control prevents and follows the value actually consumed. For non-sink findings, the evidence directly supports the claim without a spurious trace assertion.
- **1** — A trace is present but shallow: names the immediate source ("comes from req.body.q") without showing what was checked at the caller/middleware layer, or asserts "unsanitized" without naming what was examined and found absent.
- **0** — The finding asserts "sink reached" / "tainted" / "user-controlled" with no trace chain shown at all — a bare classification with no evidence, which is itself a Rule 7 violation the grader is catching after the fact.

### Criterion 3: Fix specificity (0-2)
- **2** — Fix opens with the concrete remediation (parameterize this query with X, add `DOMPurify.sanitize()` at this call, replace this pattern with Y) and the fix actually targets the specific gap the trace identified.
- **1** — Names what to change ("add input validation", "sanitize this parameter") but not the concrete mechanism or library — a developer still has to figure out how.
- **0** — Generic/framing prose ("review your security posture", "consider hardening this area") with no concrete action, or a fix that addresses a different problem than the one the trace actually found.

### Criterion 4: Rule adherence (0-2)
Covers Rule 5's defensive framing, Rule 6, and the SCOPE RULE.
- **2** — Defensive evidence and remediation, no claim that code was fixed during scanning, and only selected-category Findings and Passes.
- **1** — A stray aside references an out-of-scope category without becoming a Finding or Pass.
- **0** — Working attack payloads, a fix attempted during the read-only scan, or an out-of-scope Finding or Pass. Ordinary API names are not violations.

### Criterion 5: Evidence-to-claim alignment (0-2)
Checks whether the assigned CWE / severity / confidence actually match what the trace showed.
- **2** — CWE matches the specific vulnerability class shown in evidence; severity is consistent with the risk narrative and blast radius; confidence is consistent with how far the trace actually reached.
- **1** — One mismatch that's a matter of degree, not a categorical error: severity one tier higher than evidence+risk supports, or the right CWE family but the wrong specific ID.
- **0** — Categorical mismatch: CWE doesn't match the vulnerability at all, severity is wildly out of line with the trace (e.g., Critical on an admin-only, internal, already-mitigated path), or the finding's narrative contradicts its own Evidence block.

## Confidence-trace calibration check (pass/fail, not scored)

Directly enforces Rule 7's existing hard rule: *"Do not promote to High confidence on incomplete traces."* Read the finding's Input trace and its four-bucket classification.

- If the trace landed in bucket 4 (**trace can't reach a definitive source — tagged `needs human verification`**) and the finding's `Confidence` field reads **High** or **Medium** → `confidence_trace_calibration: fail`. Flag for immediate re-tier: confidence must drop to Low with the `needs human verification` tag present.
- If the trace is already Low + tagged correctly for a bucket-4 classification → pass.
- If the trace reached a definitive bucket (literal, protected for this sink, or user-controlled without effective protection), calibrate confidence to the evidence. The presence of a validator or prompt label alone does not establish protection.

## REDACTION hard-fail (blocking gate — NOT a scored criterion, NOT a normal pass/fail check)

This is categorically different from every other check in this document and is evaluated first, across the **entire drafted report** — findings, Passed Checks, Coverage section, everywhere — not per finding.

**Trigger conditions:**
- Any string matching a live-secret shape that is not fully X-redacted per Rule 5 (e.g., `sk_live_`, `AKIA`, `ghp_`, a connection-string password segment) followed by what looks like real remaining characters rather than a run of X's.
- Any other unredacted credential or real personal data, even without a recognizable key prefix. Check values in context; a shape match alone does not establish whether a value is real.

Ordinary function, method, property, and module names do not trigger this gate. Apply actual
host-specific restrictions per Rule 5 without turning them into secret-redaction failures.

**On trigger:**
1. Set `redaction_hard_fail: true`.
2. **Do not present or save the report.** Redact the leak before output, regardless of the quality score.
3. Perform a **narrow redaction-only rewrite**: replace only sensitive values with X's. Preserve code identifiers, locations, and the rest of the evidence.
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
3. Agent reopens source as needed and rewrites the finding from evidence. Never fill a missing trace with invented detail to improve a score; unresolved evidence gaps remain explicit.
4. Grader re-runs on the rewritten finding, including the confidence-trace calibration check.
5. Re-run the redaction gate on the rewritten draft. If quality still fails, mark `grader_failure: true` in metadata and surface it to the human — never silently ship a failing finding as if it passed.

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

- A `confidence_trace_calibration: pass` on a bucket-4 finding still assigned High or Medium confidence. Low confidence with the human-verification tag is the correct calibrated outcome.
- Treating the redaction hard-fail gate as "just another criterion" that can be scored 0/1/2 and deferred to the normal rewrite loop — a live leak blocks the save outright.
- A `pass_rate` computed by excluding findings that failed and were never successfully rewritten (`findings_still_failing` must be counted against the denominator, not dropped).
- Grading a finding's severity/CWE calibration (Criterion 5) as a substitute for the severity × likelihood fix-ordering overlay in `references/risk-prioritization.md` — that overlay answers "which to fix first"; this criterion answers "is this finding's write-up internally consistent." Keep both; do not collapse one into the other.
