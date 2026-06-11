# Observability and logs

Railway captures stdout/stderr from every deployment and shows it in dashboard or via `railway logs`. Retention depends on plan tier.

## Retention (verify in dashboard)

| Plan | Retention |
|---|---|
| Trial / Hobby | ~7 days |
| Pro | ~30 days |
| Enterprise | custom |

After retention, log lines are gone. **For security audit trails, use a log drain.**

## Log drains (Pro+)

Configure in dashboard → project → Logs → Drain. Targets (subject to change):

- Datadog
- Sentry (HTTP intake)
- Loki / Grafana Cloud
- Honeycomb
- New Relic
- Sumo Logic
- Splunk HEC
- Generic webhook

## Tailing live

```bash
railway logs                       # current service in active env
railway logs --service api
railway logs --deployment <id>
```

## Audit log

Dashboard-only — no GraphQL endpoint to dump. Tracks variable changes, deploys, member additions, token revocations.

## Skill behavior

- `state logs` reports retention by plan tier and surfaces presence of log-drain-shaped env vars.
- `apply logs` recommends drain config on Pro+; gates with `[locked: pro+]` on lower tiers.

## Recommendations

- On Pro+: configure drain to your SIEM. Without one, security incidents that take >7 days to investigate hit a wall.
- Centralize logs across multiple Railway projects to one destination.
- Avoid logging variable values; if your framework stamps env on startup, mask common secret-shaped names.

## Docs

- https://docs.railway.com/reference/logging
