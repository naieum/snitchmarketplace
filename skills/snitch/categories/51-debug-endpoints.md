## CATEGORY 51: Debug Endpoints in Production
> Type: posture · Groups: — · CWE: CWE-489

### Detection
- Debug, profiling, or introspection routes exposed without authentication
- Environment configuration set to development mode in production
- Verbose error pages with stack traces served to end users
- Source maps (.map files) served in production builds
- Admin/debug tooling enabled in production configuration

### What to Search For

**Node.js/TypeScript (Express, Next.js, Fastify):**
- Routes matching `/debug`, `/__debug__`, `/test`, `/dev`
- `NODE_ENV` not set to `production` or missing environment check
- `app.use(errorHandler)` that returns stack traces (e.g., `err.stack` in response body)
- Source maps generated and served in production (`devtool: 'source-map'` in webpack prod config)
- A GraphQL IDE route (Playground, GraphiQL, Apollo Sandbox) served without an environment check — as a *route exposure*. The GraphQL configuration itself (introspection, depth, complexity, field auth) is Category 57; report it there
- Next.js `/_next/data` or debug pages left in `pages/` or `app/` directories
- Express `morgan('dev')` or verbose logging middleware in production

**Python (Django, Flask, FastAPI):**
- Django `DEBUG = True` in production settings
- Django `django-debug-toolbar` installed and enabled in production
- Flask `app.run(debug=True)` or `FLASK_DEBUG=1` in production
- FastAPI with `docs_url` and `redoc_url` enabled in production (Swagger UI)
- Django `/admin/` accessible without strong authentication
- `ALLOWED_HOSTS = ['*']` in Django production settings

**Java (Spring Boot):**
- Spring Boot Actuator endpoints exposed: `/actuator`, `/actuator/env`, `/actuator/beans`, `/actuator/heapdump`, `/actuator/configprops`
- `management.endpoints.web.exposure.include=*` in `application.properties`
- Missing security on Actuator endpoints (no `management.endpoints.web.exposure.exclude`)
- Swagger UI enabled in production: `springdoc.swagger-ui.enabled=true`
- `server.error.include-stacktrace=always` in properties

**Go:**
- `net/http/pprof` imported and routes registered: `/debug/pprof/`, `/debug/pprof/heap`, `/debug/pprof/goroutine`
- `/debug/vars` endpoint from `expvar` package exposed without auth
- Gin debug mode: `gin.SetMode(gin.DebugMode)` or missing `gin.SetMode(gin.ReleaseMode)` in production
- Custom `/health` or `/status` endpoints returning internal system details (memory, goroutine count, versions)

**Ruby (Rails):**
- `config.consider_all_requests_local = true` in production environment
- `better_errors` or `web-console` gem in production Gemfile group
- Rails `/rails/info/routes` or `/rails/info/properties` accessible in production
- `config.action_dispatch.show_exceptions = false` in production
- Pry or byebug breakpoints left in production code

**General (All Languages):**
- `/phpinfo`, `/info.php` endpoints exposing PHP configuration
- `/elmah.axd` exposing .NET error logs
- `/trace` or `/httptrace` endpoints
- `/metrics` (Prometheus) exposed without authentication
- `/health` endpoints returning database connection strings, internal IPs, or version details
- `.map` files (source maps) accessible via HTTP in production
- `/swagger-ui`, `/api-docs`, `/openapi.json` without authentication

### Actually Vulnerable
- `/debug/pprof/` accessible in production Go application -- exposes heap dumps, goroutine stacks, CPU profiles
- Django `DEBUG = True` in production -- shows full stack traces, settings, and SQL queries to end users
- Spring Boot `/actuator/env` exposed without auth -- reveals all environment variables including secrets
- Spring Boot `/actuator/heapdump` exposed -- allows downloading JVM heap containing in-memory secrets
- Express error handler returning `err.stack` in JSON response body in production
- Flask `app.run(debug=True)` in production -- enables interactive debugger with code execution
- Source maps deployed to production CDN -- allows reconstructing original source code
- `/metrics` endpoint without auth exposing internal service names, response times, and error rates
- Rails with `web-console` gem in production -- allows executing arbitrary Ruby code from browser
- Swagger UI enabled in production without auth -- documents all API endpoints and parameters

### NOT Vulnerable
- Debug endpoints behind VPN or internal network only (not internet-facing)
- `/health` returning only `{ "status": "ok" }` with no sensitive details
- `/metrics` behind authentication or restricted to internal load balancer
- `NODE_ENV=production` properly set with error handler returning generic messages
- Spring Boot Actuator with only `/actuator/health` exposed and secured
- Source maps uploaded to error tracking service (Sentry) but not served publicly
- Swagger UI disabled in production via environment variable check
- Debug routes registered only when `process.env.NODE_ENV === 'development'`
- `/health` and `/ready` endpoints with no sensitive data (standard for Kubernetes liveness/readiness probes)
- `/metrics` behind authentication or accessible only from internal network (Prometheus scraping from within VPC)
- Debug endpoints gated by environment check (`NODE_ENV`, `RAILS_ENV`, `FLASK_DEBUG`, `ASPNETCORE_ENVIRONMENT`) and confirmed disabled in production
- Swagger/OpenAPI docs intentionally public for documented public APIs (API-as-a-product)
- No GraphQL IDE route reachable in production. On Apollo Server the hosted playground stopped being a production default well before the current major, so its absence is the framework's own behavior rather than a configuration you can credit — see Category 57 for the version-specific reading
- Internal admin tools accessible only behind VPN or corporate SSO, not on the public internet

### Context Check
1. Is the application running in production mode (NODE_ENV, FLASK_DEBUG, Spring profiles)?
2. Are debug/profiling endpoints restricted to internal networks or behind authentication?
3. Do error responses include stack traces, internal paths, or configuration details?
4. Are source maps served to end users or only uploaded to error tracking services?
5. Are Spring Boot Actuator endpoints properly secured?
6. Does the `/health` endpoint expose sensitive internal information?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the debug endpoint or feature is registered without an environment check (not gated to `NODE_ENV === 'development'` or equivalent)
2. [ ] Verified the endpoint is not behind authentication, VPN, or internal network restriction
3. [ ] Checked that error responses include stack traces or internal details (not just generic error messages)
4. [ ] For source maps, confirmed `.map` files are served publicly (not just generated for error tracking upload)
5. [ ] For Spring Actuator, confirmed which endpoints are exposed and whether they are secured
6. [ ] Distinguished between intentionally public endpoints (`/health`, public API docs) and accidentally exposed debug features

### Confidence Scoring
- **HIGH**: Debug endpoint (pprof, actuator/env, actuator/heapdump) is registered unconditionally with no environment check or authentication. Or `DEBUG = True` / `debug=True` is set in what appears to be a production configuration file.
- **MEDIUM**: Debug features are present but gated by an environment variable check that may or may not be correctly set in production (e.g., `if (!process.env.PROD)` which defaults to debug if the var is missing).
- **LOW**: Debug endpoint or tool exists but is likely only used in development (e.g., in a dev-only config file, or behind a VPN that is not visible in application code).
- **SKIP**: All debug routes are explicitly gated to non-production environments. `/health` returns only status with no sensitive data. Source maps are uploaded to Sentry but not served publicly. GraphQL configuration is out of scope here — Category 57 owns it.

### Files to Check
- `**/app.ts`, `**/app.js`, `**/server.ts`, `**/server.js`, `**/main.go`
- `**/routes/**`, `**/router*`
- `**/settings.py`, `**/config.py`, `**/config/environments/production.rb`
- `**/application.properties`, `**/application.yml`, `**/application-prod.yml`
- `**/webpack.config.*`, `**/next.config.*`, `**/vite.config.*` (source map settings)
- `**/error*handler*`, `**/error*middleware*`
- `Gemfile`, `requirements.txt`, `pom.xml` (debug dependencies in production)

### Shadow / Undocumented Endpoints

#### What to Search For
- Routes defined in source code but not referenced in API documentation or OpenAPI spec
- Health/status endpoints exposing internal details: dependency versions, database connection status, memory usage, uptime
- Admin routes accessible without IP restriction or VPN requirement
- Catch-all middleware that serves content for undefined routes instead of returning 404
- Commented-out routes that were re-enabled without review

#### Actually Vulnerable
- `/health` endpoint returns `{ db: "connected", redis: "connected", version: "2.1.3", memory: "512MB" }` — internal system info
- Admin panel at `/admin` with auth but no IP restriction — accessible from public internet
- `app.use('*', serveApp)` catches all paths including undocumented API routes

#### NOT Vulnerable
- `/health` returns only `{ status: "ok" }` — no internal details
- Admin routes behind VPN or IP allowlist
- 404 handler for undefined routes: `app.use((req, res) => res.status(404).json({ error: "Not found" }))`
