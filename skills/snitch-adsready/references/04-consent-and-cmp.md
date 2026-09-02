# 04 — Consent + CMP

Read when wiring Consent Mode v2 or auditing why pixels are firing without consent. Pair with `references/recommendations/cmp.md` to pick a CMP.

## Consent Mode v2

Google's mandatory consent signaling for advertisers serving EU/UK/EEA. Required since March 2024 to avoid Smart Bidding degradation in Google Ads + GA4. Other platforms (Meta, Microsoft, TikTok) interop with it.

Four signals:

| Signal | Controls |
|---|---|
| `ad_storage` | Ad cookies (gclid, _gcl_*) for measurement / remarketing |
| `ad_user_data` | User data sent to Google for advertising |
| `ad_personalization` | User data used for personalized ads |
| `analytics_storage` | GA4 cookies (_ga, _gid) |

Set defaults to `denied` BEFORE any tag loads, then upgrade per user choice:

```html
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('consent', 'default', {
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    analytics_storage: 'denied',
    wait_for_update: 500
  });
</script>
<!-- CMP loads here, then upgrades on user accept: -->
<!-- gtag('consent','update',{ad_storage:'granted',analytics_storage:'granted',...}); -->
```

Without `wait_for_update`, tags fire while consent is still pending → wrong telemetry.

## IAB TCF v2.2

Most enterprise CMPs (OneTrust, Cookiebot, Sourcepoint, Didomi) ship TCF support.

- **TCF** is the EU-canonical signal protocol — vendors read a TC string from `__tcfapi`.
- **Consent Mode v2** is Google's first-party gtag protocol.

Most CMPs do BOTH automatically. Custom-built consent UIs (Klaro, custom React banner) ship Consent Mode v2 directly and skip TCF unless selling programmatic display where TCF is mandatory.

## When you need a CMP

Triggers:
- EU/UK/EEA traffic (GDPR + UK GDPR + ePrivacy)
- California (CCPA / CPRA)
- Colorado, Connecticut, Virginia, Utah, Texas, Oregon (US state privacy laws)
- Quebec law 25 (2024)
- Brazil LGPD, India DPDP, Japan APPI

Any of the above + no CMP signal = 🔴 FAIL. Never write tracking pixels into a page when no consent banner / CMP is detected — `fix pixel-install` enforces this and points at `recommend cmp` (SKILL.md, Guardrails).

## Per-platform consent integration

| Platform | Consent integration |
|---|---|
| Google (GA4 / Ads) | Consent Mode v2 native |
| Meta | `fbq('consent','grant'/'revoke')`. Many CMPs auto-wire. Reads CMv2 via Google API. |
| Microsoft (UET) | `uetq.push('consent','default',{ad_storage:'denied'})` then update on grant |
| TikTok | `ttq.consent('grant'/'revoke')` (newer pixel) |
| LinkedIn | Insight Tag respects DNT + reads CMP TCF; gate via CMP — NOT a CMv2 partner |
| Pinterest | `pintrk('consent','grant')` |
| Snap | `snaptr('consent','grant')` |
| Reddit | `rdt('consent','grant')` (newer pixel) |
| X | reads platform's gdpr/consent params at click → ad-server level |
| Apple Search Ads | iOS App Tracking Transparency — OS-handled, not web |

The CMP does most of this glue automatically. Sanity-check by clicking "decline all" and watching DevTools → Network: no platform domains should fire.

## Regional consent defaults

| Region | Consent default behavior |
|---|---|
| EU + UK + EEA | denied (must opt in) — Consent Mode v2 enforced |
| Switzerland (FADP) | denied (aligned with GDPR) |
| Brazil (LGPD) | similar to GDPR |
| California (CCPA / CPRA) | granted by default; honor opt-out + GPC signal |
| Other US states (CO, CT, VA, etc.) | similar to California |
| Canada (PIPEDA / Quebec L25) | denied for Quebec; granted elsewhere |
| Australia, NZ, Asia (most) | granted, with opt-out support |

Most CMPs auto-detect region by IP and apply the right default. Verify the CMP in use does
this rather than assuming it — a single global default is the common failure.

## Audit checks

Each one is a Finding only with the quoted call or the network record behind it. "Consent may
not be wired" is not a finding; the `gtag('consent', ...)` line at `file:line`, or its absence
across the whole tree, is.

| Check | Finding when | Evidence to quote |
|---|---|---|
| Banner present | site serves a regulated region and no CMP / consent library loads | absence across the tree, plus the region signal (locale routes, currency, `hreflang`, stated market) |
| Default state | `gtag('consent','default', ...)` sets any signal to `granted` | the default call and the granted key |
| Default ordering | the default call runs after `gtag.js` / a pixel init | both `file:line`s and their order in `<head>` |
| Banner actually blocks | tags fire on first load regardless of the choice | the pre-consent network requests to platform domains after "decline all" |
| Tag manager wiring | a GTM container loads pixels and consent state is not bound to the firing rules | container snippet + missing consent trigger/variable |
| Choice persistence | the saved choice is not replayed before tags on a return visit | the storage read (or its absence) relative to the first tag |
| Signal completeness | v1-shaped default with no `ad_user_data` / `ad_personalization` | the default call's key set |

Sanity path: load with a clean profile, decline all, and record every request to a platform
domain. Zero requests is the Pass; quote the recorded list either way.

## Not a finding

- A US-only site with no EU/UK traffic can skip full Consent Mode; state privacy laws still
  apply through opt-out and GPC, so check that path instead of reporting a missing banner.
- Cookieless, no-ad-pixel analytics (the privacy-first hosted kind that sets no cross-site
  identifier) does not need Consent Mode v2. Confirm no ad pixel is also installed before
  granting this.
- A CMP that ships TCF only, on a site running no Google ad products, is a deliberate choice —
  Skip with that reason, not a Finding.

## Verifying consent reaches the platforms

| Platform | Tool |
|---|---|
| Google | Tag Assistant Companion (Chrome ext) |
| Meta | Meta Pixel Helper (Chrome ext) |
| Microsoft | UET Tag Helper |
| LinkedIn | LinkedIn Insight Tag Helper |
| TikTok | TikTok Pixel Helper |
| Pinterest | Pinterest Tag Helper |
| Reddit | Reddit Pixel Helper |
| Snapchat | Snap Pixel Helper |
| X | TwitterPixel inspector (community) |

Inspector should show page-view WITH a consent_state object reflecting the user's choice — never `granted` when declined.

## See also

- `references/recommendations/cmp.md` — vendor comparison.
- `references/setup/consent-mode.md` — setup walkthrough.
- Google Consent Mode v2: https://developers.google.com/tag-platform/security/guides/consent
