# Custom-domain takeover and cookie probe patterns

## Subdomain takeover on Vercel

The pattern:

1. You set `app.example.com` as a project domain.
2. You delete the project (or remove the domain).
3. Your DNS still has `CNAME app.example.com → cname.vercel-dns.com`.
4. An attacker creates a new Vercel project, claims the same project name, attaches `app.example.com`. Vercel sees the dangling CNAME as verification, serves attacker content from your hostname.
5. Browsers trust your cookies (Secure, `Domain=.example.com`) on the attacker's site.

## Mitigations

| Mitigation | Detail |
|---|---|
| Remove DNS record on domain removal | Always |
| Apex hosted-by-A-record | Less takeover-prone where feasible |
| Periodic zone scan | Find CNAMEs to vendors whose project is gone |
| `_dnsauth.<host>` TXT | Vercel verifies initial; rotation matters |

`state domains` lists every project domain. Cross-reference with your DNS to find dangling pointers.

## Cookie scoping

Cookies on a parent (`example.com`) are sent to every subdomain. If `marketing.example.com` is compromised, it can send your `app.example.com` session cookie:

```
Set-Cookie: session=...; Domain=app.example.com; Secure; HttpOnly; SameSite=Lax    # safe
Set-Cookie: session=...; Domain=.example.com;    Secure; HttpOnly; SameSite=Lax    # broad, unsafe
```

Default to host-only cookies (no `Domain` directive) unless cross-subdomain is required.

## Detecting an active takeover

| Signal | How |
|---|---|
| Missing Vercel headers | `curl -I https://<host>/` — absence of `Server`, `x-vercel-*` on a Vercel-hosted host |
| DNS history | SecurityTrails, ViewDNS — historical CNAME |
| Unexpected cert | DevTools — Vercel uses Let's Encrypt + Google Trust Services. Just-issued cert + unfamiliar project = flag |

## Probe

```bash
HOST=app.example.com
curl -sI "https://$HOST" | grep -iE 'server|x-vercel|x-powered-by'
dig +short "$HOST"
# CNAME points at vercel-dns.com but response is "Project not found" → takeover-eligible window.
```

## References

- https://github.com/EdOverflow/can-i-take-over-xyz
- https://vercel.com/docs/projects/domains
