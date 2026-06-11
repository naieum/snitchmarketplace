# Custom Selection Menu (Option 10)

When user selects Option 10, present this menu:

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
  [11] Cloud Security (11)            [12] Data Exposure (12)

Modern Stack
  [13] Stripe (13)                   [14] Auth Providers (14)
  [15] AI APIs (15)                  [16] Email Services (16)
  [17] Database (17)                 [18] Redis/Cache (18)
  [19] SMS/Communication (19)

Compliance
  [20] HIPAA (20)                    [21] SOC 2 (21)
  [22] PCI-DSS (22)                  [23] GDPR (23)

Performance
  [24] Memory Leaks (24)             [25] N+1 Queries (25)
  [26] Performance (26)

Infrastructure & Supply Chain
  [27] Dependencies (27)             [28] Authorization/IDOR (28)
  [29] File Uploads (29)             [30] Input Validation (30)
  [31] CI/CD Security (31)           [32] Security Headers (32)
  [33] Unused Dependencies (33)      [40] Tunnels & DNS (40)

Governance & Compliance (Extended)
  [34] FIPS 140-3 (34)               [35] Gov Certifications (35)
  [36] BC/DR (36)                    [37] Monitoring (37)
  [38] Data Classification (38)      [39] Token Lifetimes (39)

License & Supply Chain
  [41] License Compliance (41)

Advanced Security
  [42] Container & Docker (42)         [43] IaC Security (43)
  [44] API Security (44)              [45] AI Tool Supply Chain (45)
  [46] AI/LLM App Security (46)

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
- Map names to category numbers (case-insensitive, partial match)
- Remove duplicates
- Validate all categories are in range 1-60

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
-> Display: "Invalid categories: 99, xyz. Please enter 1-60 or valid names."
-> Re-display menu

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
"cloud" -> 11
"logging" or "data exposure" -> 12
"stripe" -> 13
"providers" or "auth providers" -> 14
"ai" or "ai apis" -> 15
"email" -> 16
"database" or "db" -> 17
"redis" or "cache" -> 18
"sms" or "twilio" or "communication" -> 19
"hipaa" -> 20
"soc" or "soc2" -> 21
"pci" or "pcidss" -> 22
"gdpr" -> 23
"memory" or "memory leaks" -> 24
"n+1" or "n1" or "n plus 1" -> 25
"performance" or "perf" -> 26
"dependencies" or "supply chain" or "deps" -> 27
"authorization" or "idor" or "access control" -> 28
"upload" or "file upload" -> 29
"input" or "validation" or "redos" -> 30
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
"license" or "license compliance" or "sbom" or "copyleft" or "gpl" or "dependency license" -> 41
"container" or "docker" or "dockerfile" -> 42
"iac" or "infrastructure as code" or "terraform" or "kubernetes" or "k8s" or "cloudformation" -> 43
"api" or "api security" or "openapi" or "swagger" or "graphql" or "rest api" -> 44
"ai tool" or "mcp" or "mcp server" or "ai supply chain" or "skill security" or "plugin security" -> 45
"ai app" or "llm security" or "prompt injection" or "rag" or "guardrails" -> 46
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
```
