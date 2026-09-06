# Stack: ElevenLabs Agents (formerly Conversational AI)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

ElevenLabs Agents hosts the whole loop: speech-to-text, the model, tools and text-to-speech run on the vendor's side, and the repo holds a web or mobile client, a signed-URL broker, webhook tool receivers, and a post-call webhook consumer. Three facts drive the audit: a **public** agent needs only its `agent_id` to be run on your bill; the client SDK can override the prompt and first message when the agent allows it; and the default retention of recordings and transcripts is long. Read this before Cats 01, 03, 04, 10, 11, 12, 14, 21 run.

## Fingerprints

- Packages: `@elevenlabs/elevenlabs-js`, `@elevenlabs/client` (`Conversation.startSession`), `@elevenlabs/react` (`useConversation`), `@elevenlabs/react-native`, `elevenlabs` (PyPI: `Conversation`, `ConversationInitiationData`, `PrivacyConfig`), older `@11labs/client`, `@11labs/react`
- Env: `ELEVENLABS_API_KEY`, `ELEVEN_API_KEY`, `XI_API_KEY`, `ELEVENLABS_AGENT_ID`, `ELEVENLABS_WEBHOOK_SECRET`; `NEXT_PUBLIC_ELEVENLABS_AGENT_ID` is legitimate, `NEXT_PUBLIC_ELEVENLABS_API_KEY` is not
- Hosts and paths: `api.elevenlabs.io/v1/convai/`, `GET /v1/convai/conversation/get-signed-url?agent_id=`, `GET /v1/convai/conversation/token?agent_id=`, `wss://api.elevenlabs.io/v1/convai/conversation?agent_id=`, `POST /v1/convai/twilio/outbound-call`, `POST /v1/convai/sip-trunk/outbound-call`
- Headers: `xi-api-key`, `ElevenLabs-Signature`
- Keys: `signedUrl`, `conversationToken`, `agentId`, `clientTools`, `overrides`, `conversation_config_override`, `conversation_initiation_client_data`, `dynamic_variables`, `platform_settings.auth.enable_auth`, `platform_settings.auth.allowlist[].hostname`, `built_in_tools`, `prompt.tools[]`, `system_tool_type`, `transfer_to_number`, `transfer_to_agent`, `transfer_number`, `end_call`, `play_keypad_touch_tone`, `dtmf_tones`, `voicemail_detection`, `language_detection`, `skip_turn`, `update_state`, `first_message`, `agent_phone_number_id`, `to_number`
- Helpers: `getSignedUrl`, `get_signed_url`, `elevenlabs.webhooks.constructEvent`, `construct_event`

## Ingress and verification (H1)

- Post-call webhooks (transcription, audio, call-initiation-failure) carry `ElevenLabs-Signature: t=<ts>,v0=<hmac>`, HMAC-SHA256 with the webhook secret over the timestamp and body (format per the SDK; the official page names the helper rather than the wire format). Verify with `elevenlabs.webhooks.constructEvent(payload, signature, secret)` (JS) or `construct_event(...)` (Python); both check the timestamp. An optional egress-IP allowlist exists.
- Webhook tools (server-side tools the agent calls) authenticate with an auth connection configured in the workspace: OAuth2, JWT, basic, bearer, custom header, or mTLS, with per-environment variables. The receiver in the repo must check whichever one was configured; a receiver that checks nothing is Cat 12.
- Insecure shape: a `/elevenlabs/post-call` route reading `data.transcript` into a CRM with no `constructEvent`.

## Client authentication (H2)

- Safe browser credential: a signed URL from `get-signed-url` (about 15 minutes) for WebSocket, or a conversation token from `/conversation/token` for WebRTC — both minted server-side with the API key. A public agent (`enable_auth` off) can be started with `agentId` alone by any origin unless `allowlist[].hostname` (max 10, exact match) restricts it.
- Server-side only: the API key (`xi-api-key`).
- Anti-patterns: API key in a bundle (Cat 03); a signed-URL broker route with no user auth or rate limit — a private agent behind an open broker is effectively public (Cat 04); `enable_auth` off with no allowlist on an agent that has tools or costs money (Cat 04 posture, Medium, capped when dashboard-side); `overrides` / `conversation_config_override` supplying the prompt or first message from the client when the agent's security settings permit it (Cat 11).

## Tools (H6)

- Three kinds. **System tools** in `built_in_tools` / `prompt.tools[{type: "system"}]`: `end_call`, `language_detection`, `transfer_to_agent`, `transfer_to_number` (`transfer_number`, `client_message`, `agent_message`), `skip_turn`, `play_keypad_touch_tone` (`dtmf_tones`), `voicemail_detection`, `update_state`. **Webhook tools** run server-side with workspace-held secrets. **Client tools** are registered in code via `clientTools: { name: fn }` and execute in the browser or app — a client tool that mutates account state or calls a privileged API is Cat 12 / 13, because the caller's own device runs it.
- `transfer_to_number` with a model-filled `transfer_number` is Cat 14's unrestricted-destination row; with a fixed number it is a Pass.
- Secrets pasted inline into a webhook tool definition in an exported config are Cat 26.

## Call control (H7)

- Transfers: `transfer_to_number`, `transfer_to_agent`; DTMF via `play_keypad_touch_tone`; end via `end_call`.
- Outbound: `POST /v1/convai/twilio/outbound-call` and `/sip-trunk/outbound-call` with `agent_id`, `agent_phone_number_id`, `to_number`, `conversation_initiation_client_data`. An app route that takes `to_number` from a form is Cat 14 open-outbound-endpoint.
- Caller ID is the `agent_phone_number_id` resource. Country restrictions are workspace-side (Rule 6).

## Limits (H10)

- Max conversation duration and silence handling are per-agent dashboard settings (unverified names — confirm in the platform docs). Concurrency is workspace-side. Rule 6 Skips unless an exported agent config carries them.

## Recording, transcripts, retention, redaction (H9)

- Recordings and transcripts are stored by default; documented default retention is about two years. Per-agent Privacy settings control audio and transcript retention; Zero Retention Mode (per agent or enterprise-wide) stores neither. `PrivacyConfig` in the Python SDK.
- Post-call webhooks deliver the full transcript and analysis, and optionally the full-call audio as base64 — the app's consumer is where Cat 21 and 22 look.
- No transcript redaction feature documented on the pages read (unverified).

## Disclosure surfaces (H8)

- `first_message`, the agent prompt, `client_message` / `agent_message` on transfers, `voicemail_detection` message.

## What the platform already handles (do not flag)

- `constructEvent` / `construct_event` verify both signature and timestamp; do not ask for a separate replay window.
- A signed URL is short-lived and single-agent; do not flag its TTL.
- `enable_auth: true` with a broker behind the app's own login is the intended pattern; Pass with both quoted.
- Zero Retention Mode in an exported config is a Pass for Cat 21 storage rows.


## Workspace shapes

The broker that makes a private agent public:

```ts
app.get("/api/signed-url", async (_req, res) => {            // no session check, no rate limit
  const r = await fetch(`https://api.elevenlabs.io/v1/convai/conversation/get-signed-url?agent_id=${AGENT_ID}`,
    { headers: { "xi-api-key": process.env.ELEVENLABS_API_KEY! } });
  res.json(await r.json());
});
```

The guarded shape sits behind the app's own auth middleware and throttles per user. The client-side override that Cat 11 reads:

```ts
await Conversation.startSession({ signedUrl, overrides: { agent: { prompt: { prompt: promptFromPage }, firstMessage: greetingFromPage } } });
```

It only takes effect when the agent's security settings permit overrides — quote the exported setting or Skip under Rule 6. The post-call consumer, wrong and right:

```ts
app.post("/elevenlabs/post-call", express.raw({ type: "*/*" }), (req, res) => {
  const event = elevenlabs.webhooks.constructEvent(req.body.toString(), req.header("elevenlabs-signature"), process.env.ELEVENLABS_WEBHOOK_SECRET!);
  // wrong: JSON.parse(req.body) with no constructEvent, then crm.upsert(event.data.transcript)
});
```

## Trace hints

- Client tools run in the caller's own browser or app: `clientTools: { transferFunds: async ({ amount }) => api.post(...) }` is a consequential action the caller's device executes on the model's word — Cat 13.
- `dynamic_variables` passed in `conversation_initiation_client_data` land in prompt placeholders; resolve their source (client vs server).
- Outbound routes wrap `/twilio/outbound-call`; follow `to_number` back to its origin.
- The transcription webhook's `data.transcript[]` and the audio webhook's base64 payload are the Cat 21 and 22 sinks.

## Category quick map

| Cat | Row this stack most often fires on | Inherent Rule 6 Skips |
|---|---|---|
| 01 | post-call webhook consumer with no `constructEvent` | egress-IP allowlist |
| 03 | API key in a bundle | — |
| 04 | open signed-URL broker; public agent with no allowlist | `enable_auth` / allowlist when not exported |
| 10 | prompt carried in `overrides` from the client | prompt when only in dashboard |
| 11 | client `overrides` of prompt / first message | override permissions setting |
| 12 | webhook-tool receiver checking nothing; client tool that mutates state | auth-connection definition |
| 14 | `transfer_to_number` with a model-filled number; outbound route from a form | country restrictions |
| 17 | — | duration and silence settings |
| 21 | post-call audio and transcript forwarded to automation over unsigned URLs | retention / ZRM when not exported |
