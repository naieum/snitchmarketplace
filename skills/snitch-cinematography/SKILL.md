---
name: snitch-cinematography
description: Plan or audit the camera and lighting for a supplied film scene, script, storyboard, or shot sequence in live action or animation. Use for "how should we shoot this", "choose lenses and framing", "light this scene", "camera movement", "shot coverage", "DP plan", or "cinematography audit". Produces a reasoned shot and lighting plan independent of equipment brands or generation services. Do NOT use for directing the whole film across performance, design, sound, and edit (use snitch-director), building character/location/prop appearance and sets (use snitch-productiondesign), or writing an animated short from scratch (use snitch-animation).
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Cinematography

How should this scene be photographed or virtually framed and lit? Turn the story action and
spatial plan into camera and light decisions a crew, layout artist, or production workflow
can test. Every essential shot states what it lets the audience see, when they see it, and
why that viewpoint is useful. A style label or lens number alone does not answer the task.

Use the requested medium: live action, 2D/3D animation, stop motion, or mixed media. The
same composition principles apply, but physical optics and rigging are not meaningful in
every medium. Give qualitative instructions where exact equipment is unknown. This Skill
writes a plan; do not claim it has photographed, rendered, or measured the scene.

## Select the task

- **Plan:** supplied script/scene or director's staged scene → shot and light plan.
- **Focused advice:** answer the camera, lens, framing, movement, or lighting choice asked.
- **Audit:** inspect supplied shot plans, stills, or clips and report evidenced Findings.
- **Revision:** repair only the requested shots and their affected transitions; keep the
  user's protected story, staging, visual rules, and duration.

For an integrated directing request covering performance, scene design, edit, and sound,
call the Skill tool with "snitch-director". For a visual bible or set/character/prop design,
call the Skill tool with "snitch-productiondesign". For a 2–5 minute animated story from a
premise, call the Skill tool with "snitch-animation". If the host lacks a Skill tool, use its
supported loading mechanism and do not claim a call occurred. A bounded camera/light task
needs no preceding full director project.

Read the actual input before selecting gear or camera moves: story beat or action, audience
knowledge, location layout, actor/subject blocking, available references, medium, aspect
ratio, intended viewing surface, target duration, equipment and lighting constraints.
Preserve scene/shot IDs and version; otherwise assign stable `SC01-SH01` IDs. Label missing
geography or equipment as assumptions and propose a workable test. Do not turn the absence
of a camera specification into a request for a brand unless it materially changes the plan.

## Design the image

1. **Set the viewing question.** For each beat, identify the action, information to reveal
   or conceal, attention target, and response needed. Decide whether one held composition
   makes the change clearer than multiple angles. Give essential coverage before alternates.
2. **Place the camera in the scene.** Establish landmarks, performer paths, action axis,
   eyelines, entrances and exits, and potential camera access. Describe camera position in
   world terms, then screen effect. A reverse angle or axis crossing needs a readable
   orientation plan; intentional disorientation can be a reason if stated.
3. **Choose framing and optics.** Load
   [references/camera-and-optics.md](references/camera-and-optics.md) when shot size,
   viewpoint, focal length, focus, or movement needs detail. Distinguish a camera move from
   a change in focal length, subject motion, and focus. Specify start state, trigger, path,
   pace, and end state for a moving shot. Keep lens values conditional on camera format and
   tested geometry; do not imply that a lens changes perspective without moving viewpoint.
4. **Design the light.** Load
   [references/lighting-plan.md](references/lighting-plan.md). Place sources in the world,
   decide what must read and what may recede, and carry direction/quality consistently
   across angles. State which decisions are design intent and which require a location,
   camera, or rendering test. Color and contrast serve story information as well as mood.
5. **Check coverage and execution.** Load
   [references/shot-feasibility.md](references/shot-feasibility.md). Trace action and prop
   state across adjacent planned shots, provide editable starts/ends, and flag access,
   focus, exposure, set-extension, rig, or animation-layout needs. If a hard limit conflicts
   with a shot, propose a specific alternative preserving its information. Keep an
   ambitious user choice and name what must be solved to achieve it.

A shot plan is not automatically a production schedule. Distinguish selected screen time,
alternate coverage, source handles, setup time, and test needs. Do not add parallel action
or overlapping sound twice. If the supplied dialogue and action cannot fit the target, show
the conflict rather than changing protected material or disguising it with labels.

## Handoff and evidence

A full request returns a short look/lighting rule set, layout assumptions, an ordered shot
index, per-shot decisions, coverage/continuity notes, and a verification note. Each shot
card states `shot ID | beat/purpose | estimated duration | subject action | framing and
viewpoint | focus/optics if useful | camera state/path | light | entry/exit state | next cut or endpoint`.
Add a small overhead diagram when spatial prose is ambiguous. List optional shots separately
so they are not counted as story duration. A focused request gets only its relevant subset.
For a requested prompt, translate one shot into self-contained visual and motion directions;
do not invent upload IDs, model controls, or guarantees of visual consistency.

For an audit, each **Finding** has **Impact** (High for lost essential information or an
unachievable hard production limit; Medium for a local camera/light/continuity failure;
Low for a local ambiguity), **Evidence** (file:line plus snippet, scene/shot ID plus supplied
text, or inspected asset plus timestamp/frame and observable detail), **Risk**, and **Fix**.
A **Pass** names shots/transitions tested; a **Skip** names material or measurements absent.
A plan may be internally consistent without rendered shots proving focus, exposure, motion,
or visual match. Do not infer motion from a still, measured lux/stop values from prose, or
sound from silent footage. Distinguish a purposeful rule break from an accidental mismatch.

Return inline unless files are requested or the project already supplies an output home.
Do not overwrite source material without authorization. This Skill stops at written direction
or evidenced audit; camera operation, generation, rendering, and publication are separate
requested work.
