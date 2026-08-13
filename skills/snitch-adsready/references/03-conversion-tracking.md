# 03 — Conversion tracking

Standard events, custom events, dedup, attribution windows. For per-platform event names + payload schemas, see `references/platforms/<name>.md`.

## Standard events (cross-platform mapping)

| Funnel stage | Google Ads / GA4 | Meta | TikTok | Microsoft | LinkedIn | X | Pinterest | Reddit | Snapchat |
|---|---|---|---|---|---|---|---|---|---|
| Page view | `page_view` | `PageView` | `Pageview` | `pageLoad` | (auto) | `pageView` | `pagevisit` | `PageVisit` | `PAGE_VIEW` |
| Search | `search` | `Search` | `Search` | `search` | n/a | n/a | `search` | `Search` | `SEARCH` |
| View product | `view_item` | `ViewContent` | `ViewContent` | `viewContent` | n/a | `Content View` | `ViewCategory` | `ViewContent` | `VIEW_CONTENT` |
| Add to cart | `add_to_cart` | `AddToCart` | `AddToCart` | `addToCart` | n/a | `Add to cart` | `addtocart` | `AddToCart` | `ADD_CART` |
| Initiate checkout | `begin_checkout` | `InitiateCheckout` | `InitiateCheckout` | `beginCheckout` | n/a | n/a | `checkout` | `Lead` | `START_CHECKOUT` |
| Purchase | `purchase` | `Purchase` | `CompletePayment` | `purchase` | conversion event | `Purchase` | `checkout` | `Purchase` | `PURCHASE` |
| Lead | `generate_lead` | `Lead` | `SubmitForm` | `signupCompleted` | LeadGen Form | `Sign up` | `lead` | `Lead` | `SIGN_UP` |
| Sign up | `sign_up` | `CompleteRegistration` | `CompleteRegistration` | `signupCompleted` | LeadGen Form | `Sign up` | `signup` | `SignUp` | `SIGN_UP` |
| Subscribe | `subscribe` | `Subscribe` | `Subscribe` | `subscribe` | n/a | n/a | `signup` | `Subscribe` | `SUBSCRIBE` |
| Add to wishlist | `add_to_wishlist` | `AddToWishlist` | `AddToWishlist` | n/a | n/a | n/a | n/a | `AddToWishlist` | `ADD_TO_WISHLIST` |

Send the platform's exact name. The `apply_pixel` snippets fire the canonical ones; custom funnel stages use the platform's `track`/`event` API with a custom name.

## Custom events

Beyond standard names, every platform supports a custom event name (e.g., `fbq('trackCustom','TrialStarted',{...})`).

- Smart-bidding optimization typically requires standard events; custom events bid on volume only.
- Pinterest and Snap cap custom names at ~30 chars or strict regex.
- Conversion lookback windows are SHORTER for custom events on most platforms.

## Deduplication

Two valid conversion sources:

1. **Client pixel fire** — browser, captures cookies, click IDs (gclid/fbclid/ttclid).
2. **Server CAPI fire** — backend after the order/lead commits, captures hashed PII, IP, UA.

Dedup field per platform:

| Platform | Dedup field |
|---|---|
| Google Ads (Enhanced) | `transaction_id` + `gclid` |
| GA4 | `transaction_id` |
| Meta / TikTok / Pinterest / X | `event_id` |
| Snap | `client_dedup_id` ↔ CAPI `event_id` |
| LinkedIn | `eventId` |
| Reddit | `conversion_id` |

Use a server-issued UUID per order/lead. Pass to both client (pixel) and server (CAPI).

## Attribution windows

| Platform | Default window | Configurable? |
|---|---|---|
| Google Ads | 30d click + 1d view | yes (data-driven, last-click) |
| Meta | 7d click + 1d view | yes (1d, 7d, 28d historically) |
| TikTok | 7d click + 1d view | yes |
| LinkedIn | 30d click + 7d view | yes (1, 7, 30, 90) |
| Microsoft | 30d | yes (1, 7, 30) |
| Pinterest | 30d click + 1d engagement + 7d view | yes |
| Reddit | 7d click + 1d view | yes |
| Snap | 7d swipe + 1d view | yes |
| X | 1, 7, 14, 30d | yes (per conversion event) |
| Apple Search Ads | n/a — SKAdNetwork conversion-value bits, ~24-48h | no |

Common mistake: comparing two platforms' "purchase" counts and concluding one is wrong. They use different windows + dedup + multi-touch logic. Compare each platform vs your single source of truth (your order DB) — not vs each other.

## See also

- `02-pixel-foundations.md` — init order, dedup overview.
- `04-consent-and-cmp.md` — Consent Mode v2 effects.
- `references/platforms/<name>.md` — exact event names + payload fields.
