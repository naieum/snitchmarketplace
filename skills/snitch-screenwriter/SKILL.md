---
name: snitch-screenwriter
description: Develop or revise a screenplay for animation or live action from a premise, treatment, outline, or draft. Use for film treatments, scene outlines, screenplay pages, dialogue, story structure, character arcs, and script audits across short or long forms. Do NOT use for the focused 2–5 minute animated-short story workflow (use snitch-animation), integrated staging and shot direction of a supplied script (use snitch-director), or a visual-world bible (use snitch-productiondesign).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Screenwriter

How does this film become a script people can perform and produce? Develop the story from
the user's premise or existing pages into consequential scenes, playable action, and
dialogue. Preserve the user's premise, genre, voice, protected scenes, and ending unless
asked to change them. This Skill writes and diagnoses the story; it does not decide camera
setups or make finished media. Work across live action, animation, stop motion, and mixed
media, at the length the user requests.

For the focused workflow that turns a premise into a timed 2–5 minute animated story,
call the Skill tool with "snitch-animation". For integrated staging, performance, shots,
edit, and sound of an existing script, call the Skill tool with "snitch-director". For a
visual-world or asset bible, call the Skill tool with "snitch-productiondesign". Use one
Skill call per handoff. If the host has no Skill tool, use its supported loading mechanism
without pretending a call occurred. When writing and directing are both requested, settle
the story version first and carry its scene IDs and protected decisions into direction.

## Choose the deliverable

| Request | Deliver |
|---|---|
| Explore a premise | Logline, dramatic question, character desire, stakes, and story paths if options were requested |
| Develop a story | Treatment or scene outline with cause, change, and unresolved questions |
| Write a script | Complete requested scenes or screenplay pages with action and exact dialogue |
| Revise supplied pages | Diagnosis, revised requested scope, and a change ledger |
| Audit a draft | Evidenced Findings, Passes, and Skips; no unsolicited rewrite |

Read the supplied draft/version, outline, character and world notes, required lines,
ending, references, medium, target length, audience, format, and production limits. Keep
existing scene IDs; otherwise assign stable IDs such as `SC01`. Label source facts,
interpretations, and new proposals. Ask only for a missing decision that blocks a
consequential choice. Otherwise state reversible assumptions and proceed. A logline request
does not authorize an invented feature screenplay.

## Develop and test the story

1. **Name the central motion.** Identify the point-of-view character or ensemble, active
   want, opposing force, stakes, and the question the ending answers. An atmospheric or
   ensemble film need not force one hero or a moral lesson. Preserve a supplied ending and
   work backward to establish what earns it.
2. **Map change, not a mandatory template.** List decisions, discoveries, reversals, and
   costs. For each major beat ask what prior fact or action enables it, what changes now,
   and what later action it makes possible. An outside event can start a complication, but
   its consequences must enter the established story. Fixed act ratios and prescribed
   beats are not requirements. For a substantial outline, read
   [references/story-and-scene.md](references/story-and-scene.md).
3. **Build scenes with an event.** State who wants what, what resistance or discovery
   changes the tactic, and what state the scene leaves behind. Purposeful atmosphere,
   observation, and silence can alter knowledge, expectation, tension, or emotional
   context. A scene need not contain an argument or joke. In an audit, trace whether a
   quiet image, choice, or line returns later; name the source and payoff scenes together
   in a Pass when the connection is supported.
4. **Write performable pages.** Use present-tense observable action and exact dialogue.
   Give actors or animators behavior they can play. Avoid camera instructions unless a
   viewpoint or reveal is necessary to understand the story, or the user requests them.
   For dialogue or scene revision, read
   [references/dialogue-and-revision.md](references/dialogue-and-revision.md).
5. **Trace continuity and feasibility.** Follow who knows what, where people and key
   props are, what a rule permits, and which choices permanently change the situation.
   Respect hard cast, location, effect, and access limits. If they conflict with protected
   story material, surface the conflict rather than silently rewriting it. For multi-scene
   work, read [references/script-continuity.md](references/script-continuity.md).

For a full screenplay request, continue through the requested scope. Do not call a sample
opening a completed film. If output length prevents complete delivery in one response,
state exact scene coverage and continue in stable batches without redoing approved pages.
Preserve the input draft when revising; return a new version or clear replacement block.

## Runtime and format

Separate target duration from verified duration. Estimate dialogue delivery, action,
reactions, and intentional holds; do not use a universal pages-per-minute claim or stretch
a time label over action that cannot fit. An outline has coarser estimates than a performed
read or animatic. If a hard target conflicts with protected dialogue or action, show the
conflict and offer conditional changes. Do not quietly accelerate performance, cut
protected text, or claim measured runtime from a desk estimate.

Match the user's requested screenplay format or project convention. Otherwise use
readable scene headings, action, character cues, dialogue, and transitions only where they
aid comprehension. Preserve a supplied format when editing. Do not claim readiness for a
particular submission system without checking its current requirements.

## Deliver and verify

Scale output to the request. A full development packet can include a brief, logline,
treatment, scene outline, script, and continuity/change notes; a single-scene revision
needs only that scene and affected context. A screenplay scene has a stable ID, place/time,
present-tense action, exact spoken dialogue, and changed exit state. An outline can use
`scene ID | location/time | objective or focus | event/change | causal link | exit state`.
A revision names the input version, protected elements, changes, and downstream scenes
needing another pass. End with verification naming scenes inspected or written and whether
timing was estimated, read, or tested.

For an audit, each **Finding** has **Impact** (High: central causal chain, ending, or hard
constraint fails; Medium: scene/character continuity or local turn fails; Low: local
clarity), **Evidence** (actual `file:line` and snippet, or scene ID and quoted text),
**Risk**, and **Fix**. A **Pass** names the scenes and links checked; a **Skip** names
missing material, the claim it prevents, and what would unblock it. Use an explicit Skip
for untested runtime or performance when only prose is supplied; an unlabeled caveat
does not make audit coverage clear. A stylistic preference is not a Finding without a
broken story function or stated constraint. A character's unproven accusation may be
intentional behavior rather than an objective continuity error. Likewise, an unexplained
event may be a deliberately
withheld mystery; name the missing setup or later payoff to inspect without asserting a
contradiction unless the supplied material rules out a coherent path. Do not invent
footage, audience reactions, approval, or measured duration.

Return inline unless files were requested or the project has an output convention. The
Skill ends at writing or auditing; casting, filming, rendering, editing, and publishing
need their own requested workflows.
