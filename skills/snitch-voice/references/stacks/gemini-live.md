# Stack: Google Gemini Live API

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

The Live API is a bidirectional-streaming speech model reached over WebSocket, from a server
with an API key or from a browser with an ephemeral token. There is no telephony ingress of its
own; phone calls reach it through a carrier bridge or a framework. The defect that defines this
stack is an ephemeral token minted without constraints: the client's own setup frame then
decides the model, the system instruction, and the tools — including code execution — on the
project's bill.

## Fingerprints

- Packages: `google-genai` (PyPI, `from google import genai`), `@google/genai` (npm),
  `google.adk` (Agent Development Kit); superseded `google-generativeai` / `@google/generative-ai`
- Env: `GEMINI_API_KEY`, `GOOGLE_API_KEY`, `GOOGLE_GENAI_API_KEY`, `GOOGLE_CLOUD_PROJECT`,
  `GOOGLE_GENAI_USE_VERTEXAI`
- Hosts: `generativelanguage.googleapis.com` (the `BidiGenerateContent` WebSocket path;
  exact path unverified — confirm in the platform docs), `POST …/v1beta/auth_tokens`
- Model names: `gemini-live-*`, `*-native-audio`, `gemini-*-flash-live-preview`
- Calls and keys: `client.aio.live.connect(model=…, config={…})`, `live.connect(`,
  `response_modalities`, `system_instruction`, `tools`, `function_declarations`,
  `google_search`, `code_execution`, `session.send_tool_response(`,
  `client.auth_tokens.create(`, `authTokens.create(`, `uses`, `expire_time`,
  `new_session_expire_time`, `live_connect_constraints`, `liveConnectConstraints`,
  `bidi_generate_content_setup`, `lock_additional_fields`, `http_options={"api_version":
  "v1alpha"}`, `access_token` query parameter

## Ingress and verification (H1)

- No inbound webhook exists at this layer. Ingress is a carrier or framework bridge (see
  that stack file for its signature) or a browser connecting directly with a token.
- A server that proxies audio between a carrier socket and the Live socket has the carrier's
  handshake to verify (Cat 02) and nothing else.

## Client authentication (H2)

- Safe browser credential: an ephemeral token from `client.auth_tokens.create(config={ uses,
  expire_time, new_session_expire_time, live_connect_constraints, lock_additional_fields })`
  (the v1alpha API version), passed as the `access_token` query parameter or as
  `Authorization: Token …`. Documented defaults: `uses` 1, `expire_time` 30 minutes,
  `new_session_expire_time` 1 minute.
- Must stay server-side: the `AIza…` API key. A key in a browser WebSocket URL as `?key=` is
  Cat 03.
- Constraints are the control. `live_connect_constraints.bidi_generate_content_setup` should
  carry the `model`, the `system_instruction`, and an explicit `tools` array (empty when no
  tools are intended), with `lock_additional_fields` naming the fields the client may not
  add. A token minted with only `uses` and expiry fields leaves the client's setup frame free
  to set its own model, instruction, and tools — the shape of a widely reported 2026 flaw in
  a vendor-published sample server. Cat 11 reads for the missing constraints; Cat 04 reads the
  mint route for auth, rate limit, `uses` > 1, and long `expire_time`.
- Anti-patterns: `uses: 10`; `expire_time` of hours; no `live_connect_constraints`;
  `lock_additional_fields` absent; the mint route accepting `system_instruction` from the
  request body.

## Tools (H6)

- Definition: `tools: [{ "function_declarations": [ {name, description, parameters} ] },
  { "google_search": {} }, { "code_execution": {} }]` in the connect config or the setup
  frame. The model sends `toolCall`; the app answers with
  `session.send_tool_response(function_responses=[…])`.
- Execution: `function_declarations` run in your process (server) or in the browser (client
  direct); `google_search` and `code_execution` run on the vendor's side and are enabled by
  whoever controls the setup frame — which is the token-constraint question above.
- Every declared parameter is LLM-filled. Handlers that act on them without server-side
  authorization are Cat 12 / 13.
- ADK agents wrap the same surface; tool functions are Python callables on the agent.

## Call control (H7)

- None at this layer. Dial, transfer, DTMF, and hang-up are the bridging carrier's or
  framework's primitives; trace them there. Ending the session is closing the socket.

## Limits (H10)

- Session duration and connection limits are vendor-side (documented maximums exist;
  values unverified — confirm in the platform docs). Session resumption and context-window
  compression settings in the connect config extend sessions; the app-side cap is a timer.
- Token lifetime: `expire_time` bounds the whole session for a token-authenticated client;
  `new_session_expire_time` bounds when a new session may start. Long values are Cat 04.
- Spend: `max_output_tokens` in `generation_config` bounds one response; project quotas and
  budgets are platform-side (Rule 6 Skip). A token with `uses` > 1 multiplies exposure.
- Concurrency: per-project session limits are platform-side; an app-side cap is Cat 18.

## Recording, transcripts, retention, redaction (H9)

- No recording by the API. Input and output transcription can be enabled in the connect
  config (`input_audio_transcription`, `output_audio_transcription`) and arrive as events;
  durable storage is the app's write (Cat 21).
- Retention and abuse-monitoring logging are governed by the API's data terms, which differ
  between the developer API and Vertex AI; treat as platform-side (unverified — confirm in
  the platform docs).
- No redaction at this layer; redact before the write (Cat 22).

## Disclosure surfaces (H8)

- `system_instruction` in the connect config or setup frame, the first
  `session.send_client_content` / `send_realtime_input` that seeds a greeting, and ADK agent
  `instruction`. Cat 23 and 24 grep these. On a token-authenticated browser client, the
  instruction lives in `live_connect_constraints` — if it is not there, the client wrote it.

## What the platform already handles (do not flag)

- A token minted with `bidi_generate_content_setup` and `lock_additional_fields` pins the
  instruction and tools; do not flag the browser "sending the setup" when the constraints
  are quoted.
- `uses: 1` and the 1-minute new-session default already limit replay; do not ask for a
  separate nonce.
- Transport is TLS; not a finding.

## Category quick map

| Cat | Where this stack most often fires | Inherent Rule 6 Skips |
|---|---|---|
| 02 | carrier bridge socket accepting any client | — |
| 03 | `AIza…` key in a browser socket URL or bundle | — |
| 04 | mint route without auth or rate limit; `uses` > 1; long `expire_time` | — |
| 10 | instruction embedded in the browser setup frame | — |
| 11 | tokens minted without `live_connect_constraints` / `lock_additional_fields`; client-set `tools` including `code_execution` | — |
| 12, 13 | `function_declarations` handlers acting on arguments with no authorization or confirmation | — |
| 17, 18, 19 | no session timer, no open-session cap, no `max_output_tokens` | vendor session maximums, project quotas |
| 21, 22 | transcription events logged; no redaction before the write | data-retention terms |
| 23, 24 | `system_instruction` lacking the announcement or disclosure | — |
