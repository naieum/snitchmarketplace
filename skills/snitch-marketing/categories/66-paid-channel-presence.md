## CATEGORY 66: Paid channel presence (search + social)

Is the brand running paid at all, on which channels, with what message, to what destination? Search and social are one audit because the evidence is one kind: public ad libraries and the SERP, read from outside the ad account. Even a brand that runs no paid at all benefits — competitor ad copy is the clearest public statement of which value props are converting on the queries the site is trying to rank for organically.

Scope boundary, and it is a hard one. This category audits **presence and message**: which channels carry live ads, what the creative says, where it lands, and whether anyone is bidding on the brand's own name. It does not audit the wiring behind them. Pixel installs, conversion-event completeness, server-side pairing and consent signals belong to a different audit — when a pixel is detected and the question becomes whether it is wired correctly, call the Skill tool with "snitch-adsready". Per-ad landing-page scoring belongs to Cat 109 (message match). Campaign management — bid strategy, budget, audience sets — is outside this skill entirely.

### Pre-flight: brand maturity check

Before running, confirm STEP 0.6 (Brand Maturity Check) classified paid presence as `minimal` or `established` on at least one channel. If presence is `none` on every channel (no historical ads in the search engine's ads transparency center, and none in the social ad libraries), **Skip this category** with reason `no paid-advertising history detected; recommendation pending in Strategic Recommendations (STEP 4)`. Do not run the Evidence Required steps; they would all return empty and waste tokens. When one channel has presence and another does not, run the channel that does and record the other as a per-channel Skip with the same reason.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Tooling caveat, governing every off-site step below.** The ads transparency centers and social ad libraries are JS-rendered and region-gated — a plain `Fetch` returns a shell or a gated page. Use a browser/Playwright tool or a `WebSearch` tool IF one is present this session and quote the captured result; otherwise ask the user to paste or screenshot the library results; otherwise **Skip-with-reason**. Never assert ads you could not see (Rule 1). `references/ads-detection-matrix.md` carries the per-platform what's-checkable spine.

**Crawl mode, required tool calls:**

1. **Search side.** Search the brand name plus 3-5 commercial keywords drawn from the site's own value prop. Capture the SERP: are there ads from this brand? Quote the ad headlines and display URLs. Then capture the top 3 advertisers on those same keywords and quote their ad copy.
2. **Social side.** Check the public ad libraries for the brand and for the same competitors:
   - Meta Ad Library: `https://www.facebook.com/ads/library/?search_type=keyword_unordered&q=<brand-name>`
   - LinkedIn Ad Library: `https://www.linkedin.com/ad-library/`
   - TikTok Creative Center: `https://ads.tiktok.com/business/creativecenter/inspiration/topads`
   - The X ads transparency surface
   Capture which channels carry active ads, and the creative shape, copy and CTA of each.
3. **Brand defense.** On a brand-name search, note whether a competitor's ad sits above the brand's own result and whether the brand runs a defensive bid of its own.
4. **Destinations.** For each brand-owned ad, fetch the destination URL. Is it a dedicated landing page or the homepage? Does the page carry the offer the ad promised? Per-ad scoring of that match is Cat 109's pass, not this one — record the destination and hand the scoring over.

**Source mode, required tool calls:**

1. `Glob` for `lp/`, `landing/`, `ads/`, `paid/`, `promo/`, `get/` directories under routes. Quote the file paths, including any route excluded from the sitemap or marked `noindex` that still carries a CTA — that shape is a paid destination.
2. `Grep` for the click-ID parameters the platforms append (`gclid`, `gbraid`, `wbraid`, `msclkid`) and for paid-channel pixels (`AW-`, `uetq`, `fbq(`, `_linkedin_partner_id`, `ttq.load`, `twq(`, `pinit_pixel`, `redditpixel`). Their presence is the evidence that the site expects paid traffic from a given channel — which channels, and since when. **Report presence and location only.** Whether each pixel's conversion tracking is complete and correct is the adsready audit; say so and hand it off rather than grading the wiring here.
3. `Read` the landing-page route components for the shape of the destination: is there a form or a CTA, does the headline state the same offer the ad states, is there social proof.

### Forbidden claims

- "The brand probably runs ads." Search the SERP and the ad libraries; quote what you see, or Skip.
- "Competitor X is probably outspending them." Spend data needs a paid intelligence tool this audit does not have. Claim presence and copy quality; never a spend volume.
- "Landing pages probably don't convert." Audit the page; quote the CTA, the form, the trust signals. Never infer a conversion rate.
- "The pixel is probably misconfigured." That is not readable from presence alone — hand it to adsready.

### Detection

#### Source mode

- Routes named `/lp/`, `/landing/`, `/ads/`, `/promo/`, `/get/`
- Click-ID parsing in route loaders, middleware or analytics init — the site expecting paid traffic
- Paid-channel pixels present (as a channel signal, not a wiring grade)

#### Crawl mode

- SERP results for the brand plus commercial keywords
- The brand's entries in the search engine's ads transparency center (https://adstransparency.google.com)
- The social ad libraries listed above

### What to Search For

**Off-site (browser / `WebSearch` tool, or user-pasted — else Skip-with-reason):**
- Which channels carry live ads for the brand, and for how long they have run
- The headline and description text of each brand ad, and the destination URL it points at
- Competitor entries on the same commercial queries — the message and the offer they lead with
- Whether any competitor is bidding on the brand's own name
- Creative shape per channel (static, video, carousel) against what the channel's audience actually responds to

**In source:**
- Dedicated paid destinations under `/lp/`, `/landing/`, `/ads/`, `/promo/`, `/get/`, `/g/`
- Click-ID and UTM parsing (Cat 53 owns the UTM convention itself)
- Call-tracking or lead-form handlers wired to a paid destination

### Actually Hurts the Marketing Surface

- **Paid traffic lands on the homepage instead of a dedicated destination**.
  Evidence required: the ad's destination URL = the homepage URL.
- **A competitor runs ads on the brand's own brand name and the brand has no defensive bid**.
  Evidence required: the brand-name SERP capture with the competitor's ad quoted, and no brand ad present.
- **No paid presence on the commercial queries competitors dominate**, where budget exists.
  Evidence required: the SERP for the top 3 commercial keywords with competitor ads present and none from the brand.
- **Ad creative opens with the brand or its features instead of the customer's problem.** On discovery channels the words are the targeting — the algorithm finds the audience for the message, so an ad that opens with the company name, a feature list or mission copy targets no one. The working shape is a survival sound bite: a specific, quantified problem or outcome a scroller instantly self-selects on ("Losing baristas faster than you can hire?"). Note that the brand is not in an auction against its category competitors but against the best advertisers on the channel, period.
  Evidence required: the ad creative quoted from the library (subject to the tooling caveat), showing a brand-first or feature-first opening with no problem or outcome line.
- **Channel / audience mismatch** (a B2B tool buying a consumer-video channel while its buyers live in professional networks and developer forums).
  Evidence required: the business model, the buyer, and the channel carrying the spend.
- **Creative message conflicts with the site's own message** — the ads sell one promise and the site leads with another.
  Evidence required: the ad copy and the site's H1 / value prop, quoted side by side. Per-ad landing-page scoring is Cat 109's; what this category reports is the channel-level contradiction.
- **A paid-channel pixel is present but its wiring is unaudited from here.**
  Evidence required: the pixel snippet at file:line, plus the handoff — call the Skill tool with "snitch-adsready" for pixel, conversion-event and consent wiring.

### NOT a Problem

- A brand that explicitly doesn't run paid (founder-led, organic-only). Note the strategy; skip the paid-side findings.
- Landing page = homepage on a single-product site where the homepage IS the landing page.
- Competitor ads on broad category keywords, in a commodity market where everyone bids.
- Pixel installed for retargeting only, when retargeting is the stated strategy.
- Paid presence on one channel and none on another, when the audience is only on the first.

### Context Check

1. Does the brand have budget for paid at all? Pre-revenue or bootstrapped, paid recommendations get deprioritized regardless of what the audit finds.
2. What is the average customer value? Paid needs CAC < LTV; low-LTV products often can't afford the click prices in their category.
3. Is the audience search-driven (high intent at the SERP) or discovery-driven (better fit for paid social)?
4. Is the competitive landscape ad-saturated? Some niches are pay-to-play, and organic advice in them is advice to lose.
5. Are there branded vs non-branded opportunities? A branded defensive bid is usually the highest-ROI paid play a small brand can make.
6. Is the creative format right for the channel it runs on?

### Reference

Google Ads Transparency Center: https://adstransparency.google.com

Meta Ad Library: https://www.facebook.com/ads/library/

LinkedIn Ad Library: https://www.linkedin.com/ad-library/

`references/ads-detection-matrix.md`, the per-platform what's-checkable methodology spine

Cat 53 (Analytics instrumentation), the UTM convention every paid campaign self-identifies with

Cat 109 (Message match audit), per-ad landing-page scoring; this category covers channel-level posture

Pixel, conversion-tracking and consent wiring: call the Skill tool with "snitch-adsready".

**Severity tagging:**
- Paid traffic landing on the homepage instead of a dedicated destination → High.
- Competitor bidding on the brand name with no defensive bid → Medium.
- No paid presence on top commercial queries, where budget exists → Medium.
- Ad creative brand-first / feature-first with no problem line → Medium.
- Channel / audience mismatch → Medium.
- Ad and site messages contradict each other → Medium.

**Fix voice:** `analytics-engineer` (primary) | `indie-commerce-founder` (backup, when the fix is "spend less on paid, build organic / product-led instead").

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> Start with what the public record already says. Pull every live ad the brand runs and every live ad its three closest competitors run, and read them side by side. That comparison answers more than an account audit would: which problem the category leads with, which offer they put in the headline, and which words the brand is conceding.
>
> Three moves follow from it.
>
> **1. The destination matches the promise.** One page per ad group, not the homepage. The page's first line is the ad's line — not a paraphrase, the line. Everything below it proves that one promise. Send the per-ad scoring through Cat 109 once the pages exist.
>
> **2. The creative opens on the buyer's problem.** The name of the company is not a hook on a discovery channel; the words are the targeting. Rewrite the opening line as the most specific version of the problem a scroller would recognise in themselves, and let the brand name arrive after they have stopped scrolling.
>
> **3. Defend the brand name.** If a competitor's ad sits above the brand's own organic result on a brand-name search, that is the cheapest click in the account to take back, and the highest-intent traffic on the list.
>
> What this fix deliberately does not touch: the pixel, the conversion events, the consent signals. Presence says the channel is live; it says nothing about whether the measurement behind it is honest. Run that audit separately — call the Skill tool with "snitch-adsready" — before spending another week judging the ads by numbers the wiring may not be earning.
