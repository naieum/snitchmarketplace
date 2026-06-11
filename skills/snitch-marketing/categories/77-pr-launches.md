## CATEGORY 77: PR, launches, press surface

In 2026 traditional press pitching is the LAST step, not the first. The launch sequence that works now:

1. **Founder posts the announcement** on personal LinkedIn / X / Substack (cross-reference Cat 84). Personal account = personal trust = better engagement than the brand account.
2. **Hacker News submission** at 8am ET on a Tuesday/Wednesday for tech / dev / infra products. The community decides if it's interesting; press follows traction, not pitches.
3. **Product Hunt launch** at 12:01am PT. Hunter is the founder. Top-5 placement compounds for 30+ days.
4. **Niche newsletter / podcast announcements** through pre-arranged sponsorships or relationships (cross-reference Cat 85).
5. **Creator partnerships** time their content to coincide (cross-reference Cat 83).
6. **Traditional press pitch** comes AFTER the above generate signal. Journalists cover what's already trending; cold pitches fail because they're cold.

The press kit / `/press` page exists as a follow-on for journalists who DO show up after the launch generates signal. It's a landing page for inbound press interest, not the activator.

Audit covers: launch infrastructure (HN/PH ready, founder-led announcement), press kit completeness for inbound, surfaced press coverage, founder publishing cadence.

### Pre-flight: PR maturity check

Confirm STEP 0.6 classified PR presence as `minimal` or `established`. If `none` (no third-party press, no Product Hunt launch, no founder-published essays), **Skip** with reason `no detectable press coverage yet; recommendation pending in STEP 5`.

### Evidence required (do not skip, only when maturity is `minimal`+)

**Crawl mode, required tool calls:**

1. Search `"<brand>" site:techcrunch.com OR site:theverge.com OR site:wired.com OR site:venturebeat.com OR site:producthunt.com OR site:news.ycombinator.com`. Quote results.
2. Check brand site for `/press`, `/media`, `/news` routes, press kit indicates outreach maturity.
3. Search Hacker News (https://news.ycombinator.com/from?site=<domain>) for the brand's submissions.
4. Check Product Hunt (https://www.producthunt.com/products/<brand>) for launch records.

### Forbidden claims

- "Brand has had no press." Either you searched and found none, or you didn't search. Show.

### Detection

Search-based, off-site.

### What to Search For

Press surfaces:
- TechCrunch, The Verge, Wired, Ars Technica, VentureBeat, Hacker News, Product Hunt
- Industry publications (varies by niche, InfoQ for dev, MarTech for marketing, etc.)
- `/press`, `/media`, `/news` routes on the brand site
- `media-kit.zip`, brand assets download links

### Actually Hurts the Marketing Surface

- **Press kit missing** (when product has been live >6 months and warrants it).
  Evidence required: site age + missing `/press` route.
- **Product Hunt never launched** (when product fits PH audience).
  Evidence required: PH search returning empty.
- **HN submissions never** (when product fits HN audience, dev tools, infra, productivity).
  Evidence required: HN site search returning empty.
- **No founder-published content** (no Medium, Substack, dev.to articles by founder/team).
  Evidence required: search of common platforms returning empty.
- **Press coverage exists but not surfaced on site** ("As seen in" / "Press" section absent).
  Evidence required: third-party coverage found + no on-site reflection.

### NOT a Problem

- Stealth / pre-launch brand without press. Intentional.
- Brand that explicitly avoids PR / runs dark. Strategy.

### Context Check

1. Does the niche have relevant press outlets?
2. Is the team comfortable with PR (founder-led writing vs press-shy)?
3. Has there been a launch moment worth pitching?
4. Are there embargoed releases planned (don't push for PR before they're ready)?

### Reference

Justin Jackson on indie product launches: https://justinjackson.ca/launches

**Severity tagging:**
- No press kit on a >6mo product → Medium.
- No Product Hunt launch (when fitting) → Medium.
- No founder-published content → Medium.
- Press coverage exists but not surfaced on site → High.

**Fix voice:** `sahil-lavingia` (primary) | `tobias-van-schneider` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Pick one launch moment. A new product, a major version, a category-defining post. Write the announcement post yourself first, control the narrative.
>
> Then submit:
> - Hacker News at 8am ET on a Tuesday/Wednesday. Title is the punch line; body is one paragraph. Show up in comments.
> - Product Hunt at 12:01am PT same day. Hunter is the founder.
> - Pitch to 5-10 niche journalists with a one-paragraph email and the link.
>
> Build a `/press` page with logo files (svg + png in dark/light), brand color hex, founder bios, contact email. Links to existing coverage as it accumulates.
>
> Most launches get one window. Use the post-launch traction to seed the next quarter's PR, "this is what we shipped, and this is what users said about it."
