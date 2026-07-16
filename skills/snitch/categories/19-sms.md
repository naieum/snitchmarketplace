## CATEGORY 19: SMS/Communication Security (Twilio)
> Type: sink-pattern · Groups: modern-stack · CWE: CWE-798

**Data flow tracing required (SKILL.md Rule 7).** Trace the destination phone number (and message body) back to its source before reporting. Hardcoded or ownership-verified numbers are Passes; a number taken from `req.*` and passed to the send call without validation or verification is a finding (SMS pumping / toll fraud). Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- `twilio` imports
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` environment variables

### What to Search For
- Auth tokens in client code
- User-controlled phone numbers
- Missing webhook verification

### Actually Vulnerable

#### Critical
- `TWILIO_AUTH_TOKEN` in client-side code
- Account SID + Auth Token in frontend files

#### High
- User-controlled phone numbers without validation (SMS pumping attack)
- No rate limiting on SMS endpoints
- Missing webhook signature validation (`validateRequest`)

#### Medium
- Phone numbers logged without masking
- No verification of phone number ownership before sending

### NOT Vulnerable
- Twilio credentials in server-only code
- Properly validated phone numbers with ownership verification
- Rate-limited SMS endpoints

### Context Check
1. Is the SMS endpoint server-only and rate-limited?
2. Are phone numbers validated and verified before sending?
3. Is webhook signature validation applied to incoming Twilio requests?
4. Are phone numbers masked in logs?

### Evidence Chain
- Sink file:line — the Twilio send call (e.g. `client.messages.create`), or the credential reference for exposure findings
- The traced path of the destination phone number (and message body) from source to the send call
- Controls checked on that path and found absent (no number validation, no ownership verification, no rate limit on the endpoint)
- Source classification: user-controlled (`req.*`) vs hardcoded/ownership-verified numbers
- For webhook findings: the handler file:line with `validateRequest` verified absent

### Confidence Scoring
- High: complete trace of a `req.*` phone number to the send call with validation/rate limiting absent, or Twilio credentials verifiably in client-shipped code
- Medium: the number flows through helpers only partially traced, or rate limiting/validation may exist at an infrastructure layer (API gateway, middleware) not visible at the call site
- Low: the phone number's source cannot be traced → tag `needs human verification`

### Files to Check
- `**/twilio*.ts`, `**/sms*.ts`
- `pages/api/*sms*`, `app/api/*sms*`
- `.env*`
