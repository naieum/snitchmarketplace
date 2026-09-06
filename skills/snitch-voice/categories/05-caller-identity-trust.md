## CATEGORY 05: Caller ID, CNAM and voice as identity
> Type: sink-pattern · Groups: quick, actions · Hop: H2 Session authentication · Standards: CWE-290, CWE-287

The webhook arrives with a `From` number, sometimes a caller name, sometimes a city, sometimes a
SIP header the trunk forwarded. The temptation is to look that number up, find a customer, and
treat the call as that customer from the first word. Caller ID is a routing hint the network
forwards, not a credential: it is spoofable, carrier attestation vouches for the originating
carrier's signing key rather than the person, the name field is a third-party lookup, and any SIP
header from an untrusted trunk is whatever the sender typed. Voice itself is no better as a sole
factor — cloning from a few minutes of audio has been demonstrated against production voice-ID
systems, and by 2025 the industry's own leaders were describing voice authentication as defeated.
This category traces every place the agent decides who it is talking to, and asks whether that
decision rests on something the caller cannot forge.

**Call-path tracing required (anti-hallucination Rule 3).** Trace `From`, `CallerName`,
`customer.number`, `sip.phoneNumber`, participant attributes, biometric match results, and any
"verified" flag from their arrival to the first place they gate a disclosure or an action. A
number used only to prefill a lookup that is then confirmed by a separate verification step is a
Pass; a number, name, or voice match that alone unlocks account data or a consequential tool is a
finding. A system-prompt instruction to "verify the caller" is never a control.

**Boundary.** This category judges what the agent accepts as identity. The verification flow
that should follow (what questions, how many, what they unlock) is Cat 06. The same `From` value
landing in the prompt as text is Cat 08; the same value used as a tool argument that selects
another customer's record is Cat 12. Trunk-level number filters and PINs are read in Cat 02 and
cited here as partial controls.

### Detection
- Webhook fields: `From`, `Caller`, `CallerName`, `FromCity`, `FromState`, `FromZip`,
  `StirVerstat`, `CallToken`, `caller_id_number`, `caller_id_name`, `from.number`, `from.name`
- Platform objects: Vapi `call.customer.number`, `customer.name`; Retell `from_number`,
  `call.from_number`; Bland `from`; ElevenLabs `caller_id`, `system__caller_id`; LiveKit
  `sip.phoneNumber`, `sip.trunkPhoneNumber`, `sip.h.*`, `headers_to_attributes`,
  `attributes_to_headers`; Amazon Connect `CustomerEndpoint.Address`; Asterisk `CALLERID(num)`;
  FreeSWITCH `caller_id_number`
- Voice biometrics and liveness: `voiceprint`, `speaker_verification`, `speaker_id`,
  `enroll`, `verify_speaker`, `liveness`, `anti_spoof`, `deepfake_detect`, vendor SDKs for
  speaker recognition
- Lookups keyed by number: `findByPhone`, `getCustomerByNumber`, `WHERE phone =`,
  `customers.filter(phone ===`, CRM search by `phone_number`
- Flags: `isVerified`, `verified: true`, `authenticated`, `identity_confirmed`, `known_caller`

### What to Search For
- A customer record loaded by `From` and passed to the model or a tool as the authenticated
  identity with no subsequent verification gate
- `verified` / `authenticated` set to true because the number matched a record
- Trunk-level filters (`allowed_numbers`, inbound number lists) or STIR/SHAKEN attestation
  values (`StirVerstat`, `verstat`) treated as proof of the person rather than of the carrier
- CNAM / `CallerName` used to greet by name and then to skip a verification question because
  "the name matched"
- SIP headers (`P-Asserted-Identity`, `X-*`, `Remote-Party-ID`) from an external trunk mapped
  into attributes the agent trusts
- Anonymous, withheld, or malformed `From` handled by falling back to a default account, or by
  granting the same access as a matched number
- Duplicate-number handling: two records with the same phone resolved by picking the first
- Voice biometrics as the only factor before disclosure or action, with no liveness or
  synthetic-speech check and no second factor
- Biometric match thresholds lowered for convenience, or a match result cached across calls
- The verification result carried in a variable the model can set (a tool that returns
  `verified: true` on the model's say-so, a dynamic variable the client can supply)
- Outbound calls: the agent assumes whoever answers is the intended person and discloses on
  pickup, with no confirmation of who answered

### Rule table
| Row | Fails when | Evidence | Severity |
|---|---|---|---|
| caller-id-as-auth | `From`, CNAM, city, or a trunk-forwarded header alone sets an authenticated identity that gates disclosure or a consequential tool | trace from the field to the gate | Critical |
| attestation-as-identity | STIR/SHAKEN attestation, trunk number lists, or `allowed_numbers` is read as proof of the person | the read + the downstream trust | High |
| voice-as-sole-factor | A biometric or speaker match is the only factor before disclosure or action, with no liveness check and no second factor | the verification path + the absent factor | High |
| model-settable-identity | The verified flag lives in a variable the model or client can set | the flag's writers | High |
| anonymous-fallback | Withheld or unmatched caller ID falls back to an account or to matched-caller access | the fallback branch | High |
| duplicate-resolution | Multiple records match the number and one is chosen without disambiguation | the lookup + the selection | Medium |
| outbound-pickup-trust | On an outbound call the agent discloses account data to whoever answers without confirming the person | the outbound flow + the disclosure | High |
| number-only-prefill | Caller ID prefills a lookup and a separate verification gate follows before any disclosure | the gate quoted | Pass |

### Actually Vulnerable

#### Critical
- `const customer = await db.customers.findByPhone(req.body.From); session.authenticated = true;`
  followed by tools that read balances, addresses, or bookings
- A Vapi `assistant-request` handler that returns a per-customer prompt with account details
  because `customer.number` matched
- A LiveKit agent that reads `sip.phoneNumber` and treats the participant as the account holder

#### High
- `if (StirVerstat === 'TN-Validation-Passed-A') verified = true`
- Speaker-verification result as the only gate before a payment or address change
- `verified` stored in `assistantOverrides.variableValues` or set by a tool the model calls with
  no server-side check
- Anonymous caller routed to a shared "guest" account with data in it
- Outbound: "Hi, this is about your appointment on the 12th at the clinic" before confirming who
  picked up

#### Medium
- First-match on duplicate numbers
- CNAM used to personalize and then to shorten verification

### NOT Vulnerable
- Caller ID used to prefill or narrow a lookup, followed by a verification gate (Cat 06) before
  any disclosure — quote the gate and the order
- Identity established by a factor the caller must possess or know that is not derivable from
  the call metadata: an OTP to a number on file, an in-app confirmation, a PIN set out of band,
  a callback to the number on record — quote it
- Biometrics used as one factor with liveness or synthetic-speech detection and a second
  factor before consequential actions
- Trunk-level restrictions used to reject calls (a coarse filter), with the agent still
  verifying in conversation
- Anonymous callers restricted to a no-account flow
- No account-bound flows at all (a pure information line) — Skip, `not applicable`, with the
  tool list as evidence

### Context Check
1. What does the agent do with `From` and its relatives, hop by hop?
2. Where is "this caller is X" first decided, and by what?
3. What follows that decision: disclosure, action, or a verification gate?
4. Can the model, the client, or a retrieved record set the verified state?
5. For biometrics: what factor accompanies the match, and is synthetic speech checked?
6. For outbound: what confirms the person who answered?

### Evidence Chain
- The field's arrival file:line (webhook, platform object, participant attribute)
- Each hop to the identity decision, with file:line
- The decision file:line and the gate it unlocks (tool, prompt content, disclosure)
- Controls checked and found absent: a possession or knowledge factor, liveness, a gate before
  disclosure
- Source classification: network-forwarded metadata, third-party lookup, biometric match,
  model-settable

### Confidence Scoring
- **High**: complete trace from a forgeable field to a gate it alone unlocks
- **Medium**: the gate may be enforced in a platform-side flow not exported, or the lookup's
  downstream use is partially traced
- **Low**: the identity decision could not be located — tag `needs human verification`

### Severity
Critical is forgeable metadata alone unlocking data or actions. High is a partial control
(attestation, biometrics, a settable flag, an anonymous fallback, outbound pickup) standing in
for identity. Medium is disambiguation and personalization shortcuts. Low is not used.

### Files to Check
- `**/incoming*`, `**/inbound*`, `**/answer*`, `**/assistant-request*`, `**/call-start*`
- `**/identity*`, `**/verify*`, `**/auth*`, `**/customer*`, `**/lookup*`
- `**/biometric*`, `**/voiceprint*`, `**/speaker*`
- `**/*assistant*.json`, `**/*agent*.json`, `**/dispatch*`, `**/trunk*`
- `**/outbound*`, `**/campaign*`

### Reference
- CWE-290: Authentication Bypass by Spoofing
- CWE-287: Improper Authentication
- CWE-308: Use of Single-factor Authentication
- OWASP Agentic Top 10 (2025): ASI03 Identity and Privilege Abuse
- Per-platform caller fields and trunk controls: `references/stacks/<platform>.md`
