# 14 — Cost and budgets

Fly bills usage-based. Cost drivers, in rough order of impact:

| Driver | Range |
|---|---|
| GPU machines | $0.30 - $3+/hour each. |
| CPU machines | $0.005 - $0.10/hour, by VM size. |
| Volumes | $0.15/GB-month. |
| Bandwidth out | Free within Fly; standard rates outbound. |

Tigris and Postgres are billed separately.

## Where to look

| Source | Use |
|---|---|
| `https://fly.io/dashboard/<org>/billing` | Authoritative; current month by app + line item. |
| `bash snitch-flyio.sh state cost <org>` | Derived shape (machine count, volume size, GPU presence) — not numbers. |

## Common surprise costs

### Forgotten GPU machines

```sh
fly machines list -a <app> --json | jq '.[] | select(.config.guest.gpu_kind != null)'
```

A100 / H100 bill by the second when running. With `auto_stop_machines = "off"`, they run 24/7. Audit: every GPU machine has a clear job; if unclear, stop it.

### Multiple regions you didn't ask for

`fly deploy --regions a,b,c` makes regions permanent. Re-deploy without doesn't auto-remove machines:

```sh
fly machines list -a <app> --json | jq '.[] | select(.region == "old-region") | .id'
fly machines destroy <id> -a <app>
```

### Idle machines without auto_stop

```toml
[http_service]
  auto_stop_machines = "stop"   # or "suspend" (faster wake)
  auto_start_machines = true
  min_machines_running = 0
```

Without these, you pay 24/7 at zero traffic.

### Orphan volumes

```sh
fly volumes list -a <app> --json | jq '.[] | select(.attached_machine_id == null)'
```

Unattached volumes still bill. Destroy if unintentional.

### Large logs

If you ship to Datadog/Logtail at high volume, log bill exceeds Fly bill at small scale. Sample debug logs.

## Budgets

Fly has no hard caps. Closest you have:

| Mechanism | |
|---|---|
| Email alerts at thresholds | Set in dashboard billing page. |
| Manual review weekly | |
| `bash snitch-flyio.sh state cost <org>` cron | Derived shape only. |

For hard caps, write an external monitor (e.g., Lambda reading the Fly billing API).

## Cost cliffs

| Threshold | Effect |
|---|---|
| Multi-region prod | Volumes per region; bandwidth between free within Fly. |
| First GPU machine | Bill jumps; use `auto_stop_machines = "stop"`. |
| Postgres replica in 2nd region | Doubled DB cost + cross-region bandwidth (free within Fly). |
| Tigris bucket > 100GB | Storage cost noticeable; egress to non-Fly metered. |
| 24/7 worker process_group with idle time | Stop when no jobs queue. |

Authoritative: https://fly.io/pricing.

## What `state cost <org>` returns

```json
{
  "totals": { "machines": 12, "gpu_machines": 1, "volume_gb": 200 },
  "per_app": [
    {"app":"web","machines":4,"gpu_machines":0,"volumes":0,"volume_gb":0},
    {"app":"worker","machines":2,"gpu_machines":0,"volumes":0,"volume_gb":0},
    {"app":"db","machines":2,"gpu_machines":0,"volumes":2,"volume_gb":100},
    {"app":"ml-inf","machines":1,"gpu_machines":1,"volumes":1,"volume_gb":100}
  ]
}
```

`gpu_machines: 1` is your audit target — confirm intentional.
