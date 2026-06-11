# Vertical: Marketing site

Detection: SSGs (Hugo, Astro static, Eleventy, Gatsby), lead-form libs (Hubspot/Marketo/Pardot embed scripts, `/contact`, `/demo`, `/signup-newsletter`), heavy 301 redirect set, schema.org JSON-LD.

CF overlay: cache for crawler-friendliness + fast TTFB; Turnstile + honeypot on lead forms; redirect cleanup.

## Cloudflare overlay

- Long cache TTLs on assets, short on HTML:

  ```
  # Assets: 1 year (content-hashed filenames)
  starts_with(http.request.uri.path, "/assets/") or
  starts_with(http.request.uri.path, "/_astro/") or
  starts_with(http.request.uri.path, "/_next/static/") or
  ends_with(http.request.uri.path, ".css") or ends_with(http.request.uri.path, ".js") or
  ends_with(http.request.uri.path, ".woff2")
  → edge_ttl: 31536000; browser_ttl: 31536000

  # HTML: 1 hour edge cache
  http.request.uri.path matches "^/(?:blog|guides|features|pricing).*$" or http.request.uri.path eq "/"
  → edge_ttl: 3600; browser_ttl: 600
  ```

- Turnstile on every lead form + honeypot field + time-to-submit check (< 3s = bot) + per-IP rate limit (5/hour). Server validates token + honeypot empty + reasonable submit time. Merge `templates/csp-stack-overlays.json` `cloudflare-turnstile`.
- Polish (Pro+) for image optimization at edge; Mirage (Pro+); Cloudflare Images for full transform pipeline. https://developers.cloudflare.com/images/polish/
- Bot Fight Mode on — verified bots (Googlebot, Bingbot) auto-allowlisted. Allowlist niche services with a `skip` rule.
- Redirect Rules, not Page Rules for any new redirect (more rules per zone, regex on Biz+). https://developers.cloudflare.com/rules/url-forwarding/
- DMARC for the form-destination domain — prevents form weaponization. See `14-email-and-dmarc.md`.
- Cloudflare Web Analytics (free, no cookie banner needed in most jurisdictions) when Mixpanel/Amplitude depth isn't needed.
- Zaraz to consolidate 5+ third-party tag scripts off-browser — see `28-privacy-and-zaraz.md`.

## SEO misconfigurations the skill flags

- `Cache-Control: no-store` on HTML.
- `robots.txt` `Disallow: /` shipped to prod.
- 302s where 301s should be.
- `<meta name="robots" content="noindex">` left from staging.

## Plan recommendation

Free covers most static marketing sites. Pro ($25/mo): Polish, Managed Ruleset, exposed-credentials, Page Shield. Business: heavy regex / redirect needs only.

## Skill checklist

- [ ] Cache Rules: long TTL assets, short TTL HTML.
- [ ] Turnstile + honeypot on every lead form.
- [ ] Modern Redirect Rules.
- [ ] `robots.txt` + `sitemap.xml` published and not blocking.
- [ ] HSTS preloaded.
- [ ] Bot Fight Mode on.
- [ ] Zaraz when 5+ third-party tags.

Sources: https://developers.cloudflare.com/images/polish/ · https://developers.cloudflare.com/rules/url-forwarding/
