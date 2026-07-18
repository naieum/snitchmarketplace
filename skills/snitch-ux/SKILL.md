---
name: snitch-ux
description: Apply behavioral-design / UX-psychology and usability principles when designing, building, or reviewing any user-facing interface — landing & marketing pages, onboarding, sign-up, paywalls & pricing, forms, checkout, dashboards, empty states, navigation, mobile nav — or when asked to improve conversion, retention, engagement, reduce drop-off, 'make this clearer / look good / feel premium / more polished', or write UI copy, CTAs, taglines, value props, hero headlines, or brand messaging. Encodes two lenses — clarity (self-evident pages, scanning, conventions, navigation, the parachute test, usability testing) and persuasion (defaults, anchoring, social proof, loss aversion, goal-gradient, reciprocity, endowment, friction reduction, visual hierarchy, feedback), as concrete, checkable moves.
license: MIT
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude.ai, Claude Code, Codex CLI, Cursor, GitHub Copilot, Gemini CLI, Goose, and 25+ more — see agentskills.io). Pure guidance; no server, tools, or external calls required.
metadata:
  author: Snitch
  version: 0.2.0
  homepage: https://snitchplugin.com
---

# UX Psychology

A field guide for making interfaces people actually finish, trust, and come back to. It
works on two lenses, in this order:

1. **Clarity — "don't make me think."** Before anyone can be persuaded, they have to
   understand. Users scan, they don't read; they pick the first reasonable option, not the
   best; they muddle through without reading instructions. So make the page **self-evident**
   — every question mark you leave in their head ("Is that a link? Where am I? What does this
   mean?") spends a little of their attention and their goodwill. Get rid of the question
   marks. (Depth in `references/clarity.md`.)
2. **Persuasion — users don't decide logically.** Once a screen is clear, shape the choice:
   defaults read as recommendations, the first number sets the anchor, a gift creates a
   debt, building something makes it yours, and even fake progress creates real momentum.

Both lenses rest on one **substrate — how the mind actually works.** People run on System 1
(fast, automatic, emotional) and spend System 2 (slow, effortful) as little as possible;
they perceive top-down, hold only ~4 things in working memory, decide emotionally then
rationalize, and build a *mental model* of how each thing works. Every rule in this skill is
a consequence of that. When a situation isn't covered by a specific rule, reason up from the
substrate: `references/psychology-foundations.md` (how the mind works) and
`references/interaction-model.md` (how a mind and a designed thing work together).

Design for how people actually think, not how you wish they thought — and when a decision
turns into an argument, **stop debating and watch three people use it**
(`references/usability-testing.md`).

## When to use this

Reach for this whenever you're shaping or critiquing a user-facing surface:
building/redesigning a page or flow, writing CTA/microcopy, designing onboarding or a
paywall, laying out a form or dashboard, choosing a mobile nav, or answering "how do I
make this convert / feel premium / stop people bouncing." Use it both **generatively**
(while building) and as a **review lens** (auditing an existing screen).

When it's a review, treat it as covering the **whole product surface**, not the first screen
you land on: scope it first (Workflow Step 0), and when the target, goal, or audience is
unclear, **ask the user rather than guessing**. A thorough pass over an agreed scope is the
job — a quick skim of a few pages is the failure mode to avoid.

## The one mental model

> **Every element on the screen is asking the user a question.** The question you pose
> determines whether they act or hesitate.

Before touching a screen, name the question it's really asking. Then make that question
*easy*. "Is this worth $19/mo?" is a hard question with the easy answer "later" (= never).
"Can I try this free?" is an easy question with the answer "yes." Same product — different
question. That reframe is most of the game.

Two kinds of questions live on a screen, and they map to the two lenses. There are the
questions *you pose on purpose* (the persuasion above). And there are the ones you leave by
accident — the **question marks** you leave behind: *Is that clickable? What does this label
mean? Where am I? Did I land on the right page?* Those are pure friction. **First remove the
accidental questions (clarity), then make the intentional one easy (persuasion).**

### How people really use interfaces

Design for the real user, not the attentive one you imagine. Three facts (detail in
`references/clarity.md`):

- **They scan, they don't read** — glancing for words that match their task, like a
  billboard at 60 mph. So *design great billboards*: strong visual hierarchy, few words.
- **They satisfice** — they click the *first reasonable* option, not the best. Make the
  first plausible label the right one.
- **They muddle through** — they don't read instructions or build a mental model, and stick
  with whatever works. So make it self-evident; don't rely on explanation.

Corollary: the **Back button is the lifeboat** — never break it or strand the user.

## Workflow

This runs in two modes — **generative** (building something new) and **review** (auditing
existing UI). Both start by establishing scope. **Do not skip Step 0 and start critiquing the
first page you open** — that's the main way this skill under-delivers.

### Step 0 — Scope the surface and confirm intent (always do this first)

Before building or reviewing anything, work out *exactly* what you're covering and why. Do
not sample a couple of screens and proceed.

- **Enumerate the full surface.** Build the actual list of user-facing surfaces in scope,
  don't assume it's one or two:
  - *In a codebase:* find every screen/page/flow — route definitions, page/view components,
    templates, layouts — **and** the states each one has (default, empty, loading, error,
    success, logged-out). Search the routing/pages directory; don't stop at the first file.
  - *On a live site/app:* walk the primary navigation and list the reachable pages and key
    flows (signup, checkout, onboarding, settings).
- **Ask the user when anything about scope or intent is unclear — ask, don't guess.** Use a
  direct clarifying question (the host's question tool) *before* starting if you don't know:
  which surfaces to cover, the **goal** (conversion? clarity? accessibility? "make it feel
  premium"? reduce a specific drop-off?), whether this is generative or a review, the
  **audience/stakes** (any vulnerable users or high-stakes decisions? → `inclusive-design.md`),
  or which single flow matters most. Present your enumerated surface list back and let the
  user confirm or narrow it.
- **Set the coverage bar out loud.** State which surfaces you will review. Cover **every**
  in-scope surface against the passes below — not a representative few. If the surface is too
  large to cover fully, propose an explicit prioritized subset and get agreement; never
  silently truncate and imply you covered everything.

### Step 1 — For each in-scope surface, run the pass

Work the list surface by surface. For a real review, **actually open the relevant reference
files** — don't work from the cheat sheet alone.

1. **Locate the moment.** What is the user trying to do here, and what's the one question this
   screen asks? (sign up? pay? pick? log? trust you?)
2. **Clarity pass first.** Is the page **self-evident** at a glance — obvious what it is,
   what's clickable, where you are? Remove the accidental question marks before anything else
   (`references/clarity.md`). A confusing screen can't be persuasive.
3. **Diagnose friction & framing.** Where are they doing unpaid work (blank fields, extra
   taps, decisions you could pre-make)? Is the framing a gain (weak) or a loss (strong)? Is
   any number shown in isolation (no anchor)?
4. **Apply the relevant principles** (cheat-sheet below; depth in `references/principles.md`).
   Prefer the highest-leverage 2–4 for this surface — don't cram all of them.
5. **Pass the copy** through `references/copywriting.md` (specificity, possessive, verbs, and
   omit needless words). For **brand-level surfaces** — home hero, tagline, value prop,
   pricing page, onboarding sequence, pitch copy — also check the *message* against
   `references/brand-messaging.md` (problem-first, five sound bites, one controlling idea);
   for taglines, names, and headline-scale lines use `references/taglines-and-naming.md`,
   and for funnel collateral (lead magnets, pricing framing, CTAs/closes, sales emails) use
   `references/messaging-campaign.md`.
6. **Review** against `references/review-checklist.md` before you call the surface done —
   including the accessibility/inclusion and ethics gates.
7. **Validate, don't debate.** When a call is contested or risky, don't argue from opinion —
   frame it as "put this in front of 3 users" (`references/usability-testing.md`). Run the
   **parachute test** on any page with navigation.

For anything with a **bottom tab bar / mobile navigation**, read
`references/mobile-navigation.md` — hard rules (tab count, sizes, active states). For
**site-level navigation, page names, breadcrumbs, tabs, and home-page big-picture**, see
`references/site-navigation.md`.

### Step 2 — Report coverage honestly

When done, list **every surface you reviewed** with its findings, and **explicitly name what
you did not cover** and why. Never imply full coverage you didn't do — if you looked at 3 of
11 screens, say so.

## Cheat sheet — the principles

**Make it self-evident (clarity — do this first)** — see `references/clarity.md`
- **Don't make me think** — a page should be understood at a glance; kill every question mark (*is that a link? where am I? what does this mean?*).
- **Design for scanning (billboard)** — strong visual hierarchy (prominence + grouping + nesting), few words, clearly defined page areas. People scan, they don't read.
- **Obvious clickability** — buttons look like buttons, links like links; never make users wonder what's clickable.
- **Use conventions** — the familiar pattern (logo top-left links home, hamburger, cart icon) needs no explaining; innovate only when your idea is clearly better and everyone says "wow."
- **Mindless clicks > few clicks** — the 3-click rule is a myth; ambiguity tires people, not clicks. Three mindless clicks beat one that makes you stop and think.
- **Minimize noise** — treat every element as visual clutter until it earns its place.
- **Navigation is the site** — Site ID, sections, a way home, a search box; page names that match the link clicked; obvious "you are here." Pass the **parachute test** (`references/site-navigation.md`).
- **Convey the big picture** — a first-time visitor knows *what is this, what can I do, why here* from the tagline + welcome blurb (`references/site-navigation.md`).

**Reduce the thinking (cognitive load)**
- **Smart defaults** — pre-select the most common choice; 70–90% never change a default and read it as a recommendation. Never show a blank form you could pre-fill.
- **Choice reduction (Hick's Law)** — fewer options → more action. Cut, group, or stage choices; one obvious primary action per screen.
- **Reduce interaction cost** — every removed tap/field/step improves UX. Surface content directly instead of behind banners; offer selection over free-text; show options as visible swatches, not dropdowns.
- **Progressive disclosure** — keep the first view clean; reveal advanced options on demand (reward the click).
- **Recognition over recall** — show faces/icons/thumbnails/recents so users recognize instead of remember.
- **Match input to context** — sliders/pickers for casual one-time setup; steppers/number fields for frequent, precise, repeated entry.

**Create motivation & commitment**
- **The convergence model (diagnostic)** — a behavior happens only when *motivation + ability + a prompt* line up at once. When a user doesn't act, exactly one is missing: too hard (fix ability/friction), not wanted enough (fix motivation/timing), or no clear cue (fix the prompt). Easing effort usually beats pumping motivation. (`references/psychology-foundations.md`.)
- **Goal-gradient / never start at zero** — give an artificial head start; a progress meter that begins at ~20% and is never empty. Count something they've already done.
- **Endowment / build-it effect** — let users build/choose/customize *before* you ask for commitment; people value what they made. Button says "Continue," not "Sign up."
- **Loss aversion** — losing hurts ~2× more than gaining pleases. Frame the cost of *inaction* ("you'll lose X"), not the gain. Dismiss reads "I'll risk it," not "Maybe later."
- **Commitment & consistency** — surface the small decision they already made so the remaining one feels tiny.
- **Reciprocity** — give real value *before* asking for anything (partial result, free sample, trial). The ask never feels like a wall.

**Persuade & build trust**
- **Anchoring / contrast** — never show a cost in isolation; control the first number. Show a % of a larger whole, a crossed-out reference price, or the total up front.
- **Social proof & halo** — specific, non-round counts ("4.9 ★, 221 reviews," "500+ this week") and status badges ("best-seller") shift risk perception. Round numbers feel fake.
- **Transparency bias** — proactively revealing a downside (upcoming charge, reminder before trial ends) *increases* trust and conversion.
- **Specificity = trust** — exact numbers kill doubt ("start in 2 taps," "23 min") better than adjectives ("quick," "fast"). Doubt is the most expensive thing in your UI.
- **Sell safety, not the pitch** — people convert from a safety net (free cancellation, money-back, "cancel anytime") placed *at the moment of hesitation*, not from harder selling.

**Message the brand as a story (brand-level surfaces: hero, tagline, value prop, pitch)** — see `references/brand-messaging.md`
- **Customer is the hero, you are the guide** — never open with the company, category, or backstory. A product is a rope, and a rope is only valuable to someone in a hole: lead with the customer's problem or the product has no value.
- **Five sound bites (PEACE)** — Problem, Empathy, Answer, Change, End result. Five zero-nuance, repeatable lines that each work alone as an ad and together read as one sentence ("Have you ever worried about money? We know how you feel. Download the app and get good with money — so you'll never worry about money again."). The full script adds: a three-step plan, a direct CTA, stakes (success *and* failure), and the customer's villain.
- **The one-liner** — the memorized answer to "what do you do?": problem → concrete product → specific result, closing the exact story loop the problem opened.
- **Controlling idea** — people carry away *one* thing; be known for something specific ("get good with money," "best serve in the game"), make it the tagline, and let it govern every downstream asset. Marketing is an exercise in memorization: repeat it verbatim for years.
- **Curiosity, not education** — the first touch's only job is "that sounds like me — tell me more." Explanation, proof, and nuance belong deeper in the funnel, never in the hero (`references/messaging-campaign.md` for the full funnel collateral, pricing framing, and closing scripts).
- **Weigh the copy; audit the leaks** — the header weighs zero pounds of cognitive load; run the Sharpie test (10+ problem mentions on the homepage) and the 5-second test (what problem? what's life after? how do I buy?). Taglines and names get their own tests (`references/taglines-and-naming.md`).

**Direct attention (visual hierarchy)**
- **Emphasize values, not labels** — rank elements by importance first; make the data big and the label quiet.
- **Differentiate with size / weight / color / position** — uniform styling kills hierarchy; vary deliberately, add an icon cue.
- **Show real content, not decoration** — people can't commit to what they can't visualize; show the actual thing in context over abstract hero art.
- **Cards over plain lists**, **soft shadows tinted to the background**, **bold type as hierarchy**, **minimalism** (every element earns its place), **glow/color to guide the eye**.

**Feedback, personalization & delight**
- **System feedback** — every action gets an immediate, satisfying response (state change, live-updating value, instant consequence like a new balance).
- **Micro-interactions** — tap feedback (scale/ripple), animated active states, soft screen transitions.
- **Empty states as opportunities** — never a dead end; explain the value, add an illustration, give a CTA.
- **Smart search** — on focus, offer recents / popular / personalized suggestions instead of a blank box.
- **Lifecycle personalization** — new vs returning vs power users see different first screens; use their name.
- **Emotional / sensory copy** — descriptive language ("beachside escape, steps from the sand") activates imagination before price.

**Paywalls & upgrade screens** — see `references/paywalls.md`
- **The paywall is a flow, not a screen** — sell the outcome during onboarding so the price screen collects a decision already made; multi-page beats single-page.
- **Risk reduction beats pressure** — a step-by-step trial timeline ("day 5: we remind you"), a "cancel anytime" CTA subtitle, and an exit-intent downsell outperform urgency.
- **Friction is a dial** — a card-wall halves trials but can 5× paid conversion; removing the wall entirely can lift trial starts. Match the friction to the metric that matters.
- **Two plans max, annual default, table sells by loss** — and anchor price to something already bought (weekly cost, "less than a coffee").

**Mobile & reachability** (see `references/mobile-navigation.md`)
- **Thumb zone** — put primary actions where a thumb reaches one-handed.
- **Tap targets ≥ 44×44px.**
- **Bottom nav: 3–5 tabs; ≥2 active-state cues; separate it from content; neutral colors; badges sparingly.**

## References
- `references/psychology-foundations.md` — the substrate: how the mind works (System 1/2, perception, memory, attention, motivation, emotion, error, decision). The *why* under every rule.
- `references/interaction-model.md` — how interaction works: conceptual models, the gulfs of execution & evaluation, affordances vs. signifiers, mapping, feedback, constraints, slips vs. mistakes.
- `references/clarity.md` — the clarity lens: the three laws of clarity, scanning/satisficing/muddling, billboard design, conventions, the reservoir of goodwill, accessibility quick wins.
- `references/site-navigation.md` — site-level navigation (persistent nav, page names, "you are here", breadcrumbs, tabs), the parachute test, and the home-page big picture (tagline vs. motto).
- `references/usability-testing.md` — validate don't debate: cheap testing (3 users, one morning a month), get-it vs. task testing, triage, the myth of the average user, and measuring honestly.
- `references/inclusive-design.md` — who the user really is: the full range of ability/culture/attention, cognitive inclusion, localization, and when to dial persuasion *down* for vulnerable users and high-stakes moments.
- `references/principles.md` — full persuasion catalog: each principle with the psychology, the rule, and do/don't.
- `references/copywriting.md` — CTA & microcopy patterns (verbs, possessives, numbers, framing, omit needless words).
- `references/brand-messaging.md` — brand-level message (StoryBrand-derived): customer-as-hero / brand-as-guide, the five PEACE sound bites plus the full script (three-step plan, CTA, stakes), the one-liner, the villain rules, the controlling idea, message audits (cognitive-load weighing, Sharpie test, 5-second test), where the founder's story belongs, and the funnel zones.
- `references/taglines-and-naming.md` — taglines (offer-not-vibe, name-strip and stranger-guess tests, category+twist, command taglines, name/tagline division of labor), naming rules (bullseye test, outcome-not-mechanism, bridge words, feature naming), and billboard-scale copy rules for any 3-second surface.
- `references/messaging-campaign.md` — deploying the message as a campaign: the 5-3-3 structure (curiosity → enlightenment → commitment), staged disclosure, lead generators, entry offers and product ladders, pricing/premium framing, the decision-trigger close and sales-copy structures, repetition discipline, and the bad-news/crisis playbook.
- `references/mobile-navigation.md` — bottom-nav / tab-bar hard rules (the mobile component).
- `references/paywalls.md` — paywalls & upgrade screens: paywall-as-flow, risk-reduction patterns (trial timeline, cancel-anytime, exit-intent downsell), qualifying friction vs. pay-ramps, packaging rules (two plans, annual default, loss-framed tables), and paywall-specific dark patterns (fake-urgency wheels, cancel asymmetry).
- `references/review-checklist.md` — a screen/flow audit to run before shipping.

## Guardrails
These techniques are for helping users decide and act with less friction — not for
tricking them. Loss framing, urgency, and social proof must reflect something **true**
(a real streak, a real deadline, real counts). Fabricated scarcity, fake reviews, or
buried cancellation are dark patterns: they win the tap and lose the trust.

Think of every user as arriving with a **reservoir of goodwill**: each friction and
each broken promise lowers it, a single bad move (a giant required form, a hidden fee
sprung late) can empty it, and honest, considerate design refills it. Persuasion wins the
tap; goodwill decides whether they come back — never spend the reservoir to close one
conversion. **Do right by the user:** tell people what they want to know up front, don't ask
for what you don't need, and when in doubt, apologize. The test stays the same: "would the
user thank me if they saw how this was built?"

Three more habits keep the psychology honest:

- **There is no neutral layout — so choose deliberately.** Every default, order, and
  emphasis nudges the decision whether you intend it or not. Since you can't *not* influence,
  own it: arrange things toward the choice that's genuinely best for the user, and be able to
  defend the arrangement out loud.
- **Design for the person at their worst moment, not their best.** The real user may be
  stressed, distracted, on a bad connection, in a crisis, or an edge case you find
  inconvenient. Techniques that assume a calm, ideal user (dense forms, urgency, buried
  escape hatches) turn cruel under stress. Pressure-test the flow against the anxious user.
- **Design for the full range of people, and know when to dial persuasion down.** The calm,
  capable, Western, neurotypical user this skill quietly assumes is rare. For the real range
  of ability, culture, literacy, and attention — and for vulnerable users and high-stakes
  moments (children, elders, health/money/crisis) where the persuasion half should *reduce*,
  not intensify — see `references/inclusive-design.md`.
- **Watch your own biases.** The same shortcuts these techniques rely on run in *you* — you
  overweight the vivid demo, assume users are like you, and see the pattern you hoped to
  find. Treat your instinct as a hypothesis, and let watching real people (see
  `references/usability-testing.md`) overrule it.
