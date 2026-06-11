# 09 — Observability: CloudTrail, CloudWatch, Config

## CloudTrail targets

| Target | Value |
|---|---|
| Multi-region trail | at least one (org trail when in an Organization) |
| Log file integrity validation | ON |
| KMS encryption | customer-managed key |
| CloudWatch Logs | enabled (for metric filters + alarms) |
| S3 destination | separate "log archive" account if Org-managed; bucket policy locks deletion; Object Lock for compliance |
| Selectors | S3 data events per-bucket as needed; Lambda invocation events for high-value functions |

## CloudWatch Logs targets

| Target | Value |
|---|---|
| Retention | set on every log group (default `never` = expensive) |
| KMS encryption | for sensitive log groups |
| Metric filters + alarms | root login, IAM access-key creation outside specific roles, CloudTrail/Config disable, SG rule changes, failed console logins |

## Config targets

| Target | Value |
|---|---|
| Configuration recorder | enabled in every region used (all resources) |
| Delivery channel | centralized S3 bucket |
| Conformance packs | AWS Foundational Security Best Practices + PCI/HIPAA/CIS as relevant |

## Skill checks

- `state cloudtrail` digest: total trails, multi-region, org-trail, log-file-validation, with-KMS, with-CloudWatch-Logs, actively-logging.
- `state cloudwatch` digest: log groups (never-expires count), alarms (in-alarm, no-actions).
- `state config` digest: recorder presence, recording status, all-resources flag, conformance pack count.
- `apply cloudtrail` flips multi-region + log-file-validation on existing trails when missing; warns on missing KMS/CWL.

## Docs

- CloudTrail security: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html
- Metric filters: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudwatch-alarms-for-cloudtrail.html
- AWS Config: https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html
