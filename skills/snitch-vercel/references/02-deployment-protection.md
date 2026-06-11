# Deployment protection

Vercel offers four protection surfaces; combine for your environment split.

## Surfaces

| # | Surface | Tier | Use case |
|---|---|---|---|
| 1 | Vercel Authentication (SSO) | Pro+ for preview; all-tiers limited | Force visitors to sign in with Vercel before viewing a deployment. Prevents Google indexing of preview links. |
| 2 | Password protection | Pro+ | Single shared password — lower friction than SSO for external stakeholders. |
| 3 | Trusted IPs | Enterprise | IP allowlist; outside list sees 403. Pairs with VPN / corporate network. |
| 4 | Deployment Approvals | Pro+ via Git | Manual approval (or status check) before production. Configure in Settings → Git → Production deploys. Not fully API-readable — surfaced as `WARN`. |

API surfaces (1) and (2):

- `PATCH /v9/projects/<id>` with `{"ssoProtection":{"deploymentType":"preview"}}`.
- `PATCH /v9/projects/<id>` with `{"passwordProtection":{"deploymentType":"preview","password":"..."}}`. The skill never types the password value.

## OAuth + integrations

Review OAuth apps and marketplace integrations periodically: Settings → Security → OAuth applications. Marketplace tokens (Sentry, LogDNA, Stripe) get scoped tokens — audit them.

## Recommended baseline

| Environment | Recommended |
|---|---|
| Preview | Vercel Auth (preview) for internal-only; Password for external stakeholders |
| Production | None (public site); Trusted IPs (Enterprise) for internal apps; SSO for ALL only during incidents (`panic lock-production`) |
| Branch deploys (non-main) | Same as Preview |

## Fork protection

`gitForkProtection: true` blocks unauthorized forks from triggering deploys. On by default for new projects; the skill verifies during `state protection`.

## References

- https://vercel.com/docs/security/deployment-protection
- https://vercel.com/docs/security/deployment-protection/methods-to-protect-deployments/vercel-authentication
- https://vercel.com/docs/security/deployment-protection/methods-to-protect-deployments/password-protection
- https://vercel.com/docs/security/deployment-protection/methods-to-protect-deployments/trusted-ips
- https://vercel.com/docs/deployments/checks
