# 12 — Migrations

Read when transitioning between legacy and current ads-tracking primitives.

## UA → GA4 (sunset July 2023; full deletion July 2024)

UA is gone. If a site still references `UA-XXXXX-X`, the data is no longer collected.

Steps:

1. Create a GA4 property. Each old UA view maps to ~one GA4 property; or roll up several views.
2. Install GA4 via gtag.js or GTM (`fix pixel-install google`).
3. Map UA events to GA4 names — they don't match 1:1. UA's `category/action/label` triple is gone; GA4 uses event name + parameters.
4. Re-define conversions — each business-significant event marked as conversion in GA4 Admin.
5. Wire BigQuery export for raw event data. GA4's free tier includes BigQuery streaming; UA's didn't.
6. Update Google Ads conversion linking to GA4 events.

## Third-party cookies

Chrome backed off the full deprecation announced in 2024 — third-party cookies remain available, but Google now uses Privacy Sandbox APIs (Topics, Protected Audience, Attribution Reporting) as supplements. Safari ITP and Firefox ETP have restricted them for years.

For ads:
- **Plan for the post-cookie world anyway.** Build CAPI integrations now; they don't depend on third-party cookies.
- **First-party cookies are NOT going away.** `_ga`, `_fbp`, `_uetmsclkid`, `_ttp`, `_pin_unauth`, `_scid` live on.
- **CHIPS** partitions cross-site cookies; mostly affects embedded widgets, not first-party pixel work.

## Consent Mode v1 → v2 (mandatory March 2024)

If still on v1 (only `ad_storage` + `analytics_storage`), upgrade to v2 (also `ad_user_data` + `ad_personalization`). Without v2, Google Ads degrades smart bidding for EU/UK/EEA traffic.

`fix consent-mode` writes the v2 default-deny snippet plus integration glue.

## GA4 Data API → BigQuery export

GA4's Data API returns aggregated reports. For raw, joinable, sub-event data (e.g., joining on `transaction_id` to Stripe records), use BigQuery export:

1. GA4 Admin → Data Streams → BigQuery Links → Add link.
2. Creates daily and intraday tables; standard SQL.
3. Cost: BigQuery storage + query (pennies for low-traffic, $5-50/mo mid).

## Meta CAPI gateway (deprecated 2024) → CAPI direct

Meta's CAPI Gateway was sunset. Migrate to direct Conversions API calls (the `meta/node.template` and `meta/python.template` stubs).

## Ads.txt v1 → v1.1

v1.1 adds `contact=`, `managerdomain=`, `ownerdomain=` records. Backward-compatible.

## SKAdNetwork v3 → v4 → AdAttributionKit (iOS 17.4+)

| Version | iOS | Conversion value | Postbacks |
|---|---|---|---|
| SKAdNetwork v3 | 14.5-15.4 | single byte | one (24-48h delay) |
| SKAdNetwork v4 | 16.1+ | coarse + fine | three: 0-2d, 3-7d, 8-35d; source-app or source-domain |
| AdAttributionKit | 17.4+ | richer; App Store-managed | backward-compatible with SKAdNetwork |

Servers receiving postbacks should accept BOTH formats. The `apple/node.template` and `apple/python.template` stubs handle the union.

## CAPI versioning per platform

| Platform | Versioning | Notes |
|---|---|---|
| Meta | Graph API version (e.g., v21.0); pin in URL | Deprecates ~2 years after release; update annually |
| TikTok | Events API v1.3 → v2 likely 2026 | Watch changelog |
| Pinterest | v5 stable; v3 long deprecated | |
| Snapchat | v3 stable; v2 deprecated | |
| Reddit | v2.0 stable | newer feature surfaces |
| LinkedIn | `LinkedIn-Version` header (date-based, e.g., 202410) | Roll forward each quarter |

Check deprecation announcements quarterly; `refresh-docs` fetches canonical URLs.

## See also

- `01-auth-and-tokens.md` — current auth contracts.
- `13-incident-response.md` — what to do when a migration breaks.
