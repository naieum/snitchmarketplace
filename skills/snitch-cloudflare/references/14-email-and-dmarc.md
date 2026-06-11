# 14 — Email Auth: SPF / DKIM / DMARC / MTA-STS / BIMI

## SPF (TXT at apex)

```
v=spf1 include:_spf.google.com include:amazonses.com -all
```

Mechanisms: `include:`, `mx`, `a`, `ip4:`, `ip6:`. Final: `-all` (hard fail, preferred), `~all` (soft, common during migration), `?all` (useless).

10-DNS-lookup limit — `include:` chains break SPF if exceeded. Skill counts via `dig` walks.

Common includes: `_spf.google.com` (Google Workspace), `spf.protection.outlook.com` (M365), `amazonses.com` (SES), `sendgrid.net`, `mailgun.org`, `spf.mtasv.net` (Postmark), `zoho.com`, `servers.mcsv.net` (Mailchimp).

Source: https://datatracker.ietf.org/doc/html/rfc7208

## DKIM (TXT at `<selector>._domainkey.<domain>`)

```
google._domainkey.example.com  TXT  "v=DKIM1; k=rsa; p=MIGf...IDAQAB"
```

Skill discovery: detect provider via MX + SDK signals → `dig TXT <selector>._domainkey.<domain>` → flag missing/weak. See provider quick-ref below.

Source: https://datatracker.ietf.org/doc/html/rfc6376

## DMARC (TXT at `_dmarc.<domain>`)

```
v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com; fo=1; aspf=s; adkim=s; pct=100
```

| Field | Meaning |
|---|---|
| `p=` | `none` (monitor), `quarantine` (junk), `reject` (bounce) |
| `rua=` | aggregate report URI (required for monitoring) |
| `ruf=` | per-incident failure URI (optional; can leak content) |
| `fo=` | `0` (both fail) or `1` (any fail) — `1` more useful |
| `aspf` / `adkim` | `r` relaxed (default) or `s` strict |
| `pct=` | rollout percentage |

Skill ramp: `none` (week 1) → `quarantine; pct=10` (week 2) → `quarantine; pct=100` (week 4) → `reject` (week 8).

Free aggregators for `rua`: postmarkapp.com/dmarc (default), dmarcian, valimail, easydmarc.

Source: https://datatracker.ietf.org/doc/html/rfc7489

## MTA-STS (RFC 8461)

DNS TXT at `_mta-sts.<domain>`: `"v=STSv1; id=<YYYYMMDD>"`.

HTTPS at `https://mta-sts.<domain>/.well-known/mta-sts.txt`:

```
version: STSv1
mode: enforce
mx: *.gmail.com
max_age: 604800
```

Modes: `none` / `testing` / `enforce`. Skill default: `testing` for one week → `enforce`. CF delivery: Worker or Pages route.

## TLS-RPT (RFC 8460)

DNS TXT at `_smtp._tls.<domain>`: `"v=TLSRPTv1; rua=mailto:tlsrpt@example.com"`. Free; pairs with MTA-STS.

## BIMI

DNS TXT at `default._bimi.<domain>`: `"v=BIMI1; l=https://example.com/bimi-logo.svg; a=https://example.com/bimi-vmc.pem"`.

Requires DMARC `quarantine` or stricter. SVG must be SVG Tiny PS, square, no scripts. VMC required for Gmail/Yahoo display — Entrust ($1.5k–$3k/yr) or DigiCert.

Skill surfaces BIMI as INFO only — security wins are in DMARC.

Source: https://bimigroup.org/

## DNSSEC for email

Without DNSSEC, an attacker hijacking DNS can rewrite SPF/DKIM/DMARC. See `02-dns-ssl-tls.md`.

## New-domain ramp

1. CF zone live; switch nameservers.
2. SPF TXT at `@` with provider `include:` + `-all`.
3. DKIM per provider (often CNAMEs for SES/SendGrid/M365).
4. DMARC `_dmarc` TXT, `p=none; rua=mailto:<aggregator>`.
5. Wait 1 week; review reports.
6. `p=quarantine; pct=10`. Wait 1 week.
7. `p=quarantine; pct=100`. Wait 2 weeks.
8. `p=reject`.
9. Optional: MTA-STS (testing → enforce); TLS-RPT.
10. Optional: BIMI + VMC.

## Provider quick-ref

| Provider | SPF include | DKIM record |
|---|---|---|
| Google Workspace | `_spf.google.com` | TXT `google._domainkey` |
| Microsoft 365 | `spf.protection.outlook.com` | CNAMEs `selector1/2` |
| Amazon SES | `amazonses.com` | 3 CNAMEs `<token>._domainkey` |
| SendGrid | `sendgrid.net` | CNAMEs `s1/s2._domainkey` |
| Mailgun | `mailgun.org` | TXT `<region>._domainkey` |
| Postmark | `spf.mtasv.net` | TXT `pm._domainkey` |
| Zoho | `zoho.com` | TXT `zoho._domainkey` |
| CF Email Routing (forward only) | `_spf.mx.cloudflare.net` | n/a |

Source: https://developers.cloudflare.com/email-routing/

## API

DMARC body: `{type:"TXT", name:"_dmarc", content:"v=DMARC1; p=none; rua=mailto:...", ttl:3600}`. See `11-api-cheatsheet.md`.
