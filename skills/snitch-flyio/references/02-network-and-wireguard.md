# 02 — Network and WireGuard (6PN)

Network model:

| Layer | Purpose |
|---|---|
| 6PN (IPv6 Private Network) | Per-org private IPv6. Apps reach each other at `<app>.internal`. |
| Public IPs | Optional. v4 ($2/mo), v6 (free). Per-app. |
| WireGuard | Joins non-Fly hosts (laptops, CI, other clouds) to 6PN. |
| Anycast | Every public IP is anycast — request hits nearest edge, routes to nearest healthy machine. |

## Inter-app calls

Inside the same org:

```
GET http://my-api.internal:8080/health         # any running machine
GET http://my-api.iad.internal:8080/health     # nearest in iad
GET http://<machine-id>.vm.my-api.internal     # specific machine
```

Direct machine-to-machine over 6PN. Not TLS-terminated — don't use `https://` on `<app>.internal`.

## Public IPs

```sh
fly ips list -a <app>
fly ips allocate-v4 -a <app>         # paid; consider shared-v4 instead
fly ips allocate-v6 -a <app>         # free
fly ips release <ip> -a <app>
```

Most public-facing apps need only v6 + Fly's shared-v4 fronting.

## Hardening

- [ ] Internal-only services (Redis, internal API) have NO public IP.
- [ ] Public apps set `force_https = true`.
- [ ] Cross-app calls use `<app>.internal`, not the public hostname.
- [ ] WireGuard peers are per-human, not shared (see `templates/wireguard-peers.md`).

## What `state network <org>` returns

```json
{
  "wireguard_summary": {
    "total_peers": 4,
    "by_region": {"iad": 2, "fra": 1, "syd": 1},
    "peer_names": ["alice-laptop", "bob-laptop", "ci-deploy", "bastion-fra"]
  }
}
```

Look for: shared peer names, ex-employee peers, unexplained peers in odd regions.

## Common mistakes

| Mistake | Cost |
|---|---|
| Hardcoding `<app>.fly.dev` for inter-service calls | Burns public bandwidth, goes through proxy. |
| Allocating dedicated v4 when shared-v4 works | Wasted $2/mo. |
| Stale WireGuard peers after contractor leaves | Standing access. |
| No `force_https = true` on public app | Clients downgrade to HTTP. |
