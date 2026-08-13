# Meta (Facebook + Instagram + WhatsApp + Messenger)

| Field | Value |
|---|---|
| Web tag | Meta Pixel (`fbq`) |
| Identifiers | Pixel id (15-16 digits), App ID, Ad Account `act_<digits>`, Business Manager id |
| Server-side | **Conversions API (CAPI)** — `graph.facebook.com/<pixel-id>/events` |
| Account model | Business Manager → ad account → campaign → ad set → ad |
| Marketing API | `graph.facebook.com/v21.0` |
| Auth | OAuth2 user/page/system-user tokens; `appsecret_proof` strongly recommended |
| Consent | NOT a Google Consent Mode v2 partner — uses `fbq('consent', ...)` |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Create Business Manager at <https://business.facebook.com>.
2. Create / claim Pixel: Events Manager → Connect Data Sources → Web.
3. Create system user under Business Settings → Users → System Users; assign Pixel + Ad Account.
4. Mint long-lived access token.
5. (Recommended) Generate `appsecret_proof = HMAC-SHA256(access_token, app_secret)` and pass on every API call.
6. Install pixel snippet (`templates/pixel-snippets/meta.html`); fire standard events.
7. Set up CAPI for deduplicated events; pair each browser event with a CAPI event using same `event_id`.
8. Configure Aggregated Event Measurement (AEM) priorities (8 events max per domain) for iOS 14.5+ ATT.

## Conversion taxonomy

Standard events: `PageView`, `ViewContent`, `Search`, `AddToCart`, `AddToWishlist`, `InitiateCheckout`, `AddPaymentInfo`, `Purchase`, `Lead`, `CompleteRegistration`, `Contact`, `CustomizeProduct`, `Donate`, `FindLocation`, `Schedule`, `StartTrial`, `SubmitApplication`, `Subscribe`.

Custom events require manual configuration as a custom conversion before they're usable for optimization.

## CAPI

- Endpoint: `POST https://graph.facebook.com/v21.0/<pixel-id>/events?access_token=<TOKEN>&appsecret_proof=<PROOF>`
- Body: `{ "data": [ { "event_name": "Purchase", "event_time": <unix>, "event_id": "<dedupe-key>", "action_source": "website", "user_data": { "em": ["<sha256>"], "ph": ["<sha256>"], "client_ip_address": "<ip>", "client_user_agent": "<ua>", "fbp": "<fbp>", "fbc": "<fbc>" }, "custom_data": { "currency": "USD", "value": 99.0 } } ] }`
- **Event Match Quality (EMQ)** ≥7/10 target. Strongest: hashed email + phone + external_id + fbp + fbc + IP + UA.
- **Dedup**: same `event_id`, `event_name`, `event_time` within 24h between pixel and CAPI.
- **Test events**: Events Manager Test Events tab with `test_event_code` field.

## Consent integration

1. `fbq('consent', 'grant')` / `fbq('consent', 'revoke')` — controls subsequent events.
2. **Limited Data Use (LDU)**: `fbq('dataProcessingOptions', ['LDU'], <country>, <state>)` — California / state laws.
3. CAPI: pass `data_processing_options: ["LDU"]` per event for LDU.

## Notable extras

- **Pixel-CAPI dedup**: #1 thing to get right. Audit at Events Manager → Diagnostics → "Browser and Server events without deduplication".
- **AAM (Automatic Advanced Matching)**: Events Manager → Settings → Automatic Advanced Matching.
- **iOS 14.5+ ATT**: app campaigns require SKAdNetwork; AEM caps web to 8 conversion events per domain.
- **Domain verification**: required to publish AEM events (Business Settings → Brand Safety → Domains).

## Cited URLs

- Marketing API: <https://developers.facebook.com/docs/marketing-api/get-started>
- Conversions API: <https://developers.facebook.com/docs/marketing-api/conversions-api/>
- CAPI parameters: <https://developers.facebook.com/docs/marketing-api/conversions-api/parameters>
- Meta Pixel: <https://developers.facebook.com/docs/meta-pixel/reference>
- AEM: <https://www.facebook.com/business/help/721422165168355>
- System User tokens: <https://developers.facebook.com/docs/marketing-api/system-users>
- ads.txt entry (FAN publishers only): `facebook.com, <pub-id>, DIRECT, c3e20eee3f780d68`
