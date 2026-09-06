# Stack: Carriers (Vonage, Telnyx, Plivo, SignalWire, Bandwidth)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Five carriers that sit where Twilio usually sits. Each signs or authenticates its callbacks differently, and each has a Twilio-shaped XML dialect or a JSON call-control API with the same three sinks: a dial destination, a media socket URL, and a record flag. Read the H2 for the carrier detected before Cats 01, 02, 14, 17, 21 run.

---

## Vonage (Voice API, NCCO)

### Fingerprints
- Packages: `@vonage/server-sdk`, `@vonage/voice`, `@vonage/auth`, `@vonage/jwt`, `vonage` (PyPI), `vonage-ruby-sdk`, legacy `nexmo`
- Env: `VONAGE_API_KEY`, `VONAGE_API_SECRET`, `VONAGE_APPLICATION_ID`, `VONAGE_APPLICATION_PRIVATE_KEY`, `VONAGE_PRIVATE_KEY_PATH`, `VONAGE_API_SIGNATURE_SECRET`; a committed `private.key` file
- Hosts and paths: `api.nexmo.com`; routes `/answer`, `/event`, `/webhooks/answer`, `/webhooks/events`
- NCCO keys: `"action": "connect"`, `endpoint[].type: "websocket"`, `uri`, `content-type`, `headers`, `onAnswer`, `machineDetection`, `advancedMachineDetection`, `timeout`, `limit`, `record`, `eventUrl`, `endOnSilence`, `split`, `channels`, `transcription`, `input` with `dtmf` / `speech`

### Ingress and verification (H1)
- Scheme: `Authorization: Bearer <JWT>`, HS256 signed with the account signature secret; claims include `api_key`, `payload_hash` (SHA-256 of the raw body), `iat`, `jti`. Verify the JWT and compare `payload_hash` against the body actually received.
- Helpers: `verifySignature` from `@vonage/jwt`; Python `verify_signature`; or any JWT library against `VONAGE_API_SIGNATURE_SECRET`.
- Signed webhooks are on by default for new Voice applications; older applications need the "use signed webhooks" toggle, which is dashboard-side (Rule 6 Skip when no export).
- Insecure shape: an `/answer` route that returns an NCCO and an `/event` route that updates call state, neither reading the bearer header. Most tutorials look like this.

### Client authentication (H2)
- Browser calling uses the Client SDK with a JWT minted server-side from the application private key. The private key must not ship to a client; `private.key` committed to the repo is Cat 26.

### Tools (H6)
- No tool schema; the app's model owns tools. The NCCO `connect` websocket `headers` object is sent to the app's socket — data the app must not treat as identity (Cat 08).

### Call control (H7)
- `voice.createOutboundCall({ to: [{type:'phone', number}], from, ncco | answer_url })`; in-call `transfer` action; NCCO `connect` to a phone endpoint. Destination fields: `to[].number`, `endpoint[].number`. Caller ID: `from.number`.
- Country restrictions are account-side (Rule 6).

### Limits (H10)
- NCCO `limit` (max leg seconds, up to 7200); `timeout` is ring time. `endOnSilence` on `record`. Concurrency is account-side.

### Recording, transcripts, retention, redaction (H9)
- Off unless a `record` action or `record` on `connect` is present; recordings are fetched from a URL delivered to `eventUrl` and require app JWT auth to download. `transcription` on `record` produces a transcript delivered by webhook; no redaction option (unverified — confirm in the platform docs).

### Disclosure surfaces (H8)
- A `talk` action before `connect` or `record`.

### What the platform already handles
- Recording download requires the application JWT; do not flag "public recording URL" on Vonage without evidence the app re-hosts it.

---

## Telnyx (Call Control, TeXML)

### Fingerprints
- Packages: `telnyx` (npm, PyPI), `github.com/team-telnyx/telnyx-go`, `@telnyx/webrtc`
- Env: `TELNYX_API_KEY`, `TELNYX_PUBLIC_KEY`, `TELNYX_CONNECTION_ID`
- Hosts and paths: `api.telnyx.com/v2/calls`, `/v2/calls/{call_control_id}/actions/answer|transfer|hangup|record_start|send_dtmf|streaming_start`
- Headers: `telnyx-signature-ed25519`, `telnyx-timestamp`, `x-telnyx-call-control-id`
- Keys: `call_control_id`, `webhook_url`, `answering_machine_detection`, `time_limit_secs`, `record`, `record_channels`, `stream_url`, `stream_bidirectional_mode`, `send_dtmf`; TeXML is Twilio-compatible XML

### Ingress and verification (H1)
- Scheme: Ed25519 signature over `{telnyx-timestamp}|{raw body}`, verified with the account **public key** (asymmetric; no shared secret). The vendor documents a five-minute tolerance.
- Helpers: Node `client.webhooks.unwrap(rawBody, { headers })` (throws on mismatch), `client.webhooks.unsafeUnwrap(body)` skips verification and is a grep target; Python `telnyx.Webhook.construct_event(...)` (unverified exact name — confirm in the platform docs).
- The fail-open shape: verification wrapped in `if (publicKey)` so an unset `TELNYX_PUBLIC_KEY` silently accepts everything. A widely used open-source voice plugin shipped exactly this in 2026 and received a CVE; a `skipSignatureVerification` flag is now dev-only there. Flag any branch that skips the check when the key is absent (Cat 01 verification-disabled).
- Insecure shape: a Call Control webhook that issues `answer` / `transfer` commands on `event_type` without `unwrap`.

### Client authentication (H2)
- WebRTC clients use a JWT minted server-side for a telephony credential; `TELNYX_API_KEY` never ships.

### Tools (H6)
- Telnyx AI Assistants support webhook tools in sync and async modes; async requests carry `x-telnyx-call-control-id`. Tool webhook auth is configured per tool (unverified — confirm in the platform docs). Self-built agents own their tools.

### Call control (H7)
- `calls.create({ to, from, connection_id, webhook_url, time_limit_secs, record, answering_machine_detection })`; `transfer` action with `to`; `send_dtmf` with `digits`. Destination fields: `to`. Caller ID: `from`.
- Outbound geography is a connection/account setting (Rule 6).

### Limits (H10)
- `time_limit_secs` (hangup cause `time_limit`); no silence timeout on the API — app-side. Concurrency per connection is account-side.

### Recording, transcripts, retention, redaction (H9)
- Off unless `record: "record-from-answer"` or `record_start`; recordings retrieved via API with the API key. No transcript redaction option documented on the pages read (unverified).

### Disclosure surfaces (H8)
- A `speak` action before `transfer` / `record_start`; TeXML `<Say>`.

### What the platform already handles
- Ed25519 means the signing key cannot leak from your repo; a Cat 03 finding on `TELNYX_PUBLIC_KEY` is wrong — it is public by design. `TELNYX_API_KEY` is the secret.

---

## Plivo

### Fingerprints
- Packages: `plivo` (npm, PyPI), `plivo-go`
- Env: `PLIVO_AUTH_ID`, `PLIVO_AUTH_TOKEN`
- Hosts and paths: `api.plivo.com`; routes `/answer`, `/hangup`, `/answer_url`
- Headers: `X-Plivo-Signature-V3`, `X-Plivo-Signature-V3-Nonce`, `X-Plivo-Signature-Ma-V3`
- XML: `<Response><Stream bidirectional="true">wss://…</Stream>`, `<Record>`, `<Dial>`; call params `from`, `to`, `answer_url`, `hangup_url`, `machine_detection`, `machine_detection_time`, `machine_detection_url`, `ring_timeout`, `time_limit`

### Ingress and verification (H1)
- Scheme: HMAC-SHA256 over URL + sorted params + nonce, keyed with the Auth Token; multiple tokens produce comma-separated `X-Plivo-Signature-Ma-V3`. V2 is deprecated — a repo still on V2 is Cat 01 verification-weakened.
- Helpers: Node `plivo.validateV3Signature(method, uri, nonce, authToken, signature, params)`; Python `plivo.utils.validate_v3_signature`; Go `plivo.ValidateSignatureV3`; Java `Utils.validateSignatureV3`; Ruby `Plivo::Utils.valid_signatureV3?`.
- URL-bound, so the same proxy-mismatch pitfall as Twilio applies.
- Insecure shape: `/answer` returning XML with `<Dial>` and no V3 check.

### Client authentication (H2)
- Browser SDK uses endpoint credentials created server-side; `PLIVO_AUTH_TOKEN` never ships.

### Tools (H6)
- None of its own; the app's model owns tools.

### Call control (H7)
- `calls.create(from, to, answer_url, { time_limit, ring_timeout, machine_detection })`; `<Dial><Number>`; `<Stream>` URL. Destination: `to`, `<Number>` body. Caller ID: `from`. Country permissions are account-side (Rule 6).

### Limits (H10)
- `time_limit` (seconds); `ring_timeout` is ring time. Silence handling is app-side. Concurrency account-side.

### Recording, transcripts, retention, redaction (H9)
- Off unless `<Record>` or the record API; recording URLs delivered by callback; no redaction option documented (unverified).

### Disclosure surfaces (H8)
- `<Speak>` before `<Record>` / `<Dial>`.

---

## SignalWire (Compatibility API, SWML, SWAIG)

### Fingerprints
- Packages: `@signalwire/compatibility-api`, `@signalwire/realtime-api`, `@signalwire/js`, `signalwire` (PyPI), `signalwire-agents` (PyPI: `AgentBase`, `define_tool`, `set_web_hook_url`, `on_function_call`)
- Env: `SIGNALWIRE_PROJECT_ID`, `SIGNALWIRE_TOKEN`, `SIGNALWIRE_API_TOKEN`, `SIGNALWIRE_SPACE_URL`, `SWML_BASIC_AUTH_USER`, `SWML_BASIC_AUTH_PASSWORD` (unverified)
- Hosts: `*.signalwire.com`
- Headers: `x-signalwire-signature`
- SWML / SWAIG keys: `"ai"` verb, `SWAIG.defaults.web_hook_url`, `web_hook_auth_user`, `web_hook_auth_password`, `functions[].function`, `parameters`, per-function `web_hook_url`, `data_map`, `includes[].url`, `native_functions`

### Ingress and verification (H1)
- Compatibility API: `x-signalwire-signature`, HMAC with a per-project signing key from the dashboard; helpers `RestClient.validateRequest(signingKey, header, url, body)` and the Twilio-shaped `webhook()` middleware, which breaks behind tunnel URL rewriting in the same way.
- SWML endpoints that serve the `ai` verb are usually protected by HTTP basic auth (`SWML_BASIC_AUTH_*`); an SWML server with neither basic auth nor signature check is Cat 01 unverified-route.

### Client authentication (H2)
- Browser calling uses a token from the realtime API minted server-side; the project token never ships.

### Tools (H6)
- SWAIG functions are the tool schema. Auth is `web_hook_auth_user` / `web_hook_auth_password` (HTTP basic) on the function webhook, set in `defaults` or per function. A function with no `web_hook_auth_*` is Cat 12 unauthenticated tool webhook; an `http://` `web_hook_url` is Cat 26. `data_map` calls an API with no webhook, and `includes[].url` pulls remote function manifests — treat as supply chain and hand to snitch-security Cat 45. `native_functions` (`check_time`, `wait_seconds`, `wait_for_user`, `adjust_response_latency`) are low risk except `wait_seconds` in loops (Cat 17).

### Call control (H7)
- Compatibility `<Dial>` and `calls.create` mirror Twilio; SWML `connect` and `transfer`. Destination and caller-ID fields mirror Twilio. Country permissions are space-side (Rule 6).

### Limits (H10)
- Compatibility `timeLimit` mirrors Twilio; SWML `ai` verb has its own conversation limits (unverified — confirm in the platform docs).

### Recording, transcripts, retention, redaction (H9)
- Off unless `record` is set; SWML `ai` conversations produce a post-conversation summary and transcript delivered to a webhook (unverified detail).

### Disclosure surfaces (H8)
- `ai.prompt.text`, `ai.params.static_greeting` (unverified name), `<Say>` in compatibility XML.

---

## Bandwidth

### Fingerprints
- Packages: `bandwidth-sdk` (npm, PyPI), older `@bandwidth/voice`
- Env: `BW_ACCOUNT_ID`, `BW_USERNAME`, `BW_PASSWORD`, `BW_VOICE_APPLICATION_ID`, `BW_NUMBER`
- Hosts: `voice.bandwidth.com`
- BXML: `<StartStream destination="wss://…" mode="bidirectional">`, `<Transfer>`, `<Record>`, `<Gather>`; `machineDetection` object with `mode`, `callbackUrl`, `machineDetectionComplete`
- Pipecat has a `BandwidthFrameSerializer`

### Ingress and verification (H1)
- No signature. The Voice application is configured with a callback username and password, and every callback carries `Authorization: Basic`. The check is that the callback route enforces basic auth against those credentials; a route that reads the body without it is Cat 01 unverified-route, and an IP allowlist alone is the ip-only row.

### Client authentication (H2)
- WebRTC clients use tokens minted server-side; `BW_PASSWORD` never ships.

### Tools (H6)
- None of its own.

### Call control (H7)
- Create call with `to`, `from`, `applicationId`, `answerUrl`; `<Transfer><PhoneNumber>` in BXML. Destination: `to`, `<PhoneNumber>` body. Caller ID: `from`. Geography is account-side.

### Limits (H10)
- `callTimeout` is ring time; a maximum duration parameter exists on the create-call API (unverified name — confirm in the platform docs).

### Recording, transcripts, retention, redaction (H9)
- Off unless `<Record>` / `<StartRecording>`; transcription available on recordings; no redaction option documented (unverified).

### Disclosure surfaces (H8)
- `<SpeakSentence>` before `<Record>` / `<Transfer>`.

---

## Category quick map (all five)

| Cat | Row this stack most often fires on | Inherent Rule 6 Skips |
|---|---|---|
| 01 | Vonage `/answer` with no JWT check; Telnyx fail-open when the public key is unset; Plivo on V2 or none; SignalWire SWML with no basic auth; Bandwidth callback with no basic auth | Vonage signed-webhook toggle on older apps |
| 02 | `ws://` websocket URIs in NCCO / Plivo `<Stream>` / BXML `<StartStream>`; sockets that accept any client | — |
| 12 | SWAIG functions with no `web_hook_auth_*` | Telnyx AI Assistant tool auth |
| 14 | `to` / `<Number>` / `<PhoneNumber>` from a request or model; `transfer` with an inferred destination | account country permissions on all five |
| 17 | no `limit` / `time_limit_secs` / `time_limit`; no silence handling | account call ceilings |
| 21 | `record` on with transcripts logged | recording-URL auth on Plivo and Bandwidth |
| 26 | `private.key` committed; tunnel URLs; `http://` `web_hook_url` | — |
