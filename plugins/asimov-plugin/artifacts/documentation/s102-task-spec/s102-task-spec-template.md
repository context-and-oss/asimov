<!--
  S102 TASK SPEC template. One S102 is one task for one builder role: the whole
  brief a fresh agent receives, with no conversation behind it. It is the task
  part of a specification as contracts/specification.md defines it. The bar is
  "buildable blind": s102-task-spec-definition.md §2.

  WHO READS THIS FILE
  - The builder, as its brief; the reviewer, to see what the builder was told;
    artifact-s102-authoring writes it, artifact-s102-validation checks it in a
    fresh subagent. The file in the plugin is the source of truth (D100 §7.4).
  - Written to documentation/specs/{{SLUG}}/S102-{{SLUG}}-{{NNN}}-{{TASK-SLUG}}.md,
    beside the S101 whose task line it expands; {{NNN}} is the task id's
    number, T003 → 003. There is no S102 without an S101.
  - Strip THIS comment from the rendered file.

  THE LINE
  - The spec fixes WHAT: the files, the public names, the behaviour, the check.
    The builder decides HOW: every method body, every private name, every
    test's code. No code block in this file holds a body, a test or a step; the
    only code blocks are Gherkin. A done-when never searches the source for the
    spec's own text.

  THE HEADER
  - role, tier, after and traces are copied verbatim from the task's line in
    the S101 tree. owns, consumes and produces are stated HERE and nowhere
    else: the S101 reads them for disjointness and interface closure.
  - owns: exact repo-relative paths in three lists; a new test file goes under
    test alone. consumes / produces: names only, spelled exactly as the S101 §1
    Contracts spells them; the signature lives there.
  - role: dotnet-builder | angular-builder | dotnet-tester | human.
    tier: low | mid | high, as the S101 defines them (no tier means code here).
    status: draft is the only value a skill writes.

  THE BODY, FIVE SECTIONS
  1 Intent: one or two sentences, the design's words, the reason not the recipe.
  2 Behaviour: Gherkin, one scenario per behaviour, a rule with its failing
    case; public names only. A task that adds no behaviour says "none" and
    names its check instead. Compiling is not a behaviour.
  3 Done-when: numbered; a named test and its expected state, a build, a
    command and its output. Described, never written.
  4 Constraints and stops: must / must not / prefer / stops, only what is
    specific to this task. The generic stops (a file outside the owned set, a
    name that does not resolve, a conflict with design, conventions or a
    neighbour) hold by the definition and are not repeated.
  5 Out of scope: one line each, with who owns it. "none" if none.
  No section opens with a sentence from this template; the rendered file holds
  content only.

  NEVER HERE
  - A method body, a test body, a step list, a private name, a restated
    signature, a pasted enum or schema, a copied global constraint.
  - Placeholders: a missing path, a name no contract defines, a behaviour "to
    be handled", a done-when that cannot run, "similar to task N".
  - Run state; an edit to the S101 or another S102; a product entity in THIS
    template (hard rule 7).

  PLACEHOLDERS
  {{SLUG}} {{NNN}} {{TASK-SLUG}} {{TASK-ID}} {{TITLE}} {{AUTHOR}} {{YYYY-MM-DD}}
  Everything in <angle brackets> is a description of what to write there.
-->
---
spec: S102
s101: documentation/specs/{{SLUG}}/S101-{{SLUG}}.md
task: "{{TASK-ID}}"
title: "{{TITLE}}"
role: dotnet-builder
tier: mid
after: [T002]
traces: [R1, §6.2.1, AC1]
owns:
  create: []
  modify: [<repo-relative path>]
  test: []
consumes: [<ContractName>, <ExistingTypeName>]
produces: []
status: draft
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
---

# S102 {{TASK-ID}} — {{TITLE}}

## 1. Intent

<What this task delivers and why the feature needs it, in the design's words.>

## 2. Behaviour

```gherkin
Scenario: <the behaviour>
  Given <a state>
  When <an action>
  Then <an outcome>

Scenario: <the rule's failing case>
  Given <a state the rule excludes>
  When <the same action>
  Then <the excluded outcome>
```

## 3. Done-when

1. `<TestClass>` is green under `<test command from the conventions>`.
2. `<build command>` exits 0.
3. `<command>` prints `<expected output>`.

## 4. Constraints and stops

- **Must:** <a named abstraction, a public pattern, a value from the design>
- **Must not:** <bypass a layer, add a dependency, change a signature it does not own>
- **Prefer:** <what to mirror, by path>
- **Stops:** <a condition specific to this task on which the builder reports instead of deciding>

## 5. Out of scope

- <the neighbouring task that owns it> — T00n
- <the follow-up the design deferred> — OOSn
- <the refactor that tempts>
