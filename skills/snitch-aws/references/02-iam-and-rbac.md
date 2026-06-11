# 02 — IAM and RBAC

## Targets

| Target | Value |
|---|---|
| Long-lived access keys for humans | none — console + MFA, programmatic via SSO + assume-role |
| Password policy | 14+ chars, complexity, 90-day max, 24-history, change-allowed |
| MFA | required for every human; hardware keys for root + privileged roles |
| Access Analyzer | account-level analyzer in every region used |
| Policy wildcards | no `*` in `Action` or `Resource` for human-managed policies; customer-managed > AWS-managed > Inline |
| Role ownership | tag `Owner=<team>` on every role |

## Skill checks

- `state iam` digest: users, with-MFA, roles, customer-managed policies, attachment count, Access Analyzer presence, key age (>90d highlighted).
- `apply iam` enables Access Analyzer if missing; warns on access keys >90 days; recommends MFA / password policy via `apply account`.

## Access key rotation

1. `aws iam list-access-keys --user-name <user>` → find old key.
2. `aws iam create-access-key --user-name <user>` → new key.
3. Distribute; verify usage via CloudTrail.
4. `aws iam update-access-key … --status Inactive`.
5. Wait 7-14 days; verify nothing broke.
6. `aws iam delete-access-key …`.

## SCPs (in an Organization)

Useful baselines on OUs / accounts:

- Deny disabling CloudTrail or removing Config recorders.
- Deny IAM access-key creation outside break-glass roles.
- Deny region pinning outside an allowlist.
- Deny S3 PAB disabling.

## Docs

- IAM best practices: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
- Access Analyzer: https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html
- SCPs: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
