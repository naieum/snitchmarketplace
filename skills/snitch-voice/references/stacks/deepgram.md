# Stack: Deepgram (Voice Agent API, STT streaming, redaction)

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Deepgram appears in two roles: as the transcription (and sometimes speech) provider inside
another framework, and as a complete agent through the Voice Agent API, where a single
WebSocket `Settings` message carries the prompt, the model choice, and the function
definitions — including the bearer tokens the vendor will use to call your tool endpoints.
Where that message is built decides most of the findings.

## Fingerprints

- Packages: `@deepgram/sdk`, `@deepgram/agent`, `deepgram/browser-agent` (web component);
  `deepgram-sdk`, `deepgram` (PyPI)
- Env: `DEEPGRAM_API_KEY`, `DEEPGRAM_PROJECT_ID`
- Hosts and paths: `wss://agent.deepgram.com/v1/agent/converse`, `api.deepgram.com`,
  `/v1/listen`, `/v1/speak`, `POST /v1/auth/grant`
- Headers: `Authorization: Token <key>` (server), `Authorization: Bearer <jwt>` (temporary
  token), `Sec-WebSocket-Protocol: token, <jwt>` (browser socket)
- Config keys: `"type": "Settings"`, `agent.listen.provider`, `agent.think.provider`,
  `agent.think.prompt`, `agent.think.functions[]`, `endpoint.url`, `endpoint.method`,
  `endpoint.headers`, `client_side`, `agent.think.endpoint` (custom LLM gateway),
  `agent.speak`, `agent.greeting`, `mip_opt_out`, `tags`, `FunctionCallRequest`,
  `FunctionCallResponse`, `ttl_seconds`, `redact`, `no_delay`
- Model names: `nova-3`, `flux-*` (listen), `aura-*` (speak)

## Ingress and verification (H1)

- No inbound webhook from the vendor to you for a session. Telephony reaches the agent through
  a carrier bridge (the carrier's signature applies) or a framework.
- **Function endpoints**: for a function with an `endpoint`, the vendor calls your URL with
  the `endpoint.headers` you supplied in `Settings`. There is no vendor signature; the
  control is the bearer or API-key header you put there and check on your route. A function
  endpoint with no `headers` is Cat 12 (unauthenticated tool webhook); the route that does not
  check the header is Cat 01 `unverified-route` for this vendor.
- **Custom LLM gateway**: `agent.think.endpoint.url` with `headers` — same rule.

Insecure shape:

```js
// browser bundle
const settings = { type: "Settings", agent: { think: { prompt: SYSTEM_PROMPT,
  functions: [{ name: "lookup_account", endpoint: { url: "https://api.example.com/tools/lookup",
    headers: { authorization: `Bearer ${BACKEND_TOKEN}` } } }] } } };
ws.send(JSON.stringify(settings));   // prompt, tool URLs and the backend bearer token all ship to the client
```

## Client authentication (H2)

- Safe browser credential: a temporary token from `POST /v1/auth/grant` (server-side, with
  `Authorization: Token <key>`; body `ttl_seconds`, documented default 30, maximum 3600),
  returned as an `access_token` JWT with write scope, used as `Bearer` or in the socket
  subprotocol. The vendor's SDKs support a "token factory" callback for this.
- Must stay server-side: `DEEPGRAM_API_KEY`.
- Mint endpoint: your `/token` or `/deepgram-token` route. Cat 04 reads it for auth, a rate
  limit, and a `ttl_seconds` close to the default rather than the maximum.
- Anti-patterns: the API key in a browser socket URL or subprotocol; `ttl_seconds: 3600` for
  every caller; the mint route open to any origin; the `Settings` message assembled in the
  browser (Cat 11: the client chooses prompt, model, and tools; Cat 03: any `endpoint.headers`
  secret ships with it).

## Tools (H6)

- Definition: `agent.think.functions[]` with `name`, `description`, `parameters`, and either
  `endpoint: { url, method, headers }` (the vendor executes it server-side) or
  `client_side: true` (the vendor sends `FunctionCallRequest` and the client answers with
  `FunctionCallResponse`).
- Every parameter is LLM-filled. An endpoint function's authorization is whatever your route
  does with the request: the bearer proves the vendor is calling, not who the caller is. The
  caller's identity must be bound in your session state, not read from arguments (Cat 12).
- Client-side functions run wherever the socket is held: in the browser they are the user's
  code, in a server relay they are yours.
- Dangerous shapes: endpoint functions with no `headers`; endpoint URLs pointing at a tunnel;
  functions whose name says transfer, pay, update, send, or end.

## Call control (H7)

- None in the Voice Agent API itself; the socket carries audio both ways. Dial, transfer,
  DTMF, and hang-up belong to the carrier or framework that bridged the call; closing the
  socket ends the agent's side. Trace those primitives in the carrier's stack file.

## Limits (H10)

- Session duration: the socket lives until closed; the vendor may enforce a maximum
  (unverified — confirm in the platform docs). The app-side cap is a timer (Cat 17).
- Idle: the vendor's socket expects keep-alives; an idle-hangup is app code.
- Spend: the `think` provider's cost is pass-through; there is no per-session budget key. The
  temporary token's `ttl_seconds` bounds how long a client can start sessions, not how long a
  session runs. Project spend limits are platform-side (Rule 6 Skip).
- Concurrency: project-level concurrency limits are platform-side; an app-side cap on open
  agent sockets or minted tokens is Cat 18.

## Recording, transcripts, retention, redaction (H9)

- Not recorded by the vendor unless a feature that stores audio is enabled; the app's relay
  writes whatever it logs (Cat 21).
- Transcripts arrive as `ConversationText` events on the agent socket and as results on
  `/v1/listen`; the app's logger is the sink.
- Redaction: on `/v1/listen`, `redact=pci|pii|phi|numbers|true` (repeatable) redacts the
  transcript; `no_delay=true` degrades it. Whether `redact` is honored inside the agent's
  `listen.provider` block is not stated on the vendor's configuration page; treat its absence
  as no redaction and its presence in the agent block as `(unverified — confirm in the
  platform docs)`, confidence Medium (Cat 22).
- Retention and data use: `mip_opt_out` in `Settings` opts the session out of the vendor's
  model-improvement program; retention terms are platform-side.

## Disclosure surfaces (H8)

- `agent.think.prompt` and `agent.greeting` in `Settings`. Cat 23 and 24 grep these. If
  `Settings` is built in the browser, the disclosure is whatever the client sends.

## What the platform already handles (do not flag)

- A temporary token from `/v1/auth/grant` with a short TTL is the vendor's intended browser
  credential; do not flag the token itself once the mint route is checked.
- TLS on every endpoint; not a finding.
- `redact=` on `/v1/listen` performs the transcript redaction; do not ask for an app-side
  regex on top when it is quoted.
- The vendor calling your function endpoint with the header you configured is expected; do
  not flag the outbound bearer as "a secret sent to a third party" — flag it only where it
  ships to a client or sits as a literal in the repo.

## Category quick map

| Cat | Where this stack most often fires | Inherent Rule 6 Skips |
|---|---|---|
| 01 | function-endpoint route that never checks the configured header | — |
| 03 | `DEEPGRAM_API_KEY` in a client; `endpoint.headers` bearer in a browser-built `Settings` | — |
| 04 | mint route without auth or rate limit; `ttl_seconds` at the maximum | — |
| 10 | `agent.think.prompt` shipped to the browser | — |
| 11 | `Settings` assembled client-side | — |
| 12, 13 | endpoint functions with no `headers`; handlers acting on arguments alone | — |
| 16 | `FunctionCallResponse` filled with raw errors | — |
| 17, 18, 19 | no socket timer, no open-socket cap, no spend guard | vendor session maximums, project limits |
| 21, 22 | `ConversationText` logged; no `redact` on listen; agent-block `redact` unconfirmed | retention terms |
| 23, 24 | `prompt` and `greeting` lacking announcement or disclosure | — |
| 26 | `endpoint.url` at a tunnel host; `http://` endpoints | — |
