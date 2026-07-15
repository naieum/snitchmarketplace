# MCP Adapter — Spec

This document specifies how to package Snitch: Marketing as a Model Context Protocol (MCP) server, exposing the audit workflow as MCP tool calls suitable for tools that don't natively support markdown skill bundles.

> **Status: Specification only.** The MCP server itself is not implemented in this bundle. This document defines the contract; an implementation lives outside this skill bundle (a separate Node.js / TypeScript project that imports this skill bundle as data).

## Why an MCP adapter

Some agent surfaces consume MCP servers more naturally than skill bundles:

- **Zed editor** — first-class MCP integration; loads servers from `~/.config/zed/settings.json`.
- **Claude Desktop** — MCP server slots in `~/Library/Application Support/Claude/claude_desktop_config.json`.
- **Custom agent harnesses** — bespoke apps using Anthropic's SDK with `tools` parameter populated from MCP discovery.
- **OpenAI MCP support** — emerging; mirrors Anthropic's adapter shape.

The skill bundle pattern (markdown + on-demand-loaded categories) doesn't fit cleanly here. Tools want function calls with structured I/O.

## Server architecture

The MCP server wraps the skill bundle and exposes ~6 tools mapping to the SKILL.md workflow steps.

```
┌────────────────────────────────────────────┐
│ Snitch: Marketing MCP Server               │
│ (Node.js / TypeScript)                     │
│                                            │
│ Loads at startup:                          │
│   ./SKILL.md                               │
│   ./categories/*.md                        │
│   ./references/*.md                        │
│   ./souls/*.json                           │
│                                            │
│ Exposes MCP tools:                         │
│   • detect_site_context                    │
│   • brand_maturity_check                   │
│   • niche_competitor_research              │
│   • run_category_audit                     │
│   • generate_report                        │
│   • generate_strategic_recommendations     │
└────────────────────────────────────────────┘
```

## Tool 1: `detect_site_context`

Maps to STEP 0 + STEP 0.5.

```json
{
  "name": "detect_site_context",
  "description": "Detect audit mode (source/crawl), stack, and site context",
  "inputSchema": {
    "type": "object",
    "properties": {
      "workingDirectory": {"type": "string", "description": "Absolute path to source mode working directory"},
      "url": {"type": "string", "description": "Target URL for crawl mode"}
    }
  }
}
```

**Returns**: `{ mode, stack, siteContext: { purpose, businessModel, primaryConversion, audience, criticalSurfaces, nonCriticalSurfaces } }`

## Tool 2: `brand_maturity_check`

Maps to STEP 0.6.

```json
{
  "name": "brand_maturity_check",
  "description": "Classify brand maturity per off-site channel (cats 66-81)",
  "inputSchema": {
    "type": "object",
    "properties": {
      "domain": {"type": "string"},
      "siteContext": {"type": "object"}
    },
    "required": ["domain"]
  }
}
```

**Returns**: `{ search, paid, social, backlinks, community, pr, gbp }` each `none | minimal | established` plus per-category `skip_recommendation` flags.

## Tool 3: `niche_competitor_research`

Maps to STEP 0.7.

```json
{
  "name": "niche_competitor_research",
  "description": "Identify niche, competitors, content/schema/feature/audience gaps",
  "inputSchema": {
    "type": "object",
    "properties": {
      "siteContext": {"type": "object"},
      "queries": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["siteContext"]
  }
}
```

**Returns**: `{ niche, competitors: [...], gaps: { content, schema, feature, audience } }`

## Tool 4: `run_category_audit`

Maps to STEP 2 (per-category audit). One call per category; the host agent iterates.

```json
{
  "name": "run_category_audit",
  "description": "Run a single category audit and return findings",
  "inputSchema": {
    "type": "object",
    "properties": {
      "category": {"type": "integer", "minimum": 1, "maximum": 120},
      "mode": {"type": "string", "enum": ["source", "crawl", "both"]},
      "workingDirectory": {"type": "string"},
      "url": {"type": "string"}
    },
    "required": ["category", "mode"]
  }
}
```

**Returns**: `{ category, findings: [{ id, title, severity, confidence, surface, evidence, risk, fix, priority, voiceUsed }], passedChecks, skipped }`

The MCP server internally:
1. Reads the category file from `./categories/{NN}-{slug}.md`
2. Applies the detection / evidence rules
3. Reads the assigned soul JSON before generating fix prose
4. Returns structured findings

## Tool 5: `generate_report`

Maps to STEP 3.

```json
{
  "name": "generate_report",
  "description": "Compile findings into a structured report",
  "inputSchema": {
    "type": "object",
    "properties": {
      "findings": {"type": "array"},
      "siteContext": {"type": "object"},
      "format": {"type": "string", "enum": ["markdown", "json", "csv", "html", "executive"]}
    },
    "required": ["findings", "siteContext", "format"]
  }
}
```

**Returns**: `{ report: string, metadata: { categoriesScanned, voiceReadsCompleted, ... } }`

## Tool 6: `generate_strategic_recommendations`

Maps to STEP 4.5.

```json
{
  "name": "generate_strategic_recommendations",
  "description": "Synthesize findings + competitor research into prioritized recommendations",
  "inputSchema": {
    "type": "object",
    "properties": {
      "findings": {"type": "array"},
      "siteContext": {"type": "object"},
      "competitorResearch": {"type": "object"}
    },
    "required": ["findings", "siteContext", "competitorResearch"]
  }
}
```

**Returns**: `{ executiveSummary, recommendations: [...], startHere: [...], quickWins: [...], whatNotToDo: [...] }`

## Configuration files the server reads

```
./
├── SKILL.md                        — workflow logic
├── categories/                     — 134 category files
├── references/                     — 50 reference files
├── souls/                          — 23 soul JSON files
└── snitch-marketing.config.md      — runtime config (min-confidence, brand redaction, etc.)
```

The server treats the bundle as **read-only data**. It does not write back to the bundle.

## Resources (MCP `resources/list`)

The server should expose these resources for client-side inspection:

- `snitch-marketing://categories` — list of all 134 categories with name + brief description
- `snitch-marketing://souls` — list of vendored souls
- `snitch-marketing://presets` — list of preset groups (Quick / Technical / B2B SaaS / etc.)

## Prompts (MCP `prompts/list`)

The server can expose pre-baked prompt templates for common audit scenarios:

- `audit-quick` — "Run a quick SEO audit on this site"
- `audit-technical` — "Run a technical SEO audit"
- `audit-saas` — "Run a B2B SaaS preset audit"
- `audit-traffic-drop` — "Diagnose the traffic drop on this site (uses STEP 4.7)"
- `audit-migration-preflight` — "Check this site for migration readiness"

Each prompt is a structured template the host agent fills with site context.

## Error handling

| Error class | When it fires | Recovery |
|---|---|---|
| `CATEGORY_NOT_APPLICABLE` | Pre-flight check skips the category | Host agent records skip + reason; no error to user |
| `EVIDENCE_MISSING` | A required tool call (Read / Fetch) returned nothing | Server marks finding as Skip; do not invent evidence |
| `SOUL_NOT_FOUND` | Voice-mapping references a soul not vendored | Fall back to backup soul; log to metadata |
| `MODE_UNAVAILABLE` | Source mode requested but no working directory access; or crawl mode requested but no fetch capability | Return mode-specific error; suggest the other mode |

## Versioning

The MCP server reports its version in `initialize` response. Skill bundle version is in `snitch-marketing.config.md`. Both should track together — bumping the server requires bumping the bundle.

## Reference implementation outline

```typescript
// pseudocode for the server entry point
import { Server } from '@modelcontextprotocol/sdk';
import { loadBundle } from './bundle';

const bundle = loadBundle('./');  // reads SKILL.md, categories/, refs, souls

const server = new Server({ name: 'snitch-marketing', version: bundle.version });

server.setRequestHandler('tools/call', async ({ name, arguments: args }) => {
  switch (name) {
    case 'detect_site_context':
      return runDetection(args, bundle);
    case 'run_category_audit':
      return runCategory(args.category, args, bundle);
    // ... etc
  }
});

server.listen({ transport: 'stdio' });
```

## Distribution

When implemented, the MCP server should be distributed as:

1. **NPM package** — `npx @snitch/marketing-mcp` for one-shot use
2. **Standalone binary** — for users without Node.js
3. **Configuration snippet** — for Claude Desktop / Zed / etc. install

```json
// example claude_desktop_config.json snippet
{
  "mcpServers": {
    "snitch-marketing": {
      "command": "npx",
      "args": ["-y", "@snitch/marketing-mcp"]
    }
  }
}
```

## Out of scope for the spec

- Implementation of the server itself (a separate MCP server project, outside this repo)
- Authentication / billing / quota enforcement (handled by Snitch product surface, not the MCP server)
- Direct file writes to user repos from the server (host agent handles writes)

## Cross-references

- `copilot-entry.md` — non-MCP entry points (Cursor, Copilot, Continue, etc.)
- SKILL.md — the canonical workflow this spec mirrors
- `output-formats.md` — the report formats `generate_report` returns
