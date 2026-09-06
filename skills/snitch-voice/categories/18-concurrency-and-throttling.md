## CATEGORY 18: Inbound concurrency, per-caller throttles and callback loops
> Type: posture · Groups: abuse · Hop: H10 Limits and operations · Standards: CWE-770, CWE-799

One caller holding one line is Cat 17's problem. A hundred callers, or one caller a hundred times,
is this one's. A published number with an agent behind it can be flooded from a dialer, a web
widget can be opened in a thousand tabs, and a "call me back" form can be scripted; each session
that starts costs the same as a real one and, past the platform's concurrency quota, real callers
get a busy signal. Outbound agents add a second shape: a retry rule that redials a voicemail, a
callback tool the model can invoke again and again, or two agents that reach each other and
neither hangs up. This category reads every place the number of simultaneous sessions, the rate of
session starts, and the number of retries is bounded.

**Boundary.** This category judges how many and how often. The length of one session is Cat 17.
The money ceiling under all of it is Cat 19. Whether the *ingress* is authenticated at all is Cat
01 and Cat 02 — an unauthenticated media socket is their finding; that it can also be flooded is
this category's row. The destination a callback dials is Cat 14. The token endpoint's rate limit is
Cat 04. A generic API rate limit off the call path is snitch-security's Cat 07 — hand off by
calling the Skill tool with "snitch-security".

### Detection
- Platform concurrency settings in exports: Vapi concurrency limit (account-level; default in the
  low tens `(unverified — confirm in the platform docs)`), Retell concurrency and calls-per-second
  limits, Bland concurrency, ElevenLabs concurrent-call limits, Twilio CPS and concurrent-call
  settings, Vonage / Telnyx / Plivo / SignalWire trunk channel limits, LiveKit `max_participants`
  and SIP trunk `allowed_addresses`, Amazon Connect `CommunicationLimitsConfig` and instance
  concurrency quotas
- Application-level session accounting: an in-memory or Redis counter of active sessions,
  `activeCalls`, `semaphore`, `p-limit`, `asyncio.Semaphore`, a per-ANI (`From`) or per-IP
  counter, `rate-limiter-flexible`, `express-rate-limit`, `slowapi`, token buckets
- Session-start entry points: inbound webhooks (Cat 01), media sockets (Cat 02), token endpoints
  (Cat 04), web-call creation, outbound `/call` starters, scheduled dialers
- Retry and redial: Bland `retry`, voicemail redial settings, Vapi outbound retries, app-level
  cron or queue dialers, `maxAttempts`, `retryCount`, callback tools the model can invoke
- Webhook retry handling: idempotency on `call-ended` / status callbacks that trigger work

### What to Search For
- No active-session counter anywhere in the app, on a stack where the platform's quota is the
  only limit (and the quota is a denial-of-service ceiling, not a cost ceiling)
- No per-caller throttle: the same `From` number or the same IP can start unlimited sessions
- Web widget or mobile app session starts with no per-user or per-IP limit on the server that
  mints tokens or creates web calls
- Form-to-call or callback endpoints with no rate limit and no CAPTCHA or equivalent
- Outbound dialers with no per-number attempt cap, no cooling-off, no daily ceiling
- Voicemail retry with no maximum
- A callback tool the model can call more than once per session
- No detection of an automated callee on outbound calls (answering-machine detection unused
  where available; no "you reached an automated system" guard)
- Post-call webhooks that start expensive work (summaries, follow-up calls) with no idempotency
  on retried deliveries
- SIP trunks accepting any source address (LiveKit `allowed_addresses` empty; carrier ACLs
  absent) — the flood surface, distinct from Cat 02's authentication row

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| no-app-concurrency-cap | No application-level cap on simultaneous sessions, and no exported platform cap in the workspace | the search + the Rule 6 line for the platform side | Medium (High on a public web widget where sessions are cheap to start) |
| no-per-caller-throttle | The same caller number, IP, or user can start unlimited sessions | the search over session-start paths | High on web and form starters; Medium on carrier inbound |
| open-callback-starter | A form or API that starts an outbound call has no rate limit | endpoint file:line | High (Critical together with Cat 14's open-outbound-endpoint) |
| unbounded-retry | Outbound retry, voicemail redial, or a callback tool has no attempt cap or cooling-off | config or handler file:line | High |
| webhook-retry-storm | A retried platform webhook re-triggers expensive or side-effecting work | handler file:line + the absent idempotency check | Medium |
| automated-callee-unguarded | Outbound calls have no answering-machine detection and no automated-system guard | config file:line | Medium |
| sip-source-unrestricted | A self-hosted SIP ingress accepts any source address | trunk config file:line | High |

### Actually Vulnerable

#### Critical
- Not used alone; an open callback starter combined with Cat 14's unrestricted destination is
  reported there as Critical and cited here

#### High
- A web widget's token or web-call endpoint with no per-user or per-IP limit
- A "request a call" form with no rate limit
- Outbound retry or voicemail redial with no cap; a callback tool invocable repeatedly
- A SIP trunk with no source restriction

#### Medium
- No app-level concurrency accounting on a carrier-fed line, with no platform export
- Post-call webhook handlers that redo work on every delivery
- Outbound agent with no automated-callee guard

### NOT Vulnerable
- An active-session counter enforced before the session starts, with a ceiling proportionate to
  the business — Pass quoting the counter and the rejection path
- Per-caller and per-IP throttles on every session-start path — Pass quoting each
- Platform concurrency and CPS limits exported in the workspace and set below the account
  quota — Pass for the platform row
- Retry configs with a maximum attempt count and a minimum interval
- Idempotency keys on webhook-triggered work (`call_id` seen-set, database unique constraint)
- Answering-machine detection enabled on outbound calls with a hang-up or leave-message rule
- Inbound-only agent on a carrier line with an exported platform cap and no web surface — the
  web rows Skip, `not applicable`

### Context Check
1. Enumerate every path that starts a session. Which are public?
2. For each: what limits the count, and what limits the rate per caller?
3. Where is the platform quota, and is it exported? Absent export is a Skip, not a finding.
4. For outbound: what bounds attempts per number and per day, and what happens on voicemail or
   an automated answer?
5. What does a retried webhook delivery cause?
6. Is any SIP ingress self-hosted, and who may send to it?

### Evidence Chain
- Each session-start path file:line
- The counter, throttle, or rate limiter found on that path, or the search establishing its
  absence with pattern and scope
- The platform export read, or the Rule 6 skip line
- Retry and redial configuration file:line and its caps
- Webhook handler idempotency checks, or their absence

### Confidence Scoring
- **High**: the session-start path is in the workspace and verifiably has no limit, or a limit
  is fully quoted (Pass)
- **Medium**: a limit may exist at a gateway, CDN, or platform setting without an export
- **Low**: the session-start path could not be resolved → tag `needs human verification`

### Severity
High is any public, cheap-to-script session starter with no throttle, any unbounded outbound
retry, or an open SIP ingress. Medium is missing accounting on carrier-fed lines, retry storms,
and unguarded automated callees. Critical is reached only in combination with Cat 14. Low is
not used.

### Files to Check
- `**/api/token*`, `**/api/session*`, `**/api/web-call*`, `**/api/call*`, `**/callback*`
- `**/middleware/**`, `**/rate-limit*`, `**/limiter*`, `**/throttle*`
- `**/outbound*`, `**/dialer*`, `**/campaign*`, `**/retry*`, `**/queue*`, `**/cron*`
- `**/webhooks/**`, `**/post-call*`, `**/call-ended*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/trunk*`, `**/sip*`, `**/livekit*`

### Reference
- CWE-770: Allocation of Resources Without Limits or Throttling
- CWE-799: Improper Control of Interaction Frequency
- OWASP LLM Top 10 (2025): LLM10 Unbounded Consumption
- MITRE ATLAS: AML.T0029 Denial of ML Service, AML.T0034 Cost Harvesting
- Per-platform concurrency, CPS, retry and answering-machine settings:
  `references/stacks/<platform>.md`
