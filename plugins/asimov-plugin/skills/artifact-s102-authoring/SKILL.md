---
name: artifact-s102-authoring
description: How to write one S102 task spec (documentation/specs/<slug>/S102-<slug>-NNN-<task>.md) for one builder role from one task line in an S101 tree — the task part of a specification under contracts/specification.md: header copied from the task line plus the owned files and the contract names it consumes and produces, intent, behaviour as Gherkin or an explicit none, done-when as named tests and commands, task-specific constraints and stops, out of scope — so that a builder with no conversation history can build it and decide every line of code itself. Use when asked to "write the S102 for task T003", "write a task spec for this ticket", "rewrite this S102 against these findings", or inside asimov-spec at every task. Writes one S102; never the S101, never another S102, never a method body, a test body or a step, never a placeholder.
---

# S102 authoring

One task line in, one task spec out. The S102 is the whole brief a fresh builder receives, so this skill writes for a reader who has nothing else open: no chat, no author, only the repo, the design, the S101 and this file. It fixes what the specification owns (the files, the names, the behaviour, the check) and leaves what the builder owns (every method body, every private name, every test's code). It does not decide the cut (artifact-s101-authoring did), and it does not judge the result (artifact-s102-validation does, blind). A skill is a leaf: it reads artifacts and calls no other skill.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s102-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s102-task-spec-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1, 2 or 3 cannot be read either way, stop and report the path.

1. **The S102 definition** — the bar (§2), the contract mapping (§3.2), the required content (§4), the rules (§5, above all *names, not bodies* and *the check is described, not written*), the anti-patterns (§7), the checks the blind reader will ask (§8):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-definition.md
   ```

2. **The S102 template** — its leading comment holds the line, the header rule and what never goes in; its body is the five sections you write:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-template.md
   ```

3. **The specification contract**, `${CLAUDE_PLUGIN_ROOT}/contracts/specification.md`: the task members you provide and the rules. **The design contract**, `${CLAUDE_PLUGIN_ROOT}/contracts/design.md`: the members the traces point into.

4. **The S101**: the task's line in the tree (title, role, tier, after, traces) and the body it inherits: §1 Contracts (the rows whose *Produced by* or *Consumed by* names this task; the signatures live there), §2 Constraints, §4 Escalation, §5 Review focus (a line pinned to this task becomes a scenario here).

5. **The design, by the ids in `traces`**: in a D101 the requirement wording for the intent, the §6 contract for the names, the rule and its counter-example for the scenarios, the acceptance criterion the slice makes pass; in a normalised design (`documentation/specs/<slug>/design.md`, named by the S101 header's `design.cache`) the R, NF, AC and OOS items and the Interfaces section.

6. **The repo**: the code the contracts link and the files the task will touch (read them to fix exact paths and to see what exists); the headers of the S102s already written for tasks that may run beside this one (no path between them in the tree), so the owned sets stay disjoint; the conventions for this stack (`documentation/conventions/<stack>/README.md` and what it lists) for the build and test commands and the test project layout.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `s101` + `task` | Path of the S101 and the task id (`T003`). |
| `findings` | On a rewrite: the validation report of the previous attempt. Address every Flag and Fail row; keep what cleared. [none] |

## Steps

1. **Header.** From the task line, copied verbatim: `task`, `title`, `role`, `tier`, `after`, `traces`; `spec: S102`, `s101`, `status: draft`, author, today's date. Never change a copied field to make the body easier; a mismatch is a plan finding, reported to the caller. Then the three members only this file states:
   - `owns`: the exact repo-relative paths the task creates, modifies and tests, read from the repo and the contracts. A new test file goes under `test` alone. A modified file must exist on disk or be created by a task this one comes after. Keep the set disjoint from every task that may run beside this one (step 6 of *Read first*); where it cannot be, report it (below) rather than widen or overlap.
   - `consumes`: every name from the S101 §1 whose *Consumed by* names this task, spelled exactly as the table spells it. Names only; never the signature.
   - `produces`: every name from the S101 §1 whose *Produced by* names this task, spelled the same way.

2. **Intent.** One or two sentences in the design's words: what this task delivers and why the feature needs it. The reason, not the recipe.

3. **Behaviour.** One Gherkin scenario per behaviour the task adds, in a fenced `gherkin` block, written from the design's rule and contract (D101 §4.5 and §6, or the normalised design's R items and Interfaces); every rule with its failing case as its own scenario; a review-focus line pinned to this task as a scenario. Public names only (the ones in the S101 §1); never a private method, a class the builder has yet to name, or a line of code. For a tester task, the scenarios are the slice's acceptance criterion made concrete at the public API of the Foundation; end to end only where the conventions name a runner. For a task that adds no behaviour (a skeleton, a registration, a reference switched, a release), write one line: *none: this task adds no behaviour; its check is <the build / the command>*. A scenario about compiling or about a file's text is not a behaviour.

4. **Done-when.** Numbered, each runnable: a test class by name under the test command from the conventions, with its expected state; a build command and its exit; a command and its output. For a tester task: the test class exists with one test per scenario in §2, named in the conventions' style, and is red against the Foundation (or green, where the builder has landed). For a builder task: the tester's class by name, green. Never the test's code; never a search of the source for the spec's own words.

5. **Constraints and stops.** Only what is specific to this task: musts (a named abstraction, a public pattern, a value or a rule from the design or from an S101 §6 assumption), must nots (a layer, a dependency, a signature it does not own, a column or key the plan ruled out), preferences by path, and the stops specific to this task. The generic stops hold by the definition and are not listed. A must that names a private method, an algorithm or the shape of a loop has crossed the line: say what must hold, not how.

6. **Out of scope.** The neighbouring task that owns the adjacent thing (by id), the follow-up the design deferred (by OOS number), the refactor that tempts. One line each; *none* if none.

7. **Write** `documentation/specs/<slug>/S102-<slug>-<NNN>-<task-slug>.md` from the template, `<NNN>` the task id's number, `<task-slug>` kebab-case from the title. No section opens with a sentence from the template; the file holds content only. On a rewrite, the same path, in place.

8. **Return** the path and, on a rewrite, one line per finding saying what changed for it. A place where you had to work around a rule of the template is returned as one line under `template findings:`, for the sidecar.

## When you cannot write it

A path, a name, a scenario or a check you cannot write without guessing is not written. Do not save a file with a gap or a placeholder in it. Return instead, with the same source prefix the validation skills use:

```
cannot write <task id>: design: <what the design does not settle>
  needs: <the D101 section, the ticket item or the author decision that would settle it>
```

or `S101:` (a name the contracts table does not carry, a producer this task does not come after, two parallel tasks that cannot own disjoint files, a task line that cannot hold the task) with the plan section that would settle it. The caller stops on `design:` (the D101 or the ticket is fixed first, not the S102) and routes `S101:` to the plan. Reporting the gap is the method; filling it from memory is the failure the blind validation exists to catch.

A missing method body is not a gap. The builder writes it.

## Never

- **Write a method body, a test body, a step list or a private name.** The only code blocks in an S102 are Gherkin.
- **Restate a signature.** The S101 §1 has it; the header names it.
- **Paste existing code**: an enum, a schema, a column list, a type that is already in the repo. Link it by path.
- **Repeat a global constraint**, the escalation routing or the generic stops. The S101 and the definition have them.
- **Write a done-when that searches the source** for the text of the spec, or one a person has to eyeball.
- **Write a placeholder**: `TBD`, `TODO`, "handle edge cases", "similar to T002", a path you did not verify, a name no contract defines. Report the gap instead.
- **Open a section with the template's sentence.**
- **Touch the S101 or another S102.** A mismatch between the task line and what the body needs is reported, never patched on either side.
- **Validate** your own output or call any other skill.
- **Set a status other than `draft`**, or change a header field copied from the task line.
- **Bake a product entity into this skill.**

## Used by

- asimov-spec, step 05, once per task after the author's go, in tree order, and again with `findings` after a failed blind validation or a plan-level finding.
- A hand run, one task at a time, once a plan exists; there is no S102 without an S101.
