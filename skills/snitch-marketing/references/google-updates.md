# Google algorithm-update reference (curated changelog)

A diagnosis aid for `references/traffic-diagnosis.md` Stage 3b ("a Google algorithm
update"). When a traffic change's onset date lines up with a confirmed update window, this
table turns "it's probably an update" into "the drop onset (2024-08-19) falls inside the
August 2024 core update window, which re-weighted quality + topical-authority signals."

**This is a curated snapshot, not a live feed.** It is compiled through 2026-07; anything
announced after that date is not in this table, and the record for it is incomplete here.
Two non-negotiable rules before you cite it:

1. **Confirm against the primary source.** The Google Search Status Dashboard
   (https://status.search.google.com/) is the authority for confirmed updates and their
   exact start/finish timestamps. Third-party trackers (Sistrix, Semrush Sensor, Mozcast)
   corroborate movement but do not *confirm* an update. Always verify the current window
   before attributing a drop.
2. **Onset must match, not just "be near."** A drop that started two weeks before an update
   completed is not caused by that update. Require the onset date to fall inside the
   confirmed window before blaming it (the anti-hallucination rule in
   `references/traffic-diagnosis.md`).

## How to use it in a diagnosis

1. Establish the drop's onset date (Stage 1, confirmed real).
2. Look for a confirmed update whose window contains that date, below.
3. If one matches, read its **targets** column → that becomes the Stage 4 root-cause
   hypothesis (e.g., a spam-update match routes to link/content-spam hypotheses; a core
   update routes to quality + E-E-A-T + topical-authority hypotheses).
4. If nothing matches the onset, **do not invent one** — move to the other Stage 3 triggers
   (deploy, migration, competitor, outage). Most self-inflicted drops are deploys, not
   updates.

## Update types (what each one re-weights)

| Type | What it re-weights | Routes the hypothesis to |
|---|---|---|
| **Core update** | Broad relevance + quality reassessment; topical authority; E-E-A-T (trust heaviest) | Content depth/quality (Cat 18, 57, 59), author/trust signals (Cat 32's Person row, Cat 60, 128), intent fit (Cat 58, 131) |
| **Spam update** | Link spam, content spam, policy violations | Backlink toxicity (Cat 69), parasite/site-reputation abuse (Cat 125), expired-domain abuse (Cat 126), scaled/programmatic thin content (Cat 18, 95) |
| **Reviews** (now folded into core) | First-hand, evidence-backed review content | Review depth + originality + first-hand experience (Cat 59, 74, 128) |
| **Helpful-content signals** (folded into core, March 2024) | People-first vs search-engine-first content | Thin/derivative content (Cat 18, 57), AI-tells (Cat 59), intent mismatch (Cat 58, 131) |
| **Discover update** | The article-surfacing systems behind Google Discover only — not Search | Clickbait / sensational framing (Cat 57, 117), country-local relevance, depth + demonstrated topical expertise (Cat 18, 59, 93, 128). Only route here once Search Console shows the loss is Discover-side |

## Confirmed updates (curated; verify dates on the Status Dashboard)

Newest first. Windows are approximate; the Status Dashboard holds the exact timestamps.

| Window (approx.) | Type | Notes / what it targeted |
|---|---|---|
| Jun 2026 | Spam | June 2026 spam update (Jun 24 – Jun 26, 2026). Routine SpamBrain refresh; Google introduced no new spam policies with it. |
| May 2026 | Core | May 2026 core update (May 21 – Jun 2, 2026). |
| Mar 2026 | Core | March 2026 core update (Mar 27 – Apr 8, 2026). Started two days after the March 2026 spam update finished — a late-March onset needs the exact date to tell the two apart. |
| Mar 2026 | Spam | March 2026 spam update (Mar 24 – Mar 25, 2026) — under 20 hours, the shortest announced spam update. A Mar 24–25 onset is a spam match, not a core one. |
| Feb 2026 | Discover | February 2026 Discover core update (Feb 5 – Feb 27, 2026) — **Discover only, not Search**. The first Discover-only update Google has announced; rolled out to English-language users in the US first, other countries/languages later. Targeted country-local relevance, less sensational/clickbait content, and more in-depth original work from sites with demonstrated topical expertise. Split Discover from Search in Search Console before attributing: Search impressions holding while Discover impressions drop is the signature. |
| Dec 2025 | Core | December 2025 core update (Dec 11 – Dec 29, 2025). |
| Aug 2025 | Spam | August 2025 spam update (Aug 26 – Sep 22, 2025) — 27 days, unusually long for a spam update, so onset-inside-window is weak evidence on its own here. Broad spam-policy enforcement, not link-spam-specific. |
| Jun 2025 | Core | June 2025 core update (Jun 30 – Jul 17, 2025). |
| Mar 2025 | Core | March 2025 core update (Mar 13 – Mar 27, 2025). |
| Dec 2024 | Spam | December 2024 spam update. |
| Dec 2024 | Core | December 2024 core update (ran close behind the November one). |
| Nov 2024 | Core | November 2024 core update (completed early December 2024). |
| Aug 2024 | Core | August 2024 core update; re-weighted quality + reduced some prior-update over-corrections. |
| Mar 2024 | Core | March 2024 core update — unusually large and long (~45 days). **This is the one that folded the "helpful content system" into core**, so there is no standalone HCU after this. A site that never recovered from a 2022-2023 "helpful content" hit is now a core-update story. |
| Mar 2024 | Spam | March 2024 spam update — **introduced three policies this skill maps directly**: *scaled content abuse* (Cat 18/95), *site-reputation abuse* / "parasite SEO" (Cat 125), and *expired-domain abuse* (Cat 126). Site-reputation-abuse enforcement began as manual actions and expanded later. |
| Nov 2023 | Core + Reviews | November 2023 core update; reviews update ran in the same period. |
| Oct 2023 | Core + Spam | October 2023 core update; October 2023 spam update. |
| Sep 2023 | Helpful Content | September 2023 helpful content update (the last *standalone* HCU before the system moved into core in March 2024). |
| Aug 2023 | Core | August 2023 core update. |

Older updates (pre-2023) are rarely the cause of a *current* drop; if a diagnosis reaches
back that far, go straight to the Status Dashboard's full history.

**Announced updates are not the whole picture.** Google's own core-update documentation
states: "We're continually making updates to our search algorithms, including smaller core
updates. These updates are not announced because they aren't widely noticeable." So an onset
with no dashboard match does not prove nothing changed on Google's side — it means you cannot
*name* what changed. Report it as unattributed volatility and keep working the other Stage 3
triggers; do not back-fill a window to close the gap.

## What this reference deliberately does NOT do

- It does not auto-detect that an update happened — you still confirm onset against the
  primary source. It is a lookup table, not a live monitor.
- It does not claim third-party "unconfirmed update" chatter as fact. If a tracker shows
  volatility with no Google confirmation, report it as "unconfirmed third-party-observed
  volatility," not "an update."
- It does not assign blame on its own. A window match is a *hypothesis*; Stage 4 still
  requires page-level evidence (the affected URLs + the quality/link/intent signal) before
  the diagnosis is allowed to name the update as the cause.

Cross-refs: `references/traffic-diagnosis.md` (Stage 3b consumes this), Cat 125
(site-reputation abuse), Cat 126 (expired-domain abuse), Cat 69 (link spam), Cat 18 / 57 /
59 / 128 (content-quality signals a core update re-weights).
