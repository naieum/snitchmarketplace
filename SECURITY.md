# Security policy

## Reporting a vulnerability

Found a security issue in a Snitch skill — a prompt-injection vector, an unsafe
script, a rule that leaks data it should redact?

Report it at **[snitchplugin.com/contact](https://snitchplugin.com/contact)** and
say "security" in the first line. Security reports go to the top of the pile;
expect a first reply within two working days.

Please do not open a public issue for an exploitable problem before we have had
a chance to ship a fix. Credit is given in the changelog unless you ask otherwise.

## Scope

- The skills in this repository (`skills/*`), including their bundled scripts.
- The install script served at `https://snitchplugin.com/snitch.sh`.

## What the skills will never do

Every Snitch skill is read-only during a scan, runs entirely inside your coding
agent on your own model, and makes no network calls home. Anything that violates
that is a vulnerability — report it.
