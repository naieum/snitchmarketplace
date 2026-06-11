# lib/terraform.sh — emit Terraform stub for the user's AWS account.
# Exports: run_terraform

run_terraform() {
  local out="${TPL_DIR}/terraform-stub.tf.tpl"
  if [[ ! -f "$out" ]]; then
    log_warn "terraform" "template" "Terraform template missing at ${out}; emitting minimal stub."
    cat <<'EOF'
provider "aws" {
  region  = var.region
  profile = var.profile
}

variable "region"  { type = string  default = "us-east-1" }
variable "profile" { type = string  default = "default" }

# Add per-area resources here. See snitch-aws/templates/ for starter blueprints.
EOF
    return 0
  fi
  cat "$out"
}
