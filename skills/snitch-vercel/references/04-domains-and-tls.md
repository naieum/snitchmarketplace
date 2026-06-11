# Domains and TLS

## Verification

Every project domain has a `verified` boolean. Vercel needs ownership proof before issuing TLS:

- **Vercel-managed nameservers**: assign Vercel as the registrar's NS — automatic.
- **External nameservers** (Cloudflare, Route53, ...): add the verification TXT/A records from `vercel domains inspect <domain>`.

`state domains` lists every project domain; `verified: false` is `FAIL`.

## TLS

- Auto-issues + auto-renews Let's Encrypt + Google Trust Services certs.
- TLS 1.3 default; TLS 1.2 fallback. Modern cipher suites only.
- Certificate transparency logs are public — fine.

You don't configure cert pinning, OCSP stapling, or stapled stapling — Vercel handles it.

## DNSSEC

**Vercel's managed DNS does not support DNSSEC**. If your threat model requires it:

1. Delegate DNS to a DNSSEC-capable registrar (Cloudflare, AWS Route53 with DNSSEC, Google Cloud DNS).
2. Point that registrar's records at Vercel as ALIAS/A.
3. Enable DNSSEC at the registrar; add the DS record at the parent zone.

The skill emits `WARN` for every Vercel-managed domain — DNSSEC isn't enableable inside Vercel.

## Apex vs www

Vercel issues TLS for both. Pick one canonical form; 308-redirect the other:

```json
{
  "redirects": [
    {
      "source": "/(.*)",
      "has": [{ "type": "host", "value": "example.com" }],
      "destination": "https://www.example.com/$1",
      "permanent": true
    }
  ]
}
```

## Wildcards

Wildcard certs (`*.example.com`) require Vercel-hosted DNS or Vercel verification.

## HSTS

Set HSTS via `vercel.json` headers (see `references/05-headers-via-vercel-json.md`). Vercel doesn't set HSTS by default.

For preload eligibility:
- `max-age >= 31536000` (1 year)
- `includeSubDomains`
- `preload`
- Apex must redirect HTTP→HTTPS (Vercel does this automatically).

Submit at https://hstspreload.org.

## Custom-domain takeover risk

Removing a project but leaving a CNAME → `cname.vercel-dns.com` enables takeover. Always remove the DNS record when removing the domain. The skill flags dangling CNAMEs as `WARN` in `state domains` if `verified: false` for an extended window.

## References

- https://vercel.com/docs/projects/domains
- https://vercel.com/docs/projects/domains/working-with-dns
- https://vercel.com/docs/projects/domains/working-with-domains#redirecting-www-and-non-www-domains
- https://hstspreload.org
