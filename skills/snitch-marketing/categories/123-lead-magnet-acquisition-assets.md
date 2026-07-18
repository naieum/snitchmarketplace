## CATEGORY 123: Lead-magnet / free-tool acquisition assets

Does the site give a reason to engage before "book a demo" or "buy"? This audits the
presence and capture-hygiene of acquisition assets: lead magnets (templates, guides,
checklists), free tools/calculators, and free tiers/trials, plus whether the value
exchange is fair and tied to a follow-up. Scope note: **generating** these assets is
a build task (`references/remediation-generator.md` + the funnel/tooling layer); this
category is the **audit** — presence, value, capture quality, and conversion path.

Free interactive tools have gained strategic weight: AI overviews trigger on learn-intent
queries — one practitioner study puts the click loss to the top result at ~35% when an
overview is present — but tool-intent queries (calculator, checker, converter, generator)
get no overview, so clicks still flow to sites. A free tool is inherently useful, earns
backlinks naturally, and is now cheap to build. The catch is that tool traffic is one-shot
unless captured: the pairing that converts it into an owned audience is tool + relevant
lead magnet (calculator → the checklist that answers the visitor's next question), gated
by email.

### Pre-flight: relevance check

Skip with reason `not applicable` for pure-content/personal sites with no conversion
goal, or transactional e-commerce where the "asset" is the product catalog itself
(though a sizing tool / quiz can still apply). Otherwise: required for SaaS, B2B,
services, and creator/info-product sites.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Search for acquisition surfaces: `/tools`, `/free`, `/templates`, `/resources`,
   `/calculator`, gated downloads, free-tier/trial CTAs, email-capture forms tied to a
   deliverable.
2. Read `.snitch-marketing-context.md` ICP + JTBD: is any asset relevant to the ICP's
   actual job, or generic?
3. Inspect the capture form (field count, friction) — cross-ref Cat 60 — and whether a
   nurture/follow-up exists (cross-ref Cat 71).

**Crawl mode, required tool calls:**

1. Fetch the homepage + nav + any resources/tools pages; capture what (if anything) is
   offered before the hard ask.
2. For any gated asset: capture the gate (what's required), the promised value, and what
   happens after submit.

### Forbidden claims

- "They should add a lead magnet." First confirm the only conversion paths are hard
  asks (demo/buy/contact) with no lighter on-ramp; quote them.
- "The lead magnet is weak." Quote the offer + what's gated; show the thin value or the
  over-gating.
- "Capture is too high-friction." Count the form fields (defer detail to Cat 60).

### Detection

Acquisition-asset presence + value-exchange fairness + capture hygiene + conversion path,
grounded in the ICP.

### What to Search For

- **Only hard-ask CTAs** ("Book a demo", "Contact sales", "Buy now") with no lighter
  on-ramp (free tool, template, checklist, free tier) for not-yet-ready visitors
- Lead magnet with vague/low value ("Sign up for our newsletter" with no reason)
- **Over-gating**: thin content (a 1-page PDF) behind a long form; or gating content that
  should be ungated for SEO/GEO (cross-ref Cat 18, 82)
- Free tool / calculator with **no conversion path** to the product (dead-end value)
- Free tool with **no capture pairing** (no lead magnet / email capture that qualifies the
  visitor's next step — the tool's traffic stays one-shot)
- Capture form friction (too many fields, no SSO) — cross-ref Cat 60
- No nurture follow-up after capture (the lead is collected and ignored) — cross-ref Cat 71
- Asset irrelevant to the ICP's job (generic magnet that attracts the wrong audience;
  Cobra Effect, `mental-models.md`)

### Actually Hurts the Marketing Surface

- **No lighter-than-demo on-ramp.** Every not-ready visitor either converts now or
  leaves with no relationship; reciprocity (`mental-models.md`) is never triggered.
  Evidence required: the CTA inventory showing only hard asks.
- **Over-gating.** Value gated that's too thin to justify the form, or content gated that
  should rank (lost SEO/GEO + poor value exchange).
  Evidence required: the gate + the gated content quoted.
- **Free tool/asset with no path to the product.** Traffic and goodwill captured, never
  converted.
  Evidence required: the tool page with no product CTA/upsell.
- **Free tool with no capture pairing.** The tool wins the visit (including AI-overview-proof
  tool-intent visits) but nothing turns it into a relationship — no paired lead magnet, no
  email capture tied to the visitor's next step.
  Evidence required: the tool page with no capture surface or paired offer.
- **Capture collected, never nurtured.** No follow-up sequence tied to the magnet.
  Evidence required: capture form present + no nurture signal (cross-ref Cat 71).
- **Off-ICP magnet.** Attracts volume that won't convert.
  Evidence required: the asset topic vs the context ICP/JTBD.

### NOT a Problem

- A genuinely high-ticket, sales-led B2B motion where "talk to sales" is the right
  primary CTA — though a champion-enablement asset (ROI calculator, business case) still
  helps (cross-ref Cat 99 B2B dark funnel).
- Ungated content offered freely as the strategy (ungating can be correct for SEO/GEO).
- A free tier that IS the on-ramp (no separate magnet needed).
- E-commerce where the catalog + email capture is sufficient.

### Context Check

1. What's the primary conversion (context file)? Is there an on-ramp for visitors not
   ready for it?
2. Is any asset relevant to the ICP's actual job, or generic?
3. Is the value exchange fair (value ≥ the data asked for)?
4. Does captured interest get nurtured (Cat 71) or dropped?
5. Does a free tool route to the product, or dead-end?

### Reference

Lead magnet value exchange / micro-conversions (Nielsen Norman): https://www.nngroup.com/articles/micro-conversions/

Reciprocity + value-first (see `references/mental-models.md`).

**Severity tagging:**
- Only hard-ask CTAs, no on-ramp, on a self-serve/PLG motion → High.
- Free tool/asset with no conversion path → Medium.
- Free tool with no capture pairing (no lead magnet / email capture) → Medium.
- Over-gating thin content / gating content that should rank → Medium.
- Capture with no nurture → Medium.
- Off-ICP magnet → Low/Medium.

**Fix voice:** `sahil-lavingia` (primary) | `josh-spector` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> Give before you ask. Right now the only doors are "buy" and "book a demo," so every
> visitor who isn't ready today leaves with nothing and no reason to come back.
>
> Add one on-ramp tied to the ICP's actual job. Not a newsletter, a *useful* thing: the
> template they'd otherwise build, the calculator that answers their real question, a
> free tier that delivers a first win. Gate it lightly (email only, cross-ref Cat 60),
> follow up with a short nurture (Cat 71), and make sure the free thing has an obvious
> next step to the paid thing. Keep it relevant to the ICP so you attract buyers, not
> freebie-seekers (Cobra Effect).
>
> If a free tool is the on-ramp, find the idea with data, not brainstorming: run keyword
> research on broad niche seeds, filter to the tool modifiers — calculator, checker,
> converter, generator, template — and validate that people already search for it. Those
> queries don't trigger AI overviews, so the clicks still arrive. Then pair the tool with
> a lead magnet that answers the visitor's *next* question (mortgage calculator →
> first-time-buyer checklist), so one-shot tool traffic becomes a list you own.
>
> Verify: track the new asset's capture rate and the capture→activation→paid path as
> micro-conversions (Cat 55/99); A/B the offer (Cat 73). The lift is a hypothesis until
> the funnel reads.
