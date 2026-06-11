# lib/terraform.sh — emit a Terraform stub for Railway.
# Railway has limited TF coverage; the community provider terraform-community-providers/railway
# covers a useful subset (project, service, variable, environment). This file
# emits a stub + URL so the user knows where to go.
#
# Exports: run_terraform

run_terraform() {
  log_section "terraform export"
  local ts; ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local pid; pid="$(api_pick_project 2>/dev/null || printf 'PROJECT_ID')"
  local out="${STATE_DIR}/railway-${ts}.tf"

  cat > "$out" <<EOF
# Auto-generated stub by snitch-railway.
# Railway's official Terraform support is limited. The most maintained
# community provider is:
#
#   https://registry.terraform.io/providers/terraform-community-providers/railway/latest
#
# It covers: railway_project, railway_service, railway_environment,
# railway_variable, railway_custom_domain, railway_tcp_proxy.
# It does NOT cover: workspace billing, log drains, member roles.
#
# This file is a starting point — fill in resource bodies after auditing
# state with: bash snitch-railway.sh state services <project-id> full

terraform {
  required_providers {
    railway = {
      source  = "terraform-community-providers/railway"
      version = "~> 0.5"
    }
  }
}

provider "railway" {
  # token is read from RAILWAY_TOKEN by default.
}

# Project (already created; import with):
#   terraform import railway_project.this ${pid}
resource "railway_project" "this" {
  name = "REPLACE_WITH_PROJECT_NAME"
}

# Example service. Run state services <pid> full to enumerate.
# resource "railway_service" "api" {
#   project_id = railway_project.this.id
#   name       = "api"
# }

# Example shared variable.
# resource "railway_variable" "shared_DATABASE_URL" {
#   environment_id = railway_environment.production.id
#   name           = "DATABASE_URL"
#   value          = "\${railway_postgres.main.url}"
# }
EOF

  cat "$out"
  log_ok "terraform" "stub" "wrote ${out}"
  log_info "Refer to https://registry.terraform.io/providers/terraform-community-providers/railway/latest/docs"
}
