# 27 — Subdomain Takeover, Cookie Audit, Live Exposure Probe

## Subdomain takeover scan

Dangling CNAME → `myapp.netlify.app` (decommissioned) → attacker registers `myapp` and gets your subdomain + valid HTTPS.

Provider fingerprints in `templates/takeover-providers.json` (refreshed by `refresh-docs`). Covered: AWS S3/CloudFront, GitHub Pages, Heroku, Azure App Service, Netlify, Vercel, Surge, Firebase, Bitbucket Pages, Fastly, Squarespace, Pantheon, Statuspage, Cargo, Tumblr, Helpjuice, Zendesk, WPEngine, Fly.io, Render.

Algorithm per A/AAAA/CNAME/ALIAS:

1. Resolve target.
2. If suffix matches known provider, HEAD the host.
3. Body matches the fingerprint → FAIL.
4. 200 with non-fingerprint content → OK.
5. Network/timeout error → WARN (couldn't verify).

Remediation: `fix takeovers` does NOT auto-delete. Walks the user through: reclaim the resource at the provider, OR delete the DNS record, then re-scan.

Source: https://github.com/EdOverflow/can-i-take-over-xyz

## Cookie audit

Static pass — grep cwd source for `Set-Cookie:`, `cookie.set`, `res.cookie`, `setcookie(`, `Cookies.set`, framework-specific (`cookies()`, `Astro.cookies`, `Hono setCookie`, `cookies.signed`, `Cookie::queue`, `response.set_cookie`).

Sensitive heuristic: name contains `session|auth|token|jwt|sid|csrf|access`. Required:
- Sensitive: `Secure` + `HttpOnly` (except CSRF) + `SameSite` (`Strict`/`Lax`/`None`+Secure).
- Non-sensitive: `Secure` + `SameSite=Lax`.

Missing on sensitive = FAIL. Missing `SameSite` (any) = WARN.

Runtime pass — GET deployed homepage, collect every `Set-Cookie`. Catches third-party cookies (GA `_ga`, Hotjar `_hjid`, Stripe `__stripe_mid`) — many lack `HttpOnly` legitimately. Pair with Page Shield cookie monitor (Biz+) for Magecart-style detection.

`fix cookies` does NOT modify code. Outputs a one-line patch per finding:

```
File: src/middleware/auth.ts:42
Patch: res.cookie('session', token, { maxAge: 86400000, secure: true, httpOnly: true, sameSite: 'lax' });
```

Agent applies via Edit/Write after user confirms.

## Live exposure probe

When: only after the foreign-tech WAF rule is applied at least once (else everything 404s).

How: HEAD each path in `templates/exposure-probe-paths.txt` against the deployed host, 1 req/sec.

Path categories (high-signal, low-FP):

- Source/secret leak: `/.git/HEAD`, `/.git/config`, `/.svn/entries`, `/.env`, `/.env.local`, `/.env.production`, `/.aws/credentials`, `/.npmrc`, `/.pypirc`, `/.DS_Store`, `/Dockerfile`, `/docker-compose.yml`.
- Wrong-stack probes (FAIL on non-WP/non-PHP/non-.NET): `/wp-admin/`, `/wp-login.php`, `/phpmyadmin/`, `/server-status`, `/server-info`, `/manager/html`, `/CFIDE/`, `/elmah.axd`, `/trace.axd`, `/owa/`, `/Autodiscover/`.
- VPN probes: `/+CSCOE+/`, `/dana-na/`, `/global-protect/`.
- Should-exist: `/.well-known/security.txt`, `/robots.txt`, `/sitemap.xml`.

Expected per row:

| Code | Verdict |
|---|---|
| `403` (WAF blocked) | ideal |
| `404` (no such path) | fine |
| `200` | FAIL except for should-exist paths |
| `5xx` | investigate; origin exposes a path WAF should block |
| `301/302` to a known page | fine |

## Skill targets

- Subdomain takeover: zero FAIL rows.
- Cookie audit static: all sensitive cookies have `Secure`+`HttpOnly`+`SameSite`.
- Cookie audit runtime: no surprise unflagged cookies.
- Live probe: every path 403/404 except permitted 200s.

Sources: https://github.com/EdOverflow/can-i-take-over-xyz , https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies
