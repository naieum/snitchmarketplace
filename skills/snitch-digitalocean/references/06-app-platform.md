# App Platform

PaaS for web services, workers, jobs, and static sites from Git or Docker. Spec at `app.yaml` or `.do/app.yaml`.

```yaml
name: my-app
region: nyc
services:
  - name: web
    source_dir: /
    build_command: npm run build
    run_command: npm start
    health_check:
      http_path: /healthz
    instance_size_slug: basic-xs
    instance_count: 2
    envs:
      - key: DATABASE_URL
        scope: RUN_AND_BUILD_TIME
        type: SECRET
        value: "..."
```

Full hardened template: `templates/app-platform-hardened.yaml.tpl`.

## Hardening checklist

| Item | Detail |
|---|---|
| Secret envs | `type: SECRET`, not default `GENERAL`. Skill scans `*SECRET*`, `*TOKEN*`, `*PASSWORD*`, `*API_KEY*`, `*PRIVATE_KEY*`; FAIL if plain. |
| Health checks | Every service has `health_check` with `http_path`. |
| `instance_count >= 2` | No SPOF on a single instance in prod. |
| Region | Set explicitly. |
| Domains | Declared in spec, not added via UI. |
| Worker components | For queue consumers / background jobs. |
| Job components | For DB migrations on deploy. |

## Limits — App Platform does NOT support

| Gap | Workaround |
|---|---|
| SSH to running pod | Use logs + ephemeral debug job |
| Custom CPU/RAM beyond `instance_size_slug` | Move to Droplet / DOKS |
| Persistent volumes | Use Managed DB / Spaces / Redis |
| Long CPU jobs >15min | Move to Droplet |

## Buildpack vs Dockerfile

| Choice | When |
|---|---|
| Buildpack | Easiest; auto-detected; platform owns runtime |
| Dockerfile | Native modules; custom system packages; full control |

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | Plain envs with secret-shaped names |
| 🟡 WARN | Service without `health_check` |
| 🟡 WARN | `instance_count: 1` in prod |
| 🟡 WARN | App-code redirect targets `http://` (App Platform terminates TLS at edge) |
