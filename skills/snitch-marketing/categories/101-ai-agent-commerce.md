## CATEGORY 101: AI-agent commerce signals

In 2026 a meaningful share of commerce is initiated by an AI agent acting on a user's behalf, ChatGPT shopping mode, Claude operator, Perplexity Pages with buy intents, Anthropic's tool-using research agents, OpenAI's custom GPTs that complete tasks. These agents read your product page, evaluate whether your product matches the user's stated need, and either recommend it or click through to it. The signals that matter to a human shopper (hero image, brand voice, mood video) matter less to an agent; the signals that matter to an agent are extractable structured data, machine-checkable trust signals, and unambiguous transactional metadata.

Brands optimized for human-only shoppers will be passed over by agent intermediation. Since early 2026 this extends past extraction into protocol-level checkout: the Universal Commerce Protocol (UCP), the open agent-transaction standard co-developed by Shopify and Google with broad industry backing (Amazon, Meta, Microsoft, Salesforce, Stripe, Target), gives agents a discoverable `/.well-known/ucp` endpoint covering discovery → cart → checkout, and hosted platforms syndicate their native structured product fields (e.g. Shopify metafields, via Shopify Catalog) directly into AI shopping surfaces. This category audits the agent-readiness of commerce surfaces.

### Pre-flight: relevance check

Skip with reason `not applicable` if the site is not selling anything (no e-commerce, no SaaS subscription, no paid digital good, no service booking). Required everywhere else, even for low-volume brands, agent intermediation is asymmetric in 2026 (small brands gain disproportionately when their product matches a niche query).

### The framework: 5 signal classes

| Signal class | What the agent extracts | Failure looks like |
|---|---|---|
| **1. Product identity** | Name, brand, category, model number, GTIN/SKU | Name only; no GTIN; no canonical category |
| **2. Price + availability** | Current price, currency, in-stock status, fulfillment time | Price as image; "Contact for quote"; stale availability |
| **3. Trust + return policy** | Return window, refund process, satisfaction guarantee, vendor reputation signal | Buried in footer; vague terms; no machine-readable policy |
| **4. Specifications** | Dimensions, materials, compatibility, requirements, technical specs | Specs in PDF; specs in marketing copy; specs in screenshots only |
| **5. Order completion** | One-click checkout-able URL, deep link to add-to-cart, structured offer | Multi-step checkout requiring login; deep link unavailable |
| **6. Protocol participation** | UCP discovery endpoint, agentic sales channels, platform catalog syndication of structured attributes | No `/.well-known/ucp` on a UCP-capable platform; AI channels never enabled; attributes locked in free-text description HTML |

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify product / SKU / service pages. `Grep` for Product schema (Cat 34) AND SoftwareApplication schema (Cat 91) AND Offer schema. Quote.
2. Check Product schema for: `name`, `brand`, `category`, `gtin`/`mpn`/`sku`, `image`, `description`, `offers` (with `price`, `priceCurrency`, `availability`, `priceValidUntil`, `url`).
3. Check for return policy + shipping policy markup: `merchantReturnPolicy`, `shippingDetails` on Offer.
4. Check whether prices are text (extractable) vs image (not extractable).
5. Check for deep-link / one-click-buy URL patterns: `/buy/[sku]`, `/cart/add?sku=...`, `/checkout?sku=...`.
6. On a detected hosted commerce platform (Shopify and similar — see `references/framework-recipes.md`): check whether product attributes beyond title/price (materials, dimensions, compatibility, care, certifications) live in the platform's native structured fields (Shopify metafields / metaobjects) or only as prose inside the description HTML / hardcoded theme templates. Platform structured fields syndicate through the platform catalog to AI channels; prose and theme Liquid do not. Quote a spec-like fact that exists only as prose.

**Crawl mode, required tool calls:**

1. `Fetch` 3-5 product pages. Find JSON-LD blocks. Parse.
2. Quote each product's structured data + visible price.
3. Test a representative agent query in ChatGPT / Claude / Perplexity ("buy [thing fitting your category] under $X with free returns"). Note whether your product is mentioned and how.
4. Check whether the page renders price + availability server-side (most agent crawlers don't execute JS heavy enough to populate JS-rendered prices).
5. `Fetch` `{origin}/.well-known/ucp`. Quote the HTTP status and, if 200, the discovery document's advertised capabilities. On a UCP-capable platform (Shopify exposes agentic commerce self-serve as of its Spring '26 release), a 404 here is a finding. On a custom-built store, absence is an opportunity note, not a failure — adoption outside the major platforms is still uneven.

### Forbidden claims

- "Agents probably can't extract this." Show the missing structured field or the JS-rendering dependency.
- "Price may be in an image." Quote the visible page; identify whether price is text or image asset.
- "Return policy may be unclear." Quote the visible policy.

### What to Search For

- Product / SoftwareApplication / Offer schema completeness
- `gtin` / `mpn` / `sku` presence
- `priceCurrency` + `priceValidUntil` set
- `availability` status and freshness
- `merchantReturnPolicy` (window, fees, eligibility)
- `shippingDetails` (cost, delivery time, regions)
- Server-side rendered price + availability
- Deep-link checkout URLs
- `/.well-known/ucp` discovery endpoint (agentic checkout participation)
- Platform-native structured attributes (Shopify metafields / metaobjects) vs prose-only specs
- AI sales-channel enablement (product feeds reaching ChatGPT shopping / Copilot / Shop app surfaces)

### Actually Hurts the Marketing Surface

- **Product without GTIN/MPN/SKU on category-applicable products** (agents disambiguate products by these, without them, your product looks identical to similar competitors).
  Evidence required: Product schema + missing identifier.
- **Price as image / canvas / SVG** (agent can't read it; OCR is unreliable).
  Evidence required: visible price element + image source.
- **Price + availability rendered post-hydration only** (the agent sees an empty placeholder).
  Evidence required: `curl` of page returns shell HTML; price absent until JS executes.
- **No `merchantReturnPolicy` markup** (agents looking for "free returns" filter your product out).
  Evidence required: missing schema field.
- **No `shippingDetails` markup** (agents looking for "ships in 2 days" can't qualify your product).
  Evidence required: missing schema field.
- **`availability` stale** (page says "in stock" but the product hasn't been in stock for weeks).
  Evidence required: schema availability + visible stockout indicator.
- **No deep-link / one-click-buy URL** (the agent can hand the user a product page but not a direct add-to-cart link).
  Evidence required: missing deep-link pattern.
- **Specifications in PDFs / images instead of structured text on the page** (agents can't extract specs from PDFs reliably).
  Evidence required: page links to spec PDF; no inline structured spec table.
- **Agent test query returns competitor products, not yours** (cross-reference Cat 82, same problem, commerce-flavored).
  Evidence required: agent query response quoted with competitor names.
- **UCP-capable platform with agentic checkout not enabled** (agents can discover, cart, and check out competitors' products through the protocol but can only hand your customer a link).
  Evidence required: platform detected (generator tag / theme assets / admin confirmation) + `/.well-known/ucp` returning 404, or the platform's AI sales channels confirmed off.
- **Product attributes trapped in free-text description HTML or theme code instead of platform structured fields** (metafield-shaped data syndicates through the platform catalog to AI channels and expands which agent queries the product matches; the same facts as prose reach only page-crawling agents).
  Evidence required: spec-like facts quoted from description prose / theme template + absent or empty platform structured fields for those attributes.

### NOT a Problem

- Custom / made-to-order products without availability (configurator product lines), `availability: "MadeToOrder"` is correct.
- B2B service business with no SKU-shaped product, Cat 101 partially applies; focus on lead-form schema instead.
- Brand explicitly opting out of agent intermediation (rare, intentional), flag the choice but don't treat as failure.
- Custom-built store with no `/.well-known/ucp` endpoint, UCP outside the hosted platforms is still an emerging build, not a toggle; note it as an opportunity, never tag it Critical.

### Context Check

1. Are products SKU-shaped (physical goods, software licenses, ticketed events)? If yes, full Cat 101 applies.
2. Is structured data complete enough for an agent to make a recommendation without visiting the page?
3. Is the price + availability extractable from the SSR HTML, not just post-hydration?
4. Is there a one-click deep-link the agent can hand to the user?
5. Has the team tested agent queries in ChatGPT / Claude / Perplexity for their category?
6. Is the store on a platform where agentic checkout is a toggle (Shopify) versus a build (custom stack)? Severity of protocol absence depends on which.

### Reference

Schema.org Offer: https://schema.org/Offer

Google's Merchant Listings + Product structured data: https://developers.google.com/search/docs/appearance/structured-data/product

OpenAI Operator + agent commerce documentation: https://openai.com/index/

Anthropic Claude tool use docs: https://docs.anthropic.com/en/docs/build-with-claude/tool-use

Universal Commerce Protocol (Shopify engineering): https://shopify.engineering/ucp

Shopify agentic-commerce developer platform (Spring '26): https://www.shopify.com/news/spring-26-edition-dev

**Severity tagging:**
- Product without GTIN/MPN/SKU → High.
- Price as image → Critical.
- Price/availability post-hydration only → Critical.
- No `merchantReturnPolicy` → High.
- No `shippingDetails` → Medium.
- Stale `availability` → High.
- No deep-link checkout URL → Medium.
- Specs in PDF only → Medium.
- Agent test surfaces competitors only → Critical.
- UCP-capable platform with agentic checkout / AI channels not enabled → High.
- Structured attributes only in prose or theme code (no platform fields) → Medium.
- Custom stack without UCP → Low (opportunity note).

**Fix voice:** `solutions-architect` (primary) | `sahil-lavingia` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Treat the product page as two surfaces: a human surface and an agent surface. They share the same DOM but consume different parts of it. The human reads the hero, the photos, the mood. The agent reads the structured data, the price as text, the availability flag, the return policy markup. If the agent surface is incomplete, the agent passes over the product regardless of how well-designed the human surface is.
>
> Make every commerce-relevant fact extractable.
>
> ```tsx
> const offerSchema = {
>   '@type': 'Offer',
>   url: `https://shop.example.com/buy/${product.sku}`,    // deep-linkable
>   priceCurrency: 'USD',
>   price: product.price.toFixed(2),
>   priceValidUntil: product.priceValidUntil,
>   availability:
>     product.stock > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
>   itemCondition: 'https://schema.org/NewCondition',
>   seller: { '@type': 'Organization', name: 'Example Co.', url: 'https://example.com' },
>   shippingDetails: {
>     '@type': 'OfferShippingDetails',
>     shippingRate: { '@type': 'MonetaryAmount', value: product.shipping, currency: 'USD' },
>     shippingDestination: { '@type': 'DefinedRegion', addressCountry: 'US' },
>     deliveryTime: {
>       '@type': 'ShippingDeliveryTime',
>       handlingTime: { '@type': 'QuantitativeValue', minValue: 0, maxValue: 1, unitCode: 'd' },
>       transitTime: { '@type': 'QuantitativeValue', minValue: 1, maxValue: 5, unitCode: 'd' },
>     },
>   },
>   hasMerchantReturnPolicy: {
>     '@type': 'MerchantReturnPolicy',
>     applicableCountry: 'US',
>     returnPolicyCategory: 'https://schema.org/MerchantReturnFiniteReturnWindow',
>     merchantReturnDays: 30,
>     returnMethod: 'https://schema.org/ReturnByMail',
>     returnFees: 'https://schema.org/FreeReturn',
>   },
> };
> ```
>
> Render price + availability server-side. Render the return policy as both visible HTML and structured data. Provide a deep-link URL the agent can hand to the user. The agent's job is to qualify the product against a user's criteria; your job is to make every criterion answerable from the page itself.
>
> On a hosted platform, don't stop at JSON-LD. Put every spec-shaped fact (material, dimensions, compatibility, certifications) into the platform's native structured fields — on Shopify that's product metafields, which syndicate through the platform catalog into AI shopping surfaces the page crawlers never touch — and turn on the agentic checkout surface (UCP) so the agent can complete the purchase instead of just recommending it. The same fact as a sentence in the description reaches one class of agent; as a metafield it reaches them all.
