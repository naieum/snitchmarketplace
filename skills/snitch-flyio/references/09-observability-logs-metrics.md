# 09 — Observability: logs, metrics, traces

## Logs

```sh
fly logs -a <app>                          # tail current
fly logs -a <app> --region iad
fly logs -a <app> -i <machine-id>
fly logs -a <app> --json                   # structured
```

Retention: ~3-7 days in Fly UI. Ship to external store for longer.

### Log shipping

| Pattern | Use |
|---|---|
| `fly-log-shipper` (Vector) | A Fly app reading NATS event stream. Ships to Loki/Datadog/Logtail/Papertrail. `fly launch --from https://github.com/superfly/fly-log-shipper`. |
| OpenTelemetry from your app | Direct OTLP export. Set `OTEL_EXPORTER_OTLP_ENDPOINT` as a fly secret. |
| stdout JSON + sidecar | Log structured JSON; sidecar parses. |

For SOC 2: log-shipper to immutable storage (S3 with object lock).

## Metrics

Per-machine Prometheus on `:9091/metrics`:

| Metric | Source |
|---|---|
| `fly_instance_*` | CPU, memory, disk. |
| `fly_app_concurrency` | Connection count. |
| HTTP service metrics | Fly proxy. |

`fly metrics` opens dashboard. For Grafana/Datadog: `fly tokens create readonly --org <org>` and point at Fly's Prometheus.

## Tracing

Fly doesn't run a tracing collector. Patterns:

| Option | Setup |
|---|---|
| Honeycomb / Datadog / Sentry | Set API key as fly secret; instrument with their SDK. |
| Self-hosted Jaeger / Tempo | Run as Fly app; app sends OTLP to `jaeger.internal:4317`. |

## Alerts

Built-in alerting is limited. Use external:

| Tool | Use |
|---|---|
| Better Stack / UptimeRobot / Healthchecks.io | HTTP probe on `/health`. |
| PagerDuty / Opsgenie / Slack | Driven from logs/metrics. |

## Verify

- [ ] `/health` returns 200 only when serving traffic.
- [ ] Logs shipped with > 30 days retention for prod.
- [ ] Critical errors page someone.
- [ ] Concurrency / connection metrics dashboards exist.
- [ ] Bills / spend alerts wired (separate from app health).

## Common mistakes

| Mistake | Cost |
|---|---|
| Relying on `fly logs` for archaeology | Only ~3-7 days retained. |
| `console.log(req)` ships PII / secrets | Sanitize. |
| No `/health` endpoint | Fly can't tell broken from working. |
| Health 200 even when DB is down | Broken app stays in rotation. |
| Metrics scraped but no alerts | Silent failures. |
