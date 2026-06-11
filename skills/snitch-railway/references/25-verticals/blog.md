# Blog / publishing on Railway

**Honest verdict: most blogs don't belong on Railway.**

Static-site generators (Hugo, Jekyll, Eleventy, Astro static) cost less and serve faster from Pages/Netlify/Vercel. Headless CMS-driven blogs (Ghost, Strapi, WordPress headless) make sense on Railway when paired with content writers needing an admin UI.

## When Railway makes sense

- Headless WordPress or Ghost: long-lived PHP/Node admin + DB.
- Custom CMS: Rails, Django, NestJS — Railway's natural home.
- Blog co-located with a SaaS product on the same infra.

## Architecture

| Component | Where |
|---|---|
| CMS (Ghost / WordPress / custom) | Railway service |
| Postgres / MySQL | Railway add-on |
| Asset bucket | R2 / S3 |
| Public-facing static export | Cloudflare Pages, fed by build hook |
| Search | Meilisearch on Railway, or Algolia |

## Security must-haves

- Admin UI behind 2FA + IP allowlist (where CMS supports it).
- Public blog at CDN; admin at separate domain.
- Rate-limit comment endpoints aggressively.
- Schedule logical backups of the CMS database.

## Pure-static option

Markdown authoring without admin UI: Hugo/Astro static + Pages + GitHub Actions build is cheapest and fastest. Skip Railway entirely.
