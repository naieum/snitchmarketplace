## CATEGORY 16: Tool results and errors reaching speech or sinks
> Type: sink-pattern · Groups: injection · Hop: H6 Tool dispatch · Standards: CWE-209; OWASP LLM05

What comes back from a tool goes two places: into the model's context, where it becomes the next
thing the agent says, and — through the model — into the next tool's arguments, where it becomes a
query. Both directions leak. A handler that returns the raw backend response hands the model a
full customer object, an internal hostname, or a stack trace, and the model reads it aloud in a
pleasant voice. A handler that lets the model's text become a SQL fragment, a shell argument, a
file path, or a URL lets whoever steered the model write to that sink. This category reads every
tool handler's return value and error path, and every place model output becomes an argument to
something other than the caller's ear.

**Call-path tracing required (anti-hallucination Rule 3).** Two traces. Outward: from the backend
response or the thrown error, through the tool's return value, to the model — a return that is
shaped (selected fields, a fixed error message) is a Pass; a raw pass-through is a finding when the
raw content includes internal or personal data. Inward: from the model's output (tool arguments,
generated text) to any sink other than synthesis — SQL, shell, filesystem, HTTP URL, template, email
body — with parameterization or validation at the sink being the control.

**Boundary.** This category judges the shape of what tools return and what model output is allowed
to touch. The SQL, command, path, and URL sinks themselves belong to snitch-security's Cats 01, 05,
10, and 30 — hand off by calling the Skill tool with "snitch-security"; this category names the hop
and the voice-borne argument. Whether a retrieved record carries instructions is Cat 09. Whether
sensitive data is redacted before storage is Cat 22. Whether the spoken result reaches a caller who
was never verified is Cat 06. Whether the agent goes silent or hangs up on an error is Cat 20.

### Detection
- Tool handler return statements: `return result`, `return { result: JSON.stringify(data) }`,
  `results: [{ toolCallId, result }]`, Retell tool responses, ElevenLabs webhook tool responses,
  LiveKit `@function_tool` return values, Pipecat `result_callback(...)`, Deepgram
  `FunctionCallResponse`, OpenAI Realtime `conversation.item.create` with
  `function_call_output`, Gemini `toolResponse`
- Error handling around backend calls in tool handlers: `catch (e) { return e.message }`,
  `return { error: String(err) }`, `err.stack`, `traceback.format_exc()`
- Model output consumers other than TTS: string-built SQL, `exec` / `spawn` / `subprocess`,
  `fs.*` with a model-derived path, `fetch(args.url)`, `axios.get(model text)`, template engines
  rendering model text as HTML or email, `eval`
- "Text-to-query" or "natural language to SQL" tool patterns
- Output filters before synthesis: PII scrubbers, allowlisted response templates, moderation
  passes, canary checks

### What to Search For
- Full backend objects returned to the model: customer records with SSN, DOB, card last-four,
  addresses, other household members; order objects with payment details; EHR objects
- Raw error text returned: exceptions, stack traces, database errors, HTTP error bodies with
  internal URLs, provider error messages carrying request IDs and hostnames
- Internal identifiers and URLs in tool results (`internalId`, `adminUrl`, `s3://`, private IPs)
- Model-derived values in SQL strings, `WHERE name = '${args.name}'`
- Model-derived shell arguments or file paths
- Model-derived URLs fetched by a "lookup" or "browse" tool with no allowlist (the voice agent as
  an SSRF proxy)
- Model text rendered into HTML email or a web page without escaping
- Tool results larger than the model needs (whole table dumps) — also a cost signal, cite Cat 19
- No shaping layer: a `select`/`pick` of fields, a DTO, a response schema, absent across the
  tool handlers
- No output guard between the model and TTS: the model's text goes straight to synthesis

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| raw-record-to-model | A tool returns a backend object containing personal, financial, health, or credential fields beyond the tool's purpose | handler file:line + the fields | High (Critical if credentials or full card/SSN) |
| raw-error-to-model | Exception text, stack traces, or provider error bodies are returned to the model | handler file:line | Medium (High if they carry internal URLs, credentials, or query text) |
| model-output-to-query-sink | Model-derived text reaches SQL, shell, filesystem, or eval without parameterization or validation at the sink | trace + sink file:line | Critical |
| model-output-to-url | A tool fetches a model- or caller-derived URL with no allowlist | trace + fetch file:line | High |
| model-output-to-markup | Model text rendered as HTML, email, or a document without escaping | trace + render file:line | High |
| no-response-shaping | No shaping layer exists across tool handlers (structural; reported once, Medium, only when a raw-record finding also exists) | the search | Medium |
| no-output-guard | Nothing between model text and synthesis checks for secrets, PII, or prompt fragments | the search | Low (advisory; never the only finding) |

### Actually Vulnerable

#### Critical
- `db.query(\`SELECT * FROM accounts WHERE name = '${args.customerName}'\`)` in a tool handler
- `exec(\`lookup ${args.orderId}\`)`, `fs.readFile(args.path)`, `eval(args.expression)`
- A tool result that includes a credential, a full card number, or an SSN

#### High
- `return customer` where the record includes DOB, address, card last-four, or health fields
  and the tool's purpose is narrower
- `return { error: err.stack }` or an error body carrying an internal hostname, a database
  name, or the failed query
- `fetch(args.url)` with no allowlist; a "read this page to me" tool
- Model text into an HTML email template unescaped

#### Medium
- Generic `err.message` returned to the model
- Whole-table or whole-history results with no field selection
- No shaping layer anywhere, alongside a raw-record finding

### NOT Vulnerable
- Handlers return a selected, purpose-sized shape (`{ nextAppointment, location }`) — Pass
  quoting the selection
- Errors mapped to fixed, caller-safe messages (`"I couldn't reach the scheduling system"`) with
  the real error logged server-side — Pass quoting the mapping
- Model-derived values reach SQL only through parameterized queries or an ORM with bound
  parameters — Pass quoting the call; the sink's own correctness remains snitch-security's
- URL tools restricted to an allowlist of hosts or to server-constructed URLs
- Model text rendered only as plain text or escaped — Pass quoting the escape
- An output guard present before synthesis — Pass evidence, recorded, never required
- No tools with backend calls (pure conversational agent) — Skip, `not applicable`, with the
  inventory

### Context Check
1. For each tool: what does the backend return, and what does the handler return to the model?
   Diff them.
2. What does the error path return?
3. Does any model output become an argument to something other than TTS? Follow every tool
   argument into the handler.
4. Is there a shaping layer or a response schema the handlers share?
5. Is there anything between model text and synthesis?

### Evidence Chain
- The handler file:line and its return statement
- The backend response shape (from the query, the SDK type, or a sample) and the fields that
  pass through
- The error path file:line and what it returns
- For inward traces: the path from the model's output to the sink, hop by hop, and the
  parameterization or validation checked at the sink
- The shaping layer or output guard found, or the searches establishing their absence

### Confidence Scoring
- **High**: the return statement demonstrably passes a record with sensitive fields, or a
  model-derived value demonstrably reaches an unparameterized sink
- **Medium**: the backend shape is inferred from a type or a helper not fully read, or a
  shaping layer may exist in a service the handler calls
- **Low**: the tool's return path or the sink could not be resolved → tag `needs human
  verification`

### Severity
Critical is model output reaching a query, command, or file sink, or credentials in a tool
result. High is personal or financial records over-returned, errors that leak internals, an
open URL fetch, or unescaped markup. Medium is generic error leakage and structural absence of
shaping. Low is the advisory output guard.

### Files to Check
- `**/tools/**`, `**/functions/**`, `**/handlers/**`, `**/actions/**`
- `**/services/**`, `**/repositories/**`, `**/db/**` (what the backend actually returns)
- `**/dto/**`, `**/schemas/**`, `**/serializers/**` (shaping layers, as Pass evidence)
- `**/tts*`, `**/synthesis*`, `**/output*`, `**/guard*` (output guards)
- `**/email/**`, `**/templates/**` (model text into markup)

### Reference
- CWE-209: Generation of Error Message Containing Sensitive Information
- CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
- CWE-89 / CWE-78 / CWE-22 / CWE-918 for the sinks (owned by snitch-security)
- OWASP LLM Top 10 (2025): LLM05 Improper Output Handling, LLM02 Sensitive Information Disclosure
- Per-platform tool response shapes: `references/stacks/<platform>.md`
