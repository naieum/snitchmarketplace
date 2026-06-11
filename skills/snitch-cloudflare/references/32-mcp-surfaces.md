# 32 — MCP-orchestration audit surfaces

Five audit lenses have **no usable curl path** (CASB, DEX, Workers Builds) or
**strongly prefer the MCP** (Browser Rendering, Observability). The skill's CLI
emits only a delegation pointer (`cfsec.audit-delegated`); the agent runs the MCP
recipe below and grades the findings. Each lens is gated by a `CFSEC_MCP_<LENS>`
env flag — when unset, the pointer carries `locked:"mcp-absent"` and the agent
renders a ⚪️ N/A row with the install hint (never silently dropped).

How the agent uses this file: `audit <lens>` (or `audit all`) returns a pointer
whose `recipe` field links here. Read the matching section, run the MCP tools in
order, gate on the first call, and map results to findings tagged `area=<lens>`.

---

## casb (Enterprise Zero Trust — AUTO-GATE) {#casb}

SaaS security posture (Google Workspace / Microsoft 365 / GitHub / etc.) from the
Cloudflare CASB graph. No public REST surface the skill uses → MCP-only.

Tools (`mcp__cloudflare-casb__*`), in order:
1. `integrations_list` — if empty or forbidden ⇒ **locked** ("Enterprise CASB / not configured"); stop, render N/A.
2. `asset_categories_list` (and `asset_categories_by_type` / `_by_vendor`) — understand what's assessable.
3. `assets_list` / `assets_search` — pull findings, especially high-risk categories.
4. `asset_by_id` — detail on a specific flagged asset.

Finding taxonomy (tag `area=casb`):
- Publicly shared SaaS files / "anyone with the link" → **FAIL**.
- Third-party OAuth grants with broad scopes → **WARN**.
- Admin accounts without MFA (as reported by the integration) → **FAIL**.
- Stale / disconnected integrations → **INFO** (coverage gap).
- Assets in high-risk categories → **WARN**.

## dex (Zero Trust / WARP — AUTO-GATE) {#dex}

Device posture & network health as a security signal (are managed devices
actually protected, is WARP on, is traffic egressing where expected). Zero-Trust
analytics, no general REST read → MCP-only.

Tools (`mcp__cloudflare-dex__*`), in order:
1. `dex_list_tests` + `dex_fleet_status_live` — if forbidden/empty ⇒ **locked** ("Zero Trust DEX / WARP not deployed"); stop.
2. `dex_test_statistics`, `dex_fleet_status_over_time` — trends.
3. `dex_http_test_details` / `dex_traceroute_test_details` / `dex_traceroute_test_network_path` — for failing synthetic tests.
4. `dex_list_warp_change_events` — posture/tamper signals (users disabling WARP).

Finding taxonomy (tag `area=dex`):
- WARP disconnect spikes / users disabling WARP → **WARN** (posture bypass).
- Synthetic-test failures to critical internal apps → **WARN**.
- Fleet % connected below ~90% → **WARN** (coverage).
- Traceroute egress outside expected colos → **INFO**.

## builds (Workers Builds CI/CD) {#builds}

Supply-chain posture of the deploy pipeline. The Workers Builds API isn't in the
REST surface the skill uses → MCP-only.

Tools (`mcp__cloudflare-builds__*`), in order:
1. `workers_list` → pick the production worker.
2. `workers_builds_set_active_worker` → `workers_builds_list_builds` → `workers_builds_get_build`.
3. `workers_builds_get_build_logs` — scan for leaked secrets.

Finding taxonomy (tag `area=builds`):
- Build-log lines matching secret patterns (`sk-`, `Bearer `, `AWS_`, `*_TOKEN=`, `AKIA`) → **FAIL** (secret in CI logs → rotate).
- Builds from unexpected branches/forks → **WARN** (review trust).
- Failing/again-failing builds on a production worker → **WARN**.
- No connected repo (manual `wrangler deploy` only) → **INFO** (no CI provenance to audit). Cross-link `lib/gha.sh`, `lib/wrangler_lint.sh`.

## browser (external rendered headers/CSP — PREFERRED + fallback) {#browser}

Validates headers/CSP from a real rendered page, catching what a header-only
check misses (meta-CSP, injected 3rd-party origins, mixed content).

Tools (`mcp__cloudflare-browser__*`):
- `get_url_html_content` / `get_url_markdown` — rendered DOM + `<meta http-equiv="Content-Security-Policy">` + script origins.
- `get_url_screenshot` — visual evidence (mixed content, unexpected widgets).

Recipe: for each in-scope host, fetch rendered page, inventory third-party
script origins + any meta-CSP, and compare to the response-header CSP from
`score` (which the skill computes locally).

Finding taxonomy (tag `area=headers` / `page-shield`):
- Header CSP missing or over-permissive (`unsafe-inline`, `*`) → **WARN** (cross-link `05-security-headers.md`).
- Third-party script origins not in the CSP allowlist → **WARN** (cross-link `16-page-shield-supply-chain.md`).
- Mixed content (http on https page) → **FAIL**.

Fallback (no browser MCP): use `score [hosts]` (header-only, local grade) and
note "rendered-DOM checks skipped (browser MCP not loaded)".

## observability (Workers errors as security signal — PREFERRED + fallback) {#observability}

Worker exceptions/errors often *are* the attack signal (probing, cred stuffing,
IDOR). Message-level detail needs the MCP; counts have a GraphQL fallback.

Tools (`mcp__cloudflare-observability__*`), in order:
1. `observability_keys` — discover available fields.
2. `query_worker_observability` — filter error/exception events, group by worker + message, last 24h.
3. `observability_values` — enumerate top values for a noisy field.
4. `workers_list` / `workers_get_worker_code` — correlate a noisy worker to code.

Finding taxonomy (tag `area=workers` / `observability`):
- Exception spikes aligned with `firewallEventsAdaptive` blocks (see `audit secevents`) → **WARN** (exploitation probing).
- Repeated auth/forbidden-class errors → **WARN** (cred stuffing / IDOR probing).
- Uncaught exceptions returning stack traces to clients → **INFO** (info disclosure).

Fallback (no observability MCP): GraphQL `workersInvocationsAdaptive`
(errors/subrequests counts) via the analytics path — counts only, no log bodies;
prefer the MCP for message-level detail.

---

Cross-refs: `33-logging-observability.md` (log coverage), `35-cicd-builds-security.md`
(CI/CD), `36-device-posture-casb.md` (DEX/CASB), `31-tool-contracts.md`
(`cfsec.audit-delegated` shape), `30-recipes.md#full-stack-audit`.
