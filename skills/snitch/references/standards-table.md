# Standards Reference

Tag each finding with the applicable CWE, OWASP Top 10:2025 category, and approximate CVSS 4.0
score. The canonical per-category OWASP + CWE mapping is the manifest — `categories/_index.md`,
one row per category — and each category file echoes its own tags in the metadata line under its
title. Omit tags for `Type: performance` categories.

Findings may cite a more specific CWE than the category anchor when the evidence supports it
(e.g., CWE-943 for a NoSQL injection found under category 01); the manifest CWE is the default,
not a ceiling.

## CVSS 4.0 Severity Alignment

| Severity | CVSS 4.0 Range | Example |
|----------|---------------|---------|
| Critical | 9.0 - 10.0 | RCE, auth bypass, mass data leak |
| High | 7.0 - 8.9 | SQLi, stored XSS, SSRF to internal |
| Medium | 4.0 - 6.9 | Reflected XSS, CORS miscfg, missing headers |
| Low | 0.1 - 3.9 | Info disclosure, verbose errors |
