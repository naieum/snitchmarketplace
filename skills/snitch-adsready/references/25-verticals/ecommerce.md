# 25 — Vertical: ecommerce

## Standard event suite

Every ecommerce site should fire (and dedup via CAPI) at minimum:

| Funnel stage | Event |
|---|---|
| View product page | `view_item` (GA4) / `ViewContent` (Meta, TikTok, Pinterest) |
| Add to cart | `add_to_cart` / `AddToCart` |
| Initiate checkout | `begin_checkout` / `InitiateCheckout` |
| Add payment info | `add_payment_info` |
| Add shipping info | `add_shipping_info` |
| Purchase | `purchase` / `Purchase` (Meta) / `CompletePayment` (TikTok) |
| Refund | `refund` |

Ship standard ecommerce parameters: `value`, `currency`, `transaction_id`, `items[]` with `item_id`, `item_name`, `category`, `quantity`, `price`.

## Catalog / product feed

| Platform | Catalog | Format |
|---|---|---|
| Google | Merchant Center | XML, Atom feed, Google Sheets, or Content API |
| Meta | Catalog | CSV, XML, TSV, or Catalog Sync |
| TikTok | Catalog | CSV, XML, or Shopify/Magento integration |
| Pinterest | Catalog | CSV, XML |
| Snapchat | Catalog | CSV, XML |
| Microsoft | Microsoft Merchant Center | similar to Google MC |

Shopify users: native channel apps sync the catalog automatically. WooCommerce: Pixel Manager + a feed plugin.

## Schema.org for ecommerce

The feed reads this, so it is in scope here. Required on a product page:
- `Product` (one per product page) — see `templates/structured-data/product.starter.json`
- `Offer` (nested in Product) with price, currency, availability, `priceValidUntil`
- `MerchantReturnPolicy` and `OfferShippingDetails` where the target market mandates disclosure
- `AggregateRating` + `Review` only where real review data backs them

`07-structured-data.md` has the field-by-field reasons. Every other schema type on the site
(BreadcrumbList, Organization, WebSite, Article) is a search surface: **call the Skill tool with
"snitch-marketing"**. Validate product templates in Merchant Center Diagnostics after the next
crawl, and in the Rich Results Test before deploy.

## Pixel deduplication is critical

Ecommerce conversions are valuable enough that double-counting skews bidding wildly:

- Server emits `transaction_id` (or UUID per order) and passes to client BEFORE success page renders.
- Client pixel includes the same value.
- CAPI server-side stub uses the SAME id.

The `templates/capi-stubs/<platform>/<lang>.template` stubs all parameterize this.

## Common ecommerce-specific failures

| Symptom | Cause |
|---|---|
| Purchase events missing for guest checkout | Pixel tied to logged-in state; fire on order success regardless |
| Cart abandonment events fire 5x | Fired on every cart-modal open instead of actual abandonment |
| Revenue in Meta != revenue in Stripe | Currency conversion in Meta UI; or value passed in cents instead of dollars |
| Refunds not subtracting | No `refund` event fired; manually backfill or wire via webhook |
| iOS conversions disappeared | ATT decline + no CAPI for iOS install attribution |
| AOV trending wrong | Coupons / discounts not subtracted from `value`; pass net not gross |

## Honest pricing on platforms

- Shopify users: native pixel apps + checkout extension is the path of least resistance. Don't reinvent.
- Headless commerce (Hydrogen, NextCommerce, Saleor): `templates/capi-stubs/<platform>/node.template` apply directly.
- WooCommerce: PixelYourSite Pro is the realistic plug-in path; manual snippet works but breaks on plugin updates.

## Spend allocation framing

A smaller advertiser running ALL TEN platforms badly often does worse than running 3 platforms well. The skill surfaces readiness — the user picks which 2-4 to focus on.

Typical ecommerce starter mix: Google Shopping + Meta + TikTok. Add Pinterest for visual products, Snap for younger demos, LinkedIn only if B2B.
