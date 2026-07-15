## CATEGORY 126: Domain heritage / expired-domain abuse risk

Google's expired-domain-abuse spam policy targets a specific move: buying an aged or
previously-used domain and repurposing it for content largely unrelated to its prior use,
in order to exploit residual ranking authority the old site had earned. A domain can also
carry forward reputation baggage from whatever ran on it before, including a prior manual
action or a history of spam. This category checks whether the brand's domain shows a
heritage mismatch (meaningful registration age plus a topical drift from its earlier use,
especially after a recent acquisition) that fits that risk pattern. It runs the same check
as pre-acquisition due diligence when a team is weighing whether to buy a domain at all.

Scope note: this is a proactive provenance check on the domain itself. It is distinct from
Cat 96 (brand-SERP defense: controlling what ranks for the brand name) and from the
reactive traffic-drop workflow in `references/traffic-diagnosis.md` (diagnosing a decline
that already happened). This category asks one question before anything is wrong: does the
domain's history match a pattern that warrants manual review?

### Pre-flight: relevance check

Run this for any brand on a domain it acquired rather than originally registered, any aged
domain whose creation date predates the brand, and any pre-acquisition due-diligence
request on a domain a team is considering buying. Lower priority for a domain the brand
registered itself and has held continuously, where there is no prior owner and no prior
topic to inherit. A brand-new domain has no heritage to inherit at all: record it as clean
on this axis and move on, do not run the external lookups.

The external lookups in Evidence required are OPTIONAL and gated on network access. If they
cannot run, this category produces a Skip-with-reason, not a guess.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Source is limited here by definition: the repository reveals only the CURRENT topic of
   the site, not the domain's registration date, ownership history, or prior use. Note this
   limit explicitly and lean on crawl mode plus the external lookups for the heritage half.
2. Read `.snitch-marketing-context.md` for provenance the team already knows: did the brand
   register this domain fresh or acquire an existing one? Was there a recent acquisition,
   migration, or rebrand? When was the brand founded, relative to the domain? Record what
   the context file states; do not infer dates it does not contain.

**Crawl mode, required tool calls (all OPTIONAL + gated on network access):**

1. Registration + ownership history via RDAP. Example:
   `Bash curl -s https://rdap.org/domain/<domain>` and read the `events` (registration,
   last-changed, transfer) and any registrant change. A creation date well before the brand
   existed, or a transfer event near a recent acquisition, is the heritage signal.
2. Prior-use topic via the Wayback Machine CDX index. Example:
   `Bash curl -s "http://web.archive.org/cdx/search/cdx?url=<domain>&output=json&limit=20&from=2005"`
   to sample historical captures, then fetch a couple of the oldest snapshots
   (`http://web.archive.org/web/<timestamp>/<url>`) and read what the site was about then.
3. Compare the prior topic against the current site topic. A large gap (old payday-loan site
   now serving B2B software content, for example) is topical drift.
4. If `curl` or network access is unavailable, mark the category **Skip** with reason
   `domain-heritage lookup needs network access to RDAP + Wayback; unavailable in this run`.
   Do not estimate a registration date or describe prior content you did not retrieve.

### Forbidden claims

- "The domain has a Google penalty" or "Google has acted on this domain." You cannot observe
  a penalty from RDAP or Wayback. Claim only: "the domain's heritage matches the
  expired-domain-abuse risk pattern; warrants manual review."
- "The domain was registered in <year>." Do not assert a registration date you did not
  retrieve from RDAP/whois. If the lookup did not run, the date is unknown.
- "The prior site was about <topic>." Only if you actually fetched and read a historical
  snapshot. Otherwise the prior use is unknown, not assumed.
- "This will trip the spam policy." The policy targets intent and pattern; you are reporting
  a pattern match for review, not adjudicating it.

### Detection

Creation/registration date and ownership-change events via RDAP/whois; prior-use topic via
sampled Wayback snapshots; compare prior topic against current site topic and weigh the gap
against registration age and any recent acquisition. Source mode covers only the current
topic; the heritage half is external-lookup-dependent and gated.

### What to Search For

When the lookups run:
- A creation date that significantly predates the brand's existence (an aged domain the
  brand did not originally hold)
- A registrant change or transfer event in RDAP near a recent acquisition (bought history,
  not a clean slate)
- Wayback snapshots showing a prior site on a clearly different topic
- Topical drift: the prior subject and the current subject are largely unrelated
- The combination that defines the policy pattern: aged domain + sharp topical drift +
  recent acquisition, where residual authority appears to be part of why the domain was chosen
- Prior content that itself looks spammy, gambling/adult, or foreign-language link-farm
  (reputation baggage independent of the drift question)

### Actually Hurts the Marketing Surface

- **Aged domain, sharp topical drift, and a recent acquisition together.** This is the exact
  shape the expired-domain-abuse policy describes, and a brand relying on inherited authority
  is building on ground it cannot account for.
  Evidence required: RDAP creation date + transfer/registrant-change event + a dated Wayback
  snapshot of the prior topic + the current topic, side by side.
- **Prior use carries reputation baggage.** The domain previously ran spam, a link farm, or
  adult/gambling content, which can follow the domain regardless of the current site's quality.
  Evidence required: a dated Wayback snapshot showing the prior content type.
- **The strategy depends on residual authority from an unrelated prior life.** The domain was
  acquired largely for ranking strength it earned under a different topic, which is the
  behavior the policy targets.
  Evidence required: RDAP transfer event + prior-vs-current topic gap + any context-file note
  that the domain was chosen for its existing authority.
- **Provenance is unknown and the domain is aged.** An old domain with no retrievable history
  is not cleared; it is unreviewed, and that uncertainty is itself the finding.
  Evidence required: RDAP creation date showing age + a note that prior-use snapshots could
  not be retrieved (or the lookup was gated), framed as warrants-manual-review.

### NOT a Problem

- A domain the brand registered and has owned continuously since, with no acquisition and no
  repurposing. There is no prior owner and no prior topic to inherit.
- A rebrand on the same continuously-owned domain. Changing the brand name or look on a domain
  you have always held is not expired-domain abuse.
- An aged domain whose topic lineage is consistent: it has always been about the same subject,
  through one or more owners. Age without drift is not the pattern.
- A brand-new domain. No heritage exists to inherit; note it as clean on this axis rather than
  running the external lookups.

### Context Check

1. Did the brand register this domain fresh, or acquire an existing one? What does the context
   file say, and what does the RDAP event history show?
2. What was the prior use (from Wayback), and how far is it from the current topic?
3. How large is the gap between the domain's creation date and the brand's founding?
4. Was there a recent acquisition, migration, or relaunch that lines up with a transfer event?
5. Is residual authority part of why this domain was chosen, per the context file?
6. Could the lookups actually run, or is this a Skip-with-reason? Distinguish "reviewed and
   clean" from "unable to review."

### Reference

Google Search Essentials, spam policies, "Expired domain abuse":
https://developers.google.com/search/docs/essentials/spam-policies#expired-domain-abuse

Internet Archive Wayback Machine: https://web.archive.org/ ; RDAP via https://rdap.org/

Cross-ref Cat 96 (brand-SERP defense) and `references/traffic-diagnosis.md` (reactive
drop analysis) when a heritage finding coincides with a ranking problem.

**Severity tagging:**
- Large registration age + sharp topical drift + recent acquisition (full pattern match) → High.
- Prior use shows spam / penalized / link-farm content baggage → High.
- Mild drift, or aged domain with unretrievable history (unreviewed) → Medium.
- Continuous-ownership rebrand on a long-held domain → Low (note, not a break).
- Brand-new domain, no heritage to inherit → Pass (note: clean on this axis).
- Network/`curl` unavailable for RDAP + Wayback → Skip-with-reason (not a Pass).

**Fix voice:** `security-engineer` (primary) | `solutions-architect` (backup).

Read `souls/security-engineer.json` before writing the Fix.

Worked fix example:

> Treat the domain as an asset you inherited, not one you built. You do not know what ran on
> it before, so model its history before you pour content and link equity onto it. Secure by
> design beats finding out in an incident review six months from now.
>
> Pull provenance first, in this order:
>
> 1. RDAP for the facts. `curl -s https://rdap.org/domain/<domain>` and read the events. A
>    creation date years before the brand existed, plus a transfer event near the acquisition,
>    means you bought history, not a clean slate.
> 2. Wayback for the prior topic. Sample the oldest captures and read two of them. Put the old
>    subject next to the current one.
>
> Then decide on what the lookups show, not on hope. A domain created in 2009 about an
> unrelated subject, transferred last quarter, now serving the brand's content is the exact
> shape the expired-domain-abuse policy describes. State it as a risk-pattern match that
> warrants manual review, not as a penalty. You cannot observe a penalty from these tools, so
> do not claim one.
>
> Pick the control that fits the finding:
>
> - Consistent lineage, continuous ownership: no action. Record the RDAP date and the snapshot
>   you checked so the audit trail exists, then move on.
> - Drift after an acquisition: do not lean on the inherited authority. Build the topic on its
>   own merits and treat any retained ranking as borrowed, not banked. Keep the evidence in
>   case a reviewer asks how the domain was sourced.
> - Prior spam or a link-farm history: this is the reputation half. Weigh whether the residual
>   baggage outweighs the brand value of the name, and document the call either way.
>
> If you are still deciding whether to buy: run this exact check before you sign. The cheapest
> time to find a domain's history is before it is yours.
>
> Verify: if `curl` or the network is unavailable, do not improvise dates or prior content.
> Mark it Skip-with-reason and flag the domain for a lookup when access is restored. An
> unreviewed aged domain is unverified, not cleared.
