## CATEGORY 74: Customer feedback & social proof (reviews, testimonials, NPS, case studies)

The signals that say "real people use this and like it." Reviews on third-party platforms (G2, Capterra, Product Hunt, Trustpilot, app stores), testimonials on the site, case studies, NPS / CSAT measurement.

These signals feed the Authoritativeness and Trust layers of `references/eeat-assessment.md` — when a finding here maps to an E-E-A-T gap (no named testimonials, no third-party reviews assistants can read), name the layer so the fix ties back to citation authority (cross-reference Cat 82, `references/brand-authority-platforms.md`).

### Pre-flight: customer presence check

If the brand has zero customers yet (pre-launch / pre-revenue), this category is premature. Mark **Skip** with reason `no customer base yet to gather feedback from; revisit after first paying customers`. If the brand has customers but no visible feedback program, that's the actual finding.

### Evidence required (do not skip, only when customers exist)

**Source mode, required tool calls:**

1. `Grep` site for testimonial / review components: `<Testimonial>`, `<Review>`, `<CaseStudy>`, `<CustomerLogo>`. Quote each.
2. `Grep` for NPS / CSAT tooling: `delighted.com`, `wootric`, `survicate`, `typeform.com/survey`, custom in-product survey hooks.
3. `Read` the testimonials page if it exists. Audit: real names, real photos, real companies, attributed quotes.

**Crawl mode, required tool calls:**

1. Search for the brand on G2, Capterra, Trustpilot, Product Hunt, Reddit. Capture review counts + average rating.
   - **Tooling caveat:** G2 / Capterra / Trustpilot listings are JS-rendered and often region-gated — a plain `Fetch` may return a shell or a consent/gated page with no count or rating. Use a browser/Playwright or `WebSearch` tool IF one is present, else ask the user to paste the count/rating, else **Skip-with-reason**; do not assert review counts or averages you can't see (Rule 1).
2. Inspect site for: customer-logo wall above-fold, named testimonials with photos, dedicated case studies.

### Forbidden claims

- "Testimonials may be fake." If you can't verify the customer is real, don't claim fake, flag for human review.
- "Reviews probably low." Quote the count + average from the platform.

### Detection

Site-side: testimonial / case-study components. Off-site: review-platform presence.

### What to Search For

Component patterns:
- `<Testimonial`, `<Review`, `<CaseStudy`, `<CustomerLogo`
- Logo cloud sections / `<LogoBar>`
- "Trusted by" / "Loved by" copy patterns
- Star rating components

Case study substance patterns:
- Symmetric metric panels (same metrics shown for "Before" and "With" — not different metrics on each side)
- "Before / With" linguistic frame (not "Before / After"; "With" implies ongoing, "After" implies the customer can leave)
- Time-bounded outcomes ("in 90 days", "Q1 2026", not "since using us")
- Honest second-order consequences (hiring, infra, training, operational ripple — the paradox pattern)
- Forward-looking forecast tied to the win (Month 3 / 4 / 6 hiring plan, infra roadmap, expansion sequence)
- Named customer + role + company context (industry, size, region, not just a logo)

Off-site:
- `g2.com/products/<brand>`
- `capterra.com/p/<brand>`
- `trustpilot.com/review/<domain>`
- `producthunt.com/products/<brand>`

### Feedback as message research (not just proof)

Reviews are double-duty assets: proof for the visitor, and the raw material for the copy
itself. Two mining moves the audit checks for:

- **Voice-of-customer language mining.** The customer's own vivid, emotional words about the
  problem — from the brand's reviews, Reddit/forum threads, YouTube comments, support
  tickets — should be the language of the headlines. The checkable mismatch: site copy
  speaks in internal jargon while every review describes the problem differently. (Worked
  case from the source: a soap brand's reviews revealed customers using the product for a
  use the brand never advertised — the reviews contained the winning message.) Research
  prompts worth handing the team: what's the most frustrating part in the customer's own
  words; what did they try that felt like wasted money; what made them finally say "I can't
  deal with this anymore."
- **Competitors' 3-star reviews.** 5-star reviewers love anything; 1-star reviewers have a
  grudge; 3-star reviewers *wanted to like it and didn't* — a list of legitimate, fixable
  complaints. The offer and the comparison copy should be built as the explicit counter to
  that list (James Clear mined the 3-star reviews of every habits book before writing
  Atomic Habits). Audit: do the brand's differentiation claims answer complaints actually
  found in the category's reviews, or founder-imagined ones?

When soliciting UGC/testimonial video, spec it like a director or you get unusable rambles:
exact length ("under 15 seconds"), exact shots ("only the last pass, then the cut"), and a
visible reward ("if we like it, we'll tag you"). This belongs in the fix, not a finding.

### The review-ask compliance line (review gating)

Review gating — pre-screening customers by sentiment and only routing the happy ones to a
public review platform — is not an optimization, it is a violation. The FTC's Consumer
Reviews and Testimonials Rule (16 CFR Part 465, effective October 2024) prohibits review
suppression, with civil penalties per violation; Google's review policy separately prohibits
discouraging negative reviews or selectively soliciting positive ones, and enforcement
includes review removal and Business Profile suspension. Widely-copied tutorials teach this
pattern as a "review funnel," so expect to find it built in good faith — the finding should
educate, not accuse.

The gate is detectable in code. Search for:

- A rating widget or survey that **branches on score**: `rating >= 4` / `stars > 3` (or a
  thumbs up/down) where the high branch redirects to a public review URL
  (`search.google.com/local/writereview`, `g.page/r/`, `google.com/maps` write-a-review,
  Yelp/Trustpilot/app-store equivalents) and the low branch routes to an internal form,
  `mailto:`, or a support endpoint.
- Interstitial "How was your experience?" pages/components (`ReviewGate`, `ReviewFunnel`,
  `FeedbackFilter` and similar names) that sit between the customer and the public review
  link.
- Review-funnel tool embeds configured with a sentiment pre-screen ahead of the public
  review CTA (the configuration is the violation, not the vendor).

The compliant shape to recommend in the fix: ask **every** customer, at a good moment
(post-service, post-support-resolution), with the public review link and a private feedback
channel offered **alongside each other, unconditionally** — never sequenced behind a
sentiment check. Internal NPS/CSAT surveys are fine on their own; they become a gate only
when the public-review ask is conditioned on the score.

### Actually Hurts the Marketing Surface

- **Review gating: sentiment pre-screen ahead of the public review ask** (legal/compliance
  violation, flagged regardless of any conversion or rating lift it produces).
  Evidence required: the branch quoted with file:line — the score condition, the public
  review URL in the high branch, and the internal-only route in the low branch (or the
  gating interstitial component and both its exits). In crawl mode: the interstitial
  survey URL + the observed conditional redirect.
- **No testimonials / social proof on commercial pages**.
  Evidence required: pricing / signup / homepage with no testimonial section.
- **Site copy language doesn't match customer language** (headlines in internal jargon while
  the brand's own reviews describe the problem in consistent, different words).
  Evidence required: 3+ review quotes using one vocabulary + hero/headline copy quoted using another.
- **Testimonials with no attribution** (anonymous "Great product!" quotes).
  Evidence required: quoted testimonial without name / company.
- **Stock-photo customer photos** (suggests fake testimonials).
  Evidence required — a PROVABLE signal (mirror Cat 119): a stock-CDN host/URL or filename (e.g. `images.unsplash.com/…`, `istockphoto`, `shutterstock`, `gettyimages`, `pexels`, `…/stock-photo-…`), stock-library EXIF/credit metadata, OR the same image reused across multiple testimonials / found elsewhere via reverse-image search. Self-hosted stock with a generic filename is NOT detectable from the toolset alone — when no provable signal is present, do NOT tag Critical; flag for human review per the guard above (`if you can't verify the customer is real, don't claim fake, flag for human review`).
- **No third-party reviews** (no G2, Capterra, Trustpilot listing).
  Evidence required: search results returning no listings.
- **NPS / feedback tooling installed but never reviewed** (data collected, no insights extracted).
  Evidence required: tool installed + no review cadence.
- **Customer logos used without permission** (legal risk).
  Evidence required: logo wall + missing public partnership announcement.
- **Case studies with no concrete numbers** ("saved time", "boosted growth" without quantification).
  Evidence required: case study page content with no numeric claims.
- **Asymmetric Before/After panels** (different metrics on each side, no apples-to-apples comparison).
  Evidence required: panel content quoted, showing metric mismatch.
- **Case studies that hide tradeoffs / second-order consequences** (every customer story is a clean win, no acknowledgment of operational ripple).
  Evidence required: case study set with zero mention of hiring needs, infra changes, training costs, or other consequences of the success.
- **Case studies without time-bounded results** (claims like "since using X" with no measurement window).
  Evidence required: outcome claim quoted without a duration.
- **Case studies with no forward-looking forecast** (story stops at the win; no acknowledgment of the customer's next chapter).
  Evidence required: case study set with retrospective metrics only, no "what's next" section.
- **Case study customer named at company level only** (no role, no person, no headshot, no industry context).
  Evidence required: case study with just "Acme Corp" attribution.
- **"After" framing instead of "With" framing** (subtle but signals one-time win, not durable integration).
  Evidence required: panel label quoted.

### NOT a Problem

- Pre-launch / early-stage brand without external reviews. Premature.
- Niche product where review platforms don't exist for the category.
- Trusted-by section with NDA'd customers shown anonymously (with permission). Acceptable.
- An internal NPS/CSAT survey with no public-review ask attached — measuring sentiment is
  fine; only conditioning the public ask on it is gating.
- A page offering the review link and a "contact us with concerns" path side by side,
  unconditionally. That's the compliant pattern, not a gate.

### Context Check

1. Is the audience B2B (G2, Capterra matter) or consumer (App Store, Trustpilot matter)?
2. Is there a review-ask process, and does it ask everyone (selective solicitation of only positive reviewers violates Google policy; a coded sentiment gate violates the FTC rule)?
3. Are testimonials kept fresh or are they from 2019?
4. Is there a feedback loop between customer-success and product?
5. Do case studies use symmetric metric panels (same metrics before and after)?
6. Do case studies acknowledge any tradeoffs or second-order consequences?
7. Are outcomes tied to a specific timeline?
8. Does the case study include a forward-looking forecast (what the customer is doing next)?
9. Is the framing "Before / With" or "Before / After"?
10. Are the relevant mental models from `references/mental-models.md` applied (Social Proof, Authority Bias, Availability Heuristic, Mimetic Desire)?

### Reference

G2 review process: https://learn.g2.com/g2-reviews

**Severity tagging:**
- Review gating (sentiment pre-screen before the public review ask) → Critical (FTC rule + Google policy violation; GBP suspension risk). Cross-reference Cat 79 when the gated destination is a Google review link.
- No social proof on commercial pages → High.
- Site copy vocabulary contradicts the customers' own review vocabulary → Medium (the reviews are free message research going unused).
- Anonymous / unattributed testimonials → High.
- Stock-photo customer photos → Critical (trust violation) ONLY with a provable signal (stock-CDN URL/filename, EXIF/credit, or duplicate image); without one, route to human review, not Critical.
- No third-party review presence (B2B brand) → High.
- NPS data collected but unused → Medium.
- Case study with no concrete numbers → High.
- Asymmetric Before/After panels → Medium.
- Case studies that never acknowledge tradeoffs (set of 3+ all clean wins) → Medium.
- Case studies missing time-bound on outcomes → Medium.
- Case studies missing forward-looking forecast → Medium.
- Case study customer attribution at company-only level → Medium.
- "After" framing instead of "With" → Low.

**Fix voice:** `indie-commerce-founder` (primary) | `honest-design-critic` (backup).

Read `souls/indie-commerce-founder.json` before writing the Fix.

Worked fix example:

> Real customers, named, with their company and headshot if they consent. One testimonial above the fold on the homepage, three on the pricing page, ten on a dedicated `/customers` page. Each one solves a specific objection a future customer will have ("does this work for solo founders?", testimonial from a solo founder).
>
> Then ask the 5-10 happiest customers for a G2 / Capterra / Product Hunt review with a one-paragraph email and the direct review link. Conversion is high if you ask the right people at the right moment (right after a "thank you, this saved me X hours" support ticket).
>
> Without third-party reviews, the buyer has only your word. With them, the buyer has the social proof Google increasingly weights for trust signals.

Worked fix example — the paradox pattern (B2B services case study):

> The strongest B2B case studies surface the second-order consequence of the win. "We got more leads" reads like a brochure. "We got more leads, then hired a foreman in month 3 and two seasonal climbers in month 4 because the crew couldn't keep up" reads like a real operator talking, because operators know growth is never free.
>
> Structure:
> 1. Two panels labeled **Before** and **With** (not "After"). Same 4-5 metrics on each side (e.g., inbound/month, voicemail rate, booked rate, monthly revenue). Color-code the "With" side to make the delta visible.
> 2. One honest interpretation sentence: "That's +16 jobs a month. The crew can't do them alone."
> 3. A forward-looking hiring / infra / training plan with specific months: Month 3 — Foreman (year-round). Month 4 — Seasonal climber × 2. Month 6 — Dedicated estimator.
>
> Why it works: it answers the unspoken objection ("will this break my ops?") before the prospect asks. Brochure case studies trigger skepticism; paradox case studies trigger planning. The forecast also signals the brand understands the customer's business past the sale.
>
> Models in play: Contrast Effect (Before vs With panels), Availability Heuristic (vivid numbers make outcomes feel achievable), Pratfall Effect (admitting the operational tradeoff increases trust), Authority Bias (named role + headshot signals real customer).
