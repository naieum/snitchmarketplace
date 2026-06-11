## CATEGORY 83: Creator partnerships (mid-tier niche creators)

In 2026, mid-tier creators (5K-100K followers) in a specific niche outperform macro influencers AND most paid-social ad spend on conversion. Their audience trusts them; the integration feels native; attribution is cleaner via custom links / codes. Audit covers: is the brand running creator partnerships, with whom, with what attribution.

### Pre-flight: brand maturity check

Confirm STEP 0.6 classified at least `minimal` brand maturity AND the brand has product/revenue to support creator deals (creators expect either flat fees or rev-share). If pre-revenue / pre-product, **Skip** with reason `creator partnerships require product + budget; revisit when both exist`.

### Evidence required (do not skip, only when brand is in market)

**Crawl mode, required tool calls:**

1. Search YouTube / X / LinkedIn / TikTok / Instagram for the brand name + "review" / "tutorial" / "alternative" patterns. Identify creators who have organically mentioned the brand.
2. Check creator-specific UTM patterns on the site's referral tracking (utm_source=<creator-handle>, ?via=<creator>, custom discount codes per creator).
3. Look for `/creators`, `/partners`, `/ambassadors` page on the brand site.

**Source mode, required tool calls:**

1. `Grep` for creator-attribution patterns: `via=`, `creator=`, `partner=`, custom discount-code handlers in checkout flow.
2. `Read` the affiliate / referral code (cross-reference Cat 78), creator partnerships often piggyback on the affiliate program with named codes.

### Forbidden claims

- "Creators may not know about the brand." Search; quote what's there.
- "Attribution is probably not set up." Show the source / URL params.

### Detection

Off-site creator content + on-site attribution wiring.

### What to Search For

- YouTube / TikTok video titles containing brand name + "review" / "tutorial" / "vs"
- Creator profile bios linking to the brand
- Discount codes named after creators (`SAVE-20-DAVID`, `JANE10`)
- UTM patterns: `utm_source=<creator>`, `utm_medium=creator`

### Actually Hurts the Marketing Surface

- **Brand has no creator partnerships** when the niche has obvious mid-tier creators talking about adjacent products.
  Evidence required: niche identified + 3-5 creators in space + zero brand mentions.
- **Creators mention the brand organically with no attribution wiring** (lost lead-source data).
  Evidence required: organic mention + no UTM / code linkage.
- **All creator deals with macro influencers** (>500K) where ROI is typically poor.
  Evidence required: partner list + follower counts.
- **Creator program managed via DMs with no contracts / payment infrastructure**.
  Evidence required: missing `/creators` or `/ambassadors` page or any formal program.
- **No tracking of creator-driven conversions** (can't tell which creator drove signups).
  Evidence required: source attribution missing in dashboard.

### NOT a Problem

- Brand at stage where creator deals don't fit (pre-launch, niche too small, B2B enterprise sales). Note context.
- Brand intentionally working with macro creators for awareness vs conversion. Acceptable strategy.

### Context Check

1. Is the audience on platforms where creators have meaningful reach (YouTube for technical, TikTok for consumer, LinkedIn for B2B)?
2. Are mid-tier creators in the niche identifiable? (If the niche is too narrow, may not exist yet.)
3. Does the team have budget for creator deals (typical mid-tier flat fees: $500-5K per video)?
4. Is conversion attribution wired before reaching out (creators ask "how do I get paid for conversions?")?

### Reference

Creator economy report (SignalFire): https://signalfire.com/blog/creator-economy-2024/

Per-creator attribution (PartnerStack / Tolt): https://www.partnerstack.com / https://tolt.io

**Severity tagging:**
- Brand untracked creator mentions → High (lost attribution + missed leverage).
- No creator program when niche supports it → High.
- Macro-only creator deals (low ROI) → Medium.
- No attribution infrastructure → High.

**Fix voice:** `sahil-lavingia` (primary) | `tobias-van-schneider` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Mid-tier wins. A YouTuber with 30K subscribers in your niche drives more signups than a macro creator with 2M because their audience came for the niche AND trusts them on it.
>
> Pick 5-10 mid-tier creators per quarter. Reach out personally with: a free account, a 60-day exploration window, an offer of either a flat fee for a review or a revenue-share via per-creator code. Track via Tolt / PartnerStack / Rewardful with creator-specific codes (`SAVE20-DAVID`).
>
> Don't dictate the content. Let creators frame it for their audience. The good ones know their voice better than you do; the worst they'll do is be honest about flaws, which is often more credible than glowing reviews.
>
> Track which creator drives which signups with which downstream conversion. After 90 days, double down on the 1-2 winners; sunset the rest. Compound the relationship, exclusive features, early access, deeper rev-share.
