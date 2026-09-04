## CATEGORY 68: Agent & Indirect Prompt Injection
> Type: sink-pattern · Groups: modern-stack · CWE: CWE-1427

Category 15 (AI API Security) covers the LLM-API boundary (keys, output handling, direct prompt injection at the chat input, cost controls). This category targets the *agent / tool-use* layer, where untrusted data reaches the model through retrieval, tool output, or upstream side-channels — the attacker never types into the prompt, but still steers the model.

**Data flow tracing required (SKILL.md Rule 7).** Trace retrieved content, tool output, and shared memory into the prompt, then into the tools, protected context, or downstream operations available to the model. An attacker-influenced source is a candidate, not a Finding by itself. Establish who can modify it and the unauthorized effect a steered model can cause. Hardcoded prompt text clears only that input source; it does not clear other messages or tool results.

### Detection
- Agent frameworks: LangChain, LangGraph, LlamaIndex, CrewAI, AutoGen, Semantic Kernel, Anthropic Claude Agent SDK, OpenAI Agents SDK, Vercel AI SDK with `tools:`, Mastra
- Tool-use / function-calling code (`tools:` array, `@tool` decorators, JSON-schema tool definitions)
- Retrieval-augmented generation: vector DB reads (`pinecone`, `weaviate`, `chroma`, `pgvector`, Cloudflare Vectorize) whose chunks are interpolated into a prompt
- Fetch-then-summarize patterns: URL → text → into prompt
- Any path where a message-role=`system` or `assistant` string is constructed by concatenating untrusted content

### What to Search For
- RAG chunks inserted into a system or assistant prompt with no fence, marker, or instruction to treat them as data
- Tool outputs (shell, HTTP, SQL, file read) returned to the model as raw strings without a "this is data, not instructions" preamble
- Emails, PDFs, PRs, Jira tickets, Slack messages, web pages, or user-uploaded files being summarized by the model
- Tool schemas that expose destructive or exfiltration-capable actions (send email, write file, make HTTP request, execute code, post to webhook) callable without a human confirmation step
- Tools registered with wider permissions than the stated purpose needs — write or delete where only read is used, a shell/command-execution tool on an agent whose job is retrieval
- Admin-scoped credentials (database superuser, cloud root key) handed to a tool function instead of a scoped role
- Model output directly invoked as a tool call with no policy check (unrestricted `allowed_tools` in agent loops)
- No distinction between the *initial* user turn and *retrieved* content in prompt construction
- No max tool-calls / max-turns cap in the agent loop
- Tool call results being written back into a shared memory / thread that downstream prompts read without provenance tags

### Actually Vulnerable
- Attacker-writable retrieved content or tool output reaches a model that can send data, modify records, or execute commands beyond the user's authorized task without an effective external control
- The same path with labeled content and a system instruction to ignore embedded directives: those instructions do not enforce tool authorization
- A model with read access to protected context can return that context to an unauthorized audience; read-only tools do not alone clear disclosure risks
- Model output is automatically executed, published, or used for an authorization decision without a control that prevents the unauthorized effect
- Attacker-influenced agent loops can consume unbounded resources with no effective iteration, tool-call, or upstream budget limit; identify the reachable loop and resource impact

### NOT Vulnerable
- For a specific action, trusted code disables it or validates its operation, arguments, destination, and caller permissions against independently established user intent
- An approval gate outside the model binds the user's approval to the actual action and arguments before execution; approving a different action or a generic agent session does not suffice
- A draft-only summarizer with no tools, protected context, or downstream execution/publication has no demonstrated unauthorized-action path. Record that scoped Pass without claiming the text is immune to manipulation
- A source demonstrably writable only by actors already authorized for the resulting effect clears that source's injection path. The label "internal" alone is not proof of this trust relationship

Prompt delimiters, system instructions, tool names on an allowlist, and minimum-permission
credentials are useful layers, but none alone proves that an allowed tool's arguments or effects
are authorized. Evaluate each reachable effect; a blocked write does not clear a separate read
or disclosure path. These criteria govern the search patterns above.

### Context Check
1. Can an attacker place content where the model will later read it (documents, tickets, pages, messages)?
2. Does the prompt clearly separate user intent from retrieved/tool content?
3. What tools does the agent have, and which are destructive or exfiltration-capable?
4. Which checks outside the model bind each action and its arguments to the user's authority? Does approval cover the exact action executed?
5. Is there a cap on tool-call count / recursion depth?
6. Can tool output or a draft summary reach protected context, an external audience, or downstream execution? Labels do not answer this.

### Evidence Chain
- The prompt-assembly sink quoted at file:line where untrusted content is interpolated (prompt template substitution, system-string concatenation, tool-output feedback into the next turn)
- The traced path from content source to the prompt, hop by hop with file:line (vector-DB read, URL fetch, uploaded document, email body, another agent's tool output, shared memory/thread)
- Source classification — who can write to that source (public upload, web crawl, third-party API, index poisoning, another agent) — stated as the trust-boundary claim
- Controls checked: distinguish advisory prompt labels from enforced permissions, argument checks, exact-action approvals, and resource limits; explain why the controls do or do not stop the specific effect
- The consequential surface: reachable tools, protected context and output audience, downstream execution/publication, or resource consumption. Name the unauthorized effect; raw retrieval alone is insufficient

### Confidence Scoring
- **High**: complete source → prompt → consequential surface trace, with the missing effective control established. Advisory labels do not reduce confidence in that trace
- **Medium**: source and effect are established but a named external control's effectiveness remains uncertain
- **Low**: source or consequential path cannot be fully traced — tag `needs human verification`; do not assert an attacker-writable source from an "internal" or "external" label alone

Severity follows the demonstrated impact and authority exposed. Tool availability alone does not
make a Finding Critical; distinguish unauthorized communication from destructive operations or
protected-data disclosure and state the preconditions.

### Files to Check
- `**/agents/**`, `**/tools/**`, `**/rag/**`, `**/retrieval/**`
- Agent loop / executor code (anywhere that iterates `while more_tool_calls`)
- Prompt template files (`*.prompt.md`, `*.mustache`, `*.hbs`, system-prompt string constants)
- Vector DB query + prompt-assembly code
- Workflow / scheduled agent runners (where the human is not in the loop by default)

### Reference
- CWE-77: Improper Neutralization of Special Elements used in a Command
- CWE-1427: Improper Neutralization of Input Used for LLM Prompting
- OWASP LLM Top 10 (2025): LLM01 Prompt Injection, LLM06 Excessive Agency
- OWASP Top 10:2025 — A03 Software Supply Chain Failures (for tool supply chain)
- CVSS 4.0: varies with the demonstrated unauthorized effect and its preconditions
