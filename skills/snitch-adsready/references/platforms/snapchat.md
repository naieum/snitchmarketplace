# Snapchat Ads

| Field | Value |
|---|---|
| Web tag | Snap Pixel — `snaptr` global |
| Identifiers | Pixel id (UUID-style), ad account id |
| Server-side | **Snap Conversions API** — `tr.snapchat.com/v3/<pixel-id>/events?token=<token>` |
| Account model | Business → ad account → campaign → ad squad → ad |
| Marketing API | `adsapi.snapchat.com/v1` |
| Auth | OAuth2; scope `snapchat-marketing-api` |
| Consent | Not a CMv2 partner; supports advanced matching |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Sign up at <https://ads.snapchat.com>.
2. Create / join Business Manager: <https://business.snapchat.com>.
3. Create developer app at <https://kit.snapchat.com>.
4. OAuth2 flow against `https://accounts.snapchat.com/login/oauth2/access_token`.
5. Create Pixel: Events Manager → Pixels → Create.
6. Install snippet (`templates/pixel-snippets/snapchat.html`).
7. Configure Standard Events.
8. (Recommended) Set up CAPI for iOS 14.5+ resilience — Snap's audience is heavily iOS, ATT impact is severe without server events.

## Conversion taxonomy

Standard events (UPPERCASE_SNAKE_CASE): `PAGE_VIEW`, `VIEW_CONTENT`, `SEARCH`, `ADD_CART`, `ADD_BILLING`, `START_CHECKOUT`, `PURCHASE`, `SIGN_UP`, `SUBSCRIBE`, `COMPLETE_TUTORIAL`, `INVITE`, `LOGIN`, `SHARE`, `RESERVE`, `ACHIEVEMENT_UNLOCKED`, `ADD_TO_WISHLIST`, `SPENT_CREDITS`, `RATE`, `START_TRIAL`, `LIST_VIEW`, `AD_CLICK`, `AD_VIEW`, `APP_OPEN`, `APP_INSTALL`.

Recommended properties: `currency`, `price`, `transaction_id`, `item_ids`, `item_category`, `description`, `search_string`, `number_items`.

## CAPI

- Endpoint: `POST https://tr.snapchat.com/v3/<pixel_id>/events?token=<long_lived_token>`
- Body: `{ "data": [ { "event_name": "PURCHASE", "event_time": <unix>, "event_id": "<dedupe-key>", "event_source_url": "https://...", "user_data": { "em": ["<sha256>"], "ph": ["<sha256>"], "sc_click_id": "<click-id>", "sc_cookie1": "<_scid>", "client_ip_address": "<ip>", "client_user_agent": "<ua>", "external_id": ["<sha256>"] }, "custom_data": { "currency": "USD", "value": "99.00", "content_ids": ["SKU-1"] }, "action_source": "website" } ] }`
- **sc_click_id**: capture from `?sccid=...`.
- **Dedup**: same `event_id` between pixel + CAPI.
- **Long-lived token**: generate in Events Manager → Conversions API → Generate Token (separate from OAuth2 token used for Marketing API).

## Consent integration

Snap Pixel has no runtime consent API:

- Gate `sc-static.net/scevent.min.js` load behind CMP `marketing` category.
- CAPI: advertiser-side gating.

## Audiences + targeting

- **Custom Audiences**: hashed email/phone/IDFA upload via `/segments`.
- **Lookalike**: from custom audience or pixel audience.
- **Interest categories**: Snap-curated lifestyle segments (heavy on Gen-Z affinities).
- **AR Lens audiences**: from users who interacted with brand AR Lens (Snap-distinctive).
- **Mobile App Custom Audiences**: from in-app events via Snap App SDK / MMP.

## Notable extras

- **AR-aware conversions**: AR Lens engagement → click → purchase funnel; lens engagement events can become custom audiences.
- **Mobile-app installs**: top app-install channel — SKAdNetwork postbacks (iOS) + Snap App SDK / MMP (Adjust / AppsFlyer / Singular).
- **iOS ATT impact**: severe on Snap — without ATT, attribution is SKAdNetwork-only (aggregate). CAPI helps web-side measurement.
- **28-day swipe / 1-day view** default attribution on retail.

## Cited URLs

- Snap Marketing API: <https://marketingapi.snapchat.com/docs/>
- Conversions API: <https://marketingapi.snapchat.com/docs/conversion.html>
- Snap Pixel: <https://businesshelp.snapchat.com/s/article/snap-pixel-about>
- Standard events: <https://businesshelp.snapchat.com/s/article/standard-events>
- OAuth2: <https://marketingapi.snapchat.com/docs/#authentication>
- Long-lived CAPI token: <https://businesshelp.snapchat.com/s/article/snap-pixel-conversions-api>
- ads.txt: not required for advertisers
