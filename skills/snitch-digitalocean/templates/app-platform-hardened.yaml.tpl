# DigitalOcean App Platform hardened spec template.
# Apply with: doctl apps create --spec app.yaml
# Replace ${...} placeholders.

name: ${APP_NAME}
region: nyc

# Domains served — App Platform manages the certs automatically (Let's Encrypt).
domains:
  - domain: ${PRIMARY_DOMAIN}
    type: PRIMARY
    zone: ${PRIMARY_DOMAIN}
  - domain: ${ALT_DOMAIN}
    type: ALIAS
    zone: ${PRIMARY_DOMAIN}

# Account-level ingress alerts.
alerts:
  - rule: DEPLOYMENT_FAILED
    disabled: false
  - rule: DOMAIN_FAILED
    disabled: false

services:
  - name: web
    instance_size_slug: basic-xs
    instance_count: 2
    http_port: 8080
    source_dir: /
    build_command: ${BUILD_CMD}
    run_command: ${RUN_CMD}
    health_check:
      http_path: /healthz
      initial_delay_seconds: 30
      period_seconds: 30
      timeout_seconds: 5
      success_threshold: 1
      failure_threshold: 3
    routes:
      - path: /
    envs:
      - key: NODE_ENV
        scope: RUN_TIME
        value: production
        type: GENERAL
      - key: DATABASE_URL
        scope: RUN_AND_BUILD_TIME
        type: SECRET
        value: ${DATABASE_URL_SECRET}
      - key: SESSION_SECRET
        scope: RUN_TIME
        type: SECRET
        value: ${SESSION_SECRET_VALUE}
      - key: REDIS_URL
        scope: RUN_TIME
        type: SECRET
        value: ${REDIS_URL_SECRET}

# Worker component for background jobs (queue consumers, etc.).
workers:
  - name: queue-worker
    instance_size_slug: basic-xs
    instance_count: 1
    source_dir: /
    run_command: ${WORKER_CMD}
    envs:
      - key: DATABASE_URL
        scope: RUN_TIME
        type: SECRET
        value: ${DATABASE_URL_SECRET}

# Database link (Managed DB attached to the app).
databases:
  - name: db
    engine: PG
    production: true
    cluster_name: ${DB_CLUSTER_NAME}
    db_name: ${DB_NAME}
    db_user: ${DB_USER}
