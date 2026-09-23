# Asset bible and state ledger

Read when characters, locations, costumes, or props recur. A useful bible distinguishes
identity from temporary scene state, and it tells another worker which source establishes
each trait.

## Canonical asset record

For each asset, capture:

| Field | Meaning |
|---|---|
| Stable ID and type | `CH01`, `LOC01`, `PR01`, or `COST01`; carry across script versions when identity is the same. |
| Story function | Why this asset matters and which scenes require it. |
| Invariants | Features that should not drift: silhouette, scale, markings, architecture, material, or mechanism. |
| Permitted variation | Lighting, aging, wet/dry state, removable layer, expression, damage progression, or costume change. |
| Reference map | Actual supplied or inspected image/text and exactly which trait it owns; mark proposed-only traits. |
| Views and mechanics | Front/side/back or interior needs, articulated parts, open/closed states, how a hero prop is handled. |
| Production requirements | Duplicates, breakaways, reset parts, unseen surfaces, or drawings/rigs needed for planned action. |
| Open verification | Measurements, construction, likeness, reverse view, or rendered match not yet established. |

A text description is a proposal until approved or evidenced. If two references disagree,
choose which controls silhouette, color, material, age, or geography. Do not merge them
silently or fabricate an image path to make the plan appear complete.

## State by scene and shot

Use `asset ID | scene/shot | entry state | change | exit state | next dependency`.
Examples: the same coat is dry in SC01, soaked in SC02, hung in SC03; a brass key moves
from Mara's right hand to Ivo's right hand; a door opens and remains open for the return
angle. Record the action that caused the change. A missing bridge is a continuity defect,
not a reason to quietly restage the next scene.

Separate story order from shoot or generation order. When SC04 is produced before SC02,
its entry state must be explicit. Prop duplicates may need to match a particular damage
stage. Costume continuity includes layers, closures, stains, and wear that remain visible.
Character knowledge is recorded when a design choice could reveal information too early.

## Handoff test

For a returning asset, another worker should be able to answer: what is it, where is it,
what does it look like from the needed view, what may change, what state is it in at the
start and end of this shot, and which actual reference supports that answer? If any answer
is missing, mark it open and state the work needed to resolve it. Reusable descriptions
reduce drift; they do not guarantee an image model or team will match them automatically.
