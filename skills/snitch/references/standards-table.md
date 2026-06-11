# Standards Reference

Tag each finding with the applicable CWE, OWASP Top 10:2025 category, and approximate CVSS 4.0 score. Use the tables below. Non-security categories (24-26) have no standards mapping -- omit tags for those.

## OWASP Top 10:2025 + CWE Mapping

| Cat | Name | OWASP Top 10:2025 | Primary CWE |
|-----|------|--------------------|-------------|
| 1 | SQL Injection | A05 Injection | CWE-89 |
| 2 | XSS | A05 Injection | CWE-79 |
| 3 | Hardcoded Secrets | A07 Authentication Failures | CWE-798 |
| 4 | Auth & Login | A07 Authentication Failures | CWE-287 |
| 5 | SSRF | A10 Server-Side Request Forgery | CWE-918 |
| 6 | Supabase | A01 Broken Access Control | CWE-862 |
| 7 | Rate Limiting | A04 Insecure Design | CWE-770 |
| 8 | CORS | A05 Injection | CWE-346 |
| 9 | Crypto | A04 Cryptographic Failures | CWE-327 |
| 10 | Dangerous Patterns | A05 Injection | CWE-94 |
| 11 | Cloud | A02 Security Misconfiguration | CWE-16 |
| 12 | Data Leaks | A09 Security Logging and Alerting Failures | CWE-532 |
| 13 | Stripe | A07 Authentication Failures | CWE-798 |
| 14 | Auth Providers | A07 Authentication Failures | CWE-287 |
| 15 | AI APIs | A07 Authentication Failures | CWE-798 |
| 16 | Email | A07 Authentication Failures | CWE-798 |
| 17 | Database | A05 Injection | CWE-89 |
| 18 | Redis & Cache | A04 Cryptographic Failures | CWE-312 |
| 19 | SMS (Twilio) | A07 Authentication Failures | CWE-798 |
| 20 | HIPAA | A02 Security Misconfiguration | CWE-200 |
| 21 | SOC 2 | A09 Security Logging and Alerting Failures | CWE-778 |
| 22 | PCI-DSS | A04 Cryptographic Failures | CWE-311 |
| 23 | GDPR | A01 Broken Access Control | CWE-359 |
| 24 | Memory Leaks | N/A | N/A |
| 25 | N+1 Queries | N/A | N/A |
| 26 | Performance | N/A | N/A |
| 27 | Dependencies | A03 Software Supply Chain Failures | CWE-1395 |
| 28 | Authorization (IDOR) | A01 Broken Access Control | CWE-639 |
| 29 | File Uploads | A04 Insecure Design | CWE-434 |
| 30 | Input Validation | A05 Injection | CWE-20 |
| 31 | CI/CD Security | A02 Security Misconfiguration | CWE-200 |
| 32 | Security Headers | A02 Security Misconfiguration | CWE-693 |
| 33 | Unused Dependencies | A03 Software Supply Chain Failures | CWE-1104 |
| 34 | FIPS 140-3 | A04 Cryptographic Failures | CWE-327 |
| 35 | Governance Certs | A02 Security Misconfiguration | CWE-693 |
| 36 | BC/DR | A02 Security Misconfiguration | CWE-636 |
| 37 | Monitoring | A09 Security Logging and Alerting Failures | CWE-778 |
| 38 | Data Classification | A01 Broken Access Control | CWE-200 |
| 39 | Token Lifetimes | A07 Authentication Failures | CWE-613 |
| 40 | Tunnels & DNS | A02 Security Misconfiguration | CWE-200 |
| 41 | License Compliance | A03 Software Supply Chain Failures | CWE-1395 |
| 42 | Container & Docker | A02 Security Misconfiguration | CWE-250 |
| 43 | IaC Security | A02 Security Misconfiguration | CWE-16 |
| 44 | API Security | A01 Broken Access Control | CWE-862 |
| 45 | AI Tool Supply Chain | A08 Software and Data Integrity Failures | CWE-506 |
| 46 | AI/LLM App Security | A03 Injection | CWE-77 |
| 47 | CSRF | A01 Broken Access Control | CWE-352 |
| 48 | Race Conditions | A04 Insecure Design | CWE-362 |
| 49 | XXE / XML | A05 Injection | CWE-611 |
| 50 | Timing Attacks | A04 Cryptographic Failures | CWE-208 |
| 51 | Debug Endpoints | A02 Security Misconfiguration | CWE-489 |
| 52 | Secrets Rotation | A07 Authentication Failures | CWE-324 |
| 53 | CCPA & SOX | A01 Broken Access Control | CWE-359 |
| 54 | OAuth/OIDC | A07 Authentication Failures | CWE-287 |
| 55 | Microservices | A02 Security Misconfiguration | CWE-284 |
| 56 | WebSocket Security | A02 Security Misconfiguration | CWE-1385 |
| 57 | GraphQL Deep | A01 Broken Access Control | CWE-862 |
| 58 | Message Queues | A02 Security Misconfiguration | CWE-284 |
| 59 | Backup Security | A02 Security Misconfiguration | CWE-530 |
| 60 | Audit Log Integrity | A09 Security Logging and Alerting Failures | CWE-778 |
| 61 | ReDoS | A04 Insecure Design | CWE-1333 |
| 62 | Prototype Pollution | A05 Injection | CWE-1321 |
| 63 | JWT Algorithm Attacks | A07 Authentication Failures | CWE-347 |
| 64 | Cloud Metadata | A10 Server-Side Request Forgery | CWE-918 |
| 65 | Insecure Deserialization | A08 Software and Data Integrity Failures | CWE-502 |
| 66 | Typosquatting / Postinstall | A03 Software Supply Chain Failures | CWE-1357 |
| 67 | Type Coercion Bypasses | A07 Authentication Failures | CWE-697 |
| 68 | Agent Prompt Injection | A05 Injection | CWE-1427 |

## CVSS 4.0 Severity Alignment

| Severity | CVSS 4.0 Range | Example |
|----------|---------------|---------|
| Critical | 9.0 - 10.0 | RCE, auth bypass, mass data leak |
| High | 7.0 - 8.9 | SQLi, stored XSS, SSRF to internal |
| Medium | 4.0 - 6.9 | Reflected XSS, CORS miscfg, missing headers |
| Low | 0.1 - 3.9 | Info disclosure, verbose errors |
