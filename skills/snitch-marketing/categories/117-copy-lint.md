## CATEGORY 117: Site copy lint (vague adjectives, unsupported superlatives, dark patterns, hidden price, weak social proof)

The categories above audit *structure* (positioning, conversion architecture, pricing strategy). This category audits the *prose itself* on the user's marketing surfaces. Site copy can pass every structural cat and still fail because the words don't carry weight: "powerful, seamless, world-class platform trusted by thousands" tells the buyer nothing they can verify or compare. The audit reads the copy as a buyer would, and flags every line that asks the reader to take the claim on faith.

Distinct from Cat 81 (positioning), Cat 60 (conversion & trust), Cat 99 (funnel deep). Those cats ask "is the positioning clear, is the conversion path complete, is the funnel measured." This cat asks "do the actual words on the page substantiate what they claim."

### Pre-flight: always run

Universal. Every brand has copy; every copy line either substantiates its claim or it doesn't.

### What this category audits

Six failure modes in the live or source copy. Each is a finding with quoted evidence (the exact line + its location).

| Failure mode | What it looks like | Why it fails |
|---|---|---|
| **Vague adjectives** | "powerful", "seamless", "robust", "world-class", "best-in-class", "amazing", "cutting-edge", "next-gen", "revolutionary", "game-changing", "innovative", "intuitive", "user-friendly", "scalable", "enterprise-grade", "frictionless", "effortless", "elegant" (as praise), "premier", "leading-edge", "state-of-the-art" | These describe nothing the buyer can verify or compare. Two products both claim to be "powerful" and the buyer learns nothing about which fits their problem. |
| **Unsupported superlatives** | "the best X", "the fastest Y", "the only Z", "#1 in [category]" with no number, named source, ranking citation, or test methodology nearby | Superlatives without proof are claims the buyer either takes on faith (rare) or discounts entirely (common). Either way the copy did no work. |
| **Dark-pattern urgency** | "only X left!" without real inventory; "ends today!", "24 hours only" without a real date that ties to a real deadline; perpetual countdown timers; "X people viewing this right now" with no source; "limited spots" that never close | Manufactured scarcity reads as untrustworthy; once a buyer notices the timer never expired the brand burned trust permanently. |
| **Hidden price** | "Starting at" with no number, "Contact us for pricing" on a self-serve product, pricing page that requires a sales call when the product is clearly self-serve, "Affordable" / "competitive pricing" without a figure | Hidden price is the #1 conversion blocker on B2B SaaS landing pages. The buyer reads "starting at" with no number as "you can't afford it" and bounces. |
| **Weak social proof** | "trusted by thousands", "trusted by industry leaders", "join 1000s of happy customers" with no count, no logos, no named customers, no review platform link | Anonymous social proof reads as fabricated. Either name customers (with their permission) and link the review/case study, or drop the line. |
| **Buzzword density** | Three or more vague-adjective hits in one hero block, one subhead, or one bullet list. The whole paragraph is unfalsifiable. | One vague adjective is a tic. Three in a row signals the copywriter had nothing concrete to say and reached for filler. |

### Evidence required (do not skip)

For each finding:

1. Quote the exact line of copy.
2. Cite source location: file path + line number (source mode), or URL + CSS selector + the rendered text (crawl mode).
3. Name the failure mode from the table above.
4. State what evidence would substantiate the claim if the brand wants to keep the language (the test the copy currently fails).

Findings without all four components are Rule 1 violations (see `references/anti-hallucination.md`).

### Detection

**Source mode:** glob route files (`src/routes/`, `src/app/`, `pages/`, `content/`, `app/`) and MDX/MD content; read homepage, pricing page, comparison pages, FAQ, about. For each H1, H2, hero subhead, CTA label, testimonial blurb, and bullet list item, run the six pattern checks below.

**Crawl mode:** fetch the homepage, `/pricing`, `/about`, `/features`, top product page, and `/compare/*` if present. Extract rendered visible text per surface. Run the six pattern checks.

### What to search for

**Vague-adjective patterns (regex-style):**

```
\b(amazing|powerful|seamless|robust|world.?class|best.?in.?class|next.?gen|cutting.?edge|revolutionary|game.?changing|innovative|synergy|leverage|premier|leading.?edge|all.?in.?one|intuitive|user.?friendly|scalable solutions?|enterprise.?grade|state.?of.?the.?art|frictionless|effortless|delightful|supercharge|reimagined|unleash|transform your|elevate your)\b
```

**Unsupported superlative patterns:**

- `the best [noun]`, `the fastest [noun]`, `the only [noun]`, `#1 [noun]`, `[noun] leader`, `[noun] expert(s)` — flag if no number, named customer, named ranking source, or independent test citation appears within 50 words.

**Dark-pattern urgency patterns:**

- `\b(only \d+ left|limited time|24 hours? only|ends today|hurry|act now|don't miss out|last chance|few spots? (left|remaining))\b` — flag if no real date or real inventory is verifiable in source or crawl.
- Countdown timer JS / HTML (`<countdown-timer>`, `setTimeout` resetting a deadline, fake-deadline libraries).
- "X people viewing this right now" lines — flag unconditionally (almost always fabricated).

**Hidden-price patterns:**

- `starting at` not followed by a currency symbol + number within 20 chars.
- `contact us for pricing`, `contact sales for a quote`, `request a demo to see pricing` — flag when the product appears self-serve (signup form / `/signup` route / install instructions present).
- `affordable`, `competitive pricing`, `value for money` without a number on the same page.

**Weak social-proof patterns:**

- `\b(trusted by (thousands|millions|industry leaders|the world's best)|join \d{4,}\+? (customers|users|teams|companies))\b` — flag if no specific customer count, no named customers, no logo wall, no link to reviews.
- Bare logo walls (logos with no testimonial, no case-study link, no count of users per logo) — borderline; downgrade to Low if at least 3 logos are present.

**Buzzword-density rule:**

- Within any hero block (H1 + immediate subhead + CTA label), flag if 3+ vague-adjective hits.
- Within any single bullet list of 3-5 items, flag if every bullet contains a vague adjective.

### Actually hurts the marketing surface

- **Hero copy is all vague-adjectives.** The buyer can't determine what the product does in 5 seconds. Critical.
  - Evidence required: H1 + subhead quoted; vague-adjective hits highlighted.
- **Pricing page hides the price on a self-serve product.** Conversion-killing. Critical.
  - Evidence required: pricing page quote + signup-flow evidence showing self-serve.
- **Unsupported superlatives in hero or pricing.** Buyer's BS-detector triggers; bounce. High.
  - Evidence required: superlative claim quoted + 50-word window scan showing no proof.
- **Dark-pattern urgency without real deadline.** Trust-burning on first detection by the buyer. High; rises to Critical if the timer resets on page reload.
  - Evidence required: urgency claim quoted + reload test (crawl mode) or backend logic (source mode).
- **"Trusted by thousands" with no logos, no count, no review link.** Anonymous social proof reads as fabricated. High.
  - Evidence required: social-proof line quoted + scan of surrounding 200 words showing no substantiation.
- **Buzzword-dense hero or subhead.** Three+ vague adjectives in one block. Medium (corrosive but not bounce-causing alone).
  - Evidence required: block quoted + each vague-adjective hit named.
- **Logo wall without context.** Logos but no testimonial, no case study, no count per logo. Medium.
  - Evidence required: surface quoted + missing context noted.

### NOT a problem

- One vague adjective used as a flavor word in a longer concrete sentence ("powerful at the workloads developers actually run, not the ones on a benchmark"). Not a finding — the adjective is qualified.
- Superlatives that *do* have proof nearby ("the fastest Postgres pooler — 12µs at p99, benchmark linked"). Not a finding.
- Real urgency with a real date ("Lifetime tier closes January 31, 2027 — current pricing won't return"). Not a finding when the date is verifiable.
- Self-evident social proof ("Used by [3 named brands the buyer recognizes], full customer list at /customers"). Not a finding when the count or names substantiate.
- Industry-standard vague words used as category labels ("Enterprise plan", "Pro tier") — these are category names, not claims about quality.

### Context check

1. Is the line a *claim about quality* (vague-adjective) or a *category label* (pricing tier name)? Only the former is a finding.
2. Does the superlative have proof within 50 words? If yes, no finding.
3. Is the urgency tied to a real deadline a customer could verify? If yes, no finding.
4. Is the product self-serve? If yes, "contact us for pricing" is a finding; if the product is genuinely sales-led (enterprise contract, custom implementation), it's not.
5. Does the social-proof claim substantiate (count + names + link)? If yes, no finding.
6. For buzzword density: read the block aloud. If the buyer could swap your brand for any competitor's brand and the sentences still work, every word in the block is doing zero work.

### Pairs with other categories

- **Cat 81 (Market positioning)** — failed positioning often produces buzzword-dense hero copy. Run Cat 117 first to surface the symptom, then Cat 81 to fix the underlying structural gap.
- **Cat 60 (Conversion & Trust)** — hidden price and weak social proof show up as Cat 60 conversion gaps; this cat reports them as copy issues with the exact language to rewrite.
- **Cat 91 / Cat 112 / Cat 115 (Pricing)** — "starting at" with no number routes here; pricing-tier *structure* routes to those cats.
- **Cat 111 (Trust artifact audit)** — anonymous social proof is a Cat 111 trust gap; this cat catches the specific copy line that needs replacement.

### Severity tagging

- Hero copy is entirely vague adjectives / hidden price on self-serve product → Critical.
- Unsupported superlatives in hero / dark-pattern urgency without real deadline / weak social proof in hero → High.
- Buzzword density in hero or subhead / logo wall without context / vague adjectives in body copy → Medium.
- One isolated vague adjective in a concrete-otherwise paragraph → Low (often Skip).

### Fix voice

`mike-monteiro` (primary) | `aaron-draplin` (backup).

Mike's voice for "you're telling the buyer nothing, and you're charging them for the privilege of reading it." Aaron Draplin's plain-language SERP voice as backup when the fix is "rewrite this hero so it says what the thing actually does, in one breath."

Internal rule: never name the practitioner in the fix prose (per `references/voiced-remediations.md`). The cadence carries the authority; the byline doesn't.

### Reference

The patterns below were validated against landing-page advice from copywriters who specifically test what converts (Joanna Wiebe, Harry Dry, John Bonini, Sam Parr's HubSpot teardowns), not from generic SEO writing guides. The audit cites the specific copy line, not "the brand should write better" generic advice.

### Kill rule (for any fix recommendation produced by this cat)

Each Cat 117 fix recommendation must declare what evidence would invalidate the fix. Example: "Recommendation: rewrite hero from 'the powerful platform for modern teams' to 'cut your Postgres query time without rewriting indexes'. Kill rule: if a 5-second test on 10 buyers shows fewer of them can explain what the product does after the rewrite than before, the original wins and we rewrite again from a different angle."

Without a kill rule, a copy rewrite is a vibe, not a decision.
