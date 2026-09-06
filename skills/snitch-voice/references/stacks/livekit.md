# Stack: LiveKit (Agents, SIP, server SDKs)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

LiveKit is an open framework: the agent is your code, the media server is yours or LiveKit Cloud,
and telephony arrives through SIP trunks you configure. Almost nothing is platform-side by
default, so most rows here are Findings or Passes in code, not Rule 6 Skips — except the trunk
and dispatch-rule objects, which live in the LiveKit project unless they are checked in as
config or created by an in-repo script.

## Fingerprints

- Packages: `livekit-agents`, `livekit-plugins-*` (openai, deepgram, cartesia, elevenlabs,
  silero, turn-detector), `livekit-api`, `livekit` (PyPI); `@livekit/agents`,
  `livekit-server-sdk`, `livekit-client`, `@livekit/components-react`, `@livekit/react-native`
  (npm); `github.com/livekit/server-sdk-go`
- Env: `LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `SIP_OUTBOUND_TRUNK_ID`,
  `LIVEKIT_SIP_URI`
- Hosts: `wss://*.livekit.cloud`, a self-hosted `wss://` URL
- Config: `livekit.toml`, `agent.yaml` (unverified — confirm in the platform docs), inbound and
  outbound trunk JSON (`numbers`, `allowed_addresses`, `allowed_numbers`, `auth_username`,
  `auth_password`, `headers_to_attributes`), dispatch-rule JSON (`pin`, `inbound_numbers`,
  `room_config.agents`)
- Classes and calls: `AccessToken(`, `VideoGrant`, `SIPGrant`, `WebhookReceiver`,
  `RoomConfiguration`, `AgentSession`, `AgentServer`, `JobContext`, `RunContext`,
  `@function_tool`, `llm.ai_callable` (older), `@server.rtc_session()`, `CreateSIPParticipant`,
  `TransferSIPParticipantRequest`, `transfer_sip_participant`, `publish_dtmf`, `EgressClient`,
  `RoomCompositeEgressRequest`, `sip.phoneNumber`, `sip.trunkPhoneNumber`

## Ingress and verification (H1)

- **Webhooks**: LiveKit POSTs events with `Authorization: Bearer <JWT>`; the JWT is signed with
  the API secret and its claims include a `sha256` of the body. Verify with
  `WebhookReceiver(apiKey, apiSecret).receive(rawBody, authHeader)` (JS) or the equivalent
  `WebhookReceiver` in the Python and Go SDKs. A `/livekit/webhook` route that parses the JSON
  and never calls `receive` is Cat 01 `unverified-route`.
- **SIP ingress**: there is no HTTP webhook for an inbound call; the trunk is the ingress. An
  inbound trunk with an empty `numbers` list and neither `auth_username`/`auth_password` nor
  `allowed_addresses` accepts INVITEs from any source that knows the SIP URI. The vendor's docs
  call `allowed_numbers` "a coarse filter, not proof of identity."
- **Media**: audio arrives over the room; the room is reached only with a token (below).

Insecure shape:

```ts
app.post("/livekit/webhook", express.json(), (req, res) => {
  const event = req.body;           // no WebhookReceiver.receive(), body already re-parsed
  if (event.event === "room_finished") saveTranscript(event.room.name);
  res.sendStatus(200);
});
```

Pitfalls: `express.json()` ahead of `receive` (it wants the raw body); trusting `event.room.name`
as a tenant identifier; a self-hosted deployment whose webhook URL is `http://`.

## Client authentication (H2)

- Safe browser credential: a JWT minted server-side by `AccessToken(apiKey, apiSecret,
  { identity, ttl })` with a `VideoGrant` (`roomJoin: true`, `room: "<specific room>"`,
  `canPublish`, `canSubscribe`) and, for agent dispatch, `RoomConfiguration.agents`. Default
  TTL is 6 hours per the vendor's docs; shorter is expected for a voice session.
- Must stay server-side: `LIVEKIT_API_SECRET`. A leaked secret mints any-permission tokens for
  any room, forever.
- Mint endpoint: your own `/token` (or `/api/connection-details`) route. Cat 04 reads it for:
  a session or user check before minting; a fixed or user-derived `room`, never a
  client-supplied wildcard; no `roomAdmin`, `roomCreate`, `roomList`, or `roomRecord` for end
  users; a TTL measured in minutes; a rate limit; CORS not `*`.
- Anti-patterns: `NEXT_PUBLIC_LIVEKIT_API_SECRET` / `VITE_LIVEKIT_API_SECRET`; `AccessToken(`
  constructed in a component file; `ttl: "30d"`; `room` taken from the query string.

## Tools (H6)

- Definition: `@function_tool async def transfer_to_human(context: RunContext, department:
  str)` (Python) or `llm.tool({...})` (JS); registered on the `Agent`. Every parameter is
  LLM-filled unless the handler ignores it and reads from `context` or from server state.
- Execution is always in your process. There is no tool webhook to authenticate; the
  authorization question is what the handler does with the participant's identity. The
  participant's `identity` and attributes come from the token (web) or from the trunk
  (`sip.phoneNumber`, `sip.trunkPhoneNumber`, and anything mapped by `headers_to_attributes`).
  Attributes mapped from SIP headers are attacker-controlled on an untrusted trunk (Cat 05, 08).
- Dangerous built-ins are the SIP API calls a tool can reach: `transfer_sip_participant`,
  `CreateSIPParticipant` (dial-out), `publish_dtmf`, `room.disconnect()` / deleting the room
  (end call). MCP servers attached via the agents MCP integration widen the surface (hand off
  the MCP supply chain to snitch-security).

## Call control (H7)

- Dial-out: `CreateSIPParticipant(sip_trunk_id, sip_call_to, room_name, participant_identity,
  wait_until_answered, krisp_enabled)`. `sip_call_to` is the destination; trace it. An outbound
  trunk carries `numbers` (caller IDs) and `auth_username`/`auth_password` for the provider;
  credentials checked into the repo are Cat 26 / snitch-security Cat 03.
- Transfer: `TransferSIPParticipantRequest(room_name, participant_identity, transfer_to="tel:…"
  | "sip:…", play_dialtone)`. `transfer_to` from a tool argument with no fixed table is Cat 14
  `unrestricted-destination`.
- DTMF: `publish_dtmf(code, digit)` on the local participant.
- Trunk-side controls: `allowed_addresses` (source IPs), `allowed_numbers`, credentials on the
  inbound trunk; dispatch rules with `pin` for a DTMF PIN before the agent joins. These are
  platform objects: Pass when the trunk/dispatch JSON or the creating script is in the
  workspace, Rule 6 Skip otherwise. There is no per-country dialing permission at the LiveKit
  layer; that lives with the upstream SIP provider (unverified — confirm in the platform docs).

## Limits (H10)

- No built-in call-duration cap: the session lasts until the participant leaves, the agent
  disconnects, or the room's `empty_timeout` / `max_participants` (room-creation options)
  apply. A duration or turn cap is app code (Cat 17): a timer in the entrypoint, or
  `room.disconnect()` after N minutes.
- Silence: the agent's VAD and turn detector decide turns; an idle timeout is app code.
- Concurrency: the agent worker's load and job limits (`WorkerOptions` load threshold,
  `num_idle_processes`) and the SIP provider's channel count. Not a platform-side cap on
  inbound calls per se (unverified — confirm in the platform docs).
- Token expiry: the `ttl` on `AccessToken` bounds how long a client can join, not how long a
  joined session runs.

## Recording, transcripts, retention, redaction (H9)

- Nothing is recorded unless Egress is started: `RoomCompositeEgressRequest` /
  `TrackEgressRequest` with `EncodedFileOutput` and S3 / GCP / Azure credentials passed in
  the request. Those credentials in code are Cat 21 (destination and access) and Cat 26.
- Transcripts live in `session.history` in memory; anything durable is the app's write (a DB,
  a log line, a webhook). `console.log` / `logger.info` of every `user_input_transcribed` or
  `conversation_item_added` event is the common Cat 21 finding.
- No platform redaction. Redaction is whatever the STT plugin offers (a Deepgram plugin's
  `redact` option, for instance) or app code before the write. Absence is Cat 22.
- Retention: none platform-side for self-managed data; LiveKit Cloud's own analytics retain
  session metadata (unverified — confirm in the platform docs).

## Disclosure surfaces (H8)

- The `instructions` string passed to `Agent(instructions=…)`, the first `session.say(…)` or
  `session.generate_reply(instructions=…)` in the entrypoint, and any greeting constant. Cat 23
  and 24 grep these for the recording announcement and the AI disclosure.

## What the platform already handles (do not flag)

- Media is end-to-end over WebRTC/SRTP; transport encryption is not a finding.
- A room token with a specific `room` and `roomJoin` only cannot reach another room; do not
  flag the grant shape itself once the mint endpoint is checked.
- Webhook bodies are signed when `WebhookReceiver.receive` is used; do not ask for an
  additional shared secret.
- Inbound trunk credentials, when set, authenticate the SIP provider; do not flag the missing
  `allowed_addresses` in addition when credentials are present and quoted.
- The agents framework's own turn detection and VAD are not a security control and are not a
  finding either way.

## Category quick map

| Cat | Where this stack most often fires | Inherent Rule 6 Skips |
|---|---|---|
| 01 | `/webhook` route without `WebhookReceiver.receive` | — |
| 02 | inbound trunk with empty `numbers`, no credentials, no `allowed_addresses` | trunk not in workspace |
| 03 | `LIVEKIT_API_SECRET` under a public env prefix or in a client file | — |
| 04 | `/token` route with no user check, wildcard `room`, admin grants, long TTL | — |
| 05, 08 | `sip.phoneNumber` or `headers_to_attributes` values used as identity or in the prompt | — |
| 12, 13 | tool handlers acting on LLM-filled args with no server-side authorization or confirmation | — |
| 14 | `transfer_to` / `sip_call_to` from a tool argument with no fixed table | provider-side geo permissions |
| 17, 18 | no duration timer, no idle timeout, no per-caller throttle in the entrypoint | worker load limits if only in deployment config |
| 19 | no spend control anywhere in code; provider budgets platform-side | STT/LLM/TTS provider caps |
| 21, 22 | egress credentials in code; transcripts logged; no redaction before writes | Cloud analytics retention |
| 23, 24 | `instructions` and first `say` lacking the announcement or disclosure | — |
| 26 | `http://` webhook URL, trunk credentials in the repo, sample entrypoints shipped | — |
