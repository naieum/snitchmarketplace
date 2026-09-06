## CATEGORY 22: Card, health, identity and voiceprint data in transcripts, logs and prompts
> Type: posture · Groups: privacy · Hop: H9 Storage and telemetry · Standards: CWE-312, CWE-359; PCI DSS 4.0

Callers say things to a phone agent that they would never type into a form: a full card number
with the security code, a date of birth and the last four of a national ID, a diagnosis, a
prescription, a child's name. Every one of those words passes through the transcriber, lands in
the model's context, is echoed in the tool arguments, and is written to whatever Cat 21 found.
The voice itself is a biometric once anyone uses it to identify the caller. A voice agent that
takes a payment by reading digits back into the transcript has just stored a card number and its
security code in a place no card-data standard permits. This category reads what sensitive data
the flow expects, where it is captured, and what strips it before it lands — and what does not.

**Boundary.** This category judges whether sensitive content is redacted or diverted before it
is stored, logged, or sent to a provider. Where the artifacts land and who can reach them is Cat
21. Whether the caller consented to recording at all is Cat 23. Which regime attaches — the card
standard's retention rules, the health rules' business-associate requirement, a biometric
statute's consent requirement — is Cat 25's judge; this category reports the flow, Cat 25 reports
the exposure. Whether the caller was verified before their data was read back is Cat 06. Generic
PII-in-logs off the call path is snitch-security's business — hand off by calling the Skill tool
with "snitch-security".

### Detection
- Payment or identity capture on the call path: tools or prompt sections named `payment`,
  `card`, `pay`, `charge`, `collect_card`, `ssn`, `dob`, `verify_identity`, `insurance`,
  `member_id`, `diagnosis`, `prescription`; `<Gather>` or DTMF capture of digit strings
- Transcription redaction options: Deepgram `redact` (`pci`, `pii`, `numbers`), AssemblyAI
  `redact_pii` / `redact_pii_policies`, Azure Speech PII detection, Amazon Transcribe
  `ContentRedaction`, Contact Lens redaction `RedactedParticipants`; Retell `pii_config`,
  `data_storage_setting: everything_except_pii`, `opt_out_sensitive_data_storage`; Vapi
  `hipaaEnabled`, `compliancePlan`
- Carrier payment and masking features: Twilio `<Pay>`, Pay Connectors, DTMF masking,
  `<Record>` pause/resume via call update; Amazon Connect encrypted `Store customer input`, "Set
  logging behavior" blocks; Vonage / Telnyx recording pause and resume
- Twilio ConversationRelay fields the provider documents as not for card data: `<Parameter>`,
  `handoffData`, `welcomeGreeting`, `hints`
- Voiceprint or speaker-verification SDKs and APIs: `speaker_id`, `voiceprint`, `enroll`,
  `verify_speaker`, `biometric`
- Prompt and message construction that interpolates caller fields: `{{customer.*}}`,
  `variableValues`, `dynamic_variables`, `metadata`

### What to Search For
- A payment step whose digits are spoken and transcribed, with no transcription redaction, no
  DTMF masking, no recording pause, and no handoff to a payment connector — the number and its
  security code land in the transcript
- Transcription redaction available for the configured provider but not enabled, on a flow that
  expects card, identity, or health data
- Recording pause and resume attempted by code that can fail open (the pause call errors and the
  flow proceeds to collect the card)
- Card or identity data placed in ConversationRelay `<Parameter>` values, `handoffData`, or the
  greeting; the provider's own documentation excludes those from card-data scope
- Sensitive fields interpolated into the system prompt or dynamic variables so they are re-sent
  on every turn and retained with the call
- Tool arguments carrying full card numbers, security codes, national IDs, or health detail,
  logged by the tool dispatcher
- The model asked to read back a full card number, ID, or balance to the caller
- Voiceprints enrolled or compared with no retention, deletion, or consent gate visible (the
  statute is Cat 25; the missing gate is here)
- Caller PII sent to a model provider with no data-processing agreement, business-associate
  agreement, or zero-retention setting in the workspace — the flow is a Finding, the agreement's
  existence is a Skip naming the document that would unblock it
- Platform storage settings that keep everything, on a flow that expects sensitive data:
  `data_storage_setting: everything` (the documented default `(unverified — confirm in the
  platform docs)`), `hipaaEnabled` absent on a health flow

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| card-data-in-transcript | A payment step captures the number or security code by speech or DTMF with no redaction, masking, pause, or connector handoff | the capture file:line + the absent control | Critical |
| card-data-in-unscoped-field | Card data placed in a parameter, handoff payload, greeting, or hint the provider documents as outside card-data scope | the field file:line | Critical |
| pause-fails-open | A recording pause is attempted but its failure does not stop the collection | the pause call and the following flow file:line | High |
| redaction-available-unused | The transcription or platform provider offers redaction and the flow that expects sensitive data does not enable it | the provider config file:line + the search | High on card or health flows; Medium elsewhere |
| sensitive-in-prompt | Identity, health, or financial fields are interpolated into the system prompt or dynamic variables | the prompt or variable construction file:line | High |
| sensitive-in-tool-log | Tool arguments carrying sensitive fields are logged | the log call file:line | High |
| read-back-full-value | The model is instructed or permitted to speak a full card number, national ID, or account balance | the prompt or tool result file:line | Medium |
| voiceprint-no-lifecycle | Voiceprints are enrolled or compared with no retention, deletion, or consent gate | the enrollment file:line + the search | High |
| pii-to-provider-no-agreement | Caller PII reaches a model or transcription provider and no agreement, zero-retention, or redaction setting is in the workspace | the flow file:line + the Skip for the agreement | Medium (flow); agreement row Skips |

### Actually Vulnerable

#### Critical
- Prompt: "ask for the sixteen-digit number and the three-digit code on the back" on a flow with
  no `<Pay>`, no DTMF masking, no `redact: pci`, no pause
- `<Parameter name="card" value="{{card_number}}">` or `handoffData: { cardNumber }`

#### High
- `await pauseRecording(callSid).catch(() => {})` followed by the collection step
- Deepgram client built without `redact` on a health-intake agent; AssemblyAI stream without
  `redact_pii` on an identity-verification agent
- `variableValues: { ssn: caller.ssn, diagnosis }` or `{{customer.dob}}` in the system prompt
- `logger.info('tool call', { name, args })` where `args` includes card or health fields
- Speaker enrollment with no deletion path anywhere in the workspace

#### Medium
- Model told to confirm the full account number aloud; PII sent to a model provider with no
  agreement or zero-retention setting visible; `data_storage_setting` left at everything on a
  sensitive flow

### NOT Vulnerable
- Payment handed to a carrier pay connector or a payment provider's IVR, so the digits never
  reach the transcriber — quote the handoff
- DTMF masking or transcription redaction enabled for the provider in use, with the config
  quoted, on the flow that collects the data
- Recording paused before collection with a failure path that aborts the collection — quote
  both
- Sensitive fields kept server-side and referenced by opaque id in prompts, tool arguments, and
  logs — quote the id pattern and the server-side lookup
- Read-back limited to the last four digits or a masked form — quote the prompt line
- Voiceprint enrollment with consent capture, retention, and deletion in the workspace — quote
  them (the statute's sufficiency is Cat 25)
- No sensitive-data step on the flow, established by reading the tools and prompt — Skip, `not
  applicable`, with the search

### Context Check
1. What sensitive data does this flow expect? Read the tools and the prompt, not the marketing.
2. For each such step, what captures the data: speech, DTMF, a connector, a form?
3. What runs between capture and storage: redaction, masking, pause, opaque ids? Quote it or
   record its absence with scope.
4. Is any sensitive field in the prompt, the dynamic variables, the tool arguments, or the logs?
5. Does the voice itself get used as an identifier? If so, what governs its lifecycle?
6. Which providers receive the data, and is there anything in the workspace about the terms?

### Evidence Chain
- The capture step file:line (prompt section, tool, `<Gather>`, DTMF handler)
- The transcription and platform configuration file:line with the redaction options present or
  absent
- Any pause, mask, or connector handoff file:line and its failure path
- Prompt, variable, tool-argument, and log constructions that carry sensitive fields, file:line
- Voiceprint enrollment, comparison, retention, and deletion file:line or the search
- The search for agreements or zero-retention settings, with scope, feeding the Skip line

### Confidence Scoring
- **High**: the capture step, the storage path, and the absent control are all quoted from the
  workspace
- **Medium**: redaction may be configured platform-side with no export, or the provider applies
  a default not visible at the call site `(unverified — confirm in the platform docs)`
- **Low**: whether the flow actually collects the data could not be established from the prompt
  and tools — tag `needs human verification`

### Severity
Critical is card data captured into the transcript or placed in a field the provider excludes
from card-data scope. High is a control that fails open, a redaction available but unused on a
card or health flow, sensitive fields in prompts or tool logs, and a voiceprint with no
lifecycle. Medium is a full-value read-back, an unused redaction on a lower-sensitivity flow, or
a provider flow with no agreement visible. Low is not used.

### Files to Check
- `**/payment*`, `**/pay*`, `**/card*`, `**/verify*`, `**/identity*`, `**/intake*`,
  `**/insurance*`, `**/health*`
- `**/prompts/**`, `**/*prompt*`, `**/*assistant*.json`, `**/*agent*.json`
- `**/transcri*`, `**/stt*`, `**/deepgram*`, `**/assemblyai*`, `**/speech*`
- `**/tools/**`, `**/dispatch*`, `**/logger*`
- `**/voiceprint*`, `**/speaker*`, `**/biometric*`, `**/enroll*`
- `docs/**`, `legal/**`, `compliance/**` (agreements, if any are checked in)

### Reference
- CWE-312: Cleartext Storage of Sensitive Information
- CWE-359: Exposure of Private Personal Information to an Unauthorized Actor
- CWE-532: Insertion of Sensitive Information into Log File
- PCI DSS 4.0 Requirement 3 (sensitive authentication data not retained after authorization);
  the applicable regime facts are in `references/legal-landscape.md` via Cat 25
- Per-platform redaction, masking and pause features: `references/stacks/<platform>.md`
