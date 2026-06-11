# MCP / CLI division of labor

When the Azure MCP is loaded, prefer it for typed inventory; use this skill (`bash snitch-azure.sh ...`) for security-shape state and mutations.

## Use Azure MCP for

| Operation |
|---|
| List subscriptions |
| List resource groups |
| List resources by type |
| Read tags |
| Search Microsoft Learn / Azure docs |

If the Azure MCP isn't loaded, this skill works for everything via `az`.

## Use this skill for

- Security-shape state the MCP doesn't expose: HTTPS-only flags, TLS minimum, RBAC vs policy mode, NSG mgmt-port rules, Defender plan tier, Conditional Access presence, App Service SCM basic-auth state.
- Mutations: `fix <area>`, `panic <action>`.
- Offline tools: `detect`, `fit-matrix`, `stack-docs`, `score`.

## `AZSEC_MCP_PRESENT`

Set `AZSEC_MCP_PRESENT=1` when the Azure MCP is loaded. `doctor` surfaces this.

If unset, `doctor` recommends installing the Azure MCP. Skill works either way.

## MCP-only ops

The skill never calls the MCP from bash. If the MCP is loaded and the op belongs to it (typed inventory), the agent calls the MCP directly — not this skill.
