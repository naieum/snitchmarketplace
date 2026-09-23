## CATEGORY 4: Authentication Issues
> Type: posture · Groups: secrets-auth, quick-core · CWE: CWE-287

> **Owns:** route-level auth coverage, session and cookie configuration, open redirect, where the
> session token is stored, and the integrity of the authentication *flows* — password reset, session
> establishment, the second-factor step, and the signals the login surface leaks about which accounts
> exist. **Does not own:** the JWT algorithm and key-confusion class (Category 63), WebSocket
> connection auth (Category 56), provider-specific misconfiguration (Category 14), mass assignment
> (Category 28), rate limiting on any of these endpoints (Category 7), constant-time comparison of a
> token (Category 50), the configured lifetime value of a token or session (Category 39), or whether
> the organization *requires* MFA as a control (Categories 21 and 35 — this category owns whether the
> code can be made to skip the factor it does implement). Report a finding under its owner; a
> duplicate across two categories reads to the user as two problems.

### Detection
- Auth libraries: `jsonwebtoken`, `passport`, `express-session`, `next-auth`, `@clerk/nextjs`, `better-auth`
- JWT usage: `jwt.sign`, `jwt.verify`, `jose` imports
- Session/cookie configuration patterns
- Flow surfaces: a `passwordReset` / `verificationToken` / `recoveryCode` table or model, `otplib`,
  `speakeasy`, `@otplib/*`, `@simplewebauthn/*`, `qrcode` next to an auth module, or any route named
  for reset, forgot, verify, confirm, challenge, enroll, or impersonate

### What to Search For
- Routes without auth middleware
- JWT signing with weak or hardcoded secrets (the algorithm itself — `none`, `alg` confusion, key mix-ups — is Category 63)
- Insecure cookie settings
- Hardcoded session secrets
- Open redirects: `redirect()`, `res.redirect()` using `returnUrl`, `next`, `redirect_to` query params without allowlist validation

### Actually Vulnerable
- Admin routes with no authentication middleware
- JWT secrets that are short or obvious
- Cookies without secure flag in production
- Session secrets hardcoded as simple strings
- `redirect(req.query.returnUrl)` without validating the URL is same-origin or on an allowlist
- `res.redirect(req.body.next)` after login with no URL validation

### NOT Vulnerable
- Routes with auth middleware applied
- Public routes that should be public
- JWT secrets loaded from environment
- Development-only insecure settings with env checks
- Redirect URLs validated against a same-origin check or explicit allowlist
- Auth provider handling redirects (Clerk, Auth0 handle this internally)

### Authentication Flow Integrity

Route-level auth coverage answers "is this door locked". These checks answer the other half: whether
the *procedures* that mint, upgrade, and recover a session can be walked around. They are the
highest-value checks in this category on generated code, because a model reproduces the happy path of
a reset or a 2FA flow far more reliably than its invariants — the token that must be single-use, the
session id that must change, the second step that must not be skippable.

#### What to Search For

**Password reset and other out-of-band tokens:**
- Token generation using a non-cryptographic source: `Math.random()`, `Date.now()`, a counter, a UUIDv1, `crypto.randomUUID()` used where an unguessable secret is needed is fine, but `uuid` v1/v3/v5 are not random.
- A reset record with no expiry column, or a verification path that reads the token row and never compares an `expiresAt` / `createdAt` against now.
- A token that survives use: no `usedAt` write, no delete, no `where: { usedAt: null }` in the consuming query.
- A reset that does not invalidate existing sessions, or that returns a logged-in session directly from the reset link.
- The token echoed somewhere it leaks: in a redirect `Location`, in a page the browser will send as a `Referer`, in a URL that gets logged, or in the response body of the request-reset endpoint (the "return the token for testing" shape that survives into production).
- A reset confirmed against an email address taken from the request rather than from the token record (`where: { email: req.body.email }` next to the token lookup).

**Session establishment and fixation:**
- Login handlers that write user identity onto an existing session without regenerating the identifier: `req.session.userId = user.id` with no `req.session.regenerate(...)` / `session.regenerate()` / `reset_session` / `cycle_csrf_token` nearby.
- Privilege changes (role upgrade, impersonation start/stop, "switch organization") that keep the same session id.
- A session identifier accepted from a query parameter, a request body, or a custom header rather than from the cookie the server set.
- Logout that clears client state without destroying the server-side session record.

**Second-factor enforcement:**
- A login flow that issues the full session cookie *before* the second factor, then relies on a client-side redirect to the challenge page.
- A verify-code endpoint that returns a session on success but where the post-MFA endpoint (or the app's other routes) can be called directly with the pre-MFA cookie — search for a session flag like `mfaPending` / `awaitingTotp` that is written but never read by the authorization middleware.
- An enrollment or "remember this device" path that sets a trust cookie the user controls, or that accepts a device token without binding it to the account.
- Recovery/backup codes that are not single-use, or stored unhashed.
- A factor that can be dropped by omitting the field: `if (req.body.totp) { verify(...) }` — absent field, no verification.

**Account enumeration on the auth surface:**
- Distinct responses for "no such user" and "wrong password" on login: different status codes, different messages, different response shapes.
- A registration or request-reset endpoint that says "this email is already registered" or returns 409 vs 200 depending on existence.
- An email-availability or username-check endpoint with no auth and no rate limit that answers existence directly.

**Account takeover via the change-of-address path:**
- An email or phone change that takes effect without verifying the new address, or without re-authenticating the current user.
- A change-email handler that updates the record and leaves existing reset tokens valid for the new address.

#### Actually Vulnerable
- `resetToken = Math.random().toString(36).slice(2)` — the token is guessable, and the reset flow is a direct account-takeover path.
- A `passwordReset` row is looked up by token and the new password is written, with no `expiresAt` comparison and no `usedAt` write: the link in an old email works forever and works twice.
- `req.session.userId = user.id` in the login handler with no `regenerate` call anywhere on the path — an attacker who can set a victim's session cookie before login (a subdomain XSS, a fixation link) holds an authenticated session afterward.
- The login handler sets the full session cookie and returns `{ mfaRequired: true }` for the client to act on; `/api/orders` accepts that cookie without checking the pending flag. The second factor is advisory.
- `POST /login` returns 404 "No account with that email" and 401 "Incorrect password" — any list of emails can be sorted into customers and non-customers.
- `PATCH /me { email }` writes the new address directly and sends no confirmation to either address.

#### NOT Vulnerable
- Tokens from `crypto.randomBytes(32)`, `crypto.getRandomValues`, `secrets.token_urlsafe`, or `SecureRandom.urlsafe_base64`, stored hashed, compared with an expiry condition in the query.
- Flows delegated to an auth provider that owns the invariant: Clerk, Auth0, Supabase Auth, Better Auth, Django's `PasswordResetTokenGenerator`, Rails' `generates_token_for` and `reset_session`, Laravel's broker. Name the provider and the specific call in the Pass — the invariant is theirs, not missing.
- Framework session middleware that regenerates by default on login when the framework's own login helper is used (`request.session.cycle_key()` inside Django's `login()`, Devise's `bypass_sign_in`/`sign_in`, `passport`'s `req.logIn` with `keepSessionInfo` left at its default false). Quote the helper call; this is the common false positive.
- Uniform login responses (same status, same message, same shape) — these are the control, not a finding.
- A registration endpoint that reveals existence *by design* on a product where accounts are public (a social handle check), where the code or config says so.
- Test fixtures, seed scripts, and local dev helpers.

#### Evidence Chain
- The flow's entry point and its consuming step, both quoted at file:line — for a reset, the generate call and the verify/consume query; for fixation, the login handler and the session write; for MFA, the place the session is issued and the place the pending flag is (or is not) read.
- The specific invariant checked and found absent, named: unguessable source, expiry comparison, single-use write, session regeneration, pending-factor check, uniform response. "Weak reset flow" without naming which invariant is missing is not a finding.
- For provider-delegated flows, the provider call that owns the invariant, quoted — this is what turns the surface into a Pass rather than a gap.
- The concrete takeover path in one sentence: what the attacker holds at the start, what they hold at the end.

#### Confidence Scoring
- **High**: the invariant's absence is provable in the quoted code — a non-crypto token source, a consume query with no expiry or single-use condition, a login handler whose whole path contains no regeneration, a pending-MFA flag written and never read anywhere in the repo.
- **Medium**: the invariant is absent from the handler but could live in a framework helper, an ORM hook, or middleware not resolved in scope — name which layer was not reachable.
- **Low**: the flow crosses into a provider or service whose behavior is not in the repository, or the enumeration difference could not be confirmed to be caller-visible — tag `needs human verification`.

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
6. For any flow finding, has the invariant been delegated rather than dropped? Auth providers and
   mature framework helpers own reset-token generation, session regeneration, and factor sequencing.
   Search for the provider call on the path before concluding the check is missing — a delegated
   invariant is a Pass with the call named, and reporting it is the most expensive false positive in
   this category because it tells a team their correct integration is broken.
7. Is the difference actually observable to the caller? An enumeration finding needs the two
   responses to differ in something the client receives — status, body, shape, or a redirect target.
   A difference in server-side logging or in an internal branch that converges on the same response
   is not a leak. Quote both response paths.

### Evidence Chain
- The route handler, session/cookie config, or redirect handler quoted at file:line
- For missing-auth findings: the absence demonstrated — the router/middleware registration checked (route level AND router/app level) and quoted or confirmed absent
- The reachability/impact link: what the unprotected route or weak config exposes (admin action, account takeover via open redirect, session forgery)
- For weak secrets/insecure settings: the config value quoted and any environment guard checked and found absent
- Why the route is judged non-public (path name, handler behavior, data accessed)

### Confidence Scoring
- **High** — sensitive route or config with the weakness unambiguous in code (e.g. admin route with middleware confirmed absent at both route and router level; a literal short session secret; `res.redirect(req.query.next)` with no allowlist)
- **Medium** — pattern present but protection could exist elsewhere not fully confirmed (e.g. possible platform-level middleware, framework defaults, or an env guard whose deployment value is unknown)
- **Low** — cannot determine whether the route is intentionally public or whether auth is applied via an untraceable mechanism (custom decorator, infra proxy) → tag `needs human verification`

### Files to Check
- `middleware.ts`, `**/auth/**`, `**/session/**`
- `pages/api/**`, `app/api/**`, `**/routes/**`
- JWT and session configuration files
- Reset and recovery flows: `**/reset*`, `**/forgot*`, `**/recover*`, `**/verify*`, `**/confirm*`
- Second-factor flows: `**/mfa/**`, `**/2fa/**`, `**/totp*`, `**/otp*`, `**/challenge*`, `**/enroll*`
- Login, logout, registration and impersonation handlers, plus any "switch account / switch org" route
- The schema or migrations defining the token tables (`passwordReset`, `verificationToken`,
  `recoveryCode`) — the missing `expiresAt` or `usedAt` column is visible there first
