# 32 — MCP / CLI division of labor

## Current state

No first-party MCP exists for any of the 10 supported ad platforms. The skill is exclusively curl-based for platform calls.

If a platform ships an MCP, the integration follows `cloudflare-secure`:

1. Honor `ADSEC_MCP_<PLATFORM>_PRESENT=1`.
2. Prefer the MCP for typed reads when present.
3. Fall back to curl when not.
4. Update this file.

## Local CLI tools

| Tool | Required? | What it does |
|---|---|---|
| `curl` | required | every HTTP call |
| `jq` | required | every JSON parse / shape transform |
| `lighthouse` | optional | full Lighthouse JSON; falls back to PSI |
| `pup` | optional | HTML parsing (Go) |
| `htmlq` | optional | HTML parsing (Rust, CSS-selector) |
| `gh` | optional | for `fix gha` scaffold |
| `openssl` | optional | Meta CAPI appsecret_proof, Apple JWT signing |

`prereqs` reports per-tool presence + install hints per OS.

## What the skill never does

- **Mutate ad campaigns.** No "pause campaign" or "change bid." Read + setup tracking only.
- **Send programmatic creative.** Out of scope.
- **Verify a charge succeeded.** Audits readiness, not billing.

## Companion tools the skill recommends but doesn't install

- CMP vendors — `recommend cmp`.
- sGTM hosts — `recommend gtm-server`.
- CAPI helper libs — `recommend capi-helpers`.
- CI Lighthouse runners — `recommend lighthouse-runner`.
- RUM monitoring — `recommend cwv-monitoring`.

Surfaced as catalogs; user picks; skill links to vendor signup or `npm install`.

## See also

- `01-auth-and-tokens.md` — env-var conventions.
- `references/recommendations/*.md` — the catalogs.
- MCP server registry: https://github.com/modelcontextprotocol/servers
