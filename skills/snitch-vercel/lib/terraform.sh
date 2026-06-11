# lib/terraform.sh — emit a starter HCL stub for the vercel/vercel provider.
# Cites a current pinned version. The user reviews + applies.

run_terraform() {
  cat <<'HCL'
# snitch-vercel terraform starter
# Provider: vercel/vercel  https://registry.terraform.io/providers/vercel/vercel/latest/docs

terraform {
  required_version = ">= 1.5"
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.0"   # check the registry for the current major
    }
  }
}

variable "vercel_team_id" {
  description = "Vercel team ID"
  type        = string
}

provider "vercel" {
  team = var.vercel_team_id
  # api_token sourced from VERCEL_API_TOKEN env var
}

# Example: project with security headers + Vercel Authentication for previews.
resource "vercel_project" "app" {
  name        = "my-app"
  framework   = "nextjs"
  team_id     = var.vercel_team_id

  vercel_authentication = {
    deployment_type = "preview"
  }

  serverless_function_region = "iad1"
}

# Example: env var marked Sensitive.
resource "vercel_project_environment_variable" "db_url" {
  project_id = vercel_project.app.id
  team_id    = var.vercel_team_id
  key        = "DATABASE_URL"
  value      = var.database_url   # never hardcode
  target     = ["production", "preview"]
  type       = "sensitive"
}

variable "database_url" { type = string; sensitive = true }

# Example: log drain (Pro+).
# resource "vercel_log_drain" "siem" {
#   team_id          = var.vercel_team_id
#   delivery_format  = "json"
#   sources          = ["lambda", "edge", "build", "static", "external"]
#   environments     = ["production"]
#   endpoint         = "https://siem.example.com/vercel"
# }
HCL
}
