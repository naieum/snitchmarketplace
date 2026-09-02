# Positioning and pricing method

The decision procedures behind two Foundation-mode documents: how `positioning.md` picks the
segment it leads with, how its positioning statement gets built and drafted, and how its
pricing posture is read. Foundation mode loads this before writing `positioning.md`. Drafting
mode loads it only when a draft's angle turns on the wedge or the price story.

Everything here is judgment, so everything here ends in a `> Reasoning:` line in the doc, not
a `> Evidence:` line — except the inputs, which are facts and carry evidence like any other
fact (evidence gate, SKILL.md).

**Boundaries.** This file decides *what the positioning should be*. It does not grade the live
site (that is snitch-marketing), restructure one page's sections (snitch-focusedcopy), or test
the hero on the screen (snitch-ux). Pricing here is the strategy read — the shape of the tier
mix and what it signals. The price *number* on a greenfield build is decided by
snitch-blueprint's sensitivity survey: when the product has no price yet, call the Skill tool
with "snitch-blueprint" and read the posture back from what it decides.

---

## 1. Wedge scoring — which segment leads for the next 60–90 days

Positioning is downstream of the segment. "For everyone who needs X" produces copy that lands
for nobody, and the fix is not "narrow the audience" by instinct — it is a scored shortlist,
one segment chosen to lead, and the conditions that would change the choice.

**Skip the exercise** when the product has a single, obviously correct buyer it already serves
directly (a local service business, a vertical tool with one named buyer). Record the skip in
`positioning.md` with the reason. **Run it** when: the current copy names three or more buyer
types in one sentence; several audience pages exist with no priority between them; one product
is sold across four or more visibly different buyer profiles; or the user asks "who should we
be for?" in any form.

### The matrix — four dimensions, 1–5 each

| Dimension | What it measures | Scores 5 | Scores 1 |
|---|---|---|---|
| **Pain** | A costly, recurring problem they will pay to end | Daily problem with a measurable cost: lost hours, lost revenue, physical discomfort, regulatory risk | Mild annoyance they can ignore indefinitely |
| **Reach** | Can a small team find them without paid ads or a sales team? | Concentrated in nameable places: subreddits, Slack groups, professional associations, conference lists | Diffuse; reachable only by paid media or warm intro |
| **Switching cost** | Can they sign up and feel value in five minutes? | Self-serve, no enterprise gate, nothing to migrate | Needs IT approval, data migration, training, or a vendor-evaluation cycle |
| **Willingness to pay** | Does this price land as an obvious yes? | Below what they already spend on the habit or tool it replaces | At or above their pain threshold; needs deliberation |

Sum the four. Twenty is the ceiling. The highest scorer becomes the primary wedge; the next
two are backups (one may earn its own landing page if there is bandwidth for it). Segments
under 12 are not recommended unless one dimension is extreme enough to carry them — a Pain of
5 driven by a compliance deadline, for example — and the exception gets written down.

**No cell scores without evidence.** Each number cites what produced it: a fetched community
page showing where the segment concentrates, a competitor price captured this run, a
testimonial naming a role, a signup flow actually walked. A matrix of confident guesses is
research theater and fails the evidence gate.

### The "cares a lot" overlay

The four dimensions are necessary; the four traits below are what make a segment sufficient.
Apply them to the top scorers before committing.

1. **The pain is frequent and visceral** — felt daily or near-daily, and strongly enough that
   they talk about it. Infrequent or abstract pain makes a lukewarm wedge.
2. **They are already trying to solve it** — spending money, time, or attention today: related
   tools bought, communities joined, contractors hired, complaints posted. Redirecting
   existing behavior is far cheaper than creating new behavior.
3. **They have a frame of reference** — they know what good looks like in the category, so
   they can evaluate a difference. Teaching a category from zero is a multi-year content
   investment, not a wedge.
4. **They have a budget** — financial first (they pay for partial solutions today), time
   budget second (hours a week lost to the problem), attention alone is weakest: they care,
   but they will not pay.

Four of four is a wedge. Three is borderline — name the missing trait in the doc. Two or fewer
is not a wedge yet; defer the segment or pick another.

**Re-score rule.** A segment scoring 5 on Pain but missing trait 2 drops one to two points.
Nobody there recognizes the problem as solvable yet, so this is demand creation, not
substitution — the slower, more expensive motion. The flag for it: competitor research finds
no community, forum, association, or competitor customer base where the segment already
discusses the problem.

### Pivot conditions

A wedge is a 60–90 day commitment, not an identity. Write the conditions that would end it
*before* the commitment starts, in the user's own numbers ("if under a fifth of paid signups
come from the primary wedge after 60 days, move to the backup that is producing organically").
Conditions written in advance are what break sunk-cost loyalty later. `positioning.md` carries
the matrix summary, the chosen wedge, the backups, and these conditions.

---

## 2. The positioning workshop — ten steps

The workshop produces the positioning statement `positioning.md` records. Steps 1–7 can be
done from evidence plus one interview round; steps 8–10 belong to the user's team and are
reported as their next actions, never claimed as done.

1. **List the true alternatives.** What would the buyer actually do if this product vanished?
   Often the honest answer is "nothing", "a spreadsheet", "the tool already on the machine", or
   "hire someone junior". Direct competitors are sometimes right and often not. The buyer's
   reflexive comparison is the input.
2. **Isolate the unique attributes.** What can this product do that none of those alternatives
   can? "Cheaper" is fragile — it is a substitute position anyone can take. A specific
   capability nothing else has is durable. Strip anything a competitor can match.
3. **Map attribute to value.** The attribute is the mechanism; the value is what it does for
   the buyer. A named model is an attribute; "eight hours of hands-free work without wrist
   pain" is the value. Copy that stops at attributes is a spec sheet.
4. **Find the buyers who care a lot about that value.** This is the wedge scoring in section 1
   — not everyone who *could* use it, the people for whom this value is materially better than
   the alternative.
5. **Choose the market category that makes the strengths the buyer's criteria.** The
   load-bearing step. The same product framed as the cheapest in a crowded category loses on
   price; framed as the answer to a specific condition it wins on a different axis. The
   category choice picks both the comparison set and the criteria.
6. **Layer a trend only if one is genuinely moving in the product's favor** — a platform
   shift, a regulation landing, a change in how the work is done. Trends decorate a solid
   foundation; they are not one.
7. **Write the statement.** One paragraph naming: category, target buyer, the specific value,
   the differentiating attribute, the proof, the comparison set. It is internal; the messaging
   derived from it is what the buyer reads.
8. **Align the team** on it before anything ships. A team that disagrees produces inconsistent
   surfaces.
9. **Translate it into messaging** — hero, FAQ, comparison pages, pitch, social bios.
10. **Use it consistently**, across surfaces and across time. Changing the story every month
    destroys the compounding.

Report where the current surfaces contradict the output: the alternatives in step 1 that the
hero does not imply, the value from step 3 that appears nowhere, the category in step 5 that
the page's own description contradicts. Those contradictions are the user's first fixes.

---

## 3. Three hero drafts, when the positioning is being replaced

When the workshop produces a positioning materially different from what the site says, write
three complete hero drafts — headline, subhead, CTA — each solving the same gap from a
different angle, all grounded in the workshop output. The user picks one to run; the others are
the alternatives if it produces no signal in 30 days. Drafts land in
`marketing/drafts/<date>-hero-<slug>.md` with the usual provenance header.

Pick three of these four patterns:

- **Pain-led.** Names the buyer's specific pain in the first sentence; the product enters as
  the relief.
- **Substitute attack.** Names what the buyer already tried that did not work, and positions
  against that prior art rather than against a named competitor. Usually the most durable for
  a small product, because the honest alternative is "nothing worked."
- **Quiet confidence.** Describes the mechanism plainly, no drama. The price and the trust
  signal do the closing.
- **Constraint shift.** Names the *new* problem that arrives once the current one is solved
  ("you will run out of crew before you run out of leads"). Credible because it forecasts a
  real operational consequence instead of claiming a pure win. Use it where the buyer's world
  is operationally complex and success creates work.

Default: lead with the substitute attack for most self-serve products, and with the constraint
shift where the buyer runs an operation that success would strain. Each draft obeys the
evidence gate — a hero is the easiest place in the whole foundation to write a sentence the
product cannot back.

Handoffs: the on-page tests for a hero (weight, five-second, Sharpie) belong to snitch-ux;
restructuring the page the hero sits on belongs to snitch-focusedcopy; grading the live page
against the strategy belongs to snitch-marketing. Name whichever applies in the draft report.

---

## 4. The sales narrative arc

A product can have correct positioning and still scroll like a feature list. The arc below is
what a homepage scroll, a demo video, or a pitch deck should follow, in order:

1. **Insight** — a shift or tension the buyer already believes. You are naming their world,
   not making a claim yet.
2. **Alternatives** — what they have already tried and where it falls short, named honestly.
   Accuracy here buys trust for everything after it.
3. **Perfect world** — what would be true if the problem were gone. The product is still not
   on stage; this is pure outcome.
4. **The solution** — now the product, delivering that outcome through the unique attribute
   from workshop step 2.
5. **Proof** — testimonials, case studies, a recording of the thing working. Without it, the
   first four beats are assertions.
6. **The ask** — specific and concrete. "Learn more" fails this beat.

---

## 5. The pricing strategy read

`positioning.md`'s pricing posture answers one question: is the pricing mix producing the cash
flow and the signal this stage needs? Not whether the number is right — that is
snitch-blueprint's survey on a greenfield build, and the user's call on a live one — and not
whether the prices are *displayed* well, which is judged against the buyer's decision path by
snitch-marketing and snitch-ux. Skip the read entirely for a free-only product.

**Read first, with evidence per line** (the pricing page in crawl mode, the billing config in
source mode):

- Tier structure: how many tiers, at what prices, on what intervals.
- Where the price falls in the competitor set captured in `competitor-analysis.md`: cheapest,
  mid-pack, premium.
- Annual option: present? at what discount?
- Lifetime offer: present, capped, and framed as time-limited, or open-ended?
- Team / business tier: present, "contact us", or absent — and is there billing, admin, and
  compliance behind it?
- Free tier shape: unlimited, usage-capped, or time-limited trial.
- The conversion moment: is there a "no card required", money-back, or equivalent reassurance
  where the buyer commits?
- Cap honesty: does "unlimited" survive the fine print?

**Then write three buckets**, each move justified:

- **What's working** — the positions to protect through any redesign. Being the value option
  in the set, a no-card free tier, no annual lock-in where competitors require one, flat rates
  where competitors throttle. These read in thirty seconds and are easy to delete by accident.
- **What's worth changing** — with the reason and the evidence. Common ones: no annual plan on
  a product people keep (quote the competitor discounts actually captured rather than a
  remembered band); a permanent discount displayed as the price (it trains buyers to wait —
  either time-bound it or make it the price); an uncapped lifetime tier (cap it explicitly, or
  it is a future-cash problem); tier inflation (each tier costs explanation, and a small
  product rarely needs more than three); no reassurance at the conversion moment; parity
  pricing with the category leader without the proof that justifies parity — either the proof
  ships or the price moves.
- **Don't do** — moves to name and refuse now, so they do not resurface next quarter: raising
  toward the leader before the proof exists; adding tiers with no differentiation pressure;
  running permanent discounts; adding a team plan before support, billing, and compliance can
  carry it; showing different prices to different visitors without deliberate revenue
  protection, which risks both trust and legal exposure if discovered.

**Claims this section may not make without the work behind them:** that pricing is too high
(compare against quoted competitor prices or say nothing); that a team plan is needed (show the
demand — multi-seat requests, inbound asking for it); that the free tier is too generous (show
the per-user variable cost, or accept that a generous free tier may be the acquisition
strategy).

**Context that changes the answer:** the stage's cash-versus-recurring tradeoff (early
products often want cash, established ones want the recurring line); whether support and
compliance can carry the recommended tier; where the funnel actually leaks, since a
free-to-paid problem and a pricing-page problem take opposite fixes; and whether the user is
willing to hold a price change for a full quarter, because pricing changes hit existing
customers and trust before they hit revenue.
