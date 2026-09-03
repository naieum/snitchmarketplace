---
name: snitch-router
description: Ask which Snitch skill or flow fits your situation. A router over the whole family.
disable-model-invocation: true
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills. Pure guidance; no server, tools, or external calls required.
metadata:
  author: Snitch
  version: 0.3.0
  homepage: https://snitchplugin.com
---

# Snitch: Router

You don't remember every Snitch skill, so ask. Read the user's situation, walk the map below,
and name the one or two skills that fit — with the boundary line that separates them from the
near-misses. When the user then wants one run, call the Skill tool with its name (one skill
per call).

The family splits by **when in the product's life you are** and **what a finding is judged
against**. Those two questions route almost everything.

## The build flow: decide → bootstrap → build → tell → grade

The route greenfield work travels. You're starting (or restarting) a site, app, or product.

1. **`snitch-blueprint`** makes the load-bearing product decisions before and while you
   build — audience, the one conversion action, surface inventory, build order, and the
   price *number* (a four-question price-sensitivity survey when the user is stuck on what to
   charge) — and checks them into `BLUEPRINT.md`. The seam it owns: it decides what *should*
   exist; the audits below grade what *does*.
2. **`snitch-devready`** runs beside it on greenfield: blueprint makes the product decisions
   good, devready makes the repo good for agents (CLAUDE.md/AGENTS.md, commands, permissions,
   the two-tier coding standard wired to real gates). Neither replaces the other.
3. Build to the blueprint's specs. For any new persuasive page, the blueprint cites CLOSER as
   the default section order; the deep per-stage work belongs to **`snitch-focusedcopy`**.
4. **`snitch-cmo`** inherits the blueprint: when `BLUEPRINT.md` exists, cmo reads its audience
   and wedge, claim inventory, and constraints as prior decisions instead of re-asking them,
   turns them into a checked-in `marketing/` foundation, and drafts channel content from it.
   It drafts; a human always publishes.
5. When traffic or launch nears, the audits grade the build. **`snitch-marketing`,
   `snitch-ux` and `snitch-ada` read `BLUEPRINT.md`'s decisions and report tensions** — where
   the built site contradicts a recorded decision, that is a tension to resolve, not an
   auto-fix. For ada that cuts both ways: a recorded Decision such as "English-only at launch"
   makes its i18n categories a Skip citing that line, while an accessibility barrier is never
   waived by a Decision. **`snitch-security` audits the code**; it needs no blueprint to do it.

## The audits: pick by what the finding is judged against

Name the judge and the table names the skill. Overlap isn't zero — several artifacts have two
legitimate judges — but every such artifact is split, not shared: each skill owns its half and
hands the other over by name. The confusions below settle the pairs that come up most.

| The finding is judged against... | Skill |
|---|---|
| Attacker impact (vulnerabilities, CWE/OWASP, compliance evidence) | `snitch-security` |
| Search and traffic outcomes (SEO, GEO/AI citation, schema, CWV contributors) | `snitch-marketing` |
| WCAG 2.2 AA conformance and the legal exposure a failure carries (ADA, Section 508, the European Accessibility Act) | `snitch-ada` |
| Whether the site is built to serve people in their own language and script (i18n readiness: strings, plurals, locale formatting, RTL, catalogs) | `snitch-ada` |
| The user's decision path (clarity, persuasion, usability, UI copy) | `snitch-ux` |
| Ad-platform requirements (pixels, CAPI, conversion tracking, Consent Mode v2, ads.txt) | `snitch-adsready` |
| Store policy and upload gates (App Store / Play review, privacy declarations) | `snitch-storeready` |
| A controlled-language rule set — "audit my docs", "does this sound like AI" | `snitch-docwriter` |

The classic confusions, settled:

- **A headline**: scored on keyword and intent match → marketing; scored on whether the
  visitor knows what to do next → ux.
- **An unlabelled input, a 3:1 contrast ratio, a 20px tap target**: scored as a WCAG criterion
  and the exposure of failing it → ada (it owns the conformance sweep, the criterion table and
  the legal read); scored as a barrier that stops a specific user finishing the task, or as a
  pattern a vulnerable user meets on their decision path → ux. The same broken element can be a
  finding in both; neither drops its half.
- **`lang`, hreflang, and translations**: read as a search signal — how engines are told which
  locale a page serves (hreflang, locale canonicals, `lang` as machine readability) and whether
  a rendered translated page reads well → marketing; read as conformance and code readiness —
  `lang` against SC 3.1.1 / 3.1.2, and whether the strings, plurals, formats, RTL layout and
  catalogs are built to carry another language at all → ada.
- **`debuggable=true`** (and friends): judged against store policy → storeready; judged
  against attacker impact → security. The same fact can be two findings.
- **Tracking code**: the pixel and consent wiring itself — pixel install completeness, CAPI
  pairing, Consent Mode v2 defaults and CMP behavior — → adsready; the site's analytics
  instrumentation — install, tag-manager hygiene, event taxonomy, UTM consistency, and whether
  any of it hurts SEO or trust — → marketing; whether tracking has the consent surface the
  *stores* require → storeready. A pixel that is present but whose wiring can't be judged from
  the page is marketing's cue to hand over to adsready.
- **Core Web Vitals and security headers**: read as a paid-media input — the field metrics an
  ad platform folds into Quality Score, and the CSP / header change a pixel needs before it can
  fire — → adsready; read as the contributors that cost search rankings (render-blocking, image
  weight, font loading, bundle weight, CLS prevention) → marketing; read as the defensive
  posture the header sets → security. Same header, three questions.
- **Store-listing text**: complies with metadata rules → storeready; sells → marketing /
  focusedcopy.

## The writing lane: pick by whether the prose keeps a voice

- **`snitch-docwriter`** — technical prose (docs, READMEs, PR descriptions, error messages,
  runbooks). Its controlled style strips voice on purpose, and it scores prose with a
  deterministic linter. Never route marketing copy through it.
- **`snitch-focusedcopy`** — one persuasive page or funnel's *structure*: the CLOSER stage
  map, reordering sections, verifying every claim before it's written. Reach for it when one
  page's persuasion arc is the problem. It takes the piece as given, whoever wrote it — a
  landing page, a cold email, a pitch deck — so on the collateral it shares with cmo below, the
  seam is **who drafts it vs. what order it's in**: a blank page → cmo, a draft that doesn't
  close → focusedcopy.
- **`snitch-cmo` (drafting mode)** — off-site channel content (blog, X, LinkedIn, Reddit/HN,
  outreach, sponsorships, launch and PR sequences, UGC briefs), plus the **brand story**
  (the villain, the About-page long story), **naming** (company, product, feature), and
  **sales collateral** (lead generators, sales emails, pitch decks, long-form sales copy) —
  written here from scratch, restructured later by focusedcopy.
  All of it driven by the checked-in foundation. No foundation, no drafting.
- **UI microcopy, CTAs, taglines, and the on-surface brand message** live in
  **`snitch-ux`**'s copy passes — the hero, the one-liner, the tagline as the visitor meets
  them, judged against the decision path rather than against a channel. The boundary with cmo
  is drafts vs. judgment: cmo drafts the hero, one-liner, and tagline options that fall out of
  positioning; ux judges the one the page ends up running and rewrites the microcopy around it.
  Everything off the surface, and the strategy that decides what the surface should say, stays
  cmo's.

**Persuasion, pricing, and retention** are the five-way case, so read the verbs. Marketing
*scores the site*: its persuasion-architecture, pricing-display and retention-funnel categories
grade the whole surface set, section by section, each cell a Pass carrying the surfaces it read
or a Skip. ux *fixes the flow*: the same psychology as checkable moves on the screen in front
of it, behind the ethics gate. blueprint *sets the price number* on a greenfield build (the
price-sensitivity survey). cmo *reads the pricing strategy* — the model, tier shape, and what
the position implies — into the foundation. And focusedcopy is the hands-on structural fix for
one page's persuasion arc. Score the site → marketing; fix the screen → ux; fix one page's
section order → focusedcopy; decide the number → blueprint; decide the strategy → cmo.

## Standalones and preconditions

- **`snitch-adsready`** also *sets up* tracking (idempotent fixes, stepped walkthroughs), not
  just audits it — reach for it the moment paid spend is planned. Its structured-data surface
  stops at the markup an ad platform itself consumes (Product/Offer for a shopping feed);
  everything else schema-shaped, plus llms.txt and AI search, hreflang and localized landing
  pages, and local business listings, is marketing's; the code's i18n readiness is ada's.
- **`snitch-storeready`** also runs a web-to-store feasibility mode when there's no native
  target yet ("can I put my web app in the App Store?").
- **`snitch-devready`** is runnable any time on brownfield too — "make this repo
  Claude-ready" needs no blueprint.
- **`snitch-blueprint`** is not greenfield-only either: it has a brownfield entry for the
  mid-build case where pages exist but nobody decided who they're for. It derives the
  blueprint from what already exists, surfaces the undeclared decisions, and course-corrects.
- Gates travel with the skills, and they are not one gate (see `CONTEXT.md`):
  - the **UI ethics gate** — `snitch-ux` owns the canonical version; `snitch-blueprint`
    carries only the one-line general test and defers to ux's gate when UI gets built;
  - cmo's **channel-conduct gate** — same shape, different surface: published channel content,
    not interface design;
  - the **evidence / anti-fabrication gates** (`snitch-cmo`, `snitch-focusedcopy`);
  - the **redaction gate** (`snitch-security`, `snitch-marketing`, `snitch-ada`,
    `snitch-storeready`).

  Those, and the never-auto-fix / human-publishes rules, hold no matter which route you took in.

## Not in this family

Paid-ads campaign management, penalty-recovery negotiation, deploying tracking code to
third-party dashboards, publishing content, app-store submission itself, and the legal side of
an accessibility complaint — filing a VPAT, answering a demand letter, commissioning a certified
audit — are all human work the skills prepare but never perform.
