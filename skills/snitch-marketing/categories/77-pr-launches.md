## CATEGORY 77: PR, launches, press surface

Traditional press pitching is the LAST step, not the first: journalists cover what already has
signal, so the founder announcement, the community submissions (Hacker News, Product Hunt), the
newsletter/podcast slots and the timed creator content all come before the pitch. This category
audits what that leaves on the site — is the launch infrastructure in place, is the press kit
complete for inbound, is coverage surfaced, is the founder publishing. Designing the launch
sequence itself is generation work: call the Skill tool with "snitch-cmo".

The press kit / `/press` page exists as a follow-on for journalists who DO show up after the launch generates signal. It is a landing page for inbound press interest, not the activator.

Audit covers: launch infrastructure (HN/PH ready, founder-led announcement), press kit completeness for inbound, surfaced press coverage, founder publishing cadence.

### Pre-flight: PR maturity check

Confirm STEP 0.6 classified PR presence as `minimal` or `established`. If `none` (no third-party press, no Product Hunt launch, no founder-published essays), **Skip** with reason `no detectable press coverage yet; recommendation pending in STEP 4`.

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

### The angle (the definition the pitch finding is scored against)

Journalists and podcast bookers accept **angles**, not products: a provocative, true claim adjacent
to the product that a non-customer would care about. A pitch that leads with what the product does,
rather than with a claim, is the finding below. Writing the angle — and the newsjacking cadence
that keeps a supply of them — is generation work: call the Skill tool with "snitch-cmo".

### Actually Hurts the Marketing Surface

- **Press kit missing** (when product has been live >6 months and warrants it).
  Evidence required: site age + missing `/press` route.
- **Outbound PR pitches the product, not an angle** (pitch materials / press releases that
  describe features and funding instead of a claim an editor would cover).
  Evidence required: press-release or pitch copy quoted, showing product description with no
  angle a non-customer would care about.
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

The launch sequence above is distilled from a large body of indie-product launch write-ups by founders who published what actually worked. Treat it as a pattern, not a rule.

**Severity tagging:**
- No press kit on a >6mo product → Medium.
- No Product Hunt launch (when fitting) → Medium.
- No founder-published content → Medium.
- Press coverage exists but not surfaced on site → High.
- PR materials pitch the product instead of an angle → Medium.

**Fix voice:** `indie-commerce-founder` (primary) | `brand-surface-designer` (backup).

Read `souls/indie-commerce-founder.json` before writing the Fix.

Worked fix example:

> Build the `/press` page the pitch points at: logo files (svg + png in dark/light), brand color hex, founder bios, a contact email, and links to coverage as it accumulates. Without it, a journalist who does show up leaves.
>
> Surface the coverage you already have — a logo strip or a `/news` list — so the next editor can see someone else went first.
>
> Rewrite the pitch materials so they lead with a claim an editor would cover rather than with the feature list. Choosing that claim, and sequencing the launch it attaches to, is generation work: call the Skill tool with "snitch-cmo".