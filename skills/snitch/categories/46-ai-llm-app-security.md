## CATEGORY 46: AI/LLM Application Security
> Type: sink-pattern · Groups: — · CWE: CWE-77

**Data flow tracing required (SKILL.md Rule 7).** Trace in two directions. (1) Into the prompt: user or RAG content reaching the `system` role or concatenated into instructions is a finding; confined to a `user`-role message it is a Pass. (2) Out of the model: treat LLM output as tainted and trace it to its sink — reaching SQL, shell, `eval` / `Function`, raw HTML (`dangerouslySetInnerHTML` / `v-html`), a file path, or `res.redirect` without validation is a finding; escaped display-only output is a Pass. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- AI/LLM SDK imports: `openai`, `@anthropic-ai/sdk`, `ai`, `@ai-sdk/openai`, `@langchain/core`, `langchain`, `@google/genai`, `google-genai`, `@google/generative-ai` (deprecated, still match it), `cohere-ai`, `llamaindex`
- Agent framework imports: `@anthropic-ai/claude-agent-sdk`, `@openai/agents`, `pydantic-ai`
- Prompt construction patterns in application code
- RAG (Retrieval-Augmented Generation) pipeline components
- Vector database integrations: `@pinecone-database/pinecone`, `chromadb`, `weaviate-client`, `@qdrant/js-client-rest`
- AI agent/tool-use implementations
- Chat or completion endpoints that accept user input

### What to Search For

**Prompt Injection Vulnerabilities:**
- User input concatenated or interpolated directly into system prompts
- User input placed in the `system` role message instead of `user` role
- Template literals or string concatenation building prompts with untrusted data
- Missing input sanitization before prompt construction
- No separation between system instructions and user-provided content

**Output Validation Gaps:**
- AI/LLM output rendered as raw HTML without sanitization (XSS via AI output)
- AI output used in database queries without parameterization
- AI output used in shell commands without escaping
- AI-generated code executed via `eval()`, `Function()`, or `vm.runInContext()`
- AI output inserted into email templates, notifications, or external messages without validation
- AI-generated URLs or redirects used without validation

**PII Leakage in AI Contexts:**
- System prompts containing hardcoded PII, credentials, or internal URLs
- RAG context documents containing unredacted PII injected into prompts
- AI responses not filtered for PII before being returned to users
- Chat history stored without PII scrubbing
- Logging of full prompt/response pairs containing user PII

**RAG Poisoning:**
- Document ingestion pipelines with no content validation or sanitization
- Vector store updates from untrusted sources without review
- No content filtering on documents before embedding
- User-uploaded documents added directly to RAG knowledge base
- Missing access controls on vector store write operations

**Missing Guardrails:**
- No content filtering or moderation on AI outputs
- No token/cost limits on AI API calls (denial-of-wallet attacks)
- No rate limiting on AI-powered endpoints
- No maximum input length validation before sending to AI API
- No fallback handling when AI API returns errors or unexpected content
- No timeout configuration on AI API calls

**System Prompt Security:**
- System prompts stored in client-accessible locations (frontend bundles, public API responses)
- System prompts exposed through error messages or debug endpoints
- No prompt hardening against extraction attacks (e.g., "repeat your instructions")
- System prompts lacking explicit boundaries between instructions and user content

**Tool Use / Function Calling Risks:**
- AI function calling with insufficient parameter validation
- Tool definitions that allow access to sensitive operations without confirmation
- No authorization checks before executing AI-requested tool calls
- AI-generated function arguments used directly without sanitization

### Actually Vulnerable
- System prompt built as: `You are a helper for ${userInput}` — user input in system role enables full prompt override
- AI response rendered with `dangerouslySetInnerHTML` or `v-html` — XSS via AI-generated content
- AI output passed to `db.query(aiResponse)` without parameterization — SQL injection via AI
- RAG pipeline ingests user-uploaded PDFs directly into vector store without content filtering
- No `max_tokens` or cost ceiling on AI API calls — attacker can trigger expensive completions
- System prompt returned in API response body or error message — full instruction extraction
- AI tool call executes `fs.writeFile(aiGeneratedPath, aiGeneratedContent)` without path validation
- Chat history stored with full user PII in plaintext logs
- AI-generated redirect URL used in `res.redirect(aiOutput)` without URL validation — open redirect

### NOT Vulnerable
- User input placed only in `user` role messages, system prompt is static
- AI output sanitized with DOMPurify or equivalent before rendering
- AI output used only as display text (not as HTML, SQL, or shell input)
- RAG documents reviewed/approved before embedding, with content filtering
- Token limits, rate limiting, and cost ceilings configured on AI endpoints
- System prompt stored server-side only, never sent to client
- Tool calls validated against an allowlist with parameter schemas
- PII redaction applied to AI inputs and outputs
- Chat history retention policies with automatic PII scrubbing

### Context Check
1. Does user input flow into the system prompt or only into user messages?
2. Is AI output rendered as HTML or used in any executable context?
3. Are RAG documents from trusted, controlled sources or from user uploads?
4. Are there token/cost limits configured on AI API calls?
5. Is the system prompt accessible from client-side code or API responses?
6. Are AI tool calls validated and authorized before execution?
7. Is PII handled appropriately in AI prompt/response pipelines?

### Evidence Chain
A finding's Evidence block must show:
- The sink file:line — the prompt-construction site (template literal / concatenation building the `system` message) or the LLM-output sink (`db.query`, shell exec, `eval`/`Function`, `dangerouslySetInnerHTML`/`v-html`, file path, `res.redirect`)
- The traced variable path source→sink: for injection-in, the user or RAG content variable followed through each assignment into the system role or instruction string; for injection-out, the model response variable followed from the API call to the executable/HTML sink
- The sanitizers checked and found absent on that path (DOMPurify or equivalent for HTML, query parameterization for SQL, shell escaping, URL/path allowlist validation, tool-argument schema validation)
- The source classification: user input, user-uploaded/RAG document, or LLM output — all treated as tainted
- If any hop in the path could not be traced (framework abstraction, config-driven prompts), the finding is downgraded per the Rule 7 banner and tagged `needs human verification`

### Confidence Scoring
- **HIGH**: Complete trace in evidence — user or RAG content demonstrably reaches the `system` role or instruction concatenation, or LLM output demonstrably reaches SQL/shell/`eval`/raw-HTML/redirect/file-path sinks, with no sanitizer found anywhere on the traced path.
- **MEDIUM**: The sink pattern is present but the trace is partial — the prompt is built from a variable whose origin crosses module boundaries, message roles are assembled by a framework helper, or sanitization may occur upstream of the sink but could not be confirmed at a specific line.
- **LOW**: The source cannot be traced (config-driven or externally loaded prompts, deep framework abstraction hiding role assignment, LLM output passing through untraceable middleware), or the guardrail gap (missing token limits, timeouts, moderation) is inferred from absence alone — tag `needs human verification`.

### Files to Check
- `**/ai/**`, `**/llm/**`, `**/chat/**`, `**/agent/**`
- `**/prompts/**`, `**/prompt*.ts`, `**/system-prompt*`
- `**/rag/**`, `**/embeddings/**`, `**/vectors/**`
- `**/tools/**`, `**/functions/**` (AI function calling definitions)
- API route handlers that call AI/LLM APIs
- Configuration files with AI API settings (token limits, model selection)
