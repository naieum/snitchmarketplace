# 03 — Network and VPC

## Targets

| Target | Value |
|---|---|
| 0.0.0.0/0 ingress on management ports (22, 3389, 3306, 5432, 27017, 6379, 9200, 11211) | none |
| VPC Flow Logs | every VPC, ship to S3 or CloudWatch Logs |
| Egress allowlists | document why if `0.0.0.0/0` |
| VPC endpoints | for S3, DynamoDB, ECR, Secrets Manager, etc. — keeps off internet, reduces NAT cost |
| Public IPs | only when needed; auto-assign-public-IP off in private subnets |

## Skill checks

- `state vpc` digest: SG counts with world-open management ports per port number, NACL count, flow logs coverage, peerings, transit gateways, VPC endpoints.
- `apply vpc` flags world-open SG rules as `FAIL` but does NOT auto-revoke; warns on VPCs without flow logs.

## When `0.0.0.0/0` is OK

- Public ALB/NLB on 80/443 (with WAFv2 + HTTPS redirect).
- CloudFront origin SG (restrict source SGs to the CloudFront managed prefix list).
- Outbound 443 for SDK calls.

## Bastion vs SSM Session Manager

Don't run a bastion. Use `aws ssm start-session` — no inbound 22, no public IPs, full audit log.

## Transit Gateway

- Default route propagation overshares — use route-table-per-segment.
- Centralize egress through a TGW-attached VPC with NAT + egress-only IGW.

## Docs

- VPC security: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html
- Flow logs: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
- Session Manager: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
