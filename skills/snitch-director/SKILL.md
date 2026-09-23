---
name: snitch-director
description: Turn a film script, treatment, or scene into an integrated directing plan for animation or live action, with staging, performance, camera, design, edit and sound intent, and continuity. Use for "direct this scene", "plan the whole film", "visual treatment", "film preproduction", or a shot-plan audit. Produces service-independent written plans and optional shot prompts. Do NOT use for focused camera and light (use snitch-cinematography), world and assets (use snitch-productiondesign), panels (use snitch-storyboard), picture editing (use snitch-editor), sound design (use snitch-sound), or story writing (use snitch-screenwriter or snitch-animation).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.3.0
  homepage: https://snitchplugin.com
---

# Snitch: Director

How should this story look, move, and sound on screen? Translate the user's story into
staging, performance, and shots that a crew, storyboard artist, animator, or generation
workflow can execute. Every major visual decision serves a specific story moment or
viewer experience. A list of cinematic adjectives is not a directing plan.

Work across live action, 2D/3D animation, stop motion, and mixed media, from one scene to
feature-length planning. Use the production method and requested duration; do not default
all films to short animation. This skill produces written direction, not finished media.
It requires no provider account, CLI, remote prompt enhancer, model catalog, or hosted agent.

## Pick the requested work

| Request | Deliver |
|---|---|
| Direct a script or scene | Treatment, staged scenes, shot plan, continuity and sound/edit notes |
| Camera or lighting advice only | Call the Skill tool with "snitch-cinematography" |
| Location, character, costume, or prop design only | Call the Skill tool with "snitch-productiondesign" |
| Detailed panels or animatic plan only | Call the Skill tool with "snitch-storyboard" |
| Selected cut, coverage gap, or pickup only | Call the Skill tool with "snitch-editor" |
| Sound spotting, cues, or mix brief only | Call the Skill tool with "snitch-sound" |
| Screenplay, treatment, or dialogue writing only | Call the Skill tool with "snitch-screenwriter" or "snitch-animation" according to scope |
| Storyboard notes within an integrated plan | Panel descriptions and shot transitions; never claim text is a drawn board |
| Prompts for an existing plan | Portable shot instructions, resolved reference descriptions, and open capability questions |
| Audit existing direction or footage | Findings grounded in the material actually inspected; no unsolicited rewrite |
| Coordinate specialist agents | Bounded assignments and integrated decisions, using the optional collaboration reference |

Story writing decides what happens. This skill decides how the audience experiences it.
For a requested 2–5 minute animated story from scratch, call the Skill tool with
"snitch-animation"; carry its beat IDs and script forward if directing is also requested.
For campaign strategy or UGC briefs, call the Skill tool with "snitch-cmo". If no Skill tool
exists, use the host's supported skill-loading mechanism and be honest about availability.
For a focused camera/lighting request, call the Skill tool with "snitch-cinematography";
for a focused visual-world or asset request, call the Skill tool with
"snitch-productiondesign". For detailed boards, a picture edit, or a sound plan alone,
call the Skill tool with "snitch-storyboard", "snitch-editor", or "snitch-sound" respectively.
For broader screenplay writing, call the Skill tool with "snitch-screenwriter". Use one skill
per call. Keep an integrated directing request
here: this Skill resolves how the departments' choices serve the scene together and remains
usable when specialist Skills are unavailable.
Never require a sibling merely to direct a supplied script. If a broad film premise lacks a
script, a treatment and provisional scene plan are possible; label invented beats and do
not pass off that plan as a completed screenplay. Preserve protected dialogue, plot, and ending.

## Establish the working brief

Read the supplied script version, boards, references, asset inventory, and production limits.
Record medium, audience, tone, duration, aspect ratio, intended viewing surface, scope,
existing look, and constraints that affect staging. Ask only for consequential missing
choices; proceed with explicit provisional assumptions when reversible. Separate facts from
creative proposals. Preserve the user's aspect ratio and style even when another is familiar.

Keep existing scene/beat/asset IDs. Otherwise assign stable scene IDs (SC01), shot IDs
(SC01-SH01), and character/location/prop IDs (CH01, LOC01, PR01). IDs identify things; they
are not a promise that a renderer recognizes them. Record the input version and touched
scope so a later story change can identify which decisions need revisiting.

For a whole film, first establish the film-wide visual rules and scene inventory, then
cover the requested scenes. If asked for the entire shot plan, work in scene batches until
all scenes are covered; report coverage and remaining work accurately. A sample scene is
not a complete feature plan. For one scene, omit unrelated film-wide paperwork.

## Direct in dependency order

1. **Interpret the scene.** State whose experience anchors it, what each character wants,
   what changes, and what the audience should know before and after the turn. Identify
   information that must remain hidden until a particular shot. Intentional ambiguity is
   allowed; accidental illegibility is not the same thing.
2. **Set the visual rules.** Choose a small set of consistent decisions for composition,
   camera distance/mobility, depth, light, palette, and texture. Translate mood into visible
   properties. Explain planned exceptions, such as a first moving shot when control breaks.
   A genre suggests options; it does not prescribe one lens, color, or cutting speed.
3. **Stage the scene and performance.** Load the concise directing check in
   [references/staging-and-world.md](references/staging-and-world.md). Map geography,
   entrances, props, sightlines, movement, and changes in power or distance. Give playable
   intentions and observable actions; tie performance shifts to cues. Establish the action
   axis before choosing reverse angles. Build the world to support the action. The deep
   visual-bible and asset-design workflow belongs to snitch-productiondesign.
4. **Choose camera and light.** Load the concise directing check in
   [references/camera-and-light.md](references/camera-and-light.md). For each essential shot,
   specify subject/action, framing, viewpoint, focus, movement or stillness, and lighting
   motivation. Explain what the shot reveals, withholds, or makes the viewer attend to.
   Prefer the simplest executable setup that achieves that purpose; preserve intentionally
   elaborate direction when requested and name its production implications. The deep
   optics, lighting, and shot-feasibility workflow belongs to snitch-cinematography.
5. **Design the cut and sound.** Load
   [references/coverage-and-continuity.md](references/coverage-and-continuity.md). Link shots
   through an action, look, revelation, sound, or deliberate contrast. Cover the change and
   its consequence. Plan sound perspective, cues, silence, and bridges alongside images;
   do not fill every moment with music. Separate essential shots from optional coverage.
6. **Make the handoff concrete.** Use
   [references/direction-packet.md](references/direction-packet.md) for the smallest useful
   packet and optional portable prompts. Maintain a shared description of recurring assets
   and write each shot's changes explicitly. No invented platform limits, universal prompt
   length cap, mandatory camera brand, or claim that references guarantee identity.
7. **Check the sequence.** Trace the required story information, continuity transitions,
   timing, and feasibility. Resolve conflicting proposals against the user's constraints
   and scene intent; when constraints cannot all hold, state the conflict and ask which may
   change. Deliver a coherent recommendation, not several contradictory departments' drafts.

## Timing and verification

Distinguish estimated screen duration, source clip length, edit handles, setup time, and
shoot order. Only selected timeline material counts toward the cut; alternate coverage is
not additional story time. Parallel action and sound do not automatically add durations.
Transitions with overlapping images count their elapsed timeline time once. Use seconds
unless a frame rate is supplied or explicitly assumed; do not invent frame-accurate timecode.

A shot must leave time to perceive the action and its consequence. Respect supplied dialogue
lengths and performance timings; say when a read or animatic is needed. Do not shorten
protected dialogue, rush an emotional beat, or make duration labels add up while the action
cannot fit. Missing footage means rendered identity, focus, lighting, and performance remain
unverified, even if the written plan is internally consistent.

For plan audits, each **Finding** includes **Impact** (High: changes a protected story fact
or central action, or makes production infeasible under a hard limit; Medium: a local
continuity/coverage/timing failure; Low: local ambiguity), **Evidence** (file:line and snippet, or supplied scene/shot
ID and text), **Risk**, and **Fix**. For inspected media, cite asset and timestamp/frame plus
what is visible or audible. Judge impact by consequence: an ordinary local state mismatch
stays Medium even when a continuity instruction was explicit, unless it has the High impact
described above. A **Pass** names the material and transitions checked. A **Skip**
names unavailable material or capability. Do not infer sound from still images, movement
from one frame, or measured exposure/focus from a prose prompt. A stylistic exception with
clear intent is not automatically a Finding.

## Output and collaboration

A full direction request gets a concise brief and treatment, staged scene cards, ordered shot
cards, continuity records, edit/sound notes, and a verification note with scope and open work.
Use the packet reference for fields. A focused request gets only its relevant subset. Return
inline unless files are requested or an established project convention supplies their home;
keep user projects out of this skill's own folder. Preserve originals when revising.

For an explicitly requested team workflow, load
[references/department-assignments.md](references/department-assignments.md). Department roles
are task briefs, not installed agents or required parallel calls. Check host capabilities and
authorization before delegation; otherwise perform the same checks locally. Direction remains
one integrated decision set. Do not claim a second opinion if none ran.

The skill ends at a written plan or audit. Generation, actual editing/mixing, equipment
operation, scheduling people, and publication require their own requested workflow. When
that work is requested, pass the plan through the host's available mechanism rather than
embedding provider commands in this skill. No plan alone proves a shot was produced.
