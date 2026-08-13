# Pinterest Ads

| Field | Value |
|---|---|
| Web tag | Pinterest Tag — `pintrk` global |
| Identifiers | Tag id (numeric, ~12 digits), ad account id |
| Server-side | **Pinterest Conversions API** — `api.pinterest.com/v5/ad_accounts/<id>/events` |
| Account model | Business → ad account → campaign → ad group → Promoted Pin |
| Marketing API | `api.pinterest.com/v5` |
| Auth | OAuth2; scopes `ads:read`, `ads:write`, `pins:read`, `user_accounts:read`, `catalogs:read` |
| Consent | Not a CMv2 partner; supports Enhanced Match (hashed PII) |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Convert / create a Pinterest **business** account: <https://business.pinterest.com>.
2. Apply for ads access; configure billing.
3. Create developer app at <https://developers.pinterest.com>; OAuth2 flow.
4. Create Pinterest Tag: Ads → Conversions → Tag manager → Create.
5. Install snippet (`templates/pixel-snippets/pinterest.html`).
6. Configure Standard / Custom Events.
7. (Optional) Set up Conversions API for server-side dedup + iOS 14.5+ resilience.
8. Submit a **product catalog** for Catalog / Shopping ads.

## Conversion taxonomy

Standard events (lowercase): `pagevisit`, `viewcategory`, `search`, `addtocart`, `checkout`, `signup`, `lead`, `watchvideo`, `custom`.

Required + recommended properties: `value`, `order_quantity`, `order_id`, `currency`, `line_items` (array of `{ product_name, product_id, product_category, product_quantity, product_price }`).

## CAPI

- Endpoint: `POST https://api.pinterest.com/v5/ad_accounts/<account-id>/events`
- Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`.
- Body: `{ "data": [ { "event_name": "checkout", "action_source": "web", "event_time": <unix>, "event_id": "<dedupe-key>", "event_source_url": "https://...", "user_data": { "em": ["<sha256>"], "ph": ["<sha256>"], "client_ip_address": "<ip>", "client_user_agent": "<ua>", "click_id": "<epik>" }, "custom_data": { "currency": "USD", "value": "99.00", "content_ids": ["SKU-1"] } } ] }`
- **EPIK click id**: capture from `?epik=...`.
- **Dedup**: matching `event_id` + `event_name` + `event_time` (within 48h) between Pixel + CAPI.

## Consent integration

Pinterest has no runtime consent API:

- Gate `s.pinimg.com/ct/core.js` load behind CMP `marketing` category.
- CAPI: advertiser-side gating; only consent users.
- **Enhanced Match** (hashed email/phone) is the recommended ID-resilience play for iOS / 3PCD — `pintrk('load', '<id>', { em: '<sha256>' })`.

## Audiences + targeting

- **Customer List**: hashed email upload.
- **Engagement audiences**: from Pin saves / clicks / outbound clicks (Pinterest-distinctive).
- **Actalike**: Pinterest's lookalike (1-10%).
- **Visitor audiences**: from website tag.
- **Catalog-driven**: dynamic retargeting via Catalog feeds.

## Notable extras

- **Visual conversions**: a "save" (user pinning your image) is a conversion-eligible event distinct from click. Configure carefully to avoid inflating CPA.
- **Product catalog feed**: required for Shopping ads. TSV / CSV / XML; updated daily.
- **Idea Pin / Video Pin**: track `watchvideo` event with `video_view_threshold` property.
- **Verification meta**: `<meta name="p:domain_verify" content="...">` required for Pin claiming.

## Cited URLs

- API v5: <https://developers.pinterest.com/docs/api/v5/>
- Conversions API: <https://developers.pinterest.com/docs/api/v5/conversion-events>
- Tag install: <https://help.pinterest.com/en/business/article/install-the-pinterest-tag>
- Tag reference: <https://developers.pinterest.com/docs/web-features/conversion-tracking/>
- Catalog feed: <https://help.pinterest.com/en/business/article/product-catalog-feed>
- ads.txt: not generally required
