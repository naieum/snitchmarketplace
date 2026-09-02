# PCI-DSS v4.0.1 Evidence Template

Fill in the [Evidence] placeholders with findings and passed checks from your Snitch scan report.

> This template supports your compliance process. It does not certify compliance.

> **Version.** Requirement numbering here is **PCI DSS v4.0.1**, the sole supported version since
> 31 December 2024. The future-dated v4 requirements — including 6.4.3 and 11.6.1 below — became
> mandatory on **31 March 2025**. If a report you are reconciling against cites `6.5`, `3.2`, `3.4`,
> or `4.1` for coding vulnerabilities, PAN storage, or TLS, it is using v3.2.1 numbering, retired
> 31 March 2024. Those numbers exist in v4.0.1 and mean different things.

> **Scope.** Snitch reads source code. It can evidence the code-visible half of these requirements
> and nothing else. Every section below states what it cannot cover; leave those to your QSA rather
> than marking them Compliant on the strength of a scan.

---

## Requirement 6.2 -- Bespoke and Custom Software Developed Securely

**Requirement text (6.2.1):** "Bespoke and custom software are developed securely, as follows: Based
on industry standards and/or best practices for secure development. In accordance with PCI DSS (for
example, secure authentication and logging). Incorporating consideration of information security
issues during each stage of the software development lifecycle."

**Mapped Snitch categories:** 3 (Hardcoded Secrets), 4 (Authentication Issues), 12 (Logging & Data
Exposure), 22 (PCI-DSS), 27 (Dependency Vulnerabilities / Supply Chain)

**Snitch cannot evidence:** 6.2.2 (annual secure-development training for development personnel) or
6.2.3 (manual or automated code review before release, and reviewer independence). Those are process
records.

### Snitch Evidence

**Category 3 -- Hardcoded Secrets**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 4 -- Authentication Issues**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 12 -- Logging & Data Exposure**
- Findings: [Evidence]
- Passed Checks: [Evidence]

**Category 22 -- PCI-DSS**
- Findings: [Evidence]
- Passed Checks: [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 6.2.4 -- Prevention of Common Software Attacks

**Requirement text:** "Software engineering techniques or other methods are defined and in use by
software development personnel to prevent or mitigate common software attacks and related
vulnerabilities in bespoke and custom software."

This is the requirement a source-code scan speaks to most directly. The rows below follow 6.2.4's own
enumerated attack classes. Each category's CWE is the one in `categories/_index.md`; do not
substitute a different CWE for a category here, since the two are cross-checked by `lint-skills.sh`.

| 6.2.4 attack class | Snitch Category | CWE |
|---|---|---|
| Injection attacks — SQL, LDAP, XPath, command, parameter, object, fault | Category 1 (SQL Injection) | CWE-89 |
| Injection attacks — code and command execution | Category 10 (Dangerous Code Patterns) | CWE-94 |
| Attacks on data and data structures — input manipulation | Category 30 (Input Validation) | CWE-20 |
| Attacks on data and data structures — object manipulation | Category 65 (Insecure Deserialization) | CWE-502 |
| Attacks on data and data structures — XML entity processing | Category 49 (XXE & XML Attacks) | CWE-611 |
| Attacks on cryptography usage — weak algorithms, modes, cipher suites | Category 9 (Cryptography) | CWE-327 |
| Attacks on business logic — cross-site scripting (XSS), named in 6.2.4 | Category 2 (Cross-Site Scripting) | CWE-79 |
| Attacks on business logic — cross-site request forgery (CSRF), named in 6.2.4 | Category 47 (CSRF Protection) | CWE-352 |
| Attacks on business logic — abuse of APIs and server-side request handling | Category 5 (SSRF) | CWE-918 |
| Attacks on access control — bypass of authentication | Category 4 (Authentication Issues) | CWE-287 |
| Attacks on access control — bypass of authorization | Category 28 (Authorization & Access Control) | CWE-639 |
| High-risk vulnerabilities per 6.3.1 — untrusted file handling | Category 29 (File Upload Security) | CWE-434 |

**Applicability note from the standard:** 6.2.4 "applies to all software developed for or by the
entity for the entity's own use. This includes both bespoke and custom software. This does not apply
to third-party software." Findings in vendor dependencies belong under 6.3, not here.

### Snitch Evidence

- Findings by attack class: [Evidence]
- Passed checks by attack class: [Evidence]
- Categories scanned vs. categories in the table above: [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 6.3 -- Security Vulnerabilities Identified and Addressed

**Requirement text (6.3.1):** "Security vulnerabilities are identified and managed as follows: New
security vulnerabilities are identified using industry-recognized sources for security vulnerability
information … vulnerabilities are assigned a risk ranking …"

**Requirement text (6.3.2):** "An inventory of bespoke and custom software, and third-party software
components incorporated into bespoke and custom software is maintained to facilitate vulnerability
and patch management."

**Mapped Snitch categories:** 27 (Dependency Vulnerabilities / Supply Chain), 33 (Unused
Dependencies, Dead Code & Package Bloat), 66 (Typosquatting & Malicious Install Scripts)

**Snitch cannot evidence:** 6.3.3 (installing applicable security patches within the required
timeframe) — that is a patch-management record, not a code property.

### Snitch Evidence

**Software inventory (6.3.2)**
- Dependency inventory / SBOM location: [Evidence]
- Direct vs. transitive component count: [Evidence]

**Vulnerability identification (6.3.1)**
- Advisory source used and date checked: [Evidence]
- Findings by risk ranking: [Evidence]
- SARIF report location: [Evidence]
- Last scan date / scan frequency: [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 6.4.3 -- Payment Page Script Management

> **Mandatory since 31 March 2025.** Applies to e-commerce entities with a payment page rendered in
> the consumer's browser.

**Requirement text:** "All payment page scripts that are loaded and executed in the consumer's
browser are managed as follows: A method is implemented to confirm that each script is authorized. A
method is implemented to assure the integrity of each script. An inventory of all scripts is
maintained with written business or technical justification as to why each is necessary."

**Customized approach objective:** "Unauthorized code cannot be executed in the payment page as it is
rendered in the consumer's browser."

This is the anti-skimming (Magecart) requirement, and it is unusually code-visible — script tags,
subresource integrity attributes, and Content-Security-Policy headers all live in the repository.

**Mapped Snitch categories:** 22 (PCI-DSS), 32 (Security Headers)

### Snitch Evidence

- Payment page(s) identified: [Evidence]
- Scripts loaded on each payment page, first- and third-party: [Evidence]
- Scripts carrying subresource integrity (`integrity=`): [Evidence]
- Scripts constrained by a `script-src` CSP directive: [Evidence]
- Script inventory document location and last review date: [Evidence]
- Tag managers or script loaders present (these can inject further scripts after load, so an
  integrity digest on the loader does not bound what executes): [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 11.6.1 -- Change and Tamper Detection on Payment Pages

> **Mandatory since 31 March 2025.** Applies to e-commerce entities with a payment page rendered in
> the consumer's browser.

**Requirement text:** "A change- and tamper-detection mechanism is deployed as follows: To alert
personnel to unauthorized modification (including indicators of compromise, changes, additions, and
deletions) to the security-impacting HTTP headers and the script contents of payment pages as
received by the consumer browser. The mechanism is configured to evaluate the received HTTP headers
and payment pages. The mechanism functions are performed as follows: at least weekly OR periodically
(at the frequency defined in the entity's targeted risk analysis, which is performed according to all
elements specified in Requirement 12.3.1)."

**Mapped Snitch categories:** 32 (Security Headers), 22 (PCI-DSS)

**Snitch cannot evidence** the monitoring mechanism itself — whether it runs, at what frequency, and
whether alerts reach personnel. A scan can show the security-impacting headers the application sets
and whether a CSP reporting endpoint is configured. The rest is an operational control.

### Snitch Evidence

- Security-impacting response headers set on payment pages (CSP, HSTS, X-Frame-Options,
  X-Content-Type-Options): [Evidence]
- CSP `report-uri` / `report-to` endpoint configured: [Evidence]
- Monitoring mechanism, frequency, and alert routing (from your operations documentation, not from
  the scan): [Evidence]
- Targeted risk analysis reference if using a frequency other than weekly: [Evidence]

### Status

- [ ] Compliant
- [ ] Non-Compliant
- [ ] Partially Compliant

### Notes

[Add auditor notes, remediation timelines, or compensating controls here.]

---

## Requirement 11.3 -- Vulnerability Scanning

> **Read this before filling the section in.** 11.3.1 requires **internal vulnerability scans** and
> 11.3.2 requires **external scans performed by a PCI SSC Approved Scanning Vendor (ASV)**. Both are
> infrastructure and network scans of running systems. **A source-code scan is neither, and cannot
> satisfy either one.** Snitch output is supporting evidence for the remediation half of 11.3.1.1
> (addressing what scans find), not evidence that a scan was performed.

**Mapped Snitch categories:** all scanned categories

### Snitch Evidence

- ASV scan reports (from your ASV, not from Snitch): [Evidence]
- Internal vulnerability scan reports (from your scanning tooling, not from Snitch): [Evidence]

**Supporting code-scan evidence for remediation tracking:**
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
