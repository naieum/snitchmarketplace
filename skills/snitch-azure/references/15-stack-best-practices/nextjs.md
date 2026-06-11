# Next.js on Azure

Verdict + caveats: `fit-matrix nextjs`. Docs: `stack-docs nextjs`.

## Landing options

| Target | Use |
|---|---|
| Static Web Apps (Hybrid) | Preview. App Router + RSC + subset of API routes via integrated Functions. Free tier covers most dev/test. |
| App Service Linux Node 20 | Full SSR + ISR + Server Actions. Production-grade. Slot blue/green. |
| Container Apps | Same as App Service + scale-to-zero + Dapr. |
| Functions | API-only Next.js (no UI), via custom handler. |

## Must-do

- `httpsOnly: true`.
- `siteConfig.minTlsVersion: "1.2"` (or 1.3).
- `siteConfig.ftpsState: "Disabled"`.
- SCM basic auth disabled (`apply_appservice.sh`).
- System-assigned MI granted `Key Vault Secrets User`; secrets via `@Microsoft.KeyVault(SecretUri=...)`.
- AAD via App Service Easy Auth (Authentication V2) for B2B/B2E.
- Front Door / App Gateway WAF: rate-limit `/api/auth/*` and Server Action POSTs.

## Secrets

- NEVER put secrets in `NEXT_PUBLIC_*` (ships to client). FAIL.
- App Settings → Key Vault references for runtime config.
- Pre-build env vars use OIDC federation (no `AZURE_CLIENT_SECRET`).

## CSP

Production CSP via `middleware.ts` (nonce-based). Verify nonce flow doesn't leak through edge cache.

## ISR / on-demand revalidation

- Static Web Apps: limited (preview).
- App Service / Container Apps: full; verify `revalidate` paths return correct cache-control.

## Skill targets

| Finding | Severity |
|---|---|
| HTTPS-only off | FAIL (`fix appservice`) |
| min TLS < 1.2 | FAIL |
| SCM basic auth allowed | FAIL |
| `NEXT_PUBLIC_*` secret-shaped values | FAIL (`detect` flags) |
| No managed identity | WARN |
| WAF in Detection mode on prod | WARN |
