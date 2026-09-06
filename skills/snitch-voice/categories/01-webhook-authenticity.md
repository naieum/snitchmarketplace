## CATEGORY 01: Telephony and platform webhook authenticity
> Type: posture · Groups: quick, ingress · Hop: H1 Ingress · Standards: CWE-345, CWE-306

Every voice stack starts with an HTTP request that claims to come from the carrier or the agent
platform: "a call is ringing, here is the caller", "the call ended, here is the transcript", "the
model wants to run this tool, here are the arguments". Each provider signs those requests, and each
signature is checked by a helper the SDK already ships. A route that reads the body before checking
the signature is a route that acts on anyone's body — an attacker can invent a caller, forge a tool
call with chosen arguments, or replay a call-ended event with a fabricated transcript. This category
reads every inbound route the carrier or platform is configured to hit and asks one question: is the
signature (or shared secret) verified, on the raw body, before anything else happens?

**Boundary.** This category judges routes the carrier or agent platform calls. The WebSocket and
SIP ingress that carries audio is Cat 02; tool webhooks specifically — the route the platform calls
when the model invokes a tool — are checked here for signature and in Cat 12 for per-call
authorization; a generic webhook from a non-voice service is snitch-security's business. Whether the
verified request then does something dangerous is the later categories' judge.

### Detection
- Telephony SDK imports: `twilio`, `@vonage/server-sdk` / `vonage`, `telnyx`, `plivo`,
  `@signalwire/compatibility-api` / `signalwire`, `@bandwidth/voice`
- Agent-platform SDKs and headers: `@vapi-ai/server-sdk`, `retell-sdk`, `@elevenlabs/elevenlabs-js`
  / `elevenlabs`, `livekit-server-sdk` / `livekit-api`, `openai` (Realtime SIP webhooks)
- Route handlers whose path or handler name says voice: `/voice`, `/twiml`, `/incoming-call`,
  `/call-status`, `/recording-status`, `/webhook`, `/vapi`, `/retell`, `/tool-calls`,
  `/function-call`, `/post-call`, `/events`, `/answer`, `/event`, `/ncco`
- Environment variables that are signing material: `TWILIO_AUTH_TOKEN`, `VONAGE_SIGNATURE_SECRET`,
  `TELNYX_PUBLIC_KEY`, `PLIVO_AUTH_TOKEN`, `SIGNALWIRE_TOKEN`, `VAPI_SERVER_SECRET`,
  `RETELL_API_KEY`, `ELEVENLABS_WEBHOOK_SECRET`, `LIVEKIT_API_SECRET`, `OPENAI_WEBHOOK_SECRET`
- Exported assistant or agent configs that carry a `server.url`, `serverUrl`, `webhook_url`,
  `answer_url`, `event_url`, or `webhookUrl` pointing at this workspace

### What to Search For
- The provider's verification helper, by name, per `references/stacks/<platform>.md`: Twilio
  `validateRequest` / `validateRequestWithBody` / `twilio.webhook()` / `RequestValidator`; Vonage
  `verifySignature` / `verify_signature` on the bearer JWT; Telnyx `constructEvent` /
  `construct_event` with `telnyx-signature-ed25519` and `telnyx-timestamp`; Plivo
  `validate_v3_signature` / `X-Plivo-Signature-V3`; SignalWire `validateRequest` /
  `x-signalwire-signature`; Vapi `server.credentialId` or a checked `X-Vapi-Secret` /
  `Authorization` header; Retell `Retell.verify` / `retell.verify` on `X-Retell-Signature`;
  ElevenLabs `constructEvent` / `construct_event` on `ElevenLabs-Signature`; LiveKit
  `WebhookReceiver.receive`; OpenAI `webhooks.unwrap` on `webhook-signature`
- Routes that never call the helper, or call it after the body has been read and acted on
- `validate: false`, `skipSignatureVerification`, `verify: false`, `NODE_ENV !== 'production'`
  guards that switch verification off, and any branch that returns early when the signing secret is
  unset instead of failing closed
- Body parsers that re-serialize JSON before verification (`express.json()` ahead of a raw-body
  HMAC check), so the signature is computed over different bytes than the provider signed
- Manual HMAC comparisons using `==` / `===` rather than a constant-time compare
- Timestamp windows: providers that send a timestamp (Telnyx, Retell, ElevenLabs, OpenAI) expect a
  replay tolerance; a check that ignores the timestamp accepts an old captured request forever
- URL reconstruction for URL-bound signatures (Twilio, Plivo, SignalWire): behind a proxy or TLS
  terminator, the URL the app sees differs from the one the provider signed; look for
  `X-Forwarded-Proto` / `X-Forwarded-Host` handling, or a hardcoded public URL passed to the helper
- Shared-secret schemes where the secret is compared against a query-string parameter or a
  guessable path segment rather than a header, and where no secret is configured at all
- IP allowlisting used as the only control for a provider that documents a signature

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| unverified-route | An inbound route the carrier or platform calls reads or acts on the body with no signature or secret check on the traced path | route file:line + the search for the helper over the route's middleware chain | Critical for tool-call, call-answer and transfer routes; High for status and post-call routes |
| verification-disabled | A helper exists but is switched off by a flag, an environment check, or an unset-secret early return | the flag or branch file:line | High |
| wrong-bytes | Verification runs over a re-parsed or re-serialized body, or over a reconstructed URL that differs from the signed one | the parser order or URL construction file:line | High |
| no-replay-window | A timestamped scheme is verified without checking the timestamp | the verify call file:line + the absent tolerance | Medium |
| non-constant-compare | A hand-rolled HMAC compare uses ordinary string equality | the compare file:line | Medium |
| ip-only | The only control is an IP allowlist on a provider that documents a signature or secret | the allowlist file:line + the absent helper | Medium |
| secret-in-url-only | The shared secret lives in the webhook URL path or query and nothing else checks the request | the config or route file:line | Medium |

### Actually Vulnerable

#### Critical
- A route that answers a call, runs a tool call, or controls a call (transfer, hang up, dial)
  with no verification on the path from request arrival to the action
- Verification present on some voice routes and absent on the tool-call route

#### High
- Verification disabled by `validate: false`, `NODE_ENV` guards, or an early `return next()`
  when the secret is unset
- A status, recording, or post-call route with no verification whose handler writes to a
  database, updates a CRM, sends a message, or stores a transcript
- HMAC verified over `JSON.stringify(req.body)` after a JSON body parser, or a URL-bound signature
  verified against a URL rebuilt from `req.headers.host` behind a proxy with no forwarded-header
  handling

#### Medium
- Timestamped scheme with no replay window
- Non-constant-time compare
- IP allowlist as the only control; secret in the URL as the only control
- A post-call route with no verification whose handler only logs

### NOT Vulnerable
- The provider's helper called on the raw body before any read of the parsed body, with the
  signing secret read from the environment — record the call and the secret's source as the Pass
- App-level middleware that verifies every route under the voice prefix, confirmed by reading the
  middleware registration and the covered path; routes outside the prefix are still checked
  individually
- A provider that documents no signature and no secret (see the stack file) where the route is
  protected by a per-deployment secret in a header the platform is configured to send — Pass
  with both the config and the check quoted
- A framework plugin that performs the verification (a Twilio Express middleware, a Fastify
  plugin) — Pass when the plugin is registered on the route and its options do not disable it
- Amazon Connect and Lex flows invoking Lambda by IAM: there is no webhook to verify; Skip with
  that reason

### Context Check
1. Which routes does the carrier or platform actually call? Read the exported config, the TwiML
   or NCCO the app returns, and the number configuration if it is in the workspace; a route the
   provider is never pointed at is not an ingress.
2. Is verification per-route or middleware? Read the registration and the path it covers.
3. Does the body reach the helper as raw bytes? Read the parser order.
4. For URL-bound schemes, what URL is passed, and does it match what the provider would sign
   through the deployed proxy?
5. Is there a branch that skips verification in any environment? Would a missing secret fail
   open or closed?
6. Is the scheme timestamped, and is the timestamp checked?

### Evidence Chain
- The route registration file:line and the handler file:line
- The middleware chain the request passes through, in order, with file:line for each
- The verification call file:line, or the search that established its absence over that chain
  with pattern and scope
- The body-parser order and the URL construction, where the scheme depends on them
- The flag or branch that disables verification, where one exists
- The provider's documented scheme, cited from the stack file, so the reader can see what was
  expected

### Confidence Scoring
- **High**: the route is confirmed as a provider ingress (config or TwiML/NCCO in the workspace
  points at it) and the helper is verifiably absent from its middleware chain, or verifiably
  disabled
- **Medium**: the route looks like an ingress by path or name but the provider-side pointer is
  not in the workspace, or verification may live in infrastructure (an API gateway, a proxy) not
  represented here
- **Low**: the handler's middleware chain could not be resolved (dynamic registration, framework
  magic) — tag `needs human verification`

### Severity
Critical is reserved for a route whose unverified body decides an action: answering a call with a
model attached, executing a tool call, transferring or dialing. High covers disabled or
wrong-bytes verification anywhere, and unverified routes that write. Medium covers weakened
verification and unverified routes that only log. Low is not used in this category; an unverified
ingress is never cosmetic.

### Files to Check
- `**/routes/**`, `**/api/**`, `**/webhooks/**`, `**/voice/**`, `**/telephony/**`
- `**/twiml*`, `**/incoming*`, `**/call*`, `**/vapi*`, `**/retell*`, `**/elevenlabs*`, `**/tools*`
- `app.ts`, `server.ts`, `index.ts`, `main.py`, `app.py` (middleware registration)
- Exported configs: `**/*assistant*.json`, `**/*agent*.json`, `**/vapi*.{json,yaml}`,
  `**/retell*.{json,yaml}`, `**/*.ncco.json`, `**/twiml/**`
- `.env*`, `**/config/**`

### Reference
- CWE-345: Insufficient Verification of Data Authenticity
- CWE-306: Missing Authentication for Critical Function
- CWE-208: Observable Timing Discrepancy (non-constant compare)
- Per-provider scheme, helper name, and known pitfalls: `references/stacks/<platform>.md`
