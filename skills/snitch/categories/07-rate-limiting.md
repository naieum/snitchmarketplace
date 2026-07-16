## CATEGORY 7: Rate Limiting
> Type: posture · Groups: secrets-auth · CWE: CWE-770

### Detection
- Auth endpoints: login, signup, password reset, OTP verification routes
- Rate limiter libraries: `express-rate-limit`, `@upstash/ratelimit`, `rate-limiter-flexible`
- API routes handling sensitive operations

### What to Search For
- Auth endpoints: login, signup, password reset
- Rate limiter imports and usage
- In-memory vs persistent rate limiting

### Actually Vulnerable
- Login endpoint with no visible rate limiting
- Password reset without rate limiting
- In-memory limiter in production

### NOT Vulnerable
- Endpoints with rate limit middleware
- Infrastructure-level limiting (Cloudflare, WAF)
- Redis-backed rate limiting
- Non-sensitive endpoints

### Context Check
1. Is rate limiting handled at infrastructure level (Cloudflare, AWS WAF, API Gateway)?
2. Is this a public endpoint or a sensitive auth endpoint?
3. Is there a reverse proxy or load balancer applying rate limits upstream?

### Evidence Chain
- The sensitive endpoint (login, signup, password reset, OTP) quoted at file:line
- The absence demonstrated: rate limiter middleware checked at the route, router, and app level and confirmed absent (name the limiter libraries searched for)
- Infrastructure-level limiting checked for and not found in the repo (Cloudflare/WAF/API Gateway config), or noted as unverifiable
- The reachability/impact link: what unlimited requests enable here (credential stuffing, OTP brute force, reset-email flooding)
- For in-memory-limiter findings: the limiter config quoted at file:line and why it fails in production (multi-instance, restart resets counters)

### Confidence Scoring
- **High** — sensitive auth endpoint with no limiter at any code level and no infrastructure-limit config in the repo, or an in-memory limiter explicitly configured for a production deployment
- **Medium** — no code-level limiter found, but infrastructure-level limiting is plausible and unverifiable from the repo (deployment behind Cloudflare/API Gateway suspected but not confirmed)
- **Low** — endpoint sensitivity is unclear, or limiting may be applied by an upstream proxy/platform outside the repo → tag `needs human verification`

### Files to Check
- `**/login*.ts`, `**/signup*.ts`, `**/password*.ts`
- `**/auth/**`, `pages/api/auth/**`, `app/api/auth/**`
- Rate limiter configuration and middleware files
