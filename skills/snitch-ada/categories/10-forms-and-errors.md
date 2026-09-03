## CATEGORY 10: Labels, error identification and suggestion, redundant entry, accessible authentication

Forms are where accessibility failures cost people money. An input with no programmatic label is announced as "edit text, blank" and the person filling it is guessing. An error surfaced only as a red border is invisible to anyone who cannot see red, or cannot see. A checkout with no review step and no reversal turns a mis-keyed quantity into a charge. A login that only accepts a distorted-character puzzle locks out anyone with a cognitive or visual disability, permanently.

Six criteria: three Level A, three Level AA, two of them new in WCAG 2.2. This is the category that appears most often in demand letters, and it is almost entirely checkable from source.

**Boundary.** This category asks whether the form meets its criterion. Whether the form has too many fields, drops people off, or asks for commitment too early is the sibling's judge — call the Skill tool with "snitch-ux". Whether the form converts, and whether its trust signals sit at the decision moment, is a third judge — call the Skill tool with "snitch-marketing". The same missing `<label>` can appear in all three reports; the criterion belongs here, the friction belongs to ux, the conversion belongs to marketing.

**Overlap with Category 11.** An unlabeled input fails 3.3.2 **and** 4.1.2, because a control with no accessible name has no name to expose. Report the label failure **once**, here, under 3.3.2, and cite 4.1.2 in the same finding's Rule line. Do not emit a second finding in Category 11 for the same element. Category 11 owns the name, role and value of everything that is **not** a natively labelable form control: custom widgets, icon-only buttons, live regions.

### Pre-flight

Run wherever the surface accepts input: sign-up, sign-in, search, contact, checkout, settings, filters, comment boxes, newsletter fields. A single search input is enough to bring the category into scope.

Skip with reason `not applicable` only when there is no `<input>`, `<select>`, `<textarea>` or `contenteditable` region on any audited surface.

Read every form on the conversion path in full before quoting any of it. Label association, error wiring and the review step are properties of the whole form, not of one line.

### Rule table

One row per success criterion. A finding names its row. A form check with no row here is a Skip, never a finding under a borrowed SC.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 3.3.1 Error Identification | A | When an input error is automatically detected, the item in error is identified and the error is described **in text** | error state carried only by a border color, a background tint or an icon with no text; error text rendered with no `role="alert"` / `aria-live` and no `aria-describedby` link from the field; the erroring field not named in the message | No | High |
| 3.3.2 Labels or Instructions | A | Labels or instructions are provided when content requires user input | `<input>` / `<select>` / `<textarea>` with no `<label for>`, no wrapping `<label>`, no `aria-label`, no `aria-labelledby`; placeholder used as the only label; required fields marked by color alone or by a bare asterisk with no legend | No | Critical |
| 3.3.3 Error Suggestion | AA | When an error is detected and a correction is known, the suggestion is provided, unless it would jeopardize security or purpose | validation copy that is only "Invalid", "Error", "Required" or "Try again", with no expected format, allowed range or suggested value | No | Medium |
| 3.3.4 Error Prevention (Legal, Financial, Data) | AA | Pages causing legal commitments or financial transactions, modifying or deleting user-controllable data, or submitting test responses are reversible, checked, or confirmed | checkout, subscription, cancellation, account-deletion or data-purge submit handlers with no review step, no confirmation step and no undo path | No | High |
| 3.3.7 Redundant Entry (new in 2.2) | A | Information already entered in the same process is auto-populated or selectable, unless re-entry is essential | multi-step flows re-asking for the same value: a second email field for confirmation, a billing address form with no "same as shipping" control, a wizard that re-prompts for a name already captured | Partly — the flow needs walking | Medium |
| 3.3.8 Accessible Authentication (Minimum) (new in 2.2) | AA | An authentication step does not rely on a cognitive function test unless an alternative, a mechanism to assist, or object-recognition / personal-content authentication is available | CAPTCHA-only or puzzle-only auth with no alternative path; password fields blocking paste (`onpaste="return false"`, `onPaste` preventDefault) or suppressing password managers; transcription-only or memory-only steps | No | Critical |

**3.3.7's exception** is re-entry that is essential: a password confirmation on account creation is essential, a memory test is not. Say which you judged it to be.

**3.3.8's permitted alternatives, as the criterion states them.** A form of authentication that does not rely on a cognitive function test; a mechanism that assists the user in completing it; object recognition; or personal content the user provided. An emailed magic link, a passkey, a one-time code the browser can autofill, and a "recognize your own uploaded photo" step all satisfy it. Note that **object recognition** is explicitly allowed: an image CAPTCHA that only asks the user to identify objects is not automatically a failure, while a distorted-text or puzzle CAPTCHA with no alternative is.

**Blocking paste is a 3.3.8 failure, not a nicety.** Password managers and paste are the mechanism that lets people avoid the cognitive test of recalling and transcribing a password. Suppressing them removes the mechanism the criterion depends on.

### Evidence required

A finding needs an observation and a criterion. The observation is a quoted element at `file:line` (source mode) or URL plus selector with the rendered HTML (crawl mode), or a runner rule id with its node.

**Source mode, cheapest first:**

1. `Grep` for `<input`, `<select`, `<textarea`, `contenteditable`. For each, resolve the label: a `<label for>` whose value matches the `id`, an ancestor `<label>`, an `aria-label`, or an `aria-labelledby` pointing at an existing element. Record the lookup result, not just its absence (3.3.2).
2. `Grep` for `placeholder=` on fields with no other label. Placeholder text disappears on entry and is not a label (3.3.2).
3. `Grep` for `required`, `aria-required`, and required markers in the markup. Record how required-ness is conveyed: text, a legend, or color and an unexplained asterisk (3.3.2).
4. `Read` each form's error path: where the error string is produced, where it renders, whether the field carries `aria-describedby` pointing at it, and whether the container carries `role="alert"`, `role="status"` or `aria-live` (3.3.1).
5. `Read` the error strings themselves. Record whether each names the expected format, the allowed range or a suggested value (3.3.3).
6. `Grep` for constrained fields — date, phone, postal code, password, card number, tax id — and record whether a format hint exists in a label, a helper text or an `aria-describedby` target (3.3.2, 3.3.3).
7. `Grep` for submit handlers on high-consequence flows: `checkout`, `purchase`, `subscribe`, `cancel`, `delete`, `deactivate`, `transfer`, `submitExam`. `Read` each for a review step, a confirmation dialog, or an undo window (3.3.4).
8. `Read` multi-step flows end to end and list every value asked for twice. Record whether a copy control, an autofill token or a stored value exists (3.3.7).
9. `Grep` for `captcha`, `recaptcha`, `hcaptcha`, `turnstile`, `puzzle`, and read the auth route for an alternative path. `Grep` for `onPaste`, `onpaste`, `autocomplete="off"` and `autocomplete="new-password"` on sign-in fields (3.3.8).

**Crawl mode:**

1. `Fetch` each form-bearing URL. Quote the input's rendered HTML with its selector and the label lookup you performed against the served DOM.
2. Quote the served error markup where it is present in the initial response; where errors render only after a client-side submit, say so and Skip that half.
3. Quote the auth page's markup, including any CAPTCHA widget and any alternative link.

**Caveat for client-rendered forms.** A plain fetch returns the shell for a client-rendered form. If the inputs are not in the served HTML, say so and Skip with `client-rendered form not verifiable without a JS-rendering fetch` rather than reporting a missing label that a hydration pass would have supplied.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. Submit each form empty and with bad values, and record what is announced and where focus lands.
2. Walk the multi-step flow and record every value asked for twice (3.3.7).
3. Attempt the auth flow using only the alternative path (3.3.8).
4. Complete a purchase or a deletion in a test environment and record whether a review, a confirmation or a reversal exists (3.3.4).

If none is available: `Skip — error announcement behaviour requires a human or runner; not run`, `Skip — multi-step flow walk requires a human or runner; not run`, and report only the static findings.

### Forbidden claims

- "Some fields may be missing labels." Enumerate them, with the failed label lookup quoted per field.
- "The placeholder acts as the label." State it as the failure it is, with the element quoted, rather than as an observation.
- "Errors are probably not announced." Quote the error component and its missing `role="alert"` / `aria-live` / `aria-describedby` wiring, or Skip.
- "The error message is unhelpful." Quote the string and the field's real constraint, and name the correction that was known and not offered (3.3.3).
- "CAPTCHA is inaccessible." Name the CAPTCHA type and the absence of an alternative path. Object-recognition CAPTCHA is explicitly permitted by 3.3.8.
- "Checkout is risky." 3.3.4 asks for reversible, checked or confirmed. Say which of the three is absent.
- Never write "compliant", "conformant" or "non-compliant" as a verdict. Write "fails SC 3.3.2 at these fields" and let the reader draw the line.

### Detection

Source or rendered-DOM audit of every form on the audited surfaces: label association, required marking, format hints, error production and its ARIA wiring, high-consequence submit paths, multi-step value reuse, and the authentication step.

### What to Search For

- `<input>` / `<select>` / `<textarea>` / `contenteditable` and the label lookup for each
- `placeholder=` on fields with no other label; `title=` used as a label substitute
- `required` / `aria-required`, asterisks, and whether a legend explains them
- `aria-describedby`, `role="alert"`, `role="status"`, `aria-live` on error containers, and their absence
- Error strings: "Invalid", "Error", "Required", "Try again", "Something went wrong"
- Constrained fields with no format hint: date, phone, postal code, password rules, card number, tax id
- Submit handlers on checkout, subscription, cancellation, deletion and exam flows, and any review or confirmation step
- Multi-step flows and every value asked for more than once; "same as shipping" and "confirm email" patterns
- `captcha`, `recaptcha`, `hcaptcha`, `turnstile`, `puzzle`, and the alternative auth path
- `onPaste` handlers and `autocomplete` values on sign-in and password fields

### Actually Fails

- **Input with no programmatic label** (3.3.2, cite 4.1.2 in the same finding). Evidence: the element plus the failed `<label for>` / wrapping-label / `aria-label` / `aria-labelledby` lookup.
- **Placeholder used as the only label** (3.3.2). Evidence: the input with its `placeholder` and no other naming attribute. The text disappears the moment the person types.
- **Required marked by color alone, or by an asterisk with no legend** (3.3.2). Evidence: the marker and the absent explanation.
- **Constrained field with no format instruction** (3.3.2). Evidence: the field, its real constraint, and the absence of a hint anywhere reachable from it.
- **Error surfaced only by color, or only on submit with no announcement** (3.3.1). Evidence: the error styling or the error component and its missing live-region and `aria-describedby` wiring.
- **Error text that does not name the field in error** (3.3.1). Evidence: the message and the form it belongs to.
- **Error message with no suggested correction when the correction is known** (3.3.3). Evidence: the message string beside the validation rule that produced it.
- **Legal, financial or data-destructive submission with no review, no confirmation and no reversal** (3.3.4). Evidence: the submit handler and the absent step.
- **Multi-step flow re-asking for a value already entered** (3.3.7). Evidence: both prompts, and the absence of an autofill token, a stored value or a copy control.
- **CAPTCHA-only or puzzle-only authentication with no alternative** (3.3.8). Evidence: the auth step and the absence of an email link, a passkey, a one-time code or an object-recognition alternative.
- **Password field blocking paste or suppressing password managers** (3.3.8). Evidence: the `onPaste` handler or the `autocomplete` value that breaks manager fill.

### NOT a Failure

- A visually hidden `<label>` that is present in the accessibility tree. Hidden is not absent.
- `aria-label` on a search input whose visible label the design deliberately omits, where the name describes the field.
- A placeholder used **alongside** a real label, as an example value.
- An asterisk convention with a legend that explains it ("Fields marked * are required"), or required-ness stated in the label text.
- Errors rendered inline on blur with text, linked by `aria-describedby`, in addition to a color change. Color plus text is the correct pattern.
- A generic message where the correction genuinely is not known, or where naming it would leak security information: "Email or password is incorrect" on a sign-in form is the right answer, not a 3.3.3 failure.
- A password confirmation field on account creation. Re-entry there is essential and 3.3.7's exception covers it.
- A "same as shipping" checkbox that populates the billing address. That is the 3.3.7 fix, working.
- A checkout with an order-review page before the charge, or an undo window after it. Reversible, checked **or** confirmed: any one satisfies 3.3.4.
- Object-recognition authentication, personal-content authentication, biometrics, passkeys or emailed one-time codes. All are permitted alternatives under 3.3.8.
- A CAPTCHA that also offers an audio or an email-link path.
- `autocomplete="new-password"` on a **registration** form. That is its correct use; the failure shape is suppressing autofill on sign-in.

### Context Check

1. Is the form client-rendered? If the inputs are absent from the served HTML, read the component, or Skip with that reason.
2. Does a design-system field wrapper supply the label automatically, unused because this call site passed no `label` prop? Read the wrapper before flagging.
3. Is the error string generated server-side and rendered into a container that already carries a live region higher up? Trace the container.
4. Is the correction genuinely known? A security-sensitive message is exempt from 3.3.3 by the criterion's own wording.
5. Does the flow cause a legal commitment, move money, delete user data, or submit test responses? Only then does 3.3.4 apply.
6. Is the repeated value essential to re-enter, or merely convenient for the backend? Say which.
7. Does the auth step offer any alternative at all, including one behind a "having trouble?" link? Look before claiming none.
8. Does the fix touch validation logic that a security control depends on? Surface the change and get explicit confirmation before applying it.
9. Are the same fields also being judged for friction or for conversion? Cross-file rather than double-count — call the Skill tool with "snitch-ux" for the friction half.

### Severity

- **Critical** — input with no programmatic label, including a placeholder-only field (3.3.2); authentication that requires a cognitive function test with no alternative, including a password field that blocks paste or password managers (3.3.8).
- **High** — error identified only by color, or surfaced with no text and no announcement (3.3.1); a legal, financial or data-destructive submission with none of reversible, checked or confirmed (3.3.4).
- **Medium** — error message with no suggested correction where the correction is known (3.3.3); required marking carried by color or an unexplained asterisk (3.3.2); a constrained field with no format hint (3.3.2); a multi-step flow re-asking for a value already given (3.3.7).
- **Low** — a format hint present but buried below the field it governs, where an `aria-describedby` link would reach it.

### Fix guidance

Four fixes, in the order the criteria fail hardest.

**1. Give every field a real label** (3.3.2, and with it 4.1.2). The label is a separate element that stays on screen. The placeholder is an example, not a name.

```tsx
// Fails 3.3.2 and 4.1.2: announced as "edit text, blank"
<input type="email" placeholder="Email address" />

// Passes: a persistent label, a described format hint, an autofill token
<label htmlFor="email">Email address</label>
<input id="email" name="email" type="email" autoComplete="email"
       aria-describedby="email-hint" required />
<p id="email-hint">We use this to send your receipt. Example: you@company.com</p>
```

**2. Say what went wrong, in text, where it will be heard** (3.3.1, 3.3.3). Three parts: name the field, describe the problem, offer the correction.

```tsx
// Fails 3.3.1 and 3.3.3: a red border and the word "Invalid"
<input className={error ? "field field--error" : "field"} />
{error && <span className="error">Invalid</span>}

// Passes: text, linked to the field, announced when it appears
<input
  id="card-expiry"
  aria-invalid={!!error}
  aria-describedby={error ? "card-expiry-error" : undefined}
/>
{error && (
  <p id="card-expiry-error" role="alert">
    Expiry date must be MM/YY, for example 04/28. You entered “4-2028”.
  </p>
)}
```

Keep the color. Add the text beside it. Color is a second channel, never the only one.

**3. Put a step between the person and the irreversible thing** (3.3.4, 3.3.7). Any one of reversible, checked or confirmed satisfies the criterion — pick the one the flow can carry.

```tsx
// Fails 3.3.4: one click charges the card
<button onClick={charge}>Place order</button>

// Passes: a review step that restates what will happen, then the commit
<section aria-labelledby="review">
  <h2 id="review">Review your order</h2>
  <dl>…items, address, total…</dl>
  <button onClick={goBackAndEdit}>Change something</button>
  <button onClick={charge}>Place order — $84.00 will be charged now</button>
</section>
```

And stop asking twice. Carry the value forward instead.

```tsx
<label>
  <input type="checkbox" checked={sameAsShipping}
         onChange={e => setSameAsShipping(e.target.checked)} />
  Billing address is the same as shipping
</label>
```

**4. Offer a way in that is not a memory test** (3.3.8). A cognitive test with no alternative is the hardest failure in this category to argue away, and the easiest to fix: add a second door.

```tsx
// Fails 3.3.8: a distorted-text puzzle is the only path
<PuzzleChallenge onSolve={signIn} />

// Passes: the challenge stays for those it works for, and a real alternative sits beside it
<PuzzleChallenge onSolve={signIn} />
<a href="/auth/email-link">Email me a sign-in link instead</a>
```

```html
<!-- Fails 3.3.8: the manager cannot fill it and paste is blocked -->
<input type="password" autocomplete="off" onpaste="return false">
<!-- Passes: the manager fills it, paste works, the memory test is gone -->
<input type="password" autocomplete="current-password">
```

Every one of these fixes makes the form faster for everyone who was never blocked by it. That is the argument to make when someone asks what it costs.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

3.3.1 Error Identification: https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html · 3.3.2 Labels or Instructions: https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions.html · 3.3.3 Error Suggestion: https://www.w3.org/WAI/WCAG22/Understanding/error-suggestion.html · 3.3.4 Error Prevention (Legal, Financial, Data): https://www.w3.org/WAI/WCAG22/Understanding/error-prevention-legal-financial-data.html

3.3.7 Redundant Entry (Level A, new in 2.2): https://www.w3.org/WAI/WCAG22/Understanding/redundant-entry.html · 3.3.8 Accessible Authentication (Minimum) (Level AA, new in 2.2): https://www.w3.org/WAI/WCAG22/Understanding/accessible-authentication-minimum.html

Cognitive function test, defined: https://www.w3.org/TR/WCAG22/#dfn-cognitive-function-test

W3C ARIA Authoring Practices, for form and alert patterns: https://www.w3.org/WAI/ARIA/apg/patterns/alert/

HTML autofill token list: https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete · The `<label>` element: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/label

axe-core rule descriptions, for the runner rule ids quoted alongside an element: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
