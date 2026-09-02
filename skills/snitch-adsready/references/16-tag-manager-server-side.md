# 16 — Server-side tag manager

Read when recommending sGTM, audit-trailing why client-side tag count is high, or budgeting first-party domain hosting.

## The four measurement layers

sGTM is one layer of the stack that replaces third-party-cookie measurement. Audit the stack as
four layers so the report says which one is missing instead of "measurement is weak":

| Layer | What it does | Failure looks like |
|---|---|---|
| 1. First-party identity | an owned identifier (user id, hashed email) rides every event | anonymous events only; logged-in sessions carry no identifier |
| 2. Server-side tagging | browser events relay through your server before they reach the platform | pure client-side `gtag` / `fbq`, nothing server-side |
| 3. Conversion APIs | the server posts conversions straight to each platform | no CAPI; browser pixel is the only source (`03-conversion-tracking.md`) |
| 4. Consent + signal handling | consent state propagates to every tag; modeled conversions cover the rest | banner present, firing rules never bound to it (`04-consent-and-cmp.md`) |

Layers 1 and 3 pay for themselves first. Layer 2 is the one with a hosting bill — see the
threshold below before recommending it.

### Layer 1: first-party identity

Once a user authenticates, every downstream event carries the durable identifier rather than
relying on a cookie surviving:

```js
gtag('config', 'G-XXXXXXX', {
  user_id: user.id,
  user_data: { sha256_email_address: hashEmail(user.email) },
});
```

Hash on the server or with a vetted client hash; normalize (trim, lowercase) before hashing or
the platform's match rate collapses. Audit check: a logged-in event payload with no `user_id`
and no hashed email, quoted at `file:line`, on a site that has accounts.

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

## Hosting options

`references/recommendations/gtm-server.md` carries the host-by-host comparison (setup effort,
pricing, pros and cons) — one copy, read it there, or run `recommend gtm-server` for the same
catalog as JSON.

## First-party domain setup

Point a subdomain (`sgtm.example.com`) at the host. CNAME or proxy through Cloudflare. The GTM web container ships events to `https://sgtm.example.com/g/collect` instead of `https://www.google-analytics.com/g/collect`.

Browsers see this as a first-party request — Safari ITP doesn't cap cookie lifetime to 7 days; ad blockers don't filter the domain.

## What sGTM doesn't fix

1. **Doesn't replace CAPI for non-Google platforms.** Meta CAPI, TikTok Events API, Pinterest CAPI — still use the per-platform stubs. sGTM can route Meta events through itself, but you still call Meta's CAPI.
2. **Doesn't fix consent.** Consent Mode v2 still applies.
3. **Doesn't make pixels invisible.** Anti-fingerprint browsers still detect outbound tracking.

## Audit signal

`state site <url> pixels` reports if sGTM is in use (detected via first-party `sgtm.*` subdomain in pixel script srcs). Absent + high ad spend → 🟡 WARN with `recommend gtm-server`.

In source mode, the server-side layer looks like a relay endpoint (`/api/track`, an edge worker
forwarding to `/g/collect`, a queue consumer posting to a platform CAPI). Quote it or quote its
absence. A client-side GTM container with no server-side variant inherits every blocking
problem the raw pixels have — that is a Medium on its own and a High when it is the only path
carrying conversions for a paid program.

Not a finding: a site with no paid media at all, or one whose measurement is deliberately
cookieless with no ad pixels. Skip with that reason.

## See also

- `references/recommendations/gtm-server.md` — vendor comparison + setup commands.
- `references/setup/pixel-install.md` — basic pixel install.
- Google sGTM: https://developers.google.com/tag-platform/tag-manager/server-side
