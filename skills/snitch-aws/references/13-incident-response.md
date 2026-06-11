# 13 — Incident response

## First 15 minutes

1. **Confirm the symptom.** CloudWatch / CloudTrail logs, GuardDuty findings, Security Hub findings.
2. **Identify blast radius.** Which roles/users/IPs/regions?
3. **Contain.** `panic revoke-key`, `panic quarantine-role`, `panic block-ip`. Each action recorded; `panic restore` rolls back.
4. **Preserve evidence.** Snapshot affected EBS volumes; export CloudTrail logs to a separate "forensics" bucket; capture `aws cloudtrail lookup-events` for the relevant window.
5. **Communicate.** Engage your team; if Business+ Support, AWS Support.

## Common incidents

### Compromised access key

```
bash snitch-aws.sh events 24h | jq '.events[] | select(.EventName=="ConsoleLogin" or .EventName=="CreateAccessKey")'
bash snitch-aws.sh panic revoke-key AKIA...
# Rotate any service that used that key.
```

### Compromised IAM role

```
bash snitch-aws.sh panic quarantine-role <role-name>
# Review CloudTrail by Username / sourceIPAddress; identify which sessions used the role.
```

### S3 data exfil

- `state s3` digest — new public buckets / new bucket policies?
- CloudTrail `PutBucketPolicy`, `DeletePublicAccessBlock` events in last N hours.
- If a bucket leaked: re-block public access first (`apply s3` re-blocks at account level), then investigate.

### Crypto-mining EC2

- GuardDuty raises `CryptoCurrency:EC2/BitcoinTool.B!DNS` and similar.
- Quarantine: stop instance; detach role.
- Rotate any credentials the instance role had access to.

## Post-incident

- Write a timeline (CloudTrail makes this mechanical).
- Add a Config rule + alarm for the next instance of the same event class.
- Update SCPs / role policies to prevent the action that enabled the incident.

## Docs

- AWS IR guide: https://docs.aws.amazon.com/whitepapers/latest/aws-security-incident-response-guide/welcome.html
- GuardDuty findings: https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_finding-types-active.html
