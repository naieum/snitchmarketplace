## CATEGORY 120: Meta ads account structure health

Cat 107 audits whether the Meta Pixel + Conversions API are installed and firing. Cat 108 audits whether UTM tagging hits the analytics layer cleanly. Both are necessary; neither audits whether the account *itself* is set up so Meta's algorithm can learn. A perfectly-installed pixel feeds a broken account structure exactly as fast as it feeds a sound one, and the broken account loses money predictably.

This category audits the structure: campaign topology, ad-set count + age, creative refresh rhythm, hook-variation depth per concept, audience specificity, learning-phase respect, and budget adequacy relative to the target CPA.

### Pre-flight: relevance check

Run when the component inventory (STEP 0.8) detects Meta Pixel / Conversions API / Meta Business Manager / Facebook Login / shared-link `fbclid` parameters in marketing URLs. Skip with reason `no Meta ads infrastructure detected; not applicable` otherwise.

If pixel + CAPI are detected but the audit can't access the actual ad account (rate limits, permissions, customer hasn't shared access), produce a partial audit covering only the on-site evidence (form fields, retargeting setup, event taxonomy) and flag the rest as `requires ad-account access; pending`.

### The 6-layer structure audit

| Layer | What it audits | Failure mode |
|---|---|---|
| **1. Campaign topology** | One long-lived CBO per business goal vs duplicate campaigns per audience / placement / variation | Account split into 12 campaigns "to test" — none accumulate enough conversions to exit learning |
| **2. Ad-set count + age** | Ad sets at meaningful budget (≥3-5× target CPA daily), at least 7 days of learning | $5/day ad sets that never escape learning; ad sets killed at day 3 with no signal |
| **3. Creative refresh cadence** | 3-6 ads per ad set to start; refresh every 3-4 weeks for local, 6-8 weeks for broader audiences | Same 2 creatives running 6 months; ad fatigue tanks CTR and frequency climbs >3 |
| **4. Hook-variation depth** | One base 30-45s creative; 5-10 first-3-second hook re-records (different opening line, framing, B-roll) per concept | One ad per concept; "we tested creative" means launching unrelated new ads instead of varying hooks |
| **5. Audience specificity** | Psychographic + behavioral targeting, not just demographic; cold-audience size 500k-1M for US targeting | "Adults 25-55 interested in {category}" — too broad to optimize against, too generic to differentiate from competitors |
| **6. Learning-phase respect** | No edits within 7 days of launch; daily budget = 3-5× target CPA; minimum 50 conversions before judgment | Helicopter-edits at day 2 ("CPM looks high, let me change targeting"); under-budgeting at $5/day; killing tests with 8 conversions |

### Evidence required (do not skip)

**Source mode contributions:**

1. `Grep` site for Meta Pixel ID pattern (`fbq\(`, `_fbp` cookie, `fbevents.js`, `pixel_id`) and Conversions API references (`/events?pixel_id=`, `meta-conversions-api-gateway`, `capi`). Confirm presence + which events fire.
2. `Grep` for Facebook Login / Meta SDK integrations.
3. Read the brand's lead form components and any landing-page form templates. Capture: field count, required fields, phone-field presence.
4. `Grep` for client-side or server-side `event` calls (`Lead`, `Purchase`, `CompleteRegistration`, `AddToCart`, `InitiateCheckout`, custom events).

**Crawl mode contributions:**

1. `Fetch` 3-5 landing pages the brand uses for paid traffic (identify via paid-traffic URL patterns: `/lp/`, `/landing/`, UTM-tagged shared links). Capture: form field count, friction inserted, trust signals at the form, social proof presence.
2. Inspect rendered page for pixel-firing JS network calls (proxy-level if available).
3. Check the brand's Meta Business Manager / Ad Library entries via public Meta Ad Library (`https://www.facebook.com/ads/library/?id={brand}`). Capture: ad count currently running, creative age (Library shows start date), ad copy + thumbnail variation, audience hints.

**Ad-account access (if granted):**

1. Campaign topology — how many active campaigns, are they CBO or ABO, age in days, optimization goal alignment.
2. Ad-set count per campaign + daily budget per ad-set.
3. Creative age — when was the most recent ad launched? Frequency on existing ads?
4. Audience definitions — saved audiences, custom audiences, lookalikes; size; refresh cadence (180-day window for custom audiences).
5. Optimization event — does it match the actual business goal (Purchase vs Lead vs View Content)?

### Forbidden claims

- "The account is probably over-segmented." Quote the campaign count and the conversion volume per campaign.
- "Creatives are probably stale." Quote the launch date of the most recent ad.
- "Audience is probably too broad." Quote the audience definition + the audience size.
- "Budget is probably under-funded." Quote the daily budget per ad-set + the target CPA.

### Detection

Site-scan for pixel + Meta Ad Library inspection + (if access) ad-account topology check.

### What to search for

On-site:

- Meta Pixel install (`fbq('init', 'PIXEL_ID')`, `fbevents.js`)
- Conversions API server-side endpoint
- `Lead`, `Purchase`, `CompleteRegistration`, `AddToCart`, `InitiateCheckout` events firing
- Lead form components — field count, phone field, conditional logic
- Landing pages with paid-traffic URL patterns

Meta Ad Library:

- Active ads count
- Earliest launch date among active ads (creative age)
- Creative variation: same script with different hooks vs unrelated ads
- Headline + body copy variation rate
- Targeting hints (the Library doesn't expose targeting but does expose impressions by demographic when available)

Ad account (if access):

- Campaign topology (CBO vs ABO, count, age)
- Ad-set count + budget + age + optimization event
- Creative refresh rhythm
- Audience definitions + size + custom-audience freshness
- Frequency, CPM, CPC, CTR by ad-set
- Cost per result vs target CPA

### Actually hurts the marketing surface

- **More than 3 active campaigns running simultaneously for the same business goal.** Over-segmented account; no campaign accumulates enough conversions to exit learning. Critical.
  - Evidence required: campaign count + per-campaign conversion volume (last 7 days).
- **Ad-set daily budget < 3× target CPA.** Algorithm has no learning signal; ad set runs forever in learning phase. High.
  - Evidence required: daily budget per ad-set + the brand's stated target CPA (from STEP 0.5.1 assumptions or the pricing model).
- **Single creative running >6 weeks with no hook variations launched.** Ad fatigue. Critical when frequency >3. High otherwise.
  - Evidence required: ad launch date + frequency metric (if available).
- **One ad per concept; no hook variations.** Creative testing is launching unrelated concepts instead of testing variations of the same base. High.
  - Evidence required: Ad Library shows {N} ads with {N} distinct base scripts vs {N} ads with one base + N-1 hook re-records.
- **Cold audience size <100k or >5M for US targeting.** Too narrow to learn; too broad to differentiate. Medium to High depending on direction.
  - Evidence required: audience definition + size.
- **Audience targeting is demographic-only ("Adults 25-55, USA, interested in [category]").** No psychographic / behavioral specificity; the audience definition could fit any competitor in the category. High.
  - Evidence required: audience definition quoted.
- **Edits applied to ad sets within 7 days of launch.** Learning phase reset; data accumulated discarded. High.
  - Evidence required: edit history (if access) or budget / audience changes inferred from Ad Library status changes.
- **Optimization event mismatched to business goal** (e.g., optimizing for `View Content` when the goal is signups; optimizing for `Lead` when leads are unqualified). Algorithm learns to drive the wrong outcome. Critical.
  - Evidence required: optimization event from account + business goal from STEP 0.5.
- **Lead form has 5+ fields including non-essential data.** Conversion rate drop per added field; the audit recommends minimum-viable form. High.
  - Evidence required: form field count + which fields are required.
- **No phone-number field on Instant Forms.** SMS retargeting + lead-quality filtering forfeited. Medium.
  - Evidence required: Instant Form configuration.
- **No form-abandoner custom audience built.** Highest-intent retargetable cohort ignored. Medium.
  - Evidence required: custom audience inventory (if access) or absence of corresponding retargeting ad in Ad Library.
- **Custom audiences not refreshed in 180+ days.** Audience freshness window expired; size drops; lookalikes built on stale source. Medium.
  - Evidence required: custom audience definition + last-updated date (if access).
- **No Conversions API alongside Pixel.** iOS 14.5+ signal loss not mitigated. High.
  - Evidence required: site scan returning Pixel but no CAPI server-side calls.

### NOT a problem

- New campaigns (<7 days) that haven't shown signal yet; the audit's job is to confirm learning is being respected, not to demand premature results.
- A single long-lived CBO with 3-6 ad sets and weekly creative additions — that's a healthy structure, not a finding.
- Demographic targeting paired with strong psychographic + behavioral overlays (interests, behaviors, lookalikes) — the demographic alone is fine when other layers carry the specificity.
- Brands deliberately running geo-restricted ads with cold audience size <100k (e.g., one neighborhood, one ZIP) — the small audience is intentional. Adjust budget expectations and increase test duration.
- Brands without ad-account access for the audit; partial audit with the on-site signals is acceptable, the rest is flagged as "pending access."

### Context check

1. What's the brand's stated target CPA or CPL? Without it, the budget-adequacy check has no anchor.
2. What's the optimization event the campaign actually uses? Does it match the business goal from STEP 0.5?
3. Is the brand running ads for awareness or conversions? Awareness campaigns have different structure rules; verify the campaign objective.
4. Does the brand have ad-account access shared with the audit? If not, scope to what's visible in Ad Library + on-site evidence.
5. What's the brand's iOS-traffic share? Higher iOS share = more pressure to have CAPI working alongside Pixel.
6. Is the brand selling B2C, B2B-self-serve, or B2B-sales-led? Each has different baseline CTR / CPC / conversion rate expectations.

### Pairs with other categories

- **Cat 107 (Pixel install)** — Pixel + CAPI presence is the prerequisite for this category. If Cat 107 fails, this category's findings are moot until Cat 107 is fixed.
- **Cat 108 (UTM hygiene)** — UTM tagging on ad destination URLs lets the brand's analytics tie back to Meta campaigns. Cross-reference.
- **Cat 67 (Paid social)** — Cat 67 audits whether the brand is on the channel at all + creative quality. This category audits whether the channel is structured to learn.
- **Cat 109 (Paid social measurement)** — measurement methodology + attribution.
- **Cat 60 (Conversion & Trust)** — landing-page conversion architecture; the ad's job is to get the click, the landing page's job is to convert it.
- **Cat 117 (Site copy lint)** — ad copy and landing-page copy must pass the same vague-adjective / unsupported-superlative / hidden-price rules.
- **Cat 110 (ICP wedge scoring)** — audience specificity ties to the ICP scoring exercise; if the brand hasn't done Cat 110, the audience definition is structurally fuzzy.

### Severity tagging

- More than 3 active campaigns per business goal (over-segmentation) → Critical.
- Optimization event mismatched to business goal → Critical.
- Single creative running >6 weeks AND frequency >3 → Critical.
- Single creative running >6 weeks AND frequency <3 → High.
- One concept, no hook variations → High.
- Ad-set daily budget <3× target CPA → High.
- Edits inside the 7-day learning phase → High.
- Lead form has 5+ fields with non-essential data → High.
- Audience size <100k or >5M for US cold → Medium to High depending on direction.
- No CAPI alongside Pixel → High.
- No form-abandoner retargeting audience → Medium.
- Custom audiences stale (>180 days) → Medium.
- No phone field on Instant Forms → Medium.

### Fix voice

`analytics-engineer` (primary) | `sahil-lavingia` (backup).

The fix is operational, measured, and pragmatic. Audience + offer drive the lion's share of performance; creative testing without volume is theater; learning-phase respect is non-negotiable. The voice is "here's the structure that lets the algorithm work," not motivation.

Internal rule: never name the practitioner in the fix prose (per `references/voiced-remediations.md`).

### Worked fix example

> The account is over-split. Twelve campaigns running simultaneously, each at $10/day, none accumulating enough conversions to exit learning. Consolidate.
>
> One CBO per business goal. If the goal is lead generation, that's one campaign. Add ad sets inside it for meaningfully-different audience hypotheses, not for "let's try this variation." Three to six ad sets at launch; daily budget per ad set is three to five times the target CPA. If target CPA is $40, ad-set budget is $120-200/day minimum; lower budgets cannot optimize because the algorithm needs roughly 50 conversions in the learning phase to commit a direction.
>
> Ad-set learning phase. Seven days, no edits. The temptation at day 3 is to "fix" a metric that looks wrong; that resets the learning and discards every signal accumulated. Helicopter parenting kills the campaign before it can perform. Wait the seven days, judge after fifty conversions, then act on real data.
>
> Creative per ad set. Three to six ads at launch. Each ad is the same base 30-45-second script with a different first-three-second hook. One script, five-to-ten hook variations: a different opening line, a different background, a different angle. Each hook variation is a fresh ad to Meta's fatigue algorithm. Refresh the hooks every three to four weeks for local audiences, every six to eight weeks for broader audiences.
>
> Audience. Demographic-only targeting fits every competitor; the brand looks like everyone else to the auction. Add psychographic + behavioral layers — interests adjacent to the buyer's actual life, behaviors that predict purchase, lookalikes built on the top 20% of current customers by lifetime value. Cold audience size for US targeting is 500k-1M; smaller is hard to learn against, larger washes out specificity.
>
> Lead form. Minimum fields. Email + phone is the floor; the phone enables SMS retargeting + bot filtering. Each extra field costs roughly 5-15% of completions. Required fields are required for a reason or they don't exist.
>
> Conversions API. Pixel alone leaks roughly 20-30% of iOS conversions. CAPI server-side recovers what pixel can't see. Both running, deduplicated via event_id.
>
> Form-abandoner custom audience. Instant Form openers who didn't submit are the highest-intent retargetable cohort the account has. Build the audience; run a retargeting ad with a testimonial-heavy creative. The cost per re-engaged lead is typically half the cost per cold lead.

Read `references/meta-ads-account-health.md` for the full playbook this cat condenses, including the Marketing Rule of Seven sequence (cold → 25/50/75% video retargeting → proof ad → lead form) and the 40/40/20 attribution model (40% audience, 40% offer, 20% creative).
