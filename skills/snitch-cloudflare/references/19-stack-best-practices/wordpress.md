# WordPress on Cloudflare

Verdict + caveats: `fit-matrix wordpress`. Framework docs: `stack-docs wordpress`.

Path: WordPress on its host, CF in front. PHP doesn't run on Workers — don't replatform.

## Cloudflare-specific

- Origin reachable only from Cloudflare (Tunnel preferred). FAIL if 443/80 public.
- `/wp-login.php` rate-limited (POST). FAIL otherwise.
- `/xmlrpc.php` blocked unless an integration explicitly needs it (almost always abused). Custom Rule: `http.request.uri.path eq "/xmlrpc.php"` → block.
- `/wp-admin/*` behind Cloudflare Access OR origin-firewalled. WARN otherwise.
- `wp-config.php` not 200-reachable. FAIL if it is.
- `?author=N` enumeration blocked: `http.request.uri.query contains "author=" and http.request.uri.path eq "/"`.
- Bot Fight Mode on. WARN if off.
- Cache bypass when logged-in cookie present:

  ```
  starts_with(http.cookie, "wordpress_logged_in_") or
  http.request.uri.path starts_with "/wp-admin"
  → Cache eligibility: bypass
  ```

## WAF profile

WP profile in `templates/waf-stack-profiles.json`. Universal blocks: `/.env`, `/.git/*`, `*.bak`, `*.sql`, `*.zip`, foreign CMS admin paths (`/administrator`, `/typo3`, `/drupal`).

## Headers / CSP

Set HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy via Transform Rules — WP themes/plugins emit inconsistent headers. Strict CSP without `'unsafe-inline'` is hard with WordPress; Page Shield (Pro+) is the practical control. https://developers.cloudflare.com/learning-paths/wordpress/

## APO / Polish

APO (Pro+ paid add-on) caches HTML aggressively + integrates with WP cache plugins. Polish/Mirage (Pro+) for image optimization. https://developers.cloudflare.com/automatic-platform-optimization/

## Skill targets

- Origin reachable only from CF: FAIL otherwise.
- `/wp-login.php` rate limit: FAIL if missing.
- `/xmlrpc.php` blocked or rate-limited: WARN.
- `/wp-admin` behind Access OR origin-allowlisted: WARN.
- Bot Fight Mode on: WARN if off.
- HSTS configured at zone: FAIL otherwise.
- `wp-config.php` not 200-reachable: FAIL.
- Plugin/theme update cadence: INFO.
