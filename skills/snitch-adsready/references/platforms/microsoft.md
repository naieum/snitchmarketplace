# Microsoft Advertising (Bing Ads)

| Field | Value |
|---|---|
| Web tag | UET (Universal Event Tracking) — `uetq` global |
| Identifiers | UET tag id (numeric), customer id, account id |
| Server-side | **Offline Conversion Import** (CSV), **Bulk API**, **Conversion Goals API** |
| Account model | Customer → account → campaign |
| Marketing API | Microsoft Advertising API v13 — **REST binding** at `campaign.api.bingads.microsoft.com/CampaignManagement/v13/<Entity>/QueryBy…` |
| Auth | OAuth2 Bearer + `DeveloperToken` + `CustomerId` + `CustomerAccountId` headers |
| Consent | Consent Mode v2 partner via UET |

Universal: pixel basics in `02-pixel-foundations.md`; CMv2 in `04-consent-and-cmp.md`.

**SOAP → REST transition:** SOAP is feature-frozen on **October 1, 2026** (new features REST-only)
and fully decommissioned on **January 31, 2027**. This skill's `state platform microsoft` already
uses the REST binding; any custom integrations still on `CampaignManagementService.svc` SOAP
need migrating before the freeze. REST path convention: SOAP operation `Get<Entity>By<X>` →
`POST /<Entity>/QueryBy<X>` with the same JSON body fields.

## Setup

1. Log in at <https://ads.microsoft.com>.
2. Apply for developer token: <https://developers.ads.microsoft.com/Account>. Defaults to Sandbox until approved.
3. Create Azure AD app registration; configure redirect URI; mint OAuth2 tokens.
4. Create UET tag: Tools → Conversion Tracking → UET tag.
5. Install snippet (`templates/pixel-snippets/microsoft.html`).
6. Define Conversion Goals (Destination URL, Event, Duration, Pages Viewed, or Custom).
7. (Optional) Import LinkedIn audiences for B2B targeting (MSAN).

## Conversion taxonomy

UET supports auto-tracked goals + JS-tracked custom events:

- **Goal types (auto)**: Destination URL, Duration on site, Pages Per Visit, Event.
- **Custom Events**: `window.uetq.push('event', 'event_action', { event_category, event_label, event_value, revenue_value, currency })`.
- **Variable revenue**: pass `revenue_value` for ROAS bidding.
- **Offline Conversions** (server-side): CSV with click id, conversion name, time, value, currency.

## Server-side

Microsoft has no real-time CAPI like Meta or TikTok:

- **Offline Conversion Import (UI)**: CSV with `MSCLKID`, conversion name, time, value, currency.
- **Bulk API**: programmatic offline conversions via Bulk service.
- **MSCLKID retention**: capture from `?msclkid=...`, persist to first-party storage / CRM, replay on conversion.

`apply_capi.sh` for `microsoft` produces an offline-conversion CSV builder + Bulk API upload script.

## Consent integration

UET integrates with Consent Mode v2 (Q1 2024+):

```js
window.uetq = window.uetq || [];
window.uetq.push('consent', 'default', { 'ad_storage': 'denied' });
window.uetq.push('consent', 'update', { 'ad_storage': 'granted' });
```

EEA: as of March 2024, Microsoft enforces consent for personalized advertising; conversion modeling fills part of the gap.

## Notable extras

- **LinkedIn audience integration**: major B2B differentiator — LinkedIn profile dimensions overlay the targeting UI.
- **Sandbox vs production developer token**: sandbox doesn't work against production; surface in `doctor`.
- **Customer header**: every API call requires `CustomerId` (numeric); some need `CustomerAccountId`.
- **Bing Webmaster verification**: `<meta name="msvalidate.01" content="...">` at site root.

## Cited URLs

- Get started: <https://learn.microsoft.com/en-us/advertising/guides/get-started>
- Campaign Management v13: <https://learn.microsoft.com/en-us/advertising/campaign-management-service/campaign-management-service-reference>
- UET install: <https://help.ads.microsoft.com/apex/index/3/en/56684>
- UET + Consent Mode: <https://help.ads.microsoft.com/apex/index/3/en/60118>
- Offline Conversion Import: <https://help.ads.microsoft.com/apex/index/3/en/60024>
- Developer token: <https://developers.ads.microsoft.com/Account>
- Bulk service: <https://learn.microsoft.com/en-us/advertising/bulk-service/bulk-service-reference>
- LinkedIn profile targeting: <https://help.ads.microsoft.com/apex/index/3/en/60022>
- ads.txt: not generally required for advertisers
