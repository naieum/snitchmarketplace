# Category Manifest

The single source of truth for category identity and attributes. Every rule elsewhere that
depends on "which categories" resolves against this table — never against hardcoded number lists.

**Rules derived from Type:**
- `sink-pattern` — Rule 7 data-flow tracing (SKILL.md) is REQUIRED; the category file carries the tracing banner.
- `compliance` — grader `compliance_pass_threshold` applies (see `references/grader.md`); evidence-package templates exist in `compliance-templates/`.
- `performance` — omit CWE/OWASP/CVSS tags on findings.
- `posture` — standard finding rules; severity tiers come from the category file's Critical/High/Medium sections.

**Groups** are the preset scan groups (menu options 2–9; see `references/category-groups.md`).
`quick-core` categories are always included in a Quick Scan. A `—` means the category is reached
only by Full System Scan, Custom selection, or smart-detection triggers.

**Status:** `active` = scannable. `merged→NN` = redirect stub; scan the target category instead.

Active categories: 69.

| ID | Slug | Title | Type | Groups | OWASP 2025 | CWE | Status |
|----|------|-------|------|--------|------------|-----|--------|
| 01 | sql-injection | SQL Injection | sink-pattern | web, quick-core | A05 Injection | CWE-89 | active |
| 02 | xss | Cross-Site Scripting (XSS) | sink-pattern | web, quick-core | A05 Injection | CWE-79 | active |
| 03 | hardcoded-secrets | Hardcoded Secrets | posture | secrets-auth, quick-core | A07 Authentication Failures | CWE-798 | active |
| 04 | authentication | Authentication Issues | posture | secrets-auth, quick-core | A07 Authentication Failures | CWE-287 | active |
| 05 | ssrf | SSRF (Server-Side Request Forgery) | sink-pattern | web | A01 Broken Access Control | CWE-918 | active |
| 06 | supabase | Supabase Security | posture | modern-stack | A01 Broken Access Control | CWE-862 | active |
| 07 | rate-limiting | Rate Limiting | posture | secrets-auth | A06 Insecure Design | CWE-770 | active |
| 08 | cors | CORS Configuration | posture | web | A02 Security Misconfiguration | CWE-346 | active |
| 09 | crypto | Cryptography | posture | — | A04 Cryptographic Failures | CWE-327 | active |
| 10 | dangerous-patterns | Dangerous Code Patterns | sink-pattern | web | A05 Injection | CWE-94 | active |
| 11 | cloud | Cloud Security | posture | modern-stack | A02 Security Misconfiguration | CWE-16 | active |
| 12 | data-leaks | Logging & Data Exposure | posture | web | A09 Security Logging and Alerting Failures | CWE-532 | active |
| 13 | stripe | Stripe Security | posture | modern-stack | A07 Authentication Failures | CWE-798 | active |
| 14 | auth-providers | Auth Provider Security (Clerk, Auth0, NextAuth) | posture | modern-stack | A07 Authentication Failures | CWE-287 | active |
| 15 | ai-apis | AI API Security | sink-pattern | modern-stack | A07 Authentication Failures | CWE-798 | active |
| 16 | email | Email Service Security | sink-pattern | modern-stack | A07 Authentication Failures | CWE-798 | active |
| 17 | database | Database Security | sink-pattern | modern-stack | A05 Injection | CWE-89 | active |
| 18 | redis | Redis/Cache Security | posture | modern-stack | A04 Cryptographic Failures | CWE-312 | active |
| 19 | sms | SMS/Communication Security (Twilio) | sink-pattern | modern-stack | A07 Authentication Failures | CWE-798 | active |
| 20 | hipaa | HIPAA | compliance | compliance | A02 Security Misconfiguration | CWE-200 | active |
| 21 | soc2 | SOC 2 | compliance | compliance | A09 Security Logging and Alerting Failures | CWE-778 | active |
| 22 | pci-dss | PCI-DSS | compliance | compliance | A04 Cryptographic Failures | CWE-311 | active |
| 23 | gdpr | GDPR | compliance | compliance | A01 Broken Access Control | CWE-359 | active |
| 24 | memory-leaks | Memory Leaks | performance | performance | — | — | active |
| 25 | n-plus-one | N+1 Queries | performance | performance | — | — | active |
| 26 | performance | Performance Problems | performance | performance | — | — | active |
| 27 | dependencies | Dependency Vulnerabilities / Supply Chain | posture | infra-supply-chain | A03 Software Supply Chain Failures | CWE-1395 | active |
| 28 | authorization | Authorization & Access Control (IDOR) | posture | infra-supply-chain | A01 Broken Access Control | CWE-639 | active |
| 29 | file-uploads | File Upload Security | sink-pattern | infra-supply-chain | A06 Insecure Design | CWE-434 | active |
| 30 | input-validation | Input Validation & ReDoS | sink-pattern | infra-supply-chain | A05 Injection | CWE-20 | active |
| 31 | cicd | CI/CD Pipeline Security | posture | infra-supply-chain | A02 Security Misconfiguration | CWE-250 | active |
| 32 | security-headers | Security Headers | posture | infra-supply-chain | A02 Security Misconfiguration | CWE-693 | active |
| 33 | unused-deps | Unused Dependencies, Dead Code & Package Bloat | posture | infra-supply-chain | A03 Software Supply Chain Failures | CWE-1104 | active |
| 34 | fips | FIPS 140-3 / Cryptographic Compliance | compliance | governance | A04 Cryptographic Failures | CWE-327 | active |
| 35 | governance | Security Governance Certifications | compliance | governance | A02 Security Misconfiguration | CWE-693 | active |
| 36 | bcdr | Business Continuity & Disaster Recovery | posture | governance | A02 Security Misconfiguration | CWE-636 | active |
| 37 | monitoring | Infrastructure Monitoring & Observability | posture | governance | A09 Security Logging and Alerting Failures | CWE-778 | active |
| 38 | data-classification | Data Classification & Lifecycle | posture | governance | A01 Broken Access Control | CWE-200 | active |
| 39 | token-lifetimes | Token & Session Lifetime Analysis | posture | secrets-auth, modern-stack | A07 Authentication Failures | CWE-613 | active |
| 40 | tunnels-dns | Infrastructure Tunneling & DNS Security | posture | infra-supply-chain | A02 Security Misconfiguration | CWE-200 | active |
| 41 | license-compliance | License Compliance | posture | infra-supply-chain | A03 Software Supply Chain Failures | CWE-1395 | active |
| 42 | container-docker | Container & Docker Security | posture | — | A02 Security Misconfiguration | CWE-250 | active |
| 43 | iac-security | Infrastructure as Code Security | posture | — | A02 Security Misconfiguration | CWE-16 | active |
| 44 | api-security | API Security | sink-pattern | — | A01 Broken Access Control | CWE-862 | active |
| 45 | ai-tool-supply-chain | AI Tool Supply Chain Security | posture | — | A08 Software or Data Integrity Failures | CWE-506 | active |
| 46 | ai-llm-app-security | AI/LLM Application Security | sink-pattern | — | A05 Injection | CWE-77 | active |
| 47 | csrf | CSRF Protection | posture | — | A01 Broken Access Control | CWE-352 | active |
| 48 | race-conditions | Race Conditions & Concurrency | posture | — | A06 Insecure Design | CWE-362 | active |
| 49 | xxe | XXE & XML Attacks | posture | — | A05 Injection | CWE-611 | active |
| 50 | timing-attacks | Timing Attacks | posture | — | A04 Cryptographic Failures | CWE-208 | active |
| 51 | debug-endpoints | Debug Endpoints in Production | posture | — | A02 Security Misconfiguration | CWE-489 | active |
| 52 | secrets-rotation | Secrets Rotation & Lifecycle | posture | — | A07 Authentication Failures | CWE-324 | active |
| 53 | ccpa-sox | CCPA & SOX Compliance | compliance | — | A01 Broken Access Control | CWE-359 | active |
| 54 | oauth-oidc | OAuth/OIDC Deep Security | posture | — | A07 Authentication Failures | CWE-287 | active |
| 55 | microservices | Microservices & Service Mesh Security | posture | — | A02 Security Misconfiguration | CWE-284 | active |
| 56 | websocket-security | WebSocket Security | posture | — | A02 Security Misconfiguration | CWE-1385 | active |
| 57 | graphql-deep | GraphQL Deep Security | posture | — | A01 Broken Access Control | CWE-862 | active |
| 58 | message-queues | Message Queue Security | posture | — | A02 Security Misconfiguration | CWE-284 | active |
| 59 | backup-security | Backup & Recovery Security | posture | — | A02 Security Misconfiguration | CWE-530 | active |
| 60 | audit-log-integrity | Audit Log Integrity | posture | — | A09 Security Logging and Alerting Failures | CWE-778 | active |
| 61 | redos | ReDoS | sink-pattern | web, performance | A06 Insecure Design | CWE-1333 | active |
| 62 | prototype-pollution | Prototype Pollution | sink-pattern | web | A05 Injection | CWE-1321 | active |
| 63 | jwt-algorithm-attacks | JWT Algorithm & Key Attacks | posture | secrets-auth | A07 Authentication Failures | CWE-347 | active |
| 64 | cloud-metadata | Cloud Metadata Endpoint Exploitation | sink-pattern | web, modern-stack | A01 Broken Access Control | CWE-918 | active |
| 65 | insecure-deserialization | Insecure Deserialization | sink-pattern | web | A08 Software or Data Integrity Failures | CWE-502 | active |
| 66 | typosquatting-postinstall | Typosquatting & Malicious Install Scripts | posture | infra-supply-chain | A03 Software Supply Chain Failures | CWE-1357 | active |
| 67 | type-coercion | Type Coercion & Juggling Bypasses | sink-pattern | web | A07 Authentication Failures | CWE-697 | active |
| 68 | agent-prompt-injection | Agent & Indirect Prompt Injection | sink-pattern | modern-stack | A05 Injection | CWE-1427 | active |
| 69 | vulnerable-dependencies | Vulnerable Dependencies (SCA) | posture | — | A03 Software Supply Chain Failures | CWE-1395 | merged→27 |
| 70 | dead-code-unused-deps | Dead Code & Unused Dependencies | posture | — | A03 Software Supply Chain Failures | CWE-1104 | merged→33 |
| 71 | iac-misconfiguration | IaC Misconfiguration | posture | — | A02 Security Misconfiguration | CWE-16 | merged→43 |
| 72 | header-injection | HTTP/Protocol Header Injection | sink-pattern | web | A05 Injection | CWE-113 | active |

Notes:
- The OWASP/CWE columns are the canonical per-category standards mapping (formerly duplicated in
  `references/standards-table.md`, which now holds only tagging instructions and CVSS alignment).
- Two label corrections from the old table: A06 is Insecure Design (was mislabeled A04 for
  categories 07/29/48/61) and category 46 maps to A05 Injection (was mislabeled A03).
