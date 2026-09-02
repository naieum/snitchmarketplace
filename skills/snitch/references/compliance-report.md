# Compliance Evidence Report Generation

This reference describes how to generate compliance evidence documents from Snitch scan results using the compliance templates.

## Overview

After a Snitch audit completes, its findings can be mapped to specific compliance framework controls. This process takes the raw scan output and populates the appropriate compliance template to produce a ready-to-review evidence document.

## Process

### 1. Identify the Target Framework

Determine which compliance framework(s) apply. Available templates in `compliance-templates/`:

| Framework | Template File | Common Use Cases |
|-----------|---------------|------------------|
| SOC 2 Type II | `soc2-evidence.md` | SaaS providers, cloud services |
| HIPAA | `hipaa-evidence.md` | Healthcare, health data processors |
| PCI-DSS v4.0.1 | `pci-dss-evidence.md` | Payment processing, cardholder data |
| GDPR | `gdpr-evidence.md` | EU personal data processing |
| CCPA | `ccpa-evidence.md` | California consumer data |
| SOX | `sox-evidence.md` | Public companies, financial systems |

### 2. Read the Compliance Template

Load the template from `compliance-templates/<framework>-evidence.md`. Each template contains:

- Sections organized by regulatory control or requirement
- Mapped Snitch category numbers for each control
- Placeholder fields marked as `[Evidence]`
- Status checkboxes
- Notes sections

### 3. Map Scan Findings to Controls

For each section in the template:

1. Identify the mapped Snitch categories listed in the section header
2. Locate findings from those categories in the scan report
3. Separate findings into two groups:
   - **Findings** -- Issues discovered (with severity, file path, line number, and description)
   - **Passed Checks** -- Categories that were scanned with no issues found

### 4. Fill in Evidence Placeholders

Replace each `[Evidence]` placeholder with the actual data:

**For findings (issues detected):**
```
- Finding: [Severity] - [Description] at [file path]:[line number]
  Remediation status: [Open/In Progress/Resolved]
  Target remediation date: [date]
```

**For passed checks (no issues):**
```
- No issues detected. [N] files scanned across [M] patterns.
  Scan date: [date]
```

**For status checkboxes:**
- Mark `[x] Compliant` if all mapped categories passed with no findings
- Mark `[x] Partially Compliant` if some findings exist but are low severity or have compensating controls
- Mark `[x] Non-Compliant` if critical or high-severity findings remain unresolved

### 5. Add Contextual Notes

In the Notes section for each control, include:

- Compensating controls that mitigate findings
- Remediation timelines for open issues
- References to related policies or procedures
- Exceptions approved by management

### 6. Save the Output

Save the completed evidence document as:

```
COMPLIANCE_EVIDENCE_[FRAMEWORK].md
```

Examples:
- `COMPLIANCE_EVIDENCE_SOC2.md`
- `COMPLIANCE_EVIDENCE_HIPAA.md`
- `COMPLIANCE_EVIDENCE_PCI_DSS.md`
- `COMPLIANCE_EVIDENCE_GDPR.md`
- `COMPLIANCE_EVIDENCE_CCPA.md`
- `COMPLIANCE_EVIDENCE_SOX.md`

Place the file in the project root or designated security artifacts directory.

## Control inventory + control-testing workpaper (auditor aids)

**Framing (read first).** Snitch does not certify compliance. These artifacts are *auditor aids*:
they organize scan evidence the way an assessor expects to consume it — demonstrating that a
control is **present and was tested**, with the scan output as the test evidence. The compliance
determination is the auditor's / firm's to make, not Snitch's. Generate these only when the user
asks for audit-ready packaging; otherwise the evidence document above is sufficient.

The evidence doc above answers "did we find vulnerabilities." An assessor also asks "does the
control that should prevent this class of issue exist, and how do you know it works." Two optional
additions answer that.

### A. Control inventory

A matrix that names the security *control* behind each scanned category (not just the finding).
Map each in-scope Snitch category to the control it exercises:

| Control ID | Control (what should be true) | Framework requirement | Type | Snitch category(ies) | Last tested | Status |
|---|---|---|---|---|---|---|
| AC-01 | All DB access uses parameterized queries / ORM binding | SOC2 CC6.1 · PCI 6.2.4 | Preventive | Cat 01 (SQLi) | {scan date} | Effective / Deficient |
| AC-02 | User input is encoded/sanitized before rendering | SOC2 CC6.1 · PCI 6.2.4 | Preventive | Cat 02 (XSS) | {scan date} | Effective / Deficient |
| AC-03 | Secrets are not hardcoded; loaded from env/secret store | SOC2 CC6.1 · HIPAA 164.312(a) | Preventive | Cat 03/secrets | {scan date} | Effective / Deficient |

- **Type** is Preventive (stops the issue — parameterized queries) or Detective (surfaces it —
  logging, the Snitch scan itself in CI). Note which.
- A control is **Effective** when the mapped category passed with Rule 7 *Pass evidence* across the
  reached sinks (not merely "0 findings") — that traced Pass is the proof the control works.

### B. Control-testing workpaper

For a control under formal review, produce a workpaper per control:

```
Control: AC-01 — Parameterized queries enforced
Objective: Confirm no user-controlled input reaches a SQL sink unsanitized.
Procedure: Snitch Cat 01 scan with Rule 7 data-flow tracing across all DB sink patterns.
Population / sample: <N> DB call sites reached; <M> traced (note if sampled vs exhaustive — say which).
Expected evidence: every reached sink traces to a literal, a bound parameter, or a validated source.
Result: <pass evidence per sink, or findings with file:line + trace>
Exceptions: <any sink that could not be traced — Low confidence / needs human verification>
Conclusion: Effective | Deficiency | Significant deficiency | Material weakness
```

**Deficiency classification** (ties to finding severity, for the conclusion line):

- **Effective** — control present; all reached sinks pass with trace evidence.
- **Deficiency** — isolated gap with a compensating control or low exploitability (cross-ref
  `references/risk-prioritization.md`).
- **Significant deficiency** — High-severity gap, reachable, no compensating control.
- **Material weakness** — Critical, reachable, unauthenticated/internet-facing path.

**No silent sampling.** If the scan sampled rather than traced every site, say so in the workpaper
(population vs. sample) — an assessor reads an unqualified "tested" as exhaustive.

## Multi-Framework Reports

When a project requires compliance with multiple frameworks, generate a separate evidence document for each. Many Snitch categories map to controls across multiple frameworks, so the same finding may appear in several evidence documents.

## Report Metadata

Include the following metadata at the top of each generated evidence document:

```markdown
**Report Generated:** <ISO-8601 timestamp>
**Snitch Scan ID:** <scan identifier or date>
**Project:** <project name>
**Branch:** <git branch>
**Commit:** <git commit hash>
**Categories Scanned:** <count>
**Total Findings:** <count by severity>
```

## Maintenance

Regenerate compliance evidence:
- After each Snitch audit
- Before scheduled compliance reviews or audits
- When findings are remediated (to update status)
- When new categories are added to the Snitch scan
