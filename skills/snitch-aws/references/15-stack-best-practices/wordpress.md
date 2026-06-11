# WordPress on AWS

## Paths

| Path | Use when |
|---|---|
| Lightsail (WordPress blueprint) | personal / small-biz; cheap, simple |
| ECS Fargate + EFS + Aurora MySQL Serverless v2 + CloudFront | production, autoscaling |
| Bitnami WordPress AMI on EC2 | works, but you own patching + HA |

## Hardening

- Always behind CloudFront with WAFv2 (managed sets + WordPress-specific rules).
- IP-allowlist `wp-admin`, `xmlrpc.php`, `wp-cron.php` (or block `xmlrpc.php` outright).
- S3 + CloudFront for media via WP Offload Media plugin.
- Disable file editing: `define('DISALLOW_FILE_EDIT', true);` in `wp-config.php`.
- Application passwords + 2FA plugin.
- Aurora Serverless v2 over single-AZ RDS for HA.

## Docs

- WordPress launch: https://aws.amazon.com/getting-started/hands-on/launch-wordpress-website/
- Lightsail WordPress: https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-tutorial-launching-and-configuring-wordpress.html
