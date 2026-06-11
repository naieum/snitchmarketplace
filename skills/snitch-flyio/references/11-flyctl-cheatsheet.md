# 11 — flyctl cheatsheet

The 80% of `flyctl` you'll use. Most accept `--json` for structured output.

## Auth

```sh
fly auth login                           # browser-based
fly auth whoami
fly auth logout
fly tokens create deploy --org <o> --expiry 720h --name "ci-2026q2"
fly tokens list --org <o> --json
fly tokens revoke <id>
```

## Apps

```sh
fly apps list --json
fly apps create <name> --org <o>
fly apps destroy <name>
fly apps suspend <name>                  # stop machines, preserve state
fly apps resume <name>
fly status -a <name> --json
fly config show -a <name> --json         # current fly.toml as JSON
fly config save -a <name>                # write fly.toml from server state
```

## Deploy

```sh
fly launch                               # bootstrap a new app
fly deploy                               # build + deploy (uses fly.toml in cwd)
fly deploy -a <name> --strategy rolling
fly deploy --image <full-tag>            # pre-built image
fly releases -a <name>
fly releases rollback -a <name>
```

## Machines

```sh
fly machines list -a <name> --json
fly machines start|stop|restart <id> -a <name>
fly machines clone <id> --region <r> -a <name>
fly machines destroy <id> -a <name>
fly scale count <n> -a <name>
fly scale memory <mb> -a <name>
fly scale vm <size> -a <name>
fly autoscale show -a <name>             # legacy (Nomad apps only)
```

## Volumes

```sh
fly volumes create <name> --size <gb> --region <r> -a <name>
fly volumes list -a <name> --json
fly volumes update <id> --snapshot-retention 14 --auto-backup -a <name>
fly volumes snapshots list -a <name> -v <vid>
fly volumes snapshots create <vid> -a <name>
fly volumes destroy <id> -a <name>
```

## Postgres

Legacy:

```sh
fly postgres create --name <db> --org <o> --region <r>
fly postgres connect -a <db>             # opens psql
fly postgres attach <db> -a <app>        # creates DATABASE_URL secret
fly postgres detach <db> -a <app>
fly pg revoke -a <db> --user <user>
```

Managed:

```sh
fly mpg list --json
fly mpg create --org <o> --region <r>
fly mpg attach <cluster> -a <app>
```

## Redis (Upstash)

```sh
fly redis create --name <db> --region <r>
fly redis list --json
fly redis status <db>
fly redis destroy <db>
```

## Secrets

```sh
fly secrets set NAME=value [...] -a <app>
fly secrets list -a <app> --json
fly secrets unset NAME -a <app>
fly secrets set --stage NAME=value -a <app>
fly deploy -a <app>                      # apply staged
```

## SSH / Console

```sh
fly ssh console -a <app>
fly ssh console -a <app> -s <id>
fly ssh issue --agent                    # ephemeral SSH cert for laptop
```

## Logs / metrics

```sh
fly logs -a <app>
fly logs -a <app> --json
fly metrics -a <app>                     # opens dashboard
```

## IPs / networking

```sh
fly ips list -a <app> --json
fly ips allocate-v4 -a <app>
fly ips allocate-v6 -a <app>
fly ips release <ip> -a <app>
fly wireguard list <org>
fly wireguard create <org> <region> <name>
fly wireguard remove <org> <name>
```

## Storage (Tigris)

```sh
fly storage create --name <bucket> --org <o>
fly storage list
fly storage destroy <bucket>
```

## Org

```sh
fly orgs list --json
fly orgs show <slug> --json
fly orgs invite <slug> <email>
fly orgs remove <slug> <email>
```

## Audit

No flyctl audit log. Visit `https://fly.io/dashboard/<org>/audit-log`.

## Tip

When automating, always pass `--json` — the human formatter changes between flyctl versions.
