<!--
  S101 IMPLEMENTATION PLAN template. One S101 per design (anything that meets
  contracts/design.md). It is the plan part of a specification as
  contracts/specification.md defines it: the task graph, the contracts between
  tasks, the constraints the design imposes, the coverage map, the escalation
  routing and the assumptions. The task part is the S102s. The bar is
  "dispatch-ready": s101-implementation-plan-definition.md §2.

  WHO READS THIS FILE
  - Agents. artifact-s101-authoring writes it, artifact-s101-validation checks
    it, the orchestrator reads it as its control document. A person sees the
    plan through the view asimov-spec prints at the cut and at the end, and
    asimov-spec prints on a re-check; nobody is meant to read the
    raw file. Keep it exact, keep it short.
  - Written to documentation/specs/{{SLUG}}/S101-{{SLUG}}.md in the product
    repo. {{SLUG}} is the D101's slug or the ticket key in kebab-case.
  - The first write is the CUT: this file alone, no S102 beside it. The author
    may edit it by hand at that point; every later write starts from the file
    on disk.
  - Strip THIS comment from the rendered file.

  THE GRAPH
  - phases[] is a tree: every task sits under its phase. Phases are in build
    order. P0 is the Foundation; P1..Pn are the slices, one per acceptance
    criterion a builder can make pass; a phase after the last slice may hold
    the work that closes the run (a release, a reference restored) and has a
    checkpoint like any other.
  - One task per line, YAML flow form: { id, title, role, tier, after, traces }.
    Validation parses it as YAML; quote a title that holds a colon.
  - id: T001, T002, … in order of appearance; NNN is the number of the task's
    S102 file, S102-{{SLUG}}-NNN-<task-slug>.md, found by that glob. Never
    renumber a task that already has an S102 on disk.
  - role: dotnet-builder | angular-builder | dotnet-tester | human. The closed
    list: a role-* skill without the prefix, or a person.
  - tier: low | mid | high. low = the change is fully determined by the name,
    the signature and the check; mid = behaviour in prose with a clear check;
    high = judgement or integration. A recommendation; the run picks the model.
  - after: the task ids this task depends on. Acyclic. In a slice the builder
    task comes after the tester task, so the test is red before the body is
    written. Every slice task comes after a Foundation task.
  - traces: ids of the design (R3, NF2, §6.4.1, AC5). A phase traces to the
    acceptance criterion it makes pass; a task to everything it serves.
  - Files, produced names and consumed names are NOT here. They are task
    members: the S102 header carries them, and validation reads disjointness
    and interface closure from the S102 headers and §1 below. Two tasks that
    may run together own disjoint file sets; the Foundation is cut so each
    slice owns its own skeleton file.
  - status: draft until asimov-spec sets ready, when the approval holds and
    every S102 is validated (definition §6). Never set by hand.
  - approved: none until the author's go at the cut; then
    { by, date, fingerprint }, written by asimov-spec and by no other skill.
    The fingerprint rule is in definition §6; a changed plan is approved again.

  THE BODY
  - Only what the graph cannot carry: the plan members of the contract.
    §1 Contracts, §2 Constraints, §3 Coverage, §4 Escalation, §5 Review focus,
    §6 Assumptions. No phase prose: the checkpoint is on the phase, the how is
    in the S102.
  - Never here: code, steps, test bodies (the S102's, and even there names
    only); run state (the ledger's); validation findings (the sidecar
    S101-{{SLUG}}.review.md); a product entity in THIS template (hard rule 7).

  PLACEHOLDERS
  {{SLUG}} {{TITLE}} {{D101-VERSION}} {{DESIGN-URL}} {{READ}} {{AUTHOR}} {{YYYY-MM-DD}} {{GOAL}}
  Keep one `design` line and delete the other. Everything in <angle brackets>
  is a description of what to write there. Sample rows show the shape.
-->
---
spec: S101
slug: "{{SLUG}}"
title: "{{TITLE}}"
design: { ref: documentation/features/D101-{{SLUG}}.html, version: "{{D101-VERSION}}" }
# design: { ref: "{{DESIGN-URL}}", read: "{{READ}}", cache: documentation/specs/{{SLUG}}/design.md }
status: draft
approved: none
version: 0.1
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
phases:
  - id: P0
    name: Foundation
    checkpoint: "<the build command, green, with every skeleton type and public method in place and no bodies>"
    tasks:
      - { id: T001, title: "<skeleton for one stack>", role: dotnet-builder, tier: low, after: [], traces: [§6.2.1] }
  - id: P1
    name: "<slice name, from the acceptance criterion it serves>"
    traces: [AC1]
    checkpoint: "<the slice's acceptance test, by name, is green>"
    tasks:
      - { id: T002, title: "<acceptance test of slice P1>", role: dotnet-tester, tier: mid, after: [T001], traces: [AC1] }
      - { id: T003, title: "<builder task of slice P1>", role: dotnet-builder, tier: mid, after: [T002], traces: [R1, AC1] }
---

# S101 — {{TITLE}}

{{GOAL}} Plans <`documentation/features/D101-{{SLUG}}.html` v{{D101-VERSION}} | [the design]({{DESIGN-URL}}), read {{READ}}>, approved by <who> on <date>.

## 1. Contracts

Every name one task produces and another consumes, stated once: the exact signature, or the design's contract number that states it. An S102 names these and never restates them. Existing code a task consumes is linked by path and never pasted.

| Name | Shape | Produced by | Consumed by |
|---|---|---|---|
| <InterfaceName> | <exact signature, or D101 §6.x.y> | T001 | T002, T003 |
| <ExistingType> | `<repo-relative path>` | existing code | T003 |

## 2. Constraints

What the design imposes on every task, and where this plan departs from the conventions. One line each, values verbatim, with the source. The conventions themselves are not repeated: the builder loads them.

- <constraint> — D101 §6.x
- <departure from a convention, and why> — `documentation/conventions/<stack>/<file>.md`

## 3. Coverage

Every requirement, contract and acceptance criterion of the design in scope, against the tasks that deliver it. An id with no task says why (*verified by review*, *out of scope here, per OOSn*). *Says* is the source's wording in one line: required for a normalised design, optional for a D101.

| Id | Says | Delivered by |
|---|---|---|
| R1 | <in the source's words> | T003 |
| AC1 | <in the source's words> | T002, T003 |
| AC2 | — | verified by review |

## 4. Escalation

- **Routes to:** <the person directing the run, by role; optionally an orchestrator agent for defects below a named threshold>
- **Stops specific to this plan:** <the conditions a builder in this plan stops on, beyond the generic ones in the S102 definition §5>
- **Reaches a human always:** an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, a plan so broken that every path forward is a guess.
- **Rulings are recorded in:** the ledger. Never in this plan or an S102.

## 5. Review focus

The failure modes the design implies that no task's check exercises. One line each: the condition, the expected behaviour, the task that owns it. Empty means the check was run and found nothing.

- <condition> → <expected behaviour> — T00n

## 6. Assumptions

Every decision about the feature taken without asking the author, in the order taken. *How* is `default`, `decided by default` or `corrected at the cut`. A workaround of this template's own rules is not an assumption; it is a finding for the sidecar. A gap no default can bridge begins its *Taken* cell with `design:`.

| # | Would have asked | Options | Taken | How |
|---|---|---|---|---|
| A1 | <question> | <option a / option b> | <option a> | default |
