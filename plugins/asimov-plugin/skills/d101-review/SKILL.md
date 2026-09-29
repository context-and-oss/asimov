---
name: d101-review
description: Review a D101 (HTML or legacy markdown). Resolves the phase, then offers the reviews that phase calls for — the gap review against the bar (§8a/§8b) plus the business- and technical-persona reviews — and runs the ones you pick. Runs the gap check itself, delegates each persona review to its skill. Never modifies the D101; never moves either axis.
argument-hint: (optional) path to D101 (.html or .md) to review — empty lists candidates in documentation/features/
allowed-tools: Read, Glob, Grep, Skill, Write
---

# d101-review

Reviews a D101: resolves its phase, offers the reviews that phase calls for — the gap review against the bar and the persona reads — and runs the ones the developer picks.

Read `method.md` in this skill's folder first and follow it. It carries the whole method; this file is only the entry.
