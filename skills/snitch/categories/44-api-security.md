## CATEGORY 44: API Security
> Type: sink-pattern · Groups: — · CWE: CWE-862

**Data flow tracing required (SKILL.md Rule 7).** For mass-assignment findings, trace the request body to the database operation: `req.body` (or `...req.body`) passed to `.update()` / `.create()` without a DTO, explicit field-picking, or schema validation is a finding; explicit field selection or a schema that strips unknown keys is a Pass. Apply the same trace to third-party API responses written to the database without validation. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- OpenAPI/Swagger specification files (`openapi.yaml`, `swagger.json`)
- API route handlers (Express, Fastify, Next.js API routes, Flask, Django REST)
- GraphQL schemas and resolvers
- REST API middleware and controllers

### What to Search For
- OpenAPI/Swagger specs: endpoints without `security` schemes defined
- Missing authentication middleware on sensitive endpoints (CRUD operations)
- Excessive data exposure (returning full database objects instead of DTOs/projections)
- Mass assignment (accepting arbitrary fields from request body directly into database updates)
- Missing rate limiting on expensive operations (search, export, report generation)
- Broken function-level authorization (admin endpoints accessible without role check)
- GraphQL: introspection enabled in production, no query depth or complexity limits
- Missing pagination on list endpoints (unbounded result sets)
- Inconsistent error responses (stack traces or internal details in some endpoints)
- Missing request validation schemas (no zod, joi, yup, or equivalent validation)
- API versioning issues (no version prefix, breaking changes without version bump)
- Missing CORS restrictions on API endpoints

### Actually Vulnerable
- API endpoint with no authentication middleware that performs database writes
- Route handler that spreads request body directly into a database update (`...req.body`)
- List endpoint returning all records with no `limit` or pagination
- Admin-only operation (delete user, change role) with no role/permission check
- GraphQL server with introspection enabled and no query depth limit in production
- Error handler returning full stack trace or database error messages to client
- OpenAPI spec with endpoints missing `security` field (no auth required)
- API that returns full user objects including `passwordHash`, `internalId`, or `stripeCustomerId`

### NOT Vulnerable
- Authentication middleware applied to all routes (or explicit public route allowlist)
- DTO/projection pattern — only selected fields returned from queries
- Request validation with schema library (zod, joi, yup, class-validator)
- Pagination enforced with maximum page size
- Role-based access control middleware on admin routes
- GraphQL depth and complexity limits configured
- Error handler that returns generic messages with correlation IDs
- API versioning with `/api/v1/` prefix

### Context Check
1. Is authentication middleware applied globally or per-route? Are there intentionally public endpoints?
2. Are database objects transformed before being returned (DTO pattern)?
3. Is request body validated before being used in database operations?
4. Are list endpoints paginated with a maximum page size?
5. Are admin operations protected by role/permission checks?
6. Is GraphQL introspection disabled in production?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the unauthenticated endpoint performs state-changing operations (not just read-only or intentionally public)
2. [ ] Checked if authentication middleware is applied globally or per-route (and if there is an explicit public route allowlist)
3. [ ] Verified database objects are not transformed before being returned (no DTO/projection pattern)
4. [ ] Confirmed list endpoints lack a `limit` parameter or maximum page size
5. [ ] Checked if role/permission middleware protects admin-level operations
6. [ ] Verified error handlers do not return stack traces or internal details to clients

### Confidence Scoring
- **HIGH**: API endpoint performs database writes with no authentication middleware, or route handler spreads `req.body` directly into database update. Or list endpoint returns all records with no pagination limit.
- **MEDIUM**: Authentication middleware exists globally but some endpoints may be intentionally public. Or request validation is partial (some fields validated, others not).
- **LOW**: Missing authentication might be intentional (public API endpoint). Or OpenAPI spec missing `security` field but auth is enforced at gateway level.
- **SKIP**: All routes have authentication middleware, request validation, pagination, and role-based access control. Or the API is internal-only behind a service mesh with mTLS.

### Files to Check
- `openapi.yaml`, `openapi.json`, `swagger.yaml`, `swagger.json`
- `**/routes/**`, `**/api/**`, `**/controllers/**`, `**/handlers/**`
- `**/middleware/**` (auth, validation, rate limiting)
- `**/graphql/**`, `**/schema/**`, `**/resolvers/**`
- `**/dto/**`, `**/serializers/**`

### Shadow APIs / Improper Inventory (OWASP API9:2023)

Undocumented or forgotten API endpoints create attack surface that bypasses security controls.

#### What to Search For
- Route definitions in code not present in OpenAPI/Swagger spec
- Deprecated API versions still active (v1 routes when v2 is current, old controllers not removed)
- Internal-only endpoints accessible without network restriction: `/internal/`, `/admin/api/`, `/rpc/`
- Test/development endpoints in production: `/test/`, `/dev/`, `/debug/`, `/sandbox/`
- Catch-all route handlers: `app.all('*', ...)` or `router.use('/', ...)` that silently serve unintended paths
- API versioning without deprecation sunset dates or migration guides

#### Actually Vulnerable
- Express route `app.get('/api/v1/users', ...)` still active when v2 is the documented current version
- Internal admin API at `/internal/users/delete` with no auth middleware (assumed network-level restriction but publicly accessible)
- Undocumented `POST /api/debug/eval` endpoint left from development

#### NOT Vulnerable
- Deprecated endpoints returning 410 Gone with migration instructions
- Internal endpoints behind API gateway with IP allowlist
- OpenAPI spec generated from route decorators (auto-documented)

### Unsafe Third-Party API Consumption (OWASP API10:2023)

Trusting third-party API responses without validation creates injection and availability risks.

#### What to Search For
- Third-party API responses used directly without validation: `const data = await thirdPartyApi.get(); db.insert(data)` — no schema validation
- No timeout on external API calls: `fetch(externalUrl)` without `signal: AbortSignal.timeout(5000)`
- No fallback/circuit breaker when external service is down — entire application fails
- Third-party API credentials hardcoded or never rotated (check Cat 3 and Cat 52)
- No retry with exponential backoff on transient failures (immediate retry floods the external service)
- Logging full third-party API responses that may contain PII or secrets

#### Actually Vulnerable
- `const userData = await partner.getUser(id); await db.users.create(userData)` — no validation of partner response
- `await fetch('https://external-api.com/data')` with no timeout — can hang forever
- Application crashes entirely when payment gateway is unreachable (no fallback/graceful degradation)

#### NOT Vulnerable
- Zod/Yup schema validation on all third-party responses before use
- Circuit breaker pattern (opossum, cockatiel) with fallback behavior
- Timeout + retry with backoff configured on all external HTTP clients
- Third-party credentials managed via secrets manager with rotation
