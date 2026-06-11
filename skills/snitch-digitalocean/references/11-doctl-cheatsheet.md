# doctl cheatsheet

Install: `brew install doctl` / `snap install doctl` / GitHub releases.

## Auth

```bash
doctl auth init                           # interactive token entry
doctl auth init --context dosec-secure    # named context
doctl auth list
doctl auth switch --context default
doctl account get
```

## Droplets

```bash
doctl compute droplet list --output json
doctl compute droplet get <id>
doctl compute droplet-action enable-backups <id>
doctl compute droplet-action enable-monitoring <id>
doctl compute droplet-action enable-ipv6 <id>
doctl compute droplet-action snapshot <id> --snapshot-name "pre-deploy-$(date +%F)"
```

## Cloud Firewalls

```bash
doctl compute firewall list
doctl compute firewall create \
  --name "web-tier" \
  --inbound-rules "protocol:tcp,ports:80,address:0.0.0.0/0,address:::/0" \
  --inbound-rules "protocol:tcp,ports:443,address:0.0.0.0/0,address:::/0" \
  --outbound-rules "protocol:tcp,ports:1-65535,address:0.0.0.0/0,address:::/0" \
  --tag-names web
```

## Managed Databases

```bash
doctl databases list
doctl databases firewalls list <id>
doctl databases firewalls append <id> --rule "tag:web-tier"
doctl databases firewalls append <id> --rule "ip_addr:1.2.3.4"
doctl databases connection <id> --format URI
```

## Spaces

`doctl` has limited Spaces commands; use `aws-cli` for bucket-level ops.

```bash
doctl compute cdn list

export AWS_ACCESS_KEY_ID="$DOSEC_SPACES_KEY"
export AWS_SECRET_ACCESS_KEY="$DOSEC_SPACES_SECRET"
aws s3api list-buckets --endpoint-url https://nyc3.digitaloceanspaces.com
aws s3api put-bucket-acl --bucket my-bucket --acl private --endpoint-url https://nyc3.digitaloceanspaces.com
```

## App Platform

```bash
doctl apps list
doctl apps spec get <id>
doctl apps update <id> --spec app.yaml      # idempotent
doctl apps create-deployment <id>
```

## Kubernetes

```bash
doctl kubernetes cluster list
doctl kubernetes cluster kubeconfig save <id>
doctl kubernetes cluster upgrade <id> --version <v>
```

## Container Registry

```bash
doctl registry get
doctl registry repository list
doctl registry login
doctl registry garbage-collection start
```

## DNS

```bash
doctl compute domain list
doctl compute domain records list <domain>
doctl compute domain records create <domain> --record-type CAA --record-name @ \
  --record-data "0 issue \"letsencrypt.org\""
```

## Monitoring + Billing

```bash
doctl monitoring alert list
doctl balance get
doctl invoice list
doctl billing-history list
```
