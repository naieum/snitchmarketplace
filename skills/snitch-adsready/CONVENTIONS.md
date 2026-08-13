# ads-ready — internal conventions (for code authors / agents)

This file is **not** part of the user-facing skill. It is the contract every `lib/*.sh` author follows so the assembled skill behaves consistently.

## Bash style

- `#!/usr/bin/env bash` is set on `ads-ready.sh` only; library files are sourced and start with a comment header.
- `set -uo pipefail` is set in `ads-ready.sh`. **Do not** add `set -e` in libs — explicit return codes only.
- All functions use lowercase_with_underscores.
- All public functions in a lib have a comment header: signature + side effects.
- 2-space indentation, no tabs. Quote all variable expansions: `"${var}"`. Prefer `[[ ... ]]` over `[ ... ]`.
- Use `printf` for output, never `echo -e`.
- `local` for every function-local variable.

## Source layout

- `lib/api.sh`, `lib/log.sh`, `lib/plan.sh` are pre-sourced by `ads-ready.sh` before any subcommand fires. Don't re-source them.
- All other lib files are sourced on demand by the dispatcher in `ads-ready.sh`. Don't source siblings — add the function call to `ads-ready.sh` instead.
- `lib/platforms/<name>.sh` files each export a single `platform_state` function, called from `lib/state_platform.sh::run_state_platform`.
- Each universal lib defines a small set of exported functions:
  - `run_<command>` — the read-only entrypoint, called from the matching subcommand.
  - `apply_<area>` — the idempotent apply pass, called from `fix <area>`.

## Output: every read tool emits JSON; every fix emits badges

Read tools (digest mode by default):

- `printf` a single JSON document on stdout with the schema header:

  ```
  { "schema": "adssec.<tool>.<slice?>",
    "schema_version": 1,
    "generated_at": "<ISO-8601>",
    "tool": "<tool-name>",
    ...payload }
  ```

- Errors → stderr as JSON `{ "error": "...", "code": "E_*", "remediation": "...", ...context }`. Non-zero exit.

Mutating tools — use these and only these:

- `log_ok    <area> <key> <message> [docs_url]` — desired state met.
- `log_warn  <area> <key> <message> [docs_url]` — fix recommended, not critical.
- `log_fail  <area> <key> <message> [docs_url]` — fix required.
- `log_locked <area> <key> <message> <required_capability> [docs_url]` — feature is gated by missing API auth.
- `log_info  <message>` — chatter.
- `log_section <title>` / `log_subsection <title>` — separators.

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, detect, site, crux, lighthouse, gsc, ga4, pixels, consent, structured-data, robots, sitemap, ads-txt, security-headers, mobile-meta, verification-meta, capi, score, fit-matrix, stack-docs, drift, export, refresh-docs, setup, recommend, prereqs, platform-google, platform-meta, platform-microsoft, platform-linkedin, platform-tiktok, platform-x, platform-pinterest, platform-reddit, platform-snapchat, platform-apple`.

## API helpers (`lib/api.sh`)

- `http_get <url>` — generic GET, prints body, rc=3 on non-2xx. Sets `ADSEC_LAST_STATUS`, `ADSEC_LAST_BODY`.
- `http_post_json <url> <json>` — generic POST.
- `fetch_url_html <url>` — used by `state_site`; follows redirects (≤5), returns body + headers.
- `fetch_url_headers <url>` — HEAD + headers via `-I -L`.
- Per-capability helpers (used to decide which tool calls to attempt):
  - `has_psi_api_key`, `has_lighthouse_cli`, `has_ga4_auth`, `has_gsc_auth`
  - `has_google_ads_api`, `has_meta_marketing_api`, `has_microsoft_ads_api`, `has_linkedin_ads_api`, `has_tiktok_marketing_api`, `has_x_ads_api`, `has_pinterest_ads_api`, `has_reddit_ads_api`, `has_snapchat_marketing_api`, `has_apple_search_ads_api`
- Each platform helper in `lib/platforms/<name>.sh` is responsible for its own request signing and emits its own `{locked:"<platform>-api"}` envelope when its env vars are missing.

## Capability gating

Before every API-gated check or fix, call:

```sh
requires_capability <area> <key> <message> <capability> [docs_url] || return 0
```

- `requires_capability` evaluates the matching `has_*` helper.
- If satisfied, returns 0 (caller proceeds).
- If not, emits `log_locked` and returns 1, letting the caller skip cleanly.
- For pure read tools that emit a single JSON doc, prefer to keep going and embed `{locked:"<capability>", ...}` inside the JSON instead of erroring out — the agent should still receive a valid, parseable response.

## Idempotency contract for `apply_*`

Every `apply_<area>` function:

1. **Reads current state first** — fetches the URL, inspects the cwd file, or checks the platform's API.
2. **Compares** to the target state defined in the function.
3. **No-ops** if already compliant; logs `[OK]` and returns 0.
4. Otherwise emits a `=== FILE/DIFF/CONTENT ===` block on stdout (the agent applies it) or a single API mutation.
5. Re-reads on success and logs `[OK]` for the new state.

Never mutate without the read-first compare. Never emit `[FAIL]` from an `apply_*` unless the underlying tool actually returned an error.

## File writes

- Library code **never** writes inside the user's project directory (cwd or below).
- For project-side changes (any `fix pixel-install`, `fix consent-mode`, `fix capi-stub`, `fix ads-txt`, `fix robots`, `fix structured-data`, `fix security-headers`, `fix mobile-meta`, `fix verification-meta`), the lib emits the proposed file path + full file body + a unified diff to stdout, and Claude (the agent) applies it via `Edit` / `Write` after the user agrees. Use this template:

  ```
  === FILE: <relative path> ===
  === DIFF ===
  <unified diff>
  === CONTENT ===
  <full proposed file>
  === END ===
  ```

- The skill freely writes inside `~/.claude/skills/ads-ready/.state/` (snapshots, caches, drift state) and `~/.claude/skills/ads-ready/references/_cache/` (refreshed docs).

## Refusing dangerous defaults

- Refuse to operate when a generic `API_KEY` (with no platform prefix) is in scope — every platform's auth must be scoped.
- Refuse to write tracking pixels into a page when no consent banner / CMP is detected and the user is in scope of GDPR / ePrivacy / CCPA — surface it as a FAIL and offer `recommend cmp`.
- Refuse to lower posture in any `apply_*` (e.g., never remove an existing CSP, never overwrite an existing `ads.txt` with fewer lines).

## Stack detection

Stack detection lives in `lib/detect.sh`. Other libs that need stack info call `run_detect` and read its JSON output. Don't re-implement detection.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
