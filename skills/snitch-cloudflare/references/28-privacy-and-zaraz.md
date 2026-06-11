# 28 — Privacy and Zaraz

Two free Cloudflare features that reduce third-party surface.

## Cloudflare Web Analytics (CFWA)

Free, no-cookie analytics: page views + RUM (LCP, FID, CLS, INP). No cross-site tracking, no consent banner required in most jurisdictions.

Doesn't cover: events / funnels, user-id sessionization, deep cohort analysis, GA4-style goal tracking. If user needs those → GA4 + consent gating (with Zaraz, below).

Setup: paste in `<head>`:

```html
<script defer src='https://static.cloudflareinsights.com/beacon.min.js'
  data-cf-beacon='{"token": "<your-token>"}'></script>
```

CSP: `script-src https://static.cloudflareinsights.com; connect-src https://cloudflareinsights.com`.

Skill flag: project uses only GA4/Plausible/Fathom/Mixpanel/Amplitude with no events needed → recommend CFWA.

Source: https://developers.cloudflare.com/web-analytics/

## Zaraz (server-side tag manager)

Third-party scripts run on Cloudflare's edge instead of browser. Browser sends one event ("user clicked signup") → Zaraz fans out to GA4 / Pixel / Hubspot / etc. Browser never loads vendor JS.

Wins: perf (no third-party network requests), privacy (vendor doesn't track in-browser), supply-chain (no skimmer surface), Magecart-resistant.

Catalog: 100+ vendors (GA4, Facebook/LinkedIn/Twitter/Pinterest/TikTok pixels, Hubspot, Marketo, Pardot, Mixpanel, Segment, Snowplow, Hotjar, FullStory, Crazy Egg, Heap, Klaviyo, Mailchimp, Iterable, custom HTML/JS).

Pricing: free 100k events/mo, Workers Paid 1M/mo, beyond pay-per-event. Live: https://developers.cloudflare.com/zaraz/reference/pricing/

Setup: dashboard → Zaraz → add tools. Cloudflare proxies inject Zaraz automatically; remove the original GTM/GA4/Pixel snippets.

Consent gating: per-tag "fires before consent" / "fires after consent". Required tags fire immediately; tracking tags wait. Built-in banner free, or use your own UI calling `window.zaraz.consent.set(...)`.

Source: https://developers.cloudflare.com/zaraz/consent-management/

## Recommendation tree

| Setup | Recommendation |
|---|---|
| GA4 only, no events needed | Switch to CFWA; drop consent banner |
| GA4 + Mixpanel + Hotjar + GTM | Move to Zaraz with consent management |
| GTM with many tags | Replace with Zaraz |
| Plausible (already privacy-first) | Keep; add CFWA for RUM |
| No analytics | Add CFWA for free baseline |

## Cookie / consent compliance

- EU GDPR / UK / Brazil LGPD: consent for non-functional cookies.
- California CCPA/CPRA: opt-out for "sale".

If site uses only CFWA + no third-party scripts → no banner needed in most jurisdictions. Zaraz with consent gating → minimal banner. GA4 direct → full granular banner.

## Skill targets

- GA4/Plausible/Fathom + no events needed → recommend CFWA (INFO).
- 3+ third-party tracker scripts → recommend Zaraz (WARN).
- GTM detected → recommend Zaraz replacement (WARN).
- Trackers loaded but no consent banner → WARN.
- Tracker scripts not in CSP allowlist (and not Zaraz-routed) → WARN.

Cross-refs: `05-security-headers.md` (CSP allowlists), `16-page-shield-supply-chain.md` (script change detection), `24-decision-trees.md` (analytics decision).
