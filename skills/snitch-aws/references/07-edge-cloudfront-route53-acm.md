# 07 — Edge: CloudFront, Route 53, ACM

## CloudFront targets

| Target | Value |
|---|---|
| S3 origin auth | OAC (not legacy OAI) |
| `MinimumProtocolVersion` | `TLSv1.2_2021`+ |
| `ViewerProtocolPolicy` | `redirect-to-https` on all behaviors |
| WAFv2 ACL | attached with AWS managed rule sets (Common, KnownBadInputs, IpReputation) |
| Security headers | CloudFront Function on `viewer-response` (template provided) |
| Logging | enabled to a separate log bucket |

## Route 53 targets

| Target | Value |
|---|---|
| DNSSEC | signing on public zones; KSK in KMS (us-east-1) |
| Query logging | CloudWatch Logs for security-relevant zones |
| Health checks | production endpoints; failover routing where appropriate |

## ACM targets

| Target | Value |
|---|---|
| Status | `ISSUED`, not expiring in <30 days |
| Validation | DNS, not email |
| Region | `us-east-1` for CloudFront use |

## Skill checks

- `state cloudfront` digest: total, enabled, with-WAF, redirect-to-https, old-TLS, IPv6.
- `state route53` digest: total zones, private vs public, with-DNSSEC-signing, with-query-logging.
- `state acm` digest: total, issued, pending, failed, in-use.
- `apply cloudfront` flags missing-WAF and old-TLS; conservative — re-deploys are opt-in via `force`.

## Docs

- CloudFront OAC: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
- Route 53 DNSSEC: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec.html
- ACM: https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html
