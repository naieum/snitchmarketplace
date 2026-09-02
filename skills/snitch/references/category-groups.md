# Category Group Mappings

These are the preset category groups behind the preset scan modes.

**Resolution rule (the manifest is authoritative).** A group's membership is every row in
`categories/_index.md` whose `Groups` column contains that group's name **and** whose `Status` is
`active`. Merged and deprecated rows are never in a group, whatever their number. The rosters below
are a reading convenience regenerated from the manifest — if one ever disagrees with the manifest,
the manifest wins and the roster is the bug.

## `quick-core` — always included in mode `quick`
- SQL Injection (1)
- Cross-Site Scripting (2)
- Hardcoded Secrets (3)
- Authentication Issues (4)

## `web` — mode `preset:web`
- SQL Injection (1)
- Cross-Site Scripting (2)
- SSRF (5) — now also covers the cloud metadata endpoint (64 merged in)
- CORS Configuration (8)
- Dangerous Code Patterns (10)
- Logging & Data Exposure (12)
- ReDoS (61)
- Prototype Pollution (62)
- Insecure Deserialization (65)
- Type Coercion Bypasses (67)
- HTTP/Protocol Header Injection (72)

## `secrets-auth` — mode `preset:secrets-auth`
- Hardcoded Secrets (3)
- Authentication Issues (4)
- Rate Limiting (7)
- Token & Session Lifetimes (39)
- JWT Algorithm & Key Attacks (63)

## `modern-stack` — mode `preset:modern-stack`
- SSRF (5)
- Supabase Security (6)
- Stripe Security (13)
- Auth Providers (14)
- AI API Security (15)
- Email Services (16)
- Database Security (17)
- Redis/Cache Security (18)
- SMS/Communication (19)
- Token & Session Lifetimes (39)
- Infrastructure as Code Security (43) — the cloud posture checks 11 was merged into
- Agent & Indirect Prompt Injection (68)

## `compliance` — mode `compliance`
- HIPAA (20)
- SOC 2 (21)
- PCI-DSS (22)
- GDPR (23)

## `infra-supply-chain` — mode `preset:infra`
- Dependency Vulnerabilities (27)
- Authorization & Access Control (28)
- File Upload Security (29)
- Input Validation (30)
- CI/CD Pipeline Security (31)
- Security Headers (32)
- Unused Dependencies & Bloat (33)
- Tunnels & DNS Security (40)
- Infrastructure as Code Security (43)
- Typosquatting & Malicious Install Scripts (66)

## `governance` — mode `preset:governance`
- FIPS 140-3 / Cryptographic Compliance (34)
- Security Governance Certifications (35)
- Business Continuity & Disaster Recovery (36)
- Infrastructure Monitoring & Observability (37)
- Data Classification & Lifecycle (38)

## Mode `full` — the Full System Scan
Every manifest row with Status `active`: 62 categories. The reserved numbers are 11, 24, 25, 26, 41,
46, 64, 69, 70, and 71 — each a redirect or deprecation stub, and none of them scannable. Resolve the
set from the manifest, never from a number range.
