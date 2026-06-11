# Incident response

## Token leaked — first 15 minutes

1. Revoke the token at https://cloud.digitalocean.com/account/api/tokens.
2. Generate a new scoped token with 90-day expiry.
3. Update `DIGITALOCEAN_ACCESS_TOKEN` in shells, CI secrets, k8s secrets, `.env` files.
4. Rotate Spaces access keys at https://cloud.digitalocean.com/account/api/spaces. (API tokens and Spaces keys are distinct; rotate both if either could have been observed.)
5. Rotate kubeconfig for every DOKS cluster: `doctl kubernetes cluster kubeconfig save --expiry-seconds 0`.
6. Rotate Container Registry credentials.
7. Rotate any SSH keys stored alongside the token.
8. Audit the Activity feed (https://cloud.digitalocean.com/account/activity) for unauthorized actions in 24h.

```
bash snitch-digitalocean.sh panic rotate-token
```

## Bucket suddenly public

```
bash snitch-digitalocean.sh panic spaces-lockdown <bucket-name>
```

Sets ACL to private and removes any matching CDN endpoint. Manually re-grant legitimate access afterwards.

## Droplets being attacked

1. Identify the source: top IPs / paths in `/var/log/nginx/access.log`.
2. Add a Cloud Firewall rule:
   ```
   bash snitch-digitalocean.sh panic firewall-block <ip-or-cidr>
   ```
   DO firewalls are allowlist-only; this emits guidance for replacing inbound rules.
3. For L7 DDoS, put **Cloudflare in front** (orange-cloud DNS). DO has no built-in L7 mitigation.
4. Postmortem after.

## Spend doubled overnight

1. `bash snitch-digitalocean.sh state cost` for top recent charges.
2. Check the dashboard's Resources view for unrecognized droplets / DBs / clusters.
3. If unrecognized: revoke the API token (see "Token leaked"), then delete rogue resources via dashboard.

## Postmortem template

```
# Incident: <title>
- When: <ISO datetime range>
- Detected by: <how>
- Impact: <users affected, data exposed, money>
- Root cause: <one sentence>
- Timeline:
  - HH:MM: <event>
- Fix: <what was done>
- Prevention: <changes to prevent recurrence>
```

Use `panic restore` afterwards to reverse recorded panic actions where reversible.
