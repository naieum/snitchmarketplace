# Written direction packet and portable shot prompts

Read when delivering a plan. Scale the packet to the task: a camera question needs no full
packet, and a feature treatment need not invent every shot before the story is developed.

## Packet fields

| Artifact | Minimum useful content |
|---|---|
| Brief / treatment | Input version, scope, medium, audience, duration/ratio, constraints, point of view, visual rules and reasons, unresolved choices |
| Scene card | Scene/beat IDs, intention and turn, world/geography, blocking/performance cues, information held/revealed, entry/exit state |
| Shot card | ID and source beat, purpose, estimated duration, action/performance, framing/viewpoint, focus, camera start/path/end, light, audio cue, entry/exit state, cut to next shot, essential/optional |
| Asset records | Character/location/prop IDs, invariant descriptions, actual references and their roles, mutable state kept separately |
| Continuity ledger | Shot boundaries and state changes, axis/screen direction, dependencies and intentional exceptions |
| Edit / sound notes | Selected order, alternate coverage, rhythm and transitions, speech/ambience/effects/music intent, timing assumptions |
| Verification note | Scenes/shots covered, links checked, arithmetic, unverified media/feasibility, unresolved decisions, affected downstream work |

Do not force a huge horizontal table. Use a compact shot index and per-shot cards when the
fields would make it unreadable. For storyboards, add start/end panel descriptions, subject
and camera arrows labeled separately, and the action between panels. A shot can need several
panels; a panel is not automatically a new shot. For a drawn board or animatic request, give
this specification to an available production workflow and report what was actually created.

## Portable instruction structure

Only produce prompts when requested or useful for an explicitly requested production handoff.
Keep the richer directing record even when a particular consumer needs shorter input.

**Static frame:** subject identity and current state; location and spatial relationships;
framing/viewpoint; pose and visible action instant; light/palette/material treatment; important
invariants. A single frame cannot perform a sequence of actions.

**Motion:** starting state; primary action and performance cue; camera start, trigger, path
and end; action phases or timing where needed; final state; continuity constraints; audio
intent if supported. If a supplied image anchors the start, describe changes while retaining
critical invariants. Without a usable anchor, include enough scene context to stand alone.

Resolve asset IDs into canonical descriptions and actual available reference mappings for a
consumer that has no access to the ledger. “Same woman as before” is not a self-contained
instruction. Do not invent upload IDs, file paths, seed support, reference limits, duration
limits, resolution options, or negative-prompt fields. State constraints in ordinary language;
map them to platform-specific controls only in a separate, verified production workflow.

An impossible simultaneous move needs a decision, not more modifiers. Split multiple cuts
into explicit shots unless the consumer is known to support a sequence. A capability limit
should lead to a disclosed split or alternative, not a silent change to story timing. A
scene's final state should be suitable for its next planned shot; it is not a guarantee that
a generated clip will land there.

## Original example: concealment becomes a choice

Brief: a 20-second dialogue-free scene, live action or restrained 3D animation. A guest
notices a chipped cup, hides the damage from a host, then chooses to show it. One table,
two people, one cup. No new plot or dialogue is added.

Layout: guest west of table, host east; camera stays south of their east–west axis. North
window provides soft light. PR01 is a white cup with a chip on its rim. At entry it rests
near the guest with the chip facing south, visible to camera. Guest faces east (screen right
from the south master); host faces west (screen left).

| Shot | Selected duration | Purpose / action | Camera and sound |
|---|---|---|---|
| SC01-SH01 | 0–5s | Establish both people; guest glances down and notices the chip. | Still medium two-shot from south; cup visibly between them. Quiet room tone. |
| SC01-SH02 | 5–9s | Guest's right hand rotates the cup so the chip faces west, away from the host. | South-side rim detail; same cup position, hand enters from guest's side. Ceramic scrape motivates the cut. |
| SC01-SH03 | 9–14s | Guest checks the host's face, stops concealing, and looks back at the cup. | South-side close-up on guest, eyes toward screen right; soft north-window source retained. Let the decision register. |
| SC01-SH04 | 14–20s | Guest rotates chip east toward host and slides cup east. Host looks down and acknowledges it with a nod. | Return to matching two-shot; move and response both readable. Scrape then room tone; no imposed music. |

Continuity: SH02 exits with chip facing west and guest's hand beside cup; SH03 does not
change the cup; SH04 enters in that state, reveals it eastward, then transfers attention to
the host. There is no off-screen handoff or cup duplication. The 20 seconds are selected cut
time; any additional handles or alternative detail shots sit outside that total. Durations
are a paper estimate requiring rehearsal or animatic validation.

Portable motion instruction for SH02, without a supplied anchor: “A white chipped cup rests
on a wooden table near the seated guest on the west side. Close detail from south of the
table, chip initially facing camera. The guest's right hand enters from the west and turns
the cup until the chip faces west, away from the host seated to the east; the cup stays in
place. Camera remains still. Soft light comes from the north window. Hold the final rim
orientation briefly; quiet ceramic scrape.”

The consumer still needs character/location references if appearance must match other shots.
This example specifies intention and state; it does not assert that a clip has been rendered.
