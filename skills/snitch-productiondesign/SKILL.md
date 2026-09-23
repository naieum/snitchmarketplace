---
name: snitch-productiondesign
description: Design or audit the visual world of a supplied film script, treatment, or scene for animation or live action, covering locations, sets, characters, costumes, props, palette, materials, and continuity states. Use for "design the world", "scene setting", "visual bible", "character and prop bible", "set design", "location look", or "production design audit". Produces reusable design records and scene-ready layout requirements without a generation service. Do NOT use for camera optics, lighting setups, or shot coverage (use snitch-cinematography), integrating the whole film's performance, shots, edit, and sound (use snitch-director), or writing a 2–5 minute animated story (use snitch-animation).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Production Design

What world must exist for this film to work? Translate the supplied story into locations,
sets, characters, costumes, and props with consistent appearance and useful spatial rules.
Every significant design choice supports story action, audience understanding, or a
production constraint. An aesthetic moodboard alone does not specify a scene people can use.

Work in live action, 2D/3D animation, stop motion, or mixed media. A location may be found,
built, drawn, modeled, or composited. Specify what must remain stable and what changes by
scene. Descriptions and references help the team match a design; they do not guarantee a
rendered match or prove an asset has been built.

## Pick the deliverable

- **Visual bible:** film-wide world rules and canonical character, location, costume, and
  important prop records from a script/treatment.
- **Scene design:** a specific room or exterior, its geography and needed objects, with
  entry/exit state and storyboard/layout information.
- **Focused design:** answer a request for one character, setting, costume, or prop.
- **Audit or revision:** identify evidenced contradictions or gaps in supplied design
  material; revise only the requested parts and their dependent records.

For camera position, lens, movement, or lighting setups, call the Skill tool with
"snitch-cinematography". For an integrated plan across performance, shots, edit, and sound,
call the Skill tool with "snitch-director". For a 2–5 minute animated story from scratch,
call the Skill tool with "snitch-animation". If the host lacks a Skill tool, use its
supported loading mechanism honestly. A bounded set or character request needs no full
film plan first.

Read supplied script version, scene list, character notes, world rules, art or location
references, format/aspect ratio, target audience, medium, and production limits. Preserve
established names, protected design traits, and scene/asset IDs. Otherwise assign stable
IDs such as `CH01`, `LOC01`, `PR01`, `COST01` and record the source scene/beat IDs. Distinguish
what the script establishes from a new proposal and from a reference that was actually
inspected. Do not fabricate reference files, locations, assets, permissions, or costs.

## Build a usable world

1. **Extract the story requirements.** For each requested scene, list the people, places,
   action surfaces, entrances/exits, sightlines, hero props, state changes, and information
   that must be visible or concealed. Separate essential requirements from stylistic options.
2. **Choose coherent world rules.** Define period and setting, scale, shape language,
   palette/material relationships, wear/weather, and any stylized physical rule that affects
   action. Explain exceptions. Reuse choices when the same character or location returns.
   For substantial world work, load [references/visual-system.md](references/visual-system.md).
3. **Design in space.** For a scene, name landmarks, orientation, doors, windows, obstacles,
   action paths, prop resting places, and camera/animation access. A set must support the
   stated action; make a simple overhead map if needed. Load
   [references/scene-layout.md](references/scene-layout.md) for live-action and animation
   adaptations. Do not prescribe camera shots or lighting rigs while placing the usable
   world; note window and practical-source positions for the camera/light plan.
4. **Record assets.** Load [references/asset-bible.md](references/asset-bible.md) when
   people, locations, costumes, or props recur. For each, state invariant traits,
   acceptable variation, source/reference role, and mutable states. A permanent scar is an
   invariant; a torn sleeve, open door, or missing key is a scene state. Resolve conflicting
   supplied references explicitly, by trait, rather than averaging them silently.
5. **Check feasibility and continuity.** Trace required objects from setup through use and
   payoff. Name anything absent from the script or available assets that a choice assumes.
   Check set space, reusable views, resets, costume/prop duplicates, scale, material,
   construction, animation layers/rig range, and intended frame visibility as applicable.
   Offer a concrete design alternative if a hard limit cannot support the first proposal.

Treat appearance ownership as distinct from camera/light ownership. A blue wall and a
north-facing window are design facts; whether a scene needs soft side light, a wide shot,
or a dolly path is a cinematography decision. If a chosen camera plan reveals an unbuilt
wall, revise the set requirement or propose an angle change to the owning department.

## Handoff and evidence

A full request returns a brief (input version, scope, medium, constraints), visual rules,
scene/location cards, character/costume/prop records, state ledger, reference map, and an
open-items list. A scene card states `scene ID | place/time | story use | geography and
orientation | required action/visibility | assets and states | live-action or animation
build notes | unresolved needs`. An asset record states `ID | canonical traits | variations
allowed | actual reference and its role | scene states | production needs`. Scale this to
the request: one room need not generate a feature-wide bible. If asked for image prompts,
provide portable, self-contained appearance instructions and mark them as untested.

For an audit, each **Finding** carries **Impact** (High: central story action or a hard
constraint fails; Medium: a local design/continuity gap; Low: local ambiguity), **Evidence**
(file:line and snippet, supplied scene/asset ID and text, or an inspected image/video
asset plus observable detail), **Risk**, and **Fix**. A **Pass** names the material and
states checked; a **Skip** names what was unavailable. An image can prove its visible
appearance, not hidden dimensions, a reverse side, suitability for construction, or an
animation rig. Do not grade a declared aesthetic choice as a defect without showing its
impact on the task or a protected constraint.

Return inline unless files are requested or the project already has an output convention.
Do not overwrite supplied bibles or concept art without authorization. This Skill writes
design specifications or audits; actual art, building, image generation, or publication
requires a separately requested production workflow.
