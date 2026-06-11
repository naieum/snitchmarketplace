## CATEGORY 65: Email compliance (CAN-SPAM, GDPR, CASL, unsubscribe)

Transactional emails are largely exempt from marketing-email compliance laws, but the line is thin: a "welcome" email that includes "check out our other products" content can become marketing in regulators' eyes. Marketing emails MUST include a working unsubscribe + a physical address (CAN-SPAM in US, similar in UK/EU/Canada). Missing these = enforcement risk + immediate deliverability penalty (Gmail and Yahoo now require one-click unsubscribe headers for bulk senders since Feb 2024).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. From Cat 61 inventory: classify each email as transactional (account/order/security) vs marketing (newsletter, promotional, "we miss you").
2. For each marketing email template: `Read` and confirm presence of:
   - Unsubscribe link (must work; pointing at a real `/unsubscribe` route)
   - Physical postal address in the footer
   - Sender identification (who is the email from, what entity)
3. For bulk senders (volume >5000/day): confirm the `List-Unsubscribe` and `List-Unsubscribe-Post` headers are set in the send call (Gmail/Yahoo enforced post Feb 2024).
4. For transactional emails that include any marketing content (cross-sells, "check out our blog"): treat as marketing for compliance purposes.

**Crawl mode, required tool calls:**

1. Skip with reason `compliance audit requires template source + send-config inspection; subscribe and check actual headers/footers`.

### Forbidden claims

- "Unsubscribe may be missing." Read the template; show present-or-absent.
- "List-Unsubscribe header may not be set." Show the send-call's headers config.
- "Email may not be CAN-SPAM compliant." Be specific about which requirement isn't met.

### Detection

#### Source mode

For each marketing email template:

- **Unsubscribe link**: presence + href pointing at a real route + the route actually unsubscribing (not just landing on a "Sorry to see you go" page that doesn't update the user's preferences).
- **Physical address**: full postal address (street, city, state, ZIP). Required by CAN-SPAM + GDPR's identification requirement.
- **Sender identification**: clear statement of which entity is sending.

For send config:

- `List-Unsubscribe` header present + valid mailto: AND/OR https: URL
- `List-Unsubscribe-Post: List-Unsubscribe=One-Click` (Gmail/Yahoo bulk-sender requirement)
- TLS / DKIM / SPF correctly configured (covered in Cat 63 but tied to compliance posture)

For consent tracking:

- If sending marketing emails to EU users: GDPR consent recorded with timestamp, source, scope.
- If sending to Canada: CASL express consent recorded.
- Cross-reference with the privacy policy and consent-management implementation.

#### Crawl mode

Skip with reason.

### What to Search For

Template patterns:
- `unsubscribe`, `Unsubscribe`, `opt-out`
- Physical-address text (street format)
- Sender entity name in footer
- `List-Unsubscribe` header in send call
- `List-Unsubscribe-Post` header

### Actually Hurts the Marketing Surface

- **Marketing email with no unsubscribe link**.
  Evidence required: template body quoted with no unsubscribe element.
- **Unsubscribe link points at a 404 / dev URL**.
  Evidence required: link href + route table or fetch result.
- **Unsubscribe link works but doesn't actually unsubscribe** (lands on a "thanks" page; user is still in the list).
  Evidence required: source code of the unsubscribe handler showing no DB update.
- **No physical address in marketing email footer**.
  Evidence required: footer content quoted.
- **Bulk sender (>5000/day) without `List-Unsubscribe` header**.
  Evidence required: send config + volume estimate.
- **Marketing email sent without recorded consent** (no row in consent log + timestamp + source).
  Evidence required: consent tracking schema vs actual consent flow.
- **"Transactional" email padded with marketing content** (a password-reset email that pitches a Pro plan upgrade).
  Evidence required: template content + the marketing block within.

### NOT a Problem

- Truly transactional emails (receipts, order confirmations, security alerts, password resets) without unsubscribe, exempt under most laws.
- Footer with PO Box instead of street address, acceptable in CAN-SPAM (a registered postal address suffices).
- Marketing email to a user who explicitly opted in via a documented form, consent is explicit, no compliance issue.

### Context Check

1. What jurisdictions does the site serve? US-only = CAN-SPAM. EU = GDPR + ePrivacy. Canada = CASL. UK = UK GDPR. Each has its own bar.
2. Are emails opt-in (user explicitly subscribed) or opt-out (auto-added on signup)? Opt-out is mostly disallowed in EU/Canada.
3. Is consent recorded with source + timestamp? Required for GDPR / CASL audits.
4. Is the unsubscribe one-click or multi-step? Gmail/Yahoo require true one-click for bulk senders.
5. Is the team a registered company with a legal entity? CAN-SPAM "physical address" requires a real one; PO Box acceptable.

### Reference

CAN-SPAM compliance guide: https://www.ftc.gov/business-guidance/resources/can-spam-act-compliance-guide-business

Gmail and Yahoo bulk sender requirements (2024): https://support.google.com/mail/answer/81126

GDPR consent guidance: https://gdpr.eu/consent/

**Severity tagging:**

- Marketing email with no unsubscribe → Critical (enforcement risk + deliverability).
- Unsubscribe link broken → Critical.
- Unsubscribe doesn't actually unsubscribe → Critical (worst-case enforcement).
- No physical address in marketing footer → High.
- Bulk sender without List-Unsubscribe header → Critical (Gmail blocks).
- Sending to EU users without consent record → Critical.
- Marketing pitch in transactional email → Medium (re-categorizes the email).

**Fix voice:** `security-engineer` (primary) | `solutions-architect` (backup).

Read `souls/security-engineer.json` before writing the Fix. SecEng's voice for compliance-as-discipline: regulatory requirements are constraints to design around, not paperwork to add later.

Worked fix example:

> Marketing emails get an unsubscribe link, a physical address, sender identification, and the `List-Unsubscribe` headers. Make those defaults of the marketing-email template; opting out should be impossible to ship without them.
>
> ```tsx
> // src/server/emails/marketing-template.tsx
> export function MarketingEmailLayout({ children, unsubToken }: Props) {
>   return (
>     <Html>
>       <Body>
>         {children}
>         <Section style={{ borderTop: '1px solid #e5e5e5', marginTop: '32px', padding: '16px 0', fontSize: '12px', color: '#666' }}>
>           <Text>
>             You're receiving this because you signed up for Snitch updates.
>             {' '}<Link href={`${BASE_URL}/unsubscribe/${unsubToken}`}>Unsubscribe</Link>
>           </Text>
>           <Text>Snitch, 1234 Real Street, City, ST 12345</Text>
>         </Section>
>       </Body>
>     </Html>
>   );
> }
>
> // Send call always sets the headers
> await resend.emails.send({
>   from: 'Snitch <hello@snitchplugin.com>',
>   to: user.email,
>   subject: subject,
>   react: <MarketingEmailLayout unsubToken={user.unsubToken}>{children}</MarketingEmailLayout>,
>   headers: {
>     'List-Unsubscribe': `<${BASE_URL}/unsubscribe/${user.unsubToken}>, <mailto:unsubscribe@snitchplugin.com>`,
>     'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
>   },
> });
> ```
>
> The `/unsubscribe/[token]` route updates the DB to mark the user as opted-out, idempotently. Returns a confirmation page. Logs the unsubscribe with timestamp + source for audit trail. The next marketing email send filters opted-out users; CI verifies that filter exists.
