# 02 — DNS, SSL/TLS

## SSL/TLS encryption mode — target `strict`

`PATCH /zones/{id}/settings/ssl` body `{"value":"strict"}`.

| Mode | Posture |
|---|---|
| `off` | refuse |
| `flexible` | FAIL — origin sees plaintext |
| `full` | better, no origin cert validation |
| `strict` | target — both legs HTTPS, origin cert validated |

`always_use_https` = on forces 301 HTTP → HTTPS at edge.

Source: https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/

## TLS version + 1.3

- `min_tls_version`: target `1.2`; `1.3` if no legacy clients. Never lower in `fix`.
- `tls_1_3`: target `on`.

Sources: https://developers.cloudflare.com/ssl/edge-certificates/additional-options/minimum-tls/ , https://developers.cloudflare.com/ssl/edge-certificates/additional-options/tls-13/

## HSTS

`PATCH /zones/{id}/settings/security_header`:

```json
{"value":{"strict_transport_security":{
  "enabled": true, "max_age": 31536000,
  "include_subdomains": true, "preload": true, "nosniff": true }}}
```

- `max_age` target `31536000`. New sites: ramp `86400` → `604800` → `31536000`.
- `include_subdomains: true` only after scanning DNS for non-HTTPS hosts.
- `preload: true` is irreversible at scale — warn before flipping. Submit at https://hstspreload.org/.
- `nosniff: true` always.

Don't set HSTS in both the toggle and a Transform Rule — toggle wins.

Source: https://developers.cloudflare.com/ssl/edge-certificates/additional-options/http-strict-transport-security/

## Certificates

| Cert | Plan | Notes |
|---|---|---|
| Universal SSL | Free | apex + one-deep wildcard, auto-renews |
| ACM | Pro+ ($10/mo add-on) | custom hostnames in SAN, validity choices, CT monitoring |
| Custom Cert | Biz/Ent | BYO |
| Origin Certificate | Free (account-level `POST /certificates`) | up to 15-year cert; pair with `strict` + AOP |

Sources: https://developers.cloudflare.com/ssl/edge-certificates/universal-ssl/ , https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/

## Authenticated Origin Pulls (AOP)

mTLS between Cloudflare and origin.

| Variant | Plan | API |
|---|---|---|
| Global cert | Free | `PATCH /zones/{id}/settings/tls_client_auth`; origin trusts CA at https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem |
| Per-Zone cert | Pro+ | upload custom cert |
| Per-Hostname | Enterprise | per-hostname cert |

Skill targets Global AOP free; Per-Zone where the user has a custom CA.

Source: https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/

## CT monitoring

Free: dashboard toggle + email. Enterprise: API + webhooks.

Source: https://developers.cloudflare.com/ssl/edge-certificates/additional-options/certificate-transparency-monitoring/

## DNSSEC

1. `PATCH /zones/{id}/dnssec` `{"status":"active"}` — Cloudflare returns DS values.
2. Registrar must paste the DS record. Cloudflare can do this only on Cloudflare Registrar.

`fix dnssec` activates + prints DS verbatim with per-registrar links (Namecheap, GoDaddy, Google/Squarespace, Gandi, Hover, Porkbun). After 24h, `verify` checks parent DS and flips to OK. Disable order: remove DS at registrar first, then `PATCH dnssec disabled`.

Source: https://developers.cloudflare.com/dns/dnssec/

## Proxied vs DNS-only

Target `proxied: true` for all public A/AAAA/CNAME. Allowed exceptions: `mail.<domain>`, `_dmarc`, MX targets; TXT/SRV (never proxied); origin hostnames intentionally exposed.

Grey-cloud A on a public site is the #1 origin-IP leak vector. Flag `WARN`.

Source: https://developers.cloudflare.com/dns/proxy-status/

## CAA

```
@ IN CAA 0 issue "pki.goog"
@ IN CAA 0 issue "letsencrypt.org"
@ IN CAA 0 issue "digicert.com"
@ IN CAA 0 issuewild "pki.goog"
@ IN CAA 0 issuewild "letsencrypt.org"
@ IN CAA 0 issuewild "digicert.com"
@ IN CAA 0 iodef "mailto:security@<domain>"
```

If user adds ACM with a specific CA, narrow CAA to that issuer.

Source: https://developers.cloudflare.com/ssl/edge-certificates/caa-records/

## API endpoints

See `11-api-cheatsheet.md`. Key:
- `GET/PATCH /zones/{id}/settings/{ssl|min_tls_version|tls_1_3|always_use_https|automatic_https_rewrites|opportunistic_encryption|tls_client_auth|security_header}`
- `GET/PATCH /zones/{id}/dnssec`
- `GET /zones/{id}/ssl/universal/settings`, `GET /zones/{id}/ssl/certificate_packs`
