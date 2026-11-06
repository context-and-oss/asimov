---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T011"
title: "Risk log definition and maturity"
role: human
tier: mid
after: [T010]
traces: [R1, §6.1, AC26]
owns:
  create: [plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md]
  modify: [documentation/D100-Asimov-architecture.md]
  test: []
  regenerates: []
consumes: [risk-log-template.html, risk-log.ps1, "s101-ledger-definition.md (plugins/asimov-plugin/artifacts/documentation/s101-ledger/s101-ledger-definition.md)", "Risk management (plugins/asimov-plugin/processes/disciplines/risk-management.md)"]
produces: [risk-log-definition.md]
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T011 — Risk log definition and maturity

## 1. Intent

The risk log's contract: its fields, states, rules, the bar a register meets, and where it departs from the delivery model's risk discipline. The skills read it by path, and its `assess` level is mirrored in D100 in the same commit (D101 §6.3, §4.5, AC26).

## 2. Behaviour

none: this task adds no behaviour; its check is the `Get-Content` and `git status` commands in §3.

## 3. Done-when

1. `pwsh -NoProfile -Command 'Get-Content -TotalCount 5 plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md'` prints `---`, `artifact: risk-log`, `maturity: assess`, a `since:` line with a `YYYY-MM-DD` date, and `---`.
2. `git status --short -- plugins/asimov-plugin/artifacts/project/risk-log/ documentation/D100-Asimov-architecture.md` prints the definition as new and D100 as modified, and nothing else.

## 4. Constraints and stops

- **Must:** the definition states the fields (four required, three optional), the five states and what each requires, the rules RL1 to RL17 of D101 §4.4 with their counter-examples, the page as the record (`project/risk-log.html`, its data in attributes and lists, nothing derived read back), and the bar a register meets.
- **Must:** it states that at closure the register is reviewed first, the risks no longer relevant are resolved, and every risk not Resolved carries into the closure report (RL14, AC26).
- **Must:** it records where the register departs from the *Risk management* discipline (`plugins/asimov-plugin/processes/disciplines/risk-management.md`) (the Accepted and Occurred states, no fixed set of areas, the score as a rank only), since the corpus is not edited (OOS11).
- **Must:** D100 §4.5 gains a *Definition of risk log* row and a *Risk log template* row with the paths under `plugins/asimov-plugin/artifacts/project/risk-log/` and maturity `assess`, in the same commit as the definition.
- **Prefer:** the section order and the append-only rules of `s101-ledger-definition.md`.
- **Must not:** restate the template's markup or the script's parameters; name them by path.

## 5. Out of scope

- D100 §3, §4.3, §4.6 and §5, and `CLAUDE.md` — T016
- The closure report itself — OOS1
