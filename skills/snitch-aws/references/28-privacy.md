# 28 — Privacy

## Data residency

- Pick regions deliberately. EU data → eu-* regions; some workloads also need to avoid US-region replication for GDPR.
- KMS keys are region-bound; cross-region usage requires multi-region keys.
- S3 cross-region replication: ON only for DR, not "convenience".

## PII / sensitive data

- Tag resources containing PII: `DataClassification=pii`.
- Macie scans S3 for PII / PHI patterns; enable for buckets with user content.
- Don't log PII to CloudWatch — use structured logs and filter at source.

## Cookie / consent

Outside the skill's CLI scope but in scope for guidance: any tracking pixel / analytics needs a consent banner that defaults to "off" in EU traffic.

## DSAR (data subject access requests)

- Have a runbook: per-user search across S3 / DynamoDB / RDS / logs.
- Tag user data with `user_id` at write time so search is mechanical.

## AWS notes

- CloudTrail logs contain user identifiers (IAM ARNs, IPs). Treat the log archive bucket as PII storage.
- KMS key policy + grants are your privacy enforcement boundary.
