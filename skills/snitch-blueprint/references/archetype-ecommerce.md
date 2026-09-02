# Archetype: E-commerce

Anything bought through a catalog, cart, and checkout, whatever is being sold. The
archetype where build mistakes are most literally measurable: every checkout-flow decision
is a conversion-rate decision.

## The platform decision comes first

Custom-building cart/checkout/tax/fraud for a small catalog is almost always the wrong
build. The blueprint forces the honest question: hosted platform (Shopify-class), platform
+ headless front end, or truly custom (needs a reason — usually catalog logic the platform
can't express). On a hosted platform this archetype scopes to what the merchant controls:
theme, content, product data, schema, apps discipline. Record the decision and the reason;
"custom because we're developers" is a recorded decision too — just an expensive one.

## Decisions this archetype forces (from the interview)

- **Catalog structure before pages.** Real variant axes (size/color) vs. separate
  products; collection taxonomy from how buyers shop (by use, by recipient, by price band),
  not from internal inventory categories. Restructuring URLs after launch costs redirects
  and rank; taxonomy is a day-one decision.
- **Fulfillment truths.** Shipping regions, costs, times, returns window — decided and
  written before checkout exists, because surprise costs at checkout are the single
  largest documented abandonment cause. The blueprint's rule: **every cost a buyer will
  pay is visible before checkout begins.** Free-shipping threshold, if any, is a decided
  number displayed early, not a checkout surprise in reverse.
- **Photography reality.** Pages that need photos the business doesn't have go DEFERRED
  behind a photography line item in the build order. Placeholder or AI-invented product
  imagery fails the decisions gate (it's a fabricated claim about the product).

## Conversion action

**Completed purchase**, instrumented as a proper e-commerce event stream from day one
(view item → add to cart → begin checkout → purchase, with values). Rank-2: email capture
— the archetype's compounding asset — offered honestly (a real discount or real content,
timed after engagement, never an entry-blocking modal; exit-intent at most).

## Surface inventory and build order

1. **Product page template** — the money surface; the homepage is marketing, the product
   page is the store. Spec: photos (multiple angles, zoom, in-context); price + variant
   picker with per-variant availability; the buy box above the fold at 360px; shipping and
   returns *on the product page* (a link to a policy page is where conversions die);
   honest reviews when they exist — none yet means no stars section, per the claim
   inventory, and never invented `aggregateRating` schema (a manual-action risk);
   description written for the buyer's decision, not the manufacturer's spec sheet.
2. **Collection page template** — scannable grid, honest badges only ("bestseller"
   requires sales data), filters that match the real variant axes.
3. **Cart + checkout** — platform-default checkout unless there's a recorded reason.
   Guest checkout mandatory; account creation offered *after* purchase. Every field
   justified; address autocomplete; express wallets (Apple/Google Pay) if the platform
   offers them. Ethics gate applies with teeth here: no pre-checked add-ons, no fake
   countdown timers, no invented "3 left!" scarcity — real inventory counts are fine.
4. **Homepage** — job: establish what the store sells, for whom, and route to the top 2-3
   collections. Compressed CLOSER: category clarity beats brand poetry at launch.
5. **Policy pages** (shipping, returns, privacy, terms) — required by payment processors
   and ad platforms alike; content comes from the fulfillment-truths decisions.
6. **About/brand page** — trust for a first-time buyer of an unknown brand.
7. **DEFERRED by default:** blog/content marketing, loyalty program, gift cards,
   subscriptions, international/multi-currency (each with a trigger — e.g. international:
   consistent overseas order inquiries).

## Day-one wiring (beyond build-defaults.md)

- `Product` schema with `offers` (price, currency, availability) per product; `Review`
  schema only when reviews are real.
- The e-commerce event stream named in the blueprint (it is snitch-adsready's prerequisite —
  every ad platform's ROAS math sits on these events).
- Product feed hygiene from the start: titles, GTINs/SKUs, image specs — the feed is the
  product page's machine-readable twin and ad platforms read the feed, not the page.
- Transactional email (order confirmation, shipping) via the platform default; marketing
  email capture wired to an actual list with a real welcome send.
- Inventory truth: whatever shows availability renders from real stock state.

## Handoffs

snitch-adsready before the first ad dollar (pixels, CAPI, consent, feed diagnostics);
snitch-marketing for the launched store (category/product SEO depth); snitch-ux if checkout
or product-page conversion underperforms; snitch-focusedcopy for landing pages built for
specific campaigns.
