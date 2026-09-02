# snitch-adsready — internal conventions (for code authors / agents)

This file is a **contributor contract**: the rules every `lib/*.sh` author follows so the assembled skill behaves consistently. It ships inside the skill folder for transparency — anyone auditing the bundled tools can read what they were built to — but nothing loads it at runtime, so no rule that governs a run may live only here. Blocking rules belong in the Guardrails section of `SKILL.md` (the one the agent actually reads) and in the code that enforces them; this file only points at them.

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
- All other lib files are sourced on demand by the dispatcher in `ads-ready.sh`. Prefer adding the
  call to the dispatcher over sourcing a sibling. A lib may source a sibling when it genuinely
  composes it — `score.sh` needs `state_site` and `state_crux`, `state_lighthouse.sh` needs
  `state_crux`, `apply_headers.sh` and `apply_structured_data.sh` need `detect` — but it must
  guard with `declare -f <fn> >/dev/null || . "$LIB_DIR/<lib>.sh"` so a second source is free,
  and it must never source `log.sh`, `api.sh`, or `plan.sh` (already loaded).
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
- Never write `--argjson x "${var:-{}}"`. Bash closes the expansion at the first `}`, so a
  non-empty `var` gets a stray `}` appended and `jq` rejects the whole document. Normalize
  first: `[[ -z "$var" ]] && var='{}'`.
- Building an object from `to_entries | map(...) | from_entries` only works when each element
  keeps a `value` key. Use `with_entries(.value |= …)` to reshape values.

Mutating tools — use these and only these:

- `log_ok    <area> <key> <message> [docs_url]` — desired state met.
- `log_warn  <area> <key> <message> [docs_url]` — fix recommended, not critical.
- `log_fail  <area> <key> <message> [docs_url]` — fix required.
- `log_locked <area> <key> <message> <required_capability> [docs_url]` — feature is gated by missing API auth. Renders `⚪ [SKIP]`: a Skip carries the reason and what would unblock it.
- `log_info  <message>` — chatter. It prints to **stdout**, so a JSON-emitting tool must redirect it (`log_info "…" >&2`) or it corrupts the document.
- `log_section <title>` / `log_subsection <title>` — separators.

`<area>` values (keep these stable; they're used for grouping):
`auth, doctor, detect, site, crux, lighthouse, gsc, ga4, pixels, consent, structured-data, robots, sitemap, ads-txt, security-headers, mobile-meta, verification-meta, capi, score, fit-matrix, stack-docs, drift, export, refresh-docs, setup, recommend, prereqs, platform-google, platform-meta, platform-microsoft, platform-linkedin, platform-tiktok, platform-x, platform-pinterest, platform-reddit, platform-snapchat, platform-apple`.

## API helpers (`lib/api.sh`)

- `http_get <url>` — generic GET, prints body, rc=3 on non-2xx.
- `http_last_status` — the status of the most recent `http_*` call. Use this, not
  `$ADSEC_LAST_STATUS`: the wrappers usually run inside `$(…)`, and a variable assigned in a
  subshell never reaches the caller. The wrappers write the status to a file for this reason.
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

- Library code **never** writes inside the skill folder either — the folder is distributed and
  may be read-only. All runtime state goes to `$STATE_DIR`
  (`${XDG_STATE_HOME:-$HOME/.local/state}/snitch-adsready`, overridable with `ADSEC_STATE_DIR`):
  `findings.tsv`, `api-calls.log`, `snapshot-*.tsv`, and `$CACHE_DIR` (`$STATE_DIR/doc-cache`)
  for `refresh-docs`. Both are exported by `ads-ready.sh`. When `$STATE_DIR` is not writable,
  `log.sh` falls back to the temp dir rather than erroring.
- Temp files live for one run and are registered with `adsec_tmp_register <path>`; the single
  `EXIT` trap in `log.sh` removes them. Never install a second `trap ... EXIT` — it silently
  replaces the first.

## Refusing dangerous defaults

The blocking rules themselves live in the Guardrails section of `SKILL.md` — one owner, and
the one the agent actually reads. Implement them there and enforce them in code:

- the generic-`API_KEY` refusal (`ads-ready.sh::_refuse_legacy_global_key_json`),
- the consent precondition on pixel writes (`lib/apply_pixel.sh::_pixel_consent_signal`),
- never lowering posture in an `apply_*`.

## Stack detection

Stack detection lives in `lib/detect.sh`. Other libs that need stack info call `run_detect` and read its JSON output. Don't re-implement detection.

## Snapshots and verify

- `log.sh::snapshot_write` writes the findings TSV to `${STATE_DIR}/snapshot-<ts>.tsv` and updates the `snapshot-latest.tsv` symlink.
- `lib/drift.sh::drift_run` diffs the current findings against `snapshot-latest.tsv`.
