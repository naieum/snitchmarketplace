## CATEGORY 100: Cookieless analytics readiness

The third-party-cookie era is over. Safari's ITP, Firefox's ETP, and Chrome's Privacy Sandbox have collapsed cross-site tracking; iOS 14.5+ ATT broke mobile attribution; the EU's Digital Markets Act forces consent flows that further suppress tracking. Brands that still rely on third-party-cookie-shaped measurement (`gtag.js` defaults, Meta Pixel client-side, third-party retargeting tags) are losing visibility into their funnel and over-paying for ads on inflated attribution.

This category audits the readiness of the brand's measurement stack for the cookieless world: server-side tagging, first-party data infrastructure, conversion APIs (Meta CAPI, Google Enhanced Conversions, TikTok Events API), consent-mode v2 implementation (Cat 56 cross-reference), identity resolution.

### Pre-flight: relevance check

Skip with reason `not applicable` ONLY if the site has no analytics or paid-marketing surface (extremely rare). Otherwise required, virtually every brand with paid media or analytics is affected.

### The framework: 4 layers

| Layer | What it does | Failure looks like |
|---|---|---|
| **1. First-party data infra** | Owned identifier (email/user_id) tied to every event | Anonymous events only; no logged-in event tagging |
| **2. Server-side tagging** | Browser-fired events relayed via your server to ad platforms | Pure client-side `gtag` / `fbq`; nothing server-side |
| **3. Conversion APIs** | Direct server-to-platform conversion uploads (Meta CAPI, Google Enhanced Conversions, TikTok Events API) | No CAPI; relying on browser pixel only |
| **4. Consent mode + signal handling** | Consent state propagated to all measurement; modeled conversions for unconsented users | Consent banner exists but doesn't propagate to tags; modeled conversions not enabled |

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for analytics integration: `gtag(`, `fbq(`, `tiktokPixel`, `linkedin_partner_id`, `_paq`, `posthog`, `mixpanel`, `segment`. Quote each.
2. Look for server-side tagging: a `/server-gtm` worker, a Cloudflare Worker proxying GA4 / Meta CAPI events, an `api/track` endpoint relaying to ad platforms.
3. Check for first-party-data identifiers in event payloads: `user_id`, `email_hash`, `client_id` populated on logged-in events.
4. Check for Conversions API (Meta CAPI / Google Enhanced Conversions / TikTok Events API) integration, look for backend code POSTing conversions to `https://graph.facebook.com/v.../events`, `https://www.googleadservices.com/pagead/conversion/`, `https://business-api.tiktok.com/`.
5. Check consent-mode propagation: consent updates from the banner trigger `gtag('consent', 'update', ...)` and propagate to all firing tags.

**Crawl mode, required tool calls:**

1. Open the site in DevTools Network tab. Record requests during a sample journey (homepage → pricing → signup).
2. Quote the analytics requests: domain (third-party `googletagmanager.com` vs first-party `analytics.example.com`), payload shape, identifiers.
3. Check whether the consent banner blocks tags pre-consent (most brands don't do this correctly).

### Forbidden claims

- "Server-side tagging is probably missing." Show the `gtag` / `fbq` clientside calls + missing server-side relay.
- "Conversions API may not be implemented." Either find the backend integration or note its absence.
- "Modeled conversions may be off." Quote the consent-mode v2 setup OR show its absence.

### What to Search For

- Client-side analytics: `gtag()`, `fbq()`, `tiktokPixel`, `linkedin_partner_id`, `_paq`
- Server-side tagging: `https://*.com/g/collect`, `/api/track`, custom analytics worker
- Conversion APIs: backend POSTs to Meta / Google / TikTok endpoints
- First-party identifiers: `email_hash`, `user_id`, hashed PII
- Consent-mode v2: `gtag('consent', 'default', ...)` + `gtag('consent', 'update', ...)`

### Actually Hurts the Marketing Surface

- **Pure client-side ad-platform pixels with no CAPI / Enhanced Conversions** (Safari + Firefox + iOS will block ~30-50% of these events).
  Evidence required: client-side pixel present + missing backend conversion upload.
- **No first-party identifier on logged-in events** (the brand owns the user identity but doesn't propagate it; attribution craters once cookies expire).
  Evidence required: logged-in event payload + missing `user_id` / `email_hash`.
- **Consent banner doesn't gate tags** (Meta Pixel fires before consent on EU traffic, GDPR risk + tag fires regardless of user choice).
  Evidence required: pre-consent network requests to ad platforms.
- **Consent-mode v2 not implemented** (modeled conversions disabled; Google can't fill attribution gaps for unconsented EU users).
  Evidence required: missing `gtag('consent', 'default', ...)` + missing v2 signal `ad_user_data` / `ad_personalization`.
- **Third-party tag manager (GTM client-side) with no server-side variant** (GTM client-side has all the same blocking problems).
  Evidence required: GTM client-side present + missing server-side container.
- **No identity resolution between marketing events and product events** (visitor → signup is one identity model; product usage is another; brands can't connect channel performance to LTV).
  Evidence required: separate identifiers in marketing analytics vs product analytics.

### NOT a Problem

- Privacy-first analytics (Plausible, Fathom, Simple Analytics) without CAPI, these brands have made an explicit choice to forgo ad attribution.
- Brand without paid media, if there's no paid acquisition, CAPI for paid platforms isn't applicable.
- Logged-out content site that explicitly avoids identifying users, privacy posture as strategy.

### Context Check

1. Does the brand run paid media? If yes, CAPI / Enhanced Conversions is non-negotiable.
2. Does the brand have logged-in users? If yes, propagate the user identity to events.
3. Is there a consent banner? If yes, does it actually gate tag firing?
4. Is identity resolution between marketing + product analytics in place?
5. Is the team prepared for the next round of restrictions (Privacy Sandbox APIs, attribution reporting via Privacy Sandbox)?

### Reference

Meta Conversions API docs: https://developers.facebook.com/docs/marketing-api/conversions-api

Google Enhanced Conversions: https://support.google.com/google-ads/answer/9888656

Google Consent Mode v2: https://developers.google.com/tag-platform/security/concepts/consent-mode

TikTok Events API: https://business-api.tiktok.com/portal/docs

Server-side GTM (Stape / Google's): https://stape.io / https://developers.google.com/tag-platform/tag-manager/server-side

`references/ads-detection-matrix.md`, per-platform CAPI / Conversions API endpoints

Cat 107 (Pixel install completeness), extends this category's CAPI methodology with the cross-platform pixel inventory

Cat 108 (UTM hygiene), server-side measurement still depends on accurate UTM ingestion

**Severity tagging:**
- Pure client-side pixels with no CAPI on a paid-media brand → Critical (under-attributed paid spend).
- No first-party identifier on logged-in events → High.
- Consent banner doesn't gate tags → Critical (regulatory + measurement gap).
- Consent-mode v2 not implemented (EU traffic) → High.
- GTM client-side with no server-side → Medium.
- No identity resolution marketing↔product → High.

**Fix voice:** `analytics-engineer` (primary) | `security-engineer` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> The third-party-cookie collapse isn't a future event; it's been the present for two years. Brands still measuring like it's 2020 are running on stale data and over-paying for paid acquisition because the tracking gaps are systematically inflating reported attribution.
>
> Three layers, in order of leverage.
>
> **1. First-party identity, propagated to every event.** When a user logs in, every analytics event going forward gets `user_id` AND `email_hash` (SHA-256 of normalized email). This is the durable identifier; cookies and `client_id` don't matter when this is present.
>
> ```ts
> gtag('config', 'G-XXXXXXX', {
>   user_id: user.id,
>   user_data: { sha256_email_address: hashEmail(user.email) },
> });
> ```
>
> **2. Server-side conversion upload (CAPI / Enhanced Conversions).** Every browser pixel is mirrored by a backend POST that reports the conversion directly to the ad platform. Use signed requests, a queued retry on failure, and dedupe by event_id so you don't double-count.
>
> ```ts
> // backend on signup-completed
> await metaCAPI.send({
>   event_name: 'CompleteRegistration',
>   event_id: eventId,                 // dedupes against pixel fire
>   event_time: Math.floor(Date.now() / 1000),
>   user_data: { em: hashEmail(user.email), client_ip_address: req.ip, client_user_agent: req.ua },
>   custom_data: { value: 49.99, currency: 'USD' },
> });
> ```
>
> **3. Consent mode v2 + actual gating.** The consent banner sets `gtag('consent', 'default', { ...denied })`. User accepts → `gtag('consent', 'update', { ad_user_data: 'granted', ad_personalization: 'granted', analytics_storage: 'granted' })`. Modeled conversions fill the attribution gap for the unconsented portion. Tags don't fire until the consent state allows.
>
> The combination, first-party identity, server-side delivery, consent-aware tagging, is what cookieless measurement looks like in practice. Each layer alone is partial; together they restore the visibility that cookies used to provide.
