# 11 — AWS CLI cheatsheet

## Identity / auth

```bash
aws sts get-caller-identity
aws configure list                      # show resolved creds source
aws configure list-profiles
AWS_PROFILE=foo aws sts get-caller-identity
```

## IAM

```bash
aws iam get-account-summary
aws iam get-account-password-policy
aws iam list-users
aws iam list-access-keys --user-name <user>
aws iam get-credential-report
aws accessanalyzer list-analyzers
aws accessanalyzer create-analyzer --analyzer-name account --type ACCOUNT
```

## S3

```bash
aws s3api list-buckets
aws s3control get-public-access-block --account-id <acct>
aws s3api get-public-access-block --bucket <b>
aws s3api get-bucket-policy --bucket <b>
aws s3api get-bucket-encryption --bucket <b>
aws s3api put-public-access-block --bucket <b> \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## EC2 / VPC

```bash
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,MetadataOptions.HttpTokens]'
aws ec2 modify-instance-metadata-options --instance-id <id> --http-tokens required --http-endpoint enabled
aws ec2 enable-ebs-encryption-by-default
aws ec2 describe-security-groups
aws ec2 describe-flow-logs
```

## RDS

```bash
aws rds describe-db-instances
aws rds modify-db-instance --db-instance-identifier <id> --deletion-protection
aws rds modify-db-instance --db-instance-identifier <id> --backup-retention-period 7 --apply-immediately
aws rds describe-db-clusters
```

## Lambda

```bash
aws lambda list-functions
aws lambda get-function-url-config --function-name <fn>
aws lambda update-function-url-config --function-name <fn> --auth-type AWS_IAM
```

## CloudFront / WAF

```bash
aws cloudfront list-distributions
aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1
aws wafv2 list-web-acls --scope REGIONAL
```

## CloudTrail / Config / GuardDuty

```bash
aws cloudtrail describe-trails
aws cloudtrail update-trail --name <t> --is-multi-region-trail --enable-log-file-validation
aws configservice describe-configuration-recorders
aws configservice describe-configuration-recorder-status
aws guardduty list-detectors
aws guardduty create-detector --enable
aws securityhub describe-hub
aws securityhub enable-security-hub --enable-default-standards
```

## Cost / Budgets

```bash
aws ce get-cost-and-usage --time-period Start=2024-12-01,End=2025-01-01 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
aws budgets describe-budgets --account-id <acct>
aws ce get-anomaly-monitors
```
