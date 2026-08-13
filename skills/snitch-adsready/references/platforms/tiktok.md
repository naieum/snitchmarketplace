# TikTok for Business

| Field | Value |
|---|---|
| Web tag | TikTok Pixel — `ttq` global |
| Identifiers | Pixel id (alphanumeric), advertiser id, app id (BC ID) |
| Server-side | **TikTok Events API** — `business-api.tiktok.com/open_api/v1.3/event/track/` |
| Account model | Business Center → advertiser → campaign → ad group → ad |
| Marketing API | `business-api.tiktok.com/open_api/v1.3` |
| Auth | OAuth2 long-term access token; scopes per-API |
| Consent | Limited Consent Mode v2 partner (LDU + holdConsent/grantConsent) |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Sign up at <https://ads.tiktok.com>.
2. Create / join Business Center.
3. Create developer app: <https://business-api.tiktok.com/portal/apps>.
4. OAuth2 flow — exchange auth code for `access_token` via `/oauth2/access_token/`.
5. Create Pixel: Assets → Events → Web Events → Set Up Web Events → TikTok Pixel.
6. Install snippet (`templates/pixel-snippets/tiktok.html`).
7. (Recommended) Configure Events API for server-side dedup.
8. Set up Standard / Custom Events.

## Conversion taxonomy

Standard events (case-sensitive): `Purchase`, `PlaceAnOrder`, `InitiateCheckout`, `AddPaymentInfo`, `AddToCart`, `AddToWishlist`, `ViewContent`, `ClickButton`, `Search`, `CompleteRegistration`, `Contact`, `Download`, `SubmitForm`, `Subscribe`.

iOS-app: `CompletePayment`, `LaunchAPP`, `Achievement`, `RegistrationApp`.

Recommended properties: `content_id`, `content_type`, `quantity`, `price`, `value`, `currency`, `description`.

## CAPI

- Endpoint: `POST https://business-api.tiktok.com/open_api/v1.3/event/track/`
- Headers: `Access-Token: <token>`, `Content-Type: application/json`.
- Body: `{ "event_source": "web", "event_source_id": "<pixel_id>", "data": [ { "event": "Purchase", "event_time": <unix>, "event_id": "<dedupe-key>", "user": { "email": ["<sha256>"], "phone": ["<sha256>"], "ttclid": "<click-id>", "ttp": "<_ttp>", "ip": "<ip>", "user_agent": "<ua>" }, "properties": { "currency": "USD", "value": 99, "content_id": "SKU-1" } } ] }`
- **Dedup**: same `event_id` between pixel + Events API.
- **TTCLID**: capture from `?ttclid=...`, store first-party, replay in Events API for highest match.

## Consent integration

TikTok Pixel built-in consent helpers:

- `ttq.holdConsent()` — defer ALL events until grant.
- `ttq.grantConsent()` — release queued events.
- `ttq.revokeConsent()` — block all subsequent.
- **LDU**: `data_processing_options: ["LDU"]` per Events API call (CCPA / state laws). Pixel: `ttq.setLDUMode()` (newer SDK).
- Consent Mode v2: limited integration (2024) — check Pixel Diagnostics.

## Audiences + targeting

- **Custom Audiences**: hashed email/phone/IDFA upload via `/dmp/custom_audience/create/`.
- **Lookalike**: from custom audience or pixel event.
- **Engagement Audiences**: video-view (10s, 25%, 50%, 75%, 95%, 100% completion) — TikTok-distinctive given video-first surface.
- **Spark Ads**: native ad format using existing organic posts; conversion still flows through pixel/CAPI.

## Notable extras

- **Advanced Matching**: pass hashed `email` / `phone` in `ttq.identify({ email: '...', phone: '...' })` after init.
- **Video-view audiences**: 25%-completion is TikTok's most predictive engagement signal.
- **iOS app installs**: SKAdNetwork + TikTok SDK.

## Cited URLs

- Marketing API portal: <https://business-api.tiktok.com/portal/docs>
- Events API: <https://business-api.tiktok.com/portal/docs?id=1727541103358977>
- Pixel install: <https://ads.tiktok.com/help/article/standard-events-parameters>
- Standard events: <https://business-api.tiktok.com/portal/docs?id=1739585702826497>
- Authentication: <https://business-api.tiktok.com/portal/docs?id=1738373164380162>
- LDU: <https://business-api.tiktok.com/portal/docs?id=1771101027431425>
- ads.txt (Pangle publishers only): `tiktok.com, <pub-id>, DIRECT, <tag-id>` — not for advertisers
