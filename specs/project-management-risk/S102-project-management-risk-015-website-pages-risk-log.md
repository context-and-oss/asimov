---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T015"
title: "Website pages name the risk log"
role: human
tier: mid
after: [T014]
traces: [R4, AC4]
owns:
  create: []
  modify: [site/inside/project-management.html, site/artifacts/project-management/index.html, documentation/features/D101-website.html]
  test: []
  regenerates: []
consumes: [risk-log-definition.md, "asimov-project (plugins/asimov-plugin/skills/asimov-project/SKILL.md)", "site-project-management.html (documentation/features/mockups/d101-project-management-risk/site-project-management.html)"]
produces: []
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T015 — Website pages name the risk log

## 1. Intent

The Asimov website describes the Project frame's risk log as available, on the day it ships: a public page that says "Nothing yet" and "planned" while the plugin carries the register is worse than none (D101 R4, §7.5, AC4).

## 2. Behaviour

none: this task adds no behaviour; its check is the link check and the `git status` command in §3.

## 3. Done-when

1. `node documentation/website/check-links.mjs` exits 0 and prints `ok:` with every page's links resolving.
2. `git status --short -- site/inside/project-management.html site/artifacts/project-management/index.html documentation/features/D101-website.html` prints the three files as modified and nothing else.

## 4. Constraints and stops

- **Must:** *What's inside → Project management* (`site/inside/project-management.html`) replaces "Nothing yet" under *What lands in your repo* with the risk log as the mockup's *After this design* state shows it: the page at `project/risk-log.html`, how to start it with `/asimov-project risk log` (and `$asimov-plugin:asimov-project risk log` in Codex), and what it keeps; the *delivery model* and *Ask it* sections keep their content.
- **Must:** *Artifacts → Project management* (`site/artifacts/project-management/index.html`) drops its *planned* chip and lists the risk log as the frame's first artifact with an `assess` chip, linking the definition and the template under `plugins/asimov-plugin/artifacts/project/risk-log/` on GitHub, so its chip equals the definition's `maturity` (`D101-website.html` AC3).
- **Must:** neither page contains the words "planned" or "Nothing yet" (AC4), which removes the bullet that says more skills are planned as a `pm-*` family.
- **Must:** `D101-website.html` AC6, and the clause of R6 it verifies, say what the two pages now say, and the document's version moves on from Draft v0.4, in the same commit as the pages (D101 §7.5).
- **Must not:** add a page under `site/`, change the navigation of any page, or give the Project column of the phase diagram on `site/inside/index.html` a box (design S4).
- **Prefer:** the chip and the *Definition · Template* links as `site/artifacts/documentation/s101.html` carries them.
- **Stops:** the definition's `maturity` is not `assess` when this task runs: report it, since the chip must equal it.

## 5. Out of scope

- D100 and `CLAUDE.md` — T016
- The product's documentation site listing the register — OOS3
- A website page of its own for the risk log, or the closure report and project setup beyond naming them as next
