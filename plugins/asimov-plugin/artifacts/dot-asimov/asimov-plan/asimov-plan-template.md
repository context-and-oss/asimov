<!--
  PLAN template. One plan per design (anything that meets contracts/design.md):
  the whole specification of contracts/specification.md in one file, the plan
  part and every task part. The plan writer writes this file in one pass;
  validate-plan.ps1 checks it before the person sees the cut; render-plan.ps1
  turns it into the S101 and one S102 per task under .asimov/specs/<slug>/,
  the data model the Build stage runs on. Nobody edits those rendered files:
  a change is made here and rendered again. The bar is the S101's
  "dispatch-ready" and the S102's "buildable blind", applied to what this
  file renders to (asimov-plan-definition.md section 2).

  WHO READS THIS FILE
  - Agents. asimov-plan-authoring.md writes it, validate-plan.ps1 checks it,
    render-plan.ps1 renders it (all beside this file, the scripts under
    scripts/). A person sees the plan through the view asimov-spec prints
    (asimov-plan-view.md); nobody is meant to read the raw file.
  - Written to .asimov/plans/{{SLUG}}.md in the product repo, gitignored
    working state. {{SLUG}} is the D101's slug or the ticket key in
    kebab-case. The design cache of a ticket sits beside it as
    .asimov/plans/{{SLUG}}.design.md, the validation sidecar as
    .asimov/plans/{{SLUG}}.review.md.
  - Strip THIS comment from the rendered file. Everything in <angle
    brackets> is a description of what to write there.

  THE HEADER AND THE TREE (rendered verbatim into the S101)
  - spec: plan. status: draft until render-plan.ps1 sets ready at the go;
    approved: none until the go, then { by, date, fingerprint } written by
    the render script and by nothing else. version: 0.1 at the first write;
    the script bumps it when an approved plan is approved again after a
    change. Never set any of the three by hand.
  - phases[] is a tree: every task sits under its phase, phases in build
    order. P0, when the plan has one, is the Foundation (definition section
    4: only when a name is shared by tasks that may run together, when
    something every slice builds against must land first, or when the repo
    has no project for a stack the design names and the solution, projects
    and test runner must be scaffolded before any slice). P1..Pn are the
    slices, one per acceptance criterion a builder can make pass; a phase
    after the last slice may close the run. A slice that adds behaviour is a
    tester, then a builder; a maintenance slice, a ticket's slice and a stack
    with no tester role take one test-first builder per stack, which owns its
    test file under test. The floor is one slice of one task.
  - name: what the phase delivers, two to five words. delivers: ONE sentence
    in the product's words, what the phase adds and why the next needs it;
    never a test result. checkpoint: ONE plain sentence, what is true in the
    product when the phase is done, the tests as the proof; never a command.
    check: the command that proves the sentence, from the conventions; run
    by the verifier, never shown. All three on every phase.
  - One task per line, YAML flow form: { id, title, role, tier, after,
    traces }. id T001, T002, ... in order of appearance. title three to seven
    words, under 60 characters; it is also the task's file slug. role:
    dotnet-builder | angular-builder | dotnet-tester | human. tier: low | mid
    | high. after: the task ids this task depends on, acyclic; a builder
    after its tester; every slice task after the P0 task of its stack when
    P0 exists. traces: ids of the design (R3, NF2, section 6.4.1, AC5).
  - Files, produced names and consumed names are NOT on the task line: they
    are the task section's yaml block below.

  THE PLAN SECTIONS (rendered verbatim into the S101 body)
  - Only what the tree cannot carry: 1 Contracts, 2 Constraints, 3
    Coverage, 4 Escalation, 5 Review focus, 6 Assumptions. No phase prose.
  - 2 Constraints is read in the view, one short line each, the value
    verbatim with its source; never a convention restated.
  - A §6 row whose decision changes what a user sees or gets carries
    ", behaviour" after its How value; a gap no default bridges begins its
    Taken cell with "design:". The view prints both.
  - Never here: code, steps, test bodies, run state, validation findings, a
    product entity in THIS template (hard rule 7).

  THE TASK SECTIONS (each rendered into one S102)
  - One section per task of the tree, heading "## T001 - <title>" with the
    title of the task line, in tree order. The section opens with ONE yaml
    block holding owns (create, modify, test, regenerates), consumes and
    produces, and nothing else: spec, s101, task, title, role, tier, after,
    traces, status, validated, author and date are rendered from the task
    line and the plan header. Then the five sections as ### headings:
    1 Intent, 2 Behaviour, 3 Done-when, 4 Constraints and stops, 5 Out of
    scope. The renderer promotes them to ## in the S102.
  - owns: repo-relative paths, or globs for a folder the task owns whole.
    test holds every test file the task creates or modifies; create and
    modify hold non-test files edited by hand; regenerates holds what a
    build, restore or generator rewrites (lock files, generated clients,
    snapshots), globs allowed, outside size and disjointness. A scaffolding
    task (dotnet new, ng new) owns the folders its template writes as globs
    (src/HomeBar.Api/**) and names the template command in its section 4,
    so the template's own files (appsettings, launch settings, a starter
    test) are owned, never a review finding. consumes: contract names
    spelled as section 1 spells them; existing code as "Name (repo-relative
    path)"; a package type as "Name (package PackageId)". produces: contract
    names only.
  - 1 Intent: one or two sentences, the design's words. 2 Behaviour:
    Gherkin, one scenario per behaviour, a rule with its failing case,
    public names only; a scenario pinned from section 5 carries
    @review-focus on the line above it; in a slice the TESTER carries the
    scenarios and the builder's section 2 is one line, "as T002: the
    scenarios of this slice's tester task"; a test-first builder carries
    them itself; a task that adds no behaviour writes "none: ..." naming its
    check. 3 Done-when: numbered; a name or command in a code span and a
    result word (green, red, passes, exits, prints, returns, is, contains,
    met); a test named by its class and scenario title, never a method; a
    builder with a tester names the tester's test class; never grep, rg,
    Select-String or findstr. 4 Constraints and stops: must / must not /
    prefer / stops, only what is specific to this task; a Must's code span
    is never a call and never a signature. 5 Out of scope: one line each
    with who owns it; "none" if none.
  - A low task is the light form: the yaml block, one sentence of intent,
    the "none:" line, the done-when, and "none" in 4 and 5 unless it has a
    stop or a boundary of its own.
  - Sizes, Warn only: 3 non-test owned files; 3 own scenarios for a builder,
    5 for a tester or a test-first builder; @review-focus not counted.
  - No placeholder (TBD, TODO, "handle edge cases", "similar to T00n", a
    <description> left from this template), no empty fence, no run state.

  THE SCHEMA THE SCRIPTS READ
  - The S101 template (artifacts/dot-asimov/s101-implementation-plan/) gives
    the header keys, the role and tier values and the plan section titles;
    the S102 template (artifacts/dot-asimov/s102-task-spec/) the yaml block's
    keys and the task section titles; the S101 definition section 8.1 the
    thresholds. This file is the writer's shape; those two are the data
    model's.

  PLACEHOLDERS
  {{SLUG}} {{TITLE}} {{D101-VERSION}} {{DESIGN-URL}} {{READ}} {{AUTHOR}} {{YYYY-MM-DD}} {{GOAL}}
  Keep one `design` line and delete the other. Sample rows show the shape.
-->
---
spec: plan
slug: "{{SLUG}}"
title: "{{TITLE}}"
design: { ref: documentation/features/D101-{{SLUG}}.html, version: "{{D101-VERSION}}" }
# design: { ref: "{{DESIGN-URL}}", read: "{{READ}}", cache: .asimov/plans/{{SLUG}}.design.md, approval: verified }
status: draft
approved: none
version: 0.1
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
phases:
  - id: P0
    name: Foundation
    delivers: "<one sentence, the product's words: what this phase adds and why the slices need it>"
    checkpoint: "<one sentence: the solution builds with every public name in place and no bodies>"
    check: "<the build command, from the conventions>"
    tasks:
      - { id: T001, title: "<skeleton, three to seven words>", role: dotnet-builder, tier: low, after: [], traces: [§6.2.1] }
  - id: P1
    name: "<what the slice delivers, two to five words>"
    traces: [AC1]
    delivers: "<one sentence, the product's words: what this phase adds and why the next needs it>"
    checkpoint: "<one sentence: what is true in the product when the phase is done, and which tests prove it>"
    check: "<the test command filtered to the slice's test class, from the conventions>"
    tasks:
      - { id: T002, title: "<the slice's acceptance tests, three to seven words>", role: dotnet-tester, tier: mid, after: [T001], traces: [AC1] }
      - { id: T003, title: "<the slice's builder task, three to seven words>", role: dotnet-builder, tier: mid, after: [T002], traces: [R1, AC1] }
---

# Plan — {{TITLE}}

{{GOAL}} Plans <`documentation/features/D101-{{SLUG}}.html` v{{D101-VERSION}} | [the design]({{DESIGN-URL}}), read {{READ}}>, approved by <who> on <date>.

## 1. Contracts

| Name | Shape | Produced by |
|---|---|---|
| <InterfaceName> | <exact signature, or D101 §6.x.y> | T001 |

## 2. Constraints

- <constraint> — D101 §6.x
- <departure from a convention, and why> — `documentation/conventions/<stack>/<file>.md`

## 3. Coverage

| Id | Says | Delivered by |
|---|---|---|
| R1 | <in the source's words> | T003 |
| AC1 | <in the source's words> | T002, T003 |
| AC2 | — | verified by review |

## 4. Escalation

- **Routes to:** <the person directing the run, by role>
- **Stops specific to this plan:** <*none*, or one sub-bullet per condition>
  - <a condition, one line>
- **Reaches a human always:** an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, a plan so broken that every path forward is a guess.
- **Rulings are recorded in:** the ledger. Never in this plan.

## 5. Review focus

- <condition> → <expected behaviour> — T00n

## 6. Assumptions

| # | Would have asked | Options | Taken | How |
|---|---|---|---|---|
| A1 | <question> | <option a / option b> | <option a> | default |

## T001 — <skeleton, three to seven words>

```yaml
owns:
  create: [<repo-relative path or glob>]
  modify: []
  test: []
  regenerates: []
consumes: []
produces: [<ContractName>]
```

### 1. Intent

<One sentence: what this task delivers and why the slices need it.>

### 2. Behaviour

none: this task adds no behaviour; its check is `<the build command>`.

### 3. Done-when

1. `<build command>` exits 0.

### 4. Constraints and stops

none

### 5. Out of scope

none

## T002 — <the slice's acceptance tests, three to seven words>

```yaml
owns:
  create: []
  modify: []
  test: [<repo-relative path of the test file this task creates or modifies>]
  regenerates: []
consumes: [<ContractName>, "<ExistingTypeName> (<repo-relative path>)"]
produces: []
```

### 1. Intent

<What this task delivers and why the feature needs it, in the design's words.>

### 2. Behaviour

```gherkin
Scenario: <the behaviour>
  Given <a state>
  When <an action>
  Then <an outcome>

Scenario: <the rule's failing case>
  Given <a state the rule excludes>
  When <the same action>
  Then <the excluded outcome>

@review-focus
Scenario: <a review-focus line of §5 pinned to this task; omit when none>
  Given <the condition>
  When <the action>
  Then <the behaviour a reasonable person expects>
```

### 3. Done-when

1. `<TestClass>` exists under `<test command from the conventions>` with one test per scenario of §2, *<scenario title>*, *<scenario title>*, red until T003 lands.

### 4. Constraints and stops

- **Must:** <a named abstraction, a public pattern, a value from the design>
- **Stops:** <a condition specific to this task on which the builder reports instead of deciding>

### 5. Out of scope

- <the neighbouring task that owns it> — T003

## T003 — <the slice's builder task, three to seven words>

```yaml
owns:
  create: [<repo-relative path>]
  modify: [<repo-relative path>]
  test: []
  regenerates: [<a glob a build or generator rewrites because of this task's edits; [] when none>]
consumes: [<ContractName>, "<PackageTypeName> (package <PackageId>)"]
produces: []
```

### 1. Intent

<What this task delivers and why the feature needs it, in the design's words.>

### 2. Behaviour

as T002: the scenarios of this slice's tester task.

### 3. Done-when

1. The tests T002 adds to `<TestClass>` are green under `<test command from the conventions>`.
2. `<build command>` exits 0.

### 4. Constraints and stops

- **Must not:** <bypass a layer, add a dependency, change a signature it does not own>
- **Prefer:** <what to mirror, by path>

### 5. Out of scope

- <the follow-up the design deferred> — OOSn
