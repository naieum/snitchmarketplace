# Google Ads + Google Marketing Platform

| Field | Value |
|---|---|
| Web tag | `gtag.js` (or via GTM container) |
| Identifiers | GA4 `G-XXXXXXXXXX`, Google Ads `AW-XXXXXXXXXX`, GTM `GTM-XXXXXXX` |
| Server-side | gtag conversions, **Enhanced Conversions for Web/Leads**, **Google Ads API uploadOfflineConversions** |
| Account model | MCC (manager) → customer; 10-digit dash-separated ids (`123-456-7890`) |
| Marketing API | `googleads.googleapis.com/v25` (REST + gRPC) |
| Auth | OAuth2 + developer token + login-customer-id |
| Consent | Consent Mode v2 — canonical implementation |

Universal: pixel/init order in `02-pixel-foundations.md`; Consent Mode v2 in `04-consent-and-cmp.md`; CAPI dedup in `03-conversion-tracking.md`.

## Setup

1. Create / log in at <https://ads.google.com>.
2. (For API) Apply for developer token in MCC: Tools → API Center.
3. Create Google Cloud project, enable Google Ads API, configure OAuth2 client.
4. Mint refresh token for an account with access.
5. Install GA4 + Google Ads via gtag.js or GTM (`fix pixel-install google`).
6. Configure Consent Mode v2 defaults BEFORE first hit; `wait_for_update` ≥ 500 ms.
7. Verify in Tag Assistant + GA4 DebugView.
8. Configure Enhanced Conversions in Google Ads → Conversions → Settings.

Walkthrough: `references/setup/pixel-install.md` + `01-auth-and-tokens.md`.

## Conversion taxonomy

GA4 recommended: `purchase`, `add_to_cart`, `begin_checkout`, `add_payment_info`, `generate_lead`, `sign_up`, `login`, `view_item`, `view_item_list`, `view_promotion`, `select_promotion`, `search`.

Google Ads conversion categories: `PURCHASE`, `LEAD`, `SIGN_UP`, `PAGE_VIEW`, `DOWNLOAD`, `ADD_TO_CART`, `BEGIN_CHECKOUT`, `SUBSCRIBE_PAID`, `PHONE_CALL_LEAD`, `SUBMIT_LEAD_FORM`, `BOOK_APPOINTMENT`, `REQUEST_QUOTE`, `STORE_VISIT`, `STORE_SALE`. Mark smart-bidding drivers `primary_for_goal: true`.

## Server-side / CAPI

Google calls these:
- **Enhanced Conversions for Web** — gtag-side hashing of email/phone, sent alongside JS conversion.
- **Enhanced Conversions for Leads** — hashed PII attached to a CRM-uploaded conversion.
- **Google Ads API: ConversionUploadService** — server-to-server upload using GCLID, GBRAID, WBRAID, or hashed user data.
- **Server-side GTM** — host `tagging.<yourdomain>` server container.

`apply_capi.sh` for `google` produces a Node/Hono/Express endpoint calling UploadClickConversions via REST.

## Call-first / local lead-gen readiness

Local-service advertisers convert by phone and quote form, not checkout — the tracking gaps differ from e-commerce. `state site <url> lead-capture` audits the on-page half; the rest is account-side.

- **Website call conversions**: a `tel:` link is only a conversion if tracked. Native route: `gtag('config', 'AW-XXXXXXXXXX/<label>', { phone_conversion_number: '<displayed number>' })` — Google swaps the number and attributes calls. Alternative: a DNI (dynamic number insertion) provider (CallRail, CallTrackingMetrics, Invoca, WhatConverts, Marchex) whose swap script must load on every page that renders the number. A `tel:` link with neither is an untracked conversion path.
- **GCLID capture on lead forms**: a hidden `gclid` input populated from the landing-page URL (or read from the `_gcl_aw` cookie) and stored on the lead record. Without it, `ConversionUploadService` has nothing to join offline outcomes to (GBRAID/WBRAID stand in on iOS traffic).
- **Enhanced Conversions for Leads**: hash email/phone at form submit (`user_data`), so Google can match the lead even when no GCLID survives. Enable per conversion action in Google Ads → Conversions → Settings.
- **The offline import loop**: CRM marks the lead closed-won with value → upload via ConversionUploadService keyed on GCLID. This is what trains Smart Bidding on revenue instead of raw lead volume; same ≥30 conversions/30d floor before tCPA on offline values.
- **Local Services Ads (LSA)**: a separate product from Search — ranked by review count/rating, responsiveness, and verification (license/insurance checks), not keywords or pixels. For licensed local-service verticals (HVAC, plumbing, electrical, legal, etc.), absence of LSA is a `recommend`-level finding: it typically undercuts Search cost-per-lead for the same queries.

## Notable extras

- **Smart Bidding readiness**: needs ≥30 conversions/30d for tCPA, ≥50/30d for tROAS.
- **GCLID retention**: ensure `_gcl_aw` cookie preserved (sGTM helps); without it, Enhanced Conversions degrade.
- **Performance Max**: requires asset-group-level conversion goals; flag PMax campaigns missing primary goals.
- **Sandbox dev token**: only works against test customer IDs.

## Cited URLs

- Google Ads API: <https://developers.google.com/google-ads/api/docs/start>
- REST reference v25: <https://developers.google.com/google-ads/api/rest/reference/rest/v25>
- gtag.js: <https://developers.google.com/tag-platform/gtagjs/install>
- Consent Mode v2: <https://developers.google.com/tag-platform/security/guides/consent>
- Enhanced Conversions: <https://support.google.com/google-ads/answer/9888656>
- GA4 Recommended events: <https://developers.google.com/analytics/devguides/collection/ga4/recommended-events>
- Server-side tagging: <https://developers.google.com/tag-platform/tag-manager/server-side>
- Website call conversions: <https://support.google.com/google-ads/answer/6095883>
- Enhanced Conversions for Leads: <https://support.google.com/google-ads/answer/11347292>
- Offline conversion imports: <https://support.google.com/google-ads/answer/2998031>
- Local Services Ads: <https://support.google.com/localservices/answer/6224841>
- Developer token application: <https://ads.google.com/aw/apicenter>
- ads.txt: AdSense/AdManager publishers add `google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0`
