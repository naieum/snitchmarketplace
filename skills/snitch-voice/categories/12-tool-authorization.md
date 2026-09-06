## CATEGORY 12: Tool webhook authentication and per-call authorization
> Type: sink-pattern · Groups: quick, actions · Hop: H6 Tool dispatch · Standards: CWE-306, CWE-639; OWASP LLM06

A tool call is the model asking your backend to do something on the caller's behalf. Two things
have to be true before the backend obliges: the request really came from the platform running
this call, and the thing it asks for belongs to the caller on this call. Both fail quietly. The
tool webhook is often deployed with no secret because the quickstart had none, so anyone who
learns the URL can invoke "lookupAccount" or "issueRefund" directly. And the account identifier
the handler uses is often whatever the model put in the arguments — which is whatever the caller
said — so a caller who reads out someone else's account number gets someone else's balance. This
category traces every tool handler from the arriving request to the backend query and asks who
authenticated the request and who authorized the object.

**Call-path tracing required (anti-hallucination Rule 3).** Trace two things per tool handler:
the authentication of the request (which header or secret is checked before the handler runs), and
the origin of every identifier that selects a record (account, customer, appointment, order,
tenant). An identifier that comes from a server-trusted field the platform populated — the call's
customer number bound at session start, a static parameter merged server-side, a session lookup
keyed by call ID — and that has passed verification (Cat 06) is a Pass. An identifier that comes
from `function.arguments` / the model's tool-call payload and reaches a query unchecked is a
finding.

**Boundary.** This category judges *who* may invoke a tool and *whose* data it touches. Whether
the platform's signature is checked on the route is Cat 01 (this category reads that result and
does not re-report it; a tool route with no signature is Cat 01's Critical and this category's
context). Whether the caller was verified before the tool ran is Cat 06. Whether a consequential
tool asks for confirmation is Cat 13. Where a dial or transfer goes is Cat 14; what a message tool
sends is Cat 15; what the tool's output does on the way back is Cat 16. The SQL string an
identifier reaches is snitch-security's Cat 01, and an IDOR on a non-voice API is its Cat 28 —
hand off by calling the Skill tool with "snitch-security"; this category names the hop and the
voice-borne argument.

### Detection
- Tool-call ingress: Vapi `tool-calls` / `function-call` server messages with `toolCallId` and
  `server.url`; Retell custom tools (`type: "custom"`, `url`) and the custom-LLM
  `llm_websocket_url`; Bland `tools[]` with `url` and `headers`; ElevenLabs server tools
  (`webhook` tools) and client tools; OpenAI Realtime `response.function_call_arguments.done`
  handlers; Gemini Live `toolCall` handlers; Deepgram `FunctionCallRequest` handlers and
  `agent.think.functions[].endpoint`; LiveKit `@function_tool` / `llm.function_tool`; Pipecat
  `register_function` / `FunctionSchema`; Twilio ConversationRelay `prompt` handling that
  dispatches to functions; Amazon Lex code hooks / Bedrock agent action groups
- Handlers that resolve `args`, `parameters`, `function.arguments`, `toolCall.function.arguments`,
  `arguments`, `input` into a database, CRM, scheduling, billing, or EHR call
- Static or server-trusted fields: Vapi tool `parameters` merged server-side, `call.customer`,
  `message.call.id`; Retell `call.metadata`, `retell_llm_dynamic_variables` set server-side;
  LiveKit `participant.attributes` set by the trunk or dispatch rule; session stores keyed by
  `callSid` / `call_id` / `room`
- Tool auth configuration: `server.credentialId`, `serverUrlSecret`, `X-Vapi-Secret`,
  `Authorization` headers on tool definitions, Retell IP allowlists or URL-path secrets, Bland
  "secrets" references, Deepgram `endpoint.headers`

### What to Search For
- Tool webhooks with no secret, no credential, and no signature check reachable in the route's
  middleware chain (cite Cat 01's result; do not re-score it)
- Retell custom-LLM websocket servers accepting any connection: no secret path segment, no IP
  allowlist, `ws://` rather than `wss://`
- Deepgram `functions[].endpoint.headers` carrying a bearer token that is then trusted by the
  tool endpoint as proof of platform origin while the `Settings` message is client-built (Cat 11
  reports the client build; here, report the endpoint trusting it)
- Handlers that read `accountId`, `customerId`, `phone`, `email`, `orderId`, `appointmentId`,
  `patientId`, `memberId` from the model's arguments and use them to select the record
- Handlers that look up "the caller" by a phone number in the arguments rather than by the
  call's bound customer number
- No tenant scoping: a multi-tenant deployment where the tool queries across all tenants by the
  spoken identifier, or where the tenant is chosen by a model argument
- No check that the record returned belongs to the verified caller (verification status held in
  the session store but never consulted in the tool)
- Tool handlers that accept `callId` / `callSid` from the arguments instead of the platform's
  envelope, so a forged request can claim any call
- Read tools that return more than the model needs: full profile, balance, card last-four, other
  household members, when the tool's purpose is "confirm the appointment time"
- Tools registered with admin or service-account credentials rather than a caller-scoped role,
  where a scoped role is available

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| unauthenticated-tool-ingress | A tool webhook or custom-LLM socket runs the handler with no platform secret, credential, signature, or allowlist on its path (context from Cat 01; reported here only for sockets and secret-less schemes Cat 01 does not cover) | route file:line + the absent check | Critical |
| identifier-from-model | A record-selecting identifier comes from the model's tool arguments and reaches the query with no binding to the call's verified identity | trace + query file:line | Critical for money, health, or credential data; High otherwise |
| tenant-from-model | The tenant, org, or workspace is chosen by a model argument or a spoken value | trace + query file:line | Critical |
| call-envelope-spoofable | The handler trusts `callId` / `callSid` / `call.customer` from the arguments instead of the platform envelope or the session store | trace | High |
| verification-not-consulted | A verified-status flag exists in the session but the tool does not read it before returning or changing protected data | session write file:line + handler file:line | High |
| over-broad-read | A read tool returns fields beyond its stated purpose to the model | handler file:line + the schema's stated purpose | Medium |
| over-privileged-credential | The tool runs with an admin or service credential where a scoped one exists in the codebase | credential file:line | Medium |

### Actually Vulnerable

#### Critical
- `const { accountId } = JSON.parse(toolCall.function.arguments); const acct = await
  db.accounts.findById(accountId)` returning balance, transactions, or card data
- A refund, payment, address-change, or prescription tool selecting its target by a model
  argument with no session binding
- A Retell custom-LLM websocket at `wss://host/llm` with no secret segment and no allowlist, or
  a Vapi/Bland/ElevenLabs tool URL with no credential where the platform supports one
- Tenant selected by `args.orgId` or by a spoken company name

#### High
- Caller looked up by `args.phoneNumber` rather than the bound customer number
- `callSid` taken from the body to fetch session state
- Session store records `verified: true` after Cat 06's flow, but the tool handler never checks it
- Any identifier-from-model path on non-financial, non-health data (appointments, orders,
  loyalty points)

#### Medium
- A "get profile" tool returning the whole customer object to the model
- Tool backend called with a root database URL or a service-account key where a caller-scoped
  token or row-level policy exists elsewhere in the codebase

### NOT Vulnerable
- The handler resolves the caller from the platform envelope (`message.call.customer.number`,
  the session keyed by the envelope's call ID) or from a static parameter merged server-side, and
  the record query is scoped to that identity — Pass quoting the binding and the query
- The tool is a pure lookup on public data (store hours, branch address) with no identifier
- The identifier from the model is used only *after* it is compared to the bound identity
  (`if (args.accountId !== session.accountId) return denied`) — Pass quoting the check
- Row-level security or a tenant-scoped connection established from the session, not the
  arguments — Pass quoting the policy and the connection setup
- Verification status read from the session store before any protected read or write
- No tools that touch per-caller data (pure informational agent) — Skip, `not applicable`, with
  the tool inventory

### Context Check
1. List every tool. For each: does it read or change per-caller data? Only those carry
   identifier rows.
2. How does the handler know which call it is serving? Envelope, session store, or arguments?
3. Where does every record-selecting identifier come from? Follow it from the arguments or the
   envelope to the query.
4. Is the identity it is bound to a *verified* identity (Cat 06), or just the caller ID?
5. Is the tenant fixed by deployment, by the number dialed, or by an argument?
6. What credential does the backend call run under, and is a narrower one available?
7. What does the tool return, and does the model need all of it?

### Evidence Chain
- The tool ingress file:line and its authentication (or Cat 01's finding number for the same
  route)
- The handler file:line and the argument parsing
- The traced path of each identifier from source (envelope / session / arguments) to the query,
  hop by hop with file:line
- The binding check or scoping found, or the search that established its absence
- Source classification: platform-envelope / server-static / session-bound / model-argument
- The credential the backend call uses

### Confidence Scoring
- **High**: complete trace from `function.arguments` to a record query with no binding, or a
  socket/webhook demonstrably reachable with no secret; or a bound-and-scoped Pass fully quoted
- **Medium**: the identifier passes through a helper or ORM layer whose scoping was not fully
  read, or an allowlist may exist at the network layer without an export
- **Low**: the argument-to-query path could not be traced → tag `needs human verification`

### Severity
Critical is an unauthenticated tool surface, or any path by which the caller's words select
whose money, health record, or credentials the tool touches, or which tenant it runs in. High is
the same path on lower-stakes data, a spoofable call envelope, or verification state that exists
but is never consulted. Medium is over-broad reads and over-privileged credentials. Low is not
used.

### Files to Check
- `**/tools/**`, `**/functions/**`, `**/handlers/**`, `**/actions/**`, `**/tool-calls*`,
  `**/function-call*`, `**/llm-websocket*`, `**/custom-llm*`
- `**/api/vapi*`, `**/api/retell*`, `**/api/bland*`, `**/api/elevenlabs*`, `**/api/tools*`
- `**/session*`, `**/call-state*`, `**/store*` (where verification and identity are bound)
- `**/db/**`, `**/repositories/**`, `**/services/**` (the queries the arguments reach)
- `**/*assistant*.json`, `**/*agent*.json` (tool definitions, static parameters, credentials)

### Reference
- CWE-306: Missing Authentication for Critical Function
- CWE-639: Authorization Bypass Through User-Controlled Key
- CWE-862: Missing Authorization
- OWASP LLM Top 10 (2025): LLM06 Excessive Agency
- OWASP Agentic Top 10 (2025): ASI03 Identity and Privilege Abuse
- How each platform delivers tool calls, which envelope fields are server-trusted, and how tool
  URLs are authenticated: `references/stacks/<platform>.md`
