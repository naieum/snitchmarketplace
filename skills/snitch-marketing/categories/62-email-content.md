## CATEGORY 62: Email content quality

The copy, voice, and information architecture inside each transactional email. Stale "beta" labels, generic "Welcome to our platform" greetings, broken merge tags ({{first_name}} rendering literally), CTA buttons that link to localhost, footer addresses left as `123 Main St`. Every transactional email is a customer touchpoint; bad copy poisons the trust the product earned.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. From Cat 61 inventory: list every template file or component that emits email body content.
2. `Read` each template in full. Quote the body content.
3. Check for: stale references ("beta", "coming soon", outdated product names), broken merge tag syntax (`{{varName}}` not interpolated), placeholder values (`123 Main St`, `support@example.com`), CTAs pointing at `localhost`, dev-only domains, or 404 paths.
4. Cross-reference against the project's CLAUDE.md / brand voice guide if present (snitchplugin.com has voice rules: no MCP, no em dashes, no "your laptop", customer-first).

**Crawl mode, required tool calls:**

1. Skip with reason `email content inventory requires source access; subscribe and inspect actual sends for empirical content review`.

### Forbidden claims

- "Email copy may be stale." Read the template; quote the stale phrase.
- "Merge tags might be broken." Read; show the unrendered tag.
- "CTAs probably point at the wrong URL." Quote the href.

### Detection

#### Source mode

For each template:

- **Stale product references**: search for "beta", "coming soon", "v1.x", old product names, sunset features (e.g., MCP for Snitch).
- **Broken merge tag syntax**: `{{var}}`, `${var}`, `<%= var %>`, confirm the template engine actually interpolates these. A literal `{{first_name}}` in production is a finding.
- **Placeholder values shipped**: `123 Main St`, `Lorem ipsum`, `Your Company`, `support@yoursite.com`, default sender names like `Acme Corp`.
- **Localhost / dev URLs in CTAs**: `http://localhost:3000`, `127.0.0.1`, `*.dev`, `*.local`, ngrok tunnels, Vercel preview URLs.
- **Voice mismatches** with the brand's CLAUDE.md / style guide: forbidden phrases (e.g., "your laptop" vs "your device" per snitchplugin's morality fix), em dash density, marketing puffery the brand otherwise avoids.

#### Crawl mode

Skip with reason as above.

### What to Search For

Inside email template files:

- `localhost`, `127.0.0.1`, `*.local`, `*.dev`, `ngrok`
- `123 Main St`, `Lorem ipsum`, `Acme`, `Your Company`, `Your Name`
- `{{`, `${`, `<%=` followed by variables that may not exist in the data shape
- "beta", "coming soon", "TODO", "FIXME", "TBD", "[insert ...]"
- Any string that violates the project's voice guide

### Actually Hurts the Marketing Surface

- **Stale "beta" or "coming soon" labels in production emails**.
  Evidence required: quoted line from template + commit history showing the label predates GA (if available).
- **Broken merge tag rendering literally** in production emails.
  Evidence required: template's `{{var}}` and the data-shape showing `var` doesn't exist OR the template engine doesn't process this syntax.
- **Localhost or preview URL in a CTA href**.
  Evidence required: the `<a href>` value.
- **Placeholder content shipped** (123 Main St, etc.).
  Evidence required: quoted line.
- **Voice violation** that contradicts the brand's documented style guide.
  Evidence required: the line + the rule it violates from CLAUDE.md or equivalent.
- **CTA button leads to a 404 / removed feature**.
  Evidence required: the href + a Fetch of that URL showing the response status.
- **Email asks the user to do something the product no longer supports** (e.g., "Click here to verify via SMS" when SMS verification was removed).
  Evidence required: the line + product context showing the discrepancy.

### NOT a Problem

- Variable placeholders that are correctly interpolated at send-time (verified by checking the `sendEmail({ data: { ... } })` call shape matches the template's variables).
- Brief, no-frills transactional language ("Your password has been reset"). That's correct; not bland.
- Plain-text fallback that's less polished than the HTML version. Acceptable; both should ship.
- Template comments / dev-only conditional content gated by `if (process.env.DEV)`.

### Context Check

1. When was the template last edited? `git blame` the file. Old templates often have stale copy.
2. Does the team have a brand voice guide? Reference it.
3. Are emails localized (multiple languages)? Audit each locale's template.
4. Are CTAs absolute URLs or built from environment variables (preferred)?
5. Does the data-shape passed to the template match what the template expects? Type mismatches produce literal `{{var}}` in output.

### Reference

Litmus on email copy best practices: https://www.litmus.com/blog/transactional-email-best-practices

**Severity tagging:**

- Localhost / preview URL in production email CTA → Critical.
- Broken merge tag rendering literally → Critical.
- Stale product references (e.g., sunset feature) → High.
- Placeholder content shipped → High.
- CTA leading to 404 → High.
- Voice violation → Medium.
- Plain-text fallback missing → Low.

**Fix voice:** `mike-monteiro` (primary) | `frank-chimero` (backup).

Read `souls/mike-monteiro.json` before writing the Fix. Mike's voice on cutting bullshit / keeping copy honest: every word in a transactional email is a promise to the user; broken promises lose trust faster than missing features.

Worked fix example:

> The welcome email tells the user "Welcome to the beta" three years after we launched. The receipt email's CTA links to `localhost:3000`. The password-reset email refers to a "Verify via SMS" button for an SMS feature we removed in 2024. Every one of these is a small lie the user catches. They don't email you about it; they just trust you a little less and remember.
>
> Audit every template against the current product. Strip stale labels. Replace placeholder URLs with environment-derived absolute URLs. Walk every CTA to the page it claims to lead to and confirm the page still exists and does what the email said it would.
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
> Add a CI step that grep-checks templates for `localhost`, `Lorem`, `TODO`, and the project's banned phrases. The first time a stale label sneaks back in, CI catches it before the customer does.
