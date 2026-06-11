# lib/apply_lambda.sh — Lambda hardening:
#  - Heuristic env-vars-with-secrets warning (cannot auto-fix without input).
#  - Function URL auth-type recommendation for AWS_IAM if currently NONE.
# Exposes: apply_lambda [args]

apply_lambda() {
  log_section "Lambda hardening"

  local funcs
  funcs="$(aws_run_json lambda list-functions 2>/dev/null | jq -c '.Functions // []' 2>/dev/null)"
  local total
  total="$(jq -r 'length' <<<"$funcs" 2>/dev/null)"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_info "no Lambda functions in this region"
    return 0
  fi

  # Env-secret heuristic (use SecretsManager).
  local sus
  sus="$(jq -r '.[] | select(((.Environment.Variables // {}) | to_entries | map(select((.key | test("(?i)(SECRET|PASSWORD|TOKEN|API_KEY)")))) | length) > 0) | .FunctionName' <<<"$funcs")"
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    log_warn "lambda" "env-secret/${f}" "${f} has env vars whose keys look like secrets. Move to Secrets Manager and reference at runtime: 'aws secretsmanager create-secret --name lambda/${f}/secrets --secret-string ...'."
  done <<<"$sus"

  # Function URL auth-type.
  local fnames
  fnames="$(jq -r '.[].FunctionName' <<<"$funcs")"
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    local fu
    fu="$(aws_run_json lambda get-function-url-config --function-name "$f" 2>/dev/null)"
    if [[ "$(jq -r 'has("FunctionUrl")' <<<"$fu" 2>/dev/null)" == "true" ]]; then
      local auth
      auth="$(jq -r '.AuthType // "NONE"' <<<"$fu")"
      if [[ "$auth" == "NONE" ]]; then
        log_warn "lambda" "url-auth/${f}" "${f} Function URL has AuthType=NONE (publicly invocable). Consider AWS_IAM: 'aws lambda update-function-url-config --function-name ${f} --auth-type AWS_IAM'." "https://docs.aws.amazon.com/lambda/latest/dg/urls-auth.html"
      else
        log_ok "lambda" "url-auth/${f}" "${f} Function URL AuthType=${auth}."
      fi
    fi
  done <<<"$fnames"

  return 0
}
