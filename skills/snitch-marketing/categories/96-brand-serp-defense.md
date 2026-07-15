## CATEGORY 96: Brand-SERP defense

When a customer searches the brand name on Google, what they see is the brand's most controlled real estate on the entire web, and the one most often abandoned. The brand SERP should be owned by the brand: knowledge panel, sitelinks, official social profiles, controlled press, and the brand's own pages in positions 1-5. Instead, brand SERPs are commonly contaminated by competitor PPC bids, typosquatters, negative reviews dominating the page, abandoned old social profiles, dead news cycle items, and Wikipedia entries with errors. This category audits the brand SERP from end to end and identifies where the brand has lost control.

### Pre-flight: relevance check

Skip with reason `not applicable` if the brand is brand-new (domain age <90 days), a brand SERP barely exists yet, so there's nothing to defend. Otherwise: required.

### The framework: 5 layers

Brand SERP defense decomposes into five layers. Audit each.

| Layer | What's at stake | Failure looks like |
|---|---|---|
| **1. Knowledge panel** | The big right-rail card, your "answer" surface | No knowledge panel, OR panel with wrong logo / wrong description / outdated info |
| **2. Sitelinks** | The 6 quick links under your top result | No sitelinks, OR sitelinks pointing at low-value internal pages (login, terms) |
| **3. Position 1-5** | The first impression in the main column | Competitor PPC ad on top, then a negative review, then your homepage at position 4 |
| **4. Social + sameAs** | Owned profiles linked to the brand entity | Stale / abandoned profiles, missing platforms, no `sameAs` linking them |
| **5. Threats** | Brand-impersonation, typosquats, hostile content | Typosquat domains, hostile press dominating, fake review sites ranking |
| **6. SERP-feature ownership** | The rich results above/around the organic list | Featured snippet, People Also Ask, image/video pack, or sitelinks-search-box answered by a third party (or a competitor) instead of the brand |

### Evidence required (do not skip)

**Crawl mode, required tool calls (most of this is off-site):**

**Tooling caveat (Critical — the live-SERP and Ads-Transparency steps below are consent-walled JavaScript apps).** Google Search, the knowledge panel, sitelinks, and the Google Ads Transparency Center return only a consent / cookie-wall page or an empty JS shell to a plain `Fetch`/`curl` — the organic results, paid ads, and panel content are rendered client-side and are NOT in that response. To capture them: use a browser/Playwright or `WebSearch` tool IF one is present this session, and quote what it returns. Otherwise, ask the user for a SERP screenshot or to paste the top results / panel / ads. Otherwise, mark the live-SERP and Ads-Transparency steps **Skip** with reason `live brand-SERP capture requires a browser/WebSearch tool or a user-supplied SERP screenshot/paste; plain Fetch returns a consent wall`. **Never assert a SERP position, panel state, or competitor ad you did not observe (Rule 1).** The Source-mode on-site `Organization` schema / `sameAs` checks below do NOT depend on the SERP and still run.

1. Search the brand name on Google (incognito, different region if international). Quote the top 10 organic results AND any paid ads.
2. Capture knowledge panel state: present? logo correct? description accurate? quick facts current?
3. Capture sitelinks: which 6 internal pages does Google show? Are they the highest-value pages or the leftover low-priority ones?
4. Identify position 1-5: brand's own pages, owned social, third-party press, competitor pages, hostile content.
5. Search `"<brand>"` (in quotes), `<brand> reviews`, `<brand> alternative`, `<brand> login`, `<brand> pricing`, `is <brand> legit`. Each query has a different defense profile.
6. Check Google Ads Transparency Center for competitors bidding on the brand name (Cat 66 cross-reference).
7. Check Wikipedia for the brand entry (if it exists). Quote any factual errors or outdated content.
8. Layer 4 off-site sweep: check presence + recency across the off-site platforms searchers and AI assistants weight, per `references/brand-authority-platforms.md` (Wikipedia, Reddit, YouTube, LinkedIn, G2, Trustpilot, etc.). Quote presence and last-activity per platform, and cross-check each against the `sameAs` array (a profile in `sameAs` that's abandoned or 404s is the finding).
9. Layer 6 SERP-feature ownership: for the brand name AND the brand's top 3-5 informational/commercial queries, capture which SERP features render and WHO owns each — **featured snippet** (which URL is quoted), **People Also Ask** (whose pages answer the questions), **image pack**, **video carousel**, **knowledge panel**, **sitelinks search box**, **top-stories**. The finding is a feature the brand could own but a third party or competitor occupies (e.g., a featured snippet for "what is {brand}" pulled from a review site, not the brand's own page). Quote the feature + the owning URL + rank. Same tooling caveat as the live-SERP steps — needs a browser/WebSearch tool or a user-supplied screenshot; otherwise Skip-with-reason. Cross-reference Cat 82 (extractability) for WHY the brand's page isn't the one being pulled into the snippet.

**Source mode, required tool calls:**

1. `Grep` Organization schema (Cat 37) for `sameAs` array. Quote.
2. Confirm `sameAs` URLs all resolve to live, brand-owned profiles.
3. Check that the brand's homepage has a complete, current `Organization` schema feeding the knowledge panel.

### Forbidden claims

- "Competitors are probably bidding on your brand." Either Ads Transparency confirms it OR you ran a brand search and saw the ad. Quote.
- "The knowledge panel is probably outdated." Quote the panel content + the on-site source of truth.
- "Wikipedia may have errors." Quote the Wikipedia text + the corrected fact.

### What to Search For

- Brand SERP top 10 results (organic + paid)
- Knowledge panel presence + content accuracy
- Sitelinks (which internal pages, which are missing)
- `sameAs` array coverage in Organization schema
- Branded-keyword PPC bids by competitors
- Typosquat domains (DNS lookups for `<brand>.com`, `<brand>.io`, `<brandname-with-hyphen>.com`, common misspellings)
- Negative review sites ranking for `<brand> reviews`
- Wikipedia entry (or absence)

### Actually Hurts the Marketing Surface

- **No knowledge panel for an established brand (>1 year old)**.
  Evidence required: brand SERP screenshot + missing panel. Often signals incomplete Organization schema (Cat 37) or low entity authority.
- **Knowledge panel with outdated logo / description / founded date / leadership**.
  Evidence required: panel quote + on-site current value.
- **No sitelinks under the brand's top result**.
  Evidence required: brand SERP missing sitelinks. Indicates low domain authority or muddled internal linking (Cat 19).
- **Sitelinks pointing at low-value pages** (Login, Terms, Privacy) instead of high-value pages (Pricing, Features, Docs).
  Evidence required: sitelinks quoted + missing higher-value alternatives that exist.
- **Competitor PPC ad above brand's organic position 1** (cross-reference Cat 66).
  Evidence required: Ads Transparency entry + brand SERP screenshot.
- **Negative review site ranking position 1-5 for `<brand> reviews`** with no defense (no review surface owned by brand, no positive third-party reviews).
  Evidence required: SERP screenshot + missing on-site review surface (Cat 74).
- **Typosquat domain registered + ranking for misspellings**.
  Evidence required: typo domain WHOIS + SERP appearance.
- **Wikipedia entry contains factual errors** (founded date, founder names, current product description).
  Evidence required: Wikipedia quote + correct fact + source.
- **Wikipedia entry absent** for a brand with >$10M revenue / >100 employees / industry significance (notability threshold likely met but no entry exists).
  Evidence required: Wikipedia search + brand size signals.
- **`sameAs` array incomplete or out of date** (missing major platforms; pointing at deleted accounts).
  Evidence required: parsed `sameAs` + fetch of each URL.
- **Stale / abandoned official social profiles ranking for the brand** (last post >12 months ago on a profile that's still in `sameAs`).
  Evidence required: profile last-post date.

### NOT a Problem

- New brand (<90 days old) without a knowledge panel, Google needs time to build entity confidence.
- A small brand without a Wikipedia entry, notability requirements may not be met; not always a problem.
- Old press / news items in positions 6-10, declines naturally as the brand publishes newer content.

### Context Check

1. What does someone landing on the brand SERP for the first time see? That's the impression that drives the first conversion or first abandonment.
2. Is the knowledge panel claimed (Google My Business / Knowledge Graph claim)? Unclaimed panels can be edited by Google's automated systems with no brand input.
3. Is the brand's Organization schema (Cat 37) feeding the knowledge panel correctly?
4. Does the brand have a defensive PPC bid on its own brand name (Cat 66)? The argument for: prevents competitor ads from displacing organic.
5. Are negative reviews dominant for `<brand> reviews`? If so, audit Cat 74 (customer feedback / social proof) and consider building an on-site review surface.

### Reference

Google Knowledge Graph + entities: https://developers.google.com/search/docs/appearance/knowledge-graph

Wikipedia notability guidelines: https://en.wikipedia.org/wiki/Wikipedia:Notability

Branded-keyword PPC defense (Cat 66 cross-ref).

**Severity tagging:**
- No knowledge panel for established brand → High.
- Knowledge panel with outdated content → High.
- No sitelinks → Medium.
- Sitelinks pointing at low-value pages → Medium.
- Competitor PPC above brand organic → High.
- Negative review site at position 1-5 for brand reviews → Critical.
- Typosquat domain ranking → High.
- Wikipedia errors → Medium.
- Wikipedia absent (notability met) → Medium.
- `sameAs` incomplete / stale → Medium.

**Fix voice:** `tobias-van-schneider` (primary) | `mike-monteiro` (backup).

Read `souls/tobias-van-schneider.json` before writing the Fix.

Worked fix example:

> The brand SERP is the most controlled surface the brand has on the entire web, and most brands ignore it until a customer screenshots it back to them. Treat it like a portfolio: every piece on the page either earns its place or it doesn't.
>
> Knowledge panel first. Confirm the Organization schema on the homepage is complete and current, name, logo, description, founded date, founders, sameAs. Claim the panel through Google. Submit the brand to Wikipedia (if notability is met) so an authoritative third-party page exists.
>
> Sitelinks next. The internal pages Google chooses for sitelinks reflect the internal link graph the team built. If sitelinks are wrong, fix the link graph: link more from the homepage to the pages that should rank as sitelinks; reduce links to the pages that shouldn't.
>
> Position 1-5: own them. Homepage, About, Pricing, Docs, a recent Press piece, the changelog, these should fill the brand's own slots. Add a defensive PPC bid on the brand name to keep competitors above organic.
>
> Threats: type the brand into Google with every variation a customer might type, `<brand> reviews`, `is <brand> legit`, `<brand> alternative`, common misspellings. Each surface that's hostile gets its own remediation: build an on-site review section that ranks for `<brand> reviews`; register the most-likely typosquat domains; respond on review sites where you can.
>
> The brand SERP is not a vanity surface. It's the first impression for everyone considering the brand, and you have more control over it than any other channel, provided you do the work.
