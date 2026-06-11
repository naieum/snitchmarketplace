# lib/state_ec2.sh — EC2 state (instances, IMDSv2, EBS encryption, public IPs).
# Exports: run_state_ec2 [slice]
#   slice ∈ digest (default) | instances | volumes | full

run_state_ec2() {
  . "$LIB_DIR/_state_helpers.sh"
  _state_header_check || return $?
  local slice="${1:-digest}"
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local account region
  account="$(aws_pick_account)" || account="unknown"
  region="$(aws_pick_region)"

  case "$slice" in
    digest|instances|volumes|full) ;;
    *)
      printf '{"error":"unknown slice","code":"E_USAGE","got":"%s","valid":["digest","instances","volumes","full"]}\n' "$slice" >&2
      return 2 ;;
  esac

  local instances volumes default_enc kp asg_lts
  instances="$(aws_run_json ec2 describe-instances 2>/dev/null | jq '[(.Reservations // [])[].Instances[]?]' 2>/dev/null || printf '[]')"
  volumes="$(aws_run_json ec2 describe-volumes 2>/dev/null | jq '.Volumes // []' 2>/dev/null || printf '[]')"
  default_enc="$(aws_run_json ec2 get-ebs-encryption-by-default 2>/dev/null | jq '{EbsEncryptionByDefault: (.EbsEncryptionByDefault // null)}' 2>/dev/null || printf '{}')"
  kp="$(aws_run_json ec2 describe-key-pairs 2>/dev/null | jq '.KeyPairs // []' 2>/dev/null || printf '[]')"
  asg_lts="$(aws_run_json ec2 describe-launch-templates 2>/dev/null | jq '.LaunchTemplates // []' 2>/dev/null || printf '[]')"

  local schema="awssec.state-ec2.${slice}"

  case "$slice" in
    digest)
      jq -n \
        --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson instances "$instances" --argjson volumes "$volumes" \
        --argjson default_enc "$default_enc" --argjson kp "$kp" \
        --argjson asg_lts "$asg_lts" \
        '{
          schema: $schema, schema_version: 1, generated_at: $ts,
          tool: "state-ec2", slice: $slice,
          account_id: $account, region: $region,
          instances_summary: {
            total: ($instances | length),
            running: ($instances | map(select(.State.Name == "running")) | length),
            stopped: ($instances | map(select(.State.Name == "stopped")) | length),
            with_public_ip: ($instances | map(select(.PublicIpAddress != null)) | length),
            imdsv2_required: ($instances | map(select(.MetadataOptions.HttpTokens == "required")) | length),
            imdsv1_allowed: ($instances | map(select(.MetadataOptions.HttpTokens == "optional" or .MetadataOptions.HttpTokens == null)) | length)
          },
          volumes_summary: {
            total: ($volumes | length),
            encrypted: ($volumes | map(select(.Encrypted == true)) | length),
            unencrypted: ($volumes | map(select(.Encrypted != true)) | length),
            unattached: ($volumes | map(select((.Attachments // []) | length == 0)) | length)
          },
          ebs_default_encryption: $default_enc,
          key_pairs_count: ($kp | length),
          launch_templates_count: ($asg_lts | length),
          hint: "for full data, run: state ec2 [instances|volumes|full]"
        }'
      ;;
    instances)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson instances "$instances" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-ec2", slice: $slice,
           account_id: $account, region: $region, instances: $instances }'
      ;;
    volumes)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson volumes "$volumes" --argjson default_enc "$default_enc" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-ec2", slice: $slice,
           account_id: $account, region: $region,
           volumes: $volumes, ebs_default_encryption: $default_enc }'
      ;;
    full)
      jq -n --arg ts "$ts" --arg schema "$schema" --arg slice "$slice" \
        --arg account "$account" --arg region "$region" \
        --argjson instances "$instances" --argjson volumes "$volumes" \
        --argjson default_enc "$default_enc" --argjson kp "$kp" \
        --argjson asg_lts "$asg_lts" \
        '{ schema: $schema, schema_version: 1, generated_at: $ts,
           tool: "state-ec2", slice: $slice,
           account_id: $account, region: $region,
           instances: $instances, volumes: $volumes,
           ebs_default_encryption: $default_enc,
           key_pairs: $kp, launch_templates: $asg_lts }'
      ;;
  esac
}
