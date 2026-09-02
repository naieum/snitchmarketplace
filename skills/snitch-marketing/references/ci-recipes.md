# Running the audit from automation — the prompt contract

There is no Snitch CLI, no hosted Action, and no exit code to gate a build on. This skill is a
prompt: something in CI has to run an AI coding agent that loads `SKILL.md` and does the audit.
This file is the contract for that — what the automation passes in, what it gets back, and what
it does with the result. The CI platform, the agent, and the model are the customer's choice and
are out of scope here.

## What automation passes in

One instruction, in plain language, naming four things:

1. **The skill** — load `snitch-marketing` (however the host agent loads a skill).
2. **The mode and scope** — diff mode against a base ref (source), or crawl mode against a
   deployed URL. Scope is what makes CI runs cheap; an unscoped full audit does not belong on a
   pull request.
3. **The non-interactive flags** — automation cannot answer a menu. Set
   `confirm-categories: false` in `snitch-marketing.config.md` (or say so in the prompt) so
   STEP 1.7 does not block, and name the preset or category list explicitly so the STEP 1 menu is
   bypassed (`references/scan-selection.md`, "When the menu MUST fire vs MAY be bypassed").
4. **Where the report goes** — the default is
   `snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md`, relative to the working directory. Upload
   that path as the build artifact.

A pull-request run reads roughly:

> Run the snitch-marketing skill in diff mode against `$BASE_REF`. Scope to the changed files and
> their route layouts / head builders. Do not show the scan menu; do not ask for confirmation.
> Write the report to its default path and print the executive snapshot.

A preview-deploy run reads roughly:

> Run the snitch-marketing skill in crawl mode against `$PREVIEW_URL` with the Quick Audit preset.
> Do not show the scan menu. Write the report to its default path.

## What automation gets back

- `snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md` — the canonical artifact, plus any secondary
  outputs beside it (`references/report-pipeline.md` owns the save contract).
- The executive snapshot on stdout, if the prompt asked for it.
- **No exit code that encodes severity.** The agent's process exits 0 for "the audit ran". If a
  build gate is wanted, the automation parses the saved report's severity counts itself and
  decides — that policy lives in the customer's pipeline, not in this skill. Nothing in this skill
  reads a `fail-on` setting, because no such setting exists.

## PR comment shape

When automation posts the result to a pull request, one comment, updated in place rather than
appended per push:

```markdown
## Snitch: Marketing — Diff Audit

Scanned 7 changed files. Detected:

**Critical (1)**
- `src/routes/blog/post.tsx:14` — Cat 3: Canonical accidentally removed in refactor

**High (2)**
- `src/routes/blog/post.tsx:18` — Cat 9: Title regressed to 14 chars (was 52)
- `src/routes/blog/post.tsx:23` — Cat 10: Meta description missing

**Medium (3)**
- `src/components/Hero.tsx:8` — Cat 25: Image alt missing
- `src/routes/changelog.tsx:11` — Cat 11: OG image not absolute URL
- `src/routes/changelog.tsx:42` — Cat 31: JSON-LD block removed

Re-run after fixing: `git push`.

[Full report](link to artifact)
```

Evidence lines only, no fix prose — the full report is the artifact. Redaction (Rule 5) applies to
the comment exactly as it applies to the report.

## Which mode fits which trigger

| Trigger | Mode | Scope | Why |
|---|---|---|---|
| Pull request | diff (source) | changed files + their route heads | Fast, scoped, advisory |
| Preview deploy | crawl | Quick Audit | Catches runtime issues a source diff cannot see |
| Post-production deploy | crawl | Quick or Technical SEO | Catches production-only regressions |
| Scheduled (weekly / monthly) | source + crawl | Full | Trend and stakeholder reporting; never per-PR |

A full audit is expensive in tokens and minutes. Schedule it; do not attach it to every push.

## Triage state in CI

Commit `.snitch-marketing-triage.json` and `.snitch-marketing-ignore` (`triage-workflow.md`).
Automated runs read both and suppress already-triaged findings, which is what keeps a PR comment
focused on what this change introduced rather than re-flagging what the team already accepted.
Triage is keyed by fingerprint, so it survives the line-number churn a diff produces.

## Artifacts and trend tracking

Upload the report on every run, including clean ones — the history is what makes a regression
diagnosable later. For trend tracking, pipe the report's metadata (finding count and severity
distribution) to whatever the team already uses; the JSON export
(`references/output-formats.md`) is the machine-readable shape.

## Cross-references

- `references/scan-selection.md` — Diff Mode behavior and the menu-bypass rule
- `references/report-pipeline.md` — the save path and the report's required sections
- `triage-workflow.md` — `.snitch-marketing-ignore` and `.snitch-marketing-triage.json` formats
- `category-groups.md` — preset definitions, when a run names a preset
