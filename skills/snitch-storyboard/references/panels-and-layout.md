# Panels and spatial layout

Read for a handoff to artists, for moving action, or when geography is uncertain. The job
is to show **one visible instant per panel** and describe the interval between panels. It
is not a demand for one drawing per second or one drawing per shot.

## Orient the reader

Use a small overhead diagram or prose map with fixed landmarks: north or another world
reference, doors, windows, obstacles, participants, prop resting places, and action paths.
Show the action axis between interacting participants or along dominant travel. Record
which side of that axis each selected view occupies. Board framing in the requested aspect
ratio. Leave safe room for important action and text only when the intended display or
delivery actually needs it.

Do not silently move a door, mirror, window, table, or actor to make a reverse angle work.
When the location is unknown, label the diagram provisional and name the location or set
test that must confirm clearance and sightlines. Live-action boards should acknowledge
performer/camera access and practical resets; animation boards should specify layers,
depth, perspective rules, or rig/extreme-pose needs only where these constrain the action.
Do not invent physical lens specifications for flat 2D layout.

## Panel notation

- Keep `scene-shot-panel` IDs stable through revisions. The panel inherits the shot's
  camera setup unless a visible movement changes it.
- Name frame boundaries and view (wide/medium/detail, height, side, and attention target).
  A lens value is optional and belongs to a camera plan when format and geometry are known.
- Describe the **visible pose/state at that instant**: which hand holds the prop, where a
  gaze points, which object is readable, what remains hidden.
- Label subject arrows `S:` and camera arrows `C:` with world-space start and end
  points. Add a timing or cue for a move, not merely an arrow through the frame. No arrow
  means stillness only if that is the intended action.
- Between successive panels of one shot, state what occurs between the poses. If a hand
  travels behind an actor, a prop changes holder, or a camera crosses the axis, the interval
  is where that must be visible or explicitly omitted.
- Mark holds and reactions as positive choices. A panel of a face is useful when the
  expression or knowledge changes; a repeated neutral close-up is not coverage by itself.

Choose panels for entry pose, anticipation, decisive action, effect/reveal, and response
where each helps the viewer read the sequence. Compress obvious continuous movement;
expand a fast, confusing action into more key poses. For image creation or an unrendered
fallback, write one self-contained visible instant per panel and keep recurring traits
from the supplied asset record. The prompt is an instruction, not evidence that the image
exists.

## Original example: one shot, three panels

A runner enters frame left, stops at a locked gate, then spots a latch above reach.
Keep the same wide camera on the south side of the east–west path:

| Panel | Visible instant | Between panels |
|---|---|---|
| SC01-SH01-P01 | Runner entering from screen left; gate at right; latch above gate visible but not emphasized | Subject travels east, camera still. |
| SC01-SH01-P02 | Runner stopped, palm on gate; the gate does not open | Gate rattles; runner's gaze rises. |
| SC01-SH01-P03 | Runner looking up toward latch, hand leaving gate | Hold enough for the new option to register before the next shot or endpoint. |

These are three panels inside one continuous shot, not three cuts or three copies of the
shot's duration. The latch's position is a supplied or proposed design fact; whether the
camera can see it at the chosen width needs a framing test.
