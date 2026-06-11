## CATEGORY 34: Product schema

`Product` schema with `Offer` (price + availability) is the single highest-CTR rich result Google offers e-commerce. With it: price, stock, rating in SERP. Without it: a plain blue link competing against competitors who have schema.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify product pages (cross-reference Cat 5 page-type detection, `/product/`, `/p/`, `/products/`, "add to cart" text, e-commerce framework like Shopify).
2. `Grep` for `"@type": "Product"`, `Offer`, `AggregateRating`. Quote each match.
3. For each product page: confirm Product schema exists AND has required fields (`name`, `image`, `offers` with `price` + `priceCurrency` + `availability`).

**Crawl mode, required tool calls:**

1. `Fetch` product URL. Parse JSON-LD. Quote Product blocks.
2. Validate required fields per Google's Product structured data spec.

### Forbidden claims

- "Product schema is probably missing." Confirm page-is-product + schema-absent.
- "Price might not be in schema." Quote the schema's `offers.price`.

### Detection

Looking for `"@type": "Product"` JSON-LD on commerce pages.

### What to Search For

- `"@type": "Product"`
- `"@type": "Offer"`, `"@type": "AggregateOffer"`
- `price`, `priceCurrency`, `availability`
- `aggregateRating` (Product field)
- `review` (Product field)

### Actually Hurts SEO

- **Product page with no Product schema**.
  Evidence required: page is product (signals quoted) + no schema.
- **Product schema missing `offers`** (no price/availability).
  Evidence required: parsed schema without offers field.
- **`availability` not a valid schema.org enum value** (must be `InStock`, `OutOfStock`, `PreOrder`, etc., as a full URL `https://schema.org/InStock`).
  Evidence required: quoted availability value.
- **Price as string with currency symbol** (`"price": "$49.99"`) instead of number + separate `priceCurrency`.
  Evidence required: quoted price field.
- **`aggregateRating` declared with no actual reviews on the page**.
  Evidence required: rating + the page content showing no review section.

### NOT a Problem

- Product schema without `aggregateRating` (only flag if reviews exist on page).
- Product schema without `review` array (acceptable; aggregateRating alone is enough).
- Multiple Product schemas on a category page (one per product card), correct shape.

### Context Check

1. Is the page actually a product (single SKU) or a category page?
2. Does the e-commerce framework auto-emit (Shopify themes, WooCommerce + plugin)?
3. Is the product out of stock with no replacement schema (`availability: OutOfStock`)? Should still have schema; OutOfStock is the correct value.
4. Is the price dynamic (per-user, time-limited)? Schema must reflect what the page shows; if dynamic, server-render the schema with the actual price.

### Reference

Google on Product structured data: https://developers.google.com/search/docs/appearance/structured-data/product

Schema.org Product: https://schema.org/Product

**Severity tagging:**
- Product page with no Product schema → Critical (biggest CTR miss in e-commerce).
- Missing `offers` field → Critical.
- Invalid `availability` enum → High.
- aggregateRating without reviews → Medium (Google may flag as inconsistent).

**Fix voice:** `sahil-lavingia` (primary) | `tobias-van-schneider` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix. Sahil's indie-commerce POV: every advantage you can claim, claim it. Product schema is free CTR if you remember to add it.

Worked fix example:

> Product schema is the single biggest free win in e-commerce SEO. The price + stock badge under your link in SERP is the difference between a 3% CTR and a 9% CTR on commercial searches. Add it.
>
> ```tsx
> const productSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'Product',
>   name: product.name,
>   image: product.images,
>   description: product.description,
>   sku: product.sku,
>   brand: { '@type': 'Brand', name: 'Snitch' },
>   offers: {
>     '@type': 'Offer',
>     url: `https://example.com/products/${product.slug}`,
>     priceCurrency: 'USD',
>     price: product.priceUsd.toFixed(2),
>     availability: product.inStock ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
>     itemCondition: 'https://schema.org/NewCondition',
>   },
>   ...(product.aggregateRating ? {
>     aggregateRating: {
>       '@type': 'AggregateRating',
>       ratingValue: product.aggregateRating.value,
>       reviewCount: product.aggregateRating.count,
>     },
>   } : {}),
> };
> ```
>
> Server-render the schema using the same data as the price label on the page. Drift is the killer, schema saying $49 while the page shows $39 = Google flags as inconsistent and may stop showing the rich result entirely.
