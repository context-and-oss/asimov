---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T001"
title: "Risk log page template"
role: human
tier: mid
after: []
traces: [§6.4, NF1, NF2, NF3, NF6]
owns:
  create: [plugins/asimov-plugin/artifacts/project/risk-log/risk-log-template.html]
  modify: []
  test: []
  regenerates: []
consumes: ["_chrome.css (plugins/asimov-plugin/artifacts/documentation/site/_chrome.css)"]
produces: [risk-log-template.html]
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T001 — Risk log page template

## 1. Intent

The shape the script renders the register page from, and the schema it reads the page back by: one readable page in the documentation site's look, holding data, view and history, with no script (D101 §6.4, NF1, NF6).

## 2. Behaviour

none: this task adds no behaviour; its check is the `Test-Path` command in §3, and the slices from T003 on render and test the page built from it.

## 3. Done-when

1. `pwsh -NoProfile -Command 'Test-Path -LiteralPath plugins/asimov-plugin/artifacts/project/risk-log/risk-log-template.html'` prints `True`.
2. `git status --short -- plugins/asimov-plugin/artifacts/project/risk-log/` prints the template as a new file and nothing else.

## 4. Constraints and stops

- **Must:** carry every element and attribute of D101 §6.4 *The page* and *One risk*, spelled as there: `lang` on `html` for the project language; on `body`, `data-artifact="risk-log"`, `data-schema="1"`, `data-register` (`kept` or `opt-out`) and `data-updated`; the `h1` and a first paragraph; `ol.register-history` inside the `details` opened by the ⓘ beside the last-updated date, each `li` with `data-date`, `data-by`, `data-kind` and, for a review, `data-with`; `table.summary`; `section.opt-out` with `data-reason`, `data-where`, `data-by`, `data-date`; `article.risk` with `id`, `data-state`, `data-impact`, `data-probability`, `data-owner`, `data-area`, `data-created`, `data-changed`; its `h3` name with the score beside it; `.risk-desc` and `.risk-mitigation`; `ol.risk-history`, each `li` with `data-date`, `data-by`, `data-kind`.
- **Must:** hold both page forms, the kept register and the opt-out page titled *No risk register kept here* whose first paragraph is the reason (D101 F5).
- **Must:** show, folded, what 1 and 5 mean on the impact and the probability axis, and the sentence that the score ranks risks and does not decide what to do (NF2, NF3); the count per state at the top; risks grouped Active, Mitigated, Accepted, Occurred, Resolved, with Resolved last and folded (D101 §5 S1).
- **Must:** link the site's shared chrome stylesheet from where the page lands, `project/risk-log.html` beside `documentation/`, so `../documentation/_chrome.css`; the page's own component styles sit in one inline `<style>` block.
- **Must:** open with a leading comment, as the other templates do, naming every placeholder and every repeated block (a risk, a history line, a summary row, a state group) and which parts are rendered only and never read back (the score, the summary table, the counts).
- **Must not:** contain a `<script>` element, an event-handler attribute, or a score in any `data-*` attribute.
- **Prefer:** the layout and class names of `documentation/features/mockups/d101-project-management-risk/risk-log-page.html` (its scenario bar and script are mockup chrome only); the leading comment and the double-brace placeholders of `plugins/asimov-plugin/artifacts/documentation/site/site-template.html`.
- **Stops:** an element the mockup shows cannot be done without a script, or §6.4 names an element whose place on the page the mockup and D101 §5 S1 do not settle.

## 5. Out of scope

- The script that renders and reads the page — T002 (interface), T003 to T010 (behaviour)
- The risk-log definition and its maturity — T011
- Listing the page on the product's documentation site — OOS3
