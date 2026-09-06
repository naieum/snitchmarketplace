## CATEGORY 20: Outage behavior, dead air, forced hang-up and human fallback
> Type: posture · Groups: abuse · Hop: H10 Limits and operations · Standards: CWE-636, CWE-755

A voice agent is three vendors in a trench coat: a transcriber, a model, and a synthesizer, each
of which can time out, return an error, or rate-limit mid-sentence. When one does, the caller
hears one of three things — dead air, a click, or a loop — and none of those is a design. The
same fragility is a weapon: a caller who knows the configured end phrase can end any call, a
played voicemail beep can trip machine detection so the agent hangs up or leaves a message
carrying account details, deliberate silence trips the silence timeout, and a steered model can
be talked into refusing, going quiet, or repeating itself until the duration cap. This category
reads what the code and configuration do when a hop fails or when the caller tries to make the
agent stop, and asks whether the outcome was chosen or merely happened.

**Boundary.** This category judges what happens when the agent cannot or will not continue. The
caps themselves — duration, silence, turns — are Cat 17; concurrency and callback loops are Cat
18; spend ceilings are Cat 19; whether an outage is noticed is Cat 27; the injection that makes
the agent go quiet is Cat 07's finding, and the end-call tool's reachability from that injection
is judged here. Generic error-handling defects off the call path are snitch-security's business —
hand off by calling the Skill tool with "snitch-security".

### Detection
- Provider client construction for STT, LLM and TTS with or without `timeout`, `maxRetries`,
  `retry`, `backoff`, `signal` / `AbortController`
- Platform end-call and detection knobs: Vapi `endCallPhrases`, `endCallFunctionEnabled`,
  `endCallMessage`, `voicemailDetection`, `voicemailMessage`; Retell `end_call`,
  `voicemail_detection`, `voicemail_message`, `end_call_after_silence_ms`; Bland `voicemail_action`,
  `voicemail_message`, `wait_for_greeting`; Twilio `MachineDetection`, `AsyncAmd`,
  `AsyncAmdStatusCallback`; ElevenLabs `end_call` system tool; LiveKit `hangup` /
  `delete_room`; Pipecat `EndFrame`, `EndTaskFrame`, `CancelFrame`
- Tool definitions named `endCall`, `end_call`, `hangup`, `hang_up`, `terminate`, `escalate`,
  `handoff`, `transfer_to_human`
- WebSocket and stream lifecycle handlers: `on('close')`, `on('error')`, `onclose`, `onerror`,
  `finally`, `except`, `catch` around the media loop
- Health endpoints (`/health`, `/healthz`, `/ready`), readiness probes, and the deployment
  manifest that wires them (`livenessProbe`, `healthcheck`, `HEALTHCHECK`)
- Fallback voice content: `<Say>`, `play`, `speak`, `firstMessage`, `welcomeGreeting` used on an
  error path

### What to Search For
- LLM, STT, or TTS calls with no timeout and no abort signal, inside the per-turn loop
- Catch blocks around the model call that swallow the error and send nothing to the caller
  (dead air), or that close the socket without a spoken message (a click)
- Retry loops on 429 or 5xx with no attempt cap, no jitter, and no bound on total time per turn
- An `endCall` tool exposed to the model with no server-side guard, so an injected instruction
  ends any call; `endCallPhrases` that are ordinary conversational words
- Voicemail or machine detection on outbound calls whose voicemail message contains account,
  appointment, balance, or health detail, or whose detection result is trusted with no minimum
  confidence
- Silence timeout that ends the call with no warning prompt and no re-prompt
- No fallback to a human queue, a callback promise, or a static IVR when the model provider is
  unavailable; the agent's only failure mode is disconnect
- No repetition guard: the same assistant text emitted N turns in a row with nothing checking
- No health endpoint, or one that returns 200 without checking any provider reachability
- Provider-side failure reasons ignored: platform `endedReason` values such as
  `pipeline-error-*`, `*-llm-failed-429`, `silence-timed-out`, `exceeded-max-duration` never
  read, alerted on, or counted (the alert is Cat 27; the absent handling is here)
- Degraded-mode switches (a cheaper model, a cached greeting, a static menu) present but never
  wired, or wired but reachable only by redeploy

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| dead-air-on-failure | A provider error or timeout on the turn loop leads to no spoken message and no disconnect, or the call is dropped with nothing said | the catch or close handler file:line | High |
| no-turn-timeout | The model, transcriber, or synthesizer call inside the turn loop has no timeout and no abort signal | the call file:line + the absent option | High |
| unbounded-retry | Retries on provider errors have no attempt cap or no total-time bound per turn | the retry config or loop file:line | Medium |
| end-call-from-model | An end-call tool or phrase is reachable by the model or the caller with no server-side condition | the tool definition or `endCallPhrases` file:line | High on lines that take money or health calls; Medium elsewhere |
| voicemail-leaks-or-misfires | Voicemail detection leaves a message carrying protected detail, or a detection result is trusted at any confidence | the voicemail message or detection config file:line | High for protected detail; Medium for misfire |
| silence-hangup-no-warning | Silence timeout disconnects with no re-prompt or warning | the timeout config file:line + the absent prompt | Low |
| no-human-fallback | No path to a human queue, callback, or static IVR exists when the model is unavailable | the search for fallback, transfer-to-human, or static TwiML on the error path | Medium |
| no-repetition-guard | Nothing detects the same assistant output repeating across turns, whether the model is stuck or the caller is steering it into repeating a phrase until it stalls or the synthesizer fails | the turn loop file:line + the search | Medium on a public line; Low on an authenticated internal line |
| health-check-hollow | A health endpoint exists but checks nothing, or none exists and the deployment wires a probe to nothing | the endpoint file:line or the manifest | Low |

### Actually Vulnerable

#### Critical
- Not used in this category; a failure that ends in silence or a click is never Critical on its
  own. A path where an outage causes an unauthorized action (a transfer fired on a timeout) is
  reported under Cat 13 or 14.

#### High
- `catch (e) { ws.close() }` around the model call with no spoken message and no fallback
- A turn loop whose provider calls carry no timeout, so one stalled request holds the line until
  the duration cap
- An `endCall` tool with no server-side guard on an agent that takes payments or health calls
- A voicemail message template interpolating account or appointment detail
- An outbound flow that acts on `MachineDetection` results with no confidence threshold
  `(unverified — confirm in the platform docs)` whether the provider exposes one

#### Medium
- Retry loops with no cap; `endCallPhrases` set to everyday words; no human fallback anywhere
  on the error path; voicemail detection trusted blindly on a flow that then leaves a message

### NOT Vulnerable
- Every provider call in the turn loop carries a timeout and an abort path, and the catch speaks
  a fixed message then either transfers to a human queue or ends with an explanation — quote the
  timeout, the message, and the transfer
- An `endCall` tool guarded server-side by call state (verification failed, task complete,
  caller asked twice) — quote the guard
- Voicemail message limited to a callback request with no detail; detection results used only
  to decide whether to speak, never to act
- A repetition guard that compares the last N assistant turns and escalates or ends — quote it
- A health endpoint that probes the model and transcription providers with a short timeout and
  returns their status — quote the probe
- No outbound calling and no voicemail detection in the workspace — the voicemail rows Skip with
  `not applicable` and the search that established it

### Context Check
1. Trace one turn: audio in, transcript, model call, synthesis, audio out. At each step, what
   happens on timeout, on error, on 429?
2. What does the caller hear on each failure path? Read the catch and close handlers; if they
   send nothing, the answer is dead air.
3. Who can end the call, and on what condition? Read the end-call tool and the phrase list.
4. On outbound calls, what does the agent do when it decides it reached a machine? What does the
   message contain?
5. Is there anywhere for the caller to go when the model is down?
6. Does anything in the code notice a stuck or looping conversation?

### Evidence Chain
- The turn-loop file:line and each provider call with its timeout option or its absence
- The error and close handlers file:line with what they send to the caller
- The end-call tool definition and any server-side guard, file:line
- The voicemail configuration and message template file:line
- The search for fallback paths (transfer to human, static IVR, callback) with pattern and scope
- The health endpoint and the deployment probe, or the search that established their absence

### Confidence Scoring
- **High**: the turn loop and its handlers are in the workspace and read end to end; the
  failure path is quoted
- **Medium**: the loop is inside a hosted platform and only its configuration is exported, or
  the provider SDK applies a default timeout not visible at the call site
  `(unverified — confirm in the platform docs)`
- **Low**: the failure path could not be resolved (dynamic pipeline assembly, framework
  internals) — tag `needs human verification`

### Severity
High is a failure path the caller experiences as silence or a click on every provider error, a
turn loop that can stall indefinitely, an end-call reachable by injection on a sensitive line, or
a voicemail that speaks protected detail. Medium is a missing bound, a missing fallback, or a
trivially triggered end phrase, or a missing repetition guard on a public line, where a caller
can drive the loop deliberately. Low is warning-less silence handling, the repetition guard on
an authenticated internal line, and a hollow health check. Critical is not used.

### Files to Check
- `**/agent*`, `**/pipeline*`, `**/turn*`, `**/loop*`, `**/session*`, `**/stream*`
- `**/tools/**` (end-call, escalate, transfer-to-human)
- `**/*assistant*.json`, `**/*agent*.json`, `**/vapi*`, `**/retell*`, `**/bland*`
- `**/health*`, `Dockerfile`, `**/k8s/**`, `**/deploy/**`, `fly.toml`, `render.yaml`
- `**/voicemail*`, `**/amd*`, `**/machine*`

### Reference
- CWE-636: Not Failing Securely ('Failing Open')
- CWE-755: Improper Handling of Exceptional Conditions
- CWE-835: Loop with Unreachable Exit Condition
- OWASP Agentic Top 10 (2025): ASI08 Cascading Failures
- Per-platform end-call, voicemail-detection and silence knobs: `references/stacks/<platform>.md`
