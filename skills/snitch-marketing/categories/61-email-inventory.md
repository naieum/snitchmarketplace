## CATEGORY 61: Transactional email inventory & templates

What emails does the site send, when, to whom, from where — and what is inside each one? Most teams can list 2-3 emails off the top of their head and forget the other 8 that the framework, plugins, or third-party services fire automatically. Untracked emails mean stale copy in production: "we noticed our welcome email still says 'beta'". The audit runs one pass over one evidence source. First build the inventory (what gets sent, who triggers it, what template emits it, what the from-address is), then read every template in that inventory twice: once for content (stale labels, unrendered merge tags, dev URLs, placeholder values) and once for rendering and accessibility (layout primitive, inline CSS, image alt, preview text, plain-text alternative, dark mode, container width).

Deliverability (SPF, DKIM, DMARC) is Cat 63; consent and compliance (CAN-SPAM, GDPR, CASL, unsubscribe) is Cat 65; lifecycle / drip / newsletter programs are Cat 71. This category is the transactional surface itself.

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
4. Build the inventory: trigger → handler file:line → template → from-address.
5. `Read` every template in the inventory in full. Quote the body content. Check for stale references ("beta", "coming soon", outdated product or feature names), broken merge-tag syntax (`{{varName}}` rendering literally), placeholder values (`123 Main St`, `support@example.com`), and CTAs pointing at `localhost`, dev-only domains, preview URLs, or 404 paths.
6. In the same read, capture the rendering shape: layout primitive (email-component library, MJML, hand-built HTML tables, or `<div>` layout), inline `style=` vs `<style>` block vs external class names, image alt text, container max-width, preview-text element, dark-mode declaration (`<meta name="color-scheme">` or a `prefers-color-scheme` rule), and whether the send call passes a `text:` alternative alongside the HTML.
7. Cross-reference against the project's own voice guide if present (`CLAUDE.md`, `AGENTS.md`, a `brand/` or `voice.md` doc). Quote the rule the template breaks at `file:line`. If the project has no voice guide, Skip this check with that reason rather than importing rules from anywhere else.

**Crawl mode, required tool calls:**

1. Largely unavailable in pure crawl mode (server-side sends aren't visible). Mark as **Skip** with reason `email inventory and template audit require source access; crawl mode cannot enumerate server-side sends`.
2. Optional partial check: subscribe to a public newsletter or sign up with a throwaway address IF the user approves it, and capture the emails actually received. Say in the report that this is empirical sampling, not a full inventory, and that rendering was observed in one client only.

### Forbidden claims

- "The site probably sends X emails." Either you grepped and found the send sites, or you don't know.
- "Welcome email may be missing." Either there's a send-on-signup handler in source, or there isn't.
- "Email copy may be stale." Read the template; quote the stale phrase.
- "Merge tags might be broken." Read; show the unrendered tag.
- "CTAs probably point at the wrong URL." Quote the href.
- "Outlook may render this badly." Quote the layout and the CSS you actually read, and name the rendering behavior you're relying on.
- "Images may lack alt." Quote the image element.

### Detection

#### Source mode

**Inventory.** Look for any code path that calls an email-sending API:

- Auth library hooks: `databaseHooks.user.create.after` (Better Auth), `events.signUp` (NextAuth), Clerk webhooks
- Stripe webhook workflows: payment success / failure / subscription started / cancelled / renewed
- Custom triggers: contact form handlers, lead-capture forms, password reset, API key issued, invitation accepted, milestone events
- Background jobs: cron handlers, queued workers, scheduled functions

For each: extract the trigger, the template, the from-address, and the to-address shape (`user.email` vs hardcoded vs param).

**Content, per template in the inventory.**

- **Stale product references**: "beta", "coming soon", "v1.x", old product names, a capability the product no longer ships.
- **Broken merge-tag syntax**: `{{var}}`, `${var}`, `<%= var %>` — confirm the template engine actually interpolates these. A literal `{{first_name}}` in production is a finding.
- **Placeholder values shipped**: `123 Main St`, `Lorem ipsum`, `Your Company`, `support@yoursite.com`, default sender names.
- **Localhost / dev URLs in CTAs**: `http://localhost:3000`, `127.0.0.1`, `*.local`, ngrok tunnels, preview deployment URLs.
- **Voice mismatches** with the project's own voice guide, if present: a phrase the guide forbids, a punctuation or density rule it sets, or puffery the brand otherwise avoids. Evidence required: the guide's rule quoted at `file:line` alongside the template line that breaks it. Never invent a voice rule the project has not written down.

**Design and accessibility, per template in the inventory.**

- **Layout primitive**: an email-component library, MJML, or hand-built HTML tables each have known cross-client behavior; `<div>` flexbox/grid layout does not survive every client.
- **CSS**: inline styles (safe) vs a `<style>` block (often stripped) vs class names that depend on external CSS (broken in most clients).
- **Image alt**: every image element needs alt text — several desktop clients block images by default and show the alt in their place.
- **Container width**: a ~600px max-width container is the email convention; wider clips on mobile.
- **Dark mode**: `<meta name="color-scheme">` declared, dark-mode-aware colors, no swapped background left with unswapped text.
- **Preview text**: a preview element or hidden preheader controlling the inbox preview line.
- **Plain-text alternative**: a `text:` field alongside the HTML, for clients and filters that prefer multipart.

#### Crawl mode

Skip with reason as above.

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

Template locations:
- Email-component JSX imports, `*.mjml` files, `*.hbs` / `*.ejs` templates, inline `<html>...</html>` template literals

Inside each template:
- `localhost`, `127.0.0.1`, `*.local`, `ngrok`, preview-deployment hostnames
- `123 Main St`, `Lorem ipsum`, `Your Company`, `Your Name`, generic default sender names
- `{{`, `${`, `<%=` followed by variables that may not exist in the data shape
- "beta", "coming soon", "TODO", "FIXME", "TBD", "[insert ...]"
- `<table` (table layout) vs `<div` (risky), `<style>` blocks vs inline `style=`, image elements without `alt`
- `prefers-color-scheme: dark`, `<meta name="color-scheme" content="light dark">`
- the preview-text / preheader element
- Any string that violates the project's voice guide

### Actually Hurts the Marketing Surface

**Inventory**

- **Email triggered but not documented**. Evidence required: the handler file:line + the trigger description. Write it to the report so the team has a complete inventory.
- **Multiple from-addresses** across emails (some `noreply@`, some `support@`, some a personal domain). Evidence required: enumerate from-addresses across all sends.
- **Send code references a template that doesn't exist**. Evidence required: the send call's template ID/path + a Glob/Read showing absence.
- **Hardcoded recipient address shipped in production code** (a debug `to:` left in). Evidence required: the hardcoded address.
- **Send-on-signup that fires before the address is confirmed**. Evidence required: the handler + the order of verification and welcome-send.

**Content**

- **Stale "beta" or "coming soon" labels in production emails**. Evidence required: the quoted line + commit history showing the label predates GA, if available.
- **Broken merge tag rendering literally**. Evidence required: the template's `{{var}}` + the data shape showing `var` doesn't exist, or the engine not processing that syntax.
- **Localhost or preview URL in a CTA href**. Evidence required: the `href` value.
- **Placeholder content shipped**. Evidence required: the quoted line.
- **CTA leading to a 404 or a removed feature**. Evidence required: the href + a Fetch of that URL showing the response status.
- **The email asks for something the product no longer supports**. Evidence required: the line + the product context showing the discrepancy.
- **Voice violation** against the project's documented guide. Evidence required: the template line + the guide's rule at `file:line`.

**Design and accessibility**

- **`<div>` flexbox/grid layout instead of tables**. Evidence required: the layout pattern quoted.
- **CSS only in a `<style>` block, none inlined**. Evidence required: the `<style>` block + elements without inline `style=`.
- **Image with no alt attribute**. Evidence required: the image element (WCAG 2.2 1.1.1).
- **No preview text**. Evidence required: template missing a preview / preheader element.
- **No plain-text alternative**. Evidence required: the send call passing only HTML.
- **Container wider than the email convention** (clipped on mobile). Evidence required: the container max-width.
- **Dark-mode rendering broken** (backgrounds swapped, text not). Evidence required: the color CSS + the missing dark-mode override.
- **Button is a styled link with no `display: inline-block` or table-cell wrapper** (renders as a plain text link in some clients). Evidence required: the button's HTML.

### NOT a Problem

- A site that sends one transactional email. The inventory is small but complete.
- Provider-hosted receipts (the payment processor sends them). Document them as out of scope for this site's audit.
- Plugin / SaaS-hosted emails the team doesn't customize. Note presence; not a finding.
- Variables that are correctly interpolated at send time (verified against the send call's data shape).
- Brief, no-frills transactional language ("Your password has been reset"). That's correct, not bland.
- A plain-text fallback less polished than the HTML version; template comments and dev-only conditional content.
- An email-component library used throughout — it handles table layout, inlining, and most of the rendering checks on its own.
- Client-specific conditional comments (`<!--[if mso]>`). Required workarounds, not bugs.
- Static images that read correctly in both light and dark mode (logos with transparency).

### Context Check

1. What's the auth library? It probably sends 2-3 emails by default (verify, welcome, password reset).
2. Is there a payment webhook handler? It probably sends at least one (receipt or failure).
3. Is there a contact form? It probably sends a team notification plus an autoresponder.
4. Are there scheduled cron emails (digests, reminders)? Check the platform's cron config.
5. When was each template last edited? `git blame` the file — old templates carry stale copy.
6. Are emails localized? Audit each locale's template.
7. Are CTAs absolute URLs or built from environment variables (preferred)?
8. Which template system is in use? Each has different defaults for inlining, tables, and dark mode.
9. Has the team ever tested rendering in a real client matrix? Without that, "designed for email" is theoretical — say so rather than asserting a client's behavior.
10. Is the content user-personalized? Personalization means variable interpolation; check for unescaped variables (injection risk).

### Reference

Resend docs: https://resend.com/docs

Postmark transactional best practices: https://postmarkapp.com/transactional-email-templates

WCAG 2.2 1.1.1 (non-text content) governs the image-alt finding; the criterion table in `categories/103-accessibility-conformance.md` is the authority on how to write an accessibility finding.

**Severity tagging (single-valued per Rule 8):**

- Hardcoded test recipient in production → Critical.
- Localhost / preview URL in a production CTA → Critical.
- Broken merge tag rendering literally → Critical.
- Send to unverified email addresses (auth-verify race) → High.
- Stale template reference (template ID without a matching template) → High.
- Stale product references (a sunset feature) → High.
- Placeholder content shipped → High.
- CTA leading to a 404 → High.
- Layout that a major client cannot render (div-based, or CSS only in a stripped `<style>` block) → High.
- Multiple uncoordinated from-addresses → Medium.
- Inventory gap (untracked emails) → Medium (informational, not destructive).
- Image with no alt → Medium. No preview text → Medium. No plain-text alternative → Medium.
- Dark mode broken → Medium. Container wider than the convention → Medium.
- Voice violation against the project's own guide → Medium.

**Fix voice:** `solutions-architect` (primary) | `honest-design-critic` (backup, when the finding is about what the copy promises).

Read `souls/solutions-architect.json` before writing the Fix. The voice for "make the system's surface area visible — you can't operate what you don't know exists."

Worked fix example:

> Build the email inventory as a single source of truth in the repo. Every transactional email goes through one helper that logs the send (trigger, template, recipient, from). The team gets a real inventory and a paper trail.
>
> ```ts
> // src/server/emails/send.ts
> type EmailKind =
>   | 'signup_welcome'
>   | 'email_verify'
>   | 'password_reset'
>   | 'payment_succeeded'
>   | 'payment_failed';
>
> export async function sendTransactional<K extends EmailKind>(
>   kind: K,
>   args: { to: string; data: EmailData[K] },
> ): Promise<void> {
>   const template = TEMPLATES[kind];           // central registry
>   const fromAddr = FROM_ADDRESSES[kind];      // central registry
>   await mailer.send({ from: fromAddr, to: args.to, ...template(args.data) });
>   await db.insert(schema.emailLog).values({ kind, to: args.to, sentAt: new Date() });
> }
> ```
>
> Now the inventory is `Object.keys(TEMPLATES)`, the from-addresses are `Object.values(FROM_ADDRESSES)`, and the send log is queryable. Every new email goes through this helper or it doesn't ship, enforced by the type system rather than by team discipline.
>
> Then walk the templates the registry now lists. The welcome email says "Welcome to the beta" three years after launch; the receipt's CTA links to `localhost:3000`; the reset email points at a verification method that was removed. Each one is a small lie the customer catches, and they don't write in about it — they trust the product a little less. Strip stale labels, replace hardcoded URLs with environment-derived absolute ones, and walk every CTA to the page it claims to lead to.
>
> ```tsx
> // Before: stale copy + dev URL
> <Text>Welcome to the beta!</Text>
> <Button href="http://localhost:3000/dashboard">Get started</Button>
>
> // After: current + env-derived
> <Text>Welcome to {APP_NAME}.</Text>
> <Button href={`${BASE_URL}/dashboard`}>Get started</Button>
> ```
>
> Standardize the rendering in the same pass. An email-component library compiles JSX to table-based, inline-styled HTML, so the team stops hand-maintaining client workarounds. Whatever the system, each template needs the same six things: a preview-text element, a ~600px container, alt text on every image, inline styles, a declared color scheme with dark-mode-aware colors, and a plain-text alternative on the send call.
>
> ```tsx
> <Html lang="en">
>   <Preview>Your account is ready. Here's what to do first.</Preview>
>   <Body style={{ backgroundColor: '#0a0a0a', color: '#f5f5f5', margin: 0 }}>
>     <Container style={{ maxWidth: '600px', margin: '0 auto', padding: '24px' }}>
>       <Img src={`${BASE_URL}/email/header.png`} alt={APP_NAME} width={200} height={40} />
>       <Section style={{ padding: '24px 0' }}>
>         <Text style={{ fontSize: '16px', lineHeight: '24px' }}>Hi {userName}, your account is ready.</Text>
>         <Button href={dashboardUrl} style={{ padding: '12px 24px', borderRadius: '6px', display: 'inline-block' }}>
>           Open dashboard
>         </Button>
>       </Section>
>     </Container>
>   </Body>
> </Html>
> ```
>
> Add a CI step that greps templates for `localhost`, `Lorem`, `TODO`, images without `alt`, and the project's own banned phrases. The first time a stale label sneaks back in, CI catches it before the customer does. Send the finished template through a real client matrix once; after that the shape is fixed and every send inherits it.
