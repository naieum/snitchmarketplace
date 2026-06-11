## CATEGORY 111: Trust artifact audit

A new visitor arriving at the brand from a paid click, a Reddit recommendation, or an organic search is in a 30-second decision: is this real? The site has 6-8 specific trust artifacts that answer that question, and the absence of each one weakens the conversion. Cat 60 covers individual conversion CTAs and trust signals; Cat 74 covers customer feedback inventory; Cat 84 covers founder presence; Cat 96 covers brand SERP defense. This category synthesizes those threads into one ordered week-one fix list, so the customer knows exactly what to ship in priority order.

### Pre-flight: relevance check

Run on every brand. The trust gap exists for indie SaaS, content publishers, e-commerce, services, and personal brands alike. The specific artifacts vary by business type but the audit pattern is universal.

Skip with reason `not applicable` only on internal-only sites with no external visitors (rare).

### The 6-artifact ordered list

The fixes ship in this order because each prerequisites the next. Don't ship #4 (privacy page) before #1 (founder face) on a single-founder brand, because the privacy page's specificity depends on the founder being identified.

1. **Founder face on homepage** (or for multi-person companies: a "Built by [team]" line with photos).
2. **Three real testimonials** with name, role / company, photo or social handle.
3. **Live changelog or "What we shipped this week" surface.**
4. **Honest, specific privacy page** that names the data flow, retention, deletion timing, and contact email. Not "we value your privacy."
5. **A "Things X is NOT the right fit for" section.** Counter-intuitive trust artifact: naming what the product doesn't do increases credibility on what it does.
6. **Public status page** (e.g., `status.{domain}.com`). Even at 99.99% uptime, the existence signals "real software company, not a side project."

### Evidence required (do not skip)

**Source mode:**

1. `Grep` for founder identification on `/about` and homepage. Look for personal name, photo, "Hi I'm" copy, founder bio. Quote presence or absence with file:line.
2. `Grep` for testimonial components / customer quote sections on the homepage and conversion-flow pages. Count named testimonials with role + photo / social handle. Strip generic "great product!" without attribution; those don't count.
3. Check for a `/changelog`, `/updates`, `/whats-new`, `/releases`, or an in-app changelog component. If present, sample the dates: is it actually updated weekly / monthly? Stale changelog is worse than absent changelog.
4. Read `/privacy`. Quote whether it names: data flow, retention period, deletion mechanism, contact email. Generic "your privacy is important to us" without specifics fails the audit.
5. `Grep` for a "not for" section / "who this is NOT for" on the homepage or about page. Most sites lack this; flag absence.
6. Check for a status page link in footer / about / docs. Common patterns: `status.{domain}`, `/status`, `<link href="https://status.{domain}.com">`. If absent, flag.

**Crawl mode:**

1. `Fetch` the homepage and `/about`. Inspect for the 6 artifacts above.
2. For changelog: visit the URL if present; sample the most recent dates.
3. For status page: try common URL patterns (`status.{domain}`, `/status`); confirm it returns 200 and shows real component status.

### Forbidden claims

- "Founder presence is probably absent." Confirm by reading `/about` and homepage; quote what's there.
- "Testimonials may not be real." Quote them; check for named role + photo / handle. Generic anonymous quotes fail the audit on attribution, not on truthfulness.
- "Privacy page is probably generic." Quote the page; show whether it names data flow + retention + deletion specifically.

### What to Search For

- Founder name + photo on `/about` and homepage
- "Hi, I'm [name]" or "I built X" first-person copy
- Testimonial components with `name`, `role`, `company`, `photo`, `quote` fields populated
- Changelog routes: `/changelog`, `/updates`, `/whats-new`, `/releases`
- Privacy page specificity: data flow, retention duration, deletion mechanism, contact email
- "Not for" / "not a good fit" / "honest about" sections
- Status page link, status subdomain, third-party status (BetterStack, Statuspage, Instatus, Hund)

### Actually Hurts the Marketing Surface

- **No founder name or photo on `/about` for an indie SaaS or personal brand**.
  Evidence required: `/about` content quoted; founder absent.
- **Zero named testimonials on a brand >6 months old**.
  Evidence required: homepage and conversion-flow pages quoted; no named testimonial with role + photo / handle.
- **Anonymous "Customer X said..." testimonials only**.
  Evidence required: testimonials present but missing attribution.
- **No changelog or stale changelog (>3 months since last entry)**.
  Evidence required: missing route OR latest entry date older than 3 months.
- **Generic privacy page** ("your privacy is important to us") without specifics.
  Evidence required: privacy page content quoted with missing specifics.
- **No "not for" section** on a positioning-sensitive brand.
  Evidence required: `/about` and homepage content; missing artifact.
- **No public status page** for a SaaS / API product.
  Evidence required: footer, docs, about page links checked; no status page reference.
- **Status page exists but is a landing page, not real status** (no component statuses, no incident history).
  Evidence required: status page content quoted.

### Review acquisition timing risk (for brands with on-site review CTAs)

Reviews on Google / Yelp / industry directories are trust artifacts that compound across customers. The acquisition mechanism — *when and where* the brand asks for the review — affects both acquisition rate and the risk of Google's review-filtering algorithm dropping the review entirely. The audit checks:

1. **Where does the brand ask?** On-site at job close (e.g., the customer scans a QR code on the contractor's truck while standing on the brand's property) is a penalty-risk pattern. Google's algorithm can correlate review-submission lat/long with the business's lat/long; reviews submitted from within roughly 50 meters of the business address get silently filtered in some categories (most aggressively in home services and local trades). The brand thinks it's collecting reviews; Google never shows them.
2. **When does the brand ask?** The safe window is 2 hours post-visit via SMS or email, after the customer has left the business's location. The customer is still fresh on the experience; the geo-correlation is gone.
3. **How does the brand ask?** Generic "please review us" links read as transactional and trigger lower response rates. Short, named, specific questions ("Hope the install in Plano went smoothly — would a quick Google review help us reach more neighbors?") convert better.
4. **What's the cadence?** Going from 5 reviews to 50 in one week triggers velocity-anomaly filters. The safe ramp is 1-3 new reviews per week sustained over months.

Audit application:

1. From the brand's site, identify any review-request surfaces (QR codes, in-product prompts, footer links to "leave a review", post-checkout pages, automated email/SMS sequences). Quote them.
2. Identify the trigger: is the review asked while the customer is on-site, immediately after, or hours / days later?
3. Findings:
   - **On-site review CTA active on a local business** (QR code on truck, in-shop kiosk, "review us before you leave" link) → High finding. Google filters; the brand burns trust + loses reviews to the algorithm.
   - **No documented review-request flow** on a brand >6 months old with <20 reviews → High finding. Trust artifacts under-leveraged; cross-references the "zero named testimonials" pattern above.
   - **Review-request flow exists but uses generic language** → Medium finding. Sharpen the messaging; acquisition rate is leaving signal on the table.
   - **Review velocity spike pattern detected** (10+ reviews in one week after months of 0-1/week) → Medium advisory. Spread the cadence; Google's filters are calibrated against unnatural ramps.

Cross-references `references/local-services-playbook.md` for the broader review-acquisition cadence (1-3/week sustained over months) and the messaging templates.

### NOT a Problem

- B2C brands without status pages (most consumers don't check; status pages are SaaS / API conventions).
- Brands explicitly opting out of testimonial display for legal reasons (e.g., regulated industries) where the choice is documented.
- Single-founder brand surfacing one founder; multi-founder brands surfacing the team.
- Solo content site / personal blog where the brand IS the founder; the founder face is the homepage.
- Online-only businesses with no physical location where the review-acquisition geo-penalty doesn't apply.
- Brands with mature review acquisition (steady 1-3/week cadence sustained) that occasionally spike on a launch event — the consistent baseline absorbs the spike's velocity-anomaly risk.

### Context Check

1. What's the buyer's first impression on landing? The first 30-second scan should answer "is this real?"
2. Is there a single-founder reality (founder face is highest-leverage) or a multi-person team (team page is the analog)?
3. What's the changelog cadence? Weekly is the bar for "live"; quarterly is "alive but slow"; nothing in 6 months is "abandoned-feeling."
4. Does the privacy page survive a paranoid reader's 30-second skim? Specificity beats reassurance language.
5. Is the brand selling to enterprise / regulated buyers? Then add: SOC 2 mention if real, security page, named DPO, named compliance officer.

### Reference

Cross-reference Cat 60 (conversion + trust signals at the conversion moment).
Cross-reference Cat 74 (customer feedback inventory + social proof).
Cross-reference Cat 84 (founder-led brand channel).
Cross-reference Cat 96 (brand SERP defense, includes "your name is the brand SERP").

**Severity tagging:**

- No founder name on `/about` for indie SaaS / personal brand → High.
- Zero named testimonials on >6mo brand → Critical.
- Anonymous-only testimonials → High.
- Generic privacy page (no specifics) → High.
- No changelog OR stale > 3 months → Medium.
- No "not for" section → Low (advisory; counter-intuitive trust signal).
- No public status page on a SaaS / API → Medium (Low for B2C).

**Fix voice:** soul slug per `references/voice-mapping.md`.

Worked fix example:

> Trust isn't earned through reassurance language; it's earned through specificity. Six artifacts, in this order, ship in week one.
>
> 1. Founder face on the homepage. "Hi, I'm [name]. I built X because [real reason]. You can email me at [direct email]." Worth more than three testimonials.
> 2. Three real testimonials: name, role, company, photo. One-line quotes work. Anonymous "this product changed my life" testimonials are worse than no testimonials.
> 3. A live changelog. "Things shipped this week" surface, updated weekly. The product looks alive even if the homepage hasn't changed.
> 4. An honest, specific privacy page. Don't say "your privacy is our priority." Say: "Audio leaves your machine, hits the [API], comes back as text, audio is deleted within 60 seconds. We do not retain transcripts. Here's the exact request flow: [diagram]." Specificity is trust.
> 5. A "Things X is NOT the right fit for" section. Counter-intuitive. Listing what the product doesn't do (or "if you need on-device, use [competitor]") makes everything else more believable.
> 6. A public status page. Even if uptime is 99.99%, the existence of `status.{domain}.com` signals real software company.
>
> Then run a customer-discovery pass (per `references/customer-discovery-script.md`) and replace the trust strip with three named testimonials within 30 days.
