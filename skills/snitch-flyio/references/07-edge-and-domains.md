# 07 — Edge and domains

## Default hostname

Every app gets `<app>.fly.dev`. TLS auto-managed via Let's Encrypt. Anycast across all Fly regions.

## Custom domains

```sh
fly certs add example.com -a <app>
fly certs show example.com -a <app>     # DNS records to set
fly certs check example.com -a <app>    # verify DNS + cert
fly certs list -a <app>
fly certs remove example.com -a <app>
```

Fly auto-renews. `fly certs check` surfaces renewal failures.

DNS records:

| Record | Purpose |
|---|---|
| A `example.com → <fly-v4-ip>` | IPv4 routing. |
| AAAA `example.com → <fly-v6-ip>` | IPv6 routing. |
| CNAME / TXT for ACME | Wildcards / apex with HTTPS validation. |

Apex options:

| Option | Tradeoff |
|---|---|
| Cloudflare DNS in front (orange cloud) | DNSSEC, WAF, DDoS, free CDN. Requires `force_https=true` on Fly. |
| Direct A/AAAA to Fly | Simplest. No DNSSEC unless registrar supports. |

## DNSSEC

Fly does NOT support DNSSEC for `.fly.dev`. For custom domains:

| Provider | Action |
|---|---|
| Cloudflare DNS | Enable DNSSEC; add DS at registrar. |
| Route53 / Google Domains / Namecheap | Each has its own flow. |

The skill flags missing DNSSEC as `WARN` — not always actionable.

## HSTS

Set in app response headers. Fly doesn't intercept:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

Submit to https://hstspreload.org after weeks of stable HSTS — one-way commitment. `bash snitch-flyio.sh score <host>` includes the preload check.

## CAA records

```
example.com.  CAA  0 issue "letsencrypt.org"
example.com.  CAA  0 issue "pki.goog"
```

Fly may use Google Trust Services. Best practice; not required.

## Anycast vs CDN

Fly's TLS endpoint is anycast — request hits nearest edge, proxies to nearest healthy machine. CDN is unnecessary unless cache-hit rate is high (then put Cloudflare or Bunny in front).

## What `score <host>` returns

| Validator | Reads |
|---|---|
| SSL Labs | TLS config grade. |
| Mozilla Observatory | Response-header policy. |
| securityheaders.com | Same. |
| HSTS preload | Status in preload list. |

## Common mistakes

| Mistake | Cost |
|---|---|
| `fly certs check` shows expired | Usually DNS changed. |
| DNSSEC at registrar but DS misaligned | Validation fails. |
| HSTS in [env] but framework strips response headers | Verify with `curl -I https://<host>`. |
| `fly certs add '*.example.com'` without DNS-01 setup | Wildcard validation fails. |
