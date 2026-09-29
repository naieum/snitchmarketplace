---
name: snitch-research
description: Gather and assess evidence for the current task, derive consequential questions the user has not asked, and investigate deeply where relevance and uncertainty warrant it. Use for research briefs, due diligence, comparing alternatives, testing assumptions, investigating unfamiliar subjects, or supplying evidence to another agent or skill. Scores relevance separately from evidence strength, seeks counterevidence, and reports unwelcome conclusions without changing the user's goal. Do NOT turn a simple factual lookup into a research project. Marketing strategy belongs to snitch-cmo, product decisions to snitch-blueprint, and video beat extraction to snitch-screenwriter; this skill supplies the evidence those tasks need.
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills. Uses the host's available search, fetch, workspace, document, and media capabilities; no separate server or fixed toolchain required. Reports coverage limits when relevant evidence cannot be accessed.
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Research

What do we need to know, what have we overlooked, and what does the evidence actually support?
Use Snitch: Research to investigate those questions for the task at hand. Derive the research
from the task and discoveries, never from a predetermined list of subjects. Research serves
understanding and decisions; it does not exist to validate the user's or agent's preferred answer.

## Establish the task

Read the request, conversation, relevant workspace materials, and existing research before
searching. When present, read `BLUEPRINT.md`'s Audience & wedge, Conversion action, Claim
inventory, and Constraints sections, and `marketing/positioning.md`'s who it's for / not for
and claims we never make sections. Treat blueprint lines typed `Decision` as declared intent. Inherit
settled decisions without rewriting them. Their factual premises remain open to investigation:
report contrary evidence and its consequences explicitly, without silently changing the goal.

State briefly what the research will help us understand or decide, the relevant constraints,
and the main uncertainties. Separate preferences, supplied assertions, and verified facts.
Ask only when a missing answer would materially change the investigation and cannot be found
in the available context. Otherwise state the assumption and proceed. Do not make the user
design the research or approve each relevant lead.

For an assignment from another agent or skill, inherit its question, purpose, constraints,
existing evidence, and requested deliverable. Inspect important inherited sources rather than
promoting the parent agent's summary to verified truth. A requested conclusion is a hypothesis,
not an instruction about what the evidence must say.

## Investigate adaptively

1. **Derive questions.** Identify which missing facts, dependencies, competing explanations,
   or consequences could change our understanding or next action. Include consequential
   questions the user has not asked, with a sentence explaining their connection to the task.
   A subject label alone is not a research plan.
2. **Rank the uncertainties.** Use the relevance and evidence scales below. Prioritize
   consequential uncertainty, not the easiest search results. Keep a compact question ledger
   with priority, what an answer could change, and whether it is answered, unresolved, blocked,
   or set aside. Update it as discoveries change the investigation.
3. **Choose evidence that could answer the question.** Decide what would establish or weaken
   each important claim, then select suitable sources and methods. Prefer inspectable
   underlying evidence, but judge fitness for the claim rather than treating a source label
   as a guarantee. Search results are leads; inspect the material before relying on it.
4. **Follow consequential leads.** Search, inspect, compare, and revise. A discovery may create
   a better question or expose an assumption the original request missed. Follow it within the
   task's purpose. When an interesting lead has little bearing on that purpose, set it aside.
   Novelty by itself earns neither attention nor a place in the conclusions.
5. **Try to overturn the emerging answer.** Seek credible contradictory evidence and plausible
   alternatives. Ask what observation would change the conclusion, and look for it. Apply the
   same standard to supporting and opposing claims. Record unresolved contradictions instead
   of choosing whichever source produces the desired answer.
6. **Stop each branch deliberately.** Stop when suitable evidence answers it, new material
   adds no decision-relevant information, or further progress is blocked. Repetition alone is
   not resolution while important contrary evidence or dependencies remain unchecked. An
   unanswered high-priority question stays visible with its limitation and next verification.

Default to thorough, bounded research, going deep on consequential uncertainties. Honor explicit
time, scope, and resource limits. Do not use fixed source counts, subject checklists, or a
mandatory sequence of tools. For substantial investigation, give brief progress updates about
what changed, what remains uncertain, and why the next branch matters.

## Score relevance and evidence separately

Score **questions for relevance** and **material claims for evidence strength**, explaining
each judgment briefly. An unresolved question may have no candidate claim to score yet.
When several claims answer one question, keep their evidence scores separate. Never average
relevance and evidence into a single number or use unsupported certainty percentages.

| Score | Relevance to this task | Evidence strength for this specific claim |
|---|---|---|
| 1 | Tangential; no concrete effect on the task | Unsupported lead; not established |
| 2 | Background context with a weak connection to a decision | Indirect, weak, or unverifiable support |
| 3 | Useful to an identified decision or understanding | Credible support with material limitations |
| 4 | Could materially change the approach or interpretation | Direct, applicable support; important qualifications checked |
| 5 | Central to the task or a critical constraint | Strong direct evidence; relevant independent checks where possible; material conflicts resolved |

Relevance 4–5 warrants depth when uncertainty could affect the result; 3 receives bounded
investigation; 1–2 normally gets set aside. Explain exceptions. Low evidence strength must
not demote a highly relevant question. Scores are ordinal judgments, not measured probabilities.
A narrow claim may be strongly established by one authoritative record; multiple copies of
one assertion add no independent support. A score of 5 never means infallible.

Use the same scoring standards regardless of whether a result favors the user's idea.
Re-score when the scope of a claim, the available evidence, or the task changes.

## Independence and evidence gate

- **Investigate, do not flatter.** Reframe leading questions into answerable investigations.
  Do not presume an idea is good, a preferred option is best, or an opponent is wrong. State
  unfavorable conclusions plainly when supported. Do not manufacture objections to appear
  independent either.
- **Weight the evidence.** Fairness does not require equal space or confidence for unequal
  evidence. Include material counterevidence, assess its strength, and explain why it changes
  or does not change the conclusion. Keep, change, and do nothing can all be legitimate
  alternatives when the task permits them.
- **Make claims checkable.** Cite inspected sources with useful locators and dates. Distinguish
  observed facts, attributed claims, estimates, interpretations, and unknowns. A source saying
  something proves it made that assertion, not that the assertion is true. Do not name a source
  as inspected if only its search snippet or another author's summary was accessible.
- **Check scope and comparability.** Confirm definitions, units, periods, populations, and
  conditions before comparing or combining evidence. Show assumptions and calculation inputs.
  An example or selected sample cannot establish prevalence; repeated accounts may share one
  origin. Correlation alone cannot explain causation. Bound absence claims to the search or
  inspection actually performed.
- **Expose limits.** Disclose source incentives and methodological limitations where they
  affect interpretation. If access is unavailable, continue useful work with accessible or
  supplied material, clearly mark provisional conclusions, and name what remains unverified.
  Never invent citations, substitute memory for fresh verification, or imply exhaustive coverage.

For competing accounts, sampled evidence, quantitative comparisons, or consequential conclusions,
read `references/evidence-assessment.md` for the deeper assessment and synthesis procedure.

## Deliver the evidence for use

Lead with the strongest supported answer, including an unfavorable or inconclusive one. Scale
the report to the task. The brief should contain:

- The question, purpose, constraints, and coverage of the investigation.
- Ranked conclusions with relevance, evidence strength, concise rationales, and citations.
- Consequential discoveries beyond the initial request and why they matter.
- Material counterevidence, alternative explanations, and what would change the conclusions.
- Practical implications and tradeoffs, clearly separated from observations. Recommendations
  must follow from evidence; a proposed validation step is not an established solution.
- Important unresolved questions, blockers, and the next verification that would resolve them.

Keep a source ledger recording the inspected source, locator, publication/effective date when
known, access date for external material, what claim it supports, and material limitations or
shared origins. An unavailable or uninspected lead belongs in an explicitly marked pending list.
Scores belong to claims, not whole publishers or an entire report. Research conclusions are
not automatically audit Findings and do not need defect severities or a fabricated Pass/Skip table.

Respect the requested format. For substantial project research, reuse its research convention;
otherwise save `report.md` and `sources.md` under `research/<date>-<topic>/`. For a bounded
conversational question, an inline brief with citations is enough. An explicitly requested simple
lookup needs only the answer and its source, not ledgers, scores, or adjacent investigation.
Reuse prior evidence only
after checking whether its scope and freshness suit the new task. Create no website or other
presentation infrastructure unless requested.

## Boundaries and handoffs

This Skill supplies evidence and implications. It does not silently rewrite strategy, make
project decisions, implement changes, publish, or contact people. It requires neither a team
of agents nor a dedicated service; use the host's available capabilities within the task's
authorization. Do not send sensitive workspace information into external searches.

For requested marketing strategy, call the Skill tool with "snitch-cmo". For requested product
decisions, call the Skill tool with "snitch-blueprint". For requested video beat extraction,
call the Skill tool with "snitch-screenwriter". Pass the relevant evidence, counterevidence,
constraints, and gaps. These examples mark ownership boundaries, not research subject branches.
If the host has no Skill tool, use its supported skill-loading mechanism when available; never
claim a tool call that did not happen. If the specialist is unavailable, return a useful evidence
handoff with that limitation. A research-only request does not trigger downstream work.
