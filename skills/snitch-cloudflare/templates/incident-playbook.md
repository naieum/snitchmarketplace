# Cloudflare incident playbook (active attack)

Use this when traffic is bad RIGHT NOW. Read step 1 aloud to whoever is on call. Each step takes <60 seconds.

---

## Step 1 — Flip Under Attack Mode

```bash
bash snitch-cloudflare.sh panic under-attack
```

This sets `security_level=under_attack` for the zone. Every visitor gets a 5-second JS challenge. Caches stay served, but anything that misses cache is challenged. Real users see a brief interstitial; bots without JS execution stop dead.

**Consequence:** legitimate users on poor networks may fail the challenge intermittently. Acceptable cost for the next 30 minutes.

A `.state/panic-<timestamp>.json` record is written automatically — `panic restore` reverses it later.

## Step 2 — Gather signals (don't skip; data drives the next move)

In the Cloudflare dashboard → Security → Events, sort by **last 5 minutes**, group by:

- **Top source ASNs** — copy the top 5.
- **Top URLs hit** — copy the top 10. Look for: a single path getting hammered, or `/.git`, `/wp-admin`, `/.env` style probing.
- **Top countries** — copy the top 5. If your business has zero traffic from one of them, that's a target.
- **Top user agents** — copy the top 5. Empty UA, `python-requests`, `curl`, `Go-http-client` are often abuse.
- **Cache hit rate** — if it cratered, the attack is hitting uncached paths.
- **HTTP status codes** — 5xx surge = origin overload; 4xx surge = the WAF is doing its job.

Optional: `bash snitch-cloudflare.sh diagnose "under attack"` walks the same data programmatically and emits a markdown trace.

## Step 3 — Targeted blocks

Order: most-specific first, broadest last.

```bash
# Single bad IP or CIDR (24h TTL by default).
bash snitch-cloudflare.sh panic block ip 203.0.113.45
bash snitch-cloudflare.sh panic block ip 203.0.113.0/24

# Whole ASN — only if the ASN is overwhelmingly abusive.
bash snitch-cloudflare.sh panic block asn 14061

# Country block — last resort. The skill warns if it has legitimate traffic
# from this country in the last 30 days.
bash snitch-cloudflare.sh panic block country RU
```

If the attack is path-specific (e.g., `/login` brute force, `/api/expensive`), prefer a Custom Rule with a tighter expression than a country/ASN ban.

If you can't pin it: `bash snitch-cloudflare.sh panic challenge-all` adds a top-priority Custom Rule that managed-challenges every request. More punishing than under-attack mode and easier to roll back surgically.

## Step 4 — Postmortem (within 24h of the all-clear)

Write a postmortem note. Template below. Save to your team's incident log.

```markdown
# Incident: <short title>
**Date:** <YYYY-MM-DD>
**Duration:** <start time UTC> → <end time UTC>
**Severity:** <SEV1 / SEV2 / SEV3>

## Timeline
- <HH:MM> First alert (source: <Cloudflare notification / on-call eyes / customer report>)
- <HH:MM> `panic under-attack` activated
- <HH:MM> Top ASN identified as <ASN>; blocked
- <HH:MM> `/api/<path>` identified as the hot endpoint; rate-limit rule deployed
- <HH:MM> Traffic returned to baseline
- <HH:MM> `panic restore` ran; `under_attack` lifted

## Signals
- Top ASNs: <list>
- Top URLs: <list>
- Top countries: <list>
- Cache hit rate during attack: <X%> (vs <Y%> baseline)
- Origin response time during attack: <X ms> (vs <Y ms> baseline)
- WAF blocks: <count>
- 5xx count: <count>

## Actions taken
- <bullet>
- <bullet>

## What worked
- <bullet>

## What didn't
- <bullet>

## Follow-ups (own by name + date)
- [ ] <Person>: codify the rate-limit rule as a permanent Custom Rule (was emergency-deployed). Due <date>.
- [ ] <Person>: review whether `panic block asn <N>` should become a permanent IP Access Rule. Due <date>.
- [ ] <Person>: add `<endpoint>` to the rate-limit-rules.starter.json. Due <date>.
- [ ] <Person>: schedule a `panic` rehearsal on a non-prod zone within 30 days. Due <date>.
```

---

## After the attack ends — checklist

- [ ] `bash snitch-cloudflare.sh panic restore` to revert under-attack mode and any temporary blocks. Verify in the dashboard.
- [ ] Re-run `bash snitch-cloudflare.sh check` and compare against the snapshot from before the attack.
- [ ] Pull WAF analytics for the full attack window — export to CSV for retention.
- [ ] Capture the top 100 attacker IPs and ASNs. Decide which to keep blocked permanently via IP Access Rules.
- [ ] Promote any emergency rules to permanent ones via `bash snitch-cloudflare.sh fix waf` (and remove the temporary ones).
- [ ] Review `bash snitch-cloudflare.sh report` — the report's "Recent incidents" section should reflect this event.
- [ ] If the attack hit a specific endpoint, add it to `templates/rate-limit-rules.starter.json` and re-apply.
- [ ] Notify customers if there was user-visible degradation (status page update, email if SLA-breaching).
- [ ] Schedule the postmortem review meeting.
- [ ] If this attack mode wasn't already in your runbook, add it.
