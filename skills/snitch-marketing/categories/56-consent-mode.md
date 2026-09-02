## CATEGORY 56: Consent-mode setup — moved to snitch-adsready

Consent Mode v2 defaults, CMP presence, per-platform consent wiring and the "do tags fire before the choice" check now run in the ads-readiness skill, which reads the same pixels it gates and knows each platform's consent call.

**Do not scan this file.** If category 56 is selected, call the Skill tool with "snitch-adsready" and report the consent findings from there. Marketing still reports the analytics-side signal it can see on its own: a pixel or tag is present but its consent wiring is unknown from here (Cat 53).
