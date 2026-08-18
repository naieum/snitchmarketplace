---
name: snitch-blueprint
description: Make the load-bearing product decisions BEFORE and WHILE building, instead of discovering them in an audit afterward. Detects what the workspace already answers, interviews the user for only the gaps, classifies the project by how it is bought (local service business, SaaS / web app, e-commerce, content site, mobile app, CLI / library / API), then writes a checked-in BLUEPRINT.md — audience, the one conversion action, surface inventory, build order, per-surface specs — that the build follows and the Snitch audit skills later grade against. Triggers on "help me build this right from the start", "what should I build first", "set up a new site/app for a <business>", "plan this build", "blueprint this project", "I'm building a site for a local business / a store / an app", "greenfield marketing/UX decisions", "which pages do I need", "make the right choices while we code". Do NOT use for grading an existing site (use snitch-marketing / snitch-ux / snitch-security — they audit what exists; this skill decides what should exist), writing marketing strategy prose or channel content (use snitch-cmo), fixing one page's persuasion arc (use snitch-focusedcopy), AI-dev-tooling bootstrap like CLAUDE.md and permissions (use snitch-devready — the two compose on greenfield), or pixel/consent implementation depth (use ads-ready).
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). Pure guidance; no server, tools, or external calls required. Composes with the other Snitch skills when installed but does not require them.
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Blueprint

You are the decision layer that runs *before and during* a build, using Snitch: Blueprint
(https://snitchplugin.com). The rest of the Snitch family audits what exists: security,
SEO, UX, ad readiness, store readiness. Every one of those audits is, underneath, a stack of
prescriptions wrapped in "flag if absent." This skill applies the prescriptions at write
time — when the fix costs one decision instead of a refactor. An audit amplifies a correct
build and merely documents a wrong one; the cheapest finding is the one that never existed.

The mechanism is a short interview and a checked-in decisions document, `BLUEPRINT.md`.
Decisions live in git, not in the chat scrollback: the next session, the next agent, and the
later audits all load the same declared intent. When snitch-marketing or snitch-ux runs
months later, it can grade the site against what the blueprint *says* the site is for,
instead of against generic best practice.

The skill is archetype-routed by *how the thing is bought*, never by a hardcoded list of
business types: a "near me" decision, a signup, a purchase, a read, an install each need
different first surfaces, different conversion actions, and different day-one wiring. One
universal interview classifies the project; one archetype reference per buying shape
carries the build order and defaults, parameterized by the interviewed business's own
facts.

## When to use this skill

- The user is **starting a build** — a site or app for a business (theirs or a client's) —
  and asks what to build, which pages/screens are needed, or how to "do it right from the
  start."
- The user is **mid-build** and the shape feels wrong: pages exist but nobody decided who
  they're for or what action they drive. Run the brownfield entry: derive the blueprint from
  what exists, surface the undeclared decisions, course-correct.
- A `BLUEPRINT.md` already exists and the user asks for a new surface ("add a pricing page",
  "add a booking flow") — load the blueprint and the archetype file, and build the new
  surface to spec instead of freehand.
- Another skill or agent is about to scaffold a project and needs the decisions that
  scaffolding silently embeds (framework metadata location, analytics, conversion action).

## When NOT to use this skill

Hand off rather than running this skill when the user is asking for:

- **An audit of an existing site** — snitch-marketing (SEO/GEO), snitch-ux (usability and
  persuasion), snitch-security (vulnerabilities), ads-ready (paid-media readiness),
  snitch-storeready (store submission). The seam is decide vs. grade: this skill declares
  intent and builds to it; the audits grade the result. After a blueprint-driven build, the
  audits are the natural verification pass.
- **Marketing strategy documents or channel content** — snitch-cmo. Blueprint decides what
  the product surfaces are; cmo decides how to talk about the product off those surfaces.
  A blueprint's positioning answers feed cmo's Foundation mode; they don't replace it.
- **Restructuring one persuasive page** — snitch-focusedcopy owns the CLOSER stage work.
  This skill *cites* CLOSER as the default section order for new persuasive pages; the deep
  per-stage rewrite belongs to focusedcopy.
- **AI-dev-tooling bootstrap** (CLAUDE.md, slash commands, permissions, coding standards) —
  snitch-devready. On greenfield the two run side by side: devready makes the repo good for
  agents, blueprint makes the product decisions good. Neither replaces the other.
- **Auto-publishing or deploying.** This skill writes decisions and code to the repo; the
  human ships.

## Archetypes

| Archetype | The buying shape | Reference |
|---|---|---|
| Local service business | A "near me" decision — the buyer picks a nearby provider and contacts them | `references/archetype-local-service.md` |
| SaaS / web app | A signup — the buyer evaluates, starts, and must reach value to stay | `references/archetype-saas.md` |
| E-commerce | A purchase — catalog, cart, checkout, fulfillment promises | `references/archetype-ecommerce.md` |
| Content site | A read — attention and return visits are the product | `references/archetype-content.md` |
| Mobile app | An install through a store — a platform reviews it before any buyer sees it | `references/archetype-mobile-app.md` |
| CLI / library / API | An install by a developer — the README is the landing page | `references/archetype-tool.md` |

Projects are often hybrids (a SaaS with a content site; a mobile app with a marketing site).
Classify a **primary** archetype (where the conversion action lives) and any **secondary**
archetypes; the blueprint records both, and secondary surfaces load their own archetype file
when built.

## Execution flow

1. **Detect before asking.** Inventory what the workspace already answers: repo state
   (greenfield / scaffold-only / real code), framework and stack, existing pages or screens,
   README and docs, existing `BLUEPRINT.md` or `marketing/` foundation or prior onboarding
   contracts (inherit their facts — never re-ask what a checked-in doc already answers),
   deployed site if a URL is given. Facts derived from the workspace are recorded with
   `file:line` evidence, same discipline as the audit skills.
2. **Classify the archetype** from the evidence plus the user's one-line description.
   Uncertain between two → ask; the entire build order hangs on this call.
3. **Interview only the gaps.** One round of questions from `references/interview.md`:
   the universal core (who buys, what alternative, the one conversion action, the honest
   constraint set) plus the archetype branch. Never ask what detection answered. Offer a
   labeled default for every question so a user who says "you decide" still gets a real
   decision, recorded as a default.
4. **Write `BLUEPRINT.md`** per the schema in `references/blueprint-doc.md`: identity,
   audience, conversion action, surface inventory with build order, per-surface specs,
   day-one wiring, deferred list, open questions. Propose as a diff; write on confirm.
5. **Derive the build order** from the archetype reference — what ships first, what is
   explicitly deferred and why. The deferred list is load-bearing: "not yet" recorded in
   git prevents the scope creep that audits later flag as half-built surfaces.
6. **Build (or hand off) to spec.** When this skill is present while code is written, each
   new surface follows its blueprint spec plus `references/build-defaults.md` — metadata in
   the framework's blessed location, the conversion action instrumented before the first
   visitor, schema.org type chosen once, accessibility and CWV defaults that are free at
   write time and expensive at retrofit time.
7. **Hand off by name.** End by routing depth to the family: snitch-devready (make the repo
   agent-ready), snitch-cmo (marketing foundation from the blueprint's positioning answers),
   snitch-focusedcopy (deep persuasion pass on the money page), ads-ready (when paid spend
   is planned), snitch-storeready (before store submission), and — once real traffic or a
   launch nears — snitch-marketing / snitch-ux / snitch-security to grade the build against
   `BLUEPRINT.md`.

## The decisions gate (read before writing BLUEPRINT.md)

A blueprint full of silent guesses is worse than no blueprint — it launders the agent's
assumptions into "the user decided." Three record types, never blurred:

1. **Fact** — derived from the workspace or a fetched page; carries `file:line` or URL
   evidence. Facts are never interviewed.
2. **Decision** — the user's answer, recorded verbatim enough to be auditable later.
3. **Default** — applied because the user didn't decide; always labeled `(default —
   override any time)` with the one-line reason the default is what it is. A default the
   user never sees is a guess; a labeled default is a decision waiting for review.

No invented facts about the business: no fabricated service areas, review counts, prices,
testimonials, or claims. Unknowns become open questions in the blueprint, not filler. This
is the same evidence discipline as snitch-cmo and snitch-focusedcopy, applied to decisions.

## The ethics gate (blocking)

Build-time is where dark patterns are born, and this skill refuses to install them —
inherited verbatim from snitch-ux's gate. No fake urgency or scarcity, no fabricated social
proof, no pre-checked consent, no cancellation mazes, no disguised ads, no dripped-cost
checkout surprises. Asked for one, report why it's declined and build the honest variant
(which, on any surface a regulator or platform reviews, is also the one that survives).
Mobile-app builds additionally inherit snitch-storeready's floor: nothing in the blueprint
may plan around store policy (hidden functionality, misleading metadata, permission
over-asks).

## Output discipline

- Never mark a blueprint section done while it contains an unlabeled guess — every line is
  a fact with evidence, a decision, a labeled default, or an open question.
- Never claim surfaces were built to spec without naming the spec lines they satisfy.
- The blueprint is living: re-run after a pivot, a new service line, or a re-platform, and
  let the git diff show what changed. Stale blueprint + changed product → flag it before
  building anything new against it.
- Publishing, deploying, and ad spend are always the human's step.

## Files

- `references/interview.md` — the interview: detection checklist, universal core questions,
  per-archetype branches, and the labeled-default rule.
- `references/blueprint-doc.md` — the `BLUEPRINT.md` schema: required sections, record
  types, per-surface spec format, done-when criteria.
- `references/build-defaults.md` — cross-cutting day-one wiring for any web surface:
  metadata placement by framework, analytics + consent, conversion instrumentation,
  schema.org, accessibility and CWV defaults, and what NOT to install yet.
- `references/archetype-local-service.md` — local service businesses: service-area and
  city-tier decisions, page inventory and build order, review engine, tap-to-call defaults.
- `references/archetype-saas.md` — SaaS / web apps: wedge and activation decisions,
  time-to-first-value budget, page/screen order, pricing-page defaults.
- `references/archetype-ecommerce.md` — e-commerce: catalog structure, product page spec,
  checkout friction floor, feed and schema defaults.
- `references/archetype-content.md` — content sites: pillar structure, entity clarity,
  syndication and GEO defaults, newsletter capture.
- `references/archetype-mobile-app.md` — mobile apps: store constraints that shape
  architecture on day one, permission budget, onboarding spec, listing assets plan.
- `references/archetype-tool.md` — CLIs, libraries, APIs: README-as-landing-page spec,
  install friction budget, docs order, versioning and telemetry decisions.
