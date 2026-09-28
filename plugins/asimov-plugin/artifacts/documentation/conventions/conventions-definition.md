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
- A **managed region** between `<!-- asimov:start -->` and `<!-- asimov:end -->` holding the skeleton read-list: the convention files to read, as links, one line each.
- Room outside the markers for the team's own text, which no run touches.

## 3. Rules

- **Detected stacks only.** Scaffolded for a stack the detection table finds, never for a guessed one. No stack detected, no folder.
- **Written when absent, refreshed when present.** An existing file keeps everything outside the markers; only the managed region is regenerated.
- **A skeleton is not a convention.** Asimov never authors the rules. A subagent that finds only the skeleton reports the gap instead of inventing defaults.
- The template's leading authoring comment never reaches the rendered file.

## 4. Relationship

| File | Role |
|---|---|
| `conventions-readme-template.md` | The skeleton, with the managed-region markers |
| `documentation/features/D101-asimov-init.html` | The command that scaffolds it (R6–R9, NF7, OOS2) |
| `documentation/features/D101-subagents.html`, D100 §7.2.1 | The subagents that read it |
