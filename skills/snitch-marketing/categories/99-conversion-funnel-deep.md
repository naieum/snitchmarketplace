## CATEGORY 99: Conversion funnel deep-audit

Cat 60 covers individual conversion + trust signals (CTAs, forms, 404 page quality). This category audits the entire **path** from first landing to conversion as one continuous unit, the journey, not the steps in isolation. A homepage can have a perfect CTA, a pricing page can have great trust signals, and a checkout form can be beautifully designed; the funnel can still be broken because the transitions between them lose the user.

The job here: trace 3-5 named user journeys end-to-end (entry → consideration → conversion → confirmation), instrument each step, identify the leakiest transition, and fix the journey rather than the page.

**Two evidence tiers (read first — this is the honesty boundary).** A source/crawl auditor can fully reconstruct the funnel's *structure, friction, and instrumentation*, but **cannot observe a single real drop-off number** without analytics access.

- **Source/crawl-detectable (assert from evidence):** the path structure, each CTA's destination, competing CTAs, dead-ends, form-field/friction count per step, and whether each step even fires an analytics event (the instrumentation).
- **Analytics-gated (never assert from crawl — "needs data"):** the actual per-step conversion %, *which* transition is leakiest, drop-off by segment/device, and time-in-step. These require GA4 Funnel Exploration / Amplitude / Mixpanel / Heap.

So **instrumentation-coverage comes before leak-hunting**: "can this funnel even be measured?" is a finding you can assert; "this step leaks 38%" is not, unless the team shares the data. Conditional trigger: *if* analytics access is provided, quantify the leak and segment it; *otherwise*, report the structural friction + the instrumentation gaps and frame the leak as a hypothesis to confirm with data.

### Pre-flight: relevance check

Skip with reason `not applicable` if the site has no conversion goal beyond reading content (pure-content / blog-only sites with no signup / purchase / demo / contact action). Otherwise: required.

### The framework: 4 stages

#### Stage 1: Name the journeys

The site has a finite number of paths to conversion. Name them concretely. Examples:

- **Cold homepage → signup**: never-heard-of-brand visitor → /home → /pricing → /signup → confirmation
- **Blog → signup**: organic-search visitor on a blog post → relevant CTA → /signup → confirmation
- **Pricing-shopper → signup**: visitor searching `<brand> pricing` → /pricing → /signup → confirmation
- **Demo-requester → SQL**: enterprise visitor → /demo → form → calendar booking → confirmation
- **Returning user → upgrade**: logged-in user → /pricing → /upgrade → confirmation

Pick the 3-5 highest-volume journeys. Each is its own audit unit.

#### Stage 2: Trace each journey

For each named journey, walk the path step-by-step. At each step, capture:

- **The page URL**
- **The CTA's exact copy** (Cat 21 cross-reference)
- **The CTA's destination**
- **The page's first impression** (above-the-fold value prop, trust signals, social proof, Cat 60 cross-reference)
- **The friction inserted** (forms, fields, login wall, payment, etc.)
- **The instrumentation** (analytics events firing per step, Cat 55 cross-reference)

Walking the journey live (incognito browser) catches what static-page audits miss.

#### Stage 3: Identify the leakiest transition

With the journey mapped + instrumented, the leakiest transition is the step where the largest percentage of users drop off. **This step is analytics-gated** — the real percentages come from GA4 Funnel Exploration (size the leaks) + Path Exploration (see what users did instead), or the equivalent in Amplitude/Mixpanel. Without that data you can name the *likely* leak from structural friction, but you cannot state a drop-off number — say "needs data," don't invent one. Common patterns (each a hypothesis to confirm with the funnel report):

| Leak | Symptom | Likely cause |
|---|---|---|
| **Homepage → /pricing** | High homepage traffic, low pricing-page sessions | Homepage doesn't lead to pricing (no clear CTA path); or value prop isn't strong enough to make the visitor want pricing |
| **Pricing → /signup** | High pricing-page sessions, low signup-page sessions | Price is too high for the value communicated; OR signup CTA placement weak; OR an alternative CTA distracts (`/contact-us` competing with `/signup`) |
| **/signup → form completion** | High signup-page sessions, low form submissions | Form too long; required fields too invasive; lack of trust signal at form |
| **Form submission → activation** | High form completions, low active accounts | Email verification flow broken; first-run experience confusing; activation requires steps the user doesn't understand |
| **Activation → first value** | Active account, no engagement | Empty state in product; no onboarding; unclear what to do first |

Each leak routes to a different fix.

#### Stage 4: Fix the leakiest transition first

A 5% improvement in the leakiest transition typically beats a 40% improvement in any other step. Funnel math: if conversion is 100 → 50 → 25 → 10 → 4, each step contributes proportionally to the final outcome. Improving the 100→50 step from 50% to 55% adds more conversions than improving the 10→4 step from 40% to 80%.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read homepage, pricing, signup, checkout, demo, contact route files. Quote CTAs, destinations, form fields.
2. Map the click path for each named journey. Quote each CTA's `to=` / `href=` value.
3. Cross-reference event taxonomy (Cat 55), does each step in each journey fire an analytics event? Quote.
4. Check for known dead-ends: forms with no error handling, signup buttons that 404, pricing CTA pointing at `/contact-us` when the page has a self-serve signup.

**Crawl mode, required tool calls:**

1. Walk each named journey in incognito browser. Capture the URL at each step + the CTA + the form fields + the time-to-load per step.
2. Test friction surfaces: signup form (how many fields? required vs optional?), demo form (how many fields? calendar required?), checkout (how many steps?).
3. Quote each step's first impression (what does the visitor see before scrolling?).

### Forbidden claims

- "The funnel is probably leaking somewhere." Walk the journey and quote each step.
- "Conversion may be hurt by friction." Identify the specific friction (form fields, login wall, etc.) and quote it.
- "Pricing may be confusing." Quote the pricing copy + the CTA + the alternative paths.

### What to Search For

- Conversion CTA copy + destinations on every page in each journey
- Form field count per signup / demo / contact form
- Friction surfaces (login walls, multi-step forms, payment gates, calendar gates)
- Analytics event coverage per step
- Trust signals at the conversion moment (testimonials near signup, security badges near checkout, money-back guarantee near purchase)
- Empty states / onboarding for post-conversion activation

### Actually Hurts the Marketing Surface

- **Named journeys not documented** (the team has not explicitly mapped which paths users take to convert; product / marketing / growth disagree on the canonical paths).
  Evidence required: missing journey docs, conflicting CTAs across pages.
- **Multiple competing CTAs at the conversion moment** (a pricing page with `Get started`, `Talk to sales`, `View demo`, `Contact us`, `Read the docs`, choice paralysis).
  Evidence required: pricing page CTA inventory.
- **No funnel instrumentation at all** — the funnel literally cannot be measured (no GA4/GTM/`dataLayer`, or no named funnel events anywhere). This is the precondition finding: report it *before* any leak claim, because without it nobody — not the team, not the auditor — can know where users drop.
  Evidence required: source scan showing no analytics tag and/or no funnel events.
- **Funnel step with no analytics event** (the team can't see drop-off because the step isn't instrumented).
  Evidence required: missing event from event taxonomy (Cat 55).
- **Form with >5 fields on a signup that should be email-only** (each additional field costs ~10% completion in benchmark data).
  Evidence required: form field count.
- **Trust signal absent at conversion moment** (no testimonial / logo / guarantee on the signup or checkout page).
  Evidence required: page content + missing trust elements.
- **Mobile journey broken** (CTAs invisible on mobile, form unusable, payment fails). Cross-reference Cat 45-49.
  Evidence required: mobile-walked journey + specific failure point.
- **Post-conversion empty state with no onboarding** (user signs up, lands in product, sees a blank dashboard, churns).
  Evidence required: post-signup screen content.
- **Pricing CTA dead-ends to a contact form** when self-serve signup exists (forces every prospect through sales).
  Evidence required: pricing CTA destination + visible self-serve option that's not the default.

### E-commerce checkout extension (cart-tier thresholds + order-bump + popup timing)

E-commerce funnels have three structural surfaces that go beyond the "is the form usable?" pass above:

**Cart-tier thresholds.** Single-threshold free shipping ("free shipping over $50") under-leverages the cart psychology. Multi-tier thresholds — free shipping at 1.25× AOV, 10% off at 1.5× AOV, free gift at 2× AOV — give the buyer multiple incentive ladders to climb. Audit application: capture the brand's current free-shipping threshold and AOV (from analytics or industry-standard estimate). Findings: single-threshold-only structures get a "test multi-tier" recommendation. Threshold set below current AOV ("free shipping over $40" when AOV is $55) gets a "raise the bar; the threshold should pull buyers up, not reward existing behavior" recommendation. Threshold set wildly above AOV (>2× current AOV) gets a "buyers ignore it; lower to 1.25-1.5×" recommendation.

**Order-bump pricing.** A single-line offer at the cart for a complementary item priced at 30-50% of the primary order, with one-click add. Common pattern: the buyer's primary purchase is $80; the order bump is $25-40 for an accessory / extended warranty / digital companion. Take-rates in the 15-25% range are typical. Audit application: capture the brand's cart page. Findings: no order bump on a brand with multiple SKUs is a Medium finding ("test it"). Order bump priced too high (>60% of primary) or priced too low (<20%) tests poorly; adjust toward the 30-50% band.

**Exit-intent vs time-delayed popup distinction.** Popups are not categorically bad — but the implementation determines whether they help or hurt conversion.

- **Exit-intent popups** (triggered on cursor leaving the viewport / browser tab) are acceptable: the buyer was leaving anyway; the popup is a recovery attempt, not an interruption.
- **Time-delayed popups** on high-intent pages (pricing, product detail, checkout) at 10-30 seconds are user-hostile: the buyer is actively reading the page; the popup interrupts the conversion flow.
- **Time-delayed popups** on top-of-funnel pages (homepage, blog post) at 30-60 seconds are debatable: lower-intent visitor, the email capture has higher trade-off value, but the buyer may still find it intrusive.

Audit application: walk the brand's high-intent pages with timing. Findings: time-delayed popups on pricing / product-detail / checkout pages are High findings. Time-delayed popups elsewhere are Low/Medium advisory. Exit-intent popups everywhere are not findings.

### Dimensions the single-session funnel misses

A "home → pricing → signup" trace is one slice. These dimensions change the picture — note which are source-detectable vs analytics-gated:

- **New vs returning** — materially different funnels (first-timers can show ~80% add-to-cart drop vs ~50% for returners; payment-step trust hits new visitors hardest). *Detectable:* does the site differentiate (saved progress, trust at commitment)? *Gated:* the segment split. Cross-ref Cat 73.
- **Mobile vs desktop** — mobile is the majority of traffic but converts ~half (Baymard cart abandonment ≈ 80% mobile vs 66% desktop). The same form/payment friction hurts mobile disproportionately; an aggregate funnel hides a mobile cliff. *Detectable:* mobile field count, wallet/Apple-Pay support, responsive form behavior. *Gated:* the device split. Cross-ref Cat 45-49.
- **Cross-device / multi-session** — the journey spans devices and visits; the conversion isn't one session. *Detectable:* whether login / persistent user-ID enables stitching. *Gated:* the stitched path.
- **Attribution sanity** — last-click misreads multi-touch journeys (GA4's default is data-driven since Jan 2024; B2B averages 6-8 touchpoints). Flag reliance on last-click. *Analytics-gated entirely.*
- **Micro-conversions / leading indicators** — only ~2.9% complete the macro conversion, so email-capture / pricing-view / doc-view are faster diagnostic signal. *Detectable:* are they instrumented as events (Cat 55)? *Gated:* their rates.
- **B2B buying group / dark funnel** — the form-filler is rarely the economic buyer; ~73% of B2B buying is unattributable and ~61% of the journey happens before first contact. *Detectable:* presence of champion-enablement assets (ROI calculator, business case, comparison pages). A single-visit form-submit funnel structurally under-measures B2B.
- **Scroll depth as a fallback proxy** — when step events are missing, scroll depth (a proxy for attention, not reading) + time-on-page is a weak substitute. *Detectable:* whether scroll tracking exists at all.
- **Post-conversion = Setup → Aha → Habit** — activation isn't "signup completed." Measure to the first *habit loop*, not setup. The Aha moment is the first time the user grasps core value; Time-to-Value is the median time to reach it. The common mistake is stopping activation work at setup. *Detectable:* onboarding steps, empty-state quality. *Gated:* activation rate, TTV.

### Honesty guardrails (do not violate)

- **No leak claim without sequenced instrumentation.** Seeing page A get more traffic than page B is not a funnel — without per-step events on the *same users in sequence*, you can't claim a drop-off. The finding is the missing instrumentation, not an invented number.
- **Correlation ≠ causation.** A step that correlates with non-conversion isn't necessarily causing it; confirm a fix with an A/B or geo test (Cat 73), don't assume.
- **Intent-adjust early drop-off.** A top-of-funnel "leak" is often just low-intent traffic (broad ads, accidental clicks) that was never going to convert. Read drop-off against intent and source.
- **Watch survivorship / consent blindness.** Analytics only sees users who tracked through consent + cross-device; consent-blocked and multi-device users are the missing failures. Don't treat the measured sample as the whole.

### NOT a Problem

- A B2B brand whose journey legitimately requires sales (high-ticket, complex implementation), `Contact us` is the right CTA, not a leak.
- A multi-step checkout that's industry-standard (e.g., e-commerce with shipping → payment → review).
- An empty state that's actually well-designed (clear next action, sample data, video tour), not a leak.
- Brands with a single-tier free-shipping threshold *set at the right level* — multi-tier is a test recommendation, not a strict requirement.
- Exit-intent popups even on high-intent pages — the trigger condition (buyer leaving) makes them acceptable.

### Context Check

1. What's the named primary conversion? Without naming it, every page CTA conflicts.
2. Are the named journeys documented somewhere a designer / engineer / marketer can read?
3. Is event taxonomy (Cat 55) covering every step?
4. Is the leakiest transition known? If not, fix the instrumentation first; you can't optimize what you can't see.
5. Has the team prioritized fixing the leakiest transition vs spreading effort across all steps?
6. Does the journey follow the AIDA arc (Attention → Interest → Desire → Action)? Map each step to a stage and flag stages without dedicated surfaces.
7. Are Goal-Gradient signals (progress bars, completion percentages) present on multi-step paths?
8. Are Zeigarnik recovery hooks (abandoned-cart, half-completed-profile follow-ups) in place?
9. Cross-reference Cat 114 §4 (Friction) and §7 (Follow-Through) for the holistic score, and `references/mental-models.md` for the model definitions.

### Reference

Funnel analysis fundamentals (Reforge): https://www.reforge.com/blog

GA4 Funnel Exploration: https://support.google.com/analytics/answer/9327974 · GA4 Path Exploration: https://support.google.com/analytics/answer/9317498

Form field count + cart abandonment (Baymard Institute): https://baymard.com/research · https://baymard.com/lists/cart-abandonment-rate

Micro-conversions (Nielsen Norman): https://www.nngroup.com/articles/micro-conversions/ · Activation / Aha moment (Amplitude): https://amplitude.com/blog/aha-moment

CRO discipline + measurement integrity (Cat 73 cross-ref).

**Severity tagging:**
- Named journeys undocumented → High.
- Competing CTAs at conversion → High.
- No funnel instrumentation at all (funnel unmeasurable) → High (precondition; report before any leak claim).
- Funnel step with no analytics event → High.
- Form with >5 fields when email-only would suffice → High.
- Trust signal absent at conversion → Medium.
- Mobile journey broken → Critical.
- Post-conversion empty state without onboarding → High.
- Self-serve dead-ended into sales contact → High.

**Fix voice:** `sahil-lavingia` (primary) | `analytics-engineer` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> The funnel is one thing, not five things. Audit it as one thing.
>
> Pick the highest-volume journey. Walk it in incognito, on mobile, like a customer who has never heard of you. At each step write down what you saw, where the CTA went, what the next page asked of you, what the friction was. The output is a one-page document, five rows, one per step.
>
> Now find the leak. The step where the percentage drop is biggest is where the next quarter's work goes. Improving the leakiest step is the highest-leverage move; improving steps that aren't leaking is rearranging deck chairs.
>
> Cut competing CTAs. Each page in the journey has ONE primary action. Secondary actions exist as text links, smaller, lower contrast, below the fold. The visitor's job is to keep moving down the funnel; your job is to make that the easy choice.
>
> Trust at the conversion moment. The signup page is not the page to be modest. Show a logo bar of customers, one specific testimonial, a money-back or cancel-anytime promise. People who reach this page are interested; the conversion friction is the gap between interest and action.
>
> Then ship. The funnel is a system, not a perfect artifact. The team that walks it once a month, picks the leakiest step, and ships a fix beats the team that argues about the perfect funnel design.
