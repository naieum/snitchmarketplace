# Database add-ons

Railway's managed-DB story is "deploy a containerized DB image with a volume" — close to managed but **without** automatic backups, point-in-time recovery, or read replicas.

## Available add-ons

| Add-on | Image lineage | Notes |
|---|---|---|
| Postgres | `ghcr.io/railwayapp-templates/postgres-ssl:<ver>` | SSL terminator + Postgres. Most common. |
| MySQL | `ghcr.io/railwayapp-templates/mysql:<ver>` | OK for prototypes. |
| Redis | `ghcr.io/railwayapp-templates/redis:<ver>` | RDB persistence to volume. |
| MongoDB | `bitnami/mongodb` or community template | For production prefer Atlas. |

## Connection strings

Cross-service references resolve at deploy time and are not visible in the consumer's Variables list:

```
DATABASE_URL=${{ Postgres.DATABASE_URL }}
```

## Versioning and EOL

`state databases` digest classifies versions:

| Status | Meaning |
|---|---|
| `supported` | current major |
| `deprecated` | patches winding down |
| `eol` | no patches issued |
| `unknown` | image not parseable |

`fix databases` emits eol/deprecated as `FAIL`/`WARN`.

| Engine | Supported | Deprecated | EOL |
|---|---|---|---|
| Postgres | 17/16/15/14 | 13 | ≤12 |
| MySQL | 8 | — | 5.x |
| Redis | 7 | 6 | — |
| MongoDB | 7/6 | ≤5 | — |

## Backups

Railway has no managed snapshot product. The skill emits a GitHub Actions workflow that runs `pg_dump` on cron and ships to S3.

For Postgres specifically:
- Logical: `pg_dump` daily, full + WAL if RPO is tight.
- Replication: Neon / RDS standby via logical replication. Railway-side DB stays warm cache; durability lives elsewhere.

## Maintenance windows

Railway does not announce maintenance; restarts are deploy-driven. Plan for:
- Second replica receiving traffic (stateless services only).
- Read traffic from a follower (only viable with logical replication).

## Docs

- https://docs.railway.com/guides/databases
- https://docs.railway.com/reference/volumes
