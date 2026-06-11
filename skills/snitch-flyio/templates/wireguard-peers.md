# WireGuard peers — operator guide

Fly orgs have a private network (6PN) reachable from any machine in the org. To reach it from your laptop, CI, or another cloud, you create a WireGuard peer.

## List peers

```sh
fly wireguard list <org>
```

Each row: name, region, network, peer IP. Surfaced in `bash snitch-flyio.sh state network <org>` digest.

## Add a peer

```sh
fly wireguard create <org> <region> <peer-name>
```

Outputs a WireGuard config file — paste into `wg-quick` / `wg0.conf`. Connect, then internal apps are reachable at `<app>.internal` from your peer.

## Remove a peer (rotate)

```sh
fly wireguard remove <org> <peer-name>
```

## Hardening checklist

- [ ] **One peer per human / service**, not shared. If a laptop is compromised, you revoke that peer alone.
- [ ] **Name peers descriptively**: `alice-laptop`, `gha-deploy`, `bastion-iad`. Surfaces clearly in `wireguard list`.
- [ ] **Pick the right region** for the peer endpoint — closest to where the human / service lives, not the app.
- [ ] **Rotate periodically**: at least quarterly, remove and recreate peers. WireGuard keys don't expire on their own.
- [ ] **CI peers should be ephemeral**: create per-job, remove on completion. Or use `fly tokens create deploy` instead — that doesn't need WireGuard at all.
- [ ] **Off-boarding**: when a team member leaves, immediately `fly wireguard remove <org> <their-peer>`.

## Common patterns

### `psql` to private Postgres from your laptop

```sh
fly wireguard create personal iad alice-laptop
# install the printed wg config, then:
psql "postgres://postgres:PASSWORD@my-db.internal:5432/myapp"
```

### Reach a private app from a non-Fly server

Same as above. Install the WireGuard config on the server, set up `wg-quick up`, and call `<app>.internal` from your code.

## What snitch-flyio surfaces

`bash snitch-flyio.sh state network <org>` (digest):

- `wireguard_summary.total_peers` — count.
- `wireguard_summary.by_region` — distribution.
- `wireguard_summary.peer_names` — names. Eyeball for shared / stale entries.

If you see ten peers and three names look like personal laptops of ex-employees, that's an immediate `fly wireguard remove`.
