## CATEGORY 14: Auth Provider Security (Clerk, Auth0, Auth.js / NextAuth)
> Type: posture · Groups: modern-stack · CWE: CWE-287

> **Owns:** what is specific to a hosted auth provider — its secrets, its middleware registration,
> its callback and issuer configuration. Everything a provider shares with hand-rolled auth belongs
> elsewhere: route-level auth coverage, cookie/session config, open redirect and token storage are
> Category 4; the JWT algorithm class is Category 63; CSRF is Category 47.

### Detection
- `@clerk/nextjs`, `@auth0/nextjs-auth0`, `next-auth`, `@auth/core`, `@auth/*` adapter imports
- `CLERK_`, `AUTH0_` environment variables
- Auth.js secrets under **both** naming schemes: `AUTH_SECRET` (v5, the current name) and
  `NEXTAUTH_SECRET` (v4). A v5 app sets `AUTH_SECRET` and never mentions `NEXTAUTH_`, so a scan that
  greps only for `NEXTAUTH_` reports "auth provider not detected" on a correctly configured app and
  misses the secret rules below entirely. Match either; also match `AUTH_URL` / `NEXTAUTH_URL`

### What to Search For
- Provider secret keys exposed to client
- Provider middleware absent where the provider is the only auth mechanism
- Weak or missing provider secrets

### Actually Vulnerable

#### Clerk Critical
- `CLERK_SECRET_KEY` in client-side code or `NEXT_PUBLIC_*`
- Missing `authMiddleware` or `clerkMiddleware` on protected routes

#### Auth0 Critical
- `AUTH0_SECRET` or `AUTH0_CLIENT_SECRET` in frontend code
- `AUTH0_ISSUER_BASE_URL` mismatch with allowed callback URLs

#### Auth.js / NextAuth Critical
- The Auth.js secret (`AUTH_SECRET` on v5, `NEXTAUTH_SECRET` on v4) exposed in client code
- That secret's literal value shorter than 32 characters — check whichever name the project uses
- `secret` option missing from the Auth.js config **and** neither env name set
- `callbacks.redirect` / `callbacks.signIn` returning a caller-supplied value with no validation

#### High (All Providers)
- Provider secret reachable from a client bundle
- Callback / redirect URI allowlist configured to a wildcard, or the configured issuer base URL not
  matching the allowed callback URLs

### NOT Vulnerable
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` in client (expected)
- Secret keys in server-only code
- Auth middleware properly applied at router level
- An Auth.js v5 app that sets `AUTH_SECRET` and never mentions `NEXTAUTH_SECRET` — the v4 name is
  simply gone, not missing

### Context Check
1. Is auth middleware applied at the router/layout level covering all protected routes?
2. Are secrets in server-only files or potentially bundled into client code?
3. Is redirect URL validation handled by the auth provider or custom code?

### Evidence Chain
- Quote the secret exposure or missing-protection file:line (the `CLERK_SECRET_KEY` / `AUTH0_SECRET` / `AUTH_SECRET` reference, or the middleware/config gap)
- For client exposure: show why the file ships to the browser (`NEXT_PUBLIC_` prefix, client component, frontend bundle path)
- For missing middleware: quote `middleware.ts` (or note its absence) and name at least one protected route left uncovered by the matcher
- For a weak/missing Auth.js secret: name which env variable the project uses (`AUTH_SECRET` or `NEXTAUTH_SECRET`), and quote the config showing the `secret` option absent or the literal shorter than 32 characters
- State the impact link: session forgery from a guessable secret, or auth bypass on a route the provider's middleware matcher does not cover

### Confidence Scoring
- **High**: Provider secret in demonstrably client-shipped code or a `NEXT_PUBLIC_*` variable; protected routes confirmed uncovered by any auth middleware matcher; an Auth.js config with no `secret` option and neither `AUTH_SECRET` nor `NEXTAUTH_SECRET` set anywhere.
- **Medium**: Secret referenced in a shared file whose bundle boundary is unclear; middleware exists but the matcher's coverage of specific routes couldn't be fully verified; callback validation may be delegated to the provider's dashboard, which source cannot show.
- **Low**: Auth provider detected but route protection and secret sourcing can't be established from the audited files — tag `needs human verification`.

### Files to Check
- `middleware.ts`, `middleware.js`
- `**/auth/**`, `pages/api/auth/**`, `app/api/auth/**`
- `auth.config.*`, `auth.ts`, `.env*`
