---
name: snitch-sound
description: Plan or audit the sound of a supplied film scene or sequence for animation or live action, including dialogue, ambience, effects, music, silence, perspective, and cue timing. Use for "sound design", "spotting", "audio cue sheet", "what should we hear", "dialogue intelligibility", or "sound audit". Produces a written sound plan independent of recording or mixing software. Do NOT use for writing the story or dialogue (use snitch-screenwriter), choosing the picture edit and coverage (use snitch-editor), or integrating every department into one direction plan (use snitch-director).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Sound

What should the audience hear, and when? Turn a supplied scene, script, board, or cut into a
sound plan whose cues carry action, place, and point of view. Sound may reveal an off-screen
event, connect shots, change the apparent space, or leave a deliberate gap. A list of moods
or a music bed across every second is not a usable sound plan.

Work across live action, animation, stop motion, and mixed media. The output is a cue sheet,
recording/design brief, or evidenced audit, not a claim that audio has been recorded, licensed,
edited, mixed, or heard when only text was supplied. A sound-only request needs no full film
plan first.

## Select the task

- **Spotting and cue plan:** map supplied beats or picture to dialogue, ambience, effects,
  music, and purposeful silence.
- **Focused brief:** specify one sound, acoustic place, transition, or recording need.
- **Audit:** inspect a supplied cue sheet or playable audio against story and continuity.
- **Revision:** change only requested cues and affected transitions; preserve protected
  dialogue, picture, duration, and chosen absence of music or speech.

For story or dialogue writing, call the Skill tool with "snitch-screenwriter". For picture
assembly, cut order, or pickups, call the Skill tool with "snitch-editor". For an integrated
film plan, call the Skill tool with "snitch-director". If the host lacks a Skill tool, use
its supported loading mechanism and do not claim a call occurred. Sound can propose a
picture change, but the editor or director must resolve it.

Read the supplied script/cut version, scene and shot IDs, medium, duration, audience point
of view, locked dialogue and cues, existing recordings or licensed music, and any picture
timing. Distinguish source facts from proposed sounds. If there is no timed cut, label all
cue positions and durations estimates. Do not fabricate an audio file, waveform, license,
microphone, channel format, loudness measurement, or listening result.

## Design the listening sequence

1. **Spot the story events.** Mark what must be heard for an action to read, what may be
   learned before or after the image, and whose listening position anchors the moment.
   Separate sounds within the story world from score. Decide where withholding sound is
   intentional.
2. **Build the sound world.** Give each location a stable ambience and acoustic character;
   carry these through shots unless the listener, space, or time changes. Place off-screen
   sources in world space first, then translate to an appropriate presentation. For detail,
   load [references/spotting-and-cues.md](references/spotting-and-cues.md).
3. **Prioritize information.** Protected dialogue and essential action cues need a clear
   place in the mix. Indicate when music or ambience should yield, pause, or return. A
   quieter cue is not automatically less important, and silence need not mean digital zero.
   Load [references/audibility-and-delivery.md](references/audibility-and-delivery.md) when
   intelligibility, source quality, or delivery is part of the request.
4. **Write temporal relationships.** Attach each cue to a beat, visible action, shot ID,
   or inspected timecode. State onset, end or decay, perspective, overlap, and whether it
   starts before a picture cut or continues across one. Count elapsed timeline time once:
   overlapping sound does not lengthen the film. Separate proposed cue duration from
   source-recording length and editorial handles.
5. **Check feasibility and continuity.** Trace recurring source position, room tone,
   acoustic distance, cut bridges, and prop-sound sync. List needed recordings, designed
   effects, performances, and music/rights questions without assuming they exist. If
   supplied constraints conflict, name the conflict and offer a specific alternative.

## Handoff and evidence

A full plan gives a short listening rule set, an ordered cue sheet, source/recording needs,
transition notes, and tests still required. A cue row states `cue ID | scene/shot or time
range | source and category | story purpose | onset/decay/overlap | world position and
perspective | priority against other sounds | source status`. Use stable IDs such as
`SC01-SND01`. For a focused request, return only the useful subset. Do not prescribe exact
mix values or delivery specifications without an actual target and measurements.

For an audit, each **Finding** includes **Impact** (High for lost protected dialogue,
essential event, or hard sound constraint; Medium for a local perspective, timing, or
continuity failure; Low for ambiguity), **Evidence** (source file:line and snippet,
supplied cue/shot ID and text, or inspected audio asset plus timestamp and what is
audible), **Risk**, and **Fix**. A **Pass** says what was actually checked; a **Skip** names
the absent audio, cut, measurement, or rights information. A cue sheet can be internally
consistent without proving the final mix is intelligible. Never report that a sound is
audible from a silent board or unplayed file.

Return inline unless files are requested or the project supplies an output home. Preserve
source material when revising. This Skill stops at written sound direction or an evidenced
audit; recording, generation, licensing, mixing, and publication are separate workflows.
