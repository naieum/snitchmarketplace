## CATEGORY 15: SMS and email sends from the call path
> Type: sink-pattern · Groups: actions · Hop: H7 Call control · Standards: CWE-20, CWE-862

"I'll text you the link." A voice agent that can send a message mid-call holds two things an
attacker wants: a sender the recipient trusts (the brand's number or domain) and a body the model
writes. If the caller names the recipient, the agent becomes a free relay — bulk sends to numbers
that pay the attacker per delivery, or a phishing text from the real support number to a victim the
attacker chose. If the model writes the body from what it heard, the caller writes the message.
This category traces every message send reachable from the call — SMS, MMS, WhatsApp, email, push —
back to where its recipient and body come from.

**Call-path tracing required (anti-hallucination Rule 3).** Trace the recipient and the body of
every send from source to the messaging call. A recipient that is the call's bound customer number
(the number the platform reports as the caller, after Cat 06 verification where the content is
sensitive) or a server-resolved address on the verified record is a Pass. A recipient the model
supplies, the caller speaks, or a form submits is a finding unless an ownership check gates it. A
body composed from a fixed template with server-chosen values is a Pass; a body the model composes
freely is a finding when it reaches a third party.

**Boundary.** This category owns sends that originate from the call path: a tool the agent calls,
a post-call hook that messages the caller, a callback form that texts a link. A standalone SMS or
email endpoint with no agent behind it is snitch-security's Cat 19 (SMS) and Cat 16 (email) — hand
off by calling the Skill tool with "snitch-security". Whether the send tool asks for confirmation
is Cat 13; whether it was authorized for this caller is Cat 12; an OTP send used *for* verification
is Cat 06's control and is not re-scored here. The rate limit on the tool is Cat 18.

### Detection
- Messaging SDK calls reachable from tool handlers or post-call hooks: Twilio
  `messages.create`, Vonage `sms.send` / `messages.send`, Telnyx `messages.create`, Plivo
  `messages.create`, SignalWire `messages.create`, Bandwidth messaging, AWS SNS / Pinpoint /
  SES, SendGrid, Postmark, Resend, Mailgun, SMTP clients, WhatsApp Business API, push providers
- Platform message tools: Vapi `sms` tool, Retell `send_sms` (where available), Bland `sms`
  actions and `pathway` SMS nodes, ElevenLabs server tools wrapping a messaging API, Amazon
  Connect outbound SMS blocks
- Tool definitions whose name or description says: text, sms, message, email, send link, send
  receipt, send confirmation, notify
- Post-call handlers (`call-ended`, `end-of-call-report`, `post_call`, `status-callback`) that
  send a follow-up

### What to Search For
- `to` / `recipient` / `phoneNumber` / `email` taken from the model's tool arguments
- Recipient from a caller-supplied form field on a click-to-call or "text me" page
- Recipient from a transcript regex ("text it to 555…")
- Body composed from the model's free text (`body: args.message`, `body: response.text`) and
  sent to anyone other than the bound caller
- Links in the body built from model output or caller input (a URL the caller dictated)
- Sender selection from a variable: `from`, `messagingServiceSid`, `alphanumeric sender` set by
  arguments
- No per-call cap on sends: a loop or repeated tool call sending many messages in one session
- Sends to the caller's number before verification when the content is account-specific
  (balance, appointment details, reset link)
- Email sends with attachments or HTML built from model output
- Post-call hooks forwarding the transcript or summary to a caller-supplied address

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| recipient-from-caller | A send's recipient comes from the model's arguments, the transcript, or a request field with no ownership check | trace + send file:line | Critical |
| body-from-model-to-third-party | The message body is model-composed free text and the recipient is not the bound caller | trace + send file:line | High |
| link-from-untrusted | A URL in the body comes from model output or caller input | trace | High |
| sender-from-variable | The sender number or address is chosen by an argument the model or caller influences | trace | High |
| unbounded-sends | No per-call or per-caller cap on sends from the tool | handler file:line + the search for a counter or limit | Medium (High if the recipient is caller-supplied) |
| pre-verification-send | Account-specific content is sent to the caller's number before the verification step | trace + the session's verification state | Medium |
| transcript-forwarded | A post-call hook sends the transcript or summary to a recipient not fixed server-side | hook file:line | High |

### Actually Vulnerable

#### Critical
- `messages.create({ to: args.phoneNumber, body: args.message })` from a tool handler
- A "text me the link" form posting `to` and starting a send with no ownership check
- A post-call hook emailing the transcript to `args.email`

#### High
- Model-composed body sent to a number the caller dictated, even if the number is validated as
  E.164
- A dictated or model-generated URL placed in an SMS from the brand number
- `from` chosen from arguments; alphanumeric sender set by the caller's words
- Unbounded sends where the recipient is caller-supplied

#### Medium
- Sends only to the bound caller but with no cap, so a session can be made to fire dozens
- Appointment details or a reset link texted to the caller ID before verification

### NOT Vulnerable
- Recipient fixed to the call's bound customer number (`message.call.customer.number`, the
  session's verified contact) and body built from a fixed template with server-chosen values —
  Pass quoting the binding and the template
- Recipient resolved from the verified record's contact fields, never from arguments
- A send that only delivers a server-generated OTP for Cat 06 verification
- Per-call send counter enforced in code, and a rate limit on the tool
- Links from a fixed allowlist or generated server-side (signed, short-lived)
- No messaging capability reachable from the call path — Skip, `not applicable`, with the
  search over the tool inventory and post-call hooks

### Context Check
1. Which sends can the agent trigger, during the call and after it? List tools and hooks.
2. For each: where does the recipient come from? Envelope, verified record, arguments, form?
3. Where does the body come from — template, server values, model text? Does any of it reach a
   third party?
4. Are links in the body server-generated?
5. Who chooses the sender?
6. How many times can one session fire the send?
7. Does account-specific content wait for verification?

### Evidence Chain
- The send call file:line
- The traced path of the recipient from source to the send, hop by hop with file:line
- The traced path of the body and any embedded link
- Controls checked and found absent: ownership check, template, allowlist, send counter,
  verification gate
- Source classification for recipient and body: bound-caller / verified-record / model-argument /
  transcript / request-field

### Confidence Scoring
- **High**: complete trace from a caller-influenced source to the send with no control, or a
  bound-recipient template Pass fully quoted
- **Medium**: the recipient or body passes through a helper not fully read, or a rate limit may
  exist at the messaging provider without an export
- **Low**: the recipient's source could not be traced → tag `needs human verification`

### Severity
Critical is any send whose recipient the caller chooses. High is the brand's sender carrying
model-written or caller-dictated content or links to anyone but the bound caller, a variable
sender, or a forwarded transcript. Medium is unbounded or premature sends to the caller only.
Low is not used.

### Files to Check
- `**/tools/**`, `**/functions/**`, `**/sms*`, `**/message*`, `**/notify*`, `**/email*`
- `**/post-call*`, `**/call-ended*`, `**/end-of-call*`, `**/status-callback*`, `**/webhooks/**`
- `pages/api/text*`, `app/api/text*`, `**/callback*`, `**/text-me*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/pathway*` (message tool definitions)
- `**/templates/**` (message templates, as Pass evidence)

### Reference
- CWE-20: Improper Input Validation
- CWE-862: Missing Authorization
- CWE-601: URL Redirection to Untrusted Site (dictated links)
- OWASP LLM Top 10 (2025): LLM05 Improper Output Handling, LLM06 Excessive Agency
- Per-platform message tools and post-call hooks: `references/stacks/<platform>.md`
