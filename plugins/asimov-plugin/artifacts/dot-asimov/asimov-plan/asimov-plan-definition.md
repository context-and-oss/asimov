---
artifact: asimov-plan
maturity: assess
since: 2026-11-17
---

# Definition of the plan

The written standard a plan must meet before it is rendered into the S101 and the S102s the Build stage runs on. A plan is **one file**, `.asimov/plans/<slug>.md`, that carries the whole specification of `contracts/specification.md` for one design: the plan part (the tree, the contracts, the constraints, the coverage, the escalation, the assumptions) and every task part (owned files, names, intent, behaviour, done-when, constraints, out of scope), written by one writer in one pass and approved by the person with one go.

Read by agents: `asimov-spec` through the method files beside this one, `asimov-plan-authoring.md` (the writer's), `asimov-plan-validation.md` (with `scripts/validate-plan.ps1`) and `asimov-plan-view.md`; the renderer `scripts/render-plan.ps1` turns it into the files the Build stage reads. A person sees the plan through the view; the file is written for the agents and kept exact and short.

Design: `documentation/features/D101-spec-stage.html` (rewritten for this form after its first run). Research: `documentation/research/S101-S102-spec-stage-research.md`, `documentation/research/specification-contract-research.md`.

---

## 1. What a plan is for

The S101 and the S102s are the data model the build runs on: one file per agent, a header that is the whole brief, disjoint owned sets, a tree the ledger follows. That model is right for the build and wrong for the writer. The first runs had the writer produce it directly, one S101 and then one S102 per task phase by phase, and paid for it twice: every plan defect surfaced one task spec at a time, each through the person's gate, and the writer spent its context keeping headers equal to task lines, consumed names equal to contract rows and owned sets disjoint across files. The plan separates the two: the writer writes the specification once, in one file where a task sits next to its tree line and its neighbours, the script keeps the data model in step, and the person approves once.

A plan answers, in one place, what the S101 and the S102 answer in theirs (`s101-implementation-plan-definition.md` §1, `s102-task-spec-definition.md` §1): which tasks in which order, what may run together, what each relies on from the others, what must hold everywhere; and per task what, where, against what, done when, stop when.

## 2. The bar

A plan clears one bar: **what it renders to clears the S101's and the S102s' bars**. Dispatch-ready for the S101 (`s101-implementation-plan-definition.md` §2) and buildable blind for every S102 (`s102-task-spec-definition.md` §2), checked on the rendered form by one script before the person sees the cut, with two rows gone because the rendering makes them hold by construction: a task spec's header equals its task line, and every task spec of a rendered plan carries its validated mark. A plan that fails is re-cut unseen; the person sees a plan whose checks are clean, or a `design:` finding that stops the run.

**The person approves the plan; the script approves the task specs.** The go at the cut is the approval. `render-plan.ps1` writes it into the plan and the S101 with the person's name, the date and the S101 fingerprint (`s101-implementation-plan-definition.md` §6, the same twelve hex characters `ledger.ps1` computes), sets both `ready` and marks every S102 `validated` with the date: a rendered task spec was checked as part of the plan that was approved, so no second check and no second approval exist. A plan whose approved parts change after the go is shown again and approved again; the version is bumped so two approved plans never share a number.

## 3. Relationship to other documents

| Doc | Stage | What it answers |
|---|---|---|
| **D100** or any architecture that meets `contracts/architecture.md` | Before Design | The product's parts, how it starts, where each part lives, what was decided; the Foundation realises it |
| **D101** or any design that meets `contracts/design.md` | Design | What feature, what scope, what rules, what verifiable outcomes |
| **`contracts/specification.md`** | Spec → Build | The members a plan provides, plan part and task part, and the line between what the spec fixes and what the builder decides |
| **Plan** | Spec | The whole specification as the writer writes it and the person approves it |
| **S101**, **S102** | Spec → Build | The same specification as the build consumes it: rendered from the plan, never written by hand |
| Ledger | Build | Run state; never in the plan |

- **One design produces one plan**, and one plan renders to one S101 and one S102 per task. The S101 and S102 definitions keep their bars, templates and placement; they say what the rendered files are. This definition says how they come to be.
- **The plan is the only place a specification is written or changed.** A re-cut, a correction at the gate, a hand edit after the go: all in the plan, then rendered again. An S101 or S102 edited by hand is overwritten by the next render.
- **The plan is not the ledger.** The build moves the S101's status (`ready` → `in progress` → `done`) and writes the ledger beside it; the plan stays as it was approved. `asimov-spec` refuses to re-cut a plan whose S101 is `in progress` or `done`.

## 4. Required content

The plan's frontmatter and tree are the S101's (`s101-implementation-plan-definition.md` §4.1, §4.3, §4.4), with `spec: plan`; its six plan sections are the S101's body (§4.2, §4.5 to §4.9); each task section is an S102 (`s102-task-spec-definition.md` §4.1 to §4.7): the yaml block is the header's three machine-read members, the five numbered sections are the body. The template beside this file, `asimov-plan-template.md`, fixes the shape, and its leading comment the rules a writer with only the template needs.

Two rules are the plan's own, learned from two greenfield runs:

- **The Foundation realises the architecture.** When a part the design names is `planned` in the product's D100 (no project for its stack yet), the plan has a Foundation whose scaffolding task creates the solution, the projects and the test projects exactly as the D100's §6 Layout says, with the stack's template commands, owns the folders the templates write as globs and names the commands in its §4. The Foundation's checkpoint is the D100's §5.1 start: the product starts as written there and the baseline tests pass; its `check` is the test command. The template's own files are then owned, not review findings, and the first slice builds against a product that runs.
- **Layout and start are never the plan's to decide.** A plan invents no root, no solution file, no target framework and no way to start the product; it reads them from the D100 and the conventions and records what it realised in §2 with the source *D100 §6* or *D100 §5.1*. A part the design names that no architecture carries is a gap the design stage closes (a `design:` assumption; `asimov-spec` stops on it before the cut). The run that asked these in chat and took defaults cost a re-cut, a new approval, a new ledger and a Foundation that could not start.

## 5. Lifecycle

`status: draft` from the first write; `ready` when `render-plan.ps1` has rendered it with an approval that holds. The writer sets `draft` on every write; the script sets `ready`; nobody sets either by hand. `approved: none` until the go, then `{ by, date, fingerprint }`, written by the script alone. `version: 0.1` at the first write, unchanged through the cut rounds before the go, bumped by the script when an approved plan is approved again after its approved parts changed (the tree, §2, §3, §6, the parts the view shows).

A re-run against a design that already has a plan takes the S101 definition's two paths, update in place or rewrite (§6 there), decided by comparing the design's items with the plan's coverage map; the plan is re-cut by the writer and rendered again. A `ready` plan named again is re-checked: validated, rendered without a new approval when the approved parts are unchanged, shown and approved again when they are not.

## 6. Placement and naming

`.asimov/plans/<slug>.md` in the product repo; `<slug>` the D101's slug or the ticket key in kebab-case. Gitignored working state, like everything under `.asimov/`: a plan is a working document, rewritten many times in a day, and git carries the code it led to. Beside it: `<slug>.design.md`, the normalised design of a ticket in the shape the S101 definition §9 fixes, and `<slug>.review.md`, the last validation report and the writer's template findings, overwritten by every run. The rendered files land in `.asimov/specs/<slug>/` (`s101-implementation-plan-definition.md` §9, `s102-task-spec-definition.md` §9), the ledger beside them (`s101-ledger-definition.md` §7). The three folders are a lockstep literal of hard rule 9.

## 7. The checks

The plan's checks are the S101's (`s101-implementation-plan-definition.md` §8) and the S102's (`s102-task-spec-definition.md` §8), run by `scripts/validate-plan.ps1` on the rendered form in one call; `asimov-plan-validation.md` beside this file lists every row and is the script's specification and the fallback without PowerShell. The script runs nothing and judges no content: whether the phases are sensible, the scenarios the right ones, the cut too fine or too coarse is the person's at the cut and the reviewer's at the PR.
