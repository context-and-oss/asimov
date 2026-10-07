<!--
  S101 LEDGER template. The run state of one build of one ready S101, written
  only by the skill artifact-s101-ledger on behalf of asimov-build. The bar is
  "resumable": s101-ledger-definition.md §2.

  WHO READS THIS FILE
  - asimov-build, through artifact-s101-ledger, to resume and to record.
  - The PR reviewer, for what was verified and reviewed in each phase.
  - Written to documentation/specs/{{SLUG}}/S101-{{SLUG}}.ledger.md, beside the
    plan; committed with each phase's go.
  - Strip THIS comment from the rendered file.

  THE FRONTMATTER is machine state: statuses move, nothing else changes.
  - fingerprint: the S101's approval fingerprint at the start; a resume refuses
    on a mismatch.
  - phases[] in the plan's order, tasks[] under each in the plan's order.
    Phase status: pending · building · built · passed · committed · discarded.
    Task status: pending · running · built · done · failed · stopped.
  - agent is the shell name of the last attempt; model the model it ran on, or
    "session" in Codex.

  THE BODY is the record: one ## per phase, appended in the order things
  happened, reports verbatim. Never rewritten, never summarised.

  PLACEHOLDERS
  {{SLUG}} {{BY}} {{YYYY-MM-DD}} {{FINGERPRINT}}
  Everything in <angle brackets> is a description of what to write there. The
  sample rows show the shape; a real ledger has one entry per phase and task.
-->
---
ledger: S101
slug: "{{SLUG}}"
s101: documentation/specs/{{SLUG}}/S101-{{SLUG}}.md
fingerprint: "{{FINGERPRINT}}"
started: { by: "{{BY}}", date: "{{YYYY-MM-DD}}" }
phases:
  - id: P0
    status: committed
    commit: "<hash>"
    go: { by: "{{BY}}", date: "{{YYYY-MM-DD}}" }
    tasks:
      - { id: T001, status: done, attempts: 1, agent: giskard-the-dotnet-developer, model: claude-haiku-4-5 }
  - id: P1
    status: building
    commit: none
    go: none
    tasks:
      - { id: T002, status: built, attempts: 1, agent: calvin-the-test-author, model: claude-sonnet-5-5 }
      - { id: T003, status: running, attempts: 2, agent: giskard-the-dotnet-developer, model: claude-sonnet-5-5 }
---

# Ledger — {{SLUG}}

## P0 · <phase name>

### T001 · attempt 1 · giskard-the-dotnet-developer · claude-haiku-4-5
<the builder's summary and flags, verbatim>

### review
<Baley's report for the phase, verbatim>

### verify
<Powell's report for the phase, verbatim>

### commit · <hash>
go by {{BY}} on {{YYYY-MM-DD}} · <n> files · ledger

## P1 · <phase name>

### T002 · attempt 1 · calvin-the-test-author · claude-sonnet-5-5
<summary>

### T003 · attempt 1 · giskard-the-dotnet-developer · claude-sonnet-5-5
<summary>

### review
<report>

### verify
<report: T003's done-when 2 fails, with the command and its last line>

### T003 · attempt 2 · giskard-the-dotnet-developer · claude-sonnet-5-5
<summary, built with the finding>
