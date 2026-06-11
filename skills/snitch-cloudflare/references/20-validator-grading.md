# 20 — Validator Grading

`snitch-cloudflare.sh score` runs these.

## SSL Labs

A+ to F. A+ requires: TLS 1.2+, ECDHE preferred, modern ciphers (AES-GCM, ChaCha20), HSTS, forward secrecy, OCSP stapling, no known-attack vulnerabilities.

CF defaults achieve A+ when SSL = strict, min TLS 1.2+, HSTS `max-age >= 31536000` + `includeSubDomains` + `preload`.

API: async (60–120s). `GET https://api.ssllabs.com/api/v3/analyze?host=example.com&publish=off&all=on` — poll for `status: READY`.

Source: https://github.com/ssllabs/ssllabs-scan/blob/master/ssllabs-api-docs-v3.md

## MDN HTTP Observatory (formerly Mozilla Observatory)

Headers + cookies + redirects, A+ to F (numeric score, can exceed 100).

| Item | Points |
|---|---|
| HSTS present + `max-age >= 6 months` + `includeSubDomains` + `preload` | +25 |
| CSP without `'unsafe-inline'`/`'unsafe-eval'` | +25 |
| `X-Frame-Options` or `frame-ancestors` | +5 |
| `X-Content-Type-Options: nosniff` | +5 |
| `Referrer-Policy` | +5 |
| COOP/COEP/CORP | +5 |
| Cookies with secure flags | +5 |
| HTTPS redirect (same-origin first) | +5 |
| SRI (when applicable) | +5 |

Mozilla retired `http-observatory.security.mozilla.org` — the old v1 analyze API now returns a 502 HTML page. The HTTP Observatory now lives at MDN and its **v2 API scans synchronously** (one request, no polling):

API: `POST https://observatory-api.mdn.mozilla.net/api/v2/scan?host=example.com`
Returns `{ grade, score, tests_passed, tests_failed, tests_quantity, details_url, scanned_at }`, or `{ error, message }` on a bad host. Skill caches 1h and only promotes a parseable body (grade or structured error) so a transient 502 can't poison a good cached result.

Source: https://developer.mozilla.org/en-US/observatory

## Security headers (local grade)

securityheaders.com now sits behind a Cloudflare anti-bot challenge — a scrape only ever returns the "Just a moment..." interstitial, never a grade. There is no public API. Rather than fake a grade, the skill computes a **transparent local grade** from the site's own response headers (`curl -I`), checking the same six headers the public tool weighs:

`Strict-Transport-Security`, `Content-Security-Policy`, `X-Frame-Options` (or CSP `frame-ancestors`), `X-Content-Type-Options: nosniff`, `Referrer-Policy`, `Permissions-Policy`.

Grade = letter by count present: 6→A, 5→B, 4→C, 3→D, 2→E, ≤1→F. Always labeled "(local)" in output so it's never mistaken for securityheaders.com's own score. This is a presence check, not a CSP-strictness check — a strict-CSP nuance still belongs to the Observatory grade above.

## HSTS Preload

Eligibility: HSTS on apex with `max-age >= 31536000` + `includeSubDomains` + `preload` + HTTPS for all subdomains + HTTP→HTTPS redirect.

API: `GET https://hstspreload.org/api/v2/status?domain=example.com` returns `{status: pending|preloaded|unknown|...}`.

A bare `status: unknown` is **not** "all clear" — it only means the domain isn't on the submission-based list (a few domains like google.com/apple.com are hard-coded in Chrome outside the list and also read `unknown`). The skill cross-references the live `Strict-Transport-Security` header to make the finding actionable:

- `preloaded` → OK.
- not preloaded **but** the live header is already preload-eligible (`max-age >= 31536000` + `includeSubDomains` + `preload`) → WARN: just submit at hstspreload.org.
- not preloaded, header present but not eligible → WARN naming exactly what's missing (max-age too short / no `includeSubDomains` / no `preload`).
- not preloaded, no HSTS header at all → WARN: enable HSTS first.

Preloading is irreversible at scale — removal takes weeks. Skill ramp: `max-age=86400` 24h → `604800` 1 week → `31536000` + `includeSubDomains` + `preload` → submit at hstspreload.org.

Source: https://hstspreload.org/

## HIBP Domains (optional)

Lists breaches involving the user's email-domain. API key required (paid for commercial).

`GET https://haveibeenpwned.com/api/v3/breaches?domain=example.com` with `hibp-api-key: ${HIBP_KEY}`. Surfaces as INFO so user can rotate affected creds.

## Skill targets

| Validator | Target | Notes |
|---|---|---|
| SSL Labs | A+ | All zones |
| MDN HTTP Observatory | A+ | A acceptable for legacy stacks |
| Security headers (local) | A (6/6) | Presence check; CSP strictness lives in Observatory |
| HSTS Preload | preloaded | Opt-in step; `unknown` is a real finding |
| HIBP Domains | zero | Optional |

## How `score` runs

For each in-scope hostname, fire all four (plus HIBP if key set) in parallel. SSL Labs is the long pole (60–120s); the MDN Observatory is now synchronous and fast. Render markdown grading sheet.

`score` is read-only. Cached per host under `.state/score-<validator>-<host>.json` (SSL Labs and Observatory cache 1h; the header/HSTS checks are cheap and re-run).

Sample output:

```
| host        | ssllabs | observatory | hsts-preload | headers (local) |
|-------------|---------|-------------|--------------|-----------------|
| example.com | A+      | A+          | preloaded    | A (6/6)         |

Wins: TLS strong, HSTS preloaded, all major headers set.
Improve: tighten CSP — Observatory docks a point for 'unsafe-inline'.
```

## Audit-lens grading (`audit all`)

The `score` validators above grade the edge. The `audit <lens>` surfaces add the
rest of the stack. Grading rules for the master report:

| Lens | Healthy ("OK") | Penalize when |
|---|---|---|
| `audit auditlog` | no unexpected token/member/delete/2FA-SSO events; no legacy-key auth | sensitive events by unexpected actors; legacy global key seen (FAIL) |
| `audit logpush` | security datasets shipped, jobs healthy, no creds in dest | missing `firewall_events`/`audit_logs`; disabled/stale/errored jobs; secret in destination (FAIL) |
| `audit dns` | low NXDOMAIN/SERVFAIL; resilient settings | NXDOMAIN >~15%, SERVFAIL spikes, query-type anomalies |
| `audit ai-gateway` | auth + rate-limit on; metadata-only logging | auth/rate-limit off; full-payload logging of PII |
| `audit secevents` | events match expected rules/sources | targeted block/challenge concentration; rules in `log` not `block` |
| `audit browser` | header CSP present & tight; no mixed content | over-permissive/missing CSP; un-allowlisted 3rd-party origins; mixed content (FAIL) |
| `audit observability` | no error/exception attack signal | exception spikes aligned with WAF blocks; auth-error floods |
| `audit casb` | no public sensitive files; admins MFA'd | public shares (FAIL); broad OAuth; admin w/o MFA (FAIL) |
| `audit dex` | fleet protected; tests passing | WARP bypass spikes; failing internal tests; low connected % |
| `audit builds` | provenance + no secrets in logs | secret in build logs (FAIL); untrusted branch/fork; failing prod builds |

**Neutral scoring is mandatory:** a `locked` (tier/not-configured) or `mcp-absent`
lens renders ⚪️ N/A and does **not** lower the grade. A free/pro account with no
Enterprise Zero-Trust features and no MCPs installed should still be able to score
well on everything it actually has. Only assessed surfaces count toward the grade.
