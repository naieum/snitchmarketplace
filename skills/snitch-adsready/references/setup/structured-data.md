# Setup — Product / Offer markup for a shopping feed

Walkthrough for `setup structured-data`. Goal: ship `Product` + `Offer` JSON-LD that a Merchant
Center / catalog crawl can read without disapproving the item.

Scope check first. This area exists because ad platforms consume `Product`/`Offer`. Organization,
WebSite, BreadcrumbList, Article, FAQ, rich results, and schema-for-AI-search are a search
surface, not an ads one — **call the Skill tool with "snitch-marketing"** for those.

## Pre-checks

1. **Is there a catalog at all?** No products, no feed, no Shopping / catalog campaign planned →
   Skip with that reason; nothing here applies.
2. **Is the feed crawl-dependent?** A complete file or API feed that never falls back to a crawl
   makes on-page markup optional. Ask before proposing work.
3. **Run `bash ads-ready.sh state site <product-url> structured-data`.** Reports the `@type`
   values already present on the page.
4. **Gather the item data source:** where price, availability, GTIN/SKU, shipping, and return
   policy come from at build or request time. Markup that is not generated from that source
   drifts within a week.

## Steps

### 1. Confirm the target market's required fields (manual)

Shipping and return-policy disclosure is mandatory for Shopping items in some markets and
optional in others. Check the Merchant Center requirements for the countries being targeted
before deciding whether `shippingDetails` and `hasMerchantReturnPolicy` are blockers or
nice-to-have.

### 2. Apply the Product / Offer starter (auto)

```bash
bash ads-ready.sh fix structured-data ecommerce
```

The `ecommerce` argument is what asserts a catalog exists. Without it the apply step infers the
vertical from `detect`, and warns `not-applicable` instead of emitting anything when detect found
no catalog signal — pass the argument once pre-check 1 has confirmed there is a catalog.

The apply step reads `templates/structured-data/product.starter.json`, and emits
`=== FILE/DIFF/CONTENT ===` with every `{{PLACEHOLDER}}` left in place. Placeholders are the
point: bind each one to the product record at build or render time rather than typing values.
A literal price in a template is a disapproval waiting for the next price change.

### 3. Bind the placeholders to the product source (manual)

| Placeholder | Bind to |
|---|---|
| `{{PRICE}}`, `{{CURRENCY_ISO}}` | the same field the checkout charges from |
| `{{PRICE_VALID_UNTIL}}` | a rolling date computed at build, never a literal |
| `{{SKU}}`, `{{MPN}}`, `{{GTIN13}}` | the catalog identifiers already used in the feed |
| `{{SHIPPING_COST}}`, `{{COUNTRY_ISO}}` | the shipping table for the target market |
| `{{RATING_VALUE}}`, `{{REVIEW_COUNT}}` | real aggregate review data, or delete the block |

Delete any block with no real data behind it. Invented ratings are a policy violation, not a
formatting problem.

### 4. Validate (external-tool)

| Tool | URL | What it checks |
|---|---|---|
| Merchant Center → Diagnostics | https://merchants.google.com/ | item-level disapprovals after the next crawl |
| Google Rich Results Test | https://search.google.com/test/rich-results | the block parses and required fields resolve |
| Schema.org Validator | https://validator.schema.org/ | type / property correctness |

### 5. Re-run the slice (auto)

```bash
bash ads-ready.sh state site <product-url> structured-data
```

`.structured_data.types` should list `Product` (and `Offer` where the parser surfaces nested
types). Then confirm price and availability in the markup match the feed for the same item.

## See also

- `07-structured-data.md` — which platforms read the markup and the field-by-field reasons.
- `templates/structured-data/product.starter.json` — the starter this step renders.
- Google product structured data: https://developers.google.com/search/docs/appearance/structured-data/product
