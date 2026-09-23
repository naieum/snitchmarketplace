---
name: snitch-storyboard
description: Turn a supplied film scene, script, or shot plan into visual storyboard panels and an animatic plan for animation or live action. Use for "storyboard this scene", "draw panels", "test the visual sequence", "layout the action", "animatic timing", or an audit of boards. Generate panel images when an authorized image capability is available, including the user's chosen tool; honor text-only requests and distinguish boards from timed animatics. Do NOT use for an integrated film direction plan (use snitch-director), a focused camera and lighting plan (use snitch-cinematography), or writing a 2–5 minute animated story from scratch (use snitch-animation).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.2.0
  homepage: https://snitchplugin.com
---

# Snitch: Storyboard

Can the sequence be read before production? Turn supplied story action and direction into
panels that show where attention goes, how action moves through space, what changes between
views, and what the viewer learns. Work in animation, live action, stop motion, or mixed
media. A panel is a chosen visual moment, not a substitute for the action between moments.

## Choose the real deliverable

| Request or available material | Deliverable | Claim you can make |
|---|---|---|
| New storyboard requested; an authorized image capability is available | Generated or drawn panel images for the requested scope, with readable panel descriptions and checks against the plan | Boards exist for the panels actually made and inspected. |
| Text-only board explicitly requested, or no authorized image capability is available | Written panel specifications, layout, selected-shot timeline, and panel-ready image prompts when generation was unavailable | A board *plan* exists; no frames were rendered. |
| Timed playback explicitly requested and an authorized media workflow exists | Playback artifact with actual panel/audio durations, transitions, and observed runtime | An animatic exists for the material actually assembled and played or measured. |
| Existing boards or animatic supplied | Evidence-based audit or bounded revision | Only inspected frames, timestamps, and tracks are verified. |

Do not rename a table of timestamps an animatic or call image prompts finished boards.
An ordinary request to storyboard a scene includes making visual panels when image creation
is available; do not wait for the words "generate images." Follow the user's chosen image
workflow when available and authorized. Otherwise use an available image capability in the
host, including an accessible website that the host can operate. Do not assume account
access or paid usage authorization. If no route can produce images, give panel-ready prompts
and state why images were not made. An explicit text-only request or an audit of supplied
boards does not trigger new image generation. An animatic plan is useful when playback
cannot be created, but its duration remains an estimate. This Skill requires no particular
generation service, editor, or drawing application.

For a whole-film plan across performance, design, camera, edit, and sound, call the Skill
tool with "snitch-director". For a focused optics or lighting decision, call the Skill tool
with "snitch-cinematography". For a 2–5 minute animated story from a premise, call the
Skill tool with "snitch-animation". If the host lacks a Skill tool, use its supported
skill-loading mechanism and report what actually ran. This Skill can board a supplied
script or staged scene without requiring a full directing project. It owns the sequential
visual test; the director owns story intent and integrated choices, cinematography owns
deep camera/light design, and editing owns decisions based on actual footage or an assembly.

## Establish the board contract

Read the actual script version, beat and shot IDs, intended reveal order, staging,
geography, character/prop states, style, duration, aspect ratio, and production limits.
Preserve protected dialogue, plot, ending, camera constraints, and intentional ambiguity.
Keep supplied IDs; otherwise assign `SC01-SH01-P01` for panels and link every panel to its
source scene/beat and selected shot. Record what is supplied versus proposed. Ask only for
missing choices that block a meaningful board; use labeled, reversible assumptions for
the rest. If a scene's geography is insufficient, draw or describe a provisional overhead
layout and mark what a director or location test must confirm.

The smallest board can be one shot with start/turn/end panels. An elaborate action may
need several panels inside one shot. A cut begins a new shot, but subject motion or a
camera move inside a shot does not. Do not force a fixed number of panels per beat.

## Build a readable sequence

1. **Track knowledge and action.** State what the audience knows at entry, the critical
   action/reveal, and what must register before the next view. Mark concealed information
   so a wide, insert, reflection, or audio cue does not accidentally expose it early.
2. **Make layout testable.** Establish landmarks, participants, prop positions, travel
   paths, axis, eyelines, and screen direction. Load
   [references/panels-and-layout.md](references/panels-and-layout.md) when the action or
   camera travels, geography is contested, or panel detail must be handed to artists.
   Give subject and camera arrows separate labels and define their start and end positions.
3. **Select visual instants.** Choose panels at state changes, poses, handoffs, reveals,
   reactions, and camera/attention changes. Describe composition and the visible instant,
   then the motion or performance between this panel and the next. Do not put several
   incompatible moments inside one still frame. Keep appearance and style references
   consistent with supplied design decisions.
4. **Connect shots.** Load
   [references/transitions-and-continuity.md](references/transitions-and-continuity.md)
   when multiple shots or scenes join. Identify the cut or transition trigger and carry
   action phase, prop holder/state, position, eyeline, light/time, and knowledge across
   boundaries. A deliberate axis crossing or jump needs a readable bridge or stated
   disorientation goal; a random insert does not automatically repair geography.
5. **Budget elapsed time.** Load
   [references/timing-and-animatics.md](references/timing-and-animatics.md) when runtime,
   dialogue, sound, or an animatic matters. Assign estimated intervals to *selected shots*
   and action phases. Panels within one shot describe its progression; they do not each
   add the shot's full duration. Account once for simultaneous action/audio and overlapping
   transitions. Keep handles and alternate coverage outside selected screen time.
6. **Make the visual panels.** For a new storyboard, load
   [references/image-boards.md](references/image-boards.md) and use an available authorized
   image capability to render each essential panel in the requested scope. Keep one visual
   instant per panel and preserve the planned IDs, geography, character/prop states, and
   reveal order. Inspect the actual output and correct material deviations. If generation
   is unavailable or the user requested text only, keep the same panel design as written
   cards; give usable per-panel image prompts when a visual result was wanted but blocked.
7. **Review at viewing scale.** Check whether the important object, action, and response
   can actually be seen in the intended frame and duration, including small/mobile viewing
   when specified. Test silhouette, screen direction, reveal order, and the cut from each
   panel's exit state to the next entry state. Identify specific missing panels, timing
   conflicts, or production tests; do not fill a board with decorative coverage.

## Deliver and verify

A full storyboard packet includes input version/scope, assumptions and protected decisions,
a simple layout where needed, an ordered selected-shot index, panel cards, a continuity
ledger, timing and sound notes, and verification limits. A panel card contains
`panel ID | source beat/shot | estimated interval within shot | visible composition and
action instant | subject motion | camera motion | sound/cut cue | entry/exit state`.
Use a compact table plus expanded cards if one wide table would be unreadable. For each
selected shot, state its story purpose, estimated duration, essential/optional status, and
next cut or endpoint. Record alternatives separately. For a focused request, return only
the relevant subset.

For actual boards, preserve panel IDs in filenames or a manifest, supply visual files or
inline images with text descriptions, and inspect every produced panel for the story
information, state, orientation, and style constraints it is meant to carry. Identify
missing or unresolved panels; do not imply a complete visual board from a few samples or
claim uninspected renders match. If producing an animatic, state the actual file, timeline
version,
frame rate if known, selected duration, whether temp audio was used, and what playback was
inspected. A still-board review cannot prove motion or sound; a silent animatic cannot prove
dialogue clarity or the final mix. Return inline unless files are requested or the project
already has an output convention; preserve supplied originals.

For an audit, each **Finding** gives **Impact** (High: protected reveal/action or hard
runtime/production limit fails; Medium: a local continuity, legibility, or timing break;
Low: local ambiguity), **Evidence** (supplied panel/shot ID and content, file:line with
snippet, or inspected media asset plus frame/timestamp and observation), **Risk**, and a
specific **Fix**. A **Pass** names panels, transitions, or intervals actually checked; a
**Skip** names missing material or capability. Do not infer an unseen reverse side, motion
between stills, audio from silent boards, or measured timing from a written estimate.
An intentional stylistic discontinuity is not a Finding without a demonstrated conflict.
