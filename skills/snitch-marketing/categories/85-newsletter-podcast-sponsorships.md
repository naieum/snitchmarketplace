## CATEGORY 85: Newsletter & podcast sponsorships (niche-vertical earned-media)

Banner display ads are dead. Macro influencer marketing has poor conversion. The middle path that works in 2026: niche newsletter sponsorships ($500-5K per send, 1-5K subscribers in tightly-targeted niche) and niche podcast read-by-host sponsorships (custom integration, host's voice). High-trust, contextual, hard to ad-block.

### Pre-flight: brand-stage check

Skip if pre-product / pre-revenue (no budget for sponsorships). Skip if niche has no targeted newsletters/podcasts (rare in 2026; most niches do). Otherwise continue.

### Evidence required (do not skip)

**Crawl mode, required tool calls:**

1. From STEP 0.7 niche definition: identify 5-10 newsletters in the brand's niche. Sources: SparkLoop directory (https://sparkloop.app), Substack search by topic, Beehiiv discover.
2. Identify 5-10 podcasts in the brand's niche. Sources: Apple Podcasts category browsing, Listen Notes (https://www.listennotes.com), Spotify category charts.
3. Check whether the brand has sponsored any (search for sponsorship calls in newsletters: "Today's email is brought to you by..."; podcast: most have ad-read at start/midroll).
4. Look for the brand's tracking infrastructure for sponsorship attribution: vanity URLs (`brand.com/podcast-name`), unique discount codes per show, custom landing pages.

**Source mode, required tool calls:**

1. `Glob` for sponsorship-specific landing pages: `/<podcast-or-newsletter-name>` routes. `Read` each.
2. `Grep` for vanity URLs / unique-code handlers in routing.

### Forbidden claims

- "Brand probably hasn't sponsored newsletters." Search a few; quote what's there.
- "Sponsorship attribution may be missing." Show source.

### Detection

Niche newsletter / podcast inventory + sponsorship presence + attribution wiring.

### What to Search For

Sources of niche newsletters:
- Substack directory by topic
- Beehiiv discover
- SparkLoop newsletter recommendation network
- Industry-specific Reddit / forum recommendations

Sources of niche podcasts:
- Apple Podcasts > Categories
- Listen Notes (search by topic)
- Spotify category charts
- Patreon top podcasts in niche

### Actually Hurts the Marketing Surface

- **Brand absent from sponsorship in obvious niche newsletters/podcasts**.
  Evidence required: newsletter / podcast list + zero brand presence.
- **Sponsorships landing on the homepage** (no vanity URL, no custom landing page = poor attribution + lower conversion).
  Evidence required: sponsorship CTA URL = generic.
- **No tracking of sponsorship-driven signups** (can't tell which podcast / newsletter delivered).
  Evidence required: dashboard / source missing per-show attribution.
- **Generic ad copy across all sponsorships** (vs custom-per-show messaging that mentions the host's audience specifically).
  Evidence required: sponsorship copy comparison if multiple shows used.
- **Sponsoring shows with mismatched audience** (technical product on a general-audience podcast).
  Evidence required: sponsorship + audience demographics.

### NOT a Problem

- Pre-revenue brand without budget. Skip via pre-flight.
- Sponsorships that ran but ended (test-and-cut is a valid strategy).
- Single sponsorship test in progress (can't measure ROI yet).

### Context Check

1. Is the niche audience podcast-heavy or newsletter-heavy? Different niches favor different formats.
2. Is the team capable of producing a custom landing page per sponsorship?
3. Is there budget for the first 5-10 tests at $500-2K each?
4. Is the metric ROI per dollar (CAC) or top-of-funnel awareness? Different success criteria.

### Reference

SparkLoop newsletter recommendation: https://sparkloop.app

Listen Notes podcast database: https://www.listennotes.com

Acquired podcast (sponsorship case study): https://www.acquired.fm

**Severity tagging:**
- Brand absent from clear-fit niche newsletters/podcasts → High.
- Sponsorships running but landing on homepage (no vanity URL) → High.
- No per-show attribution → High.
- Generic copy across shows → Medium.
- Audience-mismatched sponsorships → Medium.

**Fix voice:** `sahil-lavingia` (primary) | `analytics-engineer` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Pick 5 newsletters and 3 podcasts in your exact niche. Cost per: $500-3K. Total test budget: $5-10K over a quarter.
>
> Per sponsorship:
> 1. **Custom landing page** at `brand.com/<show-name>`. Headline mentions the show by name. Pre-fills any "where did you hear about us" form.
> 2. **Custom code or vanity URL** for attribution. Tracks signups + conversions per show.
> 3. **Custom ad copy** for the show's audience. Reference what they listen to / read for; align the brand's value to that audience's specific situation.
> 4. **Host-read script** for podcasts (vs generic ad). Let the host adapt to their voice.
>
> After 90 days: sort by conversions per dollar. Double down on the 1-2 best. Sunset the rest. Compound the wins (multi-week or multi-episode arrangements with the top performers).
>
> Trust + context + attribution. That's the 2026 winning loop.
