## CATEGORY 5: SSRF (Server-Side Request Forgery)

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

### Files to Check
- `**/api/**`, `**/routes/**`, `**/services/**`
- Webhook handlers, callback URL processors
- HTTP client utility files
