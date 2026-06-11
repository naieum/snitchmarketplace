## CUSTOM: Internal API Authentication

### Detection
- Files matching `src/api/**`, `routes/**`, `controllers/**`
- Imports of internal API client libraries
- Route handler definitions (Express, Fastify, Next.js API routes)

### What to Search For
- `app.get(`, `app.post(`, `router.get(`, `router.post(` without auth middleware
- `export default function handler` or `export async function GET/POST` without session checks
- API endpoints missing `requireAuth`, `authenticate`, or equivalent middleware

### Actually Vulnerable
- Public-facing API endpoint with no authentication check
- Internal endpoint accessible without role verification
- Admin endpoint without admin role guard

### NOT Vulnerable
- Health check endpoints (`/health`, `/ping`, `/status`)
- Public endpoints intentionally unauthenticated (login, register, password reset)
- Endpoints protected by API gateway or reverse proxy (verify in infrastructure config)
- Webhook endpoints with signature verification

### Context Check
- Is there auth middleware applied at the router level (not visible per-route)?
- Is there an API gateway handling auth before requests reach this service?
- Is this endpoint listed in a public API specification?

### Files to Check
- `src/api/**/*.ts`
- `src/routes/**/*.ts`
- `pages/api/**/*.ts`
- `app/api/**/route.ts`
