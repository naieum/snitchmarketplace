# X (Twitter) Ads

| Field | Value |
|---|---|
| Web tag | X Universal Website Tag — `twq` (a.k.a. "X Pixel") |
| Identifiers | Pixel id (lowercase alphanumeric, ~6 chars), Ads account id |
| Server-side | **X Ads CAPI** — `ads-api.x.com/12/measurement/conversions/<account-id>` |
| Account model | X Account → Ads account → campaign |
| Marketing API | `ads-api.x.com/12` (REST) |
| Auth | **OAuth 1.0a** (consumer key/secret + access token/secret); bearer alone insufficient for most Ads endpoints |
| Consent | NOT a Consent Mode v2 partner — gate via CMP |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Apply for X Ads at <https://ads.x.com>.
2. Apply for X Ads API: <https://developer.x.com/en/docs/x-ads-api/getting-started>. Approval gated, can take weeks.
3. Create developer app at <https://developer.x.com/en/portal/dashboard>; enable OAuth 1.0a.
4. Create Pixel: Tools → Conversion Tracking → Create new website tag.
5. Install snippet (`templates/pixel-snippets/x.html`).
6. Configure Conversion Events: Tools → Conversion Tracking → Add new event.
7. (Recommended) Implement CAPI for deduplicated server events.

## Conversion taxonomy

Event types: `Purchase`, `Sign Up`, `Site Visit`, `Page View`, `Custom`, `Add To Cart`, `Add To Wishlist`, `Subscribe`, `Start Trial`, `Initiate Checkout`, `Add Payment Info`, `Search`, `View Content`, `Lead`, `Complete Registration`, `Contact`, `Customize Product`, `Donate`, `Find Location`, `Schedule`, `Submit Application`.

Set event-type when creating in the Ads UI; pass `tw-sale-amount` and `twclid` for purchase value attribution.

## CAPI

- Endpoint: `POST https://ads-api.x.com/12/measurement/conversions/<account_id>`
- Auth: OAuth 1.0a signed request.
- Body: `{ "conversions": [ { "conversion_time": "<ISO8601>", "event_id": "tw-pixel-event-id", "identifiers": [ { "twclid": "<click-id>" }, { "hashed_email": "<sha256>" } ], "number_items": 1, "price_micros": 9900000, "currency": "USD", "conversion_id": "<dedupe-key>" } ] }`
- **TWCLID**: capture from `?twclid=...` — primary match identifier.
- **Dedup**: same `conversion_id` between pixel + CAPI.

## Consent integration

X has no runtime consent API on the pixel:

- Gate `static.ads-twitter.com/uwt.js` load behind CMP `marketing` category.
- For CAPI: only send when consented; X's API doesn't enforce a consent flag.

## Audiences + targeting

- **Custom (Tailored) Audiences**: hashed email / phone / X handle list upload.
- **Web-Based**: from pixel events.
- **Engager Audiences**: from on-platform engagement (likes, replies, follows).
- **Keyword targeting**: target by tweets / searches matching keywords (X-distinctive).
- **Conversation Topics**: target users active in specific ongoing conversations.

## Notable extras

- **OAuth 1.0a complexity**: most engineers expect bearer-only auth; almost all writes + most reads require OAuth 1.0a HMAC-SHA1. Skill includes inline signer in `lib/platforms/x.sh`. Confirm with `state platform x` that the signature path works.
- **Conversion expiry windows**: configurable per-event 1d / 7d / 14d post-engagement. Shorter-window-first vs. Meta's 7d/1d default.
- **API access tier**: X Ads API gated — Free / Basic does NOT include Ads API. Pro tier or Ads-API approval required.

## Cited URLs

- X Ads API: <https://developer.x.com/en/docs/x-ads-api>
- Getting started: <https://developer.x.com/en/docs/x-ads-api/getting-started>
- Conversions API: <https://developer.x.com/en/docs/x-ads-api/measurement/api-reference/conversions>
- Pixel install: <https://business.x.com/en/help/campaign-measurement-and-analytics/conversion-tracking-for-websites>
- Custom audiences: <https://developer.x.com/en/docs/x-ads-api/audiences/api-reference/custom-audiences>
- OAuth 1.0a: <https://developer.x.com/en/docs/authentication/oauth-1-0a>
- ads.txt: not generally required for advertisers
