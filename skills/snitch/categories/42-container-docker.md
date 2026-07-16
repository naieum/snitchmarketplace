## CATEGORY 42: Container & Docker Security
> Type: posture · Groups: — · CWE: CWE-250

### Detection
- Projects with `Dockerfile`, `docker-compose.yml`, or `.dockerignore`
- Container orchestration configurations
- CI/CD pipelines that build or deploy containers

### What to Search For
- Running as root (no `USER` directive after base image)
- Using `latest` tag instead of pinned versions (e.g., `FROM node:latest`)
- Exposed sensitive ports (`EXPOSE 22`, `EXPOSE 3306`, `EXPOSE 5432`)
- Secrets in build args (`ARG DB_PASSWORD`, `ENV API_KEY=...`)
- Missing health checks (no `HEALTHCHECK` directive)
- Copying entire build context (`COPY . .` without `.dockerignore`)
- Multi-stage build issues (dev dependencies in production stage)
- Privileged container flags in docker-compose (`privileged: true`)
- Insecure or outdated base images
- Missing `--no-cache` on package install commands (stale security patches)
- Using `ADD` instead of `COPY` for local files (ADD auto-extracts archives)

### Actually Vulnerable
- Container running as root with no `USER` directive — full host access if container escapes
- `FROM node:latest` or any unpinned `:latest` tag — non-reproducible, may pull vulnerable images
- `ARG PASSWORD=mysecret` or `ENV API_KEY=sk_live_...` — secrets baked into image layers
- `EXPOSE 22` — SSH exposed from container
- `COPY . .` without `.dockerignore` — copies `.env`, `.git`, `node_modules` into image
- `privileged: true` in docker-compose — container has full host kernel access
- Production stage includes `devDependencies` or test frameworks
- `apt-get install` or `apk add` without `--no-cache` — cached package indexes may include stale/vulnerable versions

### NOT Vulnerable
- `FROM node:20-alpine` or other pinned version tags
- `USER node` or `USER 1001` directive present after installing dependencies
- Multi-stage build with clean production stage (only production deps copied)
- `.dockerignore` excludes `.env`, `.git`, `node_modules`, `*.md`
- Health check defined with `HEALTHCHECK CMD`
- Build args used only for non-sensitive values (e.g., `ARG NODE_ENV=production`)
- `EXPOSE 80` or `EXPOSE 443` for web servers (expected ports)

### Context Check
1. Is there a `USER` directive after the package installation steps?
2. Are base image tags pinned to specific versions or digests?
3. Does `.dockerignore` exist and exclude sensitive files?
4. Are secrets passed via build args or baked into `ENV` directives?
5. Is this a multi-stage build? Does the production stage include only necessary files?
6. Are health checks defined for production containers?

### Evidence Chain
A finding's Evidence block must show:
- The offending directive quoted with file:line (e.g., the `ENV API_KEY=...` line, the `FROM node:latest` line, `privileged: true` in the compose file — or, for omissions, the final stage shown with no `USER` directive present)
- Which image/stage the directive lands in — for multi-stage builds, confirm it is the final/production stage (a root builder stage is not a finding)
- The reachability/impact link: this Dockerfile or compose file is actually built and deployed (referenced in CI workflows, compose services, or deployment configs), not an abandoned variant
- The absent mitigation checked for (no `USER` in final stage, no `.dockerignore` entry excluding `.env`/`.git`, no secret-mount alternative such as BuildKit `--mount=type=secret`)
- For secret-in-layer findings: why the value is sensitive (credential pattern such as `sk_live_...`, password, token) rather than a benign build arg

### Confidence Scoring
- **HIGH**: Unambiguous directive in a production-built image — a real secret baked into `ARG`/`ENV`, `privileged: true` on a deployed service, no `USER` directive anywhere in the final stage, or `COPY . .` with no `.dockerignore` in a repo containing `.env`/`.git`.
- **MEDIUM**: Pattern present but production context is partial — e.g., `:latest` tag or missing `HEALTHCHECK` in a Dockerfile whose deployment target is unclear, a `Dockerfile.dev` variant, or a multi-stage build where the final runtime stage is ambiguous.
- **LOW**: Heuristic only — base image "outdated" without version evidence, `EXPOSE` of a sensitive port with no proof the service listens on it, or a build arg that might carry a secret injected at build time from CI. Tag `needs human verification`.

### Files to Check
- `Dockerfile*`, `docker-compose*.yml`, `docker-compose*.yaml`
- `.dockerignore`
- `.github/workflows/*.yml` (for container build steps)
- `*.Dockerfile`, `containers/**`
