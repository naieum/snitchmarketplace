# Marketing site on Vercel

Common stack: Next.js / Astro / SvelteKit + a CMS (Contentful, Sanity, Storyblok, Payload, MDX in repo).

## Hardening checklist

| Area | Action |
|---|---|
| CSP | Tight default; overlay only what your CMS / analytics / chat actually need |
| Form endpoints | `/api/contact`, `/api/newsletter`: rate-limit + Cloudflare Turnstile / hCaptcha / reCAPTCHA |
| Spam | Honeypot field + server-side validation |
| CMS webhooks | Verify signature; trigger `revalidateTag` on content updates |
| `next/image` remotePatterns | Pin to your CMS asset host; no wildcards |
| robots.txt + sitemap.xml | Apex; CDN-cached |

## Privacy

- Cookie banner needed in EU; don't load Vercel Analytics / Speed Insights pre-consent if your privacy policy says so. Or pick privacy-first analytics (Plausible / Fathom).
- Geo-block: not common for marketing; usually keep open.

## Cost watchlist

- Marketing sites are mostly static — costs are dominated by bandwidth (video / large images).
- Use Vercel Image Optimization for hero images; offload large videos to a streaming platform.
- ISR with `revalidate: 60 * 60 * 24` for landing pages → near-zero function bill.

## SEO + headers

| Header | Notes |
|---|---|
| `X-Robots-Tag: noindex` | Staging only; never production |
| `Cache-Control: public, max-age=300, s-maxage=86400` | CDN 1 day; UA 5 min |

## References

- https://vercel.com/guides/marketing-sites
