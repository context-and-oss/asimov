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
    order. P0, when the plan has one, is the Foundation (definition §4.4: only
    when a name is shared by tasks that may run together, or when something
    every slice builds against must land first; a bug fix in existing files
    has none and starts at P1). P1..Pn are the slices, one per acceptance
    criterion a builder can make pass; a phase after the last slice may hold
    the work that closes the run (a release, a reference restored) and has a
    checkpoint like any other. The floor is one slice: a tester, then a builder.
  - name: what the phase delivers, two to five words ("FT step OK handling",
    not a sentence). checkpoint: ONE plain sentence a person reads in the plan
    view, saying what is true when the phase is done ("the status tests are
    green, including the FT step OK and step 2300 cases"); never a command,
    never a test filter. check: the command that proves the sentence, from the
    conventions ("dotnet test --filter FullyQualifiedName~X"); run by the
    verifier at the Build stage, never shown in the view. Both on every phase.
  - One task per line, YAML flow form: { id, title, role, tier, after, traces }.
    Validation parses it as YAML; quote a title that holds a colon.
  - title: a short name for the task, three to seven words, under 60
    characters ("Acceptance tests for FT step OK"). The sentence that says what
    it covers belongs in the S102's intent, not here: the view is read in ten
    seconds, and the title is also the task's file slug.
  - id: T001, T002, … in order of appearance; NNN is the number of the task's
    S102 file, S102-{{SLUG}}-NNN-<task-slug>.md, found by that glob; the task
    slug is three to five words of the title in kebab-case, never the whole
    title. Never renumber a task that already has an S102 on disk.
  - role: dotnet-builder | angular-builder | dotnet-tester | human. The closed
    list: a role-* skill without the prefix, or a person.
  - tier: low | mid | high. low = the change is fully determined by the name,
    the signature and the check; mid = behaviour in prose with a clear check;
    high = judgement or integration. A recommendation; the run picks the model.
  - after: the task ids this task depends on. Acyclic. In a slice the builder
    task comes after the tester task, so the test is red before the body is
    written. Every slice task comes after a Foundation task when there is one;
    a slice that extends a file an earlier slice owns comes after that slice's
    builder, and §6 names the file.
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
    The fingerprint covers the tree, §2, §3 and §6 (definition §6), never §1,
    §4 or §5; a plan whose approved parts changed is approved again. Every
    write that changes an approved part after an approval bumps version: the
    version is the approval's name.
  - design.approval (normalised designs only): verified when asimov-spec read
    the approval in the source itself; unverified when the design reached it
    as pasted text and the approval could not be checked. The view prints the
    mark; the Build stage sees it. A D101's design line has no such field.

  THE BODY
  - Only what the graph cannot carry: the plan members of the contract.
    §1 Contracts, §2 Constraints, §3 Coverage, §4 Escalation, §5 Review focus,
    §6 Assumptions. No phase prose: the checkpoint is on the phase, the how is
    in the S102.
  - §2 Constraints is read in the view, so each line is as short as its value
    allows: the value verbatim, the source, nothing explanatory.
  - Never here: code, steps, test bodies (the S102's, and even there names
    only); run state (the ledger's); validation findings (the sidecar
    S101-{{SLUG}}.review.md); what the cut learned about the repo (the
    gitignored repo-notes.md beside this file, definition §9); a product
    entity in THIS template (hard rule 7).

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
# design: { ref: "{{DESIGN-URL}}", read: "{{READ}}", cache: documentation/specs/{{SLUG}}/design.md, approval: verified }
status: draft
approved: none
version: 0.1
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
phases:
  - id: P0
    name: Foundation
    checkpoint: "<one sentence: the skeleton compiles with every public name in place and no bodies>"
    check: "<the build command, from the conventions>"
    tasks:
      - { id: T001, title: "<skeleton, three to seven words>", role: dotnet-builder, tier: low, after: [], traces: [§6.2.1] }
  - id: P1
    name: "<what the slice delivers, two to five words>"
    traces: [AC1]
    checkpoint: "<one sentence: which tests are green, including the cases this slice adds>"
    check: "<the test command filtered to the slice's test class, from the conventions>"
    tasks:
      - { id: T002, title: "<the slice's acceptance tests, three to seven words>", role: dotnet-tester, tier: mid, after: [T001], traces: [AC1] }
      - { id: T003, title: "<the slice's builder task, three to seven words>", role: dotnet-builder, tier: mid, after: [T002], traces: [R1, AC1] }
---

# S101 — {{TITLE}}

{{GOAL}} Plans <`documentation/features/D101-{{SLUG}}.html` v{{D101-VERSION}} | [the design]({{DESIGN-URL}}), read {{READ}}>, approved by <who> on <date>.

## 1. Contracts

Every name one task produces for another, stated once: the exact signature, or the design's contract number that states it, and the task that produces it. Who consumes it is not recorded here: each S102 header's `consumes` says so, and a name in this table is free for any later task to consume. Existing code is never a row here: the S102 that relies on it links it by path in its header, and validation resolves it on disk. A test name is never a contract. *none* when no task produces a name for another.

| Name | Shape | Produced by |
|---|---|---|
| <InterfaceName> | <exact signature, or D101 §6.x.y> | T001 |

## 2. Constraints

What the design imposes on every task, and where this plan departs from the conventions. One short line each, the value verbatim, with the source; a person reads these in the plan view. The conventions themselves are not repeated: the builder loads them.

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
- **Stops specific to this plan:** <*none*, or one sub-bullet per condition a builder in this plan stops on, beyond the generic ones in the S102 definition §5>
  - <a condition, one line>
  - <a condition, one line>
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
