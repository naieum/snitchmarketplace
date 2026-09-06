# Stack: Twilio (Programmable Voice, Media Streams, ConversationRelay, TwiML)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Twilio is the carrier under most self-built voice agents and under several hosted platforms' BYO-number modes. It signs every request it makes to you, it lets any client attach to a media socket that knows the URL, and its own quickstarts ship with neither check. Read this file before Cats 01, 02, 14, 17, 21, 22, 26 run on a Twilio workspace.

## Fingerprints

- Packages: `twilio` (npm, PyPI), `twilio-ruby`, `Twilio` (NuGet), `github.com/twilio/twilio-go`; client SDKs `@twilio/voice-sdk` (browser), `twilio-voice-react-native`
- Env: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_API_KEY`, `TWILIO_API_SECRET`, `TWILIO_PHONE_NUMBER`
- Hosts and paths: `api.twilio.com`; quickstart routes `/incoming-call`, `/voice`, `/twiml`, `/media-stream`, `/ws`, `/call-status`, `/recording-status`
- Headers: `X-Twilio-Signature`
- TwiML: `VoiceResponse`, `<Response><Connect><Stream url="wss://…">`, `<Connect><ConversationRelay url="wss://…">`, `<Dial>`, `<Number>`, `<Sip>`, `<Record>`, `<Gather>`, `<Pay>`, `<Parameter name= value=>`
- Media Streams socket events: `connected`, `start`, `media`, `mark`, `stop`, `streamSid`, `callSid`; base64 mu-law (`audio/pcmu`)
- ConversationRelay attributes: `url`, `welcomeGreeting`, `voice`, `ttsProvider`, `transcriptionProvider`, `dtmfDetection`, `interruptible`, `reportInputDuringAgentSpeech`, `intelligenceService`; socket messages out `text`, `play`, `sendDigits`, `end` (with `handoffData`), `language`, `handoff`; in `setup`, `prompt`, `dtmf`, `interrupt`, `error`; `setup.customParameters`
- Call resource params: `To`, `From`, `Url`, `Twiml`, `StatusCallback`, `Timeout`, `TimeLimit`, `Record`, `RecordingChannels`, `RecordingTrack`, `RecordingStatusCallback`, `MachineDetection`, `AsyncAmd`, `SendDigits`
- Helpers: `validateRequest`, `validateRequestWithBody`, `twilio.webhook(`, `RequestValidator`

## Ingress and verification (H1)

- Scheme: `X-Twilio-Signature` = base64 HMAC-SHA1, keyed with the Auth Token, over the full request URL plus the POST parameters sorted by key. JSON bodies add a `bodySHA256` query parameter that the helper checks.
- Helpers: Node `twilio.validateRequest(authToken, signature, url, params)`, `validateRequestWithBody`, Express middleware `twilio.webhook()` (403 on failure; has a `validate: false` option); Python `RequestValidator(auth_token).validate(url, params, signature)`; `RequestValidator` in Java, C#, Go, PHP, Ruby.
- Media Streams and ConversationRelay WebSocket upgrade requests carry the same header. The vendor's docs say to validate it on the handshake and to try appending a trailing `/` to the URL when validation fails. Basic auth embedded in the webhook URL is also supported.
- The insecure shape, which is the vendor's own realtime sample:

```js
fastify.all('/incoming-call', async (req, reply) => {
  reply.type('text/xml').send(`<Response><Connect>
    <Stream url="wss://${req.headers.host}/media-stream" /></Connect></Response>`);
});
fastify.get('/media-stream', { websocket: true }, (conn) => { /* model attached, no auth */ });
```

  No `validateRequest`, no check on the socket upgrade, and the socket host is taken from the request's own `Host` header.
- Pitfalls: behind TLS termination or a tunnel the app sees a different URL than the one signed, so teams disable validation instead of passing the public URL (read `X-Forwarded-Proto` / `X-Forwarded-Host` handling or a hardcoded public URL). A JSON body parser ahead of the helper changes the bytes. `express.json()` before `twilio.webhook()` is a wrong-bytes finding for JSON callbacks.

## Client authentication (H2)

- Browser and mobile calling uses `@twilio/voice-sdk` with a short-lived capability/access token minted server-side from `TWILIO_API_KEY` + `TWILIO_API_SECRET` (a `VoiceGrant`). The Auth Token and API Secret never belong in a client bundle.
- Anti-patterns: `TWILIO_AUTH_TOKEN` or `TWILIO_API_SECRET` under `NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`; a `/token` route with no user auth or a multi-day TTL; the Account SID plus Auth Token in a mobile app config.
- Media-stream and ConversationRelay sockets have no client credential of their own: whoever reaches the `wss://` URL is in. A common app-side control is an HMAC of `CallSid` and a secret passed as a `<Parameter>` and compared with a constant-time function on upgrade; quote both halves for a Pass.

## Tools (H6)

- Twilio carries no tool schema of its own. With ConversationRelay the tools live in the app's model call; with Media Streams they live in the realtime model session (`session.update` → `tools`). ConversationRelay's server-to-Twilio messages are the sinks: `sendDigits`, `end` with `handoffData`, `handoff`.
- `handoffData` and `<Parameter>` values are documented as not PCI-scoped; card data in either is a Cat 22 finding.
- Dangerous built-ins to look for in the app's tool handlers: `<Dial>` and `calls.create` (Cat 14), `sendDigits` (Cat 14), `messages.create` (Cat 15), `<Pay>` (Cat 22, Cat 25).

## Call control (H7)

- Dial: `calls.create({ to, from, url | twiml, timeLimit, record, machineDetection, sendDigits })`; in-call transfer via `calls(sid).update({ twiml })` or a `<Dial>` verb; SIP via `<Sip>`; `<Refer>` for SIP REFER.
- Destination fields: `to`, `<Dial>` body, `<Number>` body. The vendor's fraud guidance states `<Dial>` should never take user input directly as the number.
- Caller ID: `from` / `callerId` must be a verified number or a Twilio number on the account; a variable here is Cat 14's caller-id row.
- Geographic permissions (Voice Dialing Geographic Permissions, low-risk and high-risk country buckets) are account-side. They appear in the repo only if managed through the REST `DialingPermissions` resources or infrastructure-as-code; otherwise Rule 6 Skip.
- Usage Triggers (webhook when spend or minutes cross a threshold) are also account-side.

## Limits (H10)

- `TimeLimit` on the Call resource (seconds); `Timeout` is ring time, not call duration (max 600). No `TimeLimit` means the carrier's own ceiling applies (unverified — confirm in the platform docs).
- Silence and idle handling is the app's job on Media Streams; ConversationRelay has no silence timeout attribute of its own (unverified — confirm in the platform docs).
- Concurrency: per-account participant and CPS limits are account-side; overflow returns SIP 603/429. App-level throttles on the inbound route are what the repo can show.

## Recording, transcripts, retention, redaction (H9)

- Recording is off unless the code turns it on: `record: true` on `calls.create`, `<Record>`, `record` on `<Dial>`. Recording URLs are on the account; whether they require auth is an account setting (HTTP basic auth on media URLs), Rule 6 Skip unless exported.
- Transcripts: Media Streams and ConversationRelay hand the app raw audio or text; whatever the app logs is the record. `intelligenceService` routes ConversationRelay transcripts into a Conversational Intelligence service, which can redact PII in transcripts and insert silence in recordings (en-US media only), toggled per service and via the `Redacted` query param on transcript media.
- `<Pay>` is the PCI-scoped card-capture path; capturing digits with `<Gather>` or through the model is not.

## Disclosure surfaces (H8)

- ConversationRelay `welcomeGreeting`; any `<Say>` before `<Connect>`; the app's own first turn. Recording announcements usually sit in a `<Say>` ahead of `<Record>` or `<Dial record>`.

## What the platform already handles (do not flag)

- `twilio.webhook()` registered on the route with default options is full signature validation; do not flag the absence of a manual `validateRequest` beside it.
- `<Pay>` keeps card digits out of the app and the recording; do not flag PCI storage on a `<Pay>` flow the app never sees.
- Outbound `from` must already be a number the account owns; the carrier rejects others, so caller-id-from-variable is High, not Critical, on Twilio.
- Media payloads are audio; there is no Twilio-side text to inject through the socket itself. Injection lives in the transcript (Cat 07) and in `setup.customParameters` (Cat 08).

## Category quick map

| Cat | Row this stack most often fires on | Inherent Rule 6 Skips |
|---|---|---|
| 01 | unverified-route on `/incoming-call`, `/media-stream`, status callbacks; wrong-bytes behind a proxy | — |
| 02 | media socket accepts any client; `wss://${req.headers.host}` | — |
| 03 | Auth Token or API Secret in a client bundle | — |
| 08 | `setup.customParameters` / `<Parameter>` values templated into the prompt | — |
| 14 | `<Dial>` / `calls.create` with a request or model destination; `sendDigits` from text | geographic permissions, usage triggers |
| 17 | no `TimeLimit`; no app-side silence handling | account call ceilings |
| 21 | `record: true` with logs of transcripts; recording URL auth | media-URL auth setting |
| 22 | card digits via `<Gather>` or model, `<Parameter>` / `handoffData` carrying PCI data | Intelligence service redaction toggle |
| 26 | tunnel `wss://` in TwiML, `validate: false` | — |
