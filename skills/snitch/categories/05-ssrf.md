## CATEGORY 5: SSRF (Server-Side Request Forgery)
> Type: sink-pattern · Groups: web · CWE: CWE-918

**Data flow tracing required (SKILL.md Rule 7).** For every `fetch()` / `http.get()` / `axios.*` / `request()` / `urllib` call this category surfaces, trace the URL argument back to its source. Hardcoded URLs are Passes. URLs constructed from validated allow-lists (`if (ALLOWED_HOSTS.includes(host))`) are Passes — record the allow-list's file:line. URLs constructed from `req.*` / `params.*` / file content / agent output without an allow-list check are findings. Trace must cross URL-builder helpers; SSRF often hides in a `buildUrl(host, path)` utility two files away.

### Detection
- HTTP client libraries: `fetch`, `axios`, `got`, `node-fetch`, `undici`
- URL construction from dynamic sources
- Webhook or callback URL handling patterns

### What to Search For
- fetch/axios/request with dynamic URLs
- User input flowing into URL parameters
- Webhook URL handling
- URL validation using weak methods

### Actually Vulnerable
- Fetching URLs directly from user input
- User-controlled webhook/callback URLs
- Validation using string includes instead of proper parsing

### NOT Vulnerable
- Hardcoded URLs
- Environment variable base with static paths
- Proper URL parsing with allowlist validation
- Internal service calls without user input

### Context Check
1. Does user input flow into the URL?
2. Is there URL validation before the request?
3. Does validation handle IP bypass formats?

### Evidence Chain
- The sink (HTTP client call with a dynamic URL) quoted at file:line
- The traced URL path from source to sink, hop by hop — including any URL-builder helpers crossed (e.g. `req.body.webhookUrl` → `buildUrl()` → `fetch()`)
- Validation checked along the path and found absent or weak (allow-list check, proper URL parsing vs string `includes`) — or, for a Pass, the allow-list's file:line
- Source classification: user-controlled (`req.*`, `params.*`, file content, agent output) vs hardcoded/env-based
- Whether the validation, if any, handles IP bypass formats (decimal/octal IPs, redirects, `0.0.0.0`, internal hostnames)

### Confidence Scoring
- **High** — complete trace from a user-controlled source into the request URL with no allow-list or parsing validation on the path
- **Medium** — dynamic URL confirmed at the sink but the source is partially traced, or validation exists but is weak (string `includes`, prefix match, no IP-bypass handling)
- **Low** — dynamic URL whose source is un-traceable (config-driven, external caller, dynamic dispatch) → tag `needs human verification`

### Files to Check
- `**/api/**`, `**/routes/**`, `**/services/**`
- Webhook handlers, callback URL processors
- HTTP client utility files
