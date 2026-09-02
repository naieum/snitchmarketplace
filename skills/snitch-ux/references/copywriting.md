# UI Copywriting & CTA Patterns

Words are UX. The same screen converts or stalls on copy alone. Rules of thumb, then a
swap table. This file is the *line-level* pass; for the *brand-level* message these lines
serve — hero headline, tagline, value prop, onboarding narrative — see
`brand-message.md` first (problem-first story, five sound bites, controlling idea).

> Gate first: `ethics-gate.md`. Every rule below assumes the underlying claim is **true** and
> the cost is **disclosed**; on a surface that failed the gate, several of these swaps make the
> page worse rather than better.

## Principles

- **Omit needless words.** Cut the words on the page in half, then cut what's left in half
  again. Fewer words = less noise, the useful copy stands out, the page looks less daunting.
  Two things to cut ruthlessly:
  - **Happy talk must die.** Self-congratulatory intro fluff ("Welcome! We're thrilled to
    offer world-class solutions…") that a reader's brain just tunes out as noise. It carries
    no information — get straight to the point.
  - **Instructions must die.** Nobody reads them; they're an admission the UI isn't
    self-evident. First try to make the thing obvious enough to need none, then cut what's
    left to the bare minimum.
- **Make the message stick.** For anything the user must remember or be moved by — a
  headline, value prop, onboarding beat — run it against six traits: **simple** (one core
  idea, not five), **unexpected** (break a pattern so it catches — curiosity from a small
  gap in what they know), **concrete** (sensory, picturable — "steps from the sand," not
  "great location"), **credible** (a specific detail or number they can check), **emotional**
  (make them *feel*, don't just inform — people care about one person, not a statistic), and
  a **story** (a tiny narrative outlasts a spec). You rarely need all six; two or three turn
  a forgettable line into one that lands.
- **Specificity = trust.** Exact numbers kill the doubt vague adjectives create.
  "Start in 2 taps," "ready in 23 minutes," "4.9 ★ (221)" beat "quick," "fast," "loved."
  **Doubt is the most expensive thing in your interface.** Round numbers (100, 500) read as
  fake — use the real, odd number.
- **Possessive "my" over "your."** "Start my free trial" creates ownership before the tap.
- **Verb choice sets the stakes.** "Start" is light (a beginning). "Subscribe" signals
  lock-in. "Continue" implies you're mid-journey. Pick the lowest-commitment true verb.
- **Name the outcome, not the mechanism.** CTA states what the user gets / the full total:
  "Reserve — €445 total" (no hidden-fee anxiety) beats a bare "Reserve." "Add to cart —
  start my routine" reframes a purchase as a positive step.
- **Ask the easy question.** Rewrite high-commitment framing into low-stakes framing
  ("Can I try this free?" not "Is this worth $19/mo?").
- **Conversational & plain.** Write like a person ("How long did you sleep?"), not a form
  label ("Sleep duration input"). Reduces processing friction.
- **Preempt the top objection next to the CTA.** "Free cancellation before Mar 26,"
  "cancel anytime," "no card required" — answer the fear before it's asked.
- **Sensory/emotional language** where you're selling an experience: "beachside escape,
  steps from the sand" activates imagination before price does.
- **One-word categorization labels** do the deciding: a small "cheaper" / "best value" /
  "most popular" tag tells the brain which option to pick.
- **Loss framing in the copy** (only when true): "Don't lose your 5-day streak" >
  "Keep your streak"; a dismiss that owns the cost ("I'll risk it") > "Maybe later."
  **A dismiss names a real consequence; it never insults the person choosing it.** "I'll risk
  it" states what the user is accepting. "No thanks, I don't want to save money" tells them
  they are foolish — that is confirmshaming, and it is the abusive end of this same rule.
  The test: could the user read the decline aloud without being mocked by it? If the copy only
  works because refusing feels embarrassing, it is a dark pattern.

## Swap table

**Every row assumes the gate passed.** These swaps lower the perceived stakes of an action, which
is only honest when the real stakes are stated at the same decision point.

**What this table is judged against — and what it is not.** The swaps here are about
**commitment weight**: whether the verb matches the size of the step the user is actually
taking. A separate judge asks whether a CTA label is **outcome-specific** enough to be worth
clicking from a search result or an ad — that one belongs to snitch-marketing, which flags a
bare "Continue" as a generic label. The two are not in conflict, and one line satisfies both:
"Continue — start my plan" carries the light verb *and* names the outcome. When you propose a
swap from this table, prefer the form that also names the outcome. On a surface that hides
a recurring charge, the commitment word *is* the user's last warning, and softening any of these is
a dark pattern rather than a swap — that applies to the whole table, not only to the rows where it
is spelled out.

| Weaker | Stronger | Why |
|---|---|---|
| Sign up | Continue / Start my plan | endowment, low commitment — **only when the price and recurrence are stated at the same decision point**; "Continue" on a page that initiates a recurring charge is worse than "Sign up" |
| Subscribe | Start free | "start" is light; question becomes easy — **only when the price and recurrence are stated at the same decision point.** On a page that hides the recurring charge, "Subscribe" is the user's last warning and softening it is a dark pattern, not a swap |
| Your free trial | My free trial | ownership |
| Search | Show 12 results | previews the payoff (default + specificity) |
| Quick setup | Set up in 2 taps | specificity = trust |
| Fast delivery | Delivery in 23 min | specificity |
| Loved by thousands | 4.9 ★ · 221 reviews | specific, non-round = real |
| Reserve | Reserve — €445 total | names the outcome, kills fee anxiety |
| Add to cart | Add to cart — start my routine | reframes cost → step |
| Maybe later | I'll risk it | dismiss owns the loss |
| You have no projects | Create your first project → | empty state as CTA |
| Upgrade now | Keep your 3 files — they're deleted in 7 days | loss > gain (only if true) |

## Anti-patterns (don't)

- Vague adjectives where a number exists.
- Round/fabricated stats or fake reviews.
- Buried cost, surprise fees on the next screen, hidden cancellation.
- Urgency/scarcity that isn't real.
- **Confirmshaming** — a decline worded to insult the person choosing it ("No thanks, I don't
  want to save money") rather than to name a real consequence. See the dismiss rule above.
