# lib/rules.sh — WAF / Custom Rules / Bots fixes.
# Exposes:
#   apply_rules <area> [args]   — dispatcher.
# Areas:
#   waf    | deploy free Managed Ruleset; Cloudflare Managed + OWASP on Pro+.
#   rules  | foreign-tech-blocking custom rule from templates/waf-stack-profiles.json.
#   bots   | Bot Fight Mode; Super Bot Fight Mode on Pro+.
#   all    | waf, then rules, then bots.
# Side effects:
#   - Read-first via cf_get; idempotent updates by description tag.

# _put_phase_entrypoint <zone_id> <phase> <rules_json_array>
_put_phase_entrypoint() {
  local zone_id="$1" phase="$2" rules="$3"
  local payload
  payload="$(jq -n --argjson rules "$rules" '{rules:$rules}')"
  cf_put "/zones/${zone_id}/rulesets/phases/${phase}/entrypoint" "$payload" >/dev/null
}

# _get_phase_entrypoint <zone_id> <phase>
# Echoes JSON; rc=3 if not found. Empty string on absent endpoint.
_get_phase_entrypoint() {
  local zone_id="$1" phase="$2"
  cf_get "/zones/${zone_id}/rulesets/phases/${phase}/entrypoint" 2>/dev/null
}

# _find_managed_ruleset_id <zone_id> <name_match_regex>
# Echoes the first managed ruleset id whose .name matches the regex (case-insensitive).
_find_managed_ruleset_id() {
  local zone_id="$1" pat="$2"
  local body
  body="$(cf_get "/zones/${zone_id}/rulesets")" || return 3
  jq -r --arg p "$pat" '[.result[]? | select(.kind=="managed") | select(.name|test($p;"i"))][0].id // empty' <<<"$body" 2>/dev/null
}

# apply_rules_waf <zone_id>
# Deploys the Free Managed Ruleset; Cloudflare Managed + OWASP on Pro+.
# Idempotent: read existing entrypoint executes; skip if already present.
apply_rules_waf() {
  local zone_id="$1"
  local phase="http_request_firewall_managed"
  local existing
  existing="$(_get_phase_entrypoint "$zone_id" "$phase")"
  local cur_rules
  cur_rules="$(jq -c '.result.rules // []' <<<"${existing:-{}}" 2>/dev/null)"
  [[ -z "$cur_rules" || "$cur_rules" == "null" ]] && cur_rules='[]'

  local plan_tier
  plan_tier="$(detect_plan "$zone_id")"

  # Pull ruleset ids by name pattern.
  local free_id managed_id owasp_id
  free_id="$(_find_managed_ruleset_id "$zone_id" "Free")"
  managed_id="$(_find_managed_ruleset_id "$zone_id" "Cloudflare Managed")"
  owasp_id="$(_find_managed_ruleset_id "$zone_id" "OWASP")"

  local desired_ids=()
  if [[ -n "$free_id" ]]; then desired_ids+=("$free_id"); fi
  if tier_at_least "$plan_tier" "pro"; then
    [[ -n "$managed_id" ]] && desired_ids+=("$managed_id")
    [[ -n "$owasp_id" ]] && desired_ids+=("$owasp_id")
  fi

  if [[ "${#desired_ids[@]}" -eq 0 ]]; then
    log_warn "waf" "managed-deploy" "No managed ruleset ids found for this zone; cannot deploy."
    return 0
  fi

  local new_rules="$cur_rules"
  local added=0 id
  for id in "${desired_ids[@]}"; do
    local present
    present="$(jq -r --arg id "$id" '[.[] | select(.action=="execute" and .action_parameters.id==$id)] | length' <<<"$new_rules")"
    if [[ "${present:-0}" -gt 0 ]]; then
      log_ok "waf" "deploy-${id:0:8}" "Managed ruleset ${id} already deployed."
      continue
    fi
    new_rules="$(jq -c --arg id "$id" \
      '. + [{description: ("cloudflare-secure:managed-" + $id),
             expression: "true",
             action: "execute",
             action_parameters: {id: $id},
             enabled: true}]' <<<"$new_rules")"
    added=1
    log_info "Queued deploy of managed ruleset ${id}."
  done

  if [[ "$added" -eq 0 ]]; then
    log_ok "waf" "managed-deploy" "All desired managed rulesets already deployed."
    return 0
  fi

  if _put_phase_entrypoint "$zone_id" "$phase" "$new_rules"; then
    log_ok "waf" "managed-deploy" "Managed rulesets deployed."
  else
    log_fail "waf" "managed-deploy" "PUT entrypoint failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 3
  fi
}

# _foreign_tech_expression <stack>
# Echoes a Cloudflare Ruleset Engine expression that matches paths a non-<stack> site
# should never see. Reads ${TPL_DIR}/waf-stack-profiles.json if present; falls back to a
# conservative built-in.
_foreign_tech_expression() {
  local stack="${1:-generic}"
  local profile="${TPL_DIR:-/dev/null}/waf-stack-profiles.json"
  if [[ -f "$profile" ]]; then
    local expr
    expr="$(jq -r --arg s "$stack" '
      (.profiles[$s] // .profiles.generic // {paths:[],extensions:[]}) as $p
      | (([$p.paths // [] | .[] | "starts_with(http.request.uri.path, \"" + . + "\")"]) +
         ([$p.extensions // [] | .[] | "ends_with(http.request.uri.path, \"" + . + "\")"]))
      | join(" or ")
    ' "$profile" 2>/dev/null)"
    if [[ -n "$expr" && "$expr" != "null" ]]; then
      printf '(%s)' "$expr"
      return 0
    fi
  fi
  # Fallback default-deny list shared across non-PHP, non-.NET stacks.
  cat <<'EOF' | tr -d '\n'
(starts_with(http.request.uri.path, "/wp-admin") or starts_with(http.request.uri.path, "/wp-login") or starts_with(http.request.uri.path, "/wp-includes") or starts_with(http.request.uri.path, "/wp-content") or starts_with(http.request.uri.path, "/wp-config") or starts_with(http.request.uri.path, "/wp-json") or starts_with(http.request.uri.path, "/xmlrpc.php") or starts_with(http.request.uri.path, "/phpmyadmin") or starts_with(http.request.uri.path, "/pma") or starts_with(http.request.uri.path, "/adminer.php") or starts_with(http.request.uri.path, "/.git") or starts_with(http.request.uri.path, "/.svn") or starts_with(http.request.uri.path, "/.env") or starts_with(http.request.uri.path, "/.aws") or starts_with(http.request.uri.path, "/.DS_Store") or starts_with(http.request.uri.path, "/manager/html") or starts_with(http.request.uri.path, "/CFIDE") or starts_with(http.request.uri.path, "/owa") or starts_with(http.request.uri.path, "/Autodiscover") or ends_with(http.request.uri.path, ".php") or ends_with(http.request.uri.path, ".asp") or ends_with(http.request.uri.path, ".aspx") or ends_with(http.request.uri.path, ".jsp") or ends_with(http.request.uri.path, ".cgi") or ends_with(http.request.uri.path, ".bak") or ends_with(http.request.uri.path, ".sql") or ends_with(http.request.uri.path, ".env"))
EOF
}

# _detect_stack
# Echoes one of: nextjs | astro | sveltekit | remix | nuxt | vite | workers |
#                pages | wordpress | php | rails | django | dotnet | static | generic
_detect_stack() {
  if [[ -f "next.config.js" || -f "next.config.ts" || -f "next.config.mjs" ]]; then printf 'nextjs\n'; return; fi
  if [[ -f "astro.config.mjs" || -f "astro.config.ts" || -f "astro.config.js" ]]; then printf 'astro\n'; return; fi
  if [[ -f "svelte.config.js" || -f "svelte.config.ts" ]]; then printf 'sveltekit\n'; return; fi
  if [[ -f "remix.config.js" || -f "remix.config.ts" ]]; then printf 'remix\n'; return; fi
  if [[ -f "nuxt.config.js" || -f "nuxt.config.ts" ]]; then printf 'nuxt\n'; return; fi
  if [[ -f "vite.config.js" || -f "vite.config.ts" ]]; then printf 'vite\n'; return; fi
  if [[ -f "wp-config.php" ]]; then printf 'wordpress\n'; return; fi
  if [[ -f "composer.json" ]]; then printf 'php\n'; return; fi
  if [[ -f "Gemfile" ]]; then printf 'rails\n'; return; fi
  if [[ -f "manage.py" ]]; then printf 'django\n'; return; fi
  if find . -maxdepth 2 -name "*.csproj" -print -quit 2>/dev/null | grep -q .; then printf 'dotnet\n'; return; fi
  if [[ -f "wrangler.toml" || -f "wrangler.jsonc" ]]; then
    if grep -qE '^[[:space:]]*main[[:space:]]*=' wrangler.toml 2>/dev/null; then printf 'workers\n'; return; fi
    printf 'pages\n'; return
  fi
  if [[ -f "_headers" || -f "_redirects" ]]; then printf 'pages\n'; return; fi
  if [[ -f "index.html" ]]; then printf 'static\n'; return; fi
  printf 'generic\n'
}

# apply_rules_custom <zone_id>
# Deploys the foreign-tech custom rule. Idempotent by description tag.
apply_rules_custom() {
  local zone_id="$1"
  local phase="http_request_firewall_custom"
  local desc_tag="cloudflare-secure:foreign-tech"
  local stack
  stack="$(_detect_stack)"
  local expr
  expr="$(_foreign_tech_expression "$stack")"
  if [[ -z "$expr" ]]; then
    log_warn "rules" "expression" "Could not build foreign-tech expression for stack '${stack}'."
    return 0
  fi

  local target_rule
  target_rule="$(jq -n --arg desc "$desc_tag" --arg e "$expr" --arg s "$stack" '{
    description: $desc,
    expression: $e,
    action: "block",
    enabled: true,
    ref: ("snitch-cloudflare-foreign-tech-" + $s)
  }')"

  local existing cur_rules existing_rule new_rules
  existing="$(_get_phase_entrypoint "$zone_id" "$phase")"
  cur_rules="$(jq -c '.result.rules // []' <<<"${existing:-{}}" 2>/dev/null)"
  [[ -z "$cur_rules" || "$cur_rules" == "null" ]] && cur_rules='[]'
  existing_rule="$(jq -c --arg d "$desc_tag" '.[] | select(.description==$d)' <<<"$cur_rules" 2>/dev/null | head -n1)"

  if [[ -n "$existing_rule" ]]; then
    local cur_expr_hash tgt_expr_hash
    cur_expr_hash="$(jq -r '.expression' <<<"$existing_rule" | shasum 2>/dev/null | awk '{print $1}')"
    tgt_expr_hash="$(printf '%s' "$expr" | shasum 2>/dev/null | awk '{print $1}')"
    if [[ "$cur_expr_hash" == "$tgt_expr_hash" ]]; then
      log_ok "rules" "foreign-tech" "Foreign-tech custom rule already at target (stack: ${stack})."
      return 0
    fi
    new_rules="$(jq -c --arg d "$desc_tag" --argjson r "$target_rule" \
      '[ .[] | if .description==$d then $r else . end ]' <<<"$cur_rules")"
  else
    new_rules="$(jq -c --argjson r "$target_rule" '. + [$r]' <<<"$cur_rules")"
  fi

  if _put_phase_entrypoint "$zone_id" "$phase" "$new_rules"; then
    log_ok "rules" "foreign-tech" "Foreign-tech custom rule applied (stack: ${stack}, tag: ${desc_tag})."
  else
    log_fail "rules" "foreign-tech" "PUT entrypoint failed (status ${CFSEC_LAST_STATUS}). $(cf_last_error)"
    return 3
  fi
}

# apply_rules_bots <zone_id>
# Enable Bot Fight Mode; Pro+ recommend Super Bot Fight Mode (bot_management).
apply_rules_bots() {
  local zone_id="$1"
  local body cur
  body="$(cf_get "/zones/${zone_id}/settings/bot_fight_mode")" || cur=""
  cur="$(jq -r '.result.value // empty' <<<"${body:-{}}")"
  if [[ "$cur" == "on" ]]; then
    log_ok "bots" "bot-fight-mode" "Bot Fight Mode already on."
  else
    cf_patch "/zones/${zone_id}/settings/bot_fight_mode" '{"value":"on"}' >/dev/null && \
      log_ok "bots" "bot-fight-mode" "Bot Fight Mode set to on." || \
      log_fail "bots" "bot-fight-mode" "PATCH bot_fight_mode failed. $(cf_last_error)"
  fi
  if requires_tier "bots" "super-bot-fight-mode" "Super Bot Fight Mode is Pro+." "pro" "https://developers.cloudflare.com/bots/get-started/pro/"; then
    local bm
    bm="$(cf_get "/zones/${zone_id}/bot_management" 2>/dev/null)" || bm=""
    if [[ -n "$bm" ]]; then
      local sbfm
      sbfm="$(jq -r '.result.fight_mode // .result.enable_js // empty' <<<"$bm" 2>/dev/null)"
      if [[ "$sbfm" == "true" ]]; then
        log_ok "bots" "super-bot-fight-mode" "Super Bot Fight Mode already on."
      else
        cf_patch "/zones/${zone_id}/bot_management" '{"fight_mode":true,"enable_js":true,"optimize_wordpress":false}' >/dev/null && \
          log_ok "bots" "super-bot-fight-mode" "Super Bot Fight Mode enabled." || \
          log_warn "bots" "super-bot-fight-mode" "Could not PATCH bot_management; enable in dashboard."
      fi
    fi
  fi
}

# apply_rules <area> [args]
apply_rules() {
  local area="${1:-}"
  shift || true
  local zone_id
  zone_id="$(api_pick_zone)" || {
    log_fail "rules" "pick" "No zone selected."
    return 3
  }
  case "$area" in
    waf)   apply_rules_waf "$zone_id" ;;
    rules) apply_rules_custom "$zone_id" ;;
    bots)  apply_rules_bots "$zone_id" ;;
    all)
      apply_rules_waf "$zone_id"
      apply_rules_custom "$zone_id"
      apply_rules_bots "$zone_id"
      ;;
    *)
      log_fail "rules" "area" "Unknown apply_rules area: '${area}'. Valid: waf|rules|bots|all."
      return 2
      ;;
  esac
}
