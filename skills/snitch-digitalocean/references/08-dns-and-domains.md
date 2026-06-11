# DNS and domains

DigitalOcean provides a free authoritative DNS service via the v2 API and `doctl`.

## DNSSEC: NOT supported

DigitalOcean managed DNS does NOT support DNSSEC. Hard limitation as of 2026.

If DNSSEC matters:

| Option | Path |
|---|---|
| Cloudflare DNS in front (recommended) | Move authoritative DNS to Cloudflare; set `proxied: true` on records. Free DNSSEC + L7 WAF + DDoS. |
| Registrar that signs the zone | Delegate to the registrar's nameservers, not DO's. |

Skill always emits `dns/dnssec-unsupported` WARN on DO-hosted zones.

## CAA records

Skill auto-adds:

```
@ CAA 0 issue "letsencrypt.org"
@ CAA 0 issue "pki.goog"
```

Tighten further if you have a single CA.

## Email DNS

| Record | Pattern |
|---|---|
| SPF (TXT `@`) | `v=spf1 include:<provider> -all` (`-all` is the security choice) |
| DKIM (TXT `<selector>._domainkey`) | Provided by mail vendor |
| DMARC (TXT `_dmarc`) | Start `p=none; rua=mailto:dmarc@yourdomain`; tighten to `quarantine` then `reject` |

## Wildcards

Supported. Use sparingly — bypasses explicit-record audits.

## Common findings

| Status | Finding |
|---|---|
| 🟡 WARN | `dns/dnssec-unsupported` (always on DO-managed zones) |
| 🟡 WARN | Missing CAA (auto-fixable via `fix dns`) |
| 🟡 WARN | Missing SPF for a zone with MX |
| INFO | DMARC at `p=none` for >30d |
