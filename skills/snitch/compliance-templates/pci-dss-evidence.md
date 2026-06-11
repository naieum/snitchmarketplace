# PCI-DSS v4.0 Evidence Template

Fill in the [Evidence] placeholders with findings and passed checks from your Snitch scan report.

> This template supports your compliance process. It does not certify compliance.

---

## Requirement 6.2 -- Secure Development

**Mapped Snitch Categories:** 1 (Hardcoded Secrets), 2 (Dangerous Code Patterns), 5 (Injection Attacks), 10 (Dependency Vulnerabilities), 30 (Secure Coding Practices)

### Control Description

Bespoke and custom software are developed securely. Software development personnel working on bespoke and custom software are trained in software security relevant to their job function and development languages at least once every 12 months.

### Snitch Evidence

**Category 1 -- Hardcoded Secrets**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 2 -- Dangerous Code Patterns**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 5 -- Injection Attacks**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 10 -- Dependency Vulnerabilities**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 30 -- Secure Coding Practices**
- Findings: [Evidence]
- Passed Checks: [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 6.3 -- Security Testing

### Control Description

Security vulnerabilities are identified and addressed. Known security vulnerabilities in custom and bespoke software are identified and managed through a defined process.

### Snitch Evidence

**SARIF Output**
- SARIF report location: [Evidence]
- Total findings: [Evidence]
- Critical/High findings: [Evidence]

**Scan History**
- Last scan date: [Evidence]
- Scan frequency: [Evidence]
- Previous scan comparison: [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 6.5 -- Coding Vulnerabilities

### Control Description

Changes to all software components on production systems are made in accordance with secure development practices, including but not limited to the prevention of common coding vulnerabilities.

### Snitch Evidence

**CWE Mapping**

| CWE ID | CWE Name | Snitch Category | Status |
|--------|----------|-----------------|--------|
| CWE-79 | Cross-Site Scripting | Category 6 | [Evidence] |
| CWE-89 | SQL Injection | Category 5 | [Evidence] |
| CWE-798 | Hardcoded Credentials | Category 1 | [Evidence] |
| CWE-327 | Broken Crypto | Category 3 | [Evidence] |
| CWE-502 | Deserialization | Category 2 | [Evidence] |
| CWE-611 | XXE | Category 5 | [Evidence] |
| CWE-918 | SSRF | Category 9 | [Evidence] |
| CWE-22 | Path Traversal | Category 7 | [Evidence] |

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 11.3 -- Vulnerability Scanning

### Control Description

External and internal vulnerabilities are regularly identified, prioritized, and addressed. Internal vulnerability scans are performed at least once every three months and after any significant change.

### Snitch Evidence

**Full Scan Report**
- Scan date: [Evidence]
- Scope: [Evidence]
- Total categories scanned: [Evidence]
- Findings by severity:
  - Critical: [Evidence]
  - High: [Evidence]
  - Medium: [Evidence]
  - Low: [Evidence]
  - Informational: [Evidence]
- Remediation status: [Evidence]
- Rescan date (if applicable): [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]
