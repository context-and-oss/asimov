---
artifact: conventions
maturity: assess
since: 2026-09-10
---

# Definition of the convention read-list

`documentation/conventions/<stack>/README.md`: one per stack the repo uses, scaffolded by `/asimov-init` from `conventions-readme-template.md` in this folder. The build subagents read it at run-time as their convention overlay (D100 §7.2.1). Design: `documentation/features/D101-asimov-init.html`.

## 1. What it is for

A subagent writing code for a stack needs the repo's own rules — naming, layering, test style — without those rules being pasted into the subagent. This file is the read-list: it names the files that hold the rules, and the subagent reads them before writing.

## 2. Required content

- The stack it covers, in the folder name and the heading.
- A **managed region** between `<!-- asimov:start -->` and `<!-- asimov:end -->`, tool-owned: the heading and the explanation of what the file is and that only listed files reach the subagent. Never the read-list.
- The **read-list** below the end marker, user-owned: the convention files to read, as `@`-references, one line each. Seeded once from the template's example lines, then the team's.
- Room outside the markers for the team's own text, which no run touches.

## 3. Rules

- **Detected stacks only.** Scaffolded for a stack the detection table finds, never for a guessed one. No stack detected, no folder.
- **Written when absent, refreshed when present.** An existing file keeps everything outside the markers; only the managed region is regenerated, wholesale.
- **Two owners, one split.** Tool-owned text lives inside the markers and is replaced on every re-run with no merging; user-owned text lives outside them and is written once, on first scaffold, never again. The read-list is user-owned because it is the load-bearing index the subagents read (D100 §7.2.1): a run that regenerated it would silently empty the overlay. A read-list found inside the markers (a file scaffolded before this rule) is moved below the end marker by the run that refreshes the region, and the plan says so.
- **A skeleton is not a convention.** Asimov never authors the rules. A subagent that finds only the skeleton reports the gap instead of inventing defaults.
- The template's leading authoring comment never reaches the rendered file.

## 4. Relationship

| File | Role |
|---|---|
| `conventions-readme-template.md` | The skeleton, with the managed-region markers |
| `documentation/features/D101-asimov-init.html` | The command that scaffolds it (R6–R9, NF7, OOS2) |
| `documentation/features/D101-subagents.html`, D100 §7.2.1 | The subagents that read it |
