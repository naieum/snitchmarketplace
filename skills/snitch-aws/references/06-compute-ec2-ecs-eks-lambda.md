# 06 — Compute (EC2, ECS, EKS, Lambda)

## EC2 targets

| Target | Value |
|---|---|
| IMDSv2 | required (`HttpTokens=required`) |
| EBS encryption-by-default | ON at account level |
| Public IP | only when required; egress via NAT or VPC endpoints |
| AMI sources | AWS-vended or owned. Community AMIs are a footgun |
| Patching | SSM Patch Manager, not by hand |
| Bastion | replace with SSM Session Manager (no port 22 ingress) |

## ECS / Fargate targets

| Target | Value |
|---|---|
| Compute | Fargate over EC2 unless GPU / custom kernel needed |
| Task role | least-privilege; no `*` actions |
| Secrets | Secrets Manager via task definition `secrets` (not `environment`) |
| Container Insights | ON for clusters that matter |
| ECR | scan-on-push enabled |

## EKS targets

| Target | Value |
|---|---|
| Control plane logging | `audit, authenticator, controllerManager, scheduler, api` |
| Endpoint | private preferred; if public, restrict CIDRs |
| Secrets encryption | KMS key at cluster create-time |
| IRSA | use instead of node-instance-profile sharing |
| Pod Security | baseline+ minimum; OPA/Kyverno for policy |
| Network policies | Calico / Cilium |

## Lambda targets

| Target | Value |
|---|---|
| Execution role | least-privilege; no `*:*` |
| Secrets in env vars | none — use Secrets Manager / SSM SecureString |
| Function URL `AuthType` | `AWS_IAM`; `NONE` only for intentional public webhooks with HMAC verification |
| Code signing | production functions (Signer) |
| DLQ | async invocations |
| VPC config | only when needed (cold-start cost) |
| `reservedConcurrentExecutions` | for blast-radius control |

## Skill checks

- `state ec2` digest: instances, IMDSv2 vs v1 allowed, public-IP count, EBS encryption-by-default.
- `state lambda` digest: total, runtimes, with-VPC, with-DLQ, env-secret-heuristic count.
- `state eks` digest: total clusters, public-endpoint, with-secrets-encryption, full-logging coverage.

## Docs

- IMDSv2: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html
- ECS task IAM roles: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
- EKS best practices: https://docs.aws.amazon.com/eks/latest/best-practices/
- Lambda security: https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html
