# lib/state_env.sh — environment variables, digest + slices, with secret-shape heuristics.
# Exports: run_state_env [project-id] [environment-name] [slice]
#   slice ∈ digest (default) | vars | full
#
# The digest does NOT include values. It includes:
#   - count by reference type (literal vs ${{ }} reference)
#   - heuristic flags for plaintext-looking secrets
#   - duplicates across services (same value in N services → recommend shared.* ref)

run_state_env() {
  local project_id="${1:-}"
  local env_name="${2:-}"
  local slice="${3:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      printf '{"error":"could not resolve project id","code":"E_PROJECT"}\n' >&2
      return 3
    }
  fi
  if [[ -z "$env_name" ]]; then
    env_name="$(api_pick_environment 2>/dev/null)"
  fi

  case "$slice" in
    digest) _state_env_digest "$project_id" "$env_name" "$ts" ;;
    vars)   _state_env_vars   "$project_id" "$env_name" "$ts" ;;
    full)   _state_env_full   "$project_id" "$env_name" "$ts" ;;
    *)
      printf '{"error":"unknown state env slice","code":"E_USAGE","got":"%s","valid":["digest","vars","full"]}\n' "$slice" >&2
      return 2 ;;
  esac
}

# _se_resolve_environment_id <project_id> <name> -> echoes envId or empty.
_se_resolve_environment_id() {
  local pid="$1" name="$2"
  local body
  body="$(rw_gql 'query($id:String!){ project(id:$id){ environments { edges { node { id name } } } } }' \
    "$(jq -nc --arg id "$pid" '{id:$id}')" 2>/dev/null)" || return 1
  jq -r --arg n "$name" '(.data.project.environments.edges // [])[].node | select(.name==$n) | .id' \
    <<<"$body" 2>/dev/null | head -n 1
}

# _se_variables_per_service <project_id> <env_id>
# Returns: [{service_id, service_name, variables: { NAME: VALUE_OR_REF, ... }}]
_se_variables_per_service() {
  local pid="$1" eid="$2"
  local body
  body="$(rw_gql 'query($pid:String!, $eid:String!){
    project(id:$pid){
      services {
        edges {
          node {
            id name
            variables(environmentId: $eid)
          }
        }
      }
    }
  }' "$(jq -nc --arg pid "$pid" --arg eid "$eid" '{pid:$pid, eid:$eid}')" 2>/dev/null)" || {
    printf '[]'; return
  }
  jq '[(.data.project.services.edges // [])[].node | {
    service_id: .id, service_name: .name, variables: (.variables // {})
  }]' <<<"$body" 2>/dev/null || printf '[]'
}

# _se_shared_variables <project_id> <env_id>
# Project-level (shared) variables.
_se_shared_variables() {
  local pid="$1" eid="$2"
  local body
  body="$(rw_gql 'query($pid:String!, $eid:String!){
    variables(projectId:$pid, environmentId:$eid)
  }' "$(jq -nc --arg pid "$pid" --arg eid "$eid" '{pid:$pid, eid:$eid}')" 2>/dev/null)" || {
    printf '{}'; return
  }
  jq '.data.variables // {}' <<<"$body" 2>/dev/null || printf '{}'
}

# _se_classify_value -> echoes one of: reference | empty | secret-shaped | normal
# Pure-bash classifier; uses simple string matching to avoid jq quoting traps.
_se_classify_value() {
  local val="$1" name="$2"
  if [[ -z "$val" ]]; then printf 'empty'; return; fi
  # Reference form: ${{ ... }}
  if [[ "$val" == *'${{'*'}}'* ]]; then printf 'reference'; return; fi
  # Name suffix heuristic
  case "$name" in
    *_KEY|*_TOKEN|*_SECRET|*_PASSWORD|*_PASS|*_DSN|*_PRIVATE_KEY|*_API_KEY)
      printf 'secret-shaped'; return ;;
  esac
  # Prefix heuristic on value
  case "$val" in
    sk_*|pk_*|ghp_*|xoxb-*|AKIA*|eyJ*) printf 'secret-shaped'; return ;;
  esac
  # Length + entropy heuristic: ≥32 chars and base64ish/hex
  local len=${#val}
  if (( len >= 32 )); then
    if [[ "$val" =~ ^[A-Za-z0-9+/=_-]+$ ]] || [[ "$val" =~ ^[A-Fa-f0-9]+$ ]]; then
      printf 'secret-shaped'; return
    fi
  fi
  printf 'normal'
}

# _se_build_var_index <per_service_json> <shared_json>
# Emits: {
#   total_vars, by_classification, plaintext_secret_warnings: [{service,name}],
#   duplicates_across_services: [{name, services: [...]}],
#   reserved_RAILWAY_overrides: [{service,name}]
# }
_se_build_var_index() {
  local per_service="$1" shared="$2"
  python3 - "$per_service" "$shared" <<'PYEOF' 2>/dev/null || true
import json, re, sys

per_service = json.loads(sys.argv[1] or '[]')
shared      = json.loads(sys.argv[2] or '{}')

def classify(name, val):
    if val is None or val == "":
        return "empty"
    if isinstance(val, str) and "${{" in val and "}}" in val:
        return "reference"
    suffixes = ("_KEY", "_TOKEN", "_SECRET", "_PASSWORD", "_PASS", "_DSN",
                "_PRIVATE_KEY", "_API_KEY")
    if any(name.endswith(s) for s in suffixes):
        return "secret-shaped"
    if isinstance(val, str):
        for prefix in ("sk_", "pk_", "ghp_", "xoxb-", "AKIA", "eyJ"):
            if val.startswith(prefix):
                return "secret-shaped"
        if len(val) >= 32 and (re.fullmatch(r"[A-Za-z0-9+/=_-]+", val) or
                                re.fullmatch(r"[A-Fa-f0-9]+", val)):
            return "secret-shaped"
    return "normal"

reserved_prefixes = ("RAILWAY_", "PORT")
classifications = {"reference":0, "empty":0, "secret-shaped":0, "normal":0}
plaintext_secret_warnings = []
reserved_overrides = []
name_to_services = {}

for entry in per_service:
    svc = entry.get("service_name") or entry.get("service_id") or "?"
    vars_ = entry.get("variables") or {}
    if not isinstance(vars_, dict):
        continue
    for name, val in vars_.items():
        c = classify(name, val if isinstance(val, str) else "")
        classifications[c] = classifications.get(c, 0) + 1
        if c == "secret-shaped":
            plaintext_secret_warnings.append({"service": svc, "name": name})
        if any(name.startswith(p) for p in reserved_prefixes):
            reserved_overrides.append({"service": svc, "name": name})
        name_to_services.setdefault(name, []).append({"service": svc, "value_class": c})

# Shared (project) variables — collected separately.
shared_summary = {}
if isinstance(shared, dict):
    for n, v in shared.items():
        c = classify(n, v if isinstance(v, str) else "")
        shared_summary[n] = c

duplicates = []
for n, svcs in name_to_services.items():
    if len(svcs) >= 2:
        # Only flag duplicates whose values are not references (we don't see the value).
        duplicates.append({"name": n, "services": [s["service"] for s in svcs],
                           "value_classes": list({s["value_class"] for s in svcs})})

out = {
    "total_vars": sum(classifications.values()),
    "by_classification": classifications,
    "plaintext_secret_warnings": plaintext_secret_warnings,
    "reserved_RAILWAY_overrides": reserved_overrides,
    "duplicates_across_services": duplicates,
    "shared_summary": shared_summary,
}
print(json.dumps(out))
PYEOF
}

# _se_build_var_index_fallback — pure-bash fallback if python3 missing.
_se_build_var_index_fallback() {
  printf '{"total_vars":0,"by_classification":{},"plaintext_secret_warnings":[],"reserved_RAILWAY_overrides":[],"duplicates_across_services":[],"shared_summary":{},"_note":"python3 not present; only basic counts available"}'
}

_state_env_digest() {
  local pid="$1" env_name="$2" ts="$3"
  local eid; eid="$(_se_resolve_environment_id "$pid" "$env_name")"
  if [[ -z "$eid" ]]; then
    printf '{"error":"environment not found","code":"E_ENV","environment":"%s","remediation":"check RWSEC_ENVIRONMENT or list with: state project <pid> environments"}\n' "$env_name" >&2
    return 3
  fi
  local per_service shared idx
  per_service="$(_se_variables_per_service "$pid" "$eid")"
  shared="$(_se_shared_variables "$pid" "$eid")"
  if command -v python3 >/dev/null 2>&1; then
    idx="$(_se_build_var_index "$per_service" "$shared")"
  else
    idx="$(_se_build_var_index_fallback)"
  fi
  [[ -z "$idx" ]] && idx="$(_se_build_var_index_fallback)"

  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg env "$env_name" --arg eid "$eid" \
    --argjson idx "$idx" \
    '{
      schema: "rwsec.state-env.digest",
      schema_version: 1,
      generated_at: $ts,
      tool: "state-env",
      slice: "digest",
      project_id: $pid,
      environment: $env,
      environment_id: $eid,
      summary: $idx,
      hint: "for full data (var names + classifications, no values), run: state env <pid> <env> vars; full also includes raw values."
    }'
}

# vars: emit names + classifications, NOT values. Values only on `full` slice.
_state_env_vars() {
  local pid="$1" env_name="$2" ts="$3"
  local eid; eid="$(_se_resolve_environment_id "$pid" "$env_name")"
  [[ -z "$eid" ]] && {
    printf '{"error":"environment not found","code":"E_ENV"}\n' >&2
    return 3
  }
  local per_service shared
  per_service="$(_se_variables_per_service "$pid" "$eid")"
  shared="$(_se_shared_variables "$pid" "$eid")"
  # Strip values: keep only names per service.
  local stripped shared_names
  stripped="$(jq '[.[] | {service_id, service_name, variable_names: ((.variables // {}) | keys)}]' <<<"$per_service" 2>/dev/null)"
  shared_names="$(jq '[(. // {}) | keys[]?]' <<<"$shared" 2>/dev/null)"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg env "$env_name" --arg eid "$eid" \
    --argjson services "$stripped" \
    --argjson shared "$shared_names" \
    '{ schema:"rwsec.state-env.vars", schema_version:1, generated_at:$ts,
       tool:"state-env", slice:"vars", project_id:$pid, environment:$env, environment_id:$eid,
       services: $services, shared_variable_names: $shared,
       hint: "values intentionally omitted; full slice includes them but should only run in trusted contexts." }'
}

# full: includes values (treat as sensitive output).
_state_env_full() {
  local pid="$1" env_name="$2" ts="$3"
  local eid; eid="$(_se_resolve_environment_id "$pid" "$env_name")"
  [[ -z "$eid" ]] && {
    printf '{"error":"environment not found","code":"E_ENV"}\n' >&2
    return 3
  }
  local per_service shared
  per_service="$(_se_variables_per_service "$pid" "$eid")"
  shared="$(_se_shared_variables "$pid" "$eid")"
  jq -n \
    --arg ts "$ts" --arg pid "$pid" --arg env "$env_name" --arg eid "$eid" \
    --argjson services "$per_service" \
    --argjson shared "$shared" \
    '{ schema:"rwsec.state-env.full", schema_version:1, generated_at:$ts,
       tool:"state-env", slice:"full", project_id:$pid, environment:$env, environment_id:$eid,
       services: $services, shared_variables: $shared,
       _warning: "this slice includes raw values; redact before sharing." }'
}
