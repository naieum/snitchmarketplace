## CATEGORY 60: Conversion & trust (CTAs, forms, trust signals, trust artifacts, 404 recovery)

The point-in-time conversion-design surface: are CTAs clear and specific? Are forms minimal and frictionless? Are trust signals present and *specific* (named testimonials, logos, security at the decision moment, guarantees)? Are the six trust artifacts a first-time visitor looks for actually on the site? Is the 404 a recovery surface or a dead end? Cat 99 audits the funnel *journey*; Cat 73 the CRO *discipline*; Cat 114 §4 the *holistic* friction read; Cat 103 the WCAG criteria the same form markup fails; Cat 5 the HTTP status a not-found route returns. This category audits the *elements* on the page, and the trust artifacts behind them (absorbed from the former Cat 111).

**Boundary with snitch-ux.** This category judges a CTA on **outcome specificity** — does the label name what the user gets, is the promise the page made kept at the button. Whether swapping that CTA changes the **commitment weight** the user is being asked for on their decision path is the sibling's judge: call the Skill tool with "snitch-ux". Same button, two judges; report the specificity defect here and hand the commitment question over.

**Evidence discipline (read first).** Almost everything here is **source/crawl-detectable** — assert it from `file:line` or the rendered DOM, never speculate. But whether a given element actually *lifts* conversion for this audience is **not** knowable without the team's own A/B data (see Cat 73, Cat 114 validity note). So: assert the *presence/quality* defect; frame the *fix's impact* as a hypothesis to test, not a guaranteed lift.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Read` the page; identify the primary CTA (or lack of one) and its copy.
2. Inspect each form: count fields; check label association, `type`/`inputmode`/`autocomplete`, required/optional marking, error handling (inline-on-blur vs submit-only), password reveal, SSO/guest option, "why we ask" microcopy on sensitive fields.
3. Check trust signals: testimonial specificity (name/photo/title/company/result), customer logos near the CTA, third-party review badges, security emphasis at the payment/signup step, guarantee / risk-reversal, proof recency.
4. `Read` the 404 route: recovery elements (search, nav, top links, contact). The HTTP status a not-found route returns is Cat 5's check, not this one.
5. Trust artifacts: `Grep` `/about` and the homepage for founder or team identification; count named testimonials (name + role/company + photo or handle); look for a `/changelog`, `/updates`, `/whats-new` or `/releases` surface and sample its dates; read `/privacy` for named data flow, retention, deletion and a contact address; look for a "not a good fit for" section; look for a status page link or `status.{domain}`.

**Crawl mode, required tool calls:**

1. `Fetch` the URL; inspect rendered CTAs, forms, trust elements, mobile CTA persistence.
2. `Fetch` a known-bad URL (`/this-page-does-not-exist-xyz`) and inspect the rendered recovery elements. Whether it returns 200 instead of 404 is Cat 5's finding — cross-file it there rather than repeating it here.
3. `Fetch` the homepage, `/about`, `/changelog` and `/privacy` for the trust artifacts above; try `status.{domain}` and `/status` and confirm real component status rather than a landing page.

### Forbidden claims

- "The CTA may be unclear." Quote it.
- "Trust signals may be missing." List what's there + what's not.
- "This change will increase conversion by X%." You can't know the lift from source — frame it as a test hypothesis (Cat 73). Assert the defect, not the uplift.
- Do not hard-flag the **contested** items (see NOT a Problem): first-person CTA wording, CTA strictly above the fold, inline validation itself. These are A/B hypotheses, not defects.

### Detection

Source/DOM audit of the primary conversion surfaces. The highest-confidence, lowest-false-positive checks are DOM-structural (missing `<label>`, missing `autocomplete`/`inputmode`, submit-only errors, generic CTA text, an unattributed testimonial).

### What to Search For

**CTA patterns:**
- Generic labels: `Submit`, `Continue`, `Send`, `Go`, `OK`, `Click here` (vs outcome-specific "Get my free audit")
- No primary CTA within the first viewport on a commercial page
- Multiple equally-weighted primary CTAs in one viewport (split intent)
- Action elements that are `<div>`/`<span role="button">` without keyboard support, or `<a href="#">` running JS (button vs link semantics — WCAG 1.3.1/2.4.4)
- Long mobile page with no sticky/persistent CTA (CTA only in hero)

**Form patterns (DOM-detectable):**
- `<input>` with no associated `<label for>` / wrapping label / `aria-label` (placeholder-as-label is a fail — WCAG 1.3.1/3.3.2)
- Email without `type="email"`/`inputmode="email"`; phone without `type="tel"`/`inputmode="tel"`; OTP/numeric without `inputmode="numeric"`
- Missing `autocomplete` tokens (`name`,`email`,`tel`,`postal-code`,`cc-number`,`current-password`,`one-time-code`); `autocomplete="off"` on personal-data fields (WCAG 1.3.5)
- Multi-column field grids (excluding genuinely paired fields: first/last, city/zip, expiry/CVV)
- Errors only on submit with no `role="alert"`/`aria-live` region and no `aria-describedby` link (WCAG 3.3.1)
- Neither required nor optional marked; generic error strings ("Invalid input")
- `input[type=password]` with no show/hide toggle; no SSO/guest option; required phone/DOB with no "why we ask" helper text

**Trust-signal patterns:**
- Testimonials with no name/photo/title/company and no quantified result ("Great service! — J.S.")
- Commercial/B2B page with no customer-logo bar near the primary CTA; no third-party review badge (G2/Trustpilot/Capterra)
- Payment step (a `cc-number` field present) with no visual security emphasis / seal near the card field — *or* an excessive cluster of 6+ seals (suspicion)
- No guarantee / "cancel anytime" / risk-reversal near a paid CTA; testimonials/reviews with no dates (or all stale); vague counts ("trusted by many") instead of specific numbers

**404 / error patterns:**
- Default server/host 404 (Apache/nginx) instead of a branded recovery page
- 404 with no search, no nav, no links to top pages, no contact/report path
- (A not-found view returning HTTP **200** is Cat 5's soft-404 finding.)

**Trust artifacts (absorbed from the former Cat 111):**
- No founder name or photo on `/about` or the homepage for an indie SaaS or personal brand; no "Built by" line with faces for a small team
- Zero named testimonials on a brand older than six months, or anonymous-only quotes ("Great service! — J.S.")
- No changelog / updates surface, or a latest entry older than three months
- A privacy page that reassures ("your privacy is important to us") without naming data flow, retention period, deletion mechanism and a contact address
- No "what this is *not* for" section on a positioning-sensitive brand
- No public status page on a SaaS or API product, or a status page that is a landing page with no component status or incident history

**Microcopy / reassurance:**
- Email/contact field with no privacy reassurance ("we'll never share") and no privacy-policy link
- Free-trial/signup CTA with no friction-remover ("No credit card required", "Cancel anytime", "Takes 2 minutes")

### Actually Hurts the Marketing Surface

- **Commercial page with no primary CTA**, or no CTA within the first viewport.
  Evidence required: page content + missing/below-fold CTA (and confirm no above-fold CTA exists).
- **Multiple competing equal-weight CTAs** (no clear next action).
  Evidence required: CTA list quoted with their styling.
- **Generic CTA label** on the primary action (`Submit`/`Continue`).
  Evidence required: the button text quoted.
- **Form friction**: >5 required fields on initial conversion (where fewer would do), missing label association, missing `autocomplete`/`inputmode`/`type`, submit-only errors with no live region, no required/optional marking, no password reveal, forced account creation with no guest/SSO option, required sensitive field with no "why we ask."
  Evidence required: the specific field/attribute quoted. Benchmark, from a large published body of checkout-usability research: ideal single-product checkout ≈ 7–8 fields; ~24% abandon a forced account; ~14% abandon an unexplained required phone field.
- **Pricing hidden across all tiers** ("Contact us" for every tier).
  Evidence required: pricing component with no prices on any tier.
- **Weak/anonymous trust signals** on a paid product page; **no security emphasis at the card field**; **no guarantee / risk reversal** at the paid CTA; **stale or undated proof**.
  Evidence required: the testimonial/badge/guarantee block (or its absence) quoted. Benchmark, from the same body of research: ~19% of US abandoners distrust entering card data, and security concern peaks at the card field specifically.
- **Missing trust artifacts**: no founder or team identification, zero named testimonials on a brand older than six months, anonymous-only quotes, no or stale changelog, a generic privacy page, no "not for" section, no public status page on a SaaS/API.
  Evidence required: the page content quoted with the artifact absent (or present-but-unattributed). Order the fixes founder → testimonials → changelog → privacy → "not for" → status page; each one makes the next more believable. A present-but-unsubstantiated artifact (an outcome testimonial with no attribution or disclosure) routes to Cat 117 and counts as not-yet-credible here.
- **404 with no recovery** (no search, nav, top links, contact) or a default server page.
  Evidence required: 404 template content.

### NOT a Problem

- Multiple CTAs that funnel to the **same** primary action ("Get started" + "Get started free" + "Try it").
- Forms with many fields when collection is genuinely needed (enterprise inquiry, KYC).
- Hidden pricing on **enterprise** tiers only (flag only if *all* tiers hide price).
- Paired fields side-by-side (first/last, city/zip, expiry/CVV) — not a multi-column violation.
- A below-the-fold CTA **when an above-fold CTA also exists**, or on a long-form value-heavy page (above-fold-CTA-always is a myth — contested; surface as a test, not a defect).
- **Inline validation on blur** with positive confirmation — that's best practice; only flag *submit-only* errors or *per-keystroke* negative validation that fires before the user finishes.
- **First-person vs second-person CTA copy** ("Start my trial" vs "Start your trial") — a documented A/B coin-flip (wins both ways); a test hypothesis, never a defect.

### Context Check

1. Is the page a conversion surface? Apply rigor here; less on docs/blog.
2. Is the form collection necessary or padded?
3. Are trust signals visible at the decision moment, or buried at the bottom?
4. Apply Hick's Law to form-field and above-fold CTA count (see `references/mental-models.md`).
5. Activation Energy: how many clicks from this surface to first value?
6. Does the mobile experience preserve the CTA and use the right keyboards (`inputmode`/autofill)?
7. Do the form a11y items (label association, error announcement) also belong in the Cat 103 report? Cross-file the finding under its WCAG criterion.
8. Has the team A/B-tested this surface? If conversion data exists, weight it over heuristics — and remember the fix's *lift* is a hypothesis until tested (Cat 73).
9. Cross-reference Cat 114 §4 (Friction) for the holistic read and Cat 116 (Retention psychology) for follow-through.
10. Is the brand a local service business asking for reviews on its own premises? Review-acquisition timing and cadence live in `references/local-services-playbook.md`; the reviews it produces are the trust artifacts audited here.
11. Is the question whether the CTA asks for too much commitment at this point in the decision path, rather than whether its label is specific? That judge is the sibling's — call the Skill tool with "snitch-ux".

### Reference

NN/g — landing pages: https://www.nngroup.com/articles/landing-pages/ · form errors: https://www.nngroup.com/articles/errors-forms-design-guidelines/ · required fields: https://www.nngroup.com/articles/required-fields/ · 404s: https://www.nngroup.com/articles/improving-dreaded-404-error-message/

The checkout and form thresholds above (field count, required/optional marking, perceived payment security) come from a large body of published checkout-usability research; the specific thresholds are stated inline in this category.

Form autofill / input types (web.dev): https://web.dev/learn/forms/autofill · WCAG Identify Input Purpose (H98): https://www.w3.org/WAI/WCAG21/Techniques/html/H98

The HTTP status a not-found route returns belongs to Cat 5 (soft-404 detection); this category audits only the recovery content on the page.

Review acquisition that produces the testimonials and ratings audited here: `references/local-services-playbook.md`.

**Severity tagging:**
- No CTA on a commercial page → Critical.
- Pricing hidden across all tiers → High.
- Form missing label association / forced account with no guest option → High.
- No security emphasis at the card field / no guarantee at a paid CTA → Medium.
- Generic CTA label / missing `autocomplete`/`inputmode` / submit-only errors → Medium.
- Weak/anonymous or stale trust signals → Medium.
- Zero named testimonials on a brand older than six months → Critical.
- No founder or team identification on an indie SaaS / personal brand, anonymous-only testimonials, generic privacy page → High.
- No or stale changelog (>3 months), no public status page on a SaaS / API → Medium (Low for B2C).
- No "not for" section → Low (advisory).
- 404 with no recovery → Medium.

Cross-reference: when the finding is that a conversion page fails to close a buyer objection (rather than a specific missing artifact), score the page against `references/objection-killer-checklist.md` and name which of the five objections the page leaves open.

**Fix voice:** `indie-commerce-founder` (primary) | `plain-language-designer` (backup).

Read `souls/indie-commerce-founder.json` before writing the Fix. The indie-maker conversion view: every barrier between the user and the product costs you. Strip it down.

Worked fix example:

> One primary CTA above the fold, value-specific. Forms minimal, native input types, labels associated, errors inline on blur. Trust signals where the user decides. A 404 that offers a way back.
>
> ```tsx
> // Above-fold conversion surface
> <Hero>
>   <h1>Run security audits on AI-built code</h1>
>   <p>Evidence-backed findings, your AI key, no source leaves your device.</p>
>   <Button href="/signup" variant="primary">Get my free audit</Button>
>   <p className="proof">Trusted by 1,200+ indie makers • SOC2 • cancel anytime</p>
> </Hero>
>
> // Minimal, accessible signup field
> <label htmlFor="email">Work email</label>
> <input id="email" name="email" type="email" inputMode="email"
>        autoComplete="email" aria-describedby="email-help" required />
> <p id="email-help" className="help">We'll never share it. No credit card required.</p>
>
> // 404 recovery content (the HTTP status itself is Cat 5's check)
> <NotFound>
>   <h1>That page doesn't exist (anymore?)</h1>
>   <ul><li><a href="/">Home</a></li><li><a href="/docs">Docs</a></li><li><a href="/pricing">Pricing</a></li></ul>
>   <SearchInput />
> </NotFound>
> ```
>
> Conversion surfaces have one job: get the user to the next step. Strip what doesn't serve it; make the form effortless on a phone; put the trust where the decision happens. Then test — the *direction* of these fixes is well-evidenced; the *size* of the lift is yours to measure.
