# Custom Selection Menu (mode `custom`)

When the user chooses the interactive category picker, present this menu. Numbers in brackets are
category IDs, not menu positions. Reserved IDs (11, 24, 25, 26, 41, 46, 64, 69-71) are absent from
the picker on purpose — they are merged or deprecated rows and cannot be scanned.

```
======================================================================
                   Select Categories to Scan
======================================================================

Core Security
  [ 1] SQL Injection (1)              [ 2] XSS (2)
  [ 3] Hardcoded Secrets (3)          [ 4] Authentication (4)
  [ 5] SSRF (5)                       [ 6] Supabase (6)
  [ 7] Rate Limiting (7)              [ 8] CORS (8)
  [ 9] Cryptography (9)              [10] Dangerous Patterns (10)
  [12] Data Exposure (12)

Modern Stack
  [13] Stripe (13)                   [14] Auth Providers (14)
  [15] AI APIs (15)                  [16] Email Services (16)
  [17] Database (17)                 [18] Redis/Cache (18)
  [19] SMS/Communication (19)

Compliance
  [20] HIPAA (20)                    [21] SOC 2 (21)
  [22] PCI-DSS (22)                  [23] GDPR (23)

Infrastructure & Supply Chain
  [27] Dependencies (27)             [28] Authorization/IDOR (28)
  [29] File Uploads (29)             [30] Input Validation (30)
  [31] CI/CD Security (31)           [32] Security Headers (32)
  [33] Unused Dependencies (33)      [40] Tunnels & DNS (40)
  [43] IaC Security (43)

Governance & Compliance (Extended)
  [34] FIPS 140-3 (34)               [35] Gov Certifications (35)
  [36] BC/DR (36)                    [37] Monitoring (37)
  [38] Data Classification (38)      [39] Token Lifetimes (39)

Advanced Security
  [42] Container & Docker (42)        [44] API Security (44)
  [45] AI Tool Supply Chain (45)

Protocol & Session Security
  [47] CSRF (47)                       [48] Race Conditions (48)
  [49] XXE / XML (49)                  [50] Timing Attacks (50)
  [54] OAuth/OIDC (54)                 [56] WebSocket (56)
  [57] GraphQL Deep (57)

Operations & Compliance
  [51] Debug Endpoints (51)            [52] Secrets Rotation (52)
  [53] CCPA & SOX (53)                 [55] Microservices (55)
  [58] Message Queues (58)             [59] Backup Security (59)
  [60] Audit Log Integrity (60)

Modern Attack Classes
  [61] ReDoS (61)                      [62] Prototype Pollution (62)
  [63] JWT Algorithm Attacks (63)      [65] Insecure Deserialization (65)
  [66] Typosquatting/Postinstall (66)
  [67] Type Coercion Bypasses (67)     [68] Agent Prompt Injection (68)
  [72] Header Injection (72)

======================================================================

Enter selection by NUMBER or NAME, separated by spaces:

Examples:
  - By number: "1 3 5 13"
  - By name: "sql injection secrets auth stripe"
  - Mixed: "1 secrets auth 13"

Your selection:
```

## Custom Selection Processing

**Parse Input:**
- Split input by spaces
- For each item, check if it's a number or name
- Map names to category numbers. Names are matched **longest-first and whole-phrase**: try the full
  remaining phrase against the table, then progressively shorter prefixes. A bare token that is a
  proper prefix of a longer entry (`ai` inside `ai tool`, `ai app`) resolves only when the user
  typed nothing more — never by partial match into the longer name
- Remove duplicates
- Validate every ID against `categories/_index.md`. The Status column decides what happens next, and nothing here hardcodes which IDs those are:
  - `active` → scan it
  - `merged→NN` → silently remap to NN and scan that instead (today: 11→43, 46→15, 64→05, 69→27, 70→33, 71→43)
  - `deprecated` → say the category is retired and why (the one-line reason is in its stub file), then drop it from the set (today: 24, 25, 26, 41)
  - not a row at all → invalid input

**Examples:**

Input: `"1 3 5 13"`
-> Selected: 1, 3, 5, 13

Input: `"sql injection secrets auth stripe"`
-> Parsed: "sql injection" -> 1, "secrets" -> 3, "auth" -> 4, "stripe" -> 13
-> Selected: 1, 3, 4, 13

Input: `"1 secrets auth 13"`
-> Parsed: 1, "secrets" -> 3, "auth" -> 4, 13
-> Selected: 1, 3, 4, 13

Input: `"1 1 3 3"`
-> Deduplicated: 1, 3
-> Selected: 1, 3

Input: `"99 xyz"`
-> Invalid categories detected
-> Display: "Invalid categories: 99, xyz. Please pick an ID or name from the menu."
-> Re-display menu

Input: `"11 41"`
-> 11 is `merged→43` — remap silently to 43
-> 41 is `deprecated` — say "Category 41 (License Compliance) is retired: license risk is a legal question, not attacker impact" and drop it
-> Selected: 43

## Name to Category Mapping

Support flexible matching:

```
"sql" or "sql injection" -> 1
"xss" or "cross-site scripting" -> 2
"secrets" or "hardcoded secrets" -> 3
"auth" or "authentication" -> 4
"ssrf" or "server-side request forgery" -> 5
"supabase" -> 6
"rate" or "rate limiting" -> 7
"cors" -> 8
"crypto" or "cryptography" -> 9
"dangerous" or "dangerous patterns" -> 10
"logging" or "data exposure" -> 12
"stripe" -> 13
"providers" or "auth providers" -> 14
"ai apis" or "llm api" or "prompt injection" or "system prompt" or "rag tenancy" or "guardrails" -> 15
"email" -> 16
"database" or "db" -> 17
"redis" or "cache" -> 18
"sms" or "twilio" or "communication" -> 19
"hipaa" -> 20
"soc" or "soc2" -> 21
"pci" or "pcidss" -> 22
"gdpr" -> 23
"dependencies" or "supply chain" or "deps" -> 27
"authorization" or "idor" or "access control" -> 28
"upload" or "file upload" -> 29
"input" or "input validation" or "path traversal" -> 30
"cicd" or "ci/cd" or "pipeline" or "github actions" -> 31
"headers" or "csp" or "security headers" -> 32
"unused" or "bloat" or "unused dependencies" or "dead packages" -> 33
"fips" or "fips140" or "fips 140" or "cryptographic compliance" -> 34
"iso" or "iso27001" or "fedramp" or "cmmc" or "governance" or "nist" -> 35
"bcdr" or "bc/dr" or "business continuity" or "disaster recovery" or "circuit breaker" -> 36
"monitoring" or "observability" or "apm" or "tracing" or "alerting" -> 37
"data classification" or "data lifecycle" or "retention" or "pii" or "data labeling" -> 38
"token" or "token lifetime" or "session lifetime" or "token expiry" or "refresh token" or "session timeout" -> 39
"tunnel" or "ngrok" or "cloudflared" or "cloudflare tunnel" or "wrangler" or "miniflare" or "dns resolver" or "dns security" -> 40
"container" or "docker" or "dockerfile" -> 42
"iac" or "infrastructure as code" or "terraform" or "kubernetes" or "k8s" or "cloudformation" or "cloud" or "cloud security" or "imdsv2" -> 43
"api" or "api security" or "openapi" or "swagger" or "graphql" or "rest api" -> 44
"ai tool" or "mcp" or "mcp server" or "ai supply chain" or "skill security" or "plugin security" or "tool poisoning" -> 45
"csrf" or "cross-site request forgery" or "anti-forgery" -> 47
"race condition" or "race conditions" or "toctou" or "concurrency" -> 48
"xxe" or "xml" or "xml external entity" or "xml injection" -> 49
"timing" or "timing attack" or "timing attacks" or "side channel" -> 50
"debug" or "debug endpoints" or "metrics endpoint" or "profiling" -> 51
"secrets rotation" or "key rotation" or "credential rotation" or "rotate secrets" -> 52
"ccpa" or "sox" or "sarbanes-oxley" or "california privacy" -> 53
"oauth" or "oidc" or "openid" or "openid connect" or "oauth2" -> 54
"microservices" or "service mesh" or "istio" or "envoy" or "k8s networking" -> 55
"websocket" or "ws" or "wss" or "socket.io" or "websocket security" -> 56
"graphql deep" or "graphql security" or "graphql introspection" or "graphql depth" -> 57
"message queue" or "message queues" or "rabbitmq" or "kafka" or "sqs" or "nats" -> 58
"backup" or "backup security" or "snapshots" or "disaster backup" -> 59
"audit log" or "audit log integrity" or "log tampering" or "immutable logs" -> 60
"redos" or "regex dos" or "catastrophic backtracking" -> 61
"prototype pollution" or "proto pollution" or "proto" -> 62
"jwt" or "jwt algorithm" or "alg none" or "jwt attacks" or "algorithm confusion" -> 63
"cloud metadata" or "imds" or "metadata endpoint" or "instance metadata" -> 5  (alias of merged 64; IMDSv2 posture is 43)
"deserialization" or "insecure deserialization" or "pickle" or "unserialize" -> 65
"typosquatting" or "postinstall" or "install scripts" or "malicious packages" -> 66
"type coercion" or "type juggling" or "loose comparison" -> 67
"agent injection" or "agent prompt injection" or "indirect prompt injection" -> 68
"header injection" or "crlf" or "response splitting" or "header smuggling" -> 72
"vulnerable dependencies" or "sca" or "osv" -> 27  (alias of merged 69)
"dead code" -> 33  (alias of merged 70)
"iac misconfiguration" -> 43  (alias of merged 71)
"ai app" or "llm security" -> 15  (alias of merged 46)
```

**Names are unique by construction.** Every phrase above maps to exactly one category. If a new
category needs a name already in this table, rename one of them — an ambiguous name silently scans
the wrong category, and the user never learns it happened. Names for merged IDs stay as explicit
aliases so a user's old vocabulary still resolves.
