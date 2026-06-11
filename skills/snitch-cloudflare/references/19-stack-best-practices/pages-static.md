# Pages — Pure Static (no framework)

Verdict + caveats: `fit-matrix static-html` / `hugo` / `jekyll` / `eleventy` / `gatsby`. Framework docs: `stack-docs pages-static`.

For plain HTML/CSS/JS, MDX docs, Hugo / Jekyll / Eleventy / Gatsby output.

## Cloudflare-specific

- `_headers` in deploy root carries the security set. FAIL if missing — see `05-security-headers.md`.
- `_redirects` for path changes; omit the SPA fallback for true static. https://developers.cloudflare.com/pages/configuration/redirects/
- No `*.map` in deploy output.
- `.well-known/security.txt` per RFC 9116 — `templates/security-txt.example`.

## CSP for static

Strict CSP achievable:

```
default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';
img-src 'self' data: https:; font-src 'self' data:;
connect-src 'self'; frame-ancestors 'none'; form-action 'self';
base-uri 'self'; object-src 'none'; upgrade-insecure-requests;
```

Third-party widgets (GA, Stripe, search) — merge from `templates/csp-stack-overlays.json` and see `16-page-shield-supply-chain.md`.

## SSG-specific gotchas

| SSG | Note |
|---|---|
| Hugo | `_headers` / `_redirects` go in `static/` so they're copied to `public/` |
| Jekyll | same files at source root + `keep_files` config to preserve |
| Eleventy | `eleventyConfig.addPassthroughCopy("_headers")` |
| Gatsby | build to `public/`. Gatsby Functions don't 1:1 map to Pages Functions |
| MDX docs (Mintlify, Docusaurus, Nextra) | search widgets often inject inline scripts — allowlist the search vendor in CSP |

## Skill targets

- `_headers` present with full security set: FAIL if missing.
- CSP without `'unsafe-eval'` in prod: WARN if present.
- Source maps in deploy: WARN.
- `security.txt` published: INFO if missing.
- `sitemap.xml` reachable: INFO if missing.
- HSTS preload submitted (when stable): INFO.
