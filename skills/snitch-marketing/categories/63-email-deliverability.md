## CATEGORY 63: Email deliverability (SPF, DKIM, DMARC)

If the sending domain doesn't have SPF, DKIM, and DMARC DNS records correctly configured, transactional emails get spam-foldered (best case) or rejected (worst case). The signup confirmation goes to spam, the user thinks the site doesn't work, they bail. Email deliverability is invisible to the team until users complain, by which point you've lost the funnel for weeks.

### Evidence required (do not skip)

**Crawl mode (DNS), required tool calls:**

1. Identify the sending domain. From Cat 61 inventory, list every from-address. The domain after `@` is the sending domain.

**DNS tooling + fallback (steps 2-4 all need a DNS lookup):** prefer `Bash dig +short TXT …`. If `dig` is unavailable in this environment, fall back to a `Fetch` DNS-over-HTTPS query and parse the JSON `Answer[].data` TXT strings, e.g. `Fetch https://dns.google/resolve?name=<domain>&type=TXT` (or `https://cloudflare-dns.com/dns-query?name=<domain>&type=TXT` with header `accept: application/dns-json`). Quote the resolved TXT data exactly as with `dig`. If neither `dig` nor `Fetch` can reach a resolver, mark the affected record checks **Skip** with reason `no DNS resolver available (dig absent, DoH fetch failed); SPF/DKIM/DMARC not verified` — do NOT report a record as missing when you couldn't query for it (Rule 1).
2. For each sending domain: `Bash dig +short TXT <domain>` to check for SPF (TXT record starting with `v=spf1`).
3. `Bash dig +short TXT <selector>._domainkey.<domain>` for DKIM. Common selectors: `default`, `google`, `mail`, `s1`, `s2`, vendor-specific like `resend`, `postmark`, `mailgun`. Try the vendor's documented selector. **DKIM selectors are not enumerable from DNS — you can only query a selector you already know.** An empty `dig` at a GUESSED selector proves nothing (the real selector is simply one you didn't try); it is NOT evidence DKIM is absent. Only treat empty as a finding when the selector is CONFIRMED from the vendor's docs or the source config (source mode below). In crawl-mode-only with no confirmed selector, mark DKIM **inconclusive / Skip** — see NOT-a-Problem.
4. `Bash dig +short TXT _dmarc.<domain>` for DMARC.
5. Quote each record's content.

**Source mode, required tool calls:**

1. `Read` the email-send config to identify the vendor (Resend / Postmark / SendGrid / SES / Mailgun).
2. From the vendor: identify the DKIM selector + the SPF include directive that should be in the domain's DNS.
3. Cross-reference with the actual DNS records (above).

### Forbidden claims

- "DKIM may not be set up." `dig` for it; quote the result.
- "Emails probably go to spam." Without measurement (Postmark spam-test, Mail-Tester score), you can't claim deliverability outcomes, only DNS configuration.
- "DMARC policy may be wrong." Quote the actual policy.

### Detection

DNS-based, not source-based primarily.

### What to Search For

DNS records:
- `v=spf1` TXT record at the apex domain
- `v=DKIM1` TXT record at `<selector>._domainkey.<domain>`
- `v=DMARC1` TXT record at `_dmarc.<domain>`

Vendor-specific include directives:
- Resend: `include:_spf.resend.com`
- Postmark: `include:spf.mtasv.net`
- SendGrid: `include:sendgrid.net`
- AWS SES: `include:amazonses.com`
- Mailgun: `include:mailgun.org`
- Google Workspace: `include:_spf.google.com`

### Actually Hurts the Marketing Surface

- **No SPF record on the sending domain**.
  Evidence required: `dig +short TXT <domain>` output (no v=spf1 line).
- **SPF record missing the email vendor's include**.
  Evidence required: SPF content quoted + the vendor used (per source mode).
- **No DKIM record at the expected selector**.
  Evidence required: `dig +short TXT <selector>._domainkey.<domain>` returning empty AT A SELECTOR CONFIRMED from the vendor's docs or the source config. An empty result at a guessed selector is NOT a finding (the real selector may differ) — mark inconclusive / Skip instead.
- **No DMARC record**.
  Evidence required: `dig +short TXT _dmarc.<domain>` returning empty.
- **DMARC policy set to `p=none` long-term** (effectively no enforcement; should progress to `quarantine` then `reject`).
  Evidence required: DMARC record content + a note that this is the lowest-strength policy.
- **SPF record exceeds 10 DNS lookups** (RFC 7208 limit; often hit with multiple `include:` directives chained).
  Evidence required: count the includes; flag at 9+ as approaching limit.

### NOT a Problem

- Sending from a major shared sender (Gmail, Outlook personal) where you don't control DNS, different audit shape; flag the lack of branded sending instead.
- DMARC `p=quarantine` or `p=reject` with `pct=100`, strongest enforcement; correct.
- SPF with `~all` (soft-fail) for early-stage sender deployment, acceptable but eventually upgrade to `-all` (hard-fail).
- Multiple SPF includes within the 10-lookup budget, fine.
- **Empty `dig` at a GUESSED DKIM selector is NOT proof of absence.** DKIM selectors can't be enumerated from DNS; you only find one you query for. When the selector is not confirmed from the vendor's docs or the source config, an empty result is inconclusive — mark DKIM **Skip** with reason `DKIM selector not confirmed; an empty guessed-selector lookup is not evidence of absence`, not a finding.

### Context Check

1. What's the email vendor? Each has different DKIM selector + SPF include defaults.
2. Is the sending domain the apex (e.g., `snitchplugin.com`) or a subdomain (`mail.snitchplugin.com`)? DNS records belong on the sending domain.
3. Has DMARC been deployed gradually (none → quarantine → reject)? Going straight to `reject` without a monitoring period can drop legit mail.
4. Is the team using the vendor's "branded sending" / "custom domain" feature? Without it, emails come from the vendor's domain, not yours.
5. Is there a BIMI record (`default._bimi.<domain>`), the brand-logo-in-inbox standard? Optional but a deliverability + brand signal.

### Reference

DMARC.org spec: https://dmarc.org/

Postmark deliverability guide: https://postmarkapp.com/guides/dmarc

Mail Tester (manual deliverability score): https://www.mail-tester.com/

**Severity tagging:**

- No SPF → High. Rejection is governed by DMARC policy, not SPF absence — outright rejection only occurs when a DMARC `reject` / `quarantine` policy is published and the message fails alignment. Without SPF, expect spam-foldering / reduced deliverability, not guaranteed rejection.
- No DKIM (at a CONFIRMED selector) → High. Without a confirmed selector, inconclusive / Skip — not a finding.
- No DMARC → High.
- DMARC stuck at `p=none` for >6 months → Medium (should progress).
- SPF missing vendor include → High.
- SPF >10 lookups → High.
- BIMI missing → Low (nice-to-have).

**Fix voice:** `security-engineer` (primary) | `analytics-engineer` (backup).

Read `souls/security-engineer.json` before writing the Fix. SecEng's voice for DNS / authentication: every domain needs a defined posture for who can send mail as it; absence is a hijack waiting to happen.

Worked fix example:

> Three DNS records, configured once, then monitored. SPF authorizes the vendor. DKIM signs the message body. DMARC tells receivers what to do when SPF or DKIM fails AND publishes failure reports back to you.
>
> ```dns
> ; SPF, apex TXT record
> snitchplugin.com.  IN  TXT  "v=spf1 include:_spf.resend.com -all"
>
> ; DKIM, Resend's documented selector
> resend._domainkey.snitchplugin.com.  IN  TXT  "v=DKIM1; k=rsa; p=MIIBIjANBg…"
>
> ; DMARC, start with quarantine + 100% + RUF reports
> _dmarc.snitchplugin.com.  IN  TXT  "v=DMARC1; p=quarantine; pct=100; rua=mailto:dmarc@snitchplugin.com; fo=1"
> ```
>
> Verify with `dig +short TXT snitchplugin.com` (SPF), `dig +short TXT resend._domainkey.snitchplugin.com` (DKIM), `dig +short TXT _dmarc.snitchplugin.com` (DMARC). Then send a test message to a Mail-Tester address and confirm the score is 9-10/10. Then graduate DMARC from `quarantine` to `reject` after 30 days of clean reports.
