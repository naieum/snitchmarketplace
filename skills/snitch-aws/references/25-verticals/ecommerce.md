# Vertical — E-commerce on AWS

## Architecture

| Layer | Choice |
|---|---|
| Public path | CloudFront → ALB → Fargate (or Amplify Hosting / Lambda) |
| DB | Aurora Postgres / MySQL with Multi-AZ + automated backups + 35d retention |
| Cache / sessions | ElastiCache Redis with TLS + AUTH |
| Search | OpenSearch Serverless or Algolia |
| Media | S3 + CloudFront with OAC; image opt via CloudFront Functions or Lambda@Edge |
| Payments | Stripe / Adyen — secrets in Secrets Manager |
| WAF | AWS managed core + IP reputation + rate-limit (300/min) + bot management for high traffic |

## Hot spots

- **PCI scope**: keep card data off-environment via payment provider. If you must touch PAN, isolate to a separate account/VPC with restricted IAM and CloudTrail.
- **Cart abandonment / checkout DDoS**: Shield Advanced ($3000/mo) + WAF rate-limit.
- **Inventory race conditions**: DynamoDB conditional writes or Postgres `SELECT FOR UPDATE`.
