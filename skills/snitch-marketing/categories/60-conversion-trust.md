## CATEGORY 60: Conversion & trust (CTAs, forms, trust signals, 404 page)

The point-in-time conversion-design surface: are CTAs clear and specific? Are forms minimal and frictionless? Are trust signals present and *specific* (named testimonials, logos, security at the decision moment, guarantees)? Is the 404 a dead-end or a recovery surface — and does it return the right HTTP status? Cat 99 audits the funnel *journey*; Cat 73 the CRO *discipline*; Cat 114 §4 the *holistic* friction score; Cat 103 the WCAG overlap. This category audits the *elements* on the page.

**Evidence discipline (read first).** Almost everything here is **source/crawl-detectable** — assert it from `file:line` or the rendered DOM, never speculate. But whether a given element actually *lifts* conversion for this audience is **not** knowable without the team's own A/B data (see Cat 73, Cat 114 validity note). So: assert the *presence/quality* defect; frame the *fix's impact* as a hypothesis to test, not a guaranteed lift.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Read` the page; identify the primary CTA (or lack of one) and its copy.
2. Inspect each form: count fields; check label association, `type`/`inputmode`/`autocomplete`, required/optional marking, error handling (inline-on-blur vs submit-only), password reveal, SSO/guest option, "why we ask" microcopy on sensitive fields.
3. Check trust signals: testimonial specificity (name/photo/title/company/result), customer logos near the CTA, third-party review badges, security emphasis at the payment/signup step, guarantee / risk-reversal, proof recency.
4. `Read` the 404 route: recovery elements (search, nav, top links, contact) **and** the HTTP status it returns.

**Crawl mode, required tool calls:**

1. `Fetch` the URL; inspect rendered CTAs, forms, trust elements, mobile CTA persistence.
2. `Fetch` a known-bad URL (`/this-page-does-not-exist-xyz`) and **record the HTTP status code** (not just the rendered text) to catch soft-404s.

### Forbidden claims

- "The CTA may be unclear." Quote it.
- "Trust signals may be missing." List what's there + what's not.
- "This change will increase conversion by X%." You can't know the lift from source — frame it as a test hypothesis (Cat 73). Assert the defect, not the uplift.
- Do not hard-flag the **contested** items (see NOT a Problem): first-person CTA wording, CTA strictly above the fold, inline validation itself. These are A/B hypotheses, not defects.

### Detection

Source/DOM audit of the primary conversion surfaces. The highest-confidence, lowest-false-positive checks are DOM-structural (missing `<label>`, missing `autocomplete`/`inputmode`, submit-only errors, generic CTA text, soft-404 status).

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
- A "not found" view returning HTTP **200** (soft-404), or a JS SPA that 200s every route
- Default server/host 404 (Apache/nginx) instead of a branded recovery page
- 404 with no search, no nav, no links to top pages, no contact/report path

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
  Evidence required: the specific field/attribute quoted. Benchmark: Baymard — ideal single-product checkout ≈ 7–8 fields; ~24% abandon a forced account; ~14% abandon an unexplained required phone field.
- **Pricing hidden across all tiers** ("Contact us" for every tier).
  Evidence required: pricing component with no prices on any tier.
- **Weak/anonymous trust signals** on a paid product page; **no security emphasis at the card field**; **no guarantee / risk reversal** at the paid CTA; **stale or undated proof**.
  Evidence required: the testimonial/badge/guarantee block (or its absence) quoted. Benchmark: Baymard — 19% of US abandoners distrust entering card data; security concern peaks at the card field specifically.
- **Soft-404** (a not-found page returning HTTP 200) — a real technical-SEO defect: wastes crawl budget, gets de-indexed.
  Evidence required: the bad-URL request + its 200 status. Fix: return 404/410 (or 301 for moved). Source: Google Search Central.
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
7. Do the form a11y items (label association, error announcement) also belong in the Cat 103 (WCAG) report? Cross-file the finding.
8. Has the team A/B-tested this surface? If conversion data exists, weight it over heuristics — and remember the fix's *lift* is a hypothesis until tested (Cat 73).
9. Cross-reference Cat 114 §4 (Friction) for the holistic score and Cat 116 (Retention Psychology) for follow-through.

### Reference

NN/g — landing pages: https://www.nngroup.com/articles/landing-pages/ · form errors: https://www.nngroup.com/articles/errors-forms-design-guidelines/ · required fields: https://www.nngroup.com/articles/required-fields/ · 404s: https://www.nngroup.com/articles/improving-dreaded-404-error-message/

Baymard Institute — checkout/form research (field count, required/optional, payment-form perceived security): https://baymard.com/research

Form autofill / input types (web.dev): https://web.dev/learn/forms/autofill · WCAG Identify Input Purpose (H98): https://www.w3.org/WAI/WCAG21/Techniques/html/H98

Soft-404 / HTTP status (Google Search Central): https://developers.google.com/search/docs/crawling-indexing/http-network-errors

**Severity tagging:**
- No CTA on a commercial page → Critical.
- Soft-404 (200 on not-found) → High (technical-SEO).
- Pricing hidden across all tiers → High.
- Form missing label association / forced account with no guest option → High.
- No security emphasis at the card field / no guarantee at a paid CTA → Medium.
- Generic CTA label / missing `autocomplete`/`inputmode` / submit-only errors → Medium.
- Weak/anonymous or stale trust signals → Medium.
- 404 with no recovery → Medium.

**Fix voice:** `sahil-lavingia` (primary) | `aaron-draplin` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix. Sahil's indie-maker conversion POV: every barrier between the user and the product costs you. Strip it down.

Worked fix example:

> One primary CTA above the fold, value-specific. Forms minimal, native input types, labels associated, errors inline on blur. Trust signals where the user decides. A 404 that returns 404 *and* offers a way back.
>
> ```tsx
> // Above-fold conversion surface
> <Hero>
>   <h1>Run security audits on AI-built code</h1>
>   <p>72 categories, your AI key, no source leaves your device.</p>
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
> // 404 — must also return HTTP 404, not 200
> <NotFound>
>   <h1>That page doesn't exist (anymore?)</h1>
>   <ul><li><a href="/">Home</a></li><li><a href="/docs">Docs</a></li><li><a href="/pricing">Pricing</a></li></ul>
>   <SearchInput />
> </NotFound>
> ```
>
> Conversion surfaces have one job: get the user to the next step. Strip what doesn't serve it; make the form effortless on a phone; put the trust where the decision happens. Then test — the *direction* of these fixes is well-evidenced; the *size* of the lift is yours to measure.
