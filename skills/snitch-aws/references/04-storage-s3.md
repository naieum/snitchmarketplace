# 04 — S3 storage

## Targets (every bucket; justify exceptions per-bucket)

| Target | Value |
|---|---|
| Public Access Block | ON, account + per-bucket, all 4 toggles |
| Default encryption | SSE-S3 minimum; SSE-KMS for sensitive |
| Versioning | enabled for mutable data |
| MFA Delete | production buckets with critical data |
| Bucket policy | `Deny` on `aws:SecureTransport=false`; deny unencrypted PUT |
| Server access logging | to a separate "log archive" bucket |
| Object Lock | immutable / regulatory data |
| Lifecycle rules | expire incomplete multipart uploads; transition cold data to IA / Glacier |

## Skill checks

- `state s3` digest: total buckets, with-full-PAB, with-default-encryption, with-versioning, with-MFA-Delete, with-access-logging, with-object-lock; account-level PAB.
- `apply s3` ensures account-level PAB fully ON; per-bucket PAB ON if missing; default encryption (SSE-S3) if missing.

## Public buckets

`apply s3` enables PAB on every bucket — including ones that **must** be public. If `bucket-pab` apply fails on a known-public bucket, that's expected. Move the public path behind CloudFront with OAC; CloudFront accesses S3 via the OAC, not as a public principal.

## Cross-account writes

- `s3:PutObject` from another account: prefer `bucket-owner-full-control` ACL or bucket policy requiring the canonical ID.
- Replication for DR: enable versioning + replication on source AND destination.

## Docs

- Bucket security: https://docs.aws.amazon.com/AmazonS3/latest/userguide/security.html
- PAB: https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html
- Object Lock: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html
