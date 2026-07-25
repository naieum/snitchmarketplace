## CATEGORY 13: Stripe Security
> Type: posture · Groups: modern-stack · CWE: CWE-798

> **This category does not cover the payment page.** It covers the Stripe integration — keys,
> webhooks, API usage. The scripts loaded *around* the Elements iframe, their integrity, and
> tamper detection on that page are PCI DSS 6.4.3 and 11.6.1, and they live in **Category 22**.
> A Stripe repository scanned with Cat 13 and without Cat 22 has no coverage of the browser
> surface at all — which is where card skimming happens. Say so in the report if Cat 22 is not
> in the selected set.

### Detection
- `stripe` or `@stripe/stripe-js` imports
- `STRIPE_` environment variables

### What to Search For
- Secret keys in client code or public env vars
- Webhook endpoints without signature verification
- Test keys in production without env guards

### Actually Vulnerable

#### Critical
- `STRIPE_SECRET_KEY` or `sk_live_*` in client-side code
- `STRIPE_SECRET_KEY` in `NEXT_PUBLIC_*` variables
- Webhook endpoint missing `stripe.webhooks.constructEvent` verification

#### High
- Test keys (`sk_test_*`) in production code without environment guards
- Missing `STRIPE_WEBHOOK_SECRET` verification in webhook handlers
- Hardcoded price IDs that should be environment variables

#### Medium
- Publishable key (`pk_*`) hardcoded instead of environment variable
- Missing idempotency keys on payment intents

### NOT Vulnerable
- `STRIPE_SECRET_KEY` in server-only code (API routes, server actions)
- Publishable key (`pk_*`) in client code (expected)
- Test keys in test files or development configuration

### Context Check
1. Is this server-only code or client-accessible code?
2. Are webhook endpoints properly validating Stripe signatures?
3. Are test keys guarded by environment checks (NODE_ENV)?

### Evidence Chain
- Quote the key or config file:line (the `sk_live_*` / `STRIPE_SECRET_KEY` reference, the `NEXT_PUBLIC_*` assignment, or the webhook handler body)
- For client exposure: show why the file is client-accessible (client component, `NEXT_PUBLIC_` prefix, browser bundle path) — not a server-only API route
- For webhooks: quote the handler showing the event body is parsed and acted on without `stripe.webhooks.constructEvent` / `STRIPE_WEBHOOK_SECRET` verification
- For test keys in production: quote the key usage and the absence of a NODE_ENV/environment guard
- State the impact link: what the exposed key or unverified webhook allows (charges, refunds, forged payment events)

### Confidence Scoring
- **High**: `sk_live_*` or `STRIPE_SECRET_KEY` in demonstrably client-side code or a `NEXT_PUBLIC_*` variable; a webhook route that parses and acts on the event with no `constructEvent` call anywhere in the handler.
- **Medium**: Secret key referenced in a file whose client/server boundary is unclear (shared lib imported by both), or webhook verification may happen in middleware that wasn't confirmed; test keys present but deployment environment unknown.
- **Low**: Stripe usage detected but key sourcing and bundle boundaries can't be established from the code — tag `needs human verification`.

### Files to Check
- `**/stripe*.ts`, `**/checkout*.ts`, `**/webhook*.ts`
- `pages/api/webhook*`, `app/api/webhook*`
- `.env*`, `next.config.*`
