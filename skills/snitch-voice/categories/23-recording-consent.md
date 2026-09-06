## CATEGORY 23: Recording announcement and consent capture
> Type: compliance · Groups: privacy · Hop: H9 Storage and telemetry · Standards: US state wiretap statutes; GDPR Art. 6, 13

A voice agent that records is a party recording a phone call, and the law that governs that is
not the law of where the business sits but the law of where the caller is. Roughly a dozen US
states require every party's consent or knowledge for a telephone recording; the federal baseline
and the rest require one party's; the EU requires a lawful basis and information at the moment
the data are collected. The workable shape, whatever the jurisdiction, is the same: the agent says
it is recording **before** the recording starts, in words the caller can act on, and the code
enforces that order. This category reads where recording is turned on, what the first message
says, whether the announcement can be skipped or overridden, and what the flow does when a caller
declines. It produces an exposure read, never a verdict.

**Boundary.** This category judges the announcement and the consent capture. What is captured
after the announcement and whether sensitive content is stripped is Cat 22; where the recording
lands, who can reach it, and how long it stays is Cat 21; whether a Decision in `BLUEPRINT.md`
scopes recording out is STEP 0.5 of SKILL.md. The AI-disclosure sentence that often shares the
first message is Cat 24's judge; a first message that discloses AI but not recording is a finding
here and a Pass there. Which sector regime attaches to the recorded content (card data, health
data, a voiceprint) is Cat 25.

**Pre-flight.** This category consumes two inputs and never infers either. From the STEP 0
inventory: whether recording is on (a carrier `Record` flag, a `<Record>` verb, a platform
`recordingEnabled` or `record` field, an egress or transcript-persistence call). From the STEP 0.4
discovery block: the jurisdictions of callers. Two branches. **Inputs answered:** resolve the
jurisdictions against `references/legal-landscape.md` section 3, then read the announcement and
the start order against the strictest regime in scope; a national US inbound line is treated as
reaching every state in the table. **Inputs not answered:** run the announcement and start-order
checks anyway — they need no jurisdiction — and write the exposure rows generically, listing the
regimes without attaching any to this agent, with the line `Exposure could not be scoped — the
discovery questions were not answered`. Recording absent from the inventory is `Skip — not
applicable: no recording flag or API call in the workspace`, with the search that established it;
a hosted platform whose recording default lives only in its dashboard is a Rule 6 Skip naming the
export.

**Forbidden claims.** Never write "compliant", "non-compliant", "legal", "illegal", "violates" or
"lawful" as a verdict on the agent; write "records before the announcement at `file:line`, which
the all-party regimes in scope are judged on". Never predict a suit, a penalty, or a regulator's
view, and never state a monetary figure. Never decide which states a business "reaches" — the
discovery answer decides, or the national-line rule does. Every regime line in a finding carries
the `Facts verified: 2026-09-06 against <URL>` line copied from `references/legal-landscape.md`;
a fact that reference marks unverified is written with its hedge. Never assert a state's rule from
memory: if a state is not in the table, it is `(unverified — confirm at the state legislature's
site)`.

### Detection
- Recording switches: Twilio `Record: true` / `record=true` on `calls.create`, `<Record>`,
  `<Dial record=`, `RecordingStatusCallback`; Vonage NCCO `record` action; Telnyx
  `record_start`, `record: "record-from-answer"`; Plivo `<Record>`, `record: true`; Vapi
  `artifactPlan.recordingEnabled`, `recordingEnabled`; Retell agent recording (on by default with
  a `recording_url` in the call object); Bland `record`; ElevenLabs agent privacy settings;
  LiveKit `EgressClient`, `RoomCompositeEgressRequest`; Pipecat `AudioBufferProcessor` /
  transcript persistence; Amazon Connect "Set recording and analytics behavior" blocks
- First-message and greeting keys: `firstMessage`, `firstMessageMode`, `welcomeGreeting`,
  `begin_message`, `first_sentence`, `greeting`, `agent.greeting`, `instructions`,
  `system_prompt`, `general_prompt`, `<Say>` before `<Record>` or `<Connect>`
- Consent capture: tools or handlers named `consent`, `recordingConsent`, `optOut`,
  `declineRecording`; `<Gather>` prompts about recording; a state flag that gates recording start
- Override surfaces: `assistantOverrides.firstMessage`, `variableValues` used inside the
  greeting, `conversation_config_override`, client-side `session.update` on `instructions`

### What to Search For
- Recording enabled and no recording announcement anywhere in the first message, greeting,
  prompt, or a `<Say>` that precedes the recording start
- The recording started before the announcement is played: `Record: true` on the inbound call
  resource (recording from answer) while the announcement lives in a later prompt; `<Record>` or
  `<Connect><Stream>` with recording before any `<Say>`; a platform default that records from
  answer with the announcement only in `instructions` the model may or may not say
- An announcement that exists only as a prompt instruction ("tell the caller the call is
  recorded") rather than a fixed first message — the model decides whether it is said
- An announcement the client can remove: `firstMessage` overridable from the browser or from a
  request body; `welcomeGreeting` built from a variable
- No opt-out path: the announcement is a statement with no branch for a caller who declines, or
  the decline branch keeps recording
- Announcement wording that does not say recording is happening ("this call may be monitored for
  quality") where an all-party regime is in scope
- EU callers in scope and no Article 13 information point (purpose, controller, retention) on
  the call or in a referenced notice
- Outbound campaigns: the recording announcement is in the inbound greeting but the outbound
  `first_sentence` / `task` has none
- Transcription-only setups that never store audio but persist a full transcript: still a
  recording for consent purposes in most all-party regimes `(unverified — confirm per state)`;
  report as Medium with the hedge

### Rule table
| Row | Regime cited | Fails when | Evidence | Severity |
|---|---|---|---|---|
| no-announcement | the all-party states in scope (legal-landscape §3 table); GDPR Art. 13 where EU callers are in scope | Recording is on and no recording announcement exists in any fixed first-message key or preceding `<Say>` | the recording switch file:line + the search over every greeting key with its count | High when an all-party or EU jurisdiction is in scope; Medium when jurisdictions are unanswered |
| records-before-announcing | same | Recording starts on answer or on connect, and the announcement is played later or only by the model | the recording start file:line + the announcement location file:line | High / Medium as above |
| announcement-model-optional | same | The only announcement is a prompt instruction the model may skip, not a fixed first message | the prompt file:line + the absent fixed key | High / Medium |
| announcement-overridable | same | A fixed announcement can be replaced by a client override or a request-body variable | the override path file:line (see Cat 11 for the mechanism) | High / Medium |
| no-decline-path | Washington-style announce-as-consent regimes accept the announcement; regimes requiring consent need a way to withhold it | No branch for a caller who declines, or the decline branch does not stop recording | the flow file:line + the search for a decline handler | Medium |
| wording-not-recording | Massachusetts-style secrecy tests and Montana-style knowledge tests turn on whether the caller knows recording is happening | The announcement does not state that the call is recorded | the announcement text file:line | Medium |
| outbound-unannounced | same regimes; PECR reg. 19 where UK numbers are dialed | Outbound first sentence or task carries no recording announcement while recording is on | the outbound call params file:line | High / Medium |
| eu-information-absent | GDPR Art. 13 | EU callers in scope and no purpose/controller/retention information is given or referenced | the greeting + the search for a notice reference | Medium |
| upcoming-or-unlisted-state | — | A state named in discovery is not in the table | `(unverified — confirm at the state legislature's site)` | Low, informational |

### Actually Vulnerable

Critical is never used in this category: the recording itself is not the harm, the missing
consent is, and its weight depends on inputs the audit does not decide.

#### High
- Recording on, national US inbound line, no announcement in any fixed greeting key
- Recording from answer with the announcement in a later prompt, for a line that reaches an
  all-party state
- Announcement present but only as an `instructions` sentence the model may omit
- Announcement replaceable from the client via `assistantOverrides` or a request variable
- Outbound recording with no announcement in `first_sentence` / `task` / `firstMessage`

#### Medium
- The same shapes where the discovery jurisdictions were not answered
- Announcement says "monitored" or "quality purposes" but not "recorded"
- No decline path, or decline keeps recording
- EU callers in scope with no Article 13 information point
- Transcript-only persistence with no announcement, with the per-state hedge

### NOT Vulnerable
- A fixed first message (not an override-able one) that states the call is recorded, played by a
  `<Say>` or a platform first-message key **before** the recording starts; quote the order — Pass
- Recording started only after a consent tool or DTMF gather returns affirmative, with the
  decline branch ending or continuing unrecorded; quote both branches — Pass
- Recording off everywhere in the workspace and no platform default that records — Skip, `not
  applicable`, with the search
- A carrier-side or platform-side announcement configured in an export present in the workspace
  (an IVR that plays the notice before handoff) — Pass quoting the export
- A `BLUEPRINT.md` Decision that recording is off at launch, with the code matching — Skip citing
  the line; if the code records anyway, the Decision does not waive the finding
- Oregon-only or other one-party-only caller populations with a one-party-consistent flow —
  Pass for the announcement row, noting the discovery answer that scopes it

### Context Check
1. Is recording on, and where is it turned on? Read the switch, not the README.
2. What is the first thing the caller hears, and is it fixed or model-generated?
3. What order do recording start and announcement happen in, in code?
4. Can anything outside the server change the announcement?
5. What happens if the caller says no?
6. Which jurisdictions did discovery name, and which regime in the table is the strictest among
   them? A national line is every row.
7. For outbound calls, is the announcement in the outbound first sentence?

### Evidence Chain
- The recording switch file:line (or the platform default with the Rule 6 caveat)
- The announcement text and its file:line, or the search over every greeting key that returned
  nothing, with pattern and scope
- The start-order evidence: the recording start file:line beside the announcement file:line
- The override surface file:line, where one exists
- The decline handler file:line, or the search that established its absence
- The regime line(s) with `Facts verified: 2026-09-06 against <URL>` copied from
  `references/legal-landscape.md`, and the discovery answer that put them in scope

### Confidence Scoring
- **High**: the recording switch and the greeting are both in the workspace, the order is
  readable in code, and discovery named the jurisdictions
- **Medium**: the recording default or the greeting is platform-side without an export, or
  discovery left jurisdictions unanswered
- **Low**: the recording path could not be resolved (dynamic TwiML, remote NCCO) → tag `needs
  human verification`

### Severity
High is reserved for a recording with no effective announcement where an all-party or EU regime
is in scope by the inputs. Medium covers the same shapes with unanswered inputs, wording and
decline-path gaps, and the transcript-only hedge. Low is the informational unlisted-state row.
Critical is never used here.

### Files to Check
- `**/twiml*`, `**/ncco*`, `**/voice*`, `**/incoming*`, `**/outbound*`, `**/call*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/pathway*`, `**/config/**`
- `**/prompts/**`, `**/*prompt*`, `**/*greeting*`, `**/*first-message*`
- `**/consent*`, `**/privacy*`, `**/notice*`, `docs/**` (a referenced privacy notice)

### Reference
- `references/legal-landscape.md` section 3: federal baseline, the all-party table with per-state
  nuance, CCPA voice definitions; section 4: GDPR Articles 6, 9, 13
- Cat 21 (storage and access), Cat 22 (redaction), Cat 24 (the AI-disclosure half of the first
  message), Cat 25 (the sector regime attached to the recorded content)
