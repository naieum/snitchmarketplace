# 16 — Server-side tag manager

Read when recommending sGTM, audit-trailing why client-side tag count is high, or budgeting first-party domain hosting.

## What sGTM is

GTM ships in two modes:

1. **Web container (client-side)** — JS in the browser executes tags. Default.
2. **Server-side container** — your server hosts a GTM proxy that receives events from the browser, processes them, and forwards to ad platforms. Browser only loads a small first-party tag.

## Wins from sGTM

| Benefit | Why |
|---|---|
| First-party domain | Pixels load from `sgtm.example.com` — better persistence under Safari ITP, Firefox ETP |
| Smaller client JS | A 5kB sGTM client replaces a 50-200kB GTM container |
| Better CAPI bridging | Server transforms client events into server-side conversions cleanly |
| Privacy control | Drop / hash / scrub PII before forwarding |
| Reduced ad-blocker impact | First-party domain isn't on most blocklists |

## Cost

- DevOps overhead — a long-running service.
- Hosting bill ($40-300/mo typical).
- Some buy-side tags don't have a server-side variant; client-side container still needed for those.

## When sGTM is worth it

- Spend > $10k/mo on Google Ads + Meta combined.
- Substantial mobile Safari traffic (ITP cuts client-side measurement 20-40%).
- Ad-blocker rate above 15%.
- Privacy / GDPR scrutiny pushed by legal.

## When it isn't

- Spend below ~$3k/mo combined — incremental measurement gain doesn't pay for the host.
- Single-platform setup (just GA4) — direct gtag works.
- No engineering resources.

## Hosting options (see `references/recommendations/gtm-server.md`)

| Host | Vendor | Setup ease | Pricing |
|---|---|---|---|
| Google Cloud App Engine | Google | Canonical; deploy script provided | $40-120/mo |
| Cloudflare Workers | Cloudflare | Community templates; engineer-led | $5/mo + per-request |
| Stape.io | Stape | One-click; managed | $20-300/mo |
| Vercel | Vercel | Custom function; manual | $20+/mo |
| AWS App Runner | AWS | Container deploy | $25-150/mo |

App Engine is Google's reference. Stape is easiest. Workers is cheapest at scale.

## First-party domain setup

Point a subdomain (`sgtm.example.com`) at the host. CNAME or proxy through Cloudflare. The GTM web container ships events to `https://sgtm.example.com/g/collect` instead of `https://www.google-analytics.com/g/collect`.

Browsers see this as a first-party request — Safari ITP doesn't cap cookie lifetime to 7 days; ad blockers don't filter the domain.

## What sGTM doesn't fix

1. **Doesn't replace CAPI for non-Google platforms.** Meta CAPI, TikTok Events API, Pinterest CAPI — still use the per-platform stubs. sGTM can route Meta events through itself, but you still call Meta's CAPI.
2. **Doesn't fix consent.** Consent Mode v2 still applies.
3. **Doesn't make pixels invisible.** Anti-fingerprint browsers still detect outbound tracking.

## Audit signal

`state site <url> pixels` reports if sGTM is in use (detected via first-party `sgtm.*` subdomain in pixel script srcs). Absent + high ad spend → 🟡 WARN with `recommend gtm-server`.

## See also

- `references/recommendations/gtm-server.md` — vendor comparison + setup commands.
- `references/setup/pixel-install.md` — basic pixel install.
- Google sGTM: https://developers.google.com/tag-platform/tag-manager/server-side
