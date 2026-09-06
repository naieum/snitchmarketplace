# Stack: OpenAI Realtime API (Realtime, Agents SDK realtime, SIP, Twilio transport)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

The Realtime API is a speech-to-speech model reached over WebSocket (server) or WebRTC
(browser), plus a SIP endpoint that turns a phone call into a Realtime session. The agent's
prompt, tools, and limits are whatever the app sends in `session.update` or binds into a client
secret — there is no dashboard to Skip to. The two recurring defects are a standard key reaching
a client and a client being allowed to rewrite the session it was handed.

## Fingerprints

- Packages: `openai` (npm, PyPI), `@openai/agents`, `@openai/agents-realtime`,
  `@openai/agents-extensions` (`TwilioRealtimeTransportLayer`), `openai-agents` (PyPI:
  `RealtimeAgent`, `RealtimeRunner`), older `@openai/realtime-api-beta`
- Env: `OPENAI_API_KEY`, `OPENAI_WEBHOOK_SECRET`
- Hosts and paths: `wss://api.openai.com/v1/realtime?model=gpt-realtime`,
  `POST /v1/realtime/client_secrets`, `POST /v1/realtime/calls` (WebRTC SDP),
  `/v1/realtime/calls/{call_id}/accept|reject|refer|hangup` (SIP),
  `sip:proj_…@sip.api.openai.com;transport=tls`, older `/v1/realtime/sessions`
- Headers: `Authorization: Bearer sk-…` (server) or `Bearer ek_…` (client); older
  `OpenAI-Beta: realtime=v1`; webhooks `webhook-id`, `webhook-timestamp`, `webhook-signature`;
  `OpenAI-Safety-Identifier`
- Model names: `gpt-realtime`, `gpt-4o-realtime-preview` (older)
- Events and classes: `session.update`, `session.tools`, `session.instructions`,
  `response.function_call_arguments.done`, `conversation.item.create` with
  `function_call_output`, `response.create`,
  `conversation.item.input_audio_transcription.completed`, `realtime.call.incoming`,
  `webhooks.unwrap(`, `RealtimeAgent`, `RealtimeSession`, `OpenAIRealtimeWebSocket`,
  `OpenAIRealtimeSIP`, `dangerouslyAllowBrowser`
- xAI's voice endpoint is API-compatible: `wss://api.x.ai/v1/realtime?model=grok-voice-…`,
  `XAI_API_KEY`, browser subprotocol `xai-client-secret.{token}`. The same rows apply.

## Ingress and verification (H1)

- **SIP**: an inbound call to the project's SIP URI produces a `realtime.call.incoming`
  webhook. Headers follow the Standard Webhooks convention (`webhook-id`,
  `webhook-timestamp`, `webhook-signature` as `v1,<base64>`), HMAC-SHA256 with the project's
  signing secret. Verify with `client.webhooks.unwrap(rawBody, headers)` and
  `OPENAI_WEBHOOK_SECRET`; the SDK checks the timestamp window. Then `accept` the call with the
  session config, or `reject`.
- **Telephony via a carrier**: the carrier's Media Streams socket is bridged to the Realtime
  socket in your server (the vendor's own sample and the Agents SDK Twilio extension). The
  carrier's signature on the TwiML route and the media handshake is the carrier's stack file;
  the vendor's samples do not verify it.
- **Browser**: the client posts an SDP offer to `/v1/realtime/calls` with the ephemeral key;
  no webhook is involved.

Insecure shape (the vendor's carrier sample):

```js
fastify.get('/media-stream', { websocket: true }, (conn) => {   // no signature on the handshake
  const openAiWs = new WebSocket('wss://api.openai.com/v1/realtime?model=gpt-realtime',
    { headers: { Authorization: `Bearer ${OPENAI_API_KEY}` } });
  openAiWs.on('open', () => openAiWs.send(JSON.stringify({ type: 'session.update', session: { instructions: SYSTEM_MESSAGE } })));
});
```

Pitfalls: a `/webhook` route that reads `event.type` before `unwrap`; `express.json()` ahead of
`unwrap`; the media route accepting any client.

## Client authentication (H2)

- Safe browser credential: an ephemeral client secret (`ek_…`) minted server-side with
  `POST /v1/realtime/client_secrets`, whose body carries the `session` config (model,
  `instructions`, `tools`, `expires_after`). The secret is bound to that config; the browser
  uses it as `Authorization: Bearer ek_…`.
- Must stay server-side: `sk-…` keys. The vendor's docs say so plainly.
- Mint endpoint: your `/session`, `/token`, or `/client-secret` route. Cat 04 reads it for: a
  user or session check; a rate limit; `expires_after` set and short; the `session` config
  (instructions and tools) set server-side, not echoed from the request body;
  `OpenAI-Safety-Identifier` set from the authenticated user; CORS not `*`.
- Session override: even with a bound secret, a client can send `session.update` over its own
  connection. Whether that can change `instructions` and `tools` after minting is the
  vendor's behavior to confirm (unverified — confirm in the platform docs); the app-side
  control is a server-relayed connection where the browser never holds the socket, or a
  server that ignores client-originated `session.update`. Cat 11 reads for the browser
  sending `session.update` with `instructions` or `tools`.
- Anti-patterns: `new OpenAI({ apiKey, dangerouslyAllowBrowser: true })`;
  `NEXT_PUBLIC_OPENAI_API_KEY`; `Authorization: Bearer sk-` in a client bundle; a mint route
  with no `expires_after`; a mint route that accepts `instructions` from the client.

## Tools (H6)

- Definition: `session.update` with `session.tools: [{ type: "function", name, description,
  parameters }]` (or per-turn `response.tools`); the model emits
  `response.function_call_arguments.done` with `call_id` and JSON `arguments`; the app runs
  the tool and returns `conversation.item.create` `{ type: "function_call_output", call_id,
  output }` then `response.create`. Agents SDK: `tool({ name, parameters, execute })` on a
  `RealtimeAgent`. MCP servers attach with `type: "mcp"` (hand off supply chain to
  snitch-security).
- Execution is in your process (server-relayed) or in the browser (WebRTC with client-side
  tools). A browser-executed tool that calls your backend is an authenticated-API question;
  a server-executed tool acting on `arguments` is Cat 12 / 13. Every argument is LLM-filled.
- Dangerous shapes: any tool whose handler dials, transfers (SIP `refer`), hangs up, pays,
  sends, or mutates an account on `arguments` alone.

## Call control (H7)

- SIP: `POST /v1/realtime/calls/{call_id}/refer` with `target_uri` (`tel:` or `sip:`) is the
  transfer; `/hangup` ends; `/accept` starts the session with the config; `/reject` declines.
  A `refer` whose `target_uri` comes from a tool argument is Cat 14
  `unrestricted-destination`.
- Carrier-bridged: dial, transfer, and DTMF are the carrier's primitives (see that stack file).
- No caller-ID selection and no geo permission at this layer; the SIP trunk provider or the
  carrier holds them (Rule 6 Skip unless exported).

## Limits (H10)

- Session length: a Realtime session has a maximum duration set by the vendor (unverified
  value — confirm in the platform docs); the app-side cap is a timer that closes the socket or
  hangs up the SIP call (Cat 17).
- Silence and idle: `turn_detection` settings decide turns; an idle timeout is app code.
- Spend: `max_output_tokens` on `response.create` / `session.update` bounds one response;
  there is no per-session budget primitive. Account spend limits are platform-side (Rule 6
  Skip). `OpenAI-Safety-Identifier` supports per-user abuse tracking on the vendor's side.
- Concurrency: the org's rate limits are platform-side; an app-side cap on open sockets or
  in-flight SIP calls is Cat 18.

## Recording, transcripts, retention, redaction (H9)

- Nothing is recorded by the API. Transcripts arrive as
  `conversation.item.input_audio_transcription.completed` (when input transcription is
  enabled) and as `response.audio_transcript.*` events; anything durable is the app's write.
  Logging every event to stdout is the common Cat 21 finding.
- Retention: the vendor's API data-retention default and Zero Data Retention eligibility are
  platform-side and account-level (unverified specifics — confirm in the platform docs); a
  workspace claim of ZDR with no evidence is a Skip, not a Pass.
- No redaction at this layer; redact before the write (Cat 22).
- SIP call audio: not recorded by the vendor unless the app records it elsewhere (unverified —
  confirm in the platform docs).

## Disclosure surfaces (H8)

- `session.instructions` in the `session.update` or the bound `client_secrets` config, the
  Agents SDK `RealtimeAgent({ instructions })`, and the first `response.create` with
  `instructions` used as the greeting. Cat 23 and 24 grep these; on SIP the `accept` body
  carries them.

## What the platform already handles (do not flag)

- An `ek_…` secret bound to a server-set `session` config carries the instructions and tools
  with it; do not flag the browser "receiving the prompt" when only the secret is sent.
- `webhooks.unwrap` verifies signature and timestamp; do not demand a second check.
- Media over WebRTC and TLS SIP is encrypted; transport is not a finding.
- The API does not persist audio; do not file a recording finding against the vendor when
  the workspace holds no recording write.

## Category quick map

| Cat | Where this stack most often fires | Inherent Rule 6 Skips |
|---|---|---|
| 01 | `realtime.call.incoming` route without `webhooks.unwrap`; carrier TwiML route unverified | — |
| 02 | carrier media socket bridged with no handshake check | — |
| 03 | `sk-` key or `dangerouslyAllowBrowser` in a client | — |
| 04 | mint route without auth, rate limit, or `expires_after`; instructions taken from the client | — |
| 07 | input transcription events concatenated into `instructions` | — |
| 11 | browser sending `session.update` with `instructions` or `tools` | vendor behavior on post-mint overrides |
| 12, 13 | tool handlers acting on `arguments` with no authorization or confirmation | — |
| 14 | SIP `refer` with a caller-influenced `target_uri` | trunk-side geo permissions |
| 16 | `function_call_output` filled with raw errors or stack traces | — |
| 17, 18, 19 | no socket/call timer, no open-session cap, no `max_output_tokens` | org rate and spend limits, session max duration |
| 21, 22 | every event logged; no redaction before the write | ZDR eligibility |
| 23, 24 | `instructions` lacking the announcement or disclosure | — |
| 26 | tunnel URLs in the carrier TwiML; the vendor's sample shipped unchanged | — |
