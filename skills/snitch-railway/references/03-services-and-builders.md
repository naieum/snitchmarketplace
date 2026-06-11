# Services and builders

A Railway project contains services. Each service has one or more deployments per environment.

## Builders

| Builder | When | Trade-offs |
|---|---|---|
| Nixpacks (default) | `railway up` from repo with no `Dockerfile`. Detects language, installs runtime, runs standard start command. | Easiest path. Slower iteration than custom Dockerfiles for complex builds. |
| Dockerfile | Repo has `Dockerfile`. Railway builds from it. | Full control. Use when Nixpacks misdetects or you need specific base images. |
| Image | Service points at a registry image (`ghcr.io/...`, `docker.io/...`). | Fastest deploy — no build. Use for DB add-ons or pre-built containers. |

## Health checks

Configure in `railway.json` or dashboard:

```json
{
  "deploy": {
    "healthcheckPath": "/health",
    "healthcheckTimeout": 30
  }
}
```

Railway only routes traffic after health check passes. Without one, a broken deploy still receives traffic.

## Replicas

Set `numReplicas` ≥ 2 for production HTTP services. Single replica means deploy briefly drops connections, and a crash takes the service offline until restart.

Replicas all run in the same region. For multi-region, deploy the same service to multiple projects (Railway is single-region).

## Restart policy

```json
{
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

Default is `ALWAYS`. Use `ON_FAILURE` to prevent thrash for crashloops.

## Sleep mode

`sleepApplication: true` on hobby tier sleeps the service after inactivity. Cold start takes seconds. Don't enable on production.

## Recommendations

- Always set `healthcheckPath` for HTTP services.
- `numReplicas: 2` minimum on production.
- Keep build logs out of source control if they leak secrets — Railway redacts known patterns but is not exhaustive.
- Pin runtime versions in `nixpacks.toml` for reproducibility.

## Docs

- https://docs.railway.com/reference/healthchecks
- https://docs.railway.com/reference/scaling
- https://docs.railway.com/guides/dockerfiles
- https://docs.railway.com/guides/build-configuration
