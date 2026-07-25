## CATEGORY 4: Authentication Issues
> Type: posture · Groups: secrets-auth, quick-core · CWE: CWE-287

### Detection
- Auth libraries: `jsonwebtoken`, `passport`, `express-session`, `next-auth`, `@clerk/nextjs`, `better-auth`
- JWT usage: `jwt.sign`, `jwt.verify`, `jose` imports
- Session/cookie configuration patterns

### What to Search For
- Routes without auth middleware
- JWT signing with weak secrets
- JWT allowing none algorithm
- Insecure cookie settings
- Hardcoded session secrets
- Open redirects: `redirect()`, `res.redirect()` using `returnUrl`, `next`, `redirect_to` query params without allowlist validation
- WebSocket connections: `wss.on('connection', (ws) => { ... })` handlers that process messages before verifying authentication

### Actually Vulnerable
- Admin routes with no authentication middleware
- JWT secrets that are short or obvious
- Accepting none as a valid JWT algorithm
- Cookies without secure flag in production
- Session secrets hardcoded as simple strings
- `redirect(req.query.returnUrl)` without validating the URL is same-origin or on an allowlist
- `res.redirect(req.body.next)` after login with no URL validation
- WebSocket connection handler that processes data without checking session/JWT on the initial upgrade request

### NOT Vulnerable
- Routes with auth middleware applied
- Public routes that should be public
- JWT secrets loaded from environment
- Development-only insecure settings with env checks
- Redirect URLs validated against a same-origin check or explicit allowlist
- Auth provider handling redirects (Clerk, Auth0 handle this internally)
- WebSocket handlers that validate auth token from query params or headers on the `connection` event before any processing

### Context Check
1. Is middleware applied at router level?
2. Should this route be public?
3. Is insecure setting guarded by environment check?
4. **An omitted option is not a disabled option.** Before reporting a missing auth, session, password
   or cookie setting, confirm the library's default in the *installed* package — read
   `node_modules/<pkg>/` or the version's docs, not your recollection. Modern auth libraries ship
   safe defaults (password length floors, session expiry, `httpOnly` / `sameSite` cookies), so a
   config object that simply doesn't mention a setting is usually inheriting a sound value, not
   turning it off. The finding is an option **explicitly set** to a weak value, or a default you
   verified is genuinely unsafe — quote the default you found and where you found it. Reporting
   every unset option produces a wall of false positives on a correctly configured app.
5. Where is the session token stored? A token or role written to `localStorage` / `sessionStorage` is
   readable and writable by any script on the origin — client-writable authorization state is a
   privilege-escalation primitive regardless of how well the token itself was issued. (Cat 14 owns
   provider specifics; the storage location is in scope here.)

### Evidence Chain
- The route handler, JWT/session config, or redirect/WebSocket handler quoted at file:line
- For missing-auth findings: the absence demonstrated — the router/middleware registration checked (route level AND router/app level) and quoted or confirmed absent
- The reachability/impact link: what the unprotected route or weak config exposes (admin action, account takeover via open redirect, unauthenticated WebSocket data)
- For weak secrets/insecure settings: the config value quoted and any environment guard checked and found absent
- Why the route is judged non-public (path name, handler behavior, data accessed)

### Confidence Scoring
- **High** — sensitive route or config with the weakness unambiguous in code (e.g. admin route with middleware confirmed absent at both route and router level; `algorithms: ['none']`; literal short session secret)
- **Medium** — pattern present but protection could exist elsewhere not fully confirmed (e.g. possible platform-level middleware, framework defaults, or an env guard whose deployment value is unknown)
- **Low** — cannot determine whether the route is intentionally public or whether auth is applied via an untraceable mechanism (custom decorator, infra proxy) → tag `needs human verification`

### Files to Check
- `middleware.ts`, `**/auth/**`, `**/session/**`
- `pages/api/**`, `app/api/**`, `**/routes/**`
- JWT and session configuration files
