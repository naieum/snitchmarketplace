## CATEGORY 78: Affiliate / referral programs

Pay third parties (affiliates) or existing customers (referral) for new sign-ups. Effective for products with clear conversion + trackable revenue per customer.

### Pre-flight: program suitability

Not every product fits affiliate / referral. Skip if: pre-revenue, free-only, B2B enterprise sales (long cycle, attribution unclear), or products with low LTV (margin can't support payouts). **Skip** with reason `product economics or stage doesn't fit affiliate/referral; revisit when revenue model supports payouts`.

### Evidence required (do not skip, only when economics fit)

**Source mode, required tool calls:**

1. `Grep` for affiliate / referral patterns: `?ref=`, `?aff=`, `?invitation=`, attribution-tracking schemas, payout-related code.
2. Check for `/affiliate`, `/referral`, `/partners` routes (program landing).
3. Check for affiliate platform integrations: Rewardful, FirstPromoter, PartnerStack, Tapfiliate, ImpactRadius, ShareASale.

**Crawl mode, required tool calls:**

1. Fetch `/affiliate`, `/referral`, `/partners` if they exist. Capture program terms.
2. Search for the brand on affiliate-network listings.

### Forbidden claims

- "Affiliate program is probably absent." Quote present-or-absent.

### Detection

Source-side: tracking + program landing pages. Off-site: network listings.

### What to Search For

URL patterns:
- `?ref=`, `?aff=`, `?via=`, `?invitation=`, `?fpr=` (FirstPromoter)
- `/affiliate`, `/referral`, `/partners`, `/refer-friend`

Platform integrations:
- `rewardful.com`, `firstpromoter.com`, `partnerstack.com`
- `tapfiliate.com`, `impact.com`, `shareasale.com`

### Actually Hurts the Marketing Surface

- **Existing customers have no way to refer** (no per-account referral link / dashboard).
  Evidence required: dashboard inspection (or `/referral` route absent).
- **Affiliate program exists but no public landing page** (affiliates can't find it).
  Evidence required: search for `affiliate` returning nothing visible.
- **Payout terms unclear** (affiliate page exists but says "contact us" without rate / cookie window / minimum-payout).
  Evidence required: page content.
- **No tracking on affiliate-link clicks** (links work but no attribution).
  Evidence required: source for `?ref` query param handling.

### NOT a Problem

- No program because product doesn't fit. Intentional.
- Invite-only / closed beta affiliate program (intentional curation).

### Context Check

1. Is the product economics supporting payouts (margin, LTV, payback period)?
2. Is the team able to support affiliate communication / payments?
3. Are there obvious affiliate types (creators, agencies, consultants who'd recommend)?

### Reference

Rewardful's guide to SaaS referral programs: https://www.rewardful.com/blog

**Severity tagging:**
- Product fits affiliate but no program → Medium.
- Program exists but no landing page → High.
- Unclear terms on landing page → Medium.
- Existing customers can't refer → Medium.

**Fix voice:** `sahil-lavingia` (primary) | `analytics-engineer` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Stand up the simplest version that works: a public `/affiliate` page with terms (commission %, cookie window, payout schedule, prohibited promotions), a sign-up form, an integration with Rewardful or FirstPromoter for tracking + payouts.
>
> ```
> Snitch Affiliate Program
>   Commission: 30% of first-year revenue
>   Cookie window: 60 days
>   Payout: monthly via PayPal/Stripe ($50 min)
>   Approval: case-by-case based on traffic source
>   Prohibited: incentivized review sites, coupon/cashback farms
> ```
>
> Recruit 10-20 quality affiliates personally before opening the public sign-up. Quality > quantity; one trusted creator beats 50 spam-pages with your link.
