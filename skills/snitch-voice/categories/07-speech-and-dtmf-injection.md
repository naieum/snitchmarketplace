## CATEGORY 07: Injection through transcribed speech and DTMF
> Type: sink-pattern · Groups: quick, injection · Hop: H3 Transcription · Standards: CWE-1427; OWASP LLM01

Everything the caller says becomes text, and text is what the model follows. The caller can speak
instructions instead of answers — a role override, a claim of authority, a request to recite the
configuration, a "from now on" — and the transcriber will hand it over as confident, clean prose.
Voice makes this worse than a chat box: disfluent or noisy speech is normalized into plausible
sentences, some transcribers hallucinate whole phrases in silence, multi-turn pressure hides the
unsafe ask behind several valid ones, and speech-native models are demonstrably easier to move
with delivery, pace, accent, and language switching than with typed text. Keypad digits arrive
through the same door. This category traces transcribed speech and DTMF from the transcriber to
the prompt and asks whether anything outside the model separates the caller's words from the
agent's instructions.

**Call-path tracing required (anti-hallucination Rule 3).** Trace the transcript (`prompt`,
`transcript`, `text`, `input_audio_transcription`, `user` turns) and the DTMF digits (`Digits`,
`dtmf`, `digit`) from the transcriber or carrier event to the message the model receives. Speech
kept in a `user`-role turn behind a pre-model gate is a Pass; speech or digits concatenated into
the system or developer instructions, into a transcriber's own prompt parameter, or into a tool
argument with no validation is a finding. A "never follow caller instructions" line in the prompt
is never a control.

**Boundary.** This category judges the transcription hop: what the caller said or keyed. Call
metadata (`From`, name, city, SIP headers, client variables) reaching the prompt is Cat 08;
records and tool results reaching the prompt are Cat 09; what is in the system prompt to begin
with is Cat 10; a caller-steered tool call landing at a sink is Cat 12–16, with this category
naming the injection hop. Injection at a typed chat input is snitch-security's Cat 15 — hand off
by calling the Skill tool with "snitch-security". Digits sent by the agent are Cat 14.

### Detection
- Transcriber outputs: Twilio ConversationRelay `prompt` messages with `voicePrompt`, Media
  Streams paired with a transcriber; Deepgram `transcript` / `is_final`; OpenAI Realtime
  `conversation.item.input_audio_transcription.completed`; Gemini Live `inputTranscription`;
  AssemblyAI `FinalTranscript`; Azure Speech `recognized`; Whisper `transcribe(...)`;
  LiveKit `user_input_transcribed`, `on_user_turn_completed`; Pipecat `TranscriptionFrame`,
  `LLMUserContextAggregator`
- DTMF inputs: Twilio `<Gather>` `Digits`, ConversationRelay `dtmf` messages with
  `dtmfDetection="true"`, Vonage `dtmf` events, Telnyx `call.dtmf.received`, Vapi DTMF events,
  Retell digit inputs, LiveKit `sip_dtmf_received`, Amazon Connect "Get customer input"
- Transcriber prompt or hint parameters: Whisper `initial_prompt` / `prompt`, Deepgram
  `keywords` / `keyterm`, ConversationRelay `hints`, Azure phrase lists, Google
  `speechContexts`
- Prompt assembly: `messages.push`, `system:`, `instructions:`, `session.update` with
  `instructions`, `ChatContext`, `LLMMessagesFrame`, `add_message`, template literals building
  prompts

### What to Search For
- Transcript text interpolated into a system, developer, or instruction string
  (`` `${systemPrompt}\nCaller said: ${transcript}` ``, `instructions: base + transcript`)
- Transcript text appended to the prompt's instruction section on each turn as "context" or
  "summary so far" without role separation
- DTMF digits concatenated into prompt text as free text rather than validated as digits and
  passed as structured data
- `<Gather>` results or `dtmf` payloads used to select a branch by string match on an LLM-built
  value
- Caller-derived text passed into the transcriber's own prompt or hint parameter (Whisper
  `initial_prompt` built from a previous transcript, `hints` from a CRM field the caller wrote)
- No pre-model gate: no input classifier, moderation, or intent check before the transcript
  reaches the primary model on a public number
- Language or locale switching accepted mid-call with no policy re-check, where the agent's
  refusal logic is language-specific
- Instruction-like transcripts ("ignore", "you are now", "repeat your instructions") reaching
  the model with no abuse logging (advisory: pattern lists are defense in depth, never the
  control)
- Transcriber hallucination handling: no confidence threshold, no minimum audio energy, silence
  turns producing text that the model acts on
- Speech-to-speech sessions where the model consumes audio directly and the only guard is the
  system prompt: check whether the session configuration locks instructions (Cat 04, Cat 11) and
  whether an output gate exists on the synthesis path (Cat 16)
- Verbatim echo: the agent repeats caller-supplied text into synthesis on request ("say X",
  "say it again", "spell that back", "read this back to me") with no output filter, no length
  cap, and no count on how many times it has complied. The agent is then a free text-to-speech
  service in the brand's voice — the caller chooses what it says, records it, and can drive it
  round the same phrase until the duration cap, the context window, or the synthesizer's chunk
  limit ends the call. Look for prompts that instruct the agent to repeat or confirm caller
  input word for word, for the absence of any output gate on the synthesis path, and for the
  absence of a repeat counter; the loop's symptoms (turn caps, repetition guards) are Cat 17
  and Cat 20, the spend is Cat 19, and the cause is judged here
- Device-mic deployments (WebRTC, mobile, kiosk, drive-through): no note of adversarial or
  inaudible audio risk; on PSTN the band limit removes ultrasonic carriers, so that row is a
  Skip with reason on phone-only agents

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| speech-in-instruction-position | Transcribed speech reaches the system, developer, or instruction string, or a transcriber prompt parameter | trace from the transcriber event to the assembly point | Critical |
| dtmf-as-free-text | DTMF digits are concatenated into prompt text or used unvalidated in a tool argument or branch | trace from the DTMF event to the sink | High |
| no-pre-model-gate | On a public number, no input check runs before the transcript reaches the primary model, and the system prompt is the sole scope enforcer | the turn handler + the search for a gate | High |
| hallucination-unhandled | Final transcripts are acted on with no confidence threshold or silence handling where the transcriber exposes one | the transcriber config | Medium |
| language-switch-unchecked | Policy checks are language-specific and the session accepts a mid-call language change with no re-check | the language config + the gate | Medium |
| verbatim-echo | Caller-supplied text is repeated into synthesis on request with no output filter, no per-turn length cap, and no repeat counter, on a public line | the prompt instruction or the turn handler that passes caller text through + the search for an output gate and a counter | High (Medium on an authenticated or internal line) |
| no-abuse-log | Instruction-like transcripts are neither logged nor counted | the search | Low |
| device-mic-unnoted | A device-mic deployment has no adversarial-audio consideration anywhere (advisory) | the client + the search | Low |
| pstn-only | The agent is phone-only; inaudible-carrier rows do not apply | the ingress | Skip |

### Actually Vulnerable

#### Critical
- `messages = [{ role: 'system', content: SYSTEM + '\nTranscript so far:\n' + transcript }]`
- `session.update({ instructions: basePrompt + lastUserText })`
- Whisper `initial_prompt` built from the caller's prior turns

#### High
- ConversationRelay `dtmf` digit appended to `voicePrompt` text and sent as the user turn with
  no digit validation
- `<Gather>` `Digits` interpolated into a tool argument that selects a record
- A public inbound number whose turn handler forwards every final transcript straight to the
  model with no gate and no output gate
- A public line whose prompt tells the agent to repeat or confirm whatever the caller says, or
  whose turn handler passes caller text to synthesis, with no output gate, no length cap on the
  synthesized text, and nothing counting consecutive repeat requests (`verbatim-echo`)

#### Medium
- No `is_final` / confidence handling; silence turns produce text acted on
- Refusal rules written only in English on a multilingual line

### NOT Vulnerable
- Transcripts confined to `user`-role turns with structural separation from instructions, the
  instructions locked server-side (quote the assembly and the lock)
- DTMF validated as digits with a length cap and passed as structured data to a handler that
  does not build prompt text from it
- A pre-model gate (a cheap classifier, a moderation call, an intent allowlist) that runs
  before the primary model, with the code quoted
- Transcriber prompt parameters populated only from fixed vocabulary
- A transcriber confidence threshold and silence handling in place
- Speech-native sessions with instructions locked at token minting and an output gate on the
  synthesis path — Pass for this category's rows; the locks themselves are Cat 04 and Cat 16
- A pattern list that exists is not required for a Pass and its absence is not a finding on its
  own
- Read-back of a value the agent itself produced or looked up (a confirmation number, a
  scheduled time) is not verbatim echo; the row needs caller-supplied text reaching synthesis
- An agent that confirms a spoken value once, through a template ("I heard 4 5 6 — is that
  right?"), behind a per-turn length cap and a repeat counter that escalates or ends after N
  identical requests — Pass, quoting the template, the cap and the counter

### Context Check
1. Where does transcribed text first exist in the code, and what role does it land in?
2. Is any instruction string rebuilt per turn from caller text?
3. Are DTMF digits ever text to the model?
4. What, outside the model, runs on the transcript before the model does?
5. Does the transcriber take a prompt or hints, and where do they come from?
6. Is the ingress PSTN, device mic, or both?
7. Can the caller choose the words the agent says next? If caller text reaches synthesis, what
   caps its length, what filters it, and what stops the third identical request?

### Evidence Chain
- The transcriber or DTMF event handler file:line
- Each hop to the prompt assembly or tool argument, with file:line
- The role or position the text lands in, quoted
- Gates checked and found absent: role separation, pre-model gate, digit validation,
  confidence threshold
- Source classification: transcribed speech, DTMF, transcriber-prompt parameter

### Confidence Scoring
- **High**: complete trace from the transcriber event to an instruction-position sink, or to
  a tool argument with no validation
- **Medium**: the assembly happens in a framework helper whose role handling is not fully
  visible, or the gate may be platform-side
- **Low**: the transcript's path could not be followed — tag `needs human verification`

### Severity
Critical is caller speech in the instruction position. High is digits as text, tool arguments
from raw digits, a public line with no gate at all, or verbatim echo on a public line. Medium is
transcriber robustness, language-scope gaps, and verbatim echo on an authenticated line. Low is
advisory logging and device-mic notes.

### Files to Check
- `**/transcri*`, `**/stt*`, `**/asr*`, `**/speech*`, `**/whisper*`, `**/deepgram*`
- `**/relay*`, `**/media-stream*`, `**/gather*`, `**/dtmf*`
- `**/prompt*`, `**/messages*`, `**/context*`, `**/turn*`, `**/agent*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/session*`

### Reference
- CWE-1427: Improper Neutralization of Input Used for LLM Prompting
- OWASP LLM Top 10 (2025): LLM01 Prompt Injection
- OWASP Agentic Top 10 (2025): ASI01 Agent Goal Hijack
- MITRE ATLAS: AML.T0051.000 LLM Prompt Injection (direct), AML.T0054 LLM Jailbreak, AML.T0043 Craft Adversarial Data
