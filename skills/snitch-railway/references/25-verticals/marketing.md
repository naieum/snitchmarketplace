# Marketing site on Railway

**Honest verdict: marketing sites usually don't belong on Railway.**

Mostly-static sites (Astro, Hugo, Jekyll, Next.js with mostly static generation) belong on Cloudflare Pages, Netlify, or Vercel. Cheaper, CDN by default, no always-on compute charge.

## When Railway makes sense

- Heavy CMS backend (Strapi, Sanity self-hosted, Directus) — long-lived API service.
- Shares infrastructure with your product (same Postgres, same auth) — co-location simplifies operations.
- Personalization that's hard at the edge (logged-in user detection, A/B with server-side state).

## If you must run a marketing site on Railway

- Put Cloudflare in front for caching. Don't serve every page hit from Railway compute.
- Configure HSTS at the application layer.
- `numReplicas: 2`, sleep off.
- Schedule static export to a CDN for public, static parts (Next.js `next export` for those routes).

## Cost realism

A marketing site serving 100k pageviews/month from Railway probably costs more than a static site on Pages serving 10M. Compute model is wrong for static-leaning workloads.
