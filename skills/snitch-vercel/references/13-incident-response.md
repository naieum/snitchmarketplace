# Incident response

## Quick triage

| Symptom | First tools | Reasoning |
|---|---|---|
| Site down / 5xx surge | `state deployments 24h`; `vercel logs <prod-url>` | Recent bad deploy? Roll back. |
| Cert error | `state domains` | Verification dropped, DNS change |
| Function timeout | `state functions`; `vercel logs <url>` | Region misconfig or DB slow |
| DDoS / bot wave | `state cost`; `panic lock-production` | Cut surface area |
| Compromised token | `state account tokens`; `panic revoke-token <id>` | Stop the bleed |
| Leaked secret in repo | `apply_env`; rotate via `vercel env rm` + add | Re-issue, redeploy |
| Stuck preview link being indexed | `apply_project preview-auth` | Vercel Auth on previews |

## Playbooks

### A) Bad production deploy

```bash
bash snitch-vercel.sh state deployments 24h
vercel rollback <good-deploy-url>
bash snitch-vercel.sh panic pause-deploys      # optional, while investigating
```

### B) Compromised token

```bash
bash snitch-vercel.sh state account tokens
bash snitch-vercel.sh panic revoke-token <token-id>
# Rotate every secret that token could read/write.
# Audit git history; if committed, force-push to scrub (tell the team first).
```

### C) Leaked secret env var

```bash
# 1. Rotate at the source (provider's own dashboard).
# 2. Update Vercel.
vercel env rm OLD_KEY production
vercel env add OLD_KEY production --sensitive
# 3. Trigger a redeploy.
vercel --prod
# 4. NEXT_PUBLIC_* leaks: old value still served from CDN until deploy expires.
#    File takedown if it landed in third-party caches (Wayback, search engines).
```

### D) DDoS / bot wave

```bash
bash snitch-vercel.sh state cost                    # snapshot traffic
bash snitch-vercel.sh panic lock-production         # SSO Auth on all deployments
# Add stricter middleware rate-limit + bot block.
# Pro+: configure Vercel Firewall rules to block by ASN/country.
bash snitch-vercel.sh panic restore                 # once attack subsides
```

### E) Domain hijack / takeover

```bash
bash snitch-vercel.sh state domains
dig +short www.example.com
# If a previously-removed domain shows as taken, attacker may have re-registered
# the project name. Reclaim by re-adding (will fail until they release).
# Dispute via Vercel support.
```

## Postmortem checklist

- Timeline: when did each event happen (UTC). Cross-reference Vercel audit log.
- Root cause: what changed. Deploy? Config edit? External dependency?
- Detection: how did you find out? Was alerting fast enough?
- Impact: how many requests; what data was exposed.
- Action items: changes to prevent recurrence. Owner, deadline.
- File a Vercel support ticket if the incident touched their platform layer.

## What `panic` records

Every action writes to `.state/panic-<ts>-<action>.json`:

```json
{
  "ts": "...",
  "action": "lock-production",
  "before": { "ssoProtection": null, "passwordProtection": null },
  "after": { "ssoProtection": { "deploymentType": "all" } }
}
```

`panic restore` replays `before` payloads in reverse-chrono order. Not every action is reversible — a revoked token must be recreated by hand.

## References

- https://vercel.com/docs/incident-response
- https://vercel.com/docs/observability/audit-log
