# lib/extensions.sh — read-only inventory of the agent extension surface.
# Answers "what is loaded for this project, and what does it cost?" for the three
# surfaces a repo can scope: skills, plugins, MCP servers.
#
# Exports:
#   run_extensions — entrypoint. Emits one JSON document on stdout.
#
# Cost model (all figures are ESTIMATES; say so wherever they are reported):
#   - Skill listing entries are resident in every turn. est_tokens = (name+desc+6)/4.
#     Claude Code budgets the whole listing at ~1% of the context window; past that
#     entries get truncated and skill routing degrades.
#   - MCP tool schemas are deferred behind ToolSearch by default — the name is
#     resident, the schema is not. This inventory therefore reports no token figure
#     for MCP servers. Disabling one is decluttering, not a token saving.
#   - Plugin cost comes from `claude plugin details`, which reports its own
#     always-on and on-invoke numbers. When the CLI is absent or its output does not
#     parse, cost_source is "unavailable" and no number is invented.
#
# This file reads. It never writes settings, never starts an MCP server, and never
# calls a mutating `claude` subcommand.

EXT_DEFAULT_WINDOW=200000   # assumed context window when the caller gives none
EXT_LISTING_BUDGET_PCT=1    # Claude Code's skill-listing budget, in percent
EXT_CLI_TIMEOUT=15          # seconds allowed per `claude plugin details` call

# --- small helpers ----------------------------------------------------------
# Read one key from a settings file; empty when the file or key is absent.
_ext_settings_get() {
  local file="$1" filter="$2"
  [[ -f "$file" ]] || return 0
  jq -c "$filter // empty" "$file" 2>/dev/null || true
}

# The project key in ~/.claude.json is the path Claude Code recorded, which need not be
# $PWD's spelling: on a case-insensitive filesystem $PWD can carry the casing the user
# typed, and a symlinked checkout differs again. Try the literal path, then the physical
# one, then fall back to a case-insensitive match — an unmatched key would silently report
# every disabled server as enabled.
_ext_project_key() {
  local f="$1" p
  for p in "$PWD" "$(pwd -P 2>/dev/null)"; do
    [[ -z "$p" ]] && continue
    if jq -e --arg k "$p" 'has("projects") and (.projects | has($k))' "$f" >/dev/null 2>&1; then
      printf '%s' "$p"; return 0
    fi
  done
  jq -r --arg a "$PWD" --arg b "$(pwd -P 2>/dev/null)" '
    (.projects // {}) | keys[]
    | select(ascii_downcase == ($a | ascii_downcase) or ascii_downcase == ($b | ascii_downcase))' \
    "$f" 2>/dev/null | head -1
}

# Run a command with a wall-clock bound so a wedged CLI cannot hang the skill.
_ext_run_bounded() {
  if command -v perl >/dev/null 2>&1; then
    perl -e 'my $t = shift; alarm $t; exec @ARGV or exit 127;' "$EXT_CLI_TIMEOUT" "$@" 2>/dev/null
  else
    "$@" 2>/dev/null
  fi
}

# --- skills -----------------------------------------------------------------

# Parse one SKILL.md's frontmatter → TSV: scope \t name \t chars \t user_invoked \t path
_ext_parse_skill() {
  local file="$1" scope="$2"
  awk -v scope="$scope" -v path="$file" '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function unquote(s) {
      if (s ~ /^".*"$/ || s ~ /^'\''.*'\''$/) { s = substr(s, 2, length(s) - 2) }
      return s
    }
    NR == 1 {
      if ($0 !~ /^---[ \t]*$/) { bad = 1; exit }
      infm = 1; next
    }
    infm && /^---[ \t]*$/ { infm = 0; exit }
    infm {
      if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) {
        key = $0; sub(/:.*/, "", key)
        val = $0; sub(/^[^:]*:[ \t]*/, "", val)
        cur = key
        if (key == "name") { name = trim(val) }
        else if (key == "description") { desc = trim(val) }
        else if (key == "disable-model-invocation") { if (trim(val) ~ /true/) ui = 1 }
      } else if (cur == "description" && $0 ~ /^[ \t]/) {
        desc = desc " " trim($0)
      }
    }
    END {
      if (bad) { exit }
      if (name == "") {
        n = split(path, parts, "/")
        name = parts[n - 1]
      }
      desc = unquote(trim(desc))
      chars = length(name) + length(desc)
      printf "%s\t%s\t%d\t%s\t%s\n", scope, name, chars, (ui ? "true" : "false"), path
    }
  ' "$file" 2>/dev/null
}

# Walk a skills root. Scope is refined per-path (account-synced skills sit under synced/).
_ext_scan_skill_root() {
  local root="$1" base_scope="$2" f scope
  [[ -d "$root" ]] || return 0
  while IFS= read -r f; do
    case "$f" in
      */.trash/*) continue ;;
    esac
    scope="$base_scope"
    case "$f" in
      */skills/synced/*) scope="synced" ;;
    esac
    _ext_parse_skill "$f" "$scope"
  done < <(find "$root" -maxdepth 4 -name SKILL.md -type f 2>/dev/null | sort)
}

_ext_skills_tsv() {
  _ext_scan_skill_root "$HOME/.claude/skills" "user"
  _ext_scan_skill_root "$PWD/.claude/skills" "project"
}

# --- plugins ----------------------------------------------------------------

# Parse `claude plugin details <id>` → JSON. Human output, so parse defensively:
# anything unrecognised leaves the field null rather than guessing.
_ext_plugin_details() {
  local id="$1" out
  out="$(_ext_run_bounded claude plugin details "$id")" || true
  if [[ -z "$out" ]]; then
    jq -n --arg id "$id" '{id: $id, cost_source: "unavailable"}'
    return 0
  fi
  printf '%s\n' "$out" | awk -v id="$id" '
    # A count in parentheses, e.g. "Skills (13)".
    function count(line) {
      if (match(line, /\([0-9]+\)/) == 0) return ""
      return substr(line, RSTART + 1, RLENGTH - 2) + 0
    }
    # A token figure, e.g. "~1,769 tok". The CLI abbreviates larger values ("~4.8k"),
    # and reading 4.8k as 48 would be worse than reporting nothing — so abbreviated
    # or unrecognised figures return "" and the field is omitted entirely.
    function toks(line) {
      if (match(line, /~?[0-9][0-9,]*[ \t]*tok/) == 0) return ""
      s = substr(line, RSTART, RLENGTH)
      gsub(/[^0-9]/, "", s)
      return (s == "" ? "" : s + 0)
    }
    /^[ \t]*Skills \(/       { if (skills == "") skills = count($0); next }
    /^[ \t]*Agents \(/       { if (agents == "") agents = count($0); next }
    /^[ \t]*Hooks \(/        { if (hooks  == "") hooks  = count($0); next }
    /^[ \t]*MCP servers \(/  { if (mcp    == "") mcp    = count($0); next }
    /^[ \t]*LSP servers \(/  { if (lsp    == "") lsp    = count($0); next }
    /^[ \t]*Always-on:/      { if (always == "") always = toks($0); next }
    END {
      # "partial" tells the caller a field is missing because the output did not parse,
      # not because the plugin has none of that component.
      complete = (always != "" && skills != "" && mcp != "")
      printf "{\"id\":\"%s\",\"cost_source\":\"%s\"", id, (complete ? "claude-cli" : "claude-cli-partial")
      if (always != "") printf ",\"always_on_tokens\":%d", always
      if (skills != "") printf ",\"skills\":%d", skills
      if (agents != "") printf ",\"agents\":%d", agents
      if (hooks  != "") printf ",\"hooks\":%d", hooks
      if (mcp    != "") printf ",\"mcp_servers\":%d", mcp
      if (lsp    != "") printf ",\"lsp_servers\":%d", lsp
      printf "}\n"
    }
  '
}

# --- entrypoint -------------------------------------------------------------
run_extensions() {
  local window="$EXT_DEFAULT_WINDOW" use_cli="true"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --window) window="${2:-$EXT_DEFAULT_WINDOW}"; shift 2 ;;
      --no-cli) use_cli="false"; shift ;;
      *) printf 'error: unknown extensions flag "%s"\n' "$1" >&2; return 2 ;;
    esac
  done
  case "$window" in
    ''|*[!0-9]*) printf 'error: --window must be a positive integer\n' >&2; return 2 ;;
  esac

  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || printf 'unknown')"
  local cwd="$PWD"
  local user_settings="$HOME/.claude/settings.json"
  local proj_settings="$PWD/.claude/settings.json"
  local local_settings="$PWD/.claude/settings.local.json"
  local claude_json="$HOME/.claude.json"
  local policy_settings=""
  for p in "/Library/Application Support/ClaudeCode/managed-settings.json" \
           "/etc/claude-code/managed-settings.json"; do
    [[ -f "$p" ]] && { policy_settings="$p"; break; }
  done

  # -- skills
  local skills_tsv; skills_tsv="$(_ext_skills_tsv)"
  local skills_json
  skills_json="$(printf '%s' "$skills_tsv" | jq -R -s -c '
    [ split("\n")[] | select(length > 0) | split("\t")
      | { scope: .[0], name: .[1],
          est_listing_tokens: ((((.[2] | tonumber) + 6) / 4) | floor),
          user_invoked: (.[3] == "true"), path: .[4] } ]
    | sort_by(-.est_listing_tokens)')"
  [[ -z "$skills_json" ]] && skills_json='[]'

  # -- current overrides across the settings cascade (user < project < local < policy)
  local ov_user ov_proj ov_local ov_policy
  ov_user="$(_ext_settings_get "$user_settings" '.skillOverrides')";   ov_user="${ov_user:-{\}}"
  ov_proj="$(_ext_settings_get "$proj_settings" '.skillOverrides')";   ov_proj="${ov_proj:-{\}}"
  ov_local="$(_ext_settings_get "$local_settings" '.skillOverrides')"; ov_local="${ov_local:-{\}}"
  ov_policy="$(_ext_settings_get "$policy_settings" '.skillOverrides')"; ov_policy="${ov_policy:-{\}}"

  local pl_user pl_proj pl_local pl_policy
  pl_user="$(_ext_settings_get "$user_settings" '.enabledPlugins')";   pl_user="${pl_user:-{\}}"
  pl_proj="$(_ext_settings_get "$proj_settings" '.enabledPlugins')";   pl_proj="${pl_proj:-{\}}"
  pl_local="$(_ext_settings_get "$local_settings" '.enabledPlugins')"; pl_local="${pl_local:-{\}}"
  pl_policy="$(_ext_settings_get "$policy_settings" '.enabledPlugins')"; pl_policy="${pl_policy:-{\}}"

  # Effective values, and which source won — the agent needs the source to know
  # which file a change has to land in to actually take effect.
  local effective_overrides effective_plugins
  effective_overrides="$(jq -n -c \
    --argjson u "$ov_user" --argjson p "$ov_proj" --argjson l "$ov_local" --argjson y "$ov_policy" \
    '[ { s: "user", v: $u }, { s: "project", v: $p }, { s: "local", v: $l }, { s: "policy", v: $y } ]
     | reduce .[] as $src ({}; . + ($src.v | with_entries(.value = { value: .value, source: $src.s })))')"
  effective_plugins="$(jq -n -c \
    --argjson u "$pl_user" --argjson p "$pl_proj" --argjson l "$pl_local" --argjson y "$pl_policy" \
    '[ { s: "user", v: $u }, { s: "project", v: $p }, { s: "local", v: $l }, { s: "policy", v: $y } ]
     | reduce .[] as $src ({}; . + ($src.v | with_entries(.value = { value: .value, source: $src.s })))')"

  # -- plugin inventory + cost for the ones actually on
  local plugin_details='[]' pid
  if [[ "$use_cli" == "true" ]] && command -v claude >/dev/null 2>&1; then
    local details=()
    while IFS= read -r pid; do
      [[ -z "$pid" ]] && continue
      details+=("$(_ext_plugin_details "$pid")")
    done < <(printf '%s' "$effective_plugins" | jq -r 'to_entries[] | select(.value.value == true) | .key')
    if [[ ${#details[@]} -gt 0 ]]; then
      plugin_details="$(printf '%s\n' "${details[@]}" | jq -s -c '.')"
    fi
  fi

  # -- MCP servers, by scope
  local mcp_user_names mcp_local_names mcp_project_names mcp_disabled
  mcp_user_names="$(_ext_settings_get "$claude_json" '[.mcpServers // {} | keys[]]')"
  mcp_user_names="${mcp_user_names:-[]}"
  local project_key=""
  [[ -f "$claude_json" ]] && project_key="$(_ext_project_key "$claude_json")"
  mcp_local_names="$(jq -c --arg k "$project_key" '[.projects[$k].mcpServers // {} | keys[]]' "$claude_json" 2>/dev/null)"
  mcp_local_names="${mcp_local_names:-[]}"
  mcp_disabled="$(jq -c --arg k "$project_key" '.projects[$k].disabledMcpServers // []' "$claude_json" 2>/dev/null)"
  mcp_disabled="${mcp_disabled:-[]}"
  mcp_project_names="$(_ext_settings_get "$PWD/.mcp.json" '[.mcpServers // {} | keys[]]')"
  mcp_project_names="${mcp_project_names:-[]}"

  local mcpjson_disabled mcpjson_enabled mcpjson_all
  mcpjson_disabled="$(_ext_settings_get "$local_settings" '.disabledMcpjsonServers')"
  mcpjson_disabled="${mcpjson_disabled:-[]}"
  mcpjson_enabled="$(_ext_settings_get "$local_settings" '.enabledMcpjsonServers')"
  mcpjson_enabled="${mcpjson_enabled:-[]}"
  mcpjson_all="$(_ext_settings_get "$proj_settings" '.enableAllProjectMcpServers')"
  mcpjson_all="${mcpjson_all:-false}"

  local project_entry="false"
  [[ -n "$project_key" ]] && project_entry="true"

  local mcp_json
  mcp_json="$(jq -n -c \
    --argjson user "$mcp_user_names" --argjson local "$mcp_local_names" \
    --argjson project "$mcp_project_names" --argjson disabled "$mcp_disabled" \
    --argjson jdisabled "$mcpjson_disabled" --argjson jenabled "$mcpjson_enabled" \
    '[ ($user   | map({ name: ., scope: "user" })),
       ($local  | map({ name: ., scope: "local" })),
       ($project| map({ name: ., scope: "project-mcp-json" })) ]
     | add
     | map(. as $s | $s + {
         resident_tools: "deferred",
         disabled_for_project:
           (if $s.scope == "project-mcp-json"
            then ($jdisabled | index($s.name) != null)
            else ($disabled  | index($s.name) != null) end),
         approved: (if $s.scope == "project-mcp-json"
                    then ($jenabled | index($s.name) != null) else null end)
       })
     | sort_by(.scope, .name)')"

  local budget=$(( window / 100 * EXT_LISTING_BUDGET_PCT ))

  jq -n \
    --arg ts "$ts" \
    --arg cwd "$cwd" \
    --arg policy_settings "$policy_settings" \
    --arg project_key "$project_key" \
    --argjson window "$window" \
    --argjson budget "$budget" \
    --argjson skills "$skills_json" \
    --argjson plugins "$effective_plugins" \
    --argjson plugin_details "$plugin_details" \
    --argjson mcp "$mcp_json" \
    --argjson overrides "$effective_overrides" \
    --argjson project_entry "$project_entry" \
    --argjson mcpjson_all "$mcpjson_all" \
    --arg cli "$( command -v claude >/dev/null 2>&1 && printf 'true' || printf 'false' )" \
    '{
      schema: "snitch-devready.extensions",
      schema_version: 1,
      generated_at: $ts,
      cwd: $cwd,
      evidence: "presence and estimates only — token figures are approximations, and MCP tool schemas are deferred so no MCP token cost is reported",
      host: {
        claude_cli: ($cli == "true"),
        policy_settings: (if $policy_settings == "" then null else $policy_settings end),
        project_entry_in_claude_json: $project_entry,
        project_key: (if $project_key == "" then null else $project_key end)
      },
      skills: {
        scope_note: "skills installed under ~/.claude/skills and ./.claude/skills; skills delivered by a plugin are counted in plugins.details, not here",
        count: ($skills | length),
        est_listing_tokens: ([$skills[].est_listing_tokens] | add // 0),
        listing_budget_tokens: $budget,
        assumed_context_window: $window,
        items: $skills
      },
      totals: {
        note: "the resident listing is local skills plus the always-on cost of each enabled plugin; it excludes CLAUDE.md, hook output and non-deferred MCP schemas, so treat it as a floor — /context is the exact live measurement",
        skills_listing_tokens: ([$skills[].est_listing_tokens] | add // 0),
        plugin_always_on_tokens: ([$plugin_details[] | .always_on_tokens // empty] | add // 0),
        est_always_on_tokens: (([$skills[].est_listing_tokens] | add // 0)
                               + ([$plugin_details[] | .always_on_tokens // empty] | add // 0)),
        listing_budget_tokens: $budget,
        over_budget_by: ((([$skills[].est_listing_tokens] | add // 0)
                          + ([$plugin_details[] | .always_on_tokens // empty] | add // 0)) - $budget),
        plugin_cost_complete: (([$plugin_details[] | select(.cost_source != "claude-cli")] | length) == 0),
        plugin_cost_unknown_for: [$plugin_details[] | select(.cost_source != "claude-cli") | .id]
      },
      plugins: {
        effective: $plugins,
        details: $plugin_details
      },
      mcp: {
        deferred_by_default: true,
        enable_all_project_mcp_servers: $mcpjson_all,
        servers: $mcp
      },
      skill_overrides: $overrides
    }'
}
