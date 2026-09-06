# Stack: Vapi

Verified: 2026-09-06 against the vendor's public documentation. Anything marked (unverified — confirm in the platform docs) was not confirmed.

Vapi is a hosted agent platform: the assistant (prompt, voice, model, tools, limits, recording) lives in the vendor's console or is created through its API, and the repo usually holds the tool webhooks, a web client, and sometimes an exported assistant JSON. Two things make it distinctive for an audit: a **public** key that is meant for browsers and a **private** key that is not, and a web SDK that lets the client override assistant fields unless the key is restricted. Read this before Cats 01, 03, 04, 08, 10, 11, 12, 14, 17, 19, 21 run.

## Fingerprints

- Packages: `@vapi-ai/web` (browser; constructor takes the public key), `@vapi-ai/server-sdk`, `@vapi-ai/react-native`, `vapi_server_sdk` (PyPI), `vapi-client` (Rust)
- Env: `VAPI_API_KEY`, `VAPI_PRIVATE_KEY`, `VAPI_PUBLIC_KEY`, `VAPI_SERVER_SECRET`; `NEXT_PUBLIC_VAPI_PUBLIC_KEY` is legitimate, `NEXT_PUBLIC_VAPI_API_KEY` / `NEXT_PUBLIC_VAPI_PRIVATE_KEY` is not
- Hosts and paths: `api.vapi.ai`, `/call`, `/call/phone`, `/call/web`, `/assistant`, `/phone-number`, `/tool`
- Headers: `x-vapi-secret` (legacy shared string), or a configured HMAC header pair (names are user-defined), or `Authorization: Bearer`
- Config keys: `assistantId`, `assistantOverrides`, `variableValues`, `server.url`, `server.secret`, `server.credentialId`, `serverUrl`, `serverUrlSecret`, `model.tools[]`, `model.provider: "custom-llm"`, `model.url`, `maxDurationSeconds`, `silenceTimeoutSeconds`, `firstMessage`, `firstMessageMode`, `endCallPhrases`, `endCallFunctionEnabled`, `voicemailDetection`, `artifactPlan.recordingEnabled`, `artifactPlan.transcriptPlan.enabled`, `artifactPlan.recordingPath`, `hipaaEnabled`, `compliancePlan.hipaaEnabled`, `compliancePlan.pciEnabled`, `customer.number`, `phoneNumberId`; message types `assistant-request`, `tool-calls`, `end-of-call-report`, `status-update`; `toolCallList`, `results[]`
- Templating: `{{customer.number}}`, `{{customer.name}}` and other LiquidJS variables in prompts, tool URLs, headers and bodies

## Ingress and verification (H1)

- No authentication until a credential is attached. Historically `server.secret` was sent as `x-vapi-secret` (plain shared string compared for equality). Current docs deprecate `server.secret` / `server.headers` in favor of `server.credentialId` referencing a Custom Credential of type Bearer, OAuth2 client-credentials, or HMAC. For HMAC the header names, algorithm (SHA-256 or SHA-1), timestamp header and payload format are all user-configured — never assume a fixed `x-vapi-signature` header; read the credential definition if it is exported.
- Helper: none; the check is app code comparing the header against `VAPI_SERVER_SECRET` (constant-time) or verifying the configured HMAC.
- Insecure shape: a `/webhook` or `/vapi` route that switches on `message.type` and dispatches `tool-calls` with no header check. Same for a custom-LLM `/chat/completions` endpoint (`model.provider: "custom-llm"`) that never checks a key — anyone can drive the conversation.
- Pitfall: the same route often handles `assistant-request` (returns the assistant config for a call) — an unverified one lets an attacker request an assistant with any prompt and tools.

## Client authentication (H2)

- Safe browser credential: the public key. It is restrictable in the dashboard by origin, by `allowedAssistantIds`, and by whether transient (inline) assistants are allowed. Only `POST /call/web` is public-key scoped.
- Server-side only: the private key (`VAPI_API_KEY` / `VAPI_PRIVATE_KEY`), which can create calls, assistants, and phone calls on the account.
- Alternative: JWTs signed with the private key carrying `orgId`, `token.tag` (public/private), `token.restrictions` `{ allowedOrigins, allowedAssistantIds, allowTransientAssistant }`; or a proxy that maps a validated user to a server-chosen assistant.
- Anti-patterns: private key in a bundle; public key with no origin or assistant restriction (an unrestricted public key lets any site start calls on the account — Cat 04 posture, Medium, capped when the restriction is dashboard-side and not exported); `vapi.start(assistantId, assistantOverrides)` where the client supplies `model.messages`, `tools`, `variableValues` (Cat 11); transient assistants built from client input.

## Tools (H6)

- Shape: `{ "type": "function", "function": { name, description, parameters }, "server": { "url", "secret" | "credentialId" }, "async": false, "messages": {...} }` under `model.tools[]` or created as `/tool` resources. Tool-call webhook: `message.type == "tool-calls"`, `message.toolCallList[]` with `id`, `function.name`, `function.arguments`; response `{ "results": [{ "toolCallId", "result" }] }`.
- Server-trusted values: static `parameters` on the tool merge into the request without the model seeing them, and `message.call.customer.number` arrives in the server message. Account identifiers taken from `function.arguments` instead are Cat 12.
- LiquidJS variables in tool URLs, headers and bodies are an injection and SSRF surface (Cat 08 / snitch-security Cat 05).
- Built-in types: `transferCall` (with `destinations[]`), `endCall`, `dtmf`, `sms`, `voicemail`, `apiRequest`, `handoff`, `mcp`, `make`, plus agentic `bash`, `computer`, `textEditor`. An agentic shell or computer tool on a phone agent is Cat 13 Critical on its own; `apiRequest` with an LLM-filled URL is Cat 16 / snitch-security Cat 05; `mcp` is snitch-security Cat 45.

## Call control (H7)

- `transferCall` tool with `destinations[]` (number or SIP, `message`, `transferPlan` mode). A destination list that is fixed in the tool config is Cat 14 Pass; a destination assembled from `variableValues`, `assistantOverrides`, or a free-string parameter is the unrestricted-destination row.
- Outbound: `POST /call/phone` with `customer.number`, `phoneNumberId`, `assistantId`; an app route that takes `number` from a form and calls it is Cat 14 open-outbound-endpoint.
- `dtmf` tool sends digits; `endCall` / `endCallPhrases` end the call (Cat 20).
- Caller ID is the `phoneNumberId` resource; country restrictions on outbound are dashboard-side (Rule 6).

## Limits (H10)

- `maxDurationSeconds` (documented default 600); `silenceTimeoutSeconds`; ended reasons `exceeded-max-duration`, `silence-timed-out`, `*-llm-failed-429`. Default account concurrency is 10 simultaneous calls (unverified — confirm in the platform docs). Spend caps are account-side.

## Recording, transcripts, retention, redaction (H9)

- `artifactPlan.recordingEnabled` defaults to **true**; transcripts default on via `artifactPlan.transcriptPlan`; both land in the dashboard and in the `end-of-call-report` server message, plus `artifactPlan.recordingPath` for S3/GCS export.
- `hipaaEnabled` / `compliancePlan.hipaaEnabled` disables storage of logs, recordings and transcripts (Enterprise plus BAA required); `compliancePlan.pciEnabled` (default false) does the same for PCI. These disable storage; they do not redact.
- Whatever the app logs from `end-of-call-report` (full transcript, recording URL) is the app's record — Cat 21.

## Disclosure surfaces (H8)

- `firstMessage` (with `firstMessageMode`), `model.messages[0]` (system prompt), `voicemailDetection` message.

## What the platform already handles (do not flag)

- The public key in a browser is by design; flag only the private key, or an unrestricted public key.
- `transferCall` with fixed `destinations[]` is a server-resolved destination; do not flag it as caller-influenced without a trace showing the list is built at runtime.
- `hipaaEnabled: true` with an exported config is a Pass for Cat 21 storage rows.
- The platform verifies its own carrier webhooks; Cat 01 on a Vapi workspace is about the app's server URL and tool webhooks, not the carrier leg.


## Workspace shapes

The insecure dispatcher, seen in most starter repos:

```ts
app.post("/vapi", express.json(), async (req, res) => {
  const { message } = req.body;
  if (message.type === "tool-calls") {
    for (const call of message.toolCallList) results.push(await runTool(call.function.name, call.function.arguments));
  }
  if (message.type === "assistant-request") return res.json({ assistant: buildAssistant(req.body) });
  res.json({ results });
});
```

No header check, tool arguments run as-is, and the assistant returned for the call is built from the request. The guarded shape checks the secret first and takes identity from the server message:

```ts
if (!timingSafeEqual(Buffer.from(req.header("x-vapi-secret") ?? ""), Buffer.from(process.env.VAPI_SERVER_SECRET!))) return res.sendStatus(401);
const accountId = await lookupByNumber(message.call.customer.number); // never from function.arguments
```

The client override that Cat 11 looks for:

```ts
vapi.start(assistantId, { model: { messages: [{ role: "system", content: promptFromPage }] }, variableValues: { name: userInput } });
```

## Trace hints

- Tool arguments enter at `message.toolCallList[i].function.arguments` (a JSON string); follow `JSON.parse` of it into the handler.
- Dynamic variables enter the prompt through `{{name}}` in the assistant's `model.messages` — resolve where `variableValues` is set (client, `assistant-request` response, or the outbound-call creator).
- The `end-of-call-report` message carries `artifact.transcript`, `artifact.recordingUrl`, `analysis.summary`; follow what the handler does with each.
- An exported assistant JSON is the config of record for Cats 10, 17, 21; without it those rows Skip under Rule 6.

## Category quick map

| Cat | Row this stack most often fires on | Inherent Rule 6 Skips |
|---|---|---|
| 01 | server URL / tool webhook with no `x-vapi-secret` or credential check; custom-LLM endpoint unauthenticated | credential definition when not exported |
| 03 | private key in a bundle | — |
| 04 | unrestricted public key; token endpoint absent while client builds assistants | origin / assistant restriction in dashboard |
| 08 | `{{customer.name}}` in the system prompt; LiquidJS in tool URLs | — |
| 10 | system prompt inline in the web SDK call (shipped to client) | prompt when only in dashboard |
| 11 | `assistantOverrides` from client; transient assistants; unverified `assistant-request` | `allowTransientAssistant` setting |
| 12 | account id from `function.arguments`; tool `server.url` with no secret | — |
| 13 | `bash` / `computer` / `textEditor` tools; `sms` / `apiRequest` with no confirmation | — |
| 14 | `destinations[]` built from variables; `/call/phone` from a form | outbound country permissions |
| 17 | `maxDurationSeconds` / `silenceTimeoutSeconds` unset in an exported config | values when only in dashboard |
| 19 | — | spend caps, concurrency |
| 21 | `recordingEnabled` left true with transcripts forwarded to automation over unsigned URLs | dashboard retention |
