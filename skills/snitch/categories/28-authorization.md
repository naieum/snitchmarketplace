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
- ORM mass assignment: `prisma.*.update({ data: req.body })` or `Model.create(req.body)` without explicit field picking

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

### Files to Check
- `**/api/**/*.ts`, `**/routes/**/*.ts`
- `**/middleware/**/*.ts`
- `**/actions/**/*.ts`, `**/server/**/*.ts`
- `**/controllers/**/*.ts`
- `**/routes/admin*.tsx`, `**/routes/admin/**/*.tsx` — admin page layouts and route guards
- `**/routes/__root.tsx`, `**/routes/_layout.tsx` — shared root layouts that may expose admin navigation
- `**/layouts/**/*.tsx`, `**/components/**/nav*.tsx`, `**/components/**/sidebar*.tsx` — navigation components that may conditionally render admin links

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
