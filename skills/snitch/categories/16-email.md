## CATEGORY 16: Email Service Security
> Type: sink-pattern · Groups: modern-stack · CWE: CWE-798

**Data flow tracing required (SKILL.md Rule 7).** Trace the recipient (`to`) address and any user-supplied subject / header / body back to their source before reporting. Hardcoded recipients (contact form → fixed inbox) and schema-validated addresses are Passes; a `to` / `from` / subject built from `req.*` reaching the send call without validation is a finding (spam relay or header injection). Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- `resend`, `@sendgrid/mail`, `postmark` imports
- `RESEND_API_KEY`, `SENDGRID_API_KEY`, `POSTMARK_API_TOKEN` environment variables

### What to Search For
- API keys in client code
- User-controlled email addresses or content
- Missing rate limiting

### Actually Vulnerable

#### Critical
- `RESEND_API_KEY`, `SENDGRID_API_KEY`, or `POSTMARK_API_TOKEN` in client-side code
- Email API keys in `NEXT_PUBLIC_*` variables

#### High
- User-controlled `to` address without validation (spam relay)
- User-controlled email content without sanitization (email injection via headers)
- Missing rate limiting on email endpoints

#### Medium
- User-controlled `from` address (spoofing)
- No domain verification for sender addresses
- Logging full email content including sensitive data

### NOT Vulnerable
- API keys in server-only code
- Hardcoded recipient for contact forms
- Properly validated email addresses

### Context Check
1. Is the email endpoint server-only or accessible from client code?
2. Is the recipient address hardcoded or user-controlled?
3. Is there rate limiting to prevent email flooding?
4. Is email content sanitized to prevent header injection?

### Evidence Chain
- Send-call sink file:line (`resend.emails.send`, `sgMail.send`, `client.sendEmail`) or the key exposure file:line
- The traced variable path for `to` / `from` / subject / headers / body from source to the send call, naming each hop
- Source classification: hardcoded, schema-validated, or user-controlled (`req.*` / form payload)
- Sanitizers/validators checked along the path and found absent (email format validation, header newline stripping, allowlisted recipients)
- For posture findings (rate limiting, domain verification, logging): the endpoint or config file:line plus why the gap is reachable by untrusted callers

### Confidence Scoring
- **High**: Complete trace from `req.*` / form input to the `to` / `from` / subject of a send call with no validation on the path; or an email API key in demonstrably client-side code or a `NEXT_PUBLIC_*` variable.
- **Medium**: User input reaches the send call but a validator exists whose coverage is unclear (validates format but not headers), or rate limiting may be enforced by upstream middleware that wasn't confirmed.
- **Low**: Send call takes variables whose source is un-traceable within the audited files — tag `needs human verification`.

### Files to Check
- `**/email*.ts`, `**/send*.ts`, `**/mail*.ts`
- `pages/api/*mail*`, `app/api/*mail*`
- `lib/email*.ts`, `.env*`
