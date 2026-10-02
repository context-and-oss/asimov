<!--
  S101 IMPLEMENTATION PLAN template — the structural contract every S101 follows.
  One S101 per D101 at Full design: the task graph, the phases with their
  checkpoints, the interfaces, the constraints stated once, the escalation
  routing, the coverage map and the assumptions. The bar it must clear is
  "dispatch-ready" — see s101-implementation-plan-definition.md §2 in this folder.

  HOW THE SKILLS USE THIS FILE
  - Read at run-time by artifact-s101-authoring (writes an S101 from it) and
    artifact-s101-validation (checks an S101 against it). The file in the plugin
    is the source of truth (D100 §7.4); never author from a remembered copy.
  - Written to documentation/specs/{{SLUG}}/S101-{{SLUG}}.md in the product
    repo. {{SLUG}} is the D101's slug (documentation/features/D101-permissions.html
    plans to documentation/specs/permissions/S101-permissions.md) or, for a
    ticket, its key in kebab-case (PROJ-123 → documentation/specs/proj-123/).
  - The design source is a D101 at Full design or a ticket that meets the
    S101 definition §3.1. The `design` block says which; the body never
    depends on the kind beyond the coverage map's wording column.
  - The first write is the CUT: frontmatter + body with §7 Assumptions, no S102
    beside it. asimov-spec shows the cut and waits for the author's go before any
    S102 is written; the author may edit this file by hand at that point and
    asimov-spec reads it as the graph. Every later write starts from the file
    on disk, so a hand edit survives a re-cut. The final write, after the plan
    validation, completes §6 and §7 and touches nothing else.
  - Strip THIS comment from the rendered file. Everything the author needs to
    know is in the definition; the plan carries plan content only.

  THE GRAPH LIVES IN THE FRONTMATTER AND NOWHERE ELSE
  - phases[] and tasks[] are the graph. The body refers to tasks and phases by
    id and never repeats a field the frontmatter already carries (owned files,
    dependencies, role, tier, traces). Two copies drift; validation reads the
    frontmatter, the reviewer reads the body.
  - Validation parses the frontmatter as YAML: keep the keys, keep the lists as
    lists, quote a value that contains a colon.

  IDS AND VALUES
  - Phase ids: P0 is always Foundation; P1..Pn one per slice, in build order.
  - Task ids: T001, T002, … in file order. The number is the NNN of the task's
    S102 file: T003 is S102-{{SLUG}}-003-<task-slug>.md. Never renumber a task
    that already has an S102 on disk.
  - role: exactly one builder role, named as its role-* skill without the
    prefix — dotnet-builder, angular-builder, dotnet-tester — or `human`. This
    is the closed list; the definitions and the validation checks point here.
  - tier: low | mid | high. low = transcription (the S102 carries the code);
    mid = prose steps with a clear check; high = judgement or integration.
    The plan names a tier only; the toolkit's model-choice.md maps tiers to
    models, and the run picks the model.
  - traces: ids of the design source — a D101's R3, NF2, §6.4.1, AC5 as written
    there, or the R/AC/OOS ids this plan assigned to a ticket's items. A phase
    traces to the acceptance criterion it makes pass; a task to everything it
    serves.
  - owns: the task's paths in three lists, create / modify / test, exact and
    repo-relative; the S102's §2 Files repeats them list for list. The owned
    set is the union. Two tasks that may run in parallel own disjoint sets; a
    shared file is a dependency, and the skeleton is cut so each slice owns
    its own file. Size counts create + modify only.
  - produces / consumes: interface names, exactly as §3 Interfaces spells them.
    Every consumed name is produced by a task in this graph, or by existing
    code §3 links by path.
  - execution_mode: one-at-a-time | subagent-per-task | agent-team. A default
    the run may override; the graph must hold for the most parallel mode.
  - status: draft is the only value a skill writes. The author sets ready after
    the reviewer's approval; the Build workflow moves it on (definition §6).

  WHAT NEVER GOES HERE
  - Recipe: code, file-level steps, test bodies. Those are the S102's.
  - Run state: claimed, done, fix round, passes. That is the ledger's.
  - Validation findings. They go to the gitignored sidecar
    S101-{{SLUG}}.review.md (definition §9), never into the plan.
  - A product entity in THIS template (hard rule 7). The rendered plan in a
    product repo names whatever it needs.

  PLACEHOLDERS
  {{SLUG}}             the D101's slug, or the ticket key in kebab-case
  {{TITLE}}            the feature name, as the D101's h1 or the ticket's summary
  {{D101-VERSION}}     the D101's version at planning time, e.g. 0.11 (D101 only)
  {{TICKET-URL}}, {{TICKET-KEY}}, {{FETCHED}}   the ticket's link, key and fetch date (ticket only)
  {{AUTHOR}}           who ran asimov-spec
  {{YYYY-MM-DD}}       the date of this write
  {{GOAL}}             the feature in one sentence, in the design source's words
  Keep one `design` block and delete the other.
  Everything inside <angle brackets> in the body is a description of what to
  write there, replaced in full. Sample rows show the shape; replace them.
-->
---
spec: S101
slug: "{{SLUG}}"
title: "{{TITLE}}"
design:                       # a D101 …
  kind: d101
  path: documentation/features/D101-{{SLUG}}.html
  version: "{{D101-VERSION}}"
# design:                     # … or a ticket (keep one block)
#   kind: ticket
#   url: "{{TICKET-URL}}"
#   key: "{{TICKET-KEY}}"
#   fetched: "{{FETCHED}}"
status: draft
version: 0.1
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
execution_mode: subagent-per-task
phases:
  - id: P0
    name: Foundation
    traces: []
    checkpoint: "The solution builds with every skeleton type and public method in place and no bodies; a reviewer can read the shape before any logic exists."
  - id: P1
    name: <slice name, from the acceptance criterion it serves>
    traces: [AC1]
    checkpoint: "<the slice's acceptance test, by name, is green>"
tasks:
  - id: T001
    file: S102-{{SLUG}}-001-<task-slug>.md
    title: <skeleton for one stack>
    role: dotnet-builder
    tier: low
    phase: P0
    depends_on: []
    owns:
      create: [<repo-relative path>, <repo-relative path>]
      modify: []
      test: []
    produces:
      - <InterfaceName>
    consumes: []
    traces: [§6.2.1]
  - id: T002
    file: S102-{{SLUG}}-002-<task-slug>.md
    title: <builder task of slice P1>
    role: dotnet-builder
    tier: mid
    phase: P1
    depends_on: [T001]
    owns:
      create: []
      modify: [<repo-relative path>]
      test: [<repo-relative test path>]
    produces: []
    consumes:
      - <InterfaceName>
    traces: [R1, AC1]
  - id: T003
    file: S102-{{SLUG}}-003-<task-slug>.md
    title: <acceptance test of slice P1>
    role: dotnet-tester
    tier: mid
    phase: P1
    depends_on: [T001]
    owns:
      create: []
      modify: []
      test: [<repo-relative acceptance-test path>]
    produces: []
    consumes:
      - <InterfaceName>
    traces: [AC1]
---

# S101 — {{TITLE}}

{{GOAL}}

Plans <`documentation/features/D101-{{SLUG}}.html` v{{D101-VERSION}} | the ticket [{{TICKET-KEY}}]({{TICKET-URL}}), fetched {{FETCHED}}, approved by <who> on <date>>. Status, author, date and the task graph are in the frontmatter; this body says what the graph cannot.

## 1. Global constraints

Every S102 in this plan includes these without repeating them. One line each, values verbatim from the D101 §6 or the conventions, with the source.

- <constraint> — D101 §6.x / `documentation/conventions/<stack>/<file>.md`
- <constraint> — <source>

## 2. Phases and checkpoints

One entry per phase in the frontmatter, by id. What the phase delivers and how the checkpoint is verified without reading code; nothing the frontmatter already says.

### P0 · Foundation

<What the skeleton covers, per stack, and which slices each skeleton file is cut for. How the checkpoint is run: the build command, from the conventions.>

### P1 · <slice name>

<The acceptance criterion in the D101's words. What the builder task(s) and the tester task each deliver. How the checkpoint is run: the test by name, at API level against the skeleton; end to end only where the conventions name a runner.>

## 3. Interfaces

Every name one task produces and another consumes, exact signature or the D101 §6 contract number that states it. The frontmatter's `produces` / `consumes` use these names verbatim. Existing code a task consumes is linked by path here and never pasted.

| Name | Shape | Produced by | Consumed by |
|---|---|---|---|
| <InterfaceName> | <exact signature, or D101 §6.x.y> | T001 | T002, T003 |
| <ExistingType> | `<repo-relative path>` | existing code | T002 |

## 4. Review focus

The inputs or failure modes the D101 implies but no task's tests exercise. One line each: the condition, the behaviour a reasonable person expects, and the task that owns the code and carries the test. An empty section means the check was run and found nothing.

- <condition> → <expected behaviour> — T00n

## 5. Escalation routing

What a builder stops on and who rules. A builder never edits an artifact it does not own; it stops and reports here.

- **Routes to:** <the person directing the run, by role; optionally an orchestrator agent for defects below a named threshold>
- **Reaches a human always:** an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, a plan so broken that every path forward is a guess.
- **Rulings are recorded in:** the ledger, with what was decided, why, and what it costs if wrong. Never in this plan or an S102.

## 6. Coverage map

Every requirement, contract and acceptance criterion of the design source in scope, against the task ids that deliver it. A criterion verified by review or by hand carries *verified by review* instead of task ids. *Says* is the source's wording in one line: required for a ticket, whose ids are this plan's own; optional for a D101, whose ids exist in the document. The first column is what a re-run compares against the design source to decide between an update and a rewrite.

| Id | Says | Delivered by |
|---|---|---|
| R1 | <the rule or decision, in the source's words> | T002 |
| NF1 | — | T001, T002 |
| §6.2.1 | — | T001 |
| AC1 | <the observable outcome, in the source's words> | T002, T003 |
| AC2 | — | verified by review |

## 7. Assumptions

Every decision taken without asking the author, in the order taken: the question it would have been, the options, the default taken. *How* is one of three values: `default` (the default was offered and taken without an answer), `decided by default` (decided after the question budget was spent, never offered), `corrected at the cut` (the author changed it at the gate). A gap no default can bridge is listed too, its *Taken* cell beginning `D101:` and naming what the design is missing.

| # | Would have asked | Options | Taken | How |
|---|---|---|---|---|
| A1 | <question> | <option a / option b> | <option a> | default |
| A2 | <question> | <option a / option b> | <option b> | decided by default |
| A3 | <question> | <option a / option b> | <option a> | corrected at the cut |
