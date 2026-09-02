# References Index

One row per reference doc, no exceptions: what each file contains. **SKILL.md's Reference Loading Map is the single source of truth for *when* a reference loads** — every file in this directory appears there with its condition. This index answers the other question: you know the shape of the problem, you need the filename.

| Reference | Purpose |
|---|---|
| **ads-detection-matrix.md** | Per-platform what's-checkable matrix for ads (Google / Meta / LinkedIn / TikTok / X / Reddit / Pinterest / YouTube / display). Names what's publicly visible vs source-checkable vs inferrable vs invisible. |
| **anti-hallucination.md** | The full 10-rule anti-hallucination spec + false-positive prevention (negative-evidence shape, SPA hydration auto-skip, two-pass verification, auto-exclude paths/URLs, framework-aware context, inline ignores, `.snitch-marketing-ignore`). |
| **category-groups.md** | Preset to category list mapping. Groups 2-15 (Technical SEO, Content, Schema, Conversion, International, Email, Off-site, 2026 Modern, Full Audit, B2B SaaS, E-commerce, Local, Publisher, Accessibility). |
| **ci-recipes.md** | The prompt contract for running this skill from automation: what to pass an agent in CI, what it writes, and the PR-comment shape. No CLI, no exit codes — the skill is a prompt, not a binary. |
| **comparative-mode.md** | Workflow for auditing the user's site AND a named competitor side-by-side. Report template with where-they-win / where-you-win / tied sections. |
| **component-cat-map.md** | Declarative mapping from observable site components to applicable cats. The PRIMARY recommendation engine. Replaces hardcoded archetype presets. |
| **context-file.md** | Spec for the persisted `.snitch-marketing-context.md` (ICP, anti-persona, JTBD Four Forces, top objections, verbatim customer language, brand voice, proof points). Written by discovery; read first by the persuasion/CRO/copy/positioning cats so findings judge against the actual buyer. |
| **field-cwv.md** | Optional free field Core Web Vitals via CrUX / PageSpeed (real p75 LCP/INP/CLS + 25-week trend). Corroborates the CWV-contributor cats and supplies the leading indicator. Gated on `CRUX_API_KEY`; degrades to contributor findings when absent. |
| **copy-bank-templates.md** | 12 lift-and-deploy templates (Twitter bio, one-line description, Reddit reply, LinkedIn launch, hero variants, comparison sentence, "not for" section, FAQ entries, Show HN, customer-discovery email, sales-narrative homepage scroll). |
| **customer-discovery-script.md** | 9-question structured call script for paying users + free-tier non-converted. Three rules (life-not-idea, past-not-hypothetical, talk-less). Question patterns table. Signals to watch. |
| **decision-trees.md** | Six "so what do I do next?" decision trees for the most common audit-end states: master "what now?" tree, scale-channel decision, paid-acquisition readiness, which-test-first, brand-new-first-move, activation-broken triage. Each leaf cites the cat / reference that owns the detailed playbook. |
| **local-services-playbook.md** | Cross-cutting playbook for local-services brands (storefront or service-area). Service-radius targeting, neighborhood tier-1/2/3 prioritization, seasonal campaign rotation, review acquisition timing (the 2-hour-post-visit safe window vs the on-site penalty risk), NAP consistency across 50+ directories, community-platform presence (Nextdoor, neighborhood Facebook), voice-anchor DNA, photo geo-data discipline, weekly + monthly + quarterly operational cadence. |
| **objection-killer-checklist.md** | 5-point landing-page audit framework. Each conversion page is scored against the 5 buyer objections (credibility, complexity, effort, doubt, delay/urgency); the page either closes, leaves open, or compounds each one. Detection patterns per objection + cross-references to the cats that own the related fix surface. |
| **feedback-signals.md** | Activation / Resistance / Comparison / Use-case language interpretation framework. What each signal predicts. Politeness-noise sub-table. |
| **framework-recipes.md** | Per-stack gotchas (Next.js metadata API vs Pages Router, TanStack Start head, Astro frontmatter, WordPress Yoast / RankMath, Webflow / Wix CMS). |
| **grader.md** | LLM-as-grader meta-evaluation spec: 5-criteria rubric (evidence specificity, risk specificity, fix specificity, three-rules adherence, evidence-to-claim alignment) + severity-calibration check, scored 0-2 each (max 10/finding), with auto-rewrite + re-grade loop. `audit_metadata.grader` schema. |
| **html-template.md** | Single-file, offline, brand-palette-compliant HTML report template derived from the canonical markdown: hard constraints (no external deps, red/white/black only, print-friendly `@media print`, accessible semantics, confidential-mode banner) and the `SEO_AUDIT_REPORT.html` output path. |
| **INDEX.md** | This file. What each reference contains. |
| **mental-models.md** | Catalog of 70+ models from foundational thinking, behavioral psychology, and behavioral design, with a psychology hierarchy (value → credibility → friction → motivation → decisions) and reality-check / backfire questions before recommending any model. |
| **migration-preflight.md** | Migration audit. Pre-flight checklist + post-launch diagnostic chain for replatform / domain change / framework migration / CMS change. |
| **output-formats.md** | Alternate report formats: full markdown (default), executive summary, JSON for tooling, CSV for spreadsheet, HTML for client-deliverable, PR-comment summary. |
| **portfolio-mode.md** | Workflow for auditing 2+ properties owned by the same brand / agency / parent company. Cross-target synthesis with shared findings, divergent findings, best-practice opportunities. |
| **remediation-generator.md** | Audit→fix bridge: turns a finding into a ready-to-ship artifact (copy drafts A/B/C, JSON-LD, llms.txt, meta) grounded in `.snitch-marketing-context.md`, with a Verify line and an AI-boilerplate + report-lint pass. Opt-in, post-audit; emits, never auto-writes. |
| **report-lint.md** | The owner of the report-hygiene rules: the redaction gate (hard fail), em-dash density, practitioner/source-name scan, sycophantic-adjective list, framing patterns, "Bonus" sections, negative-evidence shape. `audit_metadata.lint` schema. |
| **report-pipeline.md** | STEP 3, the full contract: every report-generation stage in fixed order — executive snapshot, redaction gate, lint pass, copy-mechanics lint, grader, HTML render, save path, finding identity, scan comparison, coverage section, metadata. SKILL.md carries the ordered stage list; this file is authoritative. |
| **report-template.md** | Canonical structure for SEO_AUDIT_REPORT.md. Symmetric "What needs work" / "What's working" sections. Voice rules. Forbidden patterns. Output path conventions. |
| **scan-selection.md** | The whole selection contract in one file: the 17-option menu and per-option behavior, the must-fire vs may-bypass rule, the STEP 1.5 component-driven recommendation, the STEP 1.6 audit-mode fork, the STEP 1.7 confirm gate, and the category picker (aliases, group keywords, range parsing) both the menu and the gate parse with. |
| **screenshot-integration.md** | How the skill captures, stores, and embeds Playwright-MCP screenshots for crawl-mode findings about rendered elements: activation conditions (crawl mode + Playwright MCP + a cat listed in this file's relevance table + URL/selector evidence), output path, and `audit_metadata.screenshots` notes. Skips silently when unavailable. |
| **smart-detection.md** | Stack detection table: file patterns to framework name. Next.js (next.config.*), Astro (astro.config.*), TanStack Start, WordPress (wp-config.php), Gatsby, Eleventy, Hugo, Jekyll, etc. |
| **discovery-flow.md** | The six-part pre-audit sequence: STEP 0.4 Critical Unknowns & Validity Preconditions, 0.5 Pre-Audit Discovery (including the read-only declared-intent pass over BLUEPRINT.md / marketing/positioning.md), 0.5.1 Assumptions Capture, 0.6 Brand Maturity Check, 0.7 Niche & Competitor Research, 0.8 Component Inventory (which also writes `.snitch-marketing-context.md`). Output sections written to the audit report. |
| **standards-table.md** | Schema.org type catalog with SEO-impact tier per type, plus the per-type validation rows Cat 32 runs on: page-type signal, required and recommended properties, rich-result status, pitfalls with severities, Fix voice. 14 type rows (Article, BreadcrumbList, Product, FAQPage, HowTo, Organization / WebSite, VideoObject, Recipe, Course, Event, JobPosting, SoftwareApplication, LocalBusiness, Person) plus the Review / AggregateRating ceiling Cat 94 uses. |
| **strategic-recommendations.md** | STEP 4 STRATEGIC_RECOMMENDATIONS.md template + synthesis rules. Three-tier distribution sequencing, 30/60/90 day plan, kill/pivot/narrow rules at day 90, tracking dashboard. |
| **traffic-diagnosis.md** | Traffic-drop diagnostic workflow. 5 stages (confirm change is real / localize / identify trigger / diagnose root cause / recovery plan). 5 trigger types (deploy / algorithm update / migration / competitor / outage). |
| **triage-workflow.md** | Per-finding triage state (confirmed / accepted / false-positive / in-progress). `.snitch-marketing-triage.json` schema. `.snitch-marketing-ignore` format. Inline-ignore comments. |
| **voice-mapping.md** | Internal master table of category → primary voice slug → backup voice. INTERNAL mechanism only; never surfaced in user-visible output. |
| **voiced-remediations.md** | The discipline-specific-voice mechanism: how to read a soul JSON, how to internalize cadence without naming a source, voice-fidelity anti-hallucination rules, and the rule that no soul slug reaches an emitted artifact. |
| **ai-crawler-registry.md** | The ~16 current AI crawler user-agents (GPTBot, OAI-SearchBot, ClaudeBot, PerplexityBot, Google-Extended, etc.) with owner / purpose / robots.txt token + the training-bot vs live-retrieval-bot distinction that decides the citation consequence. |
| **assistant-profiles.md** | Per-assistant citation profiles for Cat 82's Layer 3: retrieval mechanism, citation style, trust hierarchy and the signal that earns a citation on each major assistant surface, plus the per-assistant link rates behind mention-vs-citation and a table routing each observed gap to the layer that fixes it. |
| **citability-scoring.md** | Deterministic per-passage citability rubric (7 observable dimensions) + answer-length-by-surface table (134-167 word citation blocks per Google AI Optimization Guide; 40-60 snippet/PAA; <29 voice). Scored from quoted text only. |
| **brand-authority-platforms.md** | Off-site authority sweep checklist (Wikipedia, Reddit, YouTube, LinkedIn, Quora, Stack Overflow, GitHub, Crunchbase, Product Hunt, G2, Trustpilot): per-platform what to check + capture method. Presence/recency/sentiment, no fabricated weights. |
| **geo-score.md** | Optional GEO readiness rollup (0-100) via a transparent deduction model (start 100, deduct per finding by severity). Gated to render only when the GEO cats ran; every point delta traceable to a finding. |
| **ai-visibility-gap-analysis.md** | Classification + prioritization for AI-visibility findings: branded entity map (step zero), six gap dimensions (visibility / narrative / topic / format / web mentions / demand), Fix-Build-Influence triage, three-pillar measurement stack (referral leakage, bot activity, self-reported attribution), four trend metrics + monthly/quarterly cadence, first-week action order. |
| **schema-deprecations.md** | Registry of retired/narrowed rich-result types (HowTo removed Sept 2023, FAQ narrowed, SpecialAnnouncement, etc.) so Cat 32 doesn't recommend dead rich results. |
| **eeat-assessment.md** | Consolidated E-E-A-T framework tied to Google's QRG, Trust weighted heaviest, + the Who/How/Why heuristic. Unifies signals scattered across the content/trust cats. |
| **content-intelligence.md** | Deterministic content metrics: Flesch-Kincaid readability, cross-page near-duplicate (Jaccard >0.80), keyword cannibalization. Each produces a quotable figure. |
| **brand-voice-framework.md** | Brand-voice audit system: documented-voice check, "We are / We are not" table, voice-constants vs tone-flexes, tone-by-context matrix, confidence scoring + open-questions. Audits the customer's brand voice (distinct from our voiced-remediations). |
| **backlink-commoncrawl.md** | Free, no-key backlink signals via Common Crawl: a crawl-coverage proxy (the bundled `scripts/commoncrawl_backlinks.py`) plus the heavier web-graph authority method, with explicit limits (it is not a referring-domain list). |
| **google-updates.md** | Curated changelog of confirmed Google core / spam / helpful-content / reviews updates and what each type re-weights. A lookup table, not a live monitor; always confirm exact dates against the Status Dashboard. |
| **seo-drift.md** | Stateless element-level regression check (git-diff for SEO): write a baseline artifact, diff it on re-audit against severity-ranked rules (canonical / JSON-LD / noindex / title / H1 / status). Read/Write only, no database. |
| **finding-identity.md** | Stable finding identity: `ruleId` + semantic `anchor` (+ `instance` for siblings) and the fingerprint that keys triage state and scan comparison, so findings survive line-number shifts and URL changes. |
| **writing-system.md** | How the writing system applies here: which prose runs in strict vs flavored mode, how to run `scripts/copy-lint.py`, and how a score becomes evidence in a Cat 59 / Cat 117 finding. The rule set itself (W1-W14, A1-A7) is owned by `snitch-ux` — call the Skill tool with "snitch-ux" for a full copy pass. |

## How references load

References are NOT pre-loaded. The agent reads them on demand, per the conditions in SKILL.md's Reference Loading Map. A dozen or so are unconditional on every audit (detection, discovery, selection, the report chain, the voice chain); the rest are specialist material a Quick Audit never touches. That split, not the raw file count, governs token cost.

## Adding a new reference

Append a row here with its purpose, **and** add it to SKILL.md's Reference Loading Map with the condition that loads it. A reference with no row in that map has no way to be read.

## Reference vs category file

References are CROSS-CUTTING (apply across many cats or workflow steps). Category files are PER-CATEGORY (apply to one cat's detection / fix logic). When a piece of guidance applies to a single cat, it lives in the cat file. When it applies across cats, it lives in a reference. New cross-cutting docs go in `references/`; new cat-specific guidance extends an existing cat file.

## Cross-references between docs

The references cite each other where load-bearing:

- `customer-discovery-script.md` ↔ `feedback-signals.md` ↔ `copy-bank-templates.md` form the strategic-discovery loop.
- `component-cat-map.md` ↔ `category-groups.md` ↔ `scan-selection.md` form the category-selection chain.
- `report-template.md` ↔ `output-formats.md` ↔ `triage-workflow.md` form the output / state-management chain.
- `ads-detection-matrix.md` is referenced by every ads-related cat (66, 109, and Cat 53's UTM pass).

The cross-references are documented inline within each reference; this index lists the references' independent purposes.
