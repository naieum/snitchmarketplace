## CATEGORY 71: Lifecycle / drip / newsletter marketing

Distinct from Cats 61-65 (transactional). This audit covers the marketing email program: newsletter, onboarding drip, win-back, churn-prevention, product-update announcements.

### Pre-flight: lifecycle presence check

If source has no ESP integration AND no newsletter signup form on the site, **Skip** with reason `no lifecycle / newsletter program detected; setting one up is a strategic decision, see STEP 5 recommendations`. Don't run Evidence Required.

### Evidence required (do not skip, only when ESP / signup exists)

**Source mode, required tool calls:**

1. `Grep` for newsletter / drip patterns: ConvertKit / Beehiiv / Mailchimp / Customer.io / Resend Audiences / Buttondown / Substack API calls.
2. Identify drip sequences: scheduled-job functions, cron triggers, sequence-of-emails patterns.
3. `Read` audience-list segmentation logic (who gets which sequence).

**Crawl mode, required tool calls:**

1. Find newsletter signup form: `<form>` containing email input + button labeled "Subscribe", "Get updates", "Newsletter".
2. Subscribe with a throwaway email; capture sequence of emails received over 7-14 days.
3. Note timing, tone, value-per-email, CTA quality.

### Forbidden claims

- "Drip sequence may be missing." Subscribe; show what arrives.
- "Newsletter probably doesn't exist." Look for the signup form.

### Detection

Source-side: ESP integration patterns + scheduled functions.

### What to Search For

ESPs:
- `convertkit.com/v3` / `kit.com`
- `beehiiv.com/api`
- `mailchimp.com/3.0`
- `customer.io/api`
- `resend.com/audiences`
- `buttondown.email`
- `substack.com`

Drip patterns:
- Cron jobs / scheduled workflows that send email after N days
- User-event triggered emails (`userCreated + 1d send onboarding email`)

### Actually Hurts the Marketing Surface

- **Newsletter signup exists but no email goes out**.
  Evidence required: signup form + ESP integration without active campaigns.
- **Welcome / onboarding sequence missing** (signup → silence → user forgets).
  Evidence required: signup + no drip after subscription.
- **Newsletter cadence inconsistent** (weekly for 3 months, then nothing for 6 months).
  Evidence required: ESP campaign history.
- **No segmentation** (everyone gets the same email regardless of behavior / signup source).
  Evidence required: ESP audience list with no segments.
- **Heavy promotional content with no value** (every newsletter is a sale pitch).
  Evidence required: sample of recent campaigns.
- **No re-engagement / win-back sequence** for inactive subscribers.
  Evidence required: segmentation table without an inactive-trigger sequence.
- **No post-purchase value narration** (the customer pays and the emails stop; nothing recaps
  what they received). Customers don't register value they aren't told about, in an organized
  way, at pay time — a delivery/receipt email that itemizes what was accomplished (including
  the emotional deliverables: "saved you a flooded bathroom at midnight") is marketing's last
  and cheapest touchpoint, and it feeds renewal and referral.
  Evidence required: purchase/delivery flow traced + no recap email or itemized value in receipts.

### NOT a Problem

- Newsletter intentionally low-frequency (monthly digest). Cadence by design.
- Single-segment audience for a niche audience. Acceptable.

### Context Check

1. Does the brand have a defined newsletter brand (named, recognizable voice)?
2. Is the welcome sequence value-first (here's what you get) or sale-first (buy now)?
3. How are subscribers acquired? Cross-reference with content / paid / signup-form placement.
4. Is the team capable of consistent cadence?

### Reference

Justin Welsh's solopreneur newsletter playbook (case study): https://www.justinwelsh.me

**Severity tagging:**
- Signup exists but no email sent → Critical (lost lead-gen).
- No welcome sequence → High.
- Cadence inconsistent / abandoned → High.
- No segmentation on a list >1000 → Medium.
- All-promotional content → Medium.
- No post-purchase value narration → Low.

**Fix voice:** `sahil-lavingia` (primary) | `mike-monteiro` (backup).

Read `souls/sahil-lavingia.json` before writing the Fix.

Worked fix example:

> The newsletter is the highest-leverage owned channel. Email beats social on conversion, retention, and signal-to-noise. Treat it like the product surface it is.
>
> Sequence:
> 1. **Welcome email** within minutes of signup. Sets expectations: cadence, content type, how to reply.
> 2. **Onboarding drip** over week 1: 3-4 emails, each with one piece of value (a tutorial, a case study, a tip).
> 3. **Regular newsletter** at fixed cadence. Same day, same time, same length range.
> 4. **Re-engagement** at 90 days inactive: "Haven't heard from you. Still want this?", opt-out is fine; engaged list is more valuable than big list.
>
> Each email asks one question or makes one point. Reply rate is a leading indicator; if no one replies to your newsletter, it's broadcast not conversation.
