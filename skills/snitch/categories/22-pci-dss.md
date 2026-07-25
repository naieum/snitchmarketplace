## CATEGORY 22: PCI-DSS
> Type: compliance · Groups: compliance · CWE: CWE-311

> **Standard version: PCI DSS v4.0.1 (June 2024).** Every requirement number below is v4.0.1.
> v4.0.1 has been the sole supported version since 31 December 2024; **v3.2.1 was retired on
> 31 March 2024**. The future-dated v4 requirements — including 6.4.3 and 11.6.1 — became mandatory
> on **31 March 2025**. Findings from this category are read by assessors, so cite the version
> alongside the number, and re-check this block whenever the SSC publishes a revision.
>
> **Do not use v3.2.1 numbering.** Two of the old numbers now resolve to unrelated live requirements:
> v3.2.1's `3.4` (render PAN unreadable) is v4.0.1's **3.5.1**, while v4.0.1's `3.4.1` is *masking on
> display*; v3.2.1's `4.1` (transit crypto) is v4.0.1's **4.2.1**, while v4.0.1's `4.1.x` are policy
> and roles requirements. A stale number does not read as stale — it reads as a different finding.

> **Cross-reference:** overlaps with Category 13 (Stripe Security) for processor integration and
> Category 32 (Security Headers) for CSP and header syntax. If a *processor SDK* finding is already
> reported under Cat 13, or a *generic header* finding under Cat 32, reference it here rather than
> reporting twice.
>
> **Neither deferral extends to 6.4.3 or 11.6.1.** Those are properties of the payment *page* as a
> PCI control, not of the processor integration and not of generic header hygiene. Cat 13 does not
> cover them and Cat 32 does not know which page is a payment page. Report them **here**, in full,
> even when a related CSP finding is filed under Cat 32. Pushing the browser surface to a
> neighbouring category is how a skimmer-shaped repository passes this one clean.

---

### First, establish the integration shape

Every disposition below depends on which of these the code is, and it is usually decidable in a few
minutes. Determine it before reporting anything.

| Shape | Recognised by | Consequence |
|---|---|---|
| **Processor-hosted fields** — Stripe Elements/Checkout, Braintree Hosted Fields, Square Web Payments, Adyen Components | an SDK mounting an iframe (`js.stripe.com`, `#card-element`), server sees only `pm_…` / `tok_…` / a nonce | No PAN reaches the server, so the storage and transmission requirements have little to bite on — say that, rather than "out of scope," which is a formal scoping determination an assessor makes, not a scanner. **6.4.3 and 11.6.1 still apply**: the standard says so explicitly for a page that "includes a TPSP's/payment processor's embedded payment page/form" |
| **Direct-post / client-side tokenization** — card fields on the merchant page, posted to the processor by JS | `<input autocomplete="cc-number">` on the merchant page plus a tokenization call | PAN transits the consumer browser under merchant-controlled script. **6.4.3 and 11.6.1 dominate** |
| **Server-side raw card handling** | card fields posted to the merchant's own endpoint | The application, its host, and its network segment are in the CDE. Everything below applies |

A category that never asks this question reports a compliant hosted-fields integration as raw card
handling, and passes a direct-post page that is one malicious script away from a breach.

### Detection
- Card data: `card_number`, `cardNumber`, `card_no`, `ccnum`, `cc_number`, `pan`,
  `primary_account_number`, `credit_card`
- Security codes: `cvv`, `cvv2`, `cvc`, `cvc2`, `cid`, `cvn`, `security_code`, `securityCode`
- Other SAD: `track2`, `track_data`, `pin_block`, `pinblock`
- Cardholder data: `expiry`, `exp_date`, `expMonth`, `cardholder`, `service_code`
- Markup: `autocomplete="cc-number"`, `cc-csc`, `cc-exp` — the reliable way to find a payment page
- Processors: Stripe, Braintree, Square, Adyen, Checkout.com, Worldpay, Authorize.Net, Cybersource,
  PayPal, Recurly, Chargebee

Match case- and separator-insensitively: `securityCode`, `security_code`, and `SECURITY_CODE` are the
same field.

### What to Search For
- A card or SAD field reaching a persistence sink — DB write, log call, cache, queue, file, or a
  client-side store. **The sink, not the variable name**
- `sha256`/`md5`/`bcrypt` applied to a card number, and any hash co-stored with a truncation
- Card data in a route path, query string, or redirect `Location`
- Full PAN interpolated into markup, a receipt, an email body, or a PDF
- `ssl_protocols` / `SSLProtocol` / ALB and CloudFront TLS policies naming early TLS, and cipher
  lists without an explicit ECDHE + AEAD restriction
- `<script src>` on a page carrying `autocomplete="cc-*"` inputs or a processor iframe, without
  `integrity=` or a CSP `script-src`
- Tag managers, analytics, session replay, and chat widgets on a payment page
- Absence of a CSP `report-uri`/`report-to` and of any script inventory
- Encryption keys committed to source or stored beside the ciphertext they protect

---

### Requirement 3 — stored account data

**What may be stored after authorization**, per **Requirement 3.2.1's Guidance (v4.0.1)**, verbatim:
*"the primary account number or PAN (rendered unreadable), expiration date, cardholder name, and
service code."*

> Read `3.2.1` here as a **live v4.0.1 requirement number**, not as the retired version `v3.2.1`. The
> collision is unfortunate and it is the standard's, not ours — the version is always written with a
> leading `v`.

So **expiry and cardholder name are permitted**, and storing them is not a finding. The violation is
cleartext PAN, or SAD, regardless of what else sits beside it.

| Condition | Requirement | Severity |
|---|---|---|
| Card verification code stored after authorization | **3.3.1.2** (umbrella 3.3.1) | Critical |
| Full track data stored after authorization | **3.3.1.1** | Critical |
| PIN / PIN block stored after authorization | **3.3.1.3** | Critical |
| SAD stored *before* authorization completes, unencrypted | **3.3.2** | High |
| PAN stored in cleartext anywhere | **3.5.1** | Critical |
| PAN rendered unreadable by an **unkeyed** hash | **3.5.1.1** | High |
| Full PAN displayed beyond BIN + last four | **3.4.1** | Medium |

**3.3.1 is not eligible for the customized approach** — there is no compensating-control path for
storing SAD after authorization. Say so in the finding; it removes an argument before it starts.

**But 3.3.2 exists, so do not write an absolute rule.** SAD held *before* authorization completes is
permitted when encrypted with strong cryptography. "Any variable named `cvv`" is not a finding — an
in-flight `cvv` is present in every correct direct-post integration and in every hosted-field page's
markup. **The finding is persistence past authorization**: trace the value to a database write, a
log, a cache, a queue, or a file.

**Unkeyed hashes (3.5.1.1).** The requirement is explicit that hashes used to render PAN unreadable
must be *"keyed cryptographic hashes of the entire PAN, with associated key-management processes."*
`sha256(pan)`, `md5(pan)`, and a bare `bcrypt(pan)` all fail it, and all read as "tokenized" to a
naive rule. The reason is entropy. For a 16-digit PAN with a known 6-digit BIN, the unknowns are
16 − 6 − 1 = **9 digits** — the last digit is the Luhn check and is determined by the rest — so about
**10^9 candidates**, and roughly **10^7** for an 8-digit BIN. Seconds to minutes on a GPU. (Do not
also claim Luhn cuts that by a further order of magnitude; the check digit is already excluded from
the count.) **Storing a truncation beside the hash is worse**, because the last four confirm each
brute-forced candidate instantly. Same argument as Category 9: classify by the entropy of the value
being hashed, not by the strength of the algorithm.

**Where stored PAN actually turns up.** 3.5.1 says *"anywhere it is stored"*, and its testing
procedure names payment application logs explicitly. Beyond the obvious database column:
- application logs, `console.log`, and exception messages that interpolate a request body
- error trackers — Sentry `extra`/breadcrumbs, Datadog, Rollbar
- analytics and product-telemetry payloads
- message-queue bodies, webhook forwards, and their retry stores
- cache keys and values, backups, seed data, and test fixtures with real data
- **client-side**: `localStorage`, `sessionStorage`, `IndexedDB`, cookies, and hidden form fields.
  Common in AI-written checkout code and invisible to a server-only search

### Requirement 4 — transmission

| Condition | Requirement | Severity |
|---|---|---|
| Weak protocol on a payment host — `TLSv1`, `TLSv1.1`, `SSLv3` | **4.2.1** | High |
| Cipher suite without forward secrecy, or with CBC + SHA-1 MACs | **4.2.1** (see Appendix G) | Medium |
| PAN sent by email, SMS, or chat | **4.2.2** | High |

Drop one level where TLS is plausibly terminated upstream and this repo's config is not the live one.

**PAN in a URL is a Requirement 3 finding, not a Requirement 4 one.** This is the single easiest
mistake to make here. 4.2.1 requires *"strong cryptography and security protocols … to safeguard PAN
during transmission over open, public networks"* — and over HTTPS that control **is present**. The
PAN is encrypted on the wire. The violation is **3.5.1**, because a URL is stored in places TLS never
reaches: web-server and proxy access logs, browser history and the address bar, the `Referer` sent to
every third-party script on the page, CDN and WAF logs, APM traces. Cite 3.5.1 primary, 4.2.1
secondary, and 4.2.2 only if the code actually mails or texts the value. A finding that cites 4.2.1
for an HTTPS URL gets rejected, because the control it names is right there.

**Cipher strings need real predicates.** "Weak cipher configuration" is not actionable. `HIGH:!aNULL:!MD5`
looks strong and is not: with `TLSv1` enabled it yields CBC suites with SHA-1 MACs and static-RSA key
exchange, so no forward secrecy. Appendix G defines strong cryptography as *"a minimum of 112-bits of
effective key strength and proper key-management practices."* Prefer an explicit ECDHE + AEAD list.
Early TLS is permitted only under Appendix A2, which covers **card-present POS POI terminals** —
never a browser-facing checkout host.

### Requirements 6.4.3 and 11.6.1 — the payment page

> **Mandatory since 31 March 2025.** These are the anti-skimming (Magecart) requirements, they are
> the most code-visible requirements in all of v4, and they are the ones most likely to correspond to
> an actual breach. Applies to any e-commerce entity with a payment page rendered in the consumer's
> browser — **including hosted-fields integrations**, since the page around the iframe is still the
> payment page.

**6.4.3** requires that every script loaded and executed in the consumer's browser on a payment page
is (a) confirmed authorized, (b) integrity-assured, **and** (c) inventoried with written
justification. All three, not any one.

**Scope, from the requirement's own applicability notes** — this is the part most often got wrong:

- It *"applies to all scripts loaded from the entity's environment and scripts loaded from third and
  fourth parties."* **First-party scripts are in scope.** `/assets/checkout.js` with no integrity
  digest is a finding exactly as an analytics tag is. A content-hashed filename alone is not
  integrity assurance to a browser — pair it with `integrity=` or a CSP hash.
- It *"also applies to scripts in the entity's webpage(s) that includes a TPSP's/payment processor's
  embedded payment page/form (for example, one or more inline frames or iframes)."* Hosting Stripe
  Elements does not exempt the surrounding page.
- It *"does not apply to an entity for scripts in a TPSP's/payment processor's embedded payment
  page/form"* — those *"are the responsibility of the TPSP/payment processor."* **Do not reason about
  what runs inside the processor's iframe.** You cannot see it, and it is not the entity's control.

Findings:
- A `<script src>` — **first- or third-party** — on a page carrying card inputs or a processor
  iframe, with no `integrity=` attribute and no CSP hash pinning it
- **Tag managers, analytics, session replay, chat widgets, and A/B tools specifically.** 6.4.3's
  guidance names tag management systems: they *"can be used by potential attackers to upload
  malicious scripts that can read and exfiltrate cardholder data from the consumer browser."* A tag
  manager is worse than a plain script — it injects further scripts after load, so an integrity
  digest on the loader bounds nothing
- No script inventory anywhere in the repository

**A CSP origin allowlist is authorization, not integrity.** `script-src https://cdn.example` says
*which origins may serve scripts*; it says nothing about *what those scripts contain*, so a
compromised-but-allowlisted CDN passes it. Do not treat the presence of a `script-src` as satisfying
6.4.3 on its own — it satisfies (a) and leaves (b) open. Only a hash — `integrity=` or a
`'sha256-…'` source expression — satisfies (b). The one accepted exception is the vendor
mutable-URL case below.

**11.6.1** requires a change- and tamper-detection mechanism alerting on unauthorized modification to
security-impacting HTTP headers and payment-page script contents *as received by the consumer
browser*, evaluated at least weekly (or per a 12.3.1 targeted risk analysis).

A scan can evidence the code-visible half: which security headers the app sets, and whether a CSP
reporting endpoint exists. It **cannot** evidence that a monitor runs, at what frequency, or that
alerts reach anyone. Report the absence of any mechanism as a finding; do not mark the requirement
satisfied on the strength of a CSP alone.

**`report-uri` and `report-to` do not work in a `<meta>` tag.** Both directives are header-only —
"this directive is not supported in the `<meta>` element" — so a CSP delivered as
`<meta http-equiv="Content-Security-Policy" content="… report-uri /csp-report">` silently reports
nothing. Crediting it is a false Pass on a mechanism that does not exist at runtime, and it is a
common mistake in real code. Check *how* the CSP is delivered before counting its reporting
directive: only an HTTP response header carries one.

**A vendor script without SRI is not automatically a finding.** Some processors ship deliberately
mutable, versionless URLs (`js.stripe.com/v3/`) where a digest would break on every vendor update. A
documented CSP allowlist plus the vendor's own integrity story is an accepted approach — record it
as a Pass with the justification named, not as a violation. **This exception is narrow**: it applies
to a processor's own versionless SDK URL with a written justification in the inventory, and to
nothing else. It is not a general licence to accept a CSP in place of a digest.

### Severity for the payment-page requirements

| Condition | Requirement | Severity |
|---|---|---|
| Third-party script — analytics, tag manager, chat, session replay — on a payment page, no integrity, no inventory | **6.4.3** | High |
| First-party script on a payment page with no integrity assurance | **6.4.3** | Medium |
| No script inventory anywhere for a page that loads external scripts | **6.4.3** | Medium |
| No tamper-detection mechanism and no working CSP reporting on a payment page | **11.6.1** | Medium |
| Any of the above where the page could not be confirmed to be a payment page | either | Low, `needs human verification` |

---

### Actually Vulnerable
- Card verification code, track data, or PIN persisted after authorization (**3.3.1.x**, Critical)
- SAD held pre-authorization without strong encryption (**3.3.2**)
- Cleartext PAN in a database, log, telemetry payload, queue, cache, or client-side store (**3.5.1**)
- PAN rendered unreadable by an unkeyed hash, or a hash co-stored with a truncation (**3.5.1.1**)
- PAN in a URL path or query string (**3.5.1**, not 4.2.1)
- Full PAN rendered into a page, receipt, email, or PDF (**3.4.1**)
- PAN interpolated into an email/SMS body — SendGrid, Twilio, Resend, SES (**4.2.2**)
- `TLSv1` / `TLSv1.1` / `SSLv3`, or a cipher list permitting non-PFS or SHA-1-MAC suites (**4.2.1**)
- Unpinned, un-inventoried third-party scripts on a payment page (**6.4.3**)
- No tamper-detection mechanism or CSP reporting on a payment page (**11.6.1**)
- Encryption keys hardcoded in source or config, or stored beside the data they protect (**3.6.1.2**)
- **SAD or cleartext PAN reaching a response body** — a handler that renders a whole payment record
  into a template, JSON response, or admin view without selecting fields. `res.render('receipt', { payment })`
  ships whatever columns exist, including a stored `securityCode`. Cite **3.3.1.x** for SAD or
  **3.4.1** for unmasked PAN, and note that the storage finding and the disclosure finding are
  separate: fixing the query does not unstore the data
- Card fields posted to the merchant's own origin when a hosted-field option exists. **This is a
  scoping observation, not a Requirement 3 or 4 violation** — it widens the CDE and changes SAQ
  eligibility (**12.5.2**, scope confirmation). Report it as context attached to the findings it
  causes, or as its own Low-severity item tagged `needs human verification`; do not invent a
  requirement number for it

### NOT Vulnerable
- Processor tokens: `pm_*`, `tok_*`, `cus_*`, Braintree nonces, Square source IDs
- Expiry, cardholder name, and service code stored **without** cleartext PAN — explicitly permitted
  by 3.2.1's guidance
- Last four / BIN + last four stored or displayed (**3.4.1** permits BIN + last four as the maximum)
- Masked display: `****1234`
- A card-format validation regex or Luhn check that neither stores nor transmits. A `\d{13,19}`
  *constant* in a validator is a format check, not a card number and not a logging statement — match
  the pattern to find candidates, then judge by what the code does with the value
- Test card numbers in test files: `4242424242424242`, `4111111111111111`, `5555555555554444`
- An in-flight `cvv` variable in a request handler that does not persist it past authorization
- The authorization response code (`authCode`) — it is not SAD. SAD is track data, card verification
  code, and PIN/PIN block, and nothing else
- Processor SDK usage with no raw card handling
- A vendor script under a documented CSP allowlist where the vendor publishes no stable digest

### Context Check
1. Which integration shape is this? (table above) — answer this first
2. Is the value real card data or a processor token?
3. For SAD: does it persist past authorization, or is it in-flight only?
4. For a PAN: is it cleartext, truncated, keyed-hashed, or unkeyed-hashed?
5. Is there a payment page in this repository, and what does it load?
6. Is TLS terminated in this repo's config or upstream? If upstream, say so and drop to Medium
7. Is this test code with test card numbers?

### Evidence Chain
- The snippet at file:line showing the card data handled
- The **trace** from the value's entry point to the persistence or transmission sink. A variable
  named `pan` is not a finding — `panHash`, `pan_last4`, `panToken`, and `company` all match the
  search term. `Type: compliance` means Rule 7 tracing is not automatically mandatory for this
  category; **this category requires it anyway** for any finding about card data in code
- Confirmation it is real card data — not a token, a validation regex, or a test card
- The **v4.0.1 requirement number**, with the version named
- The missing control, verified absent — no tokenization, no masking, the specific weak protocol or
  cipher in a live config, the absent `integrity`/CSP
- Reachability: a production payment path, not tests or fixtures
- Repository visibility and whether TLS is terminated in scope

### Confidence Scoring
- **High**: PAN or SAD verifiably persisted or logged in production code; an explicit weak TLS version
  in live configuration; an un-inventoried third-party script on a page carrying card inputs
- **Medium**: card-named variables whose tokenization status is partly inferred; TLS possibly
  terminated upstream (load balancer, CDN) outside the repo; cipher-list weakness that depends on the
  negotiated protocol
- **Low**: cannot distinguish raw card data from tokenized references or test data; cannot determine
  whether a page is a payment page — tag `needs human verification`

### Files to Check
- `**/payment*`, `**/checkout*`, `**/billing*`, `**/charge*`, `**/refund*` — any extension, not just
  `.ts`. This category applies equally to `.js`, `.py`, `.rb`, `.php`, `.java`, `.go`, `.cs`
- `**/stripe*`, `**/braintree*`, `**/adyen*`, and the other processors listed under Detection
- **Payment page markup**: `*.html`, `*.jsx`, `*.tsx`, `*.vue`, `*.erb`, `*.blade.php`, email
  templates. Findings 6.4.3 and 11.6.1 live only here — a TypeScript-only glob misses them entirely
- **TLS configuration wherever it lives**: `nginx.conf`, Apache `ssl.conf`, Caddyfile, HAProxy, and
  the Terraform/CloudFormation for ALB listeners, CloudFront distributions, and API Gateway domains
- Logging configuration, error-tracker initialization, analytics initialization
- `.env*` and key-management configuration
