# lib/state_project.sh — project digest + full slice.
# Exports: run_state_project [project-id] [slice]
#   slice ∈ digest (default) | full

run_state_project() {
  local project_id="${1:-}" slice="${2:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [[ -z "$project_id" ]]; then
    project_id="$(vercel_pick_project 2>/dev/null || true)"
  fi
  if [[ -z "$project_id" ]]; then
    printf '{"error":"could not resolve project id","code":"E_PROJECT","remediation":"set VRCSEC_PROJECT_ID, run inside a linked Vercel project, or pass project-id"}\n' >&2
    return 3
  fi
  case "$slice" in
    digest) _sp_digest "$project_id" "$ts" ;;
    full)   _sp_full "$project_id" "$ts" ;;
    *)
      printf '{"error":"unknown state project slice","code":"E_USAGE","got":"%s","valid":["digest","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

_sp_meta() {
  local project_id="$1"
  local body; body="$(vrc_get "/v9/projects/${project_id}")" || {
    printf '{"error":"failed to fetch project","code":"E_API","status":%s,"project_id":"%s"}\n' "${VRCSEC_LAST_STATUS:-0}" "$project_id" >&2
    printf '{}'
    return
  }
  jq '{
    id, name, accountId,
    framework,
    nodeVersion: (.nodeVersion // null),
    devCommand: (.devCommand // null),
    buildCommand: (.buildCommand // null),
    installCommand: (.installCommand // null),
    outputDirectory: (.outputDirectory // null),
    rootDirectory: (.rootDirectory // null),
    autoExposeSystemEnvs: (.autoExposeSystemEnvs // null),
    serverlessFunctionRegion: (.serverlessFunctionRegion // null),
    autoAssignCustomDomains: (.autoAssignCustomDomains // null),
    gitForkProtection: (.gitForkProtection // null),
    gitLFS: (.gitLFS // null),
    link: (.link // null),
    git: {
      type: (.link.type // null),
      repo: (.link.repo // null),
      productionBranch: (.link.productionBranch // null)
    },
    ssoProtection: (.ssoProtection // null),
    passwordProtection: (.passwordProtection // null),
    trustedIps: (.trustedIps // null),
    deploymentExpiration: (.deploymentExpiration // null),
    createdAt, updatedAt
  }' <<<"$body" 2>/dev/null || printf '{}'
}

_sp_digest() {
  local project_id="$1" ts="$2"
  local meta; meta="$(_sp_meta "$project_id")"
  jq -n --arg ts "$ts" --arg project_id "$project_id" --argjson p "$meta" \
    '{
      schema: "vrcsec.state-project.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-project",
      slice: "digest",
      project_id: $project_id,
      project: $p,
      protection_summary: {
        sso:      ($p.ssoProtection // null),
        password: ($p.passwordProtection // null),
        trusted_ips_present: (($p.trustedIps // null) != null)
      },
      hint: "for full data, run: state project <id> full"
    }'
}

_sp_full() {
  local project_id="$1" ts="$2"
  local body
  body="$(vrc_get "/v9/projects/${project_id}")" || body='{}'
  jq -n --arg ts "$ts" --arg project_id "$project_id" --argjson p "$body" \
    '{ schema: "vrcsec.state-project.full", schema_version: 1, generated_at: $ts,
       tool: "state-project", slice: "full", project_id: $project_id, project: $p }'
}
