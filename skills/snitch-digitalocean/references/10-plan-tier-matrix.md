# Plan / account tier matrix

DigitalOcean does not have product plan tiers like Cloudflare. Most security features are universal. The relevant distinction is **personal vs team account**.

## Personal vs team

| Feature | Personal | Team |
|---|---|---|
| 2FA enforcement | per-user | per-user (no admin enforcement) |
| Member roles | N/A | Owner / Member / Biller / Modifier |
| Audit log | basic | full |
| SSO (SAML/OIDC) | no | Premier-tier teams (custom) |
| Billing alerts | yes | yes |
| Resource limits | lower | higher (raisable via support) |
| Support tier | community / standard | standard / premier |

## Resource pricing tiers

| Resource | Tier | Security implication |
|---|---|---|
| Managed DB | Basic vs Production | Production: HA + read replicas + PITR. Basic: single-node, no PITR. **Use Production for prod data.** |
| DOKS | Standard vs HA | HA control plane ~$40/mo extra. **Enable HA for prod.** |
| App Platform | Static / Basic / Pro | Pro: better limits, priority support. Security checks are identical. |
| Container Registry | Free / Basic / Professional | Free has very limited storage. Vulnerability scanning is per-tier. |

## Team-only items the skill flags `[locked: team+]`

- Multi-member RBAC checks (`apply_account` skips on personal accounts).
- Audit-log slice (returns empty on personal; surfaces a note, not FAIL).

Skill detects account type via `/v2/account` (`team` field present → team).
