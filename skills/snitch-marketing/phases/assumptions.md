# Phase: assumptions (assumptions capture)

> Single source of truth for the assumptions phase. Consumed by the CLI recon
> pass and streamed via `snitch marketing step --phase=assumptions`. Mirrors
> SKILL.md STEP 0.5.1 and `references/discovery-flow.md`.

Several recommendation dimensions cannot be observed from the site alone. The audit
must NOT silently assume them — it captures each explicitly, marks it `observed`
(verified from source / public data) or `assumed` (working hypothesis to confirm before
acting), and states the risk if wrong. A recommendation grounded in a wrong assumption
is worse than none, because the team executes confidently in the wrong direction.

Capture this table (the "## Assumptions — confirm before acting" output):

| Assumption | Risk if wrong |
|---|---|
| **Team size**: solo / small (2-5) / mid (6-20) / larger | Solo founders can't maintain a 10-channel plan; tunes founder-led vs ops-heavy plays. |
| **Time commitment**: full-time / nights & weekends / 25% time | Tunes realistic content cadence, discovery throughput, launch timing. |
| **Paid budget**: $0 / <$500/mo / $500-5000/mo / >$5000/mo | Don't recommend paid channels to a $0 brand; drives content/community vs ads. |
| **Founder type**: technical / marketing-savvy / non-technical / first-time | Founder-led writing is highest-leverage for marketing-savvy founders, less so for technical-only. |
| **Business goal**: indie-profitable / venture-track / lifestyle / passion | Different goals → different pricing, segment, and channel mix. Don't recommend venture scaling to an indie target. |
| **Compliance posture**: none / SOC 2 / HIPAA / EAA / other | Gates enterprise/regulated recommendations; no SOC 2 means no enterprise pursuit regardless of TAM. |

How to derive:

1. Read the source/about/team page first — founder name, "Built by [team]," careers
   page presence are observable. Mark these `observed`.
2. Default the rest to the most common case for the brand's stage, marked `assumed`.
   For an indie SaaS: solo/2-person, founder full-time, $0 paid, technical founder,
   indie-profitable goal, no compliance. For an established commercial brand: 6-20
   person team, mixed roles, modest budget, mixed compliance.
3. Keep recommendations CONDITIONAL on the assumptions: "If team is solo and budget $0
   (assumed), the wedge is X; if budget is actually >$500/mo, it shifts to Y." Never
   silently assume; always show the conditional.
