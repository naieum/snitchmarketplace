# 01 — Auth, profiles, tokens

## AWS auth chain (resolution order)

1. Env vars: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`.
2. `~/.aws/credentials` (per-profile).
3. `~/.aws/config` — SSO sessions, `source_profile` chains.
4. EC2 instance profile / ECS task role / EKS IRSA on AWS-hosted compute.

Pick one. `doctor` resolves the active chain via `sts get-caller-identity`.

## Skill refuses

| Condition | Why |
|---|---|
| `AWS_ACCESS_KEY_ID` starts with `AKIA*` AND any SSO profile in `~/.aws/config` | long-lived static keys are footguns; SSO is short-lived |
| No credentials in any chain step | nothing to authorize |

## SSO setup

```bash
aws configure sso
aws sso login --profile <profile-name>
export AWS_PROFILE=<profile-name>
```

Refresh on expiry: `aws sso login --profile <name>`.

## CI/CD auth

| Platform | Pattern |
|---|---|
| GitHub Actions | OIDC trust + `aws-actions/configure-aws-credentials` (no long-lived secrets). See `templates/github-actions/snitch-aws-on-pr.yml` |
| GitLab CI | OIDC with `id_tokens` |
| EC2 / ECS / EKS | instance profile / task role / IRSA — never secrets in user-data |

## IAM vs Identity Center

| Type | Use for |
|---|---|
| IAM Identity Center (formerly AWS SSO) | humans — short-lived role credentials |
| IAM Users with long-lived keys | legacy automation only — rotate or eliminate |
| IAM Roles | services and federated identities — no static creds |

## Docs

- Auth chain: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html
- SSO: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html
- IAM best practices: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
