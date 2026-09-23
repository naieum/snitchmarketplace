---
name: snitch-animation
description: Write or revise animated narrative shorts that run 2–5 minutes, turning a premise into connected story beats, a timed script, and notes for storyboarding. Use for "write an animated short", "cartoon episode", "2–5 minute animation script", "fix this short's plot", or "but / therefore story beats". Supports comedy, silent stories, and other narrative tones. Do NOT use for detailed camera, lighting, staging, or shot coverage of a supplied story (use snitch-director), campaign strategy or UGC briefs (use snitch-cmo), persuasive page structure (use snitch-focusedcopy), technical prose (use snitch-docwriter), or rendering finished animation.
license: MIT with Commons Clause
metadata:
  author: Snitch
  version: 0.2.0
  homepage: https://snitchplugin.com
---

# Snitch: Animation

Need a 2–5 minute animated story that holds together? Turn the premise into a chain of
choices, complications, and consequences, then write the action and dialogue an animator
can stage. Every major story beat must follow from an earlier event or complicate an
established goal. A connector word alone does not prove the connection.

The core method comes from a short writers' room demonstration: outline on a board in
three acts, make each scene work as a small sketch, and connect the outline through
complication and consequence. The runtime estimates and animation guidance below are
adaptations for this skill, not claims made by that demonstration. Apply the method to
the user's tone; it does not require adult comedy, satire, or an existing show's style.

## Scope and starting point

- **Write:** premise or loose idea → beat outline → complete timed script.
- **Revise:** existing outline or script → locate broken connections → rewrite the requested
  scope, preserving the user's premise, tone, characters, and protected material.
- **Outline only:** stop at the beat outline when that is what the user asks for.
- **Audit only:** return evidenced Findings and suggested fixes; do not rewrite unless asked.

This skill writes narrative shorts. It does not render frames, generate voices, purchase
assets, or publish videos. Marketing strategy and UGC briefs belong to snitch-cmo;
persuasive page structure belongs to snitch-focusedcopy; technical prose belongs to
snitch-docwriter. If the requested work belongs there, call the Skill tool with the named
skill, one skill per call. If the host has no Skill tool, use its supported loading
mechanism without pretending a call occurred. A supplied brand brief can support an
animated story here; do not turn a bounded script request into a marketing project.

For detailed direction of a supplied story—camera, lighting, staging, and shot coverage—
call the Skill tool with "snitch-director". This skill still supplies basic storyboard notes
with its scripts. When both writing and directing are requested, finish the story first and
carry its beat IDs, timing assumptions, and protected decisions into that handoff.

Read any supplied premise, script, character bible, and production constraints first. Ask
only for missing choices that materially affect the story: audience, tone, premise, target
duration, dialogue language, or a hard cast/location limit. Bundle necessary questions.
Otherwise state reasonable assumptions and proceed: 3 minutes within the 2–5 minute range,
one central objective, a small cast, and reusable locations. These are adjustable defaults,
not restrictions. If the user requests a different duration, acknowledge the scope change
and adapt rather than silently forcing it into this range.

## Build the story before polishing the lines

1. **State the engine.** In one sentence: who wants what right now, what blocks them, and
   what tactic they try. Choose a visible result that will answer whether they get it.
   For comedy, identify the mismatch driving the laughs: a belief, desire, or tactic that
   predictably makes the situation worse. Preserve a supplied ending; work backward to
   earn it. Without a premise, choose and label one unless the user requested options.
2. **Lay out three movements.** Establish the want and first attempt; let the attempts
   produce escalating complications; resolve through a consequential choice and a payoff.
   Use this as a board layout, not a fixed act ratio, mandatory moral, or subplot quota.
   For 2–5 minutes, deepen one conflict before adding another plot.
3. **Write beat cards.** A beat is a meaningful change in the situation, not every shot,
   line, or gesture. Assign stable IDs such as B1, B2. Each card states the visible action,
   its result, and the connection from the prior beat. The opening establishes the situation
   and needs no incoming connector. Use the table below for subsequent beats.

   | Connection | What must actually be true | Repair when it is not |
   |---|---|---|
   | THEREFORE | A previous result causes, enables, or motivates this action; name the result and the character's reason to respond. | Add the missing motivation or mechanism, change the response, or cut the beat. |
   | BUT | Something blocks the current attempt, overturns an expectation, or changes the stakes; name the specific attempt or expectation. | Establish what is being opposed, make the obstacle relevant, or cut the interruption. |
   | AND THEN | Only time or location connects the events. | Treat as a diagnostic: join it causally, combine it with another beat, or remove it. |

   The labels describe relationships in the outline; do not insert them mechanically into
   dialogue. BUT and THEREFORE need not alternate. A new obstacle can come from outside the
   character's actions, but it must affect the established goal. An unrelated interruption
   is not a complication just because it follows the word BUT.
4. **Test each link.** Complete “Because B2 leaves ___, the character ___ in B3” or
   “B3 prevents ___ from B2 by ___.” If the explanation depends on a fact absent from the
   outline, establish it. Remove or swap a beat mentally: if later choices and results
   still work unchanged, inspect whether it belongs. This is a diagnostic, not a ban on
   reaction shots, atmosphere, travel, or purposeful comic pauses inside a beat.
5. **Give each scene a payoff.** In comedy, a scene should have its own setup, turn, and
   laugh or comic reversal while advancing the larger problem. A funny scene with no effect
   on the story needs integration or a cut; connective exposition needs an action or turn.
   For other tones, use a local reveal, tension shift, or emotional turn instead of forcing
   a joke. Escalation changes cost, knowledge, options, or commitment; merely getting louder
   or adding random spectacle does not do that.
6. **Earn the ending.** Pay off an earlier action, prop, rule, or choice. The ending can
   succeed, fail, or reverse the goal; it should answer the short's central question.
   Plant any needed capability before using it to resolve the conflict. An optional final
   gag grows from that outcome and does not erase it merely to reset the characters.

When the chain is difficult to diagnose, load
[references/causal-repair.md](references/causal-repair.md) for a worked original example
and repairs for superficially correct connector labels.

## Write for animation and elapsed time

- Write present-tense, observable action. Translate “feels rejected” into a gesture, pose,
  timing choice, or interaction. Stage the causal information so the audience can see it;
  narration should not have to rescue an invisible action.
- Use animation deliberately: a transformation, scale shift, expressive pose, visual
  metaphor, or impossible physical rule can drive the conflict. Establish rules before
  their payoff and keep them consistent. A quiet story need not add spectacle.
- Preserve prop state, geography, and who knows what across beats. A useful object cannot
  teleport into reach for the ending. Give fast actions enough staging and reaction time
  to read; avoid overlapping a critical visual revelation with unrelated dense dialogue.
- Respect the requested production limits. Reuse assets where it helps and flag a costly
  crowd, location change, effect, or transformation with a simpler staging alternative.
  Do not reduce a deliberately ambitious brief without explaining the trade-off.

Assign contiguous **estimated** time ranges to scenes or sequences; their durations must
sum to the target. Within them, account for spoken delivery, visible action, reactions,
pauses, transitions, and titles when included. A labeled 30-second scene is not credible
if its dialogue alone would take 50 seconds.

Use a rough spoken-word rate only as a starting assumption, such as 130–160 words per
minute for ordinary English dialogue. Adjust for language, character, delivery, and audience;
this is not a guaranteed rate or a whole-script word quota. Estimate sequential speech time
as `spoken words / assumed words per minute × 60`. Add action and holds that occur outside
speech; do not double-count action explicitly staged underneath it. Count only spoken
dialogue or narration for this calculation, not scene descriptions. Silent stories need
action and reaction estimates, not added narration to meet a word count.

If over time, cut duplicate exposition, merge attempts, or simplify staging while preserving
the causal chain and payoff. If under time, develop a consequential attempt or let a visual
turn breathe; do not pad with unrelated jokes. Recheck links after cutting. Timing remains
an estimate until a timed performance or animatic confirms it; say which verification, if
any, actually occurred.

If protected material and a fixed delivery rate cannot fit, show the duration conflict and
offer conditional cuts or a longer runtime. Ask which constraint may change; do not silently
alter protected material, speed up delivery, or relabel timestamps to claim it fits.

## Deliver the requested artifact

For a full script request, provide:

1. **Brief:** title, logline, audience/tone, target duration, and material assumptions.
2. **Beat outline:** `ID | estimated time | action → result | connection and why | payoff`.
   Related beats may share a scene, but each has an identifiable effect.
3. **Complete script:** numbered scenes with location and estimated time range, beat IDs,
   visible action, exact dialogue or narration, and story-relevant sound cues. Write the
   actual performance, not a summary of what characters would say. For silent work, state
   that it is silent and write the full action.
4. **Storyboard handoff:** cast, locations, important props and their changing states,
   animation rules, and any expensive staging with an alternative. Keep this proportional
   to the short; individual shot prompts are optional and only needed when requested.
5. **Verification note:** total estimated runtime and its assumptions, evidence of the key
   causal links and ending setup by beat/scene ID, and any unresolved production constraint.
   Distinguish a desk estimate from a timed read or animatic. Do not promise laughs,
   retention, virality, or a finished render.

Keep a narrow request narrow: an outline needs no full script, a single-scene revision
needs only that scene plus affected links, and an audit needs no unsolicited rewrite.
Return inline unless the user asks for files or the workspace supplies an output convention.
Do not overwrite a supplied original without authorization.

For an audit, each **Finding** carries **Impact** (High: the central conflict or resolution
breaks; Medium: a scene connection, turn, or timing breaks; Low: local clarity), **Evidence**
(actual `file:line` and snippet, or scene/beat ID and quoted text for pasted input), **Risk**
(what the viewer cannot follow or what cannot fit), and **Fix** (the specific causal or
staging change). A **Pass** names the links or scenes checked; a **Skip** says what material
is missing. Do not invent file citations or apply audit severity labels to ordinary creative
options in a new draft. Distinguish a craft preference from a broken stated constraint.
