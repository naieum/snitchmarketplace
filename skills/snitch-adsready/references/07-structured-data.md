# 07 — Product / Offer markup as a feed prerequisite

Read when a Shopping / catalog campaign needs product data off the page. This skill covers only
the structured data an ad platform itself consumes: `Product` + `Offer` markup that a shopping
feed is built from or validated against. Everything else schema-shaped — Organization, WebSite,
BreadcrumbList, Article, FAQ, rich-result eligibility, schema as an AI-search play — is
evidenced against search, not against an ad platform: **call the Skill tool with
"snitch-marketing"**.

## Which platforms read it

| Platform | What consumes the markup |
|---|---|
| Google Shopping / Performance Max | Merchant Center. Automatic feeds and the crawl-based refresh read `Product`/`Offer` off the page; a website feed is built from it outright |
| Microsoft Shopping | Microsoft Merchant Center, same shape as Google's |
| Meta / Pinterest / TikTok catalogs | a microdata/JSON-LD pixel crawl can populate or repair a catalog when the primary feed is absent or stale |

If the merchant uploads a complete, current feed by file or API and never relies on a crawl,
on-page markup is not an ads blocker. Say so as a Skip with that reason instead of raising it.

## The fields the feed cares about

`templates/structured-data/product.starter.json` carries the full shape. The fields a
disapproval usually traces back to:

| Field | Why the feed needs it |
|---|---|
| `offers.price` + `offers.priceCurrency` | a price mismatch between page and feed is the most common item disapproval |
| `offers.availability` | out-of-stock items served as in-stock get the account flagged |
| `offers.priceValidUntil` | a lapsed date drops the item on the next crawl |
| `sku` / `mpn` / `gtin13` | the identifiers that match an item to the catalog; a wrong GTIN blocks the item |
| `offers.shippingDetails` | required for Shopping items in the markets that mandate shipping disclosure |
| `offers.hasMerchantReturnPolicy` | required alongside shipping in those same markets |
| `brand` | matching and brand-restriction checks |
| `image` | catalog thumbnails; at least one absolute, crawlable URL |

## Common failures that cost impressions

1. Price rendered client-side, so the crawler reads a placeholder while the feed reads the real
   price. Item disapproved for mismatch.
2. `priceValidUntil` in the past.
3. `availability` hardcoded to `InStock` in the template.
4. Two `Product` blocks on one page (variant plus parent) with no `@id` to distinguish them.
5. Currency mismatch between the markup and the Merchant Center target country.
6. Wrong `@type` case — Schema.org is case-sensitive.

## Verification

| Tool | URL |
|---|---|
| Merchant Center → Diagnostics (item-level disapprovals) | https://merchants.google.com/ |
| Google Rich Results Test (parses the block) | https://search.google.com/test/rich-results |
| Schema.org Validator (type / property correctness) | https://validator.schema.org/ |

`state site <url> structured-data` reports the `@type` values found; check that `Product` and
`Offer` appear on product pages before blaming the feed.

## See also

- `templates/structured-data/product.starter.json` — the drop-in starter `fix structured-data` renders.
- `references/setup/structured-data.md` — the stepped walkthrough.
- `references/25-verticals/ecommerce.md` — catalog and feed expectations for the vertical.
- Google product structured data: https://developers.google.com/search/docs/appearance/structured-data/product
