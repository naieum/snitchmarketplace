# 10 — AWS plan / tier matrix

## Support tiers

| Tier | Approx cost | Tech support | Arch review | Use cases |
|---|---|---|---|---|
| Basic (default) | Free | None (docs only) | None | Personal / pre-prod |
| Developer | ~$29/mo or 3% of spend | Business hours, email | None | Single-developer prod |
| Business | $100/mo or 10/7/5/3% tiered | 24/7 phone/chat/email | None (consult-only) | Small biz prod |
| Enterprise On-Ramp | $5500/mo or 10/7/5/3% | 24/7 + TAM consult quarterly | Light arch review | Mid-market |
| Enterprise | $15000/mo or 10/7/5/3% | 24/7 + dedicated TAM | Continuous | Large enterprise |

`detect_plan` infers tier via `aws support describe-services` (Basic returns AccessDenied → infer Basic). `requires_tier` gates checks.

## Feature gating

| Feature | Available at | Notes |
|---|---|---|
| Trusted Advisor — security checks | Basic (limited 6) → Business+ (full) | Basic gets 6 core; full set needs Business |
| Shield Advanced | Standalone subscription | $3000/mo + data; DDoS Response Team, advanced WAF rules, cost protection |
| Organizations | Free | Required for SCPs, central CloudTrail, Security Hub aggregation |
| Security Hub central admin | With Organizations | Aggregates findings across accounts |
| Config aggregator | With Organizations | Cross-account, cross-region inventory |
| GuardDuty multi-account | With Organizations | Delegated admin in security account |
| CloudTrail org trail | With Organizations | Single trail for all accounts |
| Macie classification jobs | Per-job pricing | Pay per GB scanned |
| IAM Access Analyzer external access | Free | Use it |
| IAM Access Analyzer unused access | Per-IAM-resource pricing | Worth it for any non-trivial account |
| Inspector v2 | Per-resource pricing | EC2 / ECR / Lambda code + package scanning |
| AWS Backup | Storage + backup operation pricing | Vault Lock requires Backup |
| WAFv2 | Per-WebACL + per-request | $5/ACL/mo + $0.60/M req + $1/rule/mo |

## `[locked: …]` surfacing

| Feature | Locked tag |
|---|---|
| Trusted Advisor full security check set | `[locked: business+]` |
| AWS Premium Support during incident | `[locked: business+]` |
| Dedicated TAM for arch review | `[locked: enterprise+]` |

## Docs

- Support plans: https://aws.amazon.com/premiumsupport/plans/
- Pricing: https://aws.amazon.com/pricing/
