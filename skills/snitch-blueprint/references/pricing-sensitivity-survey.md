# Pricing: a price-sensitivity survey

**The question the buyer asks:** *"What should I charge?"* This module answers it with survey
evidence instead of a guess — a decades-old, published four-question price-sensitivity survey
method that asks real prospects four price questions and reads a defensible price *range* out
of their answers.

Reach for it from the interview when **pricing posture is "undecided"** and the user wants
help arriving at a number, or any time the user asks "what should I charge / how do I price
this." It does not replace the pricing *page* work (how a chosen price is presented — anchoring,
tiers, the recommended plan — is snitch-ux's paywall lane) or competitor-relative positioning
(snitch-cmo). It decides the number's honest range; the others present and position it.

It is a **decision input, recorded with its data as evidence** — never an invented fact. A
range with no survey behind it is a guess dressed as research, and fails the decisions gate.

## Two modes

Pick by whether the user already has responses.

### Collect mode — no responses yet

The method needs answers from **real target buyers** (the audience the blueprint already
named), not the founder's friends and not the general public. You cannot skip this; the math
is only as honest as the sample.

1. **Field the four questions.** Present each product to the respondent (a one-line
   description, a screenshot, or the live thing), then ask, in a currency and interval that
   match how it's sold (per month, one-time, per seat):
   - **Too expensive** — "At what price is this *so expensive* you would not consider buying
     it?"
   - **Too cheap** — "At what price is this *so cheap* you'd doubt its quality?"
   - **Getting expensive** — "At what price is this *starting to get expensive* — you'd still
     consider it, but you'd think twice?"
   - **A bargain** — "At what price is this a *great deal* — clearly good value for the money?"
   Each answer is a single price. Order matters less than clarity; keep the wording plain.
2. **Sample size, honestly.** ~30–40 responses give a rough, directional read; ~100+ tightens
   it and lets you segment (by plan, by segment, by region). Fewer than ~20 → report the
   result as *indicative only* and say so in the blueprint. Never present a 12-person read as
   a settled price.
3. **Record the raw responses** (a CSV or a table) as the evidence the decision will cite.
   Then switch to analyze mode.

Offer to generate the survey itself — the four questions, an intro line, and a one-paragraph
plan for who to send it to and how (a form to existing waitlist / trial signups, a panel, DMs
to named prospects). Fielding it is the user's step; the skill drafts and analyzes, the human
collects.

### Analyze mode — responses in hand

Take the responses (pasted, CSV, or a table). For a grid of candidate prices from below the
cheapest answer to above the dearest:

1. **Build the four cumulative curves.**
   - **Too cheap (TC)** — % of respondents whose "too cheap" price is *at or above* this
     price. Descending.
   - **Too expensive (TE)** — % whose "too expensive" price is *at or below* this price.
     Ascending.
   - **Not cheap / getting expensive (NC)** — % whose "getting expensive" price is at or
     below this price. Ascending.
   - **Not expensive / good value (NE)** — % whose "bargain" price is at or above this
     price. Descending.
2. **Read the four crossing points.**
   | Point | Where it is | What it means |
   |---|---|---|
   | **Point of Marginal Cheapness (PMC)** | TC crosses NC | The **floor.** Below it, too many read the price as suspiciously cheap. |
   | **Point of Marginal Expensiveness (PME)** | TE crosses NE | The **ceiling.** Above it, too many walk away on price. |
   | **Optimal Price Point (OPP)** | TC crosses TE | Fewest total buyers reject on price (as many find it too cheap as too expensive). |
   | **Indifference Price Point (IPP)** | NC crosses NE | Equal shares call it cheap vs. expensive — roughly the "normal"/market-leader price. |
3. **Report the Range of Acceptable Prices (RAP): PMC → PME**, with OPP and IPP marked inside
   it. That range, not a single figure, is the honest output.
4. **Plot it.** Four curves on one price axis with the four crossings and the shaded RAP is
   how the result is read at a glance — describe it, and render it (a chart / small artifact)
   when the harness allows. Numbers alone hide where the curves are flat vs. steep.

## The revenue extension (optional, needs two more questions)

The classic four questions give a *range*, not a demand curve — they cannot tell you which
price inside the range earns the most. To get that, add two **purchase-intent** questions (a
published extension to the method): at the respondent's own "too cheap" and "getting expensive"
prices, ask how likely they'd actually buy (e.g. definitely / probably / no). Weighting those
turns the curves into an estimated **trial/adoption curve**, and price × adoption gives a
**revenue-estimate curve** whose peak is the revenue-maximizing price.

Two honest caveats before quoting a single "best" price from it:
- **Revenue ≠ profit.** Multiply by **gross margin** to compare prices on money kept, not
  money taken. A lower price with a fatter margin can win.
- **Business model bends the answer.** A high-touch, sales-assisted motion can sit toward the
  top of the RAP; a self-serve, automated motion usually wants the friction-minimizing zone
  lower in the range. Say which motion the blueprint assumes.

## What it is and is not

- It measures **stated perception** of price, not proven willingness to pay. It is a strong
  starting anchor, not a verdict — real signups at real prices are the eventual truth.
- It is only as good as the **sample**. Wrong audience → confident wrong numbers.
- It is a **snapshot.** Re-field after a pivot, a big feature, or a market shift, the same way
  the blueprint itself is re-run.
- It sets the **number's range**; the cost floor (never price below margin), competitor
  context (hand to snitch-cmo), and page presentation (hand to snitch-ux) are separate calls.

## Recording the result in BLUEPRINT.md

- With a real survey behind it: record the chosen price as a **Decision**, citing the RAP,
  the four points, and the response count (e.g. "$29/mo — inside RAP $19–$41, near OPP $27,
  n=112"). The raw responses are the evidence, held like a `file:line`.
- Without enough data yet: record a **labeled Default** ("$29/mo *(default — override any
  time)*: price survey not yet fielded; anchored to the IPP of two named competitors") and add
  "field a price survey (n≥30 target buyers)" to the open-questions list. A default the user can
  see is a decision waiting for review; a silent guess is not.
- Never invent responses, a range, or an "optimal price" to fill the section. No data → it's
  an open question, per the decisions gate.
