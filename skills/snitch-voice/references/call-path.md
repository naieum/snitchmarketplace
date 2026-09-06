# The Call Path

The denominator behind every snitch-voice report. A voice agent is a pipeline, and a caller
attacks it at a hop, not at a file. This reference names the hops, says what each one is judged
against, and maps every category in `categories/_index.md` to the hops it covers. The report's
coverage block lists every hop exactly once with its outcome, so a scan that never looked at
call control cannot read like one that did.

Read this before the coverage block is written, and whenever a finding needs its `Hop` line.

---

## The hops

| Hop | Name | What arrives here | What the caller can do here |
|---|---|---|---|
| H1 | **Ingress** | The carrier's or platform's HTTP webhook, SIP INVITE, media-stream socket, or WebRTC signaling request reaches your server | Forge a request that looks like the carrier, attach to a media socket, start a session nobody dialed |
| H2 | **Session authentication** | The call is bound to an identity: the caller's, or the web/mobile client's | Spoof caller ID, present a cloned voice, mint or reuse a client token, talk the agent into treating them as an account holder |
| H3 | **Transcription** | Audio becomes text; DTMF becomes digits | Say instructions instead of answers, inject through DTMF, exploit what the transcriber does with noise, silence, or language switching |
| H4 | **Prompt assembly** | The system prompt, dynamic variables, caller metadata, and history are joined for the model | Land caller-influenced text in the instruction position; read the prompt back; override the assistant configuration from the client |
| H5 | **Retrieval** | Knowledge base, CRM, calendar, ticket, or prior-transcript content is read into context | Plant instructions in a record the agent will later read aloud or act on |
| H6 | **Tool dispatch** | The model emits a tool call; your handler runs it against a backend | Reach another customer's data, trigger an action without authorization, pass model-chosen arguments to a sink |
| H7 | **Call control** | The agent dials, transfers, hangs up, sends DTMF, or sends a message | Route a call to a premium-rate or attacker number, forward the line, send SMS from the brand's number, end or hold the call |
| H8 | **Synthesis and playback** | Text becomes speech and is played to the caller | Hear data the caller should not, hear raw tool output or error text, never hear a required disclosure |
| H9 | **Storage and telemetry** | Recordings, transcripts, logs, and analytics are written and retained | Have their card number, health detail, or voiceprint kept somewhere it should not be; reach someone else's recording by URL |
| H10 | **Limits and operations** | Duration, silence, concurrency, spend, outage behavior, alerting — cross-cutting | Keep the line open, flood the number, drain the LLM/TTS budget, make the agent go silent or hang up, act unnoticed |
| H11 | **Deployment** | Where secrets live, which URLs are wired, what a quickstart left behind — cross-cutting | Read a key from a bundle, hit a tunnel URL, use a debug route |

H1–H9 are the order of one call. H10 and H11 wrap every hop; they get their own rows in the
coverage block because "no cap anywhere" is a disposition, not a footnote.

---

## Category-to-hop map

The `Hop` column here is authoritative for a finding's `Hop` line and for the coverage block.
Category identity, type, groups and status live in `categories/_index.md`; this table carries
only the hop mapping and stores no status. If a category row changes status there, its hop
coverage here is simply not claimed.

| Cat | Slug | Primary hop | Also touches |
|---|---|---|---|
| 01 | webhook-authenticity | H1 | — |
| 02 | media-stream-and-session-endpoints | H1 | H2 |
| 03 | client-credential-exposure | H11 | H2 |
| 04 | ephemeral-token-minting | H2 | H1 |
| 05 | caller-identity-trust | H2 | H6 |
| 06 | caller-verification-before-disclosure | H2 | H6, H8 |
| 07 | speech-and-dtmf-injection | H3 | H4 |
| 08 | call-metadata-and-variable-injection | H4 | H1 |
| 09 | retrieved-content-injection | H5 | H4 |
| 10 | system-prompt-hygiene | H4 | H8 |
| 11 | assistant-config-tampering | H4 | H2 |
| 12 | tool-authorization | H6 | H2 |
| 13 | consequential-action-gates | H6 | H7 |
| 14 | dial-and-transfer-control | H7 | H10 |
| 15 | messaging-tools-on-call | H7 | H6 |
| 16 | tool-output-and-error-handling | H6 | H8 |
| 17 | session-limits | H10 | H7 |
| 18 | concurrency-and-throttling | H10 | H1 |
| 19 | spend-controls | H10 | — |
| 20 | resilience-and-fail-safe | H10 | H8 |
| 21 | recording-and-transcript-storage | H9 | — |
| 22 | sensitive-data-redaction | H9 | H4, H8 |
| 23 | recording-consent | H9 | H8 |
| 24 | ai-disclosure-and-outbound-consent | H8 | H7 |
| 25 | regulated-data-regimes | H9 | H6 |
| 26 | deployment-hygiene | H11 | H1 |
| 27 | audit-trail-and-anomaly-alerts | H10 | H9 |

**Hop ownership.** Every hop H1–H11 is the primary hop of at least one category. A hop whose
every primary category was outside the selection is a Skip in the coverage block with the reason
`category NN not in this scan's selection`; it is never omitted and never a Pass.

---

## The trust boundaries, stated once

Three boundaries carry most findings. Name the one a finding crosses in its Risk line.

1. **Carrier → server (H1).** Everything that arrives claiming to be the carrier or the agent
   platform is unauthenticated until the signature or secret is checked. A route that acts on the
   body before verifying it is acting on anyone's body.
2. **Caller → model (H2–H5).** Everything the caller says, keys, or carries (caller ID, CNAM, SIP
   headers, client-supplied variables), and everything read from a store the caller or a third
   party can write, is data, not instruction. The model cannot tell the difference; only code
   outside the model can enforce it.
3. **Model → world (H6–H8).** Every tool call, dial, transfer, message, and spoken sentence is
   the model acting on behalf of whoever steered it. A control that runs only if the model
   chooses to run it is not a control.

---

## What this skill does not judge

The same file can be two skills' business. This skill owns the finding when the evidence sits on
a hop above or in a voice platform's configuration. It hands off when the judge is elsewhere:

- A SQL string built in a tool handler is Cat 12 or 16 here **only for the voice-borne
  argument**; the SQL construction itself is snitch-security's Cat 01. Record both: the finding
  here names the hop and the argument; the hand-off names the sink.
- A provider key hardcoded in server code that never reaches a client is snitch-security's Cat
  03. The same key in a browser or mobile bundle is Cat 03 **here**, because the bundle is the
  voice client.
- A chat endpoint with prompt injection at the text input is snitch-security's Cat 15. The same
  model behind a phone number is Cat 07 here, because the source is transcribed speech.
- A non-voice agent's tool surface is snitch-security's Cat 68. A voice agent's tool surface is
  Cats 12–16 here.
- A standalone SMS endpoint is snitch-security's Cat 19. An SMS the agent sends mid-call is Cat
  15 here.
- A generic WebSocket server is snitch-security's Cat 56. A media-stream socket is Cat 02 here.
