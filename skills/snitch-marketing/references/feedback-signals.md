# Feedback Signals to Watch in Customer Calls

Customer-discovery calls produce raw language. Most of it is noise. The valuable language falls into four categories, and each category signals something specific about the brand's positioning, segment fit, and conversion friction.

This reference is the interpretation framework. Pair with `references/customer-discovery-script.md` (which describes how to run the calls) and the discovery output template.

## The four categories

| Category | What it sounds like | What it signals |
|---|---|---|
| **Activation language** | "Oh, that's cool." "Wait, what?" "I wish [other tool] worked this way too." | The customer is impressed. Use these phrases as hero / subhead / proof-strip copy. They're verbatim conversion fuel. |
| **Resistance language** | "I'd want to try it for a few days first." "I don't trust cloud transcription." "I'd buy it if my company paid." | The customer has a specific objection. Each resistance phrase is a candidate for the FAQ rewrite. The objection is the trust gap. |
| **Comparison language** | "Wispr Flow but cheaper." "I tried Win+H and gave up." "It's like [tool] but for [use case]." | The customer's reflexive comparison reveals the substitute set. "X but cheaper" is fragile (substitute position). "I tried X and gave up" is durable (demand creation, not switching). |
| **Use-case language** | "I write a lot of code review comments." "I needed a voice typing tool." "I do customer support, mostly tickets." | Job-to-be-done language. Customers who describe a job retain. Customers who describe a feature ("I needed a voice typing tool") churn. |

## Activation language: lift verbatim

When a customer says one of these, mark it as a verbatim copy candidate:

- "Oh, that's cool" → use the surrounding context as proof-strip language.
- "Wait, what?" → the customer is surprised by a feature; that feature gets prominent placement.
- "I wish [other tool] worked this way too" → comparison + activation. This is the hero candidate.
- "I just sent it to my [coworker / friend]" → spontaneous referral. The product is being recommended; lift to "what customers say" section.
- "This solved my [specific pain] in [specific timeframe]" → testimonial candidate; ask permission to attribute.
- "I would have paid 2x for this" → pricing perception data; the current price is too low for this segment.

Output: a list of 10-20 verbatim quotes that go into hero candidates, FAQ candidates, and proof-strip candidates.

## Resistance language: turn into FAQ

Resistance language is the FAQ reorganization input. Most FAQ pages lead with the vendor's framing ("How accurate is it?"). The buyer's actual question is something else. Listen for:

- "I'd want to try it for a few days first" → free-trial / no-card signup is the right structure; if absent, that's the conversion bottleneck.
- "I don't trust cloud transcription" / "I don't want my data sent to a server" → privacy gap, requires a specific privacy page (Cat 111 trust artifact #4).
- "I'd buy it if my company paid" → wrong segment for indie SaaS; not a problem to solve, but signals B2B / enterprise procurement requirements that don't apply to the indie wedge.
- "It seems too good for $X" / "what's the catch" → pricing perception gap; the page needs an explicit "why we can charge this little" answer.
- "I'd need to talk to IT" → switching-cost gap; segment is wrong-fit for self-serve.
- "Does it work offline?" → product gap if technical barrier exists; or honest-tradeoff statement on the FAQ if not on roadmap.
- "What about [competitor's specific feature]?" → the missing comparison page; the customer is doing the comparison work the brand should be doing.

Output: 5-10 FAQ entries that lead with the customer's actual question, not the vendor-framed equivalent.

### Politeness signals masquerading as resistance

Some resistance phrases sound like real objections but are actually social-niceness signals: the customer isn't engaged enough to give a real answer and is producing a polite version of "I'm not buying." Treat these as noise; probe for past behavior to surface what's actually true.

| Polite-noise phrase | What it actually signals | What to probe instead |
|---|---|---|
| "It looks great" / "I love this" | Compliment without commitment | "Tell me about your current workflow. When was the last time [adjacent problem] came up?" |
| "I would totally use that" | Future hypothetical lie | "What are you using today? When was the last time this came up? What did you do?" |
| "Other people I know would love this" | Projection onto unknown others | "Have you told them about [product]? Who specifically? What did you say to them?" |
| "I'd buy it for $X" | Future hypothetical pricing | "What did you pay last for software like this?" |
| "I'm planning to / going to / will" | Future tense | "Tell me about the last time you actually did [related action]." |

When the call surfaces several of these without past-behavior probes producing real answers, the customer is wrong-segment or wrong-stage. End the call politely; don't lift their language into copy.

## Comparison language: substitute vs demand-creation

This is the highest-leverage signal in the four. The way the customer reflexively compares the brand reveals the strategic position:

- **"X but cheaper" → substitute position.** Fragile. The customer is anchored on X, treating the brand as a replacement. The day X drops price, the brand loses. Or the day X ships a missing feature, the brand loses. Substitute positioning earns market share but doesn't earn loyalty.
- **"I tried Y and gave up" → demand-creation position.** Durable. The customer is comparing the brand to the previous failed solution, not to a competitor. "I tried Win+H and gave up" means built-in OS dictation soured them; the brand is the recovery, not the replacement. Demand-creation positioning earns retention because the alternative is "nothing."
- **"It's like Z but for [use case]" → analogy positioning.** Useful when the analog is well-known and the use case is sharp. Example: "It's like Notion but for solo founders." The analogy is the elevator pitch.
- **"I haven't seen anything like this" → category-creation territory.** Rare. Either the brand is creating a new category (treat with skepticism, most "new categories" are existing categories with new packaging) OR the customer hasn't done their research (treat as anecdote).

Output: a one-sentence positioning conclusion. Substitute / demand-creation / analogy / category-creation. Each routes to a different homepage strategy.

### Cross-reference: comparison signal vs positioning workshop

The customer's reflexive comparison is the input data for step 1 of the positioning workshop in Cat 81 ("list true competitive alternatives"). If the brand's positioning frame implies one set of competitive alternatives but customers reflexively compare the brand to a different set, the positioning frame is wrong. Examples of the misalignment:

- The brand positions itself "vs Wispr Flow" (treating Wispr as the alternative). Customers reflexively compare it to "Win+H, which I tried and gave up on" (treating built-in OS dictation as the alternative). Misalignment: the brand is fighting the wrong fight; the actual buyer is in demand-creation territory, not switching territory.
- The brand positions itself as a "team collaboration tool" (treating Notion / Asana / Slack as alternatives). Customers reflexively compare it to "Excel and a Google Doc, which is what we use today." Misalignment: the brand is fighting tools the buyer isn't using; the real switching cost is from spreadsheet inertia, not tool-to-tool migration.

When this misalignment shows up in 5+ discovery calls, the audit recommends rewriting the homepage's competitive frame to match the buyer's actual mental model. The brand's product hasn't changed; the frame has.

## Use-case language: job vs feature

Customers who describe a JOB ("I write a lot of code review comments") retain. Customers who describe a FEATURE ("I needed a voice typing tool") churn.

- **Job language**: identifies the recurring work the customer is trying to get done. "I do support tickets." "I write briefs for cases." "I respond to investor emails." The product is a means.
- **Feature language**: identifies the artifact they bought. "I needed dictation software." "I needed a form backend." The product is the end.

Listen for: does the customer describe the WORK they're getting done, or the TOOL they bought?

When the customer describes the job, the brand can position around the job. ("Voice dictation for hands that hurt.") When the customer only describes the tool, the brand is selling a feature, and feature-buyers comparison-shop on price.

Output: classify each customer's primary language as job / feature. The ratio across 20 calls signals positioning posture.

## What to skip (signals NOT to act on)

Some language sounds like signal but isn't:

- "It's pretty good" / "I like it" → noise. Doesn't tell you why or what specifically. Probe deeper or skip.
- "I'd recommend it to anyone" → noise. "Anyone" is no one. Probe for the specific person they'd recommend it to.
- "It would be cool if you added [feature]" → product feedback, not marketing signal. Route to product backlog. Don't change positioning to chase feature requests.
- "I love your team / your design / your tone" → brand affection, not actionable for positioning. Acknowledge but don't lift.
- "I'm not sure if I'm the right person to ask" → wrong segment OR the customer underestimates their representativeness. Probe for context; if confirmed wrong-segment, skip them.

## How to use the framework after the calls

For each of the 20 calls, classify the customer's most distinctive quotes into the four categories. Then aggregate:

- **Activation candidates** that appear in 5+ calls → top-priority hero / proof-strip lifts.
- **Resistance objections** that appear in 5+ calls → FAQ reorganization priorities.
- **Comparison patterns** dominant across calls → positioning conclusion (substitute vs demand-creation).
- **Use-case ratio** (job:feature) across calls → positioning posture (lead with job vs lead with feature).

Then rewrite the hero, FAQ, and trust strip using only the verbatim customer language. Ship the rewrite. Measure with the events from Cat 55.

## Cross-references

- `references/customer-discovery-script.md`, the script that produces the input.
- Cat 81 (positioning), the framework for translating these signals into positioning statements.
- Cat 110 (ICP wedge scoring), the segment-selection logic that depends on customer-language confirmation.
- Cat 111 (trust artifact audit), the resistance language directly feeds the trust artifacts.
- `references/copy-bank-templates.md`, where verbatim activation language gets re-rendered as deployable templates.
