# Spaces (S3-compatible)

S3-compatible at `https://<region>.digitaloceanspaces.com`. Use `aws-cli` or any S3 SDK with endpoint override.

The DO v2 API does **NOT** expose Spaces. Listing buckets, ACLs, CORS, lifecycle requires Spaces access keys (separate from API tokens).

```bash
export AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY"
export AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET"
aws s3api list-buckets --endpoint-url https://nyc3.digitaloceanspaces.com
```

## Hardening

| Item | Detail |
|---|---|
| Default to private | Use Spaces CDN with signed URLs for public reads. `public-read` ACL is rarely correct. |
| CORS | Never `AllowedOrigins: ["*"]` in prod. List specific origins. |
| Lifecycle | Expire incomplete multipart uploads after 7d (free space leak). |
| Bucket policy | Deny non-TLS access (`aws:SecureTransport: false`). See `templates/spaces-bucket-policy.starter.json`. |
| CDN endpoint | Custom subdomain + cert. Direct `.digitaloceanspaces.com` URLs leak the bucket name. |
| Key rotation | Rotate Spaces keys annually. One key per app. |
| Key scopes | Newer feature — scope keys to a single Space at generation. |
| Server access logging | Enable into a separate audit bucket if needed. |

## Common findings

| Status | Finding |
|---|---|
| 🟡 WARN | `public-read` ACL at bucket level (verify intent) |
| 🟡 WARN | CORS with `*` origin |
| 🟡 WARN | No bucket policy denying insecure transport |
| INFO | No lifecycle rule (multipart leak) |
| INFO | CDN endpoint without custom domain |

## Migration: S3 → Spaces

```bash
aws s3 sync s3://src-bucket/ s3://dst-bucket/ \
  --source-region us-east-1 \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

Or `rclone sync` for resumable, multi-source.

Egress: S3 charges $0.09/GB to internet; Spaces does not charge egress within ~1 TB / TB stored. Run the math first.
