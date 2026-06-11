# 27 — Subdomain takeover (S3) and cookie probe

## S3 subdomain takeover

A CNAME or alias pointing at an S3 bucket name that no longer exists in your account lets an attacker register the same bucket and serve content under your hostname.

### What to look for

- Route 53 ALIAS / CNAME records pointing at `s3-website-<region>.amazonaws.com` or `*.s3.amazonaws.com` where the named bucket isn't in any account you control.
- CloudFront origins where `OriginDomainName` references a missing or cross-account S3 bucket.
- ACM cert validation records pointing at expired buckets.

### How the skill helps

- `state route53` and `state s3` digests give the inputs. Cross-reference: every S3-pointing record must have a live, owned bucket.
- `state cloudfront` shows origins; check each origin's S3 bucket.

### Remediation

| Case | Action |
|---|---|
| Keep the domain | re-create the bucket |
| Don't need it | delete the DNS record |

## Cookie / session probe

```bash
curl -sI https://<your-domain> | grep -i set-cookie
```

| Attribute | Value |
|---|---|
| `Secure` | every cookie |
| `HttpOnly` | session cookies |
| `SameSite` | `Lax` (or `Strict` if it doesn't break OAuth) |

## Other takeover surfaces (out of scope for this skill)

- ELB CNAMEs to deleted load balancers.
- Elastic Beanstalk env URLs that have been terminated.
- API Gateway custom domain mappings to deleted APIs.

Run an external scanner (`subjack`, `dnstwister`) periodically against your DNS zones.
