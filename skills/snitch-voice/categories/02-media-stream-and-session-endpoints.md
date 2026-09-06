## CATEGORY 02: Media-stream sockets, SIP ingress and realtime session endpoints
> Type: posture · Groups: quick, ingress · Hop: H1 Ingress · Standards: CWE-306, CWE-319

The webhook says "a call is ringing"; the audio arrives somewhere else. A telephony media stream
(`<Connect><Stream>`, `<ConversationRelay>`, a Vonage or Telnyx bidirectional stream), a SIP
trunk into a LiveKit or Asterisk deployment, a Daily or LiveKit room, or a realtime session socket
is the endpoint that actually carries the caller's voice into the model and the model's voice
back. These endpoints are routinely deployed with no authentication at all: a WebSocket path that
accepts any client who knows the URL, a SIP trunk with an empty number list and no source-address
restriction, a `ws://` URL in production. Anyone who can reach the socket can start a session
nobody dialed, inject audio into a live call, pull the model's audio, or run the agent's model and
speech minutes on their own account. This category reads every audio and session ingress and asks
whether the connecting party is verified before audio flows, and whether the transport is
encrypted.

**Boundary.** This category judges the transport-level ingress that carries audio or opens a
session. The HTTP webhook that pointed the carrier at it is Cat 01; the token a browser or mobile
client presents to open a session is minted in Cat 04 and checked here only for whether the
endpoint demands one; a generic WebSocket server with no audio on it is snitch-security's Cat 56
— hand off by calling the Skill tool with "snitch-security". Whether the SIP caller's identity
is trusted once connected is Cat 05.

### Detection
- Twilio Media Streams and ConversationRelay: `<Connect><Stream url="wss://…">`,
  `<ConversationRelay url="wss://…">`, `<Start><Stream>`, WebSocket handlers receiving `connected`,
  `start`, `media`, `setup`, `prompt` events; `streamSid`, `callSid`
- Vonage `websocket` NCCO endpoints (`"type": "websocket"`, `"uri": "wss://…"`); Telnyx
  `streaming_start` / `stream_url`; Plivo `<Stream>`; SignalWire `<Stream>`
- SIP: LiveKit `inbound_trunk`, `sip_trunk`, `SipInboundTrunkInfo`, `allowed_addresses`,
  `allowed_numbers`, `auth_username`, `auth_password`, dispatch rules with `pin`; Asterisk
  `pjsip.conf` / `sip.conf` endpoints and `anonymous` contexts; FreeSWITCH `sip_profiles`,
  `accept-blind-auth`; Jambonz carrier configs; OpenAI Realtime SIP project ingress
- Session and room endpoints: LiveKit `roomJoin` / `RoomServiceClient`; Daily room creation with
  `privacy: "public"`; Pipecat `/connect`, `/start`, `/offer` routes; Retell `llm_websocket_url`
  (custom-LLM socket); Deepgram Voice Agent `wss://agent.deepgram.com`; OpenAI
  `wss://api.openai.com/v1/realtime`; ElevenLabs `wss://api.elevenlabs.io/v1/convai/conversation`
- WebSocket server frameworks: `ws`, `@fastify/websocket`, `socket.io`, `websockets` (Python),
  `FastAPI WebSocket`, `Starlette`, `aiohttp`, `gorilla/websocket`

### What to Search For
- WebSocket upgrade handlers with no check of a signature, token, or per-call secret before the
  first `media` frame is processed
- Twilio Media Streams / ConversationRelay handshakes: the `X-Twilio-Signature` header is present
  on the upgrade request (unverified — confirm against the current carrier docs for your
  stack); look for `validateRequest` on the upgrade, or a per-call HMAC passed as a
  `<Parameter>` and compared on `setup` / `start`
- Media-stream URLs built from `req.headers.host` or a tunnel hostname rather than a configured
  public origin, so a spoofed `Host` header redirects the carrier's audio to another server
- `ws://` rather than `wss://` in TwiML, NCCO, stream config, or environment variables
- Retell `llm_websocket_url` served over `ws://`, or with no secret in the path and no IP
  allowlist — the platform sends no auth headers on that socket (unverified — confirm in the
  platform docs)
- LiveKit inbound trunks with an empty `numbers` list and neither `auth_username`/`auth_password`
  nor `allowed_addresses`; dispatch rules for sensitive rooms with no `pin`; `allowed_numbers`
  treated as identity rather than a coarse filter
- Asterisk / FreeSWITCH contexts that accept anonymous SIP INVITEs and route them to the agent
- Pipecat or custom bot `/connect`, `/start`, `/offer` routes that create a room and return a
  join token to any unauthenticated caller
- Daily rooms created with public privacy, or tokens minted with `is_owner: true`
- Session sockets whose first message (`session.update`, `Settings`, `setup`) is accepted from
  any origin with no origin check on the upgrade
- Missing per-connection limits: the same socket accepting multiple `start` events, or one
  server process accepting unbounded concurrent streams (the cap itself is Cat 18)

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| unauthenticated-media-socket | A media-stream or session WebSocket processes audio or session messages with no verification of the connecting party | the upgrade handler file:line + the search for a signature, token, or per-call secret check | Critical |
| open-sip-trunk | An inbound SIP trunk or context accepts INVITEs with no provider credentials, no source-address restriction, and no number filter | the trunk or context config file:line | Critical |
| plaintext-transport | A stream, session, or custom-LLM socket URL is `ws://` or a SIP trunk carries media unencrypted in a non-loopback deployment | the URL or config file:line | High |
| host-derived-url | The stream URL handed to the carrier is built from the inbound request's `Host` header | the TwiML/NCCO builder file:line | High |
| open-session-starter | A room-creation or session-start route returns a join credential to any unauthenticated requester | the route file:line + its middleware chain | High |
| pin-less-sensitive-dispatch | A SIP dispatch rule routes to an agent that reaches account data with no PIN or in-conversation verification gate | the dispatch config + the agent's tool list | Medium |
| number-filter-as-identity | `allowed_numbers` or an inbound number list is the only control and is treated downstream as proof of who is calling | the trunk config + the downstream use | Medium (the downstream trust is Cat 05) |

### Actually Vulnerable

#### Critical
- A `/media-stream` or `/ws` handler that begins forwarding `media` payloads to the model on the
  first frame with no verification on the upgrade or on `start` / `setup`
- A SIP trunk with `numbers: []`, no `auth_username`, and no `allowed_addresses`, routed to an
  agent
- A custom-LLM socket reachable on the public internet with no secret in the path and no
  allowlist

#### High
- `ws://` in any production TwiML, NCCO, or stream configuration
- Stream URL built from `req.headers.host`
- `/connect` or `/start` returning a room token with no session guard
- A Daily room with public privacy used for phone calls

#### Medium
- Dispatch rule without a PIN in front of an agent with account tools
- `allowed_numbers` relied on as identity
- A per-call secret compared with ordinary string equality

### NOT Vulnerable
- The carrier's signature verified on the WebSocket upgrade with the same helper Cat 01 checks,
  quoted at the upgrade handler
- A per-call HMAC (call SID plus a server secret) passed as a stream `<Parameter>` and compared
  in constant time before any media is processed — quote the generation, the parameter, and
  the compare
- A stream URL built from a configured public origin (`PUBLIC_HOST`, `BASE_URL`) rather than the
  request
- LiveKit trunks with provider credentials or `allowed_addresses` set, and a dispatch rule
  PIN for rooms that reach account data — quote the trunk and the rule
- A custom-LLM socket bound to a private network, or reachable only through a secret path
  segment plus an IP allowlist matching the platform's published egress addresses
- `/connect` and `/start` inside the app's authenticated area, with the guard read
- A hosted platform that owns the media leg end to end and exposes no socket to the workspace —
  Skip, `not applicable`, with the search that established it

### Context Check
1. Where does audio actually enter this deployment? Trace the TwiML/NCCO/stream config to the
   handler, or the SIP trunk to the agent.
2. What must a connecting party present before the first media frame is acted on?
3. Is the transport encrypted end to end outside loopback?
4. How is the stream URL constructed, and can the request influence it?
5. For SIP, which of the three layers exist: trunk credentials or address restriction, dispatch
   PIN, in-conversation verification?
6. Who can call the session-starter routes, and what do they get back?

### Evidence Chain
- The stream, trunk, or session config file:line that points the carrier or client at the
  endpoint
- The handler's upgrade or first-message code file:line
- The verification performed there, or the search that established its absence with pattern and
  scope
- The transport scheme in every URL that reaches the endpoint
- For SIP, each layer read and its disposition

### Confidence Scoring
- **High**: the endpoint is confirmed as the audio ingress (config points at it) and the handler
  verifiably processes media before any check
- **Medium**: the endpoint looks like an ingress by path or event names, but the pointer is
  platform-side and not exported, or a verifying proxy may sit in front of it
- **Low**: the upgrade path could not be resolved (framework-injected middleware, dynamic
  routing) — tag `needs human verification`

### Severity
Critical is an open audio or session ingress: anyone can start or join a call. High is
plaintext transport, request-derived stream URLs, and open session starters. Medium is a missing
second layer in front of an otherwise authenticated trunk. Low is not used.

### Files to Check
- `**/media-stream*`, `**/stream*`, `**/ws*`, `**/websocket*`, `**/socket*`, `**/relay*`
- `**/twiml*`, `**/ncco*`, `**/sip/**`, `**/trunk*`, `**/dispatch*`, `pjsip.conf`, `sip.conf`,
  `**/sip_profiles/**`
- `**/connect*`, `**/start*`, `**/offer*`, `**/rooms*`
- `livekit.yaml`, `livekit.toml`, `**/livekit*`, `**/daily*`, `**/pipecat*`
- `.env*`, `**/config/**`

### Reference
- CWE-306: Missing Authentication for Critical Function
- CWE-319: Cleartext Transmission of Sensitive Information
- CWE-284: Improper Access Control
- Per-platform stream, trunk and session-endpoint auth: `references/stacks/<platform>.md`
