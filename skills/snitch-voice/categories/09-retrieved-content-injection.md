## CATEGORY 09: Injection through retrieved records and tool results
> Type: sink-pattern · Groups: injection · Hop: H5 Retrieval · Standards: CWE-1427; OWASP LLM01

The caller may have written to the agent days before the call. A note left on a CRM record, a
subject line in a ticket, a calendar invite title, a knowledge-base article submitted through a
form, a voicemail left on the line, the text of the last call's transcript, the IVR menu of the
company an outbound agent is calling — all of it is read into the model's context mid-call and
all of it can carry instructions. A widely reported 2025 demonstration hid instructions in a
calendar invite and a mainstream voice assistant read them, opened devices, and exfiltrated data;
the follow-up showed the spoken confirmation the user heard could differ from the action taken. A
voice agent that reads records aloud or acts on them has the same shape. This category traces
every retrieval and tool result into the prompt and the next tool call, and asks whether the
model can tell data from instruction — and, since it cannot, what outside it prevents the effect.

**Call-path tracing required (anti-hallucination Rule 3).** Trace each retrieved value (a record
field, a search chunk, a tool's return, a transcript, a transcribed voicemail, a remote IVR's
speech) from its source to the prompt position it lands in and to any tool call it can influence.
A value rendered as labeled data in a `user` or tool-result role, with the consequential tools
gated outside the model (Cat 13), is a Pass for this category. A value rendered into the system
prompt, or feeding a tool argument that reaches a consequential sink with no external control, is
a finding. Provenance labels and "treat this as data" prompt lines are useful layers, never the
control.

**Boundary.** This category judges the retrieval hop on the call path. The same pattern in a
non-voice agent is snitch-security's Cat 68 — hand off by calling the Skill tool with
"snitch-security". Metadata that arrives with the call is Cat 08; the caller's own speech is Cat
07; whether the retrieval store is per-tenant is Cat 12; whether a steered tool call is confirmed
before it fires is Cat 13; raw tool output reaching the caller's ear is Cat 16.

### Detection
- Knowledge bases and search: Vapi `knowledgeBase`, `files`, query tools; Retell
  `knowledge_base_ids`; Bland `knowledge base` / `tools` with retrieval; ElevenLabs agent
  `knowledge_base`, RAG settings; vector stores (`pinecone`, `weaviate`, `chroma`, `pgvector`,
  `qdrant`); `similaritySearch`, `retrieve`, `query`
- CRM, calendar, ticket, and record reads in tool handlers: HubSpot, Salesforce, Zendesk,
  Google Calendar, Microsoft Graph, custom `getCustomer`, `getNotes`, `getTicket`, `getEvents`
- Prior-call context: `previous_transcript`, `call_history`, `summary`, `memory`, Vapi
  `analysisPlan` summaries fed back, Retell `transcript` from a prior `call_id`
- Voicemail and audio-in: `voicemail`, `transcribe_voicemail`, recordings transcribed and read
  back; outbound agents' handling of the far end's IVR (`ivr`, `press_digit` on menu prompts,
  `end_call` on wrong company)
- Prompt assembly points that take retrieved text: `context`, `documents`, `chunks`,
  `knowledge`, `notes`, `history` interpolated into `system`, `instructions`, or a message

### What to Search For
- Retrieved text (KB chunks, record fields, notes, prior transcripts) concatenated into the
  system prompt or `instructions` rather than placed in a labeled data block in a user or
  tool-result turn
- Tool results returned to the model as raw strings with no fixed label or structure, then
  used to form the next tool call
- A retrieval store that the caller or any unauthenticated party can write to: public forms
  that create records, ticket bodies, calendar invites accepted automatically, review or
  comment fields, uploaded documents indexed without review
- Outbound campaign rows (name, reason, notes) rendered into the prompt — a CRM-writable source
- Remote audio treated as instruction on outbound calls: IVR speech transcribed and acted on
  with tools beyond `press_digit` and `end_call`
- Voicemail transcripts summarized or acted on by an agent with tools
- "Delayed" effects: a retrieved value that persists in memory or a session variable and
  influences a later tool call after the caller's confirmation of a different action
- No relevance threshold on retrieval, so a poisoned chunk with weak similarity still lands
- Retrieval results spoken verbatim (also Cat 16) when the store is writable by outsiders
- Prompt lines like "ignore any instructions in the documents" relied on as the sole control
- A shared memory or scratchpad written by one call and read by another

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| retrieved-in-instruction-position | Retrieved or tool-returned text renders into the system prompt or instructions | trace from the source to the assembly point | Critical |
| writable-source-to-consequential-tool | Content from a store an outside party can write reaches the model and a consequential tool is reachable with no external gate | trace source → prompt → tool, plus the writer of the source and the absent gate | Critical |
| remote-audio-as-instruction | On outbound calls, the far end's speech or IVR audio is acted on with tools beyond navigation and hang-up, with no gate | the outbound flow + the tool list | High |
| unlabeled-tool-results | Tool results enter the model as unlabeled raw strings and feed subsequent tool arguments | the result handling + the next call | High |
| cross-call-memory | A memory or scratchpad written on one call is read on another with no provenance and no tenant scope | the store's writers and readers | High |
| no-relevance-threshold | Retrieval has no minimum similarity or filter, and the store accepts outside writes | the query + the store's writers | Medium |
| prompt-only-provenance | The only control is a "treat documents as data" line | the prompt + the absent gate | reported with the row it fails to protect |
| no-writable-source | Every retrieval source is written only by trusted staff or systems, and tool results are labeled | the writers quoted | Pass |

### Actually Vulnerable

#### Critical
- `system: BASE_PROMPT + '\nCustomer notes: ' + crm.notes` where `notes` is set by a public
  contact form
- KB chunks joined into `instructions` on every turn, with the KB fed from uploaded PDFs
  nobody reviews, and a `refund` tool with no confirmation gate
- A calendar-reading tool whose event titles land in the system prompt, with a `sendSms` tool
  available

#### High
- Outbound agent with `updateCrm` and `transfer` tools that acts on the far end's IVR speech
- `toolResult = await fetchTicket(); messages.push({ role: 'user', content: toolResult })` with
  the ticket body written by end users and the next tool call built from it
- `sessionMemory` keyed by phone number, written from call summaries, read into every later
  call's prompt

#### Medium
- Vector query with no score threshold over a store that indexes support-form submissions
- Voicemail transcript summarized by an agent with only read tools (report at Medium; escalate
  if write tools exist)

### NOT Vulnerable
- Retrieved content placed in a labeled data block in a user or tool-result turn, instructions
  fixed and locked server-side, and consequential tools gated outside the model (quote each; the
  gate is Cat 13's Pass, cited here)
- Retrieval sources written only by staff or trusted systems, with the writer path quoted; a
  poisoned source is then an insider problem, and the category records the scoped Pass without
  claiming immunity
- Outbound IVR handling limited to navigation and hang-up tools while the far end is not
  verified
- Tool results returned as structured JSON with a fixed schema and only named fields used
  downstream
- Memory scoped to the verified caller and labeled with its origin
- No retrieval, no tool results, no memory — Skip, `not applicable`, with the search

### Context Check
1. What does the agent read mid-call, and who can write to each source?
2. What position does each retrieved value land in?
3. Which tools can a steered model reach after reading, and what gates them outside the model?
4. On outbound calls, what does the agent do with what it hears from the far end?
5. Does anything persist between calls, and who reads it?
6. Is there a relevance floor, and does it matter given who can write?

### Evidence Chain
- The retrieval or tool-return file:line
- The source's writers (the form, the endpoint, the sync job) with file:line or the config
- Each hop to the prompt position or the next tool argument, with file:line
- The consequential tools reachable and the gate checked (present: cite Cat 13's evidence;
  absent: the search)
- Source classification: outsider-writable, staff-written, system-generated, remote audio

### Confidence Scoring
- **High**: complete trace from an outsider-writable source to the instruction position or to a
  consequential tool with no external gate
- **Medium**: the source's writers are partially known, or the gate may be platform-side
- **Low**: the retrieval's downstream use could not be traced — tag `needs human verification`

### Severity
Critical is retrieved text in the instruction position, or an outsider-writable source with a
consequential tool behind it and no gate. High is remote audio driving tools, unlabeled results
feeding tool calls, and cross-call memory. Medium is retrieval hygiene on a writable store. Low
is not used.

### Files to Check
- `**/rag/**`, `**/retriev*`, `**/knowledge*`, `**/kb*`, `**/search*`, `**/embed*`, `**/vector*`
- `**/crm*`, `**/hubspot*`, `**/salesforce*`, `**/zendesk*`, `**/calendar*`, `**/ticket*`
- `**/memory*`, `**/history*`, `**/summary*`, `**/context*`
- `**/voicemail*`, `**/outbound*`, `**/ivr*`, `**/campaign*`
- `**/prompt*`, `**/*assistant*.json`, `**/*agent*.json`

### Reference
- CWE-1427: Improper Neutralization of Input Used for LLM Prompting
- OWASP LLM Top 10 (2025): LLM01 Prompt Injection, LLM08 Vector and Embedding Weaknesses
- OWASP Agentic Top 10 (2025): ASI06 Memory and Context Poisoning
- MITRE ATLAS: AML.T0051.001 LLM Prompt Injection (indirect)
