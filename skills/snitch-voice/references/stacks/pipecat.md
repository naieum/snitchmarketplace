# Stack: Pipecat (with Daily transport, tokens and webhooks)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Pipecat is an open Python framework: the bot is a pipeline of your services, the transport is
either a Daily room (WebRTC) or a telephony WebSocket fed by a carrier (Twilio, Telnyx, Plivo,
Exotel, Bandwidth). It has no inbound webhook of its own; ingress verification is inherited from
whichever carrier or from Daily. Pipecat Cloud adds a hosted `/start` endpoint with one-time
tokens. Most rows here are code, not Rule 6 Skips.

## Fingerprints

- Packages: `pipecat-ai[daily,openai,deepgram,cartesia,silero,twilio]`, `pipecat-ai-flows`,
  `pipecat-ai-small-webrtc`, `pipecat-ai-small-webrtc-prebuilt` (PyPI); `@pipecat-ai/client-js`,
  `@pipecat-ai/client-react`, `@pipecat-ai/daily-transport`, `@pipecat-ai/small-webrtc-transport`,
  `@daily-co/daily-js`, `@daily-co/daily-react` (npm); `daily-python`
- Env: `DAILY_API_KEY`, `DAILY_ROOM_URL`, `DAILY_SAMPLE_ROOM_URL`, `DAILY_API_URL`,
  `PIPECAT_API_KEY`, plus one key per model service (`OPENAI_API_KEY`, `DEEPGRAM_API_KEY`,
  `CARTESIA_API_KEY`, `ELEVENLABS_API_KEY`)
- Files: `bot.py`, `server.py`, `runner.py`, `pcc-deploy.toml` (Pipecat Cloud)
- Hosts: `api.daily.co`, `*.daily.co`
- Headers (Daily webhooks): `X-Webhook-Signature`, `X-Webhook-Timestamp`
- Classes and calls: `DailyTransport(room_url, token, bot_name, DailyParams(...))`,
  `FastAPIWebsocketTransport`, `FastAPIWebsocketParams(serializer=...)`,
  `TwilioFrameSerializer(stream_sid, call_sid, account_sid, auth_token)`,
  `TelnyxFrameSerializer`, `PlivoFrameSerializer`, `ExotelFrameSerializer`,
  `BandwidthFrameSerializer`, `DailyRESTHelper`, `DailyRoomParams`, `create_room(`,
  `get_token(`, `is_owner`, `FunctionSchema`, `ToolsSchema`, `llm.register_function(`,
  `FlowManager`, `MCPClient`, `TranscriptProcessor`, `startBotAndConnect(`, `DailyDialinSettings`,
  `dialout` / `dial_out`

## Ingress and verification (H1)

- **Telephony WebSocket**: the carrier opens a socket to your `FastAPIWebsocketTransport` route.
  The transport validates `allowed_origins` and has a `session_timeout`; it does **not** validate
  the carrier's signature on the upgrade request. Verification is the carrier's scheme
  (`X-Twilio-Signature` on the handshake, Telnyx Ed25519 on the preceding webhook, and so on),
  applied by your route. See the carrier's stack file.
- **The TwiML/NCCO/TeXML route** that returns the `<Stream>` pointing at the socket is a plain
  carrier webhook: Cat 01 per the carrier's helper.
- **Daily webhooks**: `X-Webhook-Timestamp` and `X-Webhook-Signature`, HMAC-SHA256 base64 over
  `${timestamp}.${JSON.stringify(event)}`, keyed with the base64-decoded HMAC secret returned
  when the webhook was created. There is no SDK helper named in the vendor's docs; grep for the
  manual HMAC and a constant-time compare.
- **Pipecat Cloud `/start`**: the hosted endpoint issues one-time tokens; new agents default to
  requiring them (unverified — confirm in the platform docs). Self-hosted `/start` or `/connect`
  endpoints have whatever auth you wrote.

Insecure shape (the shape of the vendor's own Twilio example):

```python
@app.post("/")
async def start_call():
    return HTMLResponse(content=twiml_with_stream_url, media_type="application/xml")  # no RequestValidator

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()                # any client that knows the URL
    await run_bot(websocket, stream_sid, call_sid)
```

Pitfalls: `wss://{request.headers['host']}/ws` built from the Host header; tunnel URLs in the
TwiML; `allowed_origins=["*"]`.

## Client authentication (H2)

- Safe browser credential: a Daily meeting token with an `exp`, minted by
  `DailyRESTHelper(daily_api_key=...).get_token(room_url, expiry_time, owner=False)` after
  `create_room(DailyRoomParams(...))`; the browser then calls
  `pcClient.startBotAndConnect({ endpoint: "/api/start" })` and joins with the room URL and
  token the server returned.
- Must stay server-side: `DAILY_API_KEY`, every model-service key.
- Mint endpoint: your `/api/start`, `/connect`, or `/start`. Cat 04 reads it for: a user or
  session check; a rate limit (each call also spawns a bot process and burns model minutes —
  Cat 18 and 19); `owner=False` / `is_owner: False` for end users; a short `exp`; CORS not `*`.
- Anti-patterns: `get_token(..., owner=True)` for callers; `exp` of days; the endpoint creating
  an unbounded number of rooms; `DAILY_API_KEY` under a public env prefix; the small-WebRTC
  transport's offer endpoint open to the internet with no auth.

## Tools (H6)

- Definition: `FunctionSchema(name, description, properties, required)` collected in
  `ToolsSchema(standard_tools=[...])`, handlers via `llm.register_function("name", handler,
  cancel_on_interruption=..., timeout_secs=...)`. Flows scope functions per node via
  `FlowManager`. `MCPClient` attaches MCP servers (hand off supply chain to snitch-security).
- Execution is in your process; every property is LLM-filled. Authorization is what the
  handler does with the participant (Daily participant id / user data from the token, or the
  carrier's `call_sid` and `From` captured at stream start).
- Dangerous shapes: a handler that dials out (`transport.start_dialout(...)`, Daily `dialOut`),
  ends the call (`EndFrame`, `transport.close()`), sends digits, or writes to a backend keyed
  by a spoken identifier.

## Call control (H7)

- Dial-in: `DailyDialinSettings` on `DailyParams`; the carrier delivers the call into the room.
- Dial-out: Daily `dialOut` / `dial_out` with a `phoneNumber` or SIP URI; on the carrier
  transports, dial-out is the carrier's API (`calls.create`, Telnyx `dial`). Trace the
  destination (Cat 14).
- Transfer: not a Pipecat primitive; it is a carrier call (`<Dial>`, `transfer`) or a Daily SIP
  bridge from your code. DTMF-send is the carrier's `sendDigits` / `send_dtmf`.
- Geo and allowed-country controls are carrier-side: Rule 6 Skip unless the carrier's
  permissions export is in the workspace.

## Limits (H10)

- `FastAPIWebsocketParams(session_timeout=...)` closes the telephony socket after N seconds;
  absent means no cap on the socket (unverified default — confirm in the platform docs).
- Daily rooms accept `exp` (room expiry) and `eject_at_room_exp` in `DailyRoomParams`; a room
  created without them lives until deleted.
- Idle and silence: the pipeline's VAD and an idle-timeout processor, if you added one.
- Concurrency: one bot process per call; the cap is whatever your process manager or Pipecat
  Cloud plan enforces. Rule 6 Skip for the hosted plan; a code finding when a self-hosted
  `/start` spawns without a limit.

## Recording, transcripts, retention, redaction (H9)

- Recording is off unless started: Daily cloud recording via the REST API or `start_recording`
  on the transport; carrier recording via the carrier's flags. Recording destinations and
  credentials in code are Cat 21.
- Transcripts are frames in the pipeline; `TranscriptProcessor` and any logger handler that
  prints `TranscriptionFrame` / `TextFrame` content are where they leak. The `/api/start`
  server's stdout is the usual sink.
- No platform redaction in Pipecat; use the STT service's option (Deepgram `redact`, AssemblyAI
  `redact_pii`) or a frame processor. Absence is Cat 22.
- Daily retains recordings and logs per its plan; retention is platform-side (Rule 6 Skip).

## Disclosure surfaces (H8)

- The `system` message in the initial `LLMContext` / `OpenAILLMContext` messages, the first
  `TextFrame` or `TTSSpeakFrame` the bot pushes on `on_first_participant_joined` /
  `on_client_connected`, and Flow node `task_messages`. Cat 23 and 24 grep these.

## What the platform already handles (do not flag)

- Daily media is encrypted WebRTC; do not flag transport encryption.
- A meeting token scoped to one room with `owner=False` cannot administer the room; do not flag
  the token shape once the mint endpoint is checked.
- The telephony transport's `allowed_origins` is an origin check for browser clients, not a
  substitute for the carrier signature — do not record it as the Cat 02 control.
- Pipecat Cloud's `/start` one-time tokens, when the deploy config shows them enabled, cover
  the mint-endpoint auth row.

## Category quick map

| Cat | Where this stack most often fires | Inherent Rule 6 Skips |
|---|---|---|
| 01 | the TwiML/TeXML route with no carrier `RequestValidator`; Daily webhook with no HMAC | — |
| 02 | `@app.websocket` accepting any client; `allowed_origins=["*"]`; Host-header stream URL | — |
| 03 | `DAILY_API_KEY` or model keys in a client bundle | — |
| 04 | `/api/start` with no auth, `owner=True`, long `exp`, unlimited room creation | Pipecat Cloud plan token settings |
| 07 | transcription frames reaching the system message | — |
| 12, 13 | `register_function` handlers acting on LLM-filled args without authorization or confirmation | — |
| 14 | `dial_out` / carrier dial with a traced caller-influenced destination | carrier geo permissions |
| 17, 18 | no `session_timeout`, no room `exp`, `/start` spawning bots without a cap | hosted concurrency |
| 19 | no spend guard around per-call bot spawn | provider budgets |
| 21, 22 | transcripts logged from frames; recording credentials in code; no STT redaction | Daily retention |
| 23, 24 | system message and first `TTSSpeakFrame` lacking announcement or disclosure | — |
| 26 | tunnel URL in TwiML, `.env` with every provider key committed, example `bot.py` shipped as-is | — |
