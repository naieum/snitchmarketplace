# Marketing site

Detection: static-only output, marketing CMS (Contentful, Sanity, Strapi), no auth / payment paths, page-load speed as primary metric.

## DigitalOcean overlay

- **Spaces + CDN**. Cheap, fast, no SSR runtime to maintain.
- **Custom domain on the CDN** with Let's Encrypt cert.
- **Cache headers explicit**: `Cache-Control: public, max-age=31536000, immutable` for hashed assets, `s-maxage=300` for HTML.
- **Cache invalidation** on deploy: full bucket sync + CDN purge per path.
- **CSP** via headers from a thin proxy (Cloudflare in front, or nginx on App Platform).
- **Form handler**: separate App Platform Function for `POST /contact` with rate limiting + signature verification.
- **DDoS / WAF**: Cloudflare in front. DO has no L7 WAF.

## Skill checklist

- Bucket private; CDN reads only.
- CDN endpoint with custom subdomain + cert.
- Cache headers explicit on every asset type.
- CSP set (via Cloudflare or proxy).
- Form endpoint rate-limited.
- Cloudflare DNS in front for WAF + DNSSEC.
