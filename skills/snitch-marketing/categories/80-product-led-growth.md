## CATEGORY 80: Product-led growth signals

Does the product itself drive growth? Free tier with paid upgrade path, viral loops (every use creates a new visitor), in-product share / invite CTAs, public artifacts (shareable URLs of work created in the product), clear "try it without signup" surface.

### Pre-flight: product-fit check

Not every product fits PLG (enterprise sales-led products, services, agency offerings). If business model from STEP 0.5 = `agency services` or `lead-gen` or `enterprise sales` → **Skip** with reason `business model is not product-led; PLG signals not applicable`.

### Evidence required (do not skip, only when product-led model fits)

**Source mode, required tool calls:**

1. `Grep` for "free", "try it", "no signup required", free-tier signup patterns.
2. `Grep` for share-link generation: `/s/`, `/share/`, `/embed/`, public artifact URLs.
3. `Grep` for invite mechanisms: `/invite`, "invite teammate", referral codes (cross-reference Cat 76's affiliate-referral row).

**Crawl mode, required tool calls:**

1. Visit homepage. Is there a "try it now" widget that works without signup?
2. Test a free-tier signup. After 5 minutes of use, does the product offer a clear upgrade path?
3. Create something in the product. Is there a public-share URL that links back to the product?

### Forbidden claims

- "PLG signals may be missing." Test the product; show what's there or what isn't.

### Detection

In-product instrumentation + on-site free-trial / share / invite surfaces.

### What to Search For

- "Free tier", "Free plan", "No credit card required"
- "Try it now", "Try without signup"
- `/share/`, `/s/`, `/embed/`, `/public/`
- `/invite`, "Invite teammate"
- Pricing page with prominent free-tier column

### Actually Hurts the Marketing Surface

- **No free tier or trial** for a product where competitors offer one.
  Evidence required: pricing page + competitor pricing pages.
- **Free tier exists but requires credit card upfront** (friction kills signups).
  Evidence required: signup flow inspection.
- **No "try without signup" surface** for product types that support it (image generators, code formatters, tools that produce single-use output).
  Evidence required: homepage + product type fit.
- **Public artifacts don't link back to product** (a generated PDF / image / chart with no "made with X" attribution + link).
  Evidence required: artifact inspection.
- **No invite mechanism for teams** (team product without "invite teammate" flow).
  Evidence required: dashboard inspection.
- **No upgrade prompt in free tier** (user can use forever without seeing paid upgrade pitch).
  Evidence required: free-tier UX inspection.

### NOT a Problem

- Product without PLG by design (high-touch enterprise sales, professional services).
- Free tier without credit-card requirement and without aggressive upgrade prompts (intentional product-led with patient conversion).

### Context Check

1. Does the product naturally produce shareable output?
2. Is the team capacity for a PLG funnel (instrumentation, in-product CTAs, lifecycle emails)?
3. Is the free-tier scope right (generous enough to demonstrate value, gated enough to drive upgrade)?
4. Is there an "aha moment" in the first 5 minutes of free-tier use?

### Reference

OpenView's PLG playbook: https://openviewpartners.com/product-led-growth/

**Severity tagging:**
- No free tier when competitors offer one → High.
- Free tier requires credit card upfront → High.
- No public-share / viral loop on shareable-output product → Medium.
- No team-invite flow on team product → Medium.
- No upgrade prompts in free tier → Medium.

**Fix voice:** `indie-commerce-founder` (primary) | `brand-surface-designer` (backup).

Read `souls/indie-commerce-founder.json` before writing the Fix.

Worked fix example:

> The product itself is the funnel. Make sure the funnel works.
>
> 1. **No-signup try**: a public homepage widget that demonstrates the core value in 30 seconds without an account. The user does the thing; the product earns the right to ask for their email.
> 2. **Free tier**: generous enough to be useful (one project free forever, three projects with limits, unlimited but rate-limited). No credit card. Time-to-value <5 min.
> 3. **Upgrade trigger**: at the moment the user hits the free-tier limit, surface the upgrade pitch with the cost + the value unlocked. Don't ambush; do show.
> 4. **Viral loop**: every artifact the user creates carries a "Made with [Brand]" attribution + link. Public share URLs that prospects discover and try themselves.
> 5. **Team invite**: every paid plan includes "invite teammate" with one-click flow. Each invited teammate is a potential conversion.
>
> Each of these can be A/B tested. The compound effect is significant, a 10% improvement in 4 of these multiplied is the difference between a flat conversion curve and an exponential one.
