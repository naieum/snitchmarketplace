## CATEGORY 17: Call duration, silence, idle and turn limits
> Type: posture · Groups: quick, abuse · Hop: H10 Limits and operations · Standards: CWE-400, CWE-770

Every second a voice agent is on a call, three meters run: the carrier's per-minute rate, the
transcription and synthesis providers' per-minute or per-character rates, and the model's tokens on
every turn — with the whole context re-sent each time. A caller who stays on the line, stays
silent, or keeps the agent talking in circles is spending the business's money at the business's
own rate. Most platforms offer a maximum duration, a silence timeout, and an idle timeout; most
quickstarts leave them at the default or unset, and some defaults are an hour or more. This
category reads every place a session's limits are set and asks whether an uncooperative caller can
hold a line open indefinitely.

**Boundary.** This category judges the limits on one session. How many sessions can run at once,
and how often one caller can start one, is Cat 18. The spend ceiling that bounds the account when
limits fail is Cat 19. Whether the agent goes silent or hangs up when a provider fails is Cat 20.
Whether the agent can be *made* to end the call by saying a phrase is Cat 20's forced-hang-up row.
A repetition loop that comes from injection is Cat 07's cause and this category's symptom; cite
both.

### Detection
- Platform session settings in exported configs or API calls: Vapi `maxDurationSeconds`,
  `silenceTimeoutSeconds`, `startSpeakingPlan` / `stopSpeakingPlan`; Retell
  `max_call_duration_ms`, `end_call_after_silence_ms`; Bland `max_duration`; ElevenLabs
  `conversation_config.turn.turn_timeout`, `max_duration_seconds`; Twilio `TimeLimit` on
  `calls.create`, `<Dial timeLimit>`, `<Connect>` / `<Stream>` handling with no server-side
  timer; Vonage `length_timer`, `ringing_timer`; Telnyx `time_limit_secs`; Plivo `time_limit`;
  LiveKit `RoomOptions.empty_timeout`, `departure_timeout`, `max_participants`, agent-side
  session timers; Pipecat `PipelineParams` idle timeouts, `STTMuteFilter`, `user_idle_timeout`;
  OpenAI Realtime session `expires_at` and the app's own timer; Gemini Live session windows
  (`context_window_compression`, session resumption) and the app's timer; Deepgram Voice Agent
  keep-alive handling and the app's timer; Amazon Connect flow timers
- Application timers: `setTimeout`, `setInterval`, `asyncio.wait_for`, `time.monotonic()` checks
  around the session, turn counters, `maxTurns`, `MAX_TURNS`
- Repetition or loop detection: comparing consecutive agent utterances, a "same tool call N
  times" guard, a "no progress" detector

### What to Search For
- Maximum duration unset, or set to the platform maximum, on an inbound line reachable by the
  public
- Silence timeout unset or very long; idle timeout absent for the media-stream servers that have
  no platform default (raw Twilio Media Streams to a self-hosted model, self-hosted realtime
  sessions)
- Turn cap absent: no limit on the number of model turns per session
- Keep-alive or heartbeat logic that extends the session without a ceiling
- Tool-call loops: the same tool invoked repeatedly with the same arguments and no guard
- No detection of an agent-to-agent loop (an outbound call answered by another automated
  system; both talk until the duration cap)
- Session resumption or reconnection that resets the duration clock
- Hold or "please wait" states with no timeout
- Post-hang-up work with no timeout (a summary generation that can run indefinitely)

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| no-max-duration | No maximum call duration is set in code and none is exported platform-side; or it is set to the platform maximum on a public line | the config or call file:line + the search | High (Medium if an export shows a platform default of ≤ 1 hour and the line is not public) |
| no-silence-timeout | No silence or idle timeout, so a silent caller holds the line | config file:line + the search | Medium |
| no-turn-cap | No cap on model turns or tool calls per session, with no loop guard | the search over the session loop | Medium |
| clock-reset | Reconnection, resumption, or transfer resets the duration clock with no session-level ceiling | handler file:line | Medium |
| no-loop-guard | No detection of repeated identical utterances or tool calls, whether the loop is the model's own or caller-driven (a caller asking for the same phrase again and again) | the search over the session loop | Medium on a public line or an outbound agent that can reach other automated systems; Low on an authenticated internal line |
| hold-without-timeout | A hold, wait, or queue state has no timeout | handler file:line | Medium |
| platform-side-unknown | Limits live only in a dashboard with no export | — | Skip (Rule 6), not a finding |

### Actually Vulnerable

#### Critical
- Not used in this category; a limit failure is bounded by Cat 18 and Cat 19 and does not on
  its own reach Critical

#### High
- A public inbound line with no maximum duration in code and no export showing one
- Raw media-stream or self-hosted realtime session with no server-side timer at all

#### Medium
- Silence or idle timeout absent
- No turn cap and no loop guard on a session loop the app controls
- Reconnect or resume paths that restart the clock
- Hold states with no timeout
- Max duration present but set to the platform ceiling (an hour or more) on a public line

### NOT Vulnerable
- `maxDurationSeconds` / `max_call_duration_ms` / `TimeLimit` / `max_duration` set to a value
  proportionate to the agent's task, and a silence timeout set, in the exported config or the
  call that creates the session — Pass quoting the values
- A server-side timer that ends the session on the media-stream servers that lack a platform
  default — Pass quoting the timer and the end-call action
- A turn or tool-call cap enforced in the session loop
- A loop guard that ends or escalates after repeated identical turns
- Platform defaults known to be bounded, when the export is in the workspace — Pass; when the
  export is absent — Skip with the Rule 6 wording, never inferred. Defaults this reference is
  not certain of are written `(unverified — confirm in the platform docs)`

### Context Check
1. Which component owns the session clock — the platform, the carrier, or the app? Read the
   session creation.
2. Is the line public (a published number, an open web widget) or internal? Severity follows.
3. Where is each limit set, and is it exported? Absent export is a Skip, not a finding.
4. What happens on reconnect, resume, or transfer?
5. Is there a loop in the app that could run without a turn cap?
6. For outbound agents: can the callee be another automated system?

### Evidence Chain
- The session-creation call or exported config file:line and the limit values present
- The search for each absent limit, with pattern and scope
- The server-side timer or its absence for app-owned sessions
- The reconnect, resume, or hold handlers and their clock behavior
- The Rule 6 skip line where the setting is platform-side only

### Confidence Scoring
- **High**: the session creation is in the workspace and verifiably sets no limit, or the
  export verifiably sets one (Pass)
- **Medium**: the limit may be set platform-side with no export, or a timer may live in a
  wrapper not fully read
- **Low**: the session-owning component could not be identified → tag `needs human verification`

### Severity
High is a public line with no ceiling at all. Medium is a missing secondary limit, a clock that
can be reset, a ceiling at the platform maximum, or a missing loop guard on a public line — a
caller can drive the loop as surely as the model can wander into one. Low is the loop guard on
an authenticated internal line. Critical is not used.

### Files to Check
- `**/*assistant*.json`, `**/*agent*.json`, `**/vapi*`, `**/retell*`, `**/bland*`, `**/elevenlabs*`
- `**/call*`, `**/session*`, `**/stream*`, `**/media*`, `**/realtime*`, `**/agent*.py`, `**/bot*.py`
- `**/twiml*`, `**/ncco*`, `**/outbound*`
- `.env*`, `**/config/**` (limit constants)

### Reference
- CWE-400: Uncontrolled Resource Consumption
- CWE-770: Allocation of Resources Without Limits or Throttling
- OWASP LLM Top 10 (2025): LLM10 Unbounded Consumption
- MITRE ATLAS: AML.T0034 Cost Harvesting
- Per-platform limit keys and their documented defaults: `references/stacks/<platform>.md`
