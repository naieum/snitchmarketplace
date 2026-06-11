# Blog on Vercel

Common stack: Next.js / Astro / Hugo + MDX or a headless CMS.

## Hardening checklist

| Area | Action |
|---|---|
| CSP | Extra strict; no embedded inline scripts (compile to module scripts) |
| User-supplied MDX | Sanitize on the server: `remark-gfm` + `rehype-sanitize` (allowlist) |
| Comments | Don't roll your own — Disqus / Giscus / Hyvor handle auth + spam |
| RSS feed | Cache aggressively: `Cache-Control: public, max-age=3600` |
| OG images | Generate via `@vercel/og` — built-in, secure-by-default for HTML escaping |

## Static-first

Marketing/blog sites should be ISR or SSG, not SSR-on-every-request. Pin `revalidate: 60 * 60`. Function bill drops to near-zero.

## Cost watchlist

- Blog cost = bandwidth + Image Optimization. ISR controls function cost.
- Large image libraries → dedicated image CDN (Cloudflare Images, ImageKit) over Vercel Image Optimization at scale.

## References

- https://vercel.com/templates/next.js/blog-starter-kit
- https://vercel.com/docs/functions/og-image-generation
