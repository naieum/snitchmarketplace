## CATEGORY 14: Auth Provider Security (Clerk, Auth0, NextAuth)
> Type: posture · Groups: modern-stack · CWE: CWE-287

### Detection
- `@clerk/nextjs`, `@auth0/nextjs-auth0`, `next-auth` imports
- `CLERK_`, `AUTH0_`, `NEXTAUTH_` environment variables

### What to Search For
- Secret keys exposed to client
- Missing middleware on protected routes
- Weak or missing secrets

### Actually Vulnerable

#### Clerk Critical
- `CLERK_SECRET_KEY` in client-side code or `NEXT_PUBLIC_*`
- Missing `authMiddleware` or `clerkMiddleware` on protected routes

#### Auth0 Critical
- `AUTH0_SECRET` or `AUTH0_CLIENT_SECRET` in frontend code
- `AUTH0_ISSUER_BASE_URL` mismatch with allowed callback URLs

#### NextAuth Critical
- `NEXTAUTH_SECRET` exposed in client code
- `NEXTAUTH_SECRET` shorter than 32 characters
- `secret` option missing in NextAuth config
- Callbacks without proper validation

#### High (All Providers)
- JWT secrets in client bundles
- Missing CSRF protection on auth endpoints
- Redirect URL validation missing (open redirect vulnerability)
- Session tokens stored in localStorage (should be httpOnly cookies)

### NOT Vulnerable
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` in client (expected)
- Secret keys in server-only code
- Auth middleware properly applied at router level

### Context Check
1. Is auth middleware applied at the router/layout level covering all protected routes?
2. Are secrets in server-only files or potentially bundled into client code?
3. Is redirect URL validation handled by the auth provider or custom code?

### Evidence Chain
- Quote the secret exposure or missing-protection file:line (the `CLERK_SECRET_KEY` / `AUTH0_SECRET` / `NEXTAUTH_SECRET` reference, or the middleware/config gap)
- For client exposure: show why the file ships to the browser (`NEXT_PUBLIC_` prefix, client component, frontend bundle path)
- For missing middleware: quote `middleware.ts` (or note its absence) and name at least one protected route left uncovered by the matcher
- For weak/missing NextAuth secret: quote the config showing the `secret` option absent or the literal shorter than 32 characters
- State the impact link: session forgery, auth bypass on the uncovered route, or token theft via localStorage

### Confidence Scoring
- **High**: Provider secret in demonstrably client-shipped code or a `NEXT_PUBLIC_*` variable; protected routes confirmed uncovered by any auth middleware matcher; NextAuth config with no `secret` option and no `NEXTAUTH_SECRET` env reference.
- **Medium**: Secret referenced in a shared file whose bundle boundary is unclear; middleware exists but the matcher's coverage of specific routes couldn't be fully verified; redirect validation may be delegated to the provider.
- **Low**: Auth provider detected but route protection and secret sourcing can't be established from the audited files — tag `needs human verification`.

### Files to Check
- `middleware.ts`, `middleware.js`
- `**/auth/**`, `pages/api/auth/**`, `app/api/auth/**`
- `auth.config.*`, `auth.ts`, `.env*`
