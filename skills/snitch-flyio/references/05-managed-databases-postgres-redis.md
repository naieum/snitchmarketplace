# 05 — Managed databases (Postgres, Redis)

## Postgres — two products

Pick one and stick.

### Legacy Fly Postgres (you operate)

A regular Fly app running stolon-flavored Postgres. Visible in `fly apps list`. SSH-able. You own HA, backups, monitoring.

```sh
fly postgres create --name my-db --region iad --vm-size shared-cpu-1x --volume-size 10
fly postgres list
fly postgres connect -a my-db                    # opens psql
fly postgres attach my-db -a <app>               # creates DATABASE_URL secret
fly postgres detach my-db -a <app>
fly pg revoke -a my-db --user <user>             # rotate user password
```

Hardening:

- [ ] At least 2 machines for HA. `fly machines clone <id> --region <r2>` adds a replica.
- [ ] Snapshot retention ≥ 14 days on the data volume.
- [ ] Rotate `postgres` superuser password quarterly via `fly pg revoke`. Re-attach apps after.
- [ ] App-specific users, not the superuser. `fly pg attach` creates a per-app user.
- [ ] Pin a major version. Watch EOL dates.

### Managed Postgres (Fly operates)

Cluster, backups, PITR, version upgrades all handled. Connection string only — no Fly app, no SSH.

```sh
fly mpg list
fly mpg create
fly mpg attach <cluster-id> -a <app>
```

Hardening:

- [ ] PITR window ≥ 7 days (default).
- [ ] Cross-region read replica for prod (paid feature, standard for prod).
- [ ] Connection limit sized to your app's pool. Watch for `too many connections`.

## Redis (Upstash-on-Fly)

```sh
fly redis create --name cache --region iad --plan free
fly redis list
fly redis status <db>
```

Returns two URLs:

| URL | Reachability | Use |
|---|---|---|
| `private_url` | Fly orgs only | Preferred. |
| `public_url` | Public internet | Avoid. |

Hardening:

- [ ] Use `private_url` (set as fly secret).
- [ ] TLS mandatory — URL must start with `rediss://`.
- [ ] Eviction policy: `allkeys-lru` for cache; none for sessions.
- [ ] Same region as app — cross-region adds 50-200ms.
- [ ] Don't self-run Redis without reason — Upstash-on-Fly handles HA + backups.

## What `state postgres` and `state redis` return

`state postgres`:

```json
{
  "legacy_summary": { "total": 2, "names": [...], "per_cluster_machines": {...} },
  "managed_summary": { "total": 1, "by_region": {...}, "by_plan": {...} },
  "legacy_status": [...]
}
```

`state redis`:

```json
{
  "redis_summary": {
    "total": 1,
    "by_region": {"iad": 1},
    "by_plan": {"free": 1},
    "with_public_url": 0,
    "without_eviction": 1
  }
}
```

## Common mistakes

| Mistake | Cost |
|---|---|
| Legacy `postgres` superuser as app's `DATABASE_URL` | No least-privilege; blast radius is the whole DB. |
| Single-machine Fly Postgres in prod | No HA; one Firecracker hiccup is data loss until restore. |
| Redis at `public_url` from a Fly app | Extra latency + exposure. |
| Cross-region Redis for cache | Defeats the latency win. |
| Forgetting `fly pg revoke` on offboarding | Standing access. |
