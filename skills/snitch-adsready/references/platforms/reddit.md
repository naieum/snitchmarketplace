# Reddit Ads

| Field | Value |
|---|---|
| Web tag | Reddit Pixel — `rdt` global |
| Identifiers | Pixel id (advertiser id, e.g., `a2_xxxxxxxxxxxx`), ad account id |
| Server-side | **Reddit CAPI** — `ads-api.reddit.com/api/v3/conversions/events/<advertiser-id>` |
| Account model | Account → ad account → campaign → ad group → ad |
| Marketing API | `ads-api.reddit.com/api/v3` |
| Auth | OAuth2; scopes `adsread`, `adsedit` |
| Consent | Not a CMv2 partner; gate via CMP |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Open Reddit Ads at <https://ads.reddit.com>.
2. Create app: <https://www.reddit.com/prefs/apps> (script type for personal, web for delegated).
3. OAuth2 flow against `https://www.reddit.com/api/v1/access_token`.
4. Create Pixel: Events Manager → Pixel → Create new Pixel.
5. Install snippet (`templates/pixel-snippets/reddit.html`).
6. Configure Conversion Events.
7. (Recommended) Implement Reddit CAPI — newer (GA late 2023) but increasingly important.

## Conversion taxonomy

Standard events: `PageVisit`, `ViewContent`, `Search`, `AddToCart`, `AddToWishlist`, `Purchase`, `Lead`, `SignUp`, `Custom`.

Recommended properties: `value`, `currency`, `itemCount`, `transactionId`, `products` (array of `{ id, name, category }`).

## CAPI

- Endpoint: `POST https://ads-api.reddit.com/api/v3/custom_audiences/conversion_events/<advertiser_id>`
- Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`, `User-Agent: <your-app>/1.0`.
- Body: `{ "events": [ { "event_at": "<ISO8601>", "event_type": { "tracking_type": "Purchase" }, "click_id": "<rdt-click-id>", "event_metadata": { "currency": "USD", "value_decimal": 99.00, "item_count": 1, "products": [{ "id": "SKU-1", "name": "Foo", "category": "bar" }] }, "user": { "email": "<sha256>", "external_id": "<sha256>", "ip_address": "<ip>", "user_agent": "<ua>", "rda": "<reddit-device-advertiser-id>" } } ] }`
- **RDT click id**: query param `?rdt_cid=<id>`.
- **Dedup**: pass `conversion_id`; ensure pixel + CAPI emit the same value.

## Consent integration

Gate `www.redditstatic.com/ads/pixel.js` load behind CMP. Reddit Pixel has no runtime consent API.

## Audiences + targeting

- **Custom Audiences**: hashed email upload.
- **Lookalike**: from custom audience.
- **Subreddit targeting**: target by subreddit subscription / engagement (Reddit-distinctive).
- **Interest targeting**: Reddit-curated affinity.
- **Engagement audiences**: from upvotes / comments / shares on promoted posts.

## Notable extras

- **Conversion windows**: Redditors research before buying. Default 7d-click / 1d-view often under-credits; widen to 28d-click / 7d-view if funnel supports.
- **Promoted Posts vs Standard Ads**: Promoted Posts (organic-style) tend to have higher engagement → cheaper CPM.
- **API rate limits**: 600 RPM per OAuth client (lower than peers); space out batch uploads.

## Cited URLs

- Reddit Ads API v3: <https://ads-api.reddit.com/docs/v3/>
- OAuth2: <https://ads-api.reddit.com/docs/v3/oauth2/>
- Conversions API: <https://ads-api.reddit.com/docs/v3/conversions/>
- Pixel install: <https://business.reddithelp.com/s/article/install-the-reddit-pixel-on-your-website>
- ads.txt: not required for advertisers
