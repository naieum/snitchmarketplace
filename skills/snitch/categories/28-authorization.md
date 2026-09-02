## CATEGORY 28: Authorization & Access Control (IDOR)
> Type: posture · Groups: infra-supply-chain · CWE: CWE-639

### Detection
- API routes accepting resource IDs as parameters
- Database queries using user-supplied IDs
- Role/permission systems and middleware
- Admin routes and privileged operations
- Frontend route layouts/guards for privileged pages (admin panels, moderator views, internal tools)

### What to Search For

#### API-Level Authorization
- API routes that take resource IDs but don't verify ownership
- Missing role/permission checks on admin routes
- Sequential/predictable IDs used for resource access without auth checks
- `findUnique({ where: { id } })` without ownership filter (e.g., no `userId` in where clause)
- Missing authorization middleware (distinct from authentication)
- ORM mass assignment: `prisma.*.update({ data: req.body })` or `Model.create(req.body)` without explicit field picking. **This category owns mass assignment** — Category 44 detects the API surface and defers here

#### Frontend Route Authorization (Critical — Often Missed)
- Admin/privileged layout components that render without checking user role before mounting child routes
- Dashboard or internal pages accessible by navigating directly to the URL without session/role validation
- React/Vue/Angular/Svelte route guards that only check authentication (logged in) but not authorization (correct role)
- Layout components that render sidebar, navigation, or page structure for privileged areas before verifying the user has access — even if API calls later return 403, the UI skeleton itself leaks information about admin features, endpoints, and internal tooling
- Missing `useEffect`/`onMount`/`beforeRouteEnter` guards in privileged route layouts
- Admin links or navigation items visible to non-admin users in shared layouts (e.g., root navbar showing "Admin" link to all authenticated users)

### Actually Vulnerable

#### API-Level
- `GET /api/users/:id` returning any user's data without checking if requester owns that resource
- `DELETE /api/posts/:id` without verifying the post belongs to the authenticated user
- Admin route (`/api/admin/*`) with no role check middleware
- `prisma.order.findUnique({ where: { id: params.id } })` without `userId` filter
- Endpoints using sequential integer IDs with no authorization check
- `prisma.user.update({ where: { id }, data: req.body })` — attacker can set `isAdmin: true`, `role: "admin"`, etc.
- `User.create(req.body)` or `.update(req.body)` in any ORM without allow-listing specific fields

#### Frontend Route
- Admin layout component that renders sidebar with admin navigation links (Users, Logs, Stripe, System, etc.) to any authenticated user — exposes internal feature names and URL structure even though API calls return 403
- Privileged route (e.g., `/admin`, `/internal`, `/moderator`) with no client-side role check — component mounts and renders before any authorization occurs
- Route layout that checks `session` exists (authentication) but not `session.user.role === "admin"` (authorization)
- Shared root layout that conditionally renders admin links based on a client-side flag that can be tampered with (e.g., `localStorage.isAdmin`)

### NOT Vulnerable
- Routes with ownership verification (`where: { id, userId: session.userId }`)
- Admin routes protected by role-checking middleware
- Public resources intentionally accessible to all (e.g., published blog posts)
- Routes using proper ownership verification (e.g., `where: { id, userId: session.userId }`) — UUID vs integer ID does NOT matter; ownership check is what counts
- Resources scoped by tenant/organization with middleware enforcement
- Explicit field destructuring before ORM call: `const { name, email } = req.body` then using only those fields
- Using a Zod/Yup/Joi schema that strips unknown fields before the ORM call
- Admin layout that verifies role via server-side check (API call or server function) before rendering, and redirects unauthorized users
- Route guards that call a server endpoint to verify admin status and show a loading state until confirmed

**Server Actions and RPC-style handlers are public endpoints.** A Next.js `"use server"` function,
a tRPC procedure, or any exported handler a framework wires to a route is network-callable by anyone
who can reach the origin — its id is discoverable in the client bundle, and the UI that "only shows
it to admins" gates nothing. Treat an exported action with no session and no ownership check as
unauthenticated, whatever the surrounding component does. The shape to look for is a parameter that
identifies the target row (`userId`, `orgId`, `id`) used directly in the query, with no comparison
against the caller's own identity:

```
"use server";
export async function deleteAccount(userId: string) {   // finding: caller supplies the target
  return db.user.delete({ where: { id: userId } });
}
```

The fix is to derive the identity server-side (`const session = await getSession()`) and scope the
query to it, never to trust the argument.

### Context Check
1. Does the route verify the authenticated user owns or has access to the requested resource?
2. Is there authorization middleware applied at the router level?
3. Are these intentionally public endpoints?
4. Is there a tenant/org scoping mechanism in place?
5. Are IDs UUIDs? Note: UUID format alone does NOT prevent IDOR. Ownership verification is still required.
6. **Frontend routes:** Does the layout/page component for privileged areas verify the user's role BEFORE rendering any UI? A loading/redirect pattern is required — not just hoping the API returns 403.
7. **Shared layouts:** Does the root layout or navbar conditionally show admin links only to verified admin users, or are they visible to all authenticated users?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Route handles sensitive data or privileged operations (not intentionally public resources)
2. [ ] No ownership/tenant filter in the database query (check for userId, orgId, tenantId in where clause)
3. [ ] No authorization middleware at route, router, or framework level
4. [ ] For mass assignment: req.body is passed directly to ORM without field picking or schema validation
5. [ ] For frontend routes: no server-side role verification before rendering privileged UI (client-side checks alone are insufficient)

### Confidence Scoring
- **HIGH**: API route accepts resource ID parameter and queries database without ownership filter (no userId/orgId in where clause). Admin route with no role-checking middleware. ORM update/create with req.body directly (mass assignment). Admin layout renders without role verification.
- **MEDIUM**: Route uses resource IDs but ownership check may be at middleware or service layer. Admin route exists but role checking could be at router level. Frontend route may check role after initial render.
- **LOW**: Authorization pattern is unclear. Ownership check may exist in a shared utility or middleware not directly visible in the route handler.
- **SKIP**: Routes with ownership verification (where: { id, userId }). Admin routes with role-checking middleware. Explicit field destructuring before ORM calls. Zod/Yup schema stripping unknown fields. Admin layout verifying role server-side before rendering. Public resources intentionally accessible to all.

### Business Logic Abuse (OWASP API6:2023)

Unrestricted access to sensitive business flows allows automated abuse of critical operations.

#### What to Search For
- Business-critical operations without rate limiting: checkout, money transfer, account creation, invitation sends, coupon redemption
- Workflow bypass: endpoints that skip required steps (e.g., POST /order without prior POST /payment)
- State machine violations: state transitions without validation (e.g., reactivating a canceled subscription via direct API call)
- Bulk operations without quantity limits: mass delete, mass export, mass user creation
- Client-side price values trusted by server: `req.body.price` used in payment processing
- Coupon/discount codes validated only client-side or reusable without limit
- Re-submission of already-completed operations (idempotency not enforced)

#### Actually Vulnerable
- Checkout endpoint accepts `price` from request body instead of looking up from database
- `/api/invite` sends unlimited invitation emails with no rate limit
- Order can be created by calling `/api/orders` without going through `/api/cart` and `/api/payment` first
- Subscription status changed via `PATCH /subscription { status: "active" }` without payment verification

#### NOT Vulnerable
- Idempotency keys on payment operations (Stripe idempotency_key)
- Server-side price lookup from database, ignoring client-sent values
- State machine library enforcing valid transitions (xstate, robot)
- Rate limiting on all mutation endpoints, not just auth

#### Evidence Chain
- The business-flow handler quoted at file:line, and the specific guard checked and found absent
  (rate limit, idempotency key, server-side price lookup, prior-step assertion, state-transition check)
- The step or value the caller controls, and how it is supplied (request body field, direct route call
  that skips a prior route, repeated submission)
- The concrete gain: money moved at a price the caller chose, an email flood sent from your domain,
  a subscription reactivated without payment. "Could be abused" with no named gain is not a finding
- Where a rate limit is the missing control, whether one exists at the infrastructure layer (gateway,
  Cloudflare rule, ingress annotation) — say what you checked, since it usually is not in the repo

#### Confidence Scoring
- **HIGH**: the handler reads the trusted value from the caller (`req.body.price`, `req.body.status`)
  and writes it, or the flow's prerequisite step is provably not asserted anywhere on the path
- **MEDIUM**: the guard is absent from the handler but a middleware, gateway, or state-machine
  library could supply it at a layer not in scope — name which
- **LOW**: the flow's intended sequence cannot be established from the code (no state model, no
  documentation) — tag `needs human verification`

### Fail-Open Authorization (OWASP A10:2025 — Mishandling of Exceptional Conditions)

Category 28's normal finding is a **missing** ownership filter. This one is worse and reads as
correct: a filter that is present but degenerate, or an error path that grants instead of denying.
Nothing else in this skill covers it — CWE-636 (Not Failing Securely) and CWE-754 (Improper Check
for Unusual or Exceptional Conditions) live here.

#### What to Search For
- An ownership filter built from a value that can be `undefined` / `null` / empty, where the ORM then
  drops the condition rather than matching nothing: `where: { id, userId: session?.user?.id }` with no
  assertion that the session exists
- A permission helper whose `catch` block returns `true`, returns the resource, or falls through to
  the next middleware instead of denying
- `try { await authorize(req) } catch { /* ignore */ }` — the authorization is decorative
- A role comparison against a value that is absent on the failure path (`user.role !== 'admin'` where
  `user` may be `{}`), so the check passes by absence
- Feature-flag or config lookups that default to permissive when the flag store is unreachable
- A verification call whose result is never inspected (`verifyToken(t)` invoked, return value dropped)

#### Actually Vulnerable
- `prisma.doc.findFirst({ where: { id, ownerId: userId } })` where `userId` is `undefined` for an
  unauthenticated caller — the clause is dropped and the query returns any document by id
- `catch (e) { return next() }` around a permission middleware, so any error in the permission
  lookup admits the request
- `const allowed = await checkAcl(...).catch(() => true)`

#### NOT Vulnerable
- The identifier is asserted before use (`if (!userId) return 401`) and the filter cannot degenerate
- The `catch` denies: returns 403/500, or rethrows to an error handler that denies
- The ORM is configured to reject undefined in filters, and you quoted that configuration

#### Evidence Chain
- The filter or check quoted at file:line, plus the line proving the value can be absent on some path
  (the optional chain, the nullable type, the branch that skips the assignment)
- The failure behavior quoted: what the `catch` / default / absent-value case actually returns
- The resulting access: which records or actions the degenerate path reaches
- The assertion you looked for and did not find (`if (!userId)`, a schema requiring the field, a
  framework guard that rejects undefined filters)

#### Confidence Scoring
- **HIGH**: the absent-value path and the permissive failure behavior are both quoted, on a route
  reachable without the credential the filter was supposed to enforce
- **MEDIUM**: the value is nullable by type but every traced caller supplies it, or the permissive
  `catch` sits on a path whose reachability could not be confirmed
- **LOW**: the ORM's behavior on an undefined filter value could not be determined for the installed
  version — tag `needs human verification` and say which version you looked for

### Files to Check
- `**/api/**/*.ts`, `**/routes/**/*.ts`
- `**/middleware/**/*.ts`
- `**/actions/**/*.ts`, `**/server/**/*.ts`
- `**/controllers/**/*.ts`
- `**/routes/admin*.tsx`, `**/routes/admin/**/*.tsx` — admin page layouts and route guards
- `**/routes/__root.tsx`, `**/routes/_layout.tsx` — shared root layouts that may expose admin navigation
- `**/layouts/**/*.tsx`, `**/components/**/nav*.tsx`, `**/components/**/sidebar*.tsx` — navigation components that may conditionally render admin links
