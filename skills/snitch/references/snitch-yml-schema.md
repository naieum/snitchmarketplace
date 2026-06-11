# .snitch.yml schema (v1)

Drop a `.snitch.yml` at your repo root to override Snitch for GitHub defaults
on a per-repository basis. All keys are optional; missing keys fall back to
the defaults listed below.

## Top-level keys

| Key | Type | Default | Notes |
|---|---|---|---|
| `trigger` | `smart` \| `always` \| `manual` | `smart` | When to run the scan. See "Trigger modes" below. |
| `provider` | `openrouter` \| `anthropic` \| `openai` \| `google` \| `copilot` | auto-detect | Override which AI provider to use. If unset, the highest-priority provider with a key supplied to the Action wins. |
| `model` | string | provider default | Provider-relative shorthand. e.g. `sonnet`, `opus`, `gpt-4o`, `gemini`. |
| `fail-on` | `critical` \| `high` \| `medium` \| `low` \| `none` | `high` | Severity threshold at or above which the commit check fails. |
| `categories` | array of integers | auto-detect | Explicit list of category numbers to scan. Omit to let Snitch auto-detect from changed file extensions. |
| `paths.ignore` | array of glob strings | `["**/*.md", "**/*.test.*", "**/*.spec.*", "docs/**", "vendor/**", "node_modules/**"]` | Files matching any of these globs are skipped. |
| `paths.include` | array of glob strings | `[]` (means "include all") | If non-empty, only files matching these globs are scanned (then `ignore` is applied). |
| `ignore-comments` | boolean | `true` | When true, lines preceded by `// snitch-ignore-next-line: <reason>` are skipped. |
| `override-label` | string | `snitch-override` | PR label that flips a failing check to neutral, with the reason recorded in the dashboard. |

## Trigger modes

### `smart` (default, recommended)
- Scans on PR `opened` and `ready_for_review`.
- On `synchronize` (new commits pushed), re-scans only if the previous scan
  found a Critical or High severity issue. Otherwise skips.
- Always scans when a `/snitch` comment is posted on the PR.
- Skips when a commit message contains `[skip snitch]`.

### `always`
- Scans on every PR push event.
- For regulated teams that want maximum coverage at the cost of more LLM spend.

### `manual`
- Only scans when:
  - A `/snitch` comment is posted on the PR, or
  - The PR title contains `[snitch]`, or
  - The PR body contains `/snitch`.

## Universal escape hatches

These work regardless of `trigger` mode:

- `/snitch` in a PR comment forces a scan.
- `[snitch]` in a PR title forces a scan.
- `[skip snitch]` in a commit message skips a scan.
- Adding the `snitch-override` label (or your custom `override-label`) flips a
  failing check to neutral.

## Example

```yaml
trigger: smart
provider: anthropic
model: sonnet
fail-on: high
categories: [1, 2, 5, 7]
paths:
  ignore: ["docs/**", "**/*.md", "**/*.test.*", "vendor/**"]
  include: ["src/**", "lib/**"]
ignore-comments: true
override-label: snitch-override
```
