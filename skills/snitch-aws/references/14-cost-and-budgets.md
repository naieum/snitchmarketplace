# 14 — Cost and budgets

## Targets

| Target | Value |
|---|---|
| Budget | at least one with email, alerting at 80% and 100% |
| Cost Anomaly Detection | monitor on the account |
| Tags | `Project`, `Owner`, `Environment` mandatory; cost-allocation tags activated |
| Untagged-cost rate | < 5% |
| Savings Plans | evaluated for steady-state compute spend |

## Cost cliffs

| Cliff | Why | Mitigation |
|---|---|---|
| NAT Gateway egress | $0.045/GB processed + hourly | VPC endpoints for S3, DynamoDB, ECR; centralize NAT in shared egress VPC |
| Cross-AZ traffic | $0.01/GB each way | Affinity-based routing; keep app + DB in same AZ where viable |
| CloudFront data transfer out | varies by region; cheaper than direct S3 egress | Always serve heavy reads via CloudFront |
| Lambda + Provisioned Concurrency | hourly per concurrent execution | Use only for cold-start-sensitive paths |
| GPU instances on EC2 | $1-30/hr | Spot for training, On-Demand for inference floor |
| CloudWatch Logs ingestion | $0.50/GB | Shorter retention, sampling, structured logs |
| EBS gp3 vs gp2 | gp3 cheaper at same IOPS | Migrate gp2 → gp3 |
| Idle RDS | hourly even at 0 conns | Stop dev RDS overnight; Aurora Serverless v2 scales to 0.5 ACU |

## Skill checks

- `state cost` digest: top services 30d (blended), total 30d, budgets count, anomaly monitor count.
- `analytics` provides 7d/30d/90d windows.

## When AWS isn't the cheapest

- Egress-heavy CDN: Cloudflare's $0 egress beats CloudFront pricing.
- Single-VPS-style workloads: DigitalOcean / Hetzner is cheaper.
- Per-request serverless without Reserved: Lambda + DynamoDB On-Demand can outprice a tiny container at low scale.

## Docs

- Cost Explorer: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/ce-what-is.html
- Budgets: https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
- Anomaly Detection: https://docs.aws.amazon.com/cost-management/latest/userguide/getting-started-ad.html
