## CATEGORY 42: Container & Docker Security
> Type: posture · Groups: — · CWE: CWE-250

### Detection
- Projects with `Dockerfile`, `docker-compose.yml`, or `.dockerignore`
- Container orchestration configurations
- CI/CD pipelines that build or deploy containers

### What to Search For
- Running as root (no `USER` directive after base image)
- Using `latest` tag instead of pinned versions (e.g., `FROM node:latest`)
- **Published** ports on sensitive services — a compose `ports:` mapping, a `-p` run argument, or `network_mode: host`. **Not `EXPOSE`.**
- Secrets in build args (`ARG DB_PASSWORD`, `ENV API_KEY=...`)
- Missing health checks (no `HEALTHCHECK` directive)
- Copying entire build context (`COPY . .` without `.dockerignore`)
- Multi-stage build issues (dev dependencies in production stage)
- Privileged container flags in docker-compose (`privileged: true`)
- Insecure or outdated base images
- Package-manager cache handling, **per manager — the flags are not interchangeable. Match the manager to the base image's distro before rating; `apk` in a Debian image is a build break, not a finding**:
  - `apk add` without `--no-cache` (Alpine)
  - `apt-get` split across separate `RUN` instructions, or without `rm -rf /var/lib/apt/lists/*` (Debian/Ubuntu). **`apt-get` has no `--no-cache` flag** — passing one is a build error, so never recommend it
- Using `ADD` instead of `COPY` for local files (ADD auto-extracts archives)

**HEALTHCHECK is an availability concern, not a security finding.** It appears in the search list
and the context checks; its absence is informational at most, and should not be reported as a
vulnerability. Noted here so the question has an answer rather than being asked twice and resolved
nowhere.

### Actually Vulnerable
- Container running as root with no `USER` directive — full host access if container escapes
- `FROM node:latest` or any unpinned `:latest` tag — non-reproducible, may pull vulnerable images
- `ARG PASSWORD=mysecret` or `ENV API_KEY=sk_live_...` — secrets baked into image layers
- A compose `ports:` entry publishing a database or admin port to every interface — `"5432:5432"` binds `0.0.0.0`, `"127.0.0.1:5432:5432"` does not. On Linux this also bypasses host firewall rules: Docker's published ports insert into the `DOCKER` iptables chain ahead of UFW/firewalld.
- **`EXPOSE` is documentation metadata and publishes nothing.** It sets `Config.ExposedPorts`, which documents intent and marks the port for `docker run -P` (capital P). It opens no port and binds no interface — a container with `EXPOSE 22` and a running sshd is reachable from nowhere until something publishes it. "SSH exposed from container" off an `EXPOSE` line is a factually wrong finding. The deciding question is never whether a service listens; it is whether a port is **published**
- `COPY . .` without `.dockerignore` — copies `.env`, `.git`, `node_modules` into image
- **`/var/run/docker.sock` bind-mounted into a container** — write access to the daemon socket is root-equivalent on the host: anything in the container can launch a new container mounting `/` and read or modify any host file. As severe as `privileged: true` and entirely independent of it; both frequently appear together
- **Remote installer piped to a shell at build time** — `RUN curl … | sh`, `wget … | sh`. No pinned version, no checksum, no signature, executing as root, and whatever that host serves on the day of the rebuild becomes part of the image (CWE-494)
- **Runtime posture in compose** — absent `cap_drop: [ALL]`, `read_only: true`, `security_opt: [no-new-privileges:true]`, a non-root `user:`, and resource limits. The build can be flawless and the runtime still unconstrained
- `privileged: true` in docker-compose — container has full host kernel access
- Production stage includes `devDependencies` or test frameworks
- `apk add` without `--no-cache` — the fetched index is committed into the image layer. The concern is **image size and layer hygiene**, not that a cache contains vulnerable packages; a cache does not introduce them. (Stock `alpine` ships no index at all, so the first `apk add` fetches a fresh one regardless.)
- `apt-get update` and `apt-get install` in **separate** `RUN` instructions — layer caching then serves a months-old index on rebuild. That is the real staleness problem and it is a different rule from cache flags. `update && install --no-install-recommends && rm -rf /var/lib/apt/lists/*` chained in one `RUN` is correct and must not be flagged

### NOT Vulnerable
- `FROM node:20-alpine` or other pinned version tags
- `USER node` or `USER 1001` directive present after installing dependencies
- Multi-stage build with clean production stage (only production deps copied)
- `.dockerignore` excludes `.env`, `.git`, `node_modules`, `*.md`
- Health check defined with `HEALTHCHECK CMD`
- Build args used only for non-sensitive values (e.g., `ARG NODE_ENV=production`)
- `EXPOSE` of any port, whatever the number — inert metadata. Also a Pass: a `ports:` mapping bound to `127.0.0.1`

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
- Which image/stage the directive lands in — for multi-stage builds, confirm it is the final/production stage. **This gates every Dockerfile finding, not only `USER`.** A root builder stage, a broad `COPY . .` in a builder, or a build-only tool installed in a discarded stage are all Passes; only what the final stage carries reaches the runtime. Where a finding is confined to a builder layer, say so and reduce severity rather than dropping it — build caches and pushed intermediate stages are a real if narrower exposure
- The reachability/impact link: this Dockerfile or compose file is actually built and deployed (referenced in CI workflows, compose services, or deployment configs), not an abandoned variant
- The absent mitigation checked for (no `USER` in final stage, no `.dockerignore` entry excluding `.env`/`.git`, no secret-mount alternative such as BuildKit `--mount=type=secret`)
- For secret-in-layer findings: why the value is sensitive (credential pattern such as `sk_live_...`, password, token) rather than a benign build arg

### Confidence Scoring
- **HIGH**: Unambiguous directive in a production-built image — a real secret baked into `ARG`/`ENV`, `privileged: true` on a deployed service, no `USER` directive anywhere in the final stage, or `COPY . .` with no `.dockerignore` in a repo containing `.env`/`.git`.
- **MEDIUM**: Pattern present but production context is partial — e.g., `:latest` tag or missing `HEALTHCHECK` in a Dockerfile whose deployment target is unclear, a `Dockerfile.dev` variant, or a multi-stage build where the final runtime stage is ambiguous.
- **LOW**: Heuristic only — base image "outdated" without version evidence, or a build arg that might carry a secret injected at build time from CI. Tag `needs human verification`. (`EXPOSE` is not a heuristic finding at any confidence — it is not a finding at all.)

### Files to Check
- `Dockerfile*`, `**/compose.yaml`, `**/compose.yml`, `docker-compose*.yml`, `docker-compose*.yaml`, `.dockerignore`
  **`compose.yaml` is the Compose Spec canonical default** — what `docker init` generates and what most repositories written in the last few years contain. A glob list carrying only `docker-compose*` opens none of them, silently dropping every runtime finding: published ports, `privileged`, socket mounts, capabilities.
- `.dockerignore`
- `.github/workflows/*.yml` (for container build steps)
- `*.Dockerfile`, `containers/**`
