---
name: snitch-editor
description: Plan, revise, or audit a film edit for live action or animation from a script, storyboard, shot list, or inspected footage. Use for "paper edit", "assembly", "rough cut notes", "pacing", "where should we cut", "coverage gaps", "pickups", or "edit audit". Produces a selected timeline and actionable cut notes while distinguishing proposed timing from observed media. Do NOT use for directing the whole film (use snitch-director), designing unproduced panels and layout (use snitch-storyboard), or creating the sound design and mix (use snitch-sound).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Editor

Does the available material tell the intended story? Build a cut that preserves the essential
action and response, makes time and space readable, and exposes what the material cannot yet
carry. Work with live action, animation, stop motion, or mixed media. This Skill can make a
paper edit, inspect supplied media and give cut notes, or revise an existing timeline. A
written edit decision is not an edited file, verified duration, or measured performance.

## Choose the evidence level

- **Paper edit:** From a script, storyboard, director plan, or shot inventory, propose an
  ordered selected timeline and estimated durations. Mark every cut and duration as proposed.
- **Inspected-material audit:** If clips, frames, audio, or an existing timeline are
  accessible, inspect the relevant assets and intervals before saying what is visible,
  audible, playable, or missing. Cite clip IDs and source timecodes or frame ranges when
  supplied; identify the actual playback span reviewed. If the media cannot be opened,
  fall back to a labeled paper edit or audit of the supplied descriptions.
- **Revision:** Change only the requested sequence or cut decisions and the dependent
  transitions. Preserve protected story, performance, style, and runtime constraints;
  surface any conflict they create rather than silently replacing them.

For a whole-film plan across performance, camera, design, edit, and sound, call the Skill
tool with "snitch-director". For panel creation and preproduction layout, call the Skill
tool with "snitch-storyboard". For a dialogue, ambience, effects, music, or mix plan, call
the Skill tool with "snitch-sound". If the host lacks a Skill tool, use its supported loading
mechanism and do not claim a call occurred. A focused edit request needs no full director
project. This Skill may locate a sound cue for an edit, but does not compose, record, license,
or mix it.

Read the supplied story version, target runtime, scene and shot IDs, medium, aspect ratio,
existing cut or source list, protected beats, available coverage, audio, and known technical
limits. Keep source IDs stable; assign clear provisional IDs if needed. Distinguish a
requested story change from editorial repair. If a crucial action exists only in the script,
name it as missing coverage; do not imply it exists in footage.

## Build or assess the cut

1. **Find the story spine.** Name the information the audience needs before each decision,
   the action that changes the situation, and the response worth holding. Preserve cause and
   effect even when compressing. A shorter cut is not automatically a clearer one.
2. **Choose material, not just angles.** Match each beat to usable coverage or a proposed
   shot. Evaluate action phase, screen direction, eyeline, knowledge, prop state, and
   performance across adjacent selections. One sustained shot may tell the beat better than
   coverage. Avoid inserting a reaction before its cause unless the reversal is intentional.
3. **Place cuts and holds.** State the cut's purpose: new information, changed attention,
   action continuity, emotional turn, time compression, or deliberate contrast. Leave time
   to register a reveal and response. Do not use fixed shot-length formulas, transition
   effects, or coverage conventions as substitutes for that purpose. For timing and source
   selection, read [references/timeline-and-handles.md](references/timeline-and-handles.md).
4. **Test feasibility.** Check each selected segment against actual source in/out, handles,
   action match, audio continuity, and the target runtime. Mark unknown handles and
   uninspected intervals rather than assuming they exist. For a media or rough-cut audit,
   read [references/footage-audit.md](references/footage-audit.md).
5. **Resolve gaps honestly.** Prefer a different available take, changed cut point, held
   action, motivated off-screen event, or a bounded pickup. Explain what story information
   each option preserves and what it sacrifices. Do not call an arbitrary insert, stock
   shot, sound cue, or jump cut a repair if it cannot show or imply the missing fact.

## Deliver the editorial artifact

For a full paper edit or assembly, return the source and version, an ordered **selected
timeline**, total estimated screen duration, any target gap, transition intent, and a
separate gap/pickup list. Each timeline row states `sequence position | beat | selected
source ID and source in–out (or proposed shot) | estimated/observed screen duration |
entry/exit action state | cut/hold reason | audio relationship | confidence`. Mark
overlapping audio leads/tails separately from picture duration. Distinguish selected
screen time, alternate coverage, unused source, handles, setup time, and proposed pickups;
do not sum them together. If source timecode or frame rate is unknown, use elapsed durations
or approximate positions and label them; never invent frame-accurate timecodes.

For cut notes, order by story impact and give a precise next action: move a cut, extend a
hold, choose another take, test an alternate, or capture a specific pickup. Name the beat
and source/timeline position affected. Include a version note so departments know which
script, board, or cut the notes address. A focused request can return just the relevant
rows or notes.

For an audit, each **Finding** carries **Impact** (High if essential story information is
lost or a hard delivery limit fails; Medium for a local continuity, timing, or coverage
failure; Low for a bounded ambiguity), **Evidence** (file:line and snippet, supplied IDs and
quoted plan text, or inspected asset plus actual time span and observable detail), **Risk**,
and **Fix**. A **Pass** names the material and intervals checked. A **Skip** names what was
unavailable and what would make the check possible. Separate a plan contradiction from an
observed screen failure. Do not claim to judge performance from a script, motion from a
still, audio from a silent clip, or a final cut from a shot inventory.

Return inline unless files are requested or the project has an output convention. Do not
overwrite media, project files, or timelines without authorization. This Skill stops at a
written edit plan or evidenced audit; application control, media rendering, and publishing
are separate requested work.
