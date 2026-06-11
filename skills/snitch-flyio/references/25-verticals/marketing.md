# Marketing site on Fly.io

Marketing sites usually do NOT belong on Fly. Static content with build-time HTML deploys to a CDN host (Pages, Netlify, Vercel) — cheaper, faster, simpler.

## When Fly fits

| Need | Why |
|---|---|
| A/B testing at the edge with SSR variant decisions | Long-lived process. |
| Personalization for logged-in identity | Anonymous traffic doesn't justify Fly. |
| Heavy form processing (lead-gen, CRM) | Server-side. |
| Behind-the-scenes APIs (newsletter, demos) | Long-lived backend. |

For pure static marketing: don't pay for a Fly machine.

## Hybrid pattern

```
[Cloudflare Pages]          [Fly app]
- Marketing pages           - /api/* — newsletter, lead form, CRM webhook
- Blog                      - Personalized features
- Static assets             - Webhook receivers
       │                           │
       └─────── DNS ───────────────┘
              example.com
              api.example.com → Fly
```

Marketing on Pages, dynamic API on Fly. Cheapest combo.

## If you must run marketing on Fly

```toml
[env]
  NODE_ENV = "production"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0   # cold-starts OK for marketing

  [[http_service.checks]]
    grace_period = "5s"
    interval = "60s"
    path = "/"
```

Use `auto_stop_machines` aggressively — marketing traffic is bursty.

## CDN in front

Put Cloudflare / Bunny in front:

| Win | |
|---|---|
| Cache hit rate | High; let CDN serve. |
| DDoS / bot defense | Free at CDN. |
| DNSSEC | At Cloudflare level. |

## SEO / SEM

| Concern | Approach |
|---|---|
| Server-rendered HTML | Faster, more reliable than SPAs. |
| Schema.org structured data | Render server-side in `<head>`. |
| `robots.txt`, `sitemap.xml` | Serve from app, point at right hostnames. |
| Canonical URLs | `<link rel="canonical">` to avoid duplicate-content. |

## Critical hardening

- [ ] Form submissions: rate-limit (express-rate-limit / rack-attack).
- [ ] CAPTCHA on lead forms (reCAPTCHA, hCaptcha, Cloudflare Turnstile).
- [ ] CSP: tight default-src; allow only analytics + CDN you use.
- [ ] Privacy-respecting analytics (Plausible / Fathom) or anonymized GA4.

## Common mistakes

| Mistake | Cost |
|---|---|
| Hugo / Jekyll / Eleventy on Fly Machines | Wasting money on a CDN job. |
| Marketing + dashboard on same Fly app | Marketing spikes affect dashboard. |
| No CDN in front | Fly serves every page; bandwidth grows. |
| Meta tags client-side rendered | Open Graph / Twitter Card previews fail. |
