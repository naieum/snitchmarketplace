# Scan Selection

Everything between "the user asked for a voice agent audit" and "the categories are locked in".
SKILL.md carries the summary; this file is authoritative for the menu, the preset resolution rule,
the confirm gate, the alias table and the token estimate. **Read it before showing the menu.**

Category numbers, slugs, groups and status all resolve against `categories/_index.md`, which is the
manifest of record. This file stores no ID lists. If a preset here and the manifest ever disagree,
the manifest wins and this file is the defect.

---

## The menu (STEP 1)

Display when the user asked for an audit without naming a scope:

```
Voice agent security audit for [project or agent name]

What would you like to audit?

[1] Quick — the checks that drain accounts and leak keys most often. Group: quick
[2] Ingress & secrets — webhook signatures, media sockets, client keys, token minting, deployment leftovers. Group: ingress
[3] Injection — speech, DTMF, caller metadata, retrieved records, prompt hygiene, config tampering, tool output. Group: injection
[4] Identity & actions — who the caller is, what they may see, what tools may do, dial/transfer/message control. Group: actions
[5] Abuse & cost — duration, silence, concurrency, spend caps, outage behavior, audit trail. Group: abuse
[6] Privacy & compliance — recordings, transcripts, redaction, consent, AI disclosure, sector regimes. Group: privacy
[7] Full — every active category
[8] Custom — name categories by number, slug or alias

[0] Exit

Enter your choice (0-8):
```

Show the resolved category count and token estimate for each option beside it, computed at display
time from the manifest with the rule below. Never hardcode those numbers into this file — a manifest
row changing status must change the menu automatically.

## Menu behavior

- **[0]** display `Audit cancelled. No changes made.` and exit.
- **[1] to [6]** resolve the named group per the rule below and go to the confirm gate.
- **[7]** every active row. Show the token estimate and require an explicit confirmation of the
  budget before launching.
- **[8]** ask for the selection, parse it with the alias table below, and go to the confirm gate.
- **Invalid input** display `Invalid choice. Enter 0-8.` and re-display the menu.
- **Arguments already given** skip the menu, parse them, and go straight to the confirm gate.

### When the menu must fire, and when it may be bypassed

- **Bypass allowed — the scope is explicit.** "quick voice audit", "check the webhooks", "can a
  caller make it transfer money", "is the recording setup legal", "run categories 12 and 14",
  "audit the tool webhooks". The user named a preset, a category, or a question one preset
  answers. Proceed without the menu, but still show the confirm gate.
- **Menu required — the scope is ambiguous.** "audit my voice agent", "is this safe", "check the
  bot", "we're about to launch the phone line". Show the menu and wait.

When in doubt, show the menu.

---

## Preset resolution

A preset resolves to **every active row in `categories/_index.md` whose Groups cell contains that
preset's slug**. Read the manifest at scan time and resolve by attribute. Never store, cache or
hardcode an ID list, here or anywhere else.

```
selected = [row.id for row in manifest
            if row.status == "active"
            and preset_slug in row.groups]
```

The six group slugs are `quick`, `ingress`, `injection`, `actions`, `abuse`, `privacy`. `full` is
a distinct case: every active row, regardless of Groups.

Consequences that matter:

- A category added to the manifest with `quick` in its Groups cell joins the Quick audit with no
  edit here.
- A category whose Status changes to `merged→NN`, `moved→snitch-<skill>` or `deleted` leaves every
  preset automatically, and its number stays reserved.
- A preset that resolves to zero active rows is reported as such, rather than silently running
  nothing.

A preset is a starting point, not a lock. After resolution the user can add or remove categories at
the confirm gate.

### Smart narrowing inside a preset

The inventory from STEP 0 (`references/smart-detection.md`) can make a selected category
inapplicable before it runs: no outbound dialing means Cat 14's outbound rows Skip, no recording
means Cat 23 Skips, a hosted platform with no exported config makes several posture rows Skip per
Rule 6. **Narrowing never removes a category from the selection.** The category runs, produces its
Skips with the inventory as the reason, and appears in the coverage block. That is how the report
proves the check was considered.

---

## The confirm gate

Always display the resolved scope. An explicit bounded request (named checks and supplied
surface, without scope expansion) is already confirmation: display and proceed. Ask and wait for
ambiguous scope, a full sweep's budget, or a proposed expansion. Display:

```
Resolved selection: <preset name or "Custom">

  Cat 01  webhook-authenticity            posture        H1
  Cat 05  caller-identity-trust           sink-pattern   H2
  ...

  Categories: N of M active
  Hop coverage: this selection has a primary category on K of the 11 call-path hops.
    The other 11-K will appear in the report's coverage block as Skip with a reason.
  Stack: <platforms and providers from the inventory>
  Call surface: <inbound / outbound / web-client / all, from the inventory>
  Platform config in workspace: <exported | not exported — platform-side rows will Skip>
  Estimated cost: ~<low>-<high>K tokens

Proceed? [yes / add <cats> / remove <cats> / change scope / cancel]
```

Rules for the gate:

- **The hop-coverage line is required.** It is what stops a partial scan reading like a full one.
- **`add` and `remove`** re-resolve and re-display the gate. No limit on rounds.
- **`change scope`** returns to STEP 0's inventory.
- **`cancel`** exits with `Audit cancelled. No changes made.`
- Where confirmation is needed, proceed only on an affirmative. Silence is not confirmation.

---

## Token estimate

```
estimate_low  = 6K + (1.5K * number_of_categories)
estimate_high = 6K + (1.5K * number_of_categories * 1.6)
```

6K is the fixed overhead: the anti-hallucination rules, smart detection, the inventory script,
the scan selection itself and the report scaffold. 1.5K per category is the category file plus its
search and read work.

Multipliers, applied to the high end and stated in the gate when they apply:

- **A stack file** (`references/stacks/<platform>.md`) adds ~2K per detected platform, once.
- **A large surface** (more than ~30 tool definitions, or more than ~3 platforms in one repo)
  pushes every category to the high end.
- **`references/legal-landscape.md`** adds ~4K once, when any compliance-typed category is
  selected.
- **`references/call-path.md`** adds ~1K once, whenever the report's coverage block is written.

Round the displayed estimate to the nearest thousand and always show it as a range.

---

## Alias table (Custom selection, `[8]`)

Parse a custom selection in this order: exact category ID, exact slug, then alias. Matching is
case-insensitive and ignores surrounding punctuation. A phrase that matches nothing is reported back
to the user with the closest three candidates rather than guessed at.

| The user says | Category |
|---|---|
| `webhooks`, `webhook signature`, `signature validation`, `callback auth`, `status callbacks` | 01 |
| `media stream`, `media streams`, `websocket`, `socket`, `stream url`, `sip`, `signaling`, `webrtc` | 02 |
| `client keys`, `api key in frontend`, `keys in the app`, `browser key`, `mobile key`, `public env`, `bundle secrets` | 03 |
| `ephemeral token`, `token endpoint`, `client secret`, `access token`, `session token`, `token minting`, `grants`, `ttl` | 04 |
| `caller id`, `ani`, `from number`, `cnam`, `spoofing`, `stir/shaken`, `voice biometrics`, `voice cloning`, `deepfake` | 05 |
| `verification`, `authentication flow`, `kba`, `otp`, `pin`, `account lookup`, `pii disclosure`, `step-up` | 06 |
| `prompt injection`, `speech injection`, `transcript injection`, `dtmf`, `keypad`, `ignore instructions`, `jailbreak` | 07 |
| `metadata`, `dynamic variables`, `variable values`, `custom parameters`, `sip headers`, `caller name in prompt` | 08 |
| `retrieval`, `knowledge base`, `kb`, `rag`, `crm notes`, `calendar`, `tickets`, `indirect injection` | 09 |
| `system prompt`, `prompt hygiene`, `prompt leak`, `secrets in prompt`, `repeat your instructions`, `instructions leak` | 10 |
| `assistant overrides`, `config tampering`, `client overrides`, `assistant id`, `agent config`, `inline assistant` | 11 |
| `tool auth`, `tool webhook`, `function auth`, `idor`, `tenant`, `cross-tenant`, `account access`, `authorization` | 12 |
| `confirmation`, `human in the loop`, `money`, `payment`, `refund`, `transfer money`, `bank`, `consequential`, `idempotency` | 13 |
| `transfer`, `dial`, `outbound`, `forwarding`, `toll fraud`, `premium rate`, `international`, `allowed countries`, `dtmf send` | 14 |
| `sms`, `text message`, `send sms`, `send email`, `messaging tool`, `sms pumping` | 15 |
| `tool output`, `error handling`, `stack trace`, `raw json`, `spoken errors`, `output handling` | 16 |
| `max duration`, `duration`, `silence`, `idle`, `timeout`, `turn limit`, `loop`, `keep on the line` | 17 |
| `concurrency`, `rate limit`, `flood`, `robocall`, `callback loop`, `retry storm`, `throttle` | 18 |
| `spend`, `budget`, `cost cap`, `token cap`, `max tokens`, `bill`, `denial of wallet`, `alerts on spend` | 19 |
| `resilience`, `fallback`, `dead air`, `outage`, `hang up`, `end call`, `disabled`, `mute`, `refuse`, `health check` | 20 |
| `recordings`, `transcripts`, `storage`, `retention`, `recording url`, `logs`, `s3` | 21 |
| `redaction`, `pci`, `card number`, `cvv`, `ssn`, `pii`, `pause recording`, `mask` | 22 |
| `consent`, `recording consent`, `two-party`, `all-party`, `announcement`, `this call may be recorded` | 23 |
| `disclosure`, `ai disclosure`, `bot disclosure`, `tcpa`, `robocall rules`, `do not call`, `dnc`, `outbound consent`, `ai act` | 24 |
| `hipaa`, `baa`, `pci dss`, `bipa`, `biometric`, `coppa`, `minors`, `glba`, `sector` | 25 |
| `ngrok`, `tunnel`, `http webhook`, `debug`, `test numbers`, `quickstart`, `deployment`, `env hygiene` | 26 |
| `audit trail`, `call logs`, `anomaly`, `alerting`, `monitoring`, `who did what`, `tool call log` | 27 |

Group aliases resolve to the preset, not to a category: `quick`, `ingress`, `secrets`, `injection`,
`prompt`, `actions`, `tools`, `identity`, `money`, `abuse`, `cost`, `limits`, `privacy`,
`compliance`, `legal`, `full`, `everything`.

Phrases that belong to a sibling skill are handed off rather than resolved here:

- `sql injection`, `xss`, `dependency cve`, `secrets in server code`, `cors on the api` → call the
  Skill tool with "snitch-security".
- `is the greeting confusing`, `does the menu make sense`, `conversation design` → call the Skill
  tool with "snitch-ux".
- `accessibility of the ivr`, `tty`, `relay service` → call the Skill tool with "snitch-ada".
