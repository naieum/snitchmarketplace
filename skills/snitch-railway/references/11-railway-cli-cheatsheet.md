# Railway CLI cheatsheet

Install: `brew install railway` (macOS) or `npm i -g @railway/cli`.

## Auth

```bash
railway login        # browser OAuth
railway whoami
railway logout
```

## Project navigation

```bash
railway link                       # link cwd to a project (interactive)
railway link --project <id>
railway status                     # current project + env + service
railway status --json
railway environment <name>
railway service <name>
```

## Variables

```bash
railway variables                                          # current env
railway variables --service <svc>
railway variables --set NAME=value                         # set service var
railway variables --service <svc> --set NAME=value
railway variables --shared --set NAME=value                # project-level shared
railway variables --remove NAME
```

## Deploy

```bash
railway up
railway up --service <svc>
railway up --detach              # don't follow logs
railway redeploy                 # redeploy last image
railway down --service <svc>
```

## Logs

```bash
railway logs                       # active service, follow
railway logs --service <svc>
railway logs --deployment <id>
```

## Run remotely

```bash
railway connect                    # active service shell or db
railway connect <db-service-name>  # opens psql/mysql/redis-cli
railway run <command>              # run with Railway env injected locally
railway run -- npm run db:migrate
```

## Tokens

```bash
railway login --browserless        # device-code flow; useful in SSH
RAILWAY_TOKEN=... railway up --service api
```

## Domains

```bash
railway domain                          # add Railway-managed domain
railway domain <custom.example.com>
```

## Volumes

CLI surface limited; use dashboard for volume create/resize.

## Useful env vars

| Variable | Purpose |
|---|---|
| `RAILWAY_TOKEN` | project-scoped; auto-used by CLI in CI |
| `RAILWAY_API_TOKEN` | account-scoped (skill prefers for state queries) |
| `RAILWAY_PROJECT_ID` | overrides linked project |
| `RAILWAY_ENVIRONMENT_ID` | overrides linked environment |

## Docs

- https://docs.railway.com/guides/cli
