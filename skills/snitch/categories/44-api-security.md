## CATEGORY 44: API Security
> Type: sink-pattern · Groups: — · CWE: CWE-862

> **Owns:** the API surface as posture — endpoint auth coverage, response shape, pagination,
> inventory, versioning, and third-party response handling. **Does not own:** mass assignment
> (Category 28), GraphQL configuration (Category 57), CORS (Category 8), or rate limiting
> (Category 7). Note those detections here and report them under their owner.

**Data flow tracing required (SKILL.md Rule 7).** Trace every third-party API response that reaches a database write or a rendered surface: `const data = await partnerApi.get(); db.insert(data)` with no schema between them is a finding, and a Zod/Yup/class-validator schema that strips unknown keys on the response is a Pass — record the schema's file:line. A partner API is an external party's data, not yours, and a compromised or simply sloppy upstream is an attacker-adjacent source. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- OpenAPI/Swagger specification files (`openapi.yaml`, `swagger.json`)
- API route handlers (Express, Fastify, Next.js API routes, Flask, Django REST)
- GraphQL schemas and resolvers
- REST API middleware and controllers

### What to Search For
- OpenAPI/Swagger specs: endpoints without `security` schemes defined
- Missing authentication middleware on sensitive endpoints (CRUD operations)
- Excessive data exposure (returning full database objects instead of DTOs/projections)
- Mass assignment — owned by Category 28. If `req.body` reaches `.update()` / `.create()` without field-picking, note the detection and report it there
- Missing rate limiting on expensive operations (search, export, report generation)
- Broken function-level authorization (admin endpoints accessible without role check)
- GraphQL surfaces at all — a schema, resolvers, or a `/graphql` route. Note the detection and scan Category 57 (GraphQL Deep Security), which owns introspection, depth, complexity, and field-level auth. Do not re-derive those rules here
- Missing pagination on list endpoints (unbounded result sets)
- Inconsistent error responses (stack traces or internal details in some endpoints)
- Missing request validation schemas (no zod, joi, yup, or equivalent validation)
- API versioning issues (no version prefix, breaking changes without version bump)
- Missing CORS restrictions on API endpoints

### Actually Vulnerable
- API endpoint with no authentication middleware that performs database writes
- List endpoint returning all records with no `limit` or pagination
- Admin-only operation (delete user, change role) with no role/permission check
- Error handler returning full stack trace or database error messages to client
- OpenAPI spec with endpoints missing `security` field (no auth required)
- API that returns full user objects including `passwordHash`, `internalId`, or `stripeCustomerId`

### NOT Vulnerable
- Authentication middleware applied to all routes (or explicit public route allowlist)
- DTO/projection pattern — only selected fields returned from queries
- Request validation with schema library (zod, joi, yup, class-validator)
- Pagination enforced with maximum page size
- Role-based access control middleware on admin routes
- Error handler that returns generic messages with correlation IDs
- API versioning with `/api/v1/` prefix

### Context Check
1. Is authentication middleware applied globally or per-route? Are there intentionally public endpoints?
2. Are database objects transformed before being returned (DTO pattern)?
3. Are third-party API responses validated against a schema before being stored or rendered?
4. Are list endpoints paginated with a maximum page size?
5. Are admin operations protected by role/permission checks?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the unauthenticated endpoint performs state-changing operations (not just read-only or intentionally public)
2. [ ] Checked if authentication middleware is applied globally or per-route (and if there is an explicit public route allowlist)
3. [ ] Verified database objects are not transformed before being returned (no DTO/projection pattern)
4. [ ] Confirmed list endpoints lack a `limit` parameter or maximum page size
5. [ ] Checked if role/permission middleware protects admin-level operations
6. [ ] Verified error handlers do not return stack traces or internal details to clients

### Confidence Scoring
- **HIGH**: API endpoint performs database writes with no authentication middleware. Or a list endpoint returns all records with no pagination limit. Or a third-party response is traced into a database write with no schema on the path.
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
