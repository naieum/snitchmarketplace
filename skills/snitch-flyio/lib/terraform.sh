# lib/terraform.sh — emit fly-terraform HCL skeleton for the current org's apps.
# Exports: run_terraform [org]
#
# Uses the fly-apps Terraform provider (registry.terraform.io/fly-apps/fly).
# This is a skeleton: maps apps and volumes to resources. The agent + user
# adjust per-app config.

run_terraform() {
  local org="${1:-}"
  if [[ -z "$org" ]]; then
    org="$(api_pick_org 2>/dev/null || printf '')"
  fi
  if [[ -z "$org" ]]; then
    printf '# error: could not pick org. set FLYSEC_ORG and re-run.\n' >&2
    return 2
  fi

  local apps; apps="$(fly_run_json apps list --org "$org" 2>/dev/null || printf '[]')"

  cat <<HCL
# snitch-flyio terraform skeleton — review & adjust before \`terraform apply\`.
# https://registry.terraform.io/providers/fly-apps/fly/latest/docs

terraform {
  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.0.23"
    }
  }
}

provider "fly" {
  # Pulls token from FLY_API_TOKEN env or ~/.fly/config.yml
}

variable "org" {
  default = "${org}"
}
HCL

  local app
  while IFS= read -r app; do
    [[ -z "$app" || "$app" == "null" ]] && continue
    local rname; rname="$(printf '%s' "$app" | tr -c 'a-zA-Z0-9_' '_')"
    cat <<APP

resource "fly_app" "${rname}" {
  name = "${app}"
  org  = var.org
}
APP
    local v; v="$(fly_run_json volumes list -a "$app" 2>/dev/null || printf '[]')"
    local idx=0
    while IFS=$'\t' read -r vname vregion vsize; do
      [[ -z "$vname" ]] && continue
      idx=$((idx+1))
      local rvol; rvol="${rname}_v${idx}"
      cat <<VOL

resource "fly_volume" "${rvol}" {
  name   = "${vname}"
  app    = fly_app.${rname}.name
  region = "${vregion}"
  size   = ${vsize:-1}
}
VOL
    done < <(jq -r '.[] | "\(.name // .Name)\t\(.region // .Region)\t\(.size_gb // .SizeGb // 1)"' <<<"$v" 2>/dev/null)
  done < <(jq -r '.[].Name // .[].name' <<<"$apps" 2>/dev/null)

  printf '\n# end of generated skeleton\n'
}
