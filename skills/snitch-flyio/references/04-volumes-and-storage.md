# 04 — Volumes and storage

## Volumes (single-region block storage)

NVMe block devices attached to one machine in one region. Not shared. Two machines cannot mount the same volume.

```sh
fly volumes create data --size 10 --region iad -a <app>
fly volumes list -a <app>
fly volumes snapshots list -a <app> -v <volume-id>
fly volumes snapshots create <volume-id> -a <app>
fly volumes update <volume-id> --snapshot-retention 14 -a <app>
fly volumes update <volume-id> --auto-backup -a <app>
```

### Hardening

- [ ] Encryption is on by default since 2023. The skill flags `encrypted: false`.
- [ ] Snapshot retention ≥ 14 days for prod. Defaults are too short.
- [ ] Auto-backup enabled (daily snapshot).
- [ ] No unattached volumes — they bill regardless.
- [ ] Region affinity: app running in `iad+fra` needs a volume per region.

### Multi-region patterns

| Need | Solution |
|---|---|
| Postgres multi-region | Fly Postgres replicas or Managed Postgres. |
| Redis multi-region | Upstash-on-Fly (global) or primary+replica on volumes. |
| Static assets | Tigris (S3-compatible, global). |
| App scratch | Ephemeral machines (`auto_destroy = true`) + Tigris. |

## Tigris (S3-compat global object storage)

Fly's first-party object storage. S3 API.

```sh
fly storage create                 # creates bucket; outputs creds
fly storage list
fly storage destroy <bucket>
```

Endpoint: `https://fly.storage.tigris.dev` (set as `AWS_ENDPOINT_URL_S3`).

```sh
aws s3 ls --endpoint-url=https://fly.storage.tigris.dev
aws s3 sync ./local s3://my-bucket --endpoint-url=https://fly.storage.tigris.dev
```

Credentials in `fly secrets list` after `fly storage create`. Per-bucket. Rotate by destroying access keys via dashboard.

### Migration from S3

```sh
aws s3 sync s3://old-bucket s3://new-bucket-tigris \
  --source-region us-east-1 \
  --endpoint-url=https://fly.storage.tigris.dev
```

Cost: zero egress within Fly. Outbound to non-Fly: standard rates.

## What `state volumes <app>` returns

```json
{
  "volumes_summary": {
    "total": 2,
    "by_region": {"iad": 1, "fra": 1},
    "encrypted_count": 2,
    "unencrypted_count": 0,
    "without_snapshot_retention": 0,
    "unattached": 0,
    "total_size_gb": 30
  }
}
```

`bash snitch-flyio.sh fix volumes <app>` surfaces remediation when retention is short, auto-backup is off, or volumes are unencrypted.

## Common mistakes

| Mistake | Cost |
|---|---|
| Two machines mounting the same volume | Fly refuses; symptom is confusing. |
| No snapshots configured | Permanent data loss on machine corruption. |
| Volume in a region the app doesn't run in | Orphaned billing. |
| Treating volumes like S3 | They're block devices. Use Tigris for objects. |
