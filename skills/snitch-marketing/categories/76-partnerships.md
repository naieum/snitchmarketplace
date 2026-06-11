## CATEGORY 76: Partnerships, integrations, co-marketing

Co-marketing with adjacent brands, technical integrations with partner products, partner directories. Multiplies reach by borrowing partner audiences.

### Pre-flight: partnership relevance

Some brands legitimately don't pursue partnerships (early stage, niche product, founder-led with no bandwidth). If brand maturity is `none` everywhere AND no partners are in the product yet, **Skip** with reason `no partnerships yet; will reassess after brand maturity is minimum minimal`.

### Evidence required (do not skip, only when partnership opportunities exist)

**Source mode, required tool calls:**

1. `Grep` for integration mentions in `/docs`, `/integrations`, `/partners`, `/marketplace` routes. Quote.
2. `Read` README / docs for technical integrations (Zapier, n8n, IFTTT, Slack apps, etc.).
3. Identify if the product has a public API or extension marketplace that partners could build on.

**Crawl mode, required tool calls:**

1. Fetch `/integrations`, `/partners`, `/marketplace` pages. Quote partner list.
2. Check if the brand appears in partner directories of complementary products.

### Forbidden claims

- "Partnerships probably underdeveloped." Quote the list.

### Detection

Partner directory + integration inventory.

### What to Search For

URL patterns:
- `/integrations`, `/partners`, `/marketplace`, `/ecosystem`
- Partner-listing components

Code patterns:
- API auth flows (`api/oauth/<partner>`)
- Webhook integrations (`api/webhooks/<partner>`)
- Embedded SDK references

### Actually Hurts the Marketing Surface

- **Product has obvious integration opportunities not pursued** (e.g., a B2B tool with no Slack / Notion / Linear / Zapier integration).
  Evidence required: product type + competitive integration norms.
- **Partner page exists but lists 1-2 partners** (looks abandoned).
  Evidence required: page content.
- **Integration documentation incomplete** (partner page references "available soon" for years).
  Evidence required: page age + content.
- **Brand absent from partner directories** of products it integrates with.
  Evidence required: integration in the product + missing listing on partner's marketplace.

### NOT a Problem

- Brand without integrations because product is standalone (e.g., a single-purpose web tool).
- Few partners listed because partnerships are nascent. Acceptable; not a finding.

### Context Check

1. Does the product have natural integration points (API, webhooks, OAuth)?
2. Are competitor products integrated with adjacent tools?
3. Is the team pursuing co-marketing with partners (joint webinars, content swaps, bundled pricing)?

### Reference

Crossbeam on partner ecosystems: https://www.crossbeam.com/resources/

**Severity tagging:**
- Missing obvious integration (product has API; no partners listed) → Medium.
- Stale partner page → Medium.
- Brand absent from partner directories where integration exists → Medium.

**Fix voice:** `sahil-lavingia` (primary) | `solutions-architect` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Pick the 3 partners whose audience overlaps most with yours and whose product is naturally adjacent. For a security audit tool: GitHub, Vercel, Cloudflare. For a form backend: Webflow, Framer, Notion.
>
> Build the integration first (it has to actually work). Document it on `/integrations/<partner>`. Submit to the partner's marketplace / directory. Reach out to the partner team about a joint blog post or webinar.
>
> Three real integrations beat ten "available soon" placeholder logos. The partner's audience finds you when they search for "<partner> + your category", that's the multiplier.
