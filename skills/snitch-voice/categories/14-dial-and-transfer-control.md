## CATEGORY 14: Outbound dial, transfer, forwarding and DTMF-send control
> Type: sink-pattern · Groups: quick, actions, abuse · Hop: H7 Call control · Standards: CWE-20, CWE-862

This is the category that empties accounts by the minute. A voice agent that can dial, transfer,
forward, or send keypad tones is holding the business's carrier account and caller ID, and the
model decides when to use them. If the destination can be named by the caller — spoken, typed on
the keypad, submitted in a web form that starts an outbound call, or planted in a record the agent
reads — the caller chooses where the business's money goes: a premium-rate number billed per
minute, an international destination, or a line the attacker controls that now receives calls
carrying the brand's number. The same tool driven into a downstream IVR by keypad tones can
navigate a bank menu. This category traces every dial, transfer, forward, and DTMF-send sink back
to where its destination and digits come from, and asks what outside the model constrains them.

**Call-path tracing required (anti-hallucination Rule 3).** Trace the destination number, the
caller ID, and any digit string from its source to the carrier call. A destination that is a
literal, or resolved server-side from a fixed table the model can only name a key into, is a Pass.
A destination that arrives as a free-string tool argument, a form field, a spoken number, or a
retrieved record value, and reaches the carrier call without an allowlist or a server-side lookup,
is a finding. A system-prompt sentence restricting transfers is never a control.

**Boundary.** This category owns where the call goes and what tones it sends. Whether a
consequential tool asks for confirmation before it fires is Cat 13; whether the tool webhook was
authorized for this caller is Cat 12; the spend ceiling that would bound the damage is Cat 19;
the platform's country permissions are a control this category reads but Cat 19 also cites; an
SMS or email sent from the call is Cat 15; a standalone click-to-call endpoint with no agent
behind it is snitch-security's Cat 19 (SMS) and Cat 30 (input validation).

### Detection
- Carrier dial and transfer APIs: Twilio `calls.create`, `<Dial>`, `<Number>`, `<Sip>`,
  `calls(sid).update({ twiml })`, `<Refer>`; Vonage `voice.createOutboundCall`, NCCO `connect`,
  `transfer`; Telnyx `calls.create`, `calls.transfer`, `calls.dial`; Plivo `calls.create`,
  `<Dial>`; SignalWire `calls.create`, `<Dial>`; Bandwidth `<Transfer>`; Asterisk / FreeSWITCH
  originate and bridge commands; SIP `REFER`
- Platform transfer and dial tools: Vapi `transferCall` / `type: "transferCall"` with
  `destinations[]`, `forwardingPhoneNumber`, `dtmf` tool; Retell `transfer_call` with
  `transfer_destination`, `press_digit`; Bland `transfer_phone_number`, `transfer_list`,
  `pathway` transfer nodes; ElevenLabs `transfer_to_number`, `transfer_to_agent`; LiveKit
  `TransferSIPParticipant` / `transfer_sip_participant`, `CreateSIPParticipant`; Pipecat
  `TwilioFrameSerializer` with dial-out, Daily `dialOut`; OpenAI Realtime SIP `refer`; Amazon
  Connect transfer-to-phone-number blocks
- Outbound-call starters: platform `POST /call` (Vapi `/call/phone`, Retell
  `/v2/create-phone-call`, Bland `/v1/calls`, ElevenLabs `/twilio/outbound-call`) invoked from
  application code with a `customer.number` / `to_number` / `phone_number` argument
- DTMF-send: `sendDigits`, `send_digits`, `SendDigits`, `press_digit`, `dtmf`, `<Play digits>`
- Function-tool definitions whose name or description says transfer, dial, call, forward, escalate,
  callback, or digits
- Caller-ID / `from` arguments: `callerId`, `from`, `From`, `phoneNumberId`, `outbound_number`

### What to Search For
- Free-string destination parameters on transfer and dial tools (`destination: string`,
  `phone_number: { type: "string" }`) with no `enum`, no server-side mapping, and no validation
- `transfer_destination`, `transferCall.destinations`, `transfer_phone_number` populated from
  conversation variables, dynamic variables, or `assistantOverrides`
- Outbound-call endpoints (`/call`, `/callback`, `/schedule-call`) where `to` comes from the
  request body with no ownership verification, no rate limit, and no country restriction
- Any dial sink whose destination is read from a CRM, calendar, ticket, or transcript field
- No E.164 normalization before the check, so `+1 900...` and `1900...` and `001900...` evade a
  prefix rule
- Country and prefix allowlists: their presence, the code that consults them at the sink, and
  whether the platform's geographic permissions are exported in the workspace
- Forwarding of the inbound call to a caller-supplied number ("call me back on this number")
- Caller ID set from a variable, allowing the agent to present a number it does not own
- DTMF-send arguments built from transcript text or tool arguments, especially on outbound calls
  that reach a third-party IVR
- Retry and callback loops: `retry`, `voicemail` handling, or scheduled redial with no attempt cap
  (the cap itself is Cat 18; here it is the destination that is re-dialed)
- Transfer to an agent or queue by name rather than number: a Pass when the name resolves
  server-side

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| unrestricted-destination | A model-chosen, caller-spoken, form-submitted, or retrieved destination reaches a dial, transfer, or forward sink with no allowlist, enum, or server-side lookup on the traced path | trace + the sink + the absent control | Critical |
| open-outbound-endpoint | An application endpoint starts an outbound call to a request-supplied number with no ownership verification and no rate limit | endpoint file:line + trace | Critical |
| allowlist-bypassable | An allowlist exists but the destination is not normalized to E.164 before the check, or the check is a substring/prefix match on an unnormalized string | the check file:line + the normalization gap | High |
| dtmf-from-untrusted | Digits sent to the carrier come from transcript text, tool arguments, or retrieved data with no digit-only validation and no length cap | trace + sink | High |
| caller-id-from-variable | The presented caller ID is set from a variable the model or caller can influence | trace + sink | High |
| geo-permissions-unbounded | Outbound dialing is enabled and no country restriction exists in code and no exported platform permission is in the workspace | the sink + the search + the Rule 6 skip line for the platform side | Medium (capped: platform-side unknown) |
| prompt-only-restriction | The only restriction on destinations is prose in the system prompt or tool description | the prompt file:line + the sink | reported with the unrestricted-destination row, not separately |

### Actually Vulnerable

#### Critical
- `<Dial>${args.destination}</Dial>`, `calls.create({ to: args.number })`, `transfer_call` with
  `transfer_destination` from a dynamic variable, `transferCall.destinations` built from
  `assistantOverrides`, an ElevenLabs `transfer_to_number` whose number parameter is LLM-filled
- An outbound `/call` route reading `to` from the body, reachable without authentication
- A dial destination read from a CRM or calendar field the caller or a third party can write

#### High
- An allowlist checked before normalization, or by `startsWith('+1')` on raw input
- `sendDigits` / `press_digit` driven by transcript or tool-argument text
- Caller ID from a variable
- Forwarding the inbound call to a caller-spoken callback number with no verification of
  number ownership

#### Medium
- Outbound dialing enabled with no country restriction visible anywhere in the workspace
- A fixed transfer table that includes an international or premium-prefix number with no
  documented reason (report as observation, Medium)

### NOT Vulnerable
- Destination is a literal or an environment variable the model never sees
- The tool schema exposes an `enum` of target keys and the handler resolves the key through a
  fixed table server-side; quote the schema and the table
- Transfer by named queue, agent, or SIP URI that resolves server-side
- A destination validated by E.164 normalization and then checked against an allowlist read
  from configuration, at the sink — quote the normalization, the allowlist, and the check
- Platform-side geographic permissions exported in the workspace and restricting outbound
  countries to the business's markets — Pass for the geo row; the destination row still needs
  its own control
- Outbound calls started only from an authenticated, rate-limited internal job to numbers that
  came from the business's own verified customer records (ownership established elsewhere,
  quote it)
- No dial, transfer, forward, or DTMF-send capability in the workspace at all — Skip, `not
  applicable`, with the search that established it

### Context Check
1. What can this agent do to a call: dial out, transfer, forward, send digits, none? Read the
   tool definitions and the carrier calls, not the prompt.
2. For each sink, where does the destination come from, hop by hop? Tool argument, dynamic
   variable, form field, retrieved record, literal?
3. What checks the destination outside the model, and where — at the sink, or somewhere the sink
   can be reached without passing it?
4. Is the input normalized before the check?
5. Where does the caller ID come from?
6. Is there a platform-side country restriction in the workspace? If not, that row Skips with
   the Rule 6 wording; do not assume either way.
7. For outbound-call starters, who can reach the endpoint and how often?

### Evidence Chain
- The sink file:line (the carrier call, the transfer tool config, the DTMF-send)
- The traced path of the destination or digits from source to sink, hop by hop with file:line
- Controls checked on that path and found absent or bypassable: allowlist, enum, server-side
  lookup, normalization, rate limit, ownership verification
- Source classification: literal / server-resolved / caller-influenced (spoken, keyed, form,
  retrieved, model-chosen)
- For the geo row: the platform export read, or the Rule 6 skip line

### Confidence Scoring
- **High**: complete trace from a caller-influenced source to the sink with no control on the
  path, or a literal/server-resolved destination confirmed for the Pass
- **Medium**: the destination flows through a helper or a platform-side mapping not fully
  visible in the workspace, or a control may exist platform-side without an export
- **Low**: the destination's source could not be traced → tag `needs human verification`

### Severity
Critical is any path by which an outside party chooses the destination of a billed call or a
forwarded line. High is a control that exists but can be stepped around, a caller ID the agent
does not own, or digits the agent sends on someone else's word. Medium is an unbounded geography
with no destination finding, and observations about the fixed table. Low is not used.

### Files to Check
- `**/tools/**`, `**/functions/**`, `**/transfer*`, `**/dial*`, `**/outbound*`, `**/call*`
- `**/twiml*`, `**/ncco*`, `**/*assistant*.json`, `**/*agent*.json`, `**/pathway*`
- `pages/api/call*`, `app/api/call*`, `**/routes/call*`, `**/callback*`, `**/schedule*`
- `config/**` (transfer tables, allowlists, country lists), `.env*`

### Reference
- CWE-20: Improper Input Validation
- CWE-862: Missing Authorization
- OWASP LLM Top 10 (2025): LLM06 Excessive Agency
- OWASP Agentic Top 10 (2025): ASI02 Tool Misuse and Exploitation
- Per-platform transfer, dial, DTMF and geo-permission knobs: `references/stacks/<platform>.md`
