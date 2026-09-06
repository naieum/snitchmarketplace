# Stack: Other frameworks and providers

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

One H2 per platform that appears often enough to fingerprint but not often enough to earn its own file. Each carries the same skeleton in compressed form. When a workspace fingerprints one of these alongside a carrier, read the carrier's file too — the carrier leg is where Cats 01, 02 and 14 usually land.

---

## Hume EVI

- **Fingerprints:** `hume` (npm, PyPI), `@humeai/voice-react`, `@humeai/voice-embed`; env `HUME_API_KEY`, `HUME_SECRET_KEY`, `HUME_CONFIG_ID`; `wss://api.hume.ai/v0/evi/chat?config_id=` with `api_key` or `access_token` query param; `fetchAccessToken`, `tool_call`, `tool_response`, `tool_error`, `builtin_tools` (`web_search`, `hang_up`).
- **Ingress (H1):** no inbound webhook of its own.
- **Client auth (H2):** server calls `fetchAccessToken({ apiKey, secretKey })` for a 30-minute token; the API key and secret key never ship. `?api_key=` in a browser socket URL is Cat 03.
- **Tools (H6):** Tool resources (name, JSON-schema parameters) attached to a Config; the app answers `tool_call` with `tool_response`. All execution is app-side — trace as any handler.
- **Call control (H7):** `hang_up` built-in; telephony via a carrier.
- **Limits / Recording (H9, H10):** chat history is stored by the vendor per config (unverified retention) — Rule 6.
- **Disclosure (H8):** the config's system prompt and first message.
- **Do not flag:** the access token's 30-minute TTL.

## Ultravox

- **Fingerprints:** `ultravox-client` (npm, PyPI, Flutter, Kotlin, Swift); env `ULTRAVOX_API_KEY`; `api.ultravox.ai/api/calls`, `/api/agents/{id}/calls`; header `X-API-Key`; response headers `X-Ultravox-Response-Type`, `X-Ultravox-Agent-Reaction`; keys `joinUrl`, `selectedTools[]`, `temporaryTool`, `modelToolName`, `dynamicParameters[].location` (`PARAMETER_LOCATION_BODY|QUERY|HEADER|PATH`), `staticParameters`, `automaticParameters` (`KNOWN_PARAM_CALL_ID`), `http.baseUrlPattern`, `requirements.httpSecurityOptions`, `authTokens`, `maxDuration`, `medium: { twilio: {} }`; built-ins `hangUp`, `queryCorpus`, `playDtmfSounds`, `leaveVoicemail`, `coldTransfer`, `warmTransfer`.
- **Ingress (H1):** tool webhooks are called by the vendor; auth is whatever `httpSecurityOptions` (`queryApiKey`, `headerApiKey`, `httpAuth`) requires. A temporary tool with no `httpSecurityOptions` is Cat 12.
- **Client auth (H2):** the browser joins with `joinUrl` from a server-created call; `ULTRAVOX_API_KEY` never ships. An app `/create-call` route with no auth mints join URLs for anyone (Cat 04).
- **Tools (H6):** `dynamicParameters` are model-filled; one with `location: PATH` or `QUERY` is an injection / SSRF surface (Cat 08). `staticParameters` and `automaticParameters` are the server-trusted channel (Cat 12 Pass shape).
- **Call control (H7):** `coldTransfer` / `warmTransfer` with a model-filled number is Cat 14; `playDtmfSounds` is the DTMF sink. Twilio carries the leg via `<Connect><Stream url="{joinUrl}">`.
- **Limits (H10):** `maxDuration` on the call; unset is Cat 17 with the request builder quoted.
- **Recording (H9):** transcripts and optional recordings held by the vendor; retention dashboard-side (Rule 6).
- **Disclosure (H8):** `systemPrompt`, `initialMessages`.

## Cartesia (TTS, Line agents)

- **Fingerprints:** `cartesia` (PyPI), `@cartesia/cartesia-js`, `cartesia-line` / `line`; env `CARTESIA_API_KEY`; `wss://api.cartesia.ai/tts/websocket`; headers `X-API-Key`, `Cartesia-Version`; model names `sonic-`.
- **Role:** usually the TTS leg in a LiveKit or Pipecat cascade; Line agents run on the vendor's infrastructure with Python tools.
- **Cats:** `CARTESIA_API_KEY` in a client (Cat 03); TTS of unbounded model output (Cat 19); voice cloning of the business's own voice is a brand-impersonation observation for Cat 05, not a code finding.

## AssemblyAI (streaming STT)

- **Fingerprints:** `assemblyai` (PyPI, npm); env `ASSEMBLYAI_API_KEY`; `wss://streaming.assemblyai.com/v3/ws?sample_rate=…&token=…`; `create_temporary_token(expires_in_seconds=…)`, `POST /v2/realtime/token`; `redact_pii`, `redact_pii_policies`, `redact_pii_sub` (`entity_name` | `hash`), `redact_pii_audio`.
- **Client auth (H2):** temporary token from the server; the API key in a browser socket URL is Cat 03.
- **Redaction (H9):** `redact_pii` is a Cat 22 control when quoted; `redact_pii_audio` applies to batch, not streaming (unverified for streaming).

## Jambonz

- **Fingerprints:** `@jambonz/node-client`, `@jambonz/node-client-ws`; env `JAMBONZ_ACCOUNT_SID`, `JAMBONZ_API_KEY`, `JAMBONZ_REST_API_BASE_URL`, `WEBHOOK_SECRET`; header `Jambonz-Signature`; verbs `session.llm(`, `dial`, `gather`, `transcribe`, `sip:refer`; `toolHook`, `actionHook`, `eventHook`, `session.updateLlm`, `llmOptions.session_update.instructions|tools`, `auth.apiKey`.
- **Ingress (H1):** Express middleware `WebhookResponse.verifyJambonzSignature(process.env.WEBHOOK_SECRET)` registered after body parsing. Missing it is Cat 01.
- **Tools (H6):** tool calls arrive at `toolHook` as `{name, args, tool_call_id}`; the app answers with a `function_call_output` item through `session.updateLlm`. Trace `args` as model-filled. `auth.apiKey` for the LLM vendor is serialized into the verb — a literal is Cat 26.
- **Call control (H7):** `dial` with a `target` built from `args` is Cat 14; `sip:refer` is the transfer primitive.
- **Recording (H9):** `transcribe` and call recording are app-configured; off by default.

## Vocode

- **Fingerprints:** `vocode` (PyPI); `TelephonyServer`, `TwilioConfig(account_sid, auth_token)`, `VonageConfig`, `InboundCallConfig`, `StreamingConversation`, `BaseAction`, `EndConversation`, `TransferCall`, `TransferCallActionUpdateParams`; routes `/inbound_call`, `/connect_call/{id}` (WebSocket); Redis for call state; `outbound_call.py` with `to_phone`, `from_phone`.
- **Ingress (H1):** the telephony server serves the carrier's webhook; signature checking is the app's job (see the carrier file). The `/connect_call/{id}` socket accepts any client that knows the id (Cat 02).
- **Tools (H6):** actions subclass `BaseAction`; `TransferCall` takes a phone number from the action parameters — model-filled unless fixed (Cat 14).
- **Recording (H9):** transcripts live in the app's logs and Redis; whatever is written is the record.

## Asterisk / FreeSWITCH

- **Fingerprints:** `ari-client` (npm), `asterisk-ari`, `aioari` (PyPI), `esl` (npm), `greenswitch` (PyPI); env `ARI_URL`, `ARI_USERNAME`, `ARI_PASSWORD`, `ASTERISK_ARI_*`, `FREESWITCH_PASSWORD`, `ESL_PASSWORD`; ports `:8088/ari`, `:8090` (AudioSocket), `:8021` (ESL); `StasisStart`, `externalMedia`, `AudioSocket`, `mod_audio_stream`, `mod_audio_fork`, `ari.conf`, `extensions.conf`, `originate`, `uuid_bridge`, `sofia`.
- **Ingress (H1, H2):** AudioSocket has no authentication in the protocol; a listener bound to `0.0.0.0` with no network control is Cat 02 High. ARI and ESL credentials in `ari.conf` or YAML in the repo are Cat 26.
- **Call control (H7):** dialplan `Dial()` targets, ARI `originate` / `channels.create`, ESL `originate` built from model output are Cat 14 unrestricted-destination.
- **Limits (H10):** `L()` option on `Dial()`, `absolute_codec_string` irrelevant; `TIMEOUT(absolute)` sets max duration (unverified exact names — confirm in the platform docs).
- **Recording (H9):** `MixMonitor` / `record_session`; files on disk with whatever permissions the box has.

## Kyutai Moshi / Unmute

- **Fingerprints:** `moshi` (PyPI), `moshi_mlx`, Rust `moshi-server`, `unmute` docker-compose (backend, STT, TTS, LLM via vLLM); `Mimi`.
- **Ingress / client (H1, H2):** the browser talks to the backend over a WebSocket with no auth built in; self-hosted, so exposed socket and model-server ports with no auth are Cat 02 High. Everything else is the app's own code.

## Synthflow

- **Fingerprints:** REST only; env `SYNTHFLOW_API_KEY`; `api.synthflow.ai/v2/`; `Authorization: Bearer`; keys `model_id`, `phone`, `name`, `custom_variables`, `external_webhook_url`, `call_inbound`; webhook payload `call.transcript`, `call.recording_url`, `collected_variables`; Custom Actions as HTTP calls with headers.
- **Ingress (H1):** post-call webhooks are documented as HMAC-verifiable but the scheme is on a separate security page not read (unverified — confirm in the platform docs); a consumer with no check is Cat 01 at Medium confidence.
- **Tools (H6):** Custom Actions carry headers; empty headers is Cat 12.
- **Call control (H7):** outbound `phone` from a form is Cat 14.
- **Recording (H9):** `recording_url` in the webhook; retention dashboard-side.

## PolyAI

- **Fingerprints:** REST only; hosts `api.{region}.poly.ai`, `api.{region}-1.platform.polyai.app`; header `x-api-key`; env `POLYAI_API_KEY`.
- **Notes:** keys are region- and scope-bound and the vendor's docs say never to embed them client-side (Cat 03). Webhooks are described as signed POSTs, header not documented on the overview page (unverified) — Cat 01 at Medium confidence for an unchecked consumer.

## Sierra

- **Fingerprints:** `sierra` SDK imports; agents are code-defined and deployed through CI.
- **Notes:** no public webhook signature spec surfaced. Treat as an enterprise platform where auth and tools are defined in-platform; audit the repo's own webhook receivers under Cat 01 with confidence capped at Medium, and Rule 6 Skip the platform side.

## xAI voice (OpenAI-Realtime-compatible)

- **Fingerprints:** `wss://api.x.ai/v1/realtime?model=grok-voice-…`; env `XAI_API_KEY`; browser subprotocol `xai-client-secret.{token}`; `session.update` with `instructions`, `tools` (`function`, `web_search`, `x_search`, `file_search`, `mcp`), `audio.input.format.type` (`audio/pcmu` for telephony); `response.function_call_arguments.done` → `function_call_output`.
- **Cats:** the same shape as the OpenAI Realtime stack file — API key in a bundle (Cat 03), open ephemeral-token endpoint (Cat 04), client-sent `session.update` changing instructions or tools (Cat 11), `mcp` (snitch-security Cat 45).

## Anthropic as the text LLM in a cascade

- **Fingerprints:** `@anthropic-ai/sdk`, `anthropic` (PyPI); env `ANTHROPIC_API_KEY`; header `x-api-key`; Messages API `tools`, `tool_use`, `tool_result` blocks next to any STT/TTS fingerprint (a carrier's ConversationRelay, LiveKit or Pipecat plugins).
- **Notes:** no speech-to-speech or realtime audio API as of the verification date; the model sits behind the app's own transcript loop. Cats 07–10 apply to the app's prompt assembly; the tool loop is the app's (Cats 12–16). Key in a client is Cat 03.

## Groq cascades

- **Fingerprints:** `groq`, `groq-sdk`; env `GROQ_API_KEY`; `api.groq.com/openai/v1/audio/transcriptions|speech`; model names `whisper-large-v3`, `playai-tts`.
- **Notes:** STT and TTS endpoints plus a fast LLM, no realtime socket; the app owns the loop. The STT `prompt` parameter fed from caller text is Cat 07's ASR-prompt row. Key in a client is Cat 03.

---


## Reading a self-built cascade

Several of the platforms above, and every "Anthropic or Groq behind a carrier" repo, are cascades the app owns end to end: carrier socket → STT → transcript loop → model → tool loop → TTS → carrier socket. There is no vendor dashboard to Skip to, so every hop is in the workspace and every posture row has code to quote. Where each hop lives:

| Hop | Look for |
|---|---|
| H1 | the carrier's webhook route and the media socket route (carrier file) |
| H2 | any place `From`, `CallerName`, SIP headers, or a client token becomes an identity; the STT vendor key placement |
| H3 | the STT client call and its options: `prompt` / `initial_prompt` / `keyterms` / `hints` (caller text in these is Cat 07), `redact` (Cat 22), language lock |
| H4 | the function that builds `messages[]` — where the system prompt is read from, and every `${...}` in it |
| H5 | any read from a store between turns (CRM, calendar, prior transcripts) that lands in `messages[]` |
| H6 | the `while tool_calls` loop and the map from tool name to handler; argument parsing |
| H7 | the carrier SDK calls the handlers make (`calls.create`, `<Dial>`, `sendDigits`, `messages.create`) |
| H8 | the TTS call: what text reaches it, and whether anything filters tool JSON or error strings before it |
| H9 | every `log`, `print`, database write, or bucket upload that takes transcript or audio |
| H10 | the loop's turn counter, the socket's idle timer, `max_tokens`, the per-call cost accumulator, and the `except` branches around STT/LLM/TTS calls |

A cascade repo that logs every socket message to stdout has already answered Cat 21.

## Category quick map (this file)

| Cat | Where it fires across these platforms | Inherent Rule 6 Skips |
|---|---|---|
| 01 | Jambonz without `verifyJambonzSignature`; Synthflow / PolyAI / Sierra consumers with no check (Medium confidence) | Synthflow / PolyAI / Sierra signature schemes |
| 02 | Vocode `/connect_call/{id}`; AudioSocket on `0.0.0.0`; Unmute sockets; Hume `?api_key=` sockets | — |
| 03 | any vendor key in a bundle; Hume / AssemblyAI / Cartesia keys in browser socket URLs | — |
| 04 | Ultravox `/create-call` or Hume token routes with no auth | — |
| 08 | Ultravox `dynamicParameters` in `PATH` / `QUERY`; Jambonz `args` into URLs | — |
| 12 | Ultravox tools with no `httpSecurityOptions`; Synthflow actions with empty headers | — |
| 14 | Ultravox transfers, Vocode `TransferCall`, Jambonz `dial`, Asterisk `originate` with model-filled targets | — |
| 17 | Ultravox `maxDuration` unset; Asterisk `Dial()` with no `L()` | vendor-side duration settings |
| 22 | AssemblyAI without `redact_pii` when card or health data is expected | — |
| 26 | `ari.conf` / ESL credentials committed; Jambonz `auth.apiKey` literals | — |
