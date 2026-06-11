# 29 — Health checks and failover

## Targets

| Target | Value |
|---|---|
| Health checks | every public-facing endpoint (Route 53 + ALB target group) |
| Multi-AZ | RDS Multi-AZ, ElastiCache Multi-AZ, ALB across AZs |
| Multi-region | high-tier services: Route 53 failover or active-active with latency-based routing |

## Patterns

### Active-passive failover

- Primary in us-east-1, standby in us-west-2.
- Aurora Global Database (1s replica lag typical).
- Route 53 failover routing with health checks on primary.
- DR drills monthly; verify RTO / RPO.

### Active-active

- Two regions serving traffic via Route 53 latency-based or geolocation routing.
- DynamoDB Global Tables for write-anywhere data.
- S3 Cross-Region Replication for objects.

## Skill checks

- Route 53 health checks: `state route53` (full slice).
- ALB target group health: outside scope — use console or CloudWatch metrics.

## Failure modes

| Mode | Coverage |
|---|---|
| Single-AZ outage | Multi-AZ |
| Single-region outage | only multi-region |
| Service-wide (e.g., us-east-1 IAM control plane) | can't fully escape if you depend on us-east-1 (CloudFront, billing, IAM); design for graceful degradation |
| DNS provider outage | Route 53 rarely has full outages; consider secondary DNS for highest tier |
