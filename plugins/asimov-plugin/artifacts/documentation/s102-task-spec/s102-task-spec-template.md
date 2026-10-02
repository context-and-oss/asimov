<!--
  S102 TASK SPEC template — the structural contract every S102 follows. One
  S102 is one task for one builder role: the whole brief a fresh agent
  receives, with no conversation behind it. The bar it must clear is
  "buildable blind" — see s102-task-spec-definition.md §2 in this folder.

  HOW THE SKILLS USE THIS FILE
  - Read at run-time by artifact-s102-authoring (writes an S102 from it) and
    artifact-s102-validation (checks an S102 against it, in a fresh subagent).
    The file in the plugin is the source of truth (D100 §7.4).
  - Written to documentation/specs/{{SLUG}}/S102-{{SLUG}}-{{NNN}}-{{TASK-SLUG}}.md,
    beside the S101 whose graph entry it expands. {{NNN}} is the task id's
    number: T003 → 003. A lone S102 from the board (no D101, no S101) uses the
    ticket's slug as {{SLUG}}, 001 as {{NNN}}, and the `ticket` key instead of
    `s101` + `task`.
  - Strip THIS comment from the rendered file.

  THE HEADER IS COPIED FROM THE GRAPH
  - role, tier, depends_on and traces are copied verbatim from the task's entry
    in the S101 frontmatter, so the brief stands alone when a builder reads it
    with nothing else open. The plan validation checks they still match the
    graph; the S102 never changes them on its own.
  - The owned set (§2 Files) equals the graph entry's `owns`, and the names in
    §3 Interfaces equal its `produces` / `consumes`, spelled as the S101 §3
    Interfaces table spells them.

  VALUES
  - role: exactly one — dotnet-builder, angular-builder, dotnet-tester, or human.
  - tier: low | mid | high, as the S101 (low = transcription: the code is in
    the steps; mid = prose steps with a clear check; high = judgement).
  - status: draft is the only value a skill writes; later values follow the
    S101's (definition §6).
  - traces: D101 ids as written there — R3, NF2, §6.4.1, AC5.

  WHAT THE BODY MUST DO
  - Intent in the D101's words. Files exact and complete; the modify list names
    the region when the file is large. Interfaces by exact signature; existing
    code by path, never pasted. Behaviour as Gherkin in fenced blocks, one
    scenario per behaviour, every rule with its counter-example. Constraints
    only what is specific to this task; the global ones are inherited from the
    S101 §1 by reference. Steps test first, one action each, the code inline
    where the task is transcription. Acceptance criteria each runnable. Out of
    scope one line each.
  - A lone S102 carries its own global constraints and escalation route in §5,
    because there is no plan to inherit from.

  WHAT NEVER GOES HERE
  - Placeholders: TBD, TODO, "handle edge cases", "add appropriate error
    handling", "similar to task N", a step that says what without how for code
    the author could have written. A step the author cannot write is reported
    to the loop, not papered over.
  - Pasted existing code, a copied global constraint, run state (passes,
    claimed, fix notes), an edit to the S101 or another S102.
  - A product entity in THIS template (hard rule 7).

  PLACEHOLDERS
  {{SLUG}}           the feature slug (the D101's, or the ticket's for a lone task)
  {{NNN}}            the task number, three digits
  {{TASK-SLUG}}      kebab-case task name
  {{TASK-ID}}        the id in the S101 graph, e.g. T003
  {{TITLE}}          the task title, as the graph entry
  {{AUTHOR}}         who ran asimov-spec
  {{YYYY-MM-DD}}     the date of this write
  Everything inside <angle brackets> is a description of what to write there,
  replaced in full. Sample rows show the shape; replace them.
-->
---
spec: S102
s101: documentation/specs/{{SLUG}}/S101-{{SLUG}}.md
task: "{{TASK-ID}}"
# ticket: <id>            # lone task only, instead of s101 + task
title: "{{TITLE}}"
traces: [R1, §6.2.1, AC1]
role: dotnet-builder
tier: mid
depends_on: [T001]
status: draft
author: "{{AUTHOR}}"
date: "{{YYYY-MM-DD}}"
---

# S102 {{TASK-ID}} — {{TITLE}}

## 1. Intent

<One or two sentences: what this task delivers and why the feature needs it, in the D101's words. The reason, not the recipe.>

## 2. Files

The owned set. Nothing outside it is touched; needing to is an escalation trigger (§5).

- **Create:** `<repo-relative path>`
- **Modify:** `<repo-relative path>` — <the region, when the file is large>
- **Test:** `<repo-relative test path>`

## 3. Interfaces

**Consumes** (produced by another task or existing code; the builder stops rather than invent a missing one):

- `<exact signature>` — produced by T001
- `<exact signature>` — existing code, `<repo-relative path>`

**Produces** (a later task relies on these; the signature is fixed here):

- `<exact signature>`

## 4. Behaviour

One scenario per behaviour, a test can be written from each. A rule carries its counter-example as its own scenario.

```gherkin
Scenario: <the behaviour>
  Given <a state>
  When <an action>
  Then <an outcome>

Scenario: <the rule's counter-example>
  Given <a state the rule excludes>
  When <the same action>
  Then <the excluded outcome>
```

## 5. Constraints

Only what is specific to this task. The global constraints of the S101 §1 and its escalation route apply without being repeated.

- **Must:** <a named abstraction, a logging call, a pattern this task has to use>
- **Must not:** <bypass a layer, add a dependency, change a signature it does not own>
- **Prefer:** <what to reuse, by path>
- **Escalation triggers:** needing a file outside §2; a consumed name in §3 that does not resolve; a conflict between this spec and the D101, the conventions or a neighbouring task; <task-specific trigger>. On any of these: stop, report to the route in the S101 §5, wait for a ruling.

## 6. Steps

Test first, one action each. The code is inline where the task is transcription; existing code is linked by path.

1. Write the failing test `<test name>` in `<test path>`:

   ```<language>
   <the test, in full>
   ```

2. Run `<test command from the conventions>` and see it fail on `<the assertion>`.
3. <Write / change> `<path>`:

   ```<language>
   <the code, in full, where the task is transcription; otherwise what to achieve and what to check>
   ```

4. Run `<test command>` and see it pass.
5. Commit: `<commit message, imperative, one line>`.

## 7. Acceptance criteria

Each checkable by running something and reading the result.

1. `<test name>` passes under `<test command>`.
2. `<command>` prints `<expected output>`.
3. `<path>` exists and <has a named shape>.

## 8. Out of scope

- <the neighbouring task that owns it> — T00n
- <the follow-up the D101 deferred> — D101 OOSn
- <the refactor that tempts>
