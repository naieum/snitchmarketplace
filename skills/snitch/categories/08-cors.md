## CATEGORY 8: CORS Configuration
> Type: posture · Groups: web · CWE: CWE-346

### Detection
- CORS middleware: `cors` package, `Access-Control-Allow-Origin` headers
- Framework CORS config: Next.js `next.config.js` headers, Express `cors()` middleware
- Manual header setting in API routes

### What to Search For
- CORS middleware configuration
- Access-Control headers
- Origin handling with credentials

### Actually Vulnerable
- Wildcard origin combined with credentials enabled
- Origin reflection without validation

### NOT Vulnerable
- Wildcard origin without credentials (public APIs)
- Specific origin allowlist
- Origin validation function

### Context Check
1. Is this a public API intended for cross-origin access?
2. Are credentials (cookies, auth headers) being sent with CORS requests?
3. Is the origin allowlist properly restricted to known domains?

### Evidence Chain
- The CORS config or header-setting code quoted at file:line (middleware options, `next.config.js` headers, or manual `res.setHeader` calls)
- Both halves of the dangerous combination shown: the origin value (`*` or reflected `req.headers.origin`) AND the credentials setting (`credentials: true` / `Access-Control-Allow-Credentials: true`)
- For origin-reflection findings: confirmation that no validation function or allowlist check guards the reflected value
- The reachability/impact link: which routes the config covers and whether they serve authenticated (cookie/session-bearing) responses

### Confidence Scoring
- **High** — unambiguous config: wildcard or unvalidated reflected origin together with credentials enabled, on routes that serve authenticated responses
- **Medium** — permissive origin confirmed but the credentials side or the routes' authenticated status is only partially established, or an origin validation function exists but its allowlist couldn't be confirmed as restrictive
- **Low** — CORS headers may be set or overridden at a proxy/CDN layer outside the repo, or the API's public-vs-authenticated intent is unclear → tag `needs human verification`

### Files to Check
- `**/cors*.ts`, `**/middleware*.ts`
- `next.config.*`, `**/server*.ts`
- API route files setting response headers
