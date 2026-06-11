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
| PCI-DSS v4.0 | `pci-dss-evidence.md` | Payment processing, cardholder data |
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
