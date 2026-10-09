<!--
  S102 TASK SPEC template. One S102 is one task for one builder role: the whole
  brief a fresh agent receives, with no conversation behind it. It is the task
  part of a specification as contracts/specification.md defines it. The bar is
  "buildable blind": s102-task-spec-definition.md §2.

  WHO READS THIS FILE
  - The builder, as its brief; the author, to see what the builder will be told;
    artifact-s102-authoring writes it, artifact-s102-validation checks it in a
    fresh subagent. The file in the plugin is the source of truth (D100 §7.4).
  - Written to documentation/specs/{{SLUG}}/S102-{{SLUG}}-{{NNN}}-{{TASK-SLUG}}.md,
    beside the S101 whose task line it expands; {{NNN}} is the task id's
    number, T003 → 003; {{TASK-SLUG}} is three to five words of the title in
    kebab-case, never the whole title. There is no S102 without an S101.
  - Before reading the repo from nothing, read repo-notes.md beside the S101
    when it exists (the cut's notes: files, names with their paths, package
    types, the test fixture and runner, the commands); verify every path you
    take from it.
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
  - owns: repo-relative paths, or globs for a folder the task owns whole
    (src/Services/Export/**), in four lists. test holds every test file the
    task creates or modifies; create and modify hold non-test files the
    builder edits by hand. regenerates holds the files a build, a restore
    or a generator rewrites as a consequence of those edits and that nobody
    edits by hand (lock files, generated clients, snapshots): globs allowed,
    not counted toward size, not part of disjointness; the builder runs the
    command that regenerates them and never opens them. A generated file
    under modify is a defect; a generated file nowhere is a dirty tree the
    build cannot commit. consumes: contract names spelled exactly as the S101 §1 spells them
    (the signature lives there); existing code as "Name (repo-relative path)",
    which has no §1 row and is resolved on disk; a type from a package as
    "Name (package PackageId)", resolved against the project reference. A
    member of a consumed type (an enum value, a method) is covered by the
    type's entry and is not listed again. A test name is never consumed: the
    builder's done-when names the tester's tests. produces: contract names
    only.
  - role: dotnet-builder | angular-builder | dotnet-tester | human.
    tier: low | mid | high, as the S101 defines them (no tier means code here).
    status: draft when written; asimov-spec sets validated, with the date in
    validated, once the blind check clears (definition §6). The authoring
    skill never sets either.

  THE LIGHT FORM (tier low; definition 4.7)
  - A low task (a version bump, a registration, a deletion, a skeleton) gets
    the header in full, 1 Intent as one sentence, 2 Behaviour as the "none:"
    line naming its check, 3 Done-when, and "none" in 4 and 5 unless it has a
    stop or a boundary of its own. Same shape check; written together with
    the plan's other low tasks by one writer.

  THE BODY, FIVE SECTIONS
  1 Intent: one or two sentences, the design's words, the reason not the recipe.
  2 Behaviour: Gherkin, one scenario per behaviour, a rule with its failing
    case; public names only. A scenario pinned from the S101 review focus
    carries the tag @review-focus and does not count toward the size
    threshold; in a slice the pin names the tester, never the builder. In a
    slice the TESTER task carries the slice's scenarios; the
    builder task of the same slice does not restate them: its §2 is one line,
    "as T00n: the scenarios of this slice's tester task", plus only a scenario
    the tester does not carry (normally none). A task that adds no behaviour
    says "none" and names its check instead. Compiling is not a behaviour.
  3 Done-when: numbered; a named test and its expected state, a build, a
    command and its output. Described, never written. A test is named by its
    class (a code span) and its scenario title, never by a method name: the
    methods are the builder's. A tester's done-when lists one test per
    scenario of its §2 by title; a builder's names its tester's task id and
    test class and says those tests are green.
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
  test: [<repo-relative path of a test file this task creates or modifies>]
  regenerates: [<a glob or path a build or generator rewrites because of this task's edits, e.g. "**/packages.lock.json"; [] when none>]
consumes: [<ContractName>, "<ExistingTypeName> (<repo-relative path>)", "<PackageTypeName> (package <PackageId>)"]
produces: []
status: draft
validated: none
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
---

# S102 {{TASK-ID}} — {{TITLE}}

## 1. Intent

<What this task delivers and why the feature needs it, in the design's words.>

## 2. Behaviour

<For the builder task of a slice, this section is one line instead of the block below: `as T002: the scenarios of this slice's tester task.` A scenario the tester does not carry may follow it in a gherkin block.>

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
Scenario: <a review-focus line of the S101 §5 pinned to this task; omit when none>
  Given <the condition>
  When <the action>
  Then <the behaviour a reasonable person expects>
```

## 3. Done-when

1. `<TestClass>` is green under `<test command from the conventions>` <for a tester: with one test per scenario of §2, *<scenario title>*, *<scenario title>*, red until the builder lands; for a builder: including the tests T002 adds to `<TestClass>` for its scenarios; never a method name>.
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
