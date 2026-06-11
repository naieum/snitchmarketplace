# Domains and TLS

Every service gets a Railway-issued subdomain (`<id>.up.railway.app`). Custom domains attach via CNAME/AAAA.

## TLS

Auto-managed via Let's Encrypt for both Railway subdomains and custom domains. Cert renewal is automatic. HTTP→HTTPS is enforced by default — no off switch.

## Custom domain status

| Status | Meaning |
|---|---|
| `active` | TLS issued, traffic flowing |
| `pending` | DNS not propagated; cert not issued |
| `verifying` | DNS verified, cert provisioning |
| `error` | typically misconfigured CNAME |

`state domains` digest surfaces non-active domains as `FAIL`.

## DNSSEC

Railway does not manage your DNS — bring your own registrar. DNSSEC is the registrar's concern. Surface as `WARN` if domain is not DNSSEC-signed.

## HSTS and security headers

Railway does **not** set HSTS or security headers at the edge. Your application sets:

- `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` or `Content-Security-Policy: frame-ancestors 'none'`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: geolocation=(), microphone=(), camera=()`

Set in middleware (Express `helmet`, NestJS `helmet()`, Rails `config.force_ssl + config.ssl_options[:hsts]`, Django `SECURE_HSTS_SECONDS`).

## HSTS preload

After confirming HSTS is set with `preload`, submit at https://hstspreload.org. Once preloaded, browsers force HTTPS even on first visit.

## Recommendations

- Always attach a custom domain for production. `*.up.railway.app` cannot be HSTS-preloaded.
- Enable DNSSEC at registrar if supported.
- Validate end-to-end TLS: `bash snitch-railway.sh score yourdomain.com`.

## Docs

- https://docs.railway.com/guides/public-networking
- https://hstspreload.org
