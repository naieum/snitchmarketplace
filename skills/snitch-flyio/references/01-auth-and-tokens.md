# 01 — Auth and tokens

Three auth surfaces: `flyctl` user login, organization-scoped tokens, app-scoped deploy tokens. Pick the smallest scope for each use case.

## User login

```sh
fly auth login          # browser; writes ~/.fly/config.yml
fly auth whoami         # confirm identity
fly auth logout         # clears ~/.fly/config.yml
```

The personal identity. Avoid in CI — use a deploy token.

## Token types

| Type | Scope | Created with | Use for |
|---|---|---|---|
| User session | account-wide | `fly auth login` | Local dev only. |
| Org deploy token | one org | `fly tokens create deploy --org <org>` | CI/CD across multiple apps. |
| App deploy token | one app | `fly tokens create deploy -a <app>` | Single-app CI/CD. |
| Org admin token | one org | `fly tokens create org` | Admin scripts (rare). |
| 1FA token | account-wide | dashboard | One-shot operations. |

Always set `--expiry`. Default is no expiry — long-tail risk:

```sh
fly tokens create deploy --org <org> --expiry 720h --name "ci-prod-2026q2"   # 720h = 30 days
```

## In CI

Set `FLY_API_TOKEN` as a repo secret. `flyctl` honors it automatically.

```yaml
env:
  FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

## Rotate / revoke

```sh
fly tokens list --org <org>
fly tokens revoke <token-id>
```

`bash snitch-flyio.sh state tokens <org>` digest surfaces:

| Signal | Meaning |
|---|---|
| `tokens_summary.no_expiry` | Indefinite-lifetime tokens. |
| `tokens_summary.expired` | Already expired but still listed — revoke for hygiene. |

## 2FA

Required on every member account. Enroll at `https://fly.io/user/security`. Org-level enforcement via org settings. Members without 2FA flag as `FAIL`.

## Hygiene checklist

- [ ] Personal `fly auth login` token NOT in CI.
- [ ] Every deploy token has `--expiry` ≤ 90 days.
- [ ] Deploy tokens have descriptive `--name` (env + purpose).
- [ ] Tokens for ex-employees / decommissioned services are revoked.
- [ ] All members have 2FA.
