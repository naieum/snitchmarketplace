# Vertical: Blog

Detection: Ghost / Hashnode integrations, `_posts/` (Jekyll), `content/blog/` (Hugo, Astro), RSS generators, comment systems (Disqus, Giscus, Utterances), heavy markdown.

CF overlay: aggressive cache TTLs; Turnstile on comments; safe markdown.

## Cloudflare overlay

- Aggressive cache TTLs:

  ```
  # Assets: 1 year
  starts_with(http.request.uri.path, "/assets/") or
  ends_with(http.request.uri.path, ".css") or ends_with(http.request.uri.path, ".js") or
  ends_with(http.request.uri.path, ".woff2") or ends_with(http.request.uri.path, ".jpg") or
  ends_with(http.request.uri.path, ".png") or ends_with(http.request.uri.path, ".svg")
  → edge_ttl: 31536000; browser_ttl: 31536000

  # HTML / feeds
  http.request.uri.path matches "^/posts?/.+$" or http.request.uri.path matches "^/blog/.+$" or
  http.request.uri.path eq "/feed.xml" or http.request.uri.path eq "/rss.xml"
  → edge_ttl: 3600; browser_ttl: 600
  ```

  Bust via `Cache-Tag` purges on publish.
- Turnstile on comment forms + per-IP rate limit on `/comments/*` (5/min). Giscus / Utterances inherit GitHub's anti-spam. Disqus brings third-party CSP + privacy concerns.
- RSS/feed cache 1h TTL. Don't aggressively gate feeds with Bot Fight Mode; verified-bot allowlist handles Inoreader / Feedly / NewsBlur.
- Image optimization (Pro+): Polish + Mirage. Cloudflare Images for many user-uploaded variants.
- CMS admin paths behind Access (Ghost, Statamic, Strapi). Static blogs (Hugo, Astro, Eleventy) have no admin.
- Hotlink Protection (free) — but breaks RSS images + SE image previews; recommend only if hotlinking is actively a problem.
- `?author=N` enumeration block on WP-style blogs via WAF Custom Rule.

## Markdown safety

- Disable raw HTML in `marked` / `markdown-it` (`html: false`).
- Sanitize with `rehype-sanitize` or `dompurify` (server build).
- No `eval` / `Function` constructor on user content.
- Block `javascript:` URIs in `href` and `image alt`.

## Search choice (CSP impact)

| Tool | CSP impact |
|---|---|
| Pagefind | client-side, indexed at build, `'self'` only |
| Algolia DocSearch | adds `https://*.algolia.net` |
| Cloudflare Vectorize + Workers AI BGE | server-side semantic, first-party |

## Plan recommendation

Free for personal blogs. Pro ($25/mo): Polish, Mirage, Page Shield. Workers Paid ($5/mo) only if a search/comment Worker exceeds free.

## Skill checklist

- [ ] Cache Rules: long TTL assets, hour-TTL HTML, hour-TTL feeds.
- [ ] Turnstile on comment forms.
- [ ] Markdown rendering with sanitizer; raw HTML disabled.
- [ ] `sitemap.xml` + RSS feed accessible.
- [ ] HSTS preloaded.
- [ ] Always Use HTTPS on.
- [ ] Comment-form rate limit.
- [ ] CMS admin paths (if any) behind Access.
- [ ] Image optimization (Polish or external).
