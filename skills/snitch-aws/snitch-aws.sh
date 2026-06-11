#!/usr/bin/env bash
# snitch-aws: thin tool surface, agent orchestrates synthesis.
# Read-only data tools emit JSON on stdout; mutating tools emit human-readable badges.
# No flags. Configuration via environment variables (AWS_PROFILE, AWS_REGION,
# AWSSEC_ACCOUNT_ID, AWSSEC_REGION).

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SKILL_DIR/lib"
REF_DIR="$SKILL_DIR/references"
TPL_DIR="$SKILL_DIR/templates"
STATE_DIR="$SKILL_DIR/.state"
mkdir -p "$STATE_DIR"
export SKILL_DIR LIB_DIR REF_DIR TPL_DIR STATE_DIR

# shellcheck source=lib/log.sh
. "$LIB_DIR/log.sh"
# shellcheck source=lib/api.sh
. "$LIB_DIR/api.sh"
# shellcheck source=lib/plan.sh
. "$LIB_DIR/plan.sh"

usage() {
  cat <<'EOF'
snitch-aws: thin AWS tool surface. Agent orchestrates synthesis.

Read-only (JSON on stdout):
  doctor                  env health: aws cli, jq, profile, sts caller, MCP
  detect                  cwd signals: stacks, databases, storage, IaC, AI, hostnames
  state <area> [slice]    per-area JSON; digest is default
                          Areas: account iam s3 ec2 vpc rds dynamodb lambda
                                 cloudfront route53 acm cognito secrets cloudtrail
                                 cloudwatch wafv2 shield config inspector macie
                                 guardduty securityhub backup kms organizations
                                 eks ecs eventbridge sqs-sns cost
  analytics               account cost + service usage signals
  events                  last 100 IAM-significant CloudTrail events
  fit-matrix [stack]      migration fit matrix
  stack-docs [stack]      canonical doc URLs per stack (for WebFetch)
  score [host...]         external validators (SSL Labs, Mozilla Observatory, ...)

Mutating (idempotent):
  fix <area> [args]       apply hardening; safe to re-run
                          Areas: iam s3 ec2 vpc rds lambda cloudfront cloudtrail
                                 kms secrets wafv2 guardduty securityhub backup
                                 account all
  panic <action> [args]   revoke-key <id> | quarantine-role <arn> | block-ip <ip> | restore

Utility:
  export                  JSON snapshot of in-scope areas to cwd
  terraform               emit Terraform stubs to stdout
  verify                  diff current state vs last snapshot
  refresh-docs            re-pull canonical AWS docs into references/_cache/
  help                    this message

Environment:
  AWS_PROFILE             active AWS CLI profile (prefer SSO)
  AWS_REGION / AWS_DEFAULT_REGION   default region
  AWSSEC_ACCOUNT_ID       optional account id override (else sts get-caller-identity)
  AWSSEC_REGION           optional region override
  AWSSEC_MCP_PRESENT      set to 1 if an AWS-flavored MCP is available
EOF
}

_refuse_long_lived_keys_json() {
  if [[ "${AWS_ACCESS_KEY_ID:-}" == AKIA* ]]; then
    # Detect if any SSO profile is configured.
    if [[ -f "$HOME/.aws/config" ]] && grep -E -q '^[[:space:]]*sso_(start_url|session)' "$HOME/.aws/config" 2>/dev/null; then
      printf '{"error":"long-lived AKIA* access key detected; SSO profile available","code":"E_AUTH","remediation":"unset AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY and use AWS_PROFILE=<sso-profile> with aws sso login"}\n' >&2
      return 2
    fi
  fi
  return 0
}

dispatch_state() {
  _refuse_long_lived_keys_json || return $?
  local sub="${1:-}"; shift || true
  case "$sub" in
    account)      . "$LIB_DIR/state_account.sh";      run_state_account "$@" ;;
    iam)          . "$LIB_DIR/state_iam.sh";          run_state_iam "$@" ;;
    s3)           . "$LIB_DIR/state_s3.sh";           run_state_s3 "$@" ;;
    ec2)          . "$LIB_DIR/state_ec2.sh";          run_state_ec2 "$@" ;;
    vpc)          . "$LIB_DIR/state_vpc.sh";          run_state_vpc "$@" ;;
    rds)          . "$LIB_DIR/state_rds.sh";          run_state_rds "$@" ;;
    dynamodb)     . "$LIB_DIR/state_dynamodb.sh";     run_state_dynamodb "$@" ;;
    lambda)       . "$LIB_DIR/state_lambda.sh";       run_state_lambda "$@" ;;
    cloudfront)   . "$LIB_DIR/state_cloudfront.sh";   run_state_cloudfront "$@" ;;
    route53)      . "$LIB_DIR/state_route53.sh";      run_state_route53 "$@" ;;
    acm)          . "$LIB_DIR/state_acm.sh";          run_state_acm "$@" ;;
    cognito)      . "$LIB_DIR/state_cognito.sh";      run_state_cognito "$@" ;;
    secrets)      . "$LIB_DIR/state_secrets.sh";      run_state_secrets "$@" ;;
    cloudtrail)   . "$LIB_DIR/state_cloudtrail.sh";   run_state_cloudtrail "$@" ;;
    cloudwatch)   . "$LIB_DIR/state_cloudwatch.sh";   run_state_cloudwatch "$@" ;;
    wafv2)        . "$LIB_DIR/state_wafv2.sh";        run_state_wafv2 "$@" ;;
    shield)       . "$LIB_DIR/state_shield.sh";       run_state_shield "$@" ;;
    config)       . "$LIB_DIR/state_config.sh";       run_state_config "$@" ;;
    inspector)    . "$LIB_DIR/state_inspector.sh";    run_state_inspector "$@" ;;
    macie)        . "$LIB_DIR/state_macie.sh";        run_state_macie "$@" ;;
    guardduty)    . "$LIB_DIR/state_guardduty.sh";    run_state_guardduty "$@" ;;
    securityhub)  . "$LIB_DIR/state_securityhub.sh";  run_state_securityhub "$@" ;;
    backup)       . "$LIB_DIR/state_backup.sh";       run_state_backup "$@" ;;
    kms)          . "$LIB_DIR/state_kms.sh";          run_state_kms "$@" ;;
    organizations) . "$LIB_DIR/state_organizations.sh"; run_state_organizations "$@" ;;
    eks)          . "$LIB_DIR/state_eks.sh";          run_state_eks "$@" ;;
    ecs)          . "$LIB_DIR/state_ecs.sh";          run_state_ecs "$@" ;;
    eventbridge)  . "$LIB_DIR/state_eventbridge.sh";  run_state_eventbridge "$@" ;;
    sqs-sns)      . "$LIB_DIR/state_sqs_sns.sh";      run_state_sqs_sns "$@" ;;
    cost)         . "$LIB_DIR/state_cost.sh";         run_state_cost "$@" ;;
    "")
      printf '{"error":"state requires a subscope","code":"E_USAGE","valid":["account","iam","s3","ec2","vpc","rds","dynamodb","lambda","cloudfront","route53","acm","cognito","secrets","cloudtrail","cloudwatch","wafv2","shield","config","inspector","macie","guardduty","securityhub","backup","kms","organizations","eks","ecs","eventbridge","sqs-sns","cost"]}\n' >&2
      return 2 ;;
    *)
      printf '{"error":"unknown state subscope","code":"E_USAGE","got":"%s"}\n' "$sub" >&2
      return 2 ;;
  esac
}

dispatch_fix() {
  local area="${1:-}"; shift || true
  if [[ -z "$area" ]]; then
    log_fail "fix" "usage" "fix requires an area. Run 'snitch-aws.sh help' for the list."
    return 2
  fi
  api_check_auth_env || return $?
  case "$area" in
    iam)          . "$LIB_DIR/apply_iam.sh";         apply_iam "$@" ;;
    s3)           . "$LIB_DIR/apply_s3.sh";          apply_s3 "$@" ;;
    ec2)          . "$LIB_DIR/apply_ec2.sh";         apply_ec2 "$@" ;;
    vpc)          . "$LIB_DIR/apply_vpc.sh";         apply_vpc "$@" ;;
    rds)          . "$LIB_DIR/apply_rds.sh";         apply_rds "$@" ;;
    lambda)       . "$LIB_DIR/apply_lambda.sh";      apply_lambda "$@" ;;
    cloudfront)   . "$LIB_DIR/apply_cloudfront.sh";  apply_cloudfront "$@" ;;
    cloudtrail)   . "$LIB_DIR/apply_cloudtrail.sh";  apply_cloudtrail "$@" ;;
    kms)          . "$LIB_DIR/apply_kms.sh";         apply_kms "$@" ;;
    secrets)      . "$LIB_DIR/apply_secrets.sh";     apply_secrets "$@" ;;
    wafv2)        . "$LIB_DIR/apply_wafv2.sh";       apply_wafv2 "$@" ;;
    guardduty)    . "$LIB_DIR/apply_guardduty.sh";   apply_guardduty "$@" ;;
    securityhub)  . "$LIB_DIR/apply_securityhub.sh"; apply_securityhub "$@" ;;
    backup)       . "$LIB_DIR/apply_backup.sh";      apply_backup "$@" ;;
    account)      . "$LIB_DIR/apply_account.sh";     apply_account "$@" ;;
    all)
      . "$LIB_DIR/apply_account.sh";     apply_account "$@"
      . "$LIB_DIR/apply_iam.sh";         apply_iam "$@"
      . "$LIB_DIR/apply_s3.sh";          apply_s3 "$@"
      . "$LIB_DIR/apply_ec2.sh";         apply_ec2 "$@"
      . "$LIB_DIR/apply_vpc.sh";         apply_vpc "$@"
      . "$LIB_DIR/apply_rds.sh";         apply_rds "$@"
      . "$LIB_DIR/apply_lambda.sh";      apply_lambda "$@"
      . "$LIB_DIR/apply_cloudfront.sh";  apply_cloudfront "$@"
      . "$LIB_DIR/apply_cloudtrail.sh";  apply_cloudtrail "$@"
      . "$LIB_DIR/apply_kms.sh";         apply_kms "$@"
      . "$LIB_DIR/apply_secrets.sh";     apply_secrets "$@"
      . "$LIB_DIR/apply_wafv2.sh";       apply_wafv2 "$@"
      . "$LIB_DIR/apply_guardduty.sh";   apply_guardduty "$@"
      . "$LIB_DIR/apply_securityhub.sh"; apply_securityhub "$@"
      . "$LIB_DIR/apply_backup.sh";      apply_backup "$@"
      ;;
    *)
      log_fail "fix" "usage" "unknown fix area: $area"
      return 2 ;;
  esac
}

# Deprecation notice for synthesis subcommands. Phase 1: prints a warning to
# stderr; Phase 2: removed entirely.
deprecation_notice() {
  local cmd="$1"
  printf '%s\n' "[DEPRECATED] '$cmd' is deprecated. The agent should compose the answer using primitive tools instead. See SKILL.md → 'Recipes' for the new flow." >&2
}

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    doctor)
      doctor_run ;;
    detect)
      . "$LIB_DIR/detect.sh"; run_detect "$@" ;;
    state)
      dispatch_state "$@" ;;
    analytics)
      _refuse_long_lived_keys_json || return $?
      . "$LIB_DIR/analytics.sh"; run_analytics "$@" ;;
    events)
      _refuse_long_lived_keys_json || return $?
      . "$LIB_DIR/events.sh"; run_events "$@" ;;
    fit-matrix)
      . "$LIB_DIR/fit_matrix.sh"; run_fit_matrix "$@" ;;
    stack-docs)
      . "$LIB_DIR/stack_docs.sh"; run_stack_docs "$@" ;;
    score)
      . "$LIB_DIR/score.sh"; run_score "$@" ;;
    export)
      . "$LIB_DIR/export.sh"; run_export "$@" ;;
    terraform)
      api_check_auth_env || return $?
      . "$LIB_DIR/terraform.sh"; run_terraform "$@" ;;
    verify)
      api_check_auth_env || return $?
      . "$LIB_DIR/drift.sh"; drift_run ;;
    refresh-docs)
      . "$LIB_DIR/refresh_docs.sh"; run_refresh_docs "$@" ;;
    fix)
      dispatch_fix "$@" ;;
    panic)
      api_check_auth_env || return $?
      . "$LIB_DIR/panic.sh"; run_panic "$@" ;;
    # ---------- DEPRECATED synthesis subcommands (Phase 1) ----------
    check|migrate|roadmap|report|diagnose|stacks)
      deprecation_notice "$cmd"
      printf '%s\n' "[INFO] The agent should run the appropriate primitive tool combination instead. See $REF_DIR/30-recipes.md." >&2
      return 64 ;;
    help|-h|--help|"")
      usage ;;
    *)
      log_fail "skill" "usage" "unknown subcommand: $cmd"
      usage
      return 2 ;;
  esac
}

main "$@"
