# Category Group Mappings

These are the preset category groups used by scan menu options 2-9.

## Group 2: Web Security
Categories: 1, 2, 5, 8, 10, 12, 61, 62, 64, 65, 67, 72
- SQL Injection (1)
- Cross-Site Scripting (2)
- SSRF (5)
- CORS Configuration (8)
- Dangerous Code Patterns (10)
- Logging & Data Exposure (12)
- ReDoS (61)
- Prototype Pollution (62)
- Cloud Metadata Exploitation (64)
- Insecure Deserialization (65)
- Type Coercion Bypasses (67)
- HTTP/Protocol Header Injection (72)

## Group 3: Secrets & Authentication
Categories: 3, 4, 7, 39, 63
- Hardcoded Secrets (3)
- Authentication Issues (4)
- Rate Limiting (7)
- Token & Session Lifetimes (39)
- JWT Algorithm & Key Attacks (63)

## Group 4: Modern Stack
Categories: 6, 11, 13, 14, 15, 16, 17, 18, 19, 39, 64, 68
- Supabase Security (6)
- Cloud Security (11)
- Stripe Security (13)
- Auth Providers (14)
- AI API Security (15)
- Email Services (16)
- Database Security (17)
- Redis/Cache Security (18)
- SMS/Communication (19)
- Token & Session Lifetimes (39)
- Cloud Metadata Exploitation (64)
- Agent & Indirect Prompt Injection (68)

## Group 5: Compliance
Categories: 20, 21, 22, 23
- HIPAA (20)
- SOC 2 (21)
- PCI-DSS (22)
- GDPR (23)

## Group 6: Performance
Categories: 24, 25, 26, 61
- Memory Leaks (24)
- N+1 Queries (25)
- Performance Problems (26)
- ReDoS (61) — security-flavored DoS via catastrophic regex backtracking

## Group 7: Infrastructure & Supply Chain
Categories: 27, 28, 29, 30, 31, 32, 33, 40, 41, 66
- Dependency Vulnerabilities (27)
- Authorization & Access Control (28)
- File Upload Security (29)
- Input Validation (30)
- CI/CD Pipeline Security (31)
- Security Headers (32)
- Unused Dependencies & Bloat (33)
- Tunnels & DNS Security (40)
- License Compliance (41)
- Typosquatting & Malicious Install Scripts (66)

## Group 8: Full System Scan
Categories: every row with Status `active` in `categories/_index.md` (69 categories — IDs 69-71 are merged into 27/33/43)

## Group 9: Governance & Compliance (Extended)
Categories: 34, 35, 36, 37, 38
- FIPS 140-3 / Cryptographic Compliance (34)
- Security Governance Certifications (35)
- Business Continuity & Disaster Recovery (36)
- Infrastructure Monitoring & Observability (37)
- Data Classification & Lifecycle (38)
