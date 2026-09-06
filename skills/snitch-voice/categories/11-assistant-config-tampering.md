## CATEGORY 11: Client-supplied assistant and session configuration
> Type: posture · Groups: injection, ingress · Hop: H4 Prompt assembly · Standards: CWE-602, CWE-915

Most voice platforms let the code that *starts* a session also *shape* it: pass an inline assistant,
override the prompt, set dynamic variables, add tools, change the model. That is convenient when the
starter is the server. When the starter is a browser tab or a mobile app, the person holding it can
rewrite the agent — swap the prompt for one that skips verification, add a tool the server never
intended, point the model at a costlier tier, or set a variable the prompt trusts as the caller's
account. The same shape exists on the server side when a session-start callback builds the
configuration from caller-influenced fields. This category reads every place a session's
configuration is assembled and asks who controls each field.

**Boundary.** This category judges the configuration a session starts with. Injection through the
values of individual variables once they are inside the prompt is Cat 08. Injection through speech
is Cat 07. Whether the client can *obtain* a session at all — the token endpoint — is Cat 04, and a
raw secret key in the client is Cat 03. Whether the prompt's own content is sensitive is Cat 10.
Tool definitions that the client adds are reported here; whether those tools are authorized per
call is Cat 12.

### Detection
- Web and mobile SDK session starts: Vapi `vapi.start(assistantId, assistantOverrides)` or
  `vapi.start({ ...inlineAssistant })`, `@vapi-ai/web`, `@vapi-ai/react-native`; Retell
  `retellWebClient.startCall({ accessToken })` and the server `create-web-call` body; ElevenLabs
  `Conversation.startSession({ overrides })`, `@elevenlabs/react`, `@elevenlabs/client`; OpenAI
  Realtime browser code sending `session.update` (`instructions`, `tools`, `model`,
  `tool_choice`); Gemini Live client `setup` frames (`system_instruction`, `tools`,
  `generation_config`); Deepgram Voice Agent `Settings` message construction; LiveKit
  `RoomConfiguration` / `agents[].metadata` / participant `metadata` and `attributes`;
  Pipecat `/connect` or `/start` request bodies
- Server-side session-start callbacks that return configuration: Vapi `assistant-request`
  server messages, Retell `llm_websocket_url` config frames, Twilio ConversationRelay `setup`
  handling that chooses a prompt, LiveKit dispatch metadata parsed into instructions, Bland
  `request_data` / `pathway` selection
- Public-key restriction settings when exported: Vapi public-key origin restriction,
  `allowedAssistantIds`, `allowTransientAssistant`; ElevenLabs `enable_auth`, allowlist,
  "client overrides" toggles; Gemini `live_connect_constraints`, `lock_additional_fields`;
  OpenAI `client_secrets` `session` object and `expires_after`

### What to Search For
- `assistantOverrides`, `overrides`, `variableValues`, `dynamic_variables`,
  `metadata`, `custom_data` populated from client state, URL parameters, or form fields
- Inline assistant or agent definitions in client source: `model.messages`, `tools`,
  `firstMessage`, `voice`, `model.model` set in a browser or mobile file
- `session.update` (OpenAI) or `setup` (Gemini) frames sent from client code carrying
  `instructions`, `tools`, `tool_choice`, `model`, `max_response_output_tokens`
- Ephemeral-token minting that does not pin the session: OpenAI `client_secrets` requests whose
  `session` omits `instructions` / `tools`, Gemini `auth_tokens.create` without
  `live_connect_constraints.bidi_generate_content_setup` carrying `model`, `system_instruction`
  and an explicit `tools` list, or with `lock_additional_fields` unused
- Deepgram `Settings` built in the browser, including `agent.think.functions[]` with
  `endpoint.url` and `endpoint.headers`
- Public keys (Vapi) used with no origin restriction and no `allowedAssistantIds`, or with
  `allowTransientAssistant` on — where the export is in the workspace
- ElevenLabs agents with client overrides enabled for prompt or first message
- Server `assistant-request` / config handlers that read `call.customer`, SIP headers, query
  parameters, or CRM fields and interpolate them into the returned prompt, tools, or variables
- Feature flags that switch between "safe" and "test" assistants based on a client-supplied
  value

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| client-prompt-override | Client code can set or replace the system prompt, first message, or model for the session, and the platform is not configured to reject it | client file:line + the restriction search | Critical |
| client-tool-injection | Client code can add, remove, or redefine tools (including tool endpoints and headers) for the session | client file:line | Critical |
| unpinned-token | An ephemeral token is minted without binding the session configuration (prompt, tools, model), so the client's first frame decides them | token-mint file:line + the absent constraint fields | Critical |
| client-variables-trusted | Client-supplied variables flow into the prompt or tool arguments as identity or authorization facts | client file:line + the prompt/tool use file:line | High |
| public-key-unrestricted | A browser-safe public key is used with no origin restriction and no assistant allowlist, or with transient assistants allowed, per the export in the workspace | export file:line | High |
| server-config-from-caller | A session-start callback builds prompt, tools, or variables from caller-influenced fields with no allowlist | handler file:line + trace | High |
| model-or-voice-switch | Client can select the model tier, voice, or provider (a cost lever) | client file:line | Medium |

### Actually Vulnerable

#### Critical
- `vapi.start(assistantId, { model: { messages: [...] } })` or an inline assistant object in a
  browser bundle; `Conversation.startSession({ overrides: { agent: { prompt: ... } } })` with
  overrides enabled; a browser sending `session.update({ instructions, tools })` on an OpenAI
  Realtime connection the server did not pin
- A Gemini Live ephemeral token created with only `uses` / `expire_time` and no
  `live_connect_constraints`, so the client `setup` frame may add tools such as code execution
- Deepgram Voice Agent `Settings` (with `functions[].endpoint.*`) assembled in client code

#### High
- `variableValues` / `dynamic_variables` from the client used as `accountId`, `customerName`,
  `isVerified`, `plan`, or any field the prompt or a tool treats as fact
- A Vapi public key in the workspace export with no origin restriction and no
  `allowedAssistantIds`
- An `assistant-request` handler that interpolates `customer.number`, a SIP header, or a query
  parameter into the returned prompt or chooses tools by it without an allowlist
- OpenAI `client_secrets` minted with a `session` object that omits `instructions` and `tools`
  while the browser sends them

#### Medium
- Client selects `model`, `voice`, `provider`, or `max_response_output_tokens`
- A "debug" or "test" assistant selectable by a client-supplied flag in production builds

### NOT Vulnerable
- The client passes only an assistant or agent ID (or nothing) and receives a token; all
  configuration is server-side or platform-side — Pass quoting the start call and the token route
- Overrides limited to cosmetic or session-scoped values the prompt does not trust (a display
  name shown to the caller, a language preference validated against an enum) — Pass quoting the
  allowlist
- A token-mint request that pins `instructions` and `tools` (OpenAI `session`), or Gemini
  `live_connect_constraints.bidi_generate_content_setup` with `model`, `system_instruction` and
  an explicit `tools: []`, with `lock_additional_fields` set — Pass quoting the request
- A server-side `assistant-request` handler that maps a validated, server-known identifier to a
  fixed configuration table
- A hosted platform whose restriction settings are not exported — the public-key row Skips with
  the Rule 6 wording; the client-side rows still run on the client code

### Context Check
1. Who starts the session — server, browser, mobile, a carrier callback — and what does each
   pass? Read the actual call, not the SDK's capability list.
2. For every field the client passes: does the platform accept it, and is there an exported
   restriction that rejects it? If the export is absent, the platform-side answer is a Skip.
3. Does the token minting pin the configuration, or leave it to the first client frame?
4. For server-built configuration: where does each input come from, and is it validated
   against an allowlist before it shapes the prompt or tools?
5. Do client-supplied variables ever become identity or authorization facts downstream? Follow
   them into the prompt and tool handlers.

### Evidence Chain
- The session-start call file:line (client or server) and every field it passes
- The token-mint request file:line and the presence or absence of constraint fields
- For variables: the trace from client input to the prompt or tool use with file:line
- The export of platform-side restrictions, or the Rule 6 skip line
- The allowlist or validation checked and found absent

### Confidence Scoring
- **High**: client code demonstrably passes prompt, tools, or trusted variables, and no
  server- or platform-side rejection is found in the workspace; or the token mint verifiably
  omits the constraint fields
- **Medium**: the client passes overrides but a platform-side restriction may exist without an
  export, or the variable's downstream trust is partially traced
- **Low**: the session-start path could not be resolved (bundled or minified client, dynamic
  config loading) → tag `needs human verification`

### Severity
Critical is any path by which the person holding the client decides the prompt, the tools, or
the model the session runs. High is client-supplied facts the agent trusts, an unrestricted
public key, or a server callback shaped by the caller. Medium is a cost or voice lever in client
hands. Low is not used.

### Files to Check
- `**/client/**`, `**/web/**`, `**/src/app/**`, `**/components/**`, `**/hooks/**`,
  `**/*.tsx`, `**/*.jsx`, `**/*.vue`, `**/*.svelte`, `**/*.swift`, `**/*.kt`, `**/*.dart`
- `**/api/token*`, `**/api/session*`, `**/api/client-secret*`, `**/api/web-call*`,
  `**/api/assistant*`, `**/assistant-request*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/vapi*`, `**/elevenlabs*`, `**/retell*`
- `.env*` (public-key values and `NEXT_PUBLIC_*` / `VITE_*` / `EXPO_PUBLIC_*` prefixes)

### Reference
- CWE-602: Client-Side Enforcement of Server-Side Security
- CWE-915: Improperly Controlled Modification of Dynamically-Determined Object Attributes
- OWASP LLM Top 10 (2025): LLM01 Prompt Injection, LLM06 Excessive Agency
- OWASP Agentic Top 10 (2025): ASI01 Agent Goal Hijack
- Which fields each platform lets a client set, and the restriction switches:
  `references/stacks/<platform>.md`
