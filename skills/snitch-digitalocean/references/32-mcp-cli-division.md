# MCP / CLI division

DO's developer tooling is **CLI-first**. `doctl` is primary. As of 2026, no widely-adopted official DO MCP exists.

## Today

| Use case | Tool |
|---|---|
| Inventory reads | This skill (wraps `doctl --output json` + REST) |
| Mutations | `doctl` directly OR `fix <area>` |
| Searching DO docs | `WebFetch` / `WebSearch` |
| One-off shell tasks | `doctl` |

## When a DO MCP appears

1. Skill detects via `DOSEC_MCP_PRESENT=1` (set by user).
2. Prefer typed MCP tools over wrapped CLI for inventory reads.
3. Mutations stay split: simple via MCP, complex via `fix <area>`.

## Direct `doctl` examples

```bash
doctl compute droplet list --output json
doctl compute droplet create web-1 --image ubuntu-22-04-x64 --size s-1vcpu-1gb --region nyc3
doctl databases create my-pg --engine pg --version 15 --region nyc3 --size db-s-1vcpu-1gb
```

## Reach for the skill when

- You want a digest smaller and more semantic than `doctl ... | jq`.
- You want idempotent hardening (`fix <area>`).
- You want drift detection (`verify`).
- You want incident-response primitives (`panic <action>`).

## What this skill does NOT replace

- `kubectl` for DOKS workloads.
- `aws-cli` / `s3cmd` for Spaces object-level operations.
- `terraform` / `pulumi` for IaC. The skill emits HCL via `terraform`, but it's a starting point.
