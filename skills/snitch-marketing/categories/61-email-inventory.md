## CATEGORY 61: Transactional email inventory

What emails does the site send, when, to whom, from where? Most teams can list 2-3 emails off the top of their head and forget the other 8 that the framework, plugins, or third-party services fire automatically. Untracked emails = stale copy in production = "we noticed our welcome email still says 'beta'" surprises. The audit answers: what gets sent, who triggers each one, what template/code emits it, what the from-address is.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for email-send patterns:
   - Resend: `resend.emails.send`, `'https://api.resend.com/emails'`
   - SendGrid: `sgMail.send`, `@sendgrid/mail`
   - Postmark: `postmark.sendEmail`, `'@postmark/`
   - AWS SES: `SendEmailCommand`, `ses.send`
   - Mailgun: `mailgun.messages`, `mg.messages.create`
   - Generic SMTP: `nodemailer`, `transporter.sendMail`
   - Auth library default emails: `betterAuth({ ... emailVerification, sendOnSignUp })`, `next-auth` email provider, `Clerk.user.sendInvitation`
   - Stripe webhook handlers (receipt emails fire from Stripe but checkout-completed handlers often send too)
2. For each match: `Read` the surrounding handler. Capture: trigger event, template/component used, to-address (user / hardcoded / configured), from-address.
3. `Glob` `**/emails/*.tsx`, `**/email-templates/*`, `**/transactional/*`, common locations for React Email / Mailjet / Postmark template files.
4. Build a list: trigger → handler file:line → template → from-address.

**Crawl mode, required tool calls:**

1. Largely unavailable in pure crawl mode (server-side sends aren't visible). Mark as **Skip** with reason `email inventory requires source access; crawl mode cannot enumerate server-side sends`.
2. Optional partial check: subscribe to a public newsletter / sign up for an account with a throwaway address, capture the actual emails received. Note in report that this is empirical sampling, not full inventory.

### Forbidden claims

- "The site probably sends X emails." Either you grepped + found the send sites, or you don't know.
- "Welcome email may be missing." Either there's a send-on-signup handler in source, or there isn't.
- "Template may be wrong." Check the template; quote it.

### Detection

#### Source mode

Look for any code path that calls an email-sending API. Common sources:

- Auth library hooks: `databaseHooks.user.create.after` (Better Auth), `events.signUp` (NextAuth), Clerk webhooks
- Stripe webhook workflows: payment success / failure / subscription started / cancelled / renewed
- Custom triggers: contact form handlers, lead-capture forms, password reset, API key issued, invitation accepted, milestone events
- Background jobs: cron handlers, queued workers, scheduled functions

For each: extract the trigger, the template, the from-address, the to-address shape (user.email vs hardcoded vs param).

#### Crawl mode

Limited. Skip with reason as above.

### What to Search For

Send-API patterns (case-sensitive):
- `resend.emails.send`, `Resend(` constructor + `.emails.send`
- `sgMail.send`, `mail.send` (SendGrid)
- `postmark.sendEmail`, `client.sendEmail` (Postmark)
- `SendEmailCommand`, `SendBulkEmailCommand` (AWS SES SDK v3)
- `ses.sendEmail` (AWS SES SDK v2)
- `mg.messages.create` (Mailgun)
- `transporter.sendMail` (Nodemailer)
- `'mail.send'`, `'email.send'` (generic)

Template patterns:
- React Email components: `import { Html, Body, ... } from '@react-email/components'`
- MJML: `*.mjml` files
- Handlebars / EJS templates: `*.hbs`, `*.ejs`
- Inline HTML strings: `<html>...</html>` template literals

### Actually Hurts the Marketing Surface

- **Email triggered but not documented**.
  Evidence required: the handler file:line + the trigger description. Write to the report so the team has a complete inventory.
- **Multiple from-addresses** across emails (some from `noreply@`, some from `support@`, some from `hello@`, some from a personal domain).
  Evidence required: enumerate from-addresses across all sends.
- **Email send code references a template that doesn't exist**.
  Evidence required: the send call's template ID/path + a Glob/Read of the template location showing absence.
- **Hardcoded recipient address shipped in production code** (debug `to: 'me@personal.com'` left in).
  Evidence required: the hardcoded address.
- **Send-on-signup that fires before user has confirmed their email** (welcome email goes to unverified addresses).
  Evidence required: the handler + the order of email-verification + welcome-send.

### NOT a Problem

- A site that sends only one transactional email (signup confirmation). Inventory is small but complete.
- Stripe-hosted receipts (Stripe sends them; you don't have to). Document them as out-of-scope for this site's audit.
- Plugin / SaaS-hosted emails the team doesn't customize (e.g., GitHub-hosted notification emails on PR comments). Note presence; not a finding.

### Context Check

1. What's the auth library? It probably sends 2-3 emails by default (verify, welcome, password reset).
2. Is there a Stripe webhook handler? It probably sends at least one (payment receipt or failure).
3. Is there a contact form? It probably sends a notification to the team + an autoresponder to the user.
4. Are there scheduled cron emails (digests, reminders)? Check `wrangler.jsonc` triggers, `vercel.json` crons, etc.
5. Is the email content user-personalized or static? Personalization requires variable interpolation; check for unescaped variables (XSS / injection risk).

### Reference

Resend docs: https://resend.com/docs

Postmark transactional best practices: https://postmarkapp.com/transactional-email-templates

**Severity tagging (single-valued per Rule 8):**

- Hardcoded test recipient in production → Critical.
- Send to unverified email addresses (auth-verify race) → High.
- Multiple uncoordinated from-addresses → Medium.
- Stale template references (template ID without matching template) → High.
- Inventory gap (untracked emails) → Medium (informational, not destructive).

**Fix voice:** `solutions-architect` (primary) | `analytics-engineer` (backup, when the inventory is also a measurement / observability concern).

Read `souls/solutions-architect.json` before writing the Fix. SA's voice for "make the system's surface area visible, you can't operate what you don't know exists."

Worked fix example:

> Build the email inventory as a single source of truth in the repo. Every transactional email goes through one helper that logs the send (trigger, template, recipient, from). The team gets a real-time inventory + a paper trail.
>
> ```ts
> // src/server/emails/send.ts
> type EmailKind =
>   | 'signup_welcome'
>   | 'email_verify'
>   | 'password_reset'
>   | 'payment_succeeded'
>   | 'payment_failed'
>   | 'plugin_purchase';
>
> export async function sendTransactional<K extends EmailKind>(
>   kind: K,
>   args: { to: string; data: EmailData[K] },
> ): Promise<void> {
>   const template = TEMPLATES[kind];           // central registry
>   const fromAddr = FROM_ADDRESSES[kind];      // central registry
>   await resend.emails.send({ from: fromAddr, to: args.to, ...template(args.data) });
>   await db.insert(schema.emailLog).values({ kind, to: args.to, sentAt: new Date() });
> }
> ```
>
> Now the inventory is `Object.keys(TEMPLATES)`. The from-addresses are `Object.values(FROM_ADDRESSES)`. The send log is queryable. Every new email goes through this helper or it doesn't ship, enforced by the type system, not by team discipline.
