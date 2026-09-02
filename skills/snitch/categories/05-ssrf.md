## CATEGORY 5: SSRF (Server-Side Request Forgery)
> Type: sink-pattern · Groups: web, modern-stack · CWE: CWE-918

> **Scope.** Category 64 (Cloud Metadata Endpoint Exploitation) was merged into this one: the cloud
> metadata endpoint is SSRF's highest-impact target, not a separate sink. The instance-level
> controls that sit outside application code — IMDSv2 enforcement, egress NetworkPolicy — are
> infrastructure posture and belong to Category 43 (IaC Security).

**Data flow tracing required (SKILL.md Rule 7).** For every `fetch()` / `http.get()` / `axios.*` / `request()` / `urllib` call this category surfaces, trace the URL argument back to its source. Hardcoded URLs are Passes. URLs constructed from validated allow-lists (`if (ALLOWED_HOSTS.includes(host))`) are Passes — record the allow-list's file:line. URLs constructed from `req.*` / `params.*` / file content / agent output without an allow-list check are findings. Trace must cross URL-builder helpers; SSRF often hides in a `buildUrl(host, path)` utility two files away. Escalate severity when the workload carries a stealable instance-profile or service-account token — metadata credential theft chains to lateral movement.

### Detection
- HTTP client libraries: `fetch`, `axios`, `got`, `node-fetch`, `undici`, `requests`, `httpx`, `urllib`, `http.Client`
- URL construction from dynamic sources
- Webhook or callback URL handling patterns
- The high-value SSRF surfaces: webhook delivery, URL preview/unfurl, image proxy, PDF/SSR rendering, file-from-URL import
- Workloads on AWS EC2/ECS/Lambda/EKS, Azure VM/AKS, GCP Compute/GKE — where a reachable metadata endpoint turns an SSRF into credential theft
- URL allowlist/denylist implementations for outbound requests

### What to Search For
- fetch/axios/request with dynamic URLs
- User input flowing into URL parameters
- Webhook URL handling
- URL validation using weak methods — substring or prefix match on the URL string rather than parsing and resolving it
- Outbound HTTP reachable from user input that does not block the link-local metadata address (`169.254.169.254`), its IPv6 form (`fd00:ec2::254`), or the GCP metadata host (`metadata.google.internal`)
- DNS resolved once before the fetch with no re-check of the resolved address against the denylist (DNS rebinding)
- Redirects followed without re-applying the denylist on each hop
- A metadata header (`Metadata-Flavor: Google`, `Metadata: true`) forwarded from user-controlled input

### Actually Vulnerable
- Fetching URLs directly from user input
- User-controlled webhook/callback URLs
- Validation using string includes instead of proper parsing
- URL-fetch endpoint that returns the response body to the user with no host/IP denylist
- Image/PDF/screenshot renderer that follows redirects to `169.254.169.254`, `fd00:ec2::254`, or `metadata.google.internal`

### NOT Vulnerable
- Hardcoded URLs
- Environment variable base with static paths
- Proper URL parsing with allowlist validation
- Internal service calls without user input
- Outbound fetch through a hardened client (a `ssrf-agent` / `safe-fetch`-style wrapper, or an explicit `lookup` function that rejects link-local and private ranges) that re-checks on each redirect
- Metadata reachable in principle but blocked outside the application — IMDSv2 required, or an egress NetworkPolicy/firewall rule. Record it as a Pass here and scan Category 43 for the infrastructure evidence

### Context Check
1. Does user input flow into the URL?
2. Is there URL validation before the request?
3. Does validation handle IP bypass formats (decimal/octal IPs, `0.0.0.0`, internal hostnames)?
4. Is the denylist applied to the **resolved IP**, not just the hostname string?
5. Are redirects followed, and is the denylist re-applied on each hop?
6. Does the code run with an attached instance-profile / service-account token worth stealing?

### Evidence Chain
- The sink (HTTP client call with a dynamic URL) quoted at file:line
- The traced URL path from source to sink, hop by hop — including any URL-builder helpers crossed (e.g. `req.body.webhookUrl` → `buildUrl()` → `fetch()`)
- Validation checked along the path and found absent or weak (allow-list check, proper URL parsing vs string `includes`) — or, for a Pass, the allow-list's file:line
- Source classification: user-controlled (`req.*`, `params.*`, file content, agent output) vs hardcoded/env-based
- Whether the validation, if any, handles IP bypass formats and re-checks the resolved address on every redirect hop
- For a metadata-reachable finding: whether a stealable instance-profile / service-account token is attached, and what Category 43 found (or did not find) about IMDSv2 and egress policy — this is what separates a Medium from a Critical

### Confidence Scoring
- **High** — complete trace from a user-controlled source into the request URL with no allow-list or parsing validation on the path; highest when the workload's metadata endpoint is reachable and holds a stealable token
- **Medium** — dynamic URL confirmed at the sink but the source is partially traced, or validation exists but is weak (string `includes`, prefix match, no IP-bypass handling, denylist not re-checked on redirect), or the workload's metadata protection status is unknown
- **Low** — dynamic URL whose source is un-traceable (config-driven, external caller, dynamic dispatch) → tag `needs human verification`

### Files to Check
- `**/api/**`, `**/routes/**`, `**/services/**`
- Webhook handlers, callback URL processors
- HTTP client utility files
- `**/webhook*.ts`, `**/fetch*.ts`, `**/proxy*.ts`, `**/unfurl*.ts`, `**/preview*.ts`
- Image / PDF / screenshot / SSR renderer code
