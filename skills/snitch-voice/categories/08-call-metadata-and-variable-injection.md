## CATEGORY 08: Injection through call metadata and dynamic variables
> Type: sink-pattern · Groups: injection · Hop: H4 Prompt assembly · Standards: CWE-1427; OWASP LLM01

The caller never has to speak the injection. The call arrives with a caller name from a
third-party lookup, a `From` number, a city and state, and on SIP trunks whatever headers the
sending system chose to set. Platforms then template those values into the prompt as dynamic
variables — greet them by name, mention their city — and web clients are allowed to pass their
own variable values and assistant overrides when they start a session. Every one of those is a
string an outside party controls, and every template that puts it in the instruction position lets
that party write part of the system prompt. The same variables, templated into tool URLs and
headers, become request-forgery surfaces. This category traces call metadata and client-supplied
variables into the prompt, the tool definitions, and the tool requests.

**Call-path tracing required (anti-hallucination Rule 3).** Trace each metadata field and dynamic
variable from its arrival (webhook body, platform call object, participant attributes, client
start call) to where it is rendered: a prompt template, a first message, a tool URL, a header, a
body. A value that is rendered only inside a `user`-role turn or a structured field the model
cannot interpret as instruction is a Pass; a value rendered into the system prompt, the first
message the agent speaks, a tool URL, or a header is a finding unless it is validated against a
strict shape before rendering.

**Boundary.** This category judges metadata and variables in the assembly hop. Whether the same
values are trusted as identity is Cat 05. Whether the client may override the assistant's
configuration at all — prompt, tools, model — is Cat 11; this category judges the variables that
flow into an otherwise fixed configuration. Transcribed speech is Cat 07; retrieved records are
Cat 09. A request-forgery finding at the tool sink is also snitch-security's Cat 05 — record the
hop here and hand off the sink by calling the Skill tool with "snitch-security".

### Detection
- Webhook fields: `From`, `To`, `CallerName`, `FromCity`, `FromState`, `FromCountry`, `FromZip`,
  `ForwardedFrom`, `caller_id_name`, custom `<Parameter name= value=>` arriving as
  `setup.customParameters`, Twilio `<Stream>` parameters, Vonage `custom_data`
- Platform variables: Vapi `{{customer.number}}`, `{{customer.name}}`, `variableValues`,
  `assistantOverrides`, `metadata`; Retell `retell_llm_dynamic_variables`, `dynamic_variables`,
  `{{variable}}`; Bland `request_data`, `{{variable}}`; ElevenLabs `dynamic_variables`,
  `{{var}}`, `system__caller_id`; LiveKit `participant.attributes`, `sip.h.*`,
  `headers_to_attributes`, job `metadata`; Pipecat `RTVI` client messages, `body` on `/connect`;
  Amazon Connect contact attributes
- Template engines rendering prompts: LiquidJS (`{{ }}`, `{% %}`), Jinja2, Handlebars, Mustache,
  f-strings and template literals in prompt builders
- Tool definitions with templated URLs, headers, or bodies: Vapi tool `server.url` with `{{ }}`,
  `headers` with variables; Retell custom tool `url` with `{{ }}`; ElevenLabs server tool
  `url` / `headers` with dynamic variables

### What to Search For
- `From`, `CallerName`, `FromCity`, or a platform `customer.*` / dynamic variable rendered into
  the system prompt, `instructions`, `first_message`, `firstMessage`, `welcomeGreeting`,
  `begin_message`, or any string the agent speaks first
- `variableValues` / `dynamic_variables` / `assistantOverrides.variableValues` accepted from a
  web or mobile client and rendered without a server-side allowlist of keys and a shape check on
  values
- SIP headers mapped to attributes (`headers_to_attributes`) and those attributes rendered into
  the prompt or used to select a prompt
- Custom `<Parameter>` values or `setup.customParameters` echoed into the prompt or into
  `handoffData`
- Variables templated into tool `server.url`, `url`, path segments, query strings, or headers —
  a caller-influenced value that changes where a tool request goes or what it carries
- Variables templated into the tool's request body as raw JSON without encoding
- Template engines with logic tags enabled (`{% %}`) on caller-influenced input
- No length cap, character class, or shape check on rendered metadata (a name field accepting
  hundreds of characters of punctuation)
- Prompt selection keyed by metadata (`prompts[FromState]`, `assistant = byCallerName[...]`)
  with no allowlist
- Outbound calls: the campaign row's fields (name, notes, reason) rendered into the prompt — a
  CRM-writable source, which is also Cat 09's judge

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| metadata-in-instruction-position | A caller-influenced metadata field or client-supplied variable renders into the system prompt, instructions, or the agent's first spoken message with no shape validation | trace from arrival to the template | Critical |
| variable-in-tool-url-or-header | A caller-influenced variable renders into a tool URL, path, query, or header | trace from arrival to the tool definition or request builder | Critical |
| client-variables-unfiltered | Client-supplied `variableValues` / `dynamic_variables` are accepted with no server-side key allowlist and value shape check | the accept point + the search for the filter | High |
| sip-headers-trusted | External-trunk SIP headers map to attributes the prompt or routing reads | the mapping + the read | High |
| parameters-echoed | Custom stream parameters or `customParameters` render into the prompt or hand-off data | the render point | High |
| metadata-selects-prompt | Metadata keys a prompt or assistant lookup with no allowlist | the lookup | Medium |
| template-logic-on-input | The template engine evaluates logic tags on caller-influenced values | the engine config + the input | Medium |
| unbounded-render | Rendered metadata has no length or character-class limit (advisory when the render position is a user turn) | the template + the absent check | Low |

### Actually Vulnerable

#### Critical
- `systemPrompt = template.replace('{{name}}', req.body.CallerName)` where the result is the
  system message
- Vapi assistant `model.messages[0].content` containing `{{customer.name}}` with the name taken
  from CNAM or a client `variableValues`
- Retell `begin_message` rendering `{{caller_name}}` from `retell_llm_dynamic_variables` the
  web client sets
- Vapi tool `server.url: "https://api.example.com/accounts/{{customer.number}}/balance"`
- ElevenLabs server tool header `X-Account: {{account_id}}` where `account_id` is a client
  dynamic variable

#### High
- `vapi.start(assistantId, { variableValues: formValues })` proxied straight through
- LiveKit `headers_to_attributes: { 'X-Customer-Id': 'customer_id' }` on a trunk from an
  external carrier, with `customer_id` read into the prompt
- `handoffData: JSON.stringify(setup.customParameters)` handed to a human-agent system that
  renders it

#### Medium
- `prompts[req.body.FromState] ?? prompts.default`
- LiquidJS with logic tags on client variables

### NOT Vulnerable
- Metadata rendered only into a `user`-role context block or a structured field with a fixed
  label, never into the system prompt or the first spoken line — quote the assembly
- Client variables filtered server-side through an allowlist of keys with per-key shape checks
  (a name limited to letters, spaces, and a short length; an ID matched to the session's own
  user) before rendering — quote the filter
- Tool URLs and headers fixed at definition time, with caller-influenced values only in the
  body as structured JSON — quote the definition
- SIP header mapping only on a trunk from an authenticated, internal source (quote the trunk
  credentials) and the attributes used for routing, not for prompt content
- Prompt selection through an allowlist map with a safe default
- No dynamic variables or metadata rendering in the workspace — Skip, `not applicable`, with the
  search

### Context Check
1. Which metadata and variables does this agent render, and from where do they arrive?
2. For each, what position does it land in: system prompt, first message, user context, tool
   URL, header, body?
3. Who can set the value: the network, a third-party lookup, the client, a CRM row?
4. Is there a server-side filter between arrival and rendering?
5. Does the template engine evaluate logic on the value?
6. Can the value change which prompt or assistant runs?

### Evidence Chain
- The arrival file:line (webhook field, platform object, attribute mapping, client start call)
- Each hop to the render point, with file:line
- The template or builder file:line with the position quoted
- Filters checked and found absent: key allowlist, shape check, length cap, encoding
- Source classification: network metadata, third-party lookup, SIP header, client variable, CRM
  row

### Confidence Scoring
- **High**: complete trace from an outside-controlled value to the system prompt, first message,
  tool URL, or header
- **Medium**: the template is platform-side and only partially exported, or a filter may exist
  in a proxy not in the workspace
- **Low**: the variable's arrival could not be traced — tag `needs human verification`

### Severity
Critical is an outside-controlled value in the instruction position or in a tool's destination.
High is an unfiltered client variable channel, trusted external headers, or echoed parameters.
Medium is prompt selection and template logic. Low is render hygiene on values already confined to
a user turn.

### Files to Check
- `**/prompt*`, `**/template*`, `**/*assistant*.json`, `**/*agent*.json`, `**/pathway*`
- `**/incoming*`, `**/assistant-request*`, `**/call-start*`, `**/connect*`, `**/start*`
- `**/tools/**` (definitions with URLs and headers), `**/variables*`, `**/overrides*`
- `**/trunk*`, `**/dispatch*`, `**/sip/**`
- Client code that starts sessions: `**/useVoice*`, `**/VoiceWidget*`, `**/call.ts`

### Reference
- CWE-1427: Improper Neutralization of Input Used for LLM Prompting
- CWE-918: Server-Side Request Forgery (variables in tool URLs)
- CWE-113: Improper Neutralization of CRLF Sequences in HTTP Headers (variables in tool headers)
- OWASP LLM Top 10 (2025): LLM01 Prompt Injection
- MITRE ATLAS: AML.T0051.001 LLM Prompt Injection (indirect)
- Per-platform variable names and template engines: `references/stacks/<platform>.md`
