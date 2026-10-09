---
name: artifact-s102-authoring
description: How to write one S102 task spec (documentation/specs/<slug>/S102-<slug>-NNN-<task>.md) for one builder role from one task line in an S101 tree — the task part of a specification under contracts/specification.md: header copied from the task line plus the owned files and the contract names it consumes and produces, intent, behaviour as Gherkin or an explicit none, done-when as named tests and commands, task-specific constraints and stops, out of scope — so that a builder with no conversation history can build it and decide every line of code itself. Use when asked to "write the S102 for task T003", "write a task spec for this ticket", "rewrite this S102 against these findings", or inside asimov-spec at every task. Writes one S102; never the S101, never another S102, never a method body, a test body or a step, never a placeholder.
---

# S102 authoring

One task line in, one task spec out. The S102 is the whole brief a fresh builder receives, so this skill writes for a reader who has nothing else open: no chat, no author, only the repo, the design, the S101 and this file. It fixes what the specification owns (the files, the names, the behaviour, the check) and leaves what the builder owns (every method body, every private name, every test's code). It does not decide the cut (artifact-s101-authoring did), and it does not judge the result (artifact-s102-validation does, blind). A skill is a leaf: it reads artifacts and calls no other skill.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s102-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s102-task-spec-template.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 cannot be read either way, stop and report the path.

**This skill is the method; the template is the shape; the script is the bar.** You do not read the S102 definition or the contracts: what they require of a task spec is in the steps below and in the template's leading comment (above all *names, not bodies* and *the check is described, not written*), and the shape check you run in step 8 enforces the bar row by row. The definitions are the maintainers' source of truth, cited by section where a rule comes from.

1. **The S102 template** — its leading comment holds the line, the header rule and what never goes in; its body is the five sections you write:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-template.md
   ```

2. **The S101**: the task's line in the tree (title, role, tier, after, traces) and the body it inherits: §1 Contracts (the rows this task produces, and every row whose producer this task comes after, which it may consume; the signatures live there), §2 Constraints, §4 Escalation, §5 Review focus (a line pinned to this task becomes a scenario here).

3. **The design, by the ids in `traces`**: in a D101 the requirement wording for the intent, the §6 contract for the names, the rule and its counter-example for the scenarios, the acceptance criterion the slice makes pass; in a normalised design (`documentation/specs/<slug>/design.md`, named by the S101 header's `design.cache`) the R, NF, AC and OOS items and the Interfaces section.

4. **The repo notes first**, `documentation/specs/<slug>/repo-notes.md` beside the S101, when it exists (the cut writes it; the S101 definition §9 fixes its shape): the files the plan touches, the existing names with the path that declares each, the package types with their package id, the test project, fixture and runner, the build and test commands. Start from it and **take its paths and names as given**: a path the notes carry is not re-verified and a declaring file is not reopened to see that the name is there; the shape check (step 8) looks every path and name up for free, and a wrong line in the notes is a template finding, not your cost. The second ticket-sized run's writers re-walked the repo after reading the notes and the notes saved nothing. A missing notes file costs only the reading below.

5. **The repo, only for what the notes do not carry**: a signature or a member you must name and the notes do not place (one read of its declaring file, found by one search); a file the task will touch that the notes do not list (one read). Never a walk of the folders, never a caller, never a file opened to see how it works: the builder loads the conventions and reads the code it changes. Then the headers of the S102s already written for tasks that may run beside this one (no path between them in the tree), so the owned sets stay disjoint; for a builder task in a slice, its tester's S102 (the task in `after` with a tester role in the same phase), whose §2 holds the slice's scenarios and whose §3 names the tests; the conventions for this stack (`documentation/conventions/<stack>/README.md` and what it lists) for the build and test commands and the test project layout.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `s101` + `task` | Path of the S101 and the task id (`T003`); or, in the light form, every `low` task id of the plan at once. |
| `light` | The light form (S102 definition §4.7): every task named is `low`, and each gets the header in full, one sentence of intent, a `none:` line naming its check, the done-when, and *none* in §4 and §5 unless the task has a stop or a boundary of its own. One call writes them all, reading the repo once. A task that turns out to need behaviour in prose is not written: return `cannot write <id>: S101: tier low, but the task adds behaviour (<what>)`. [off] |
| `findings` | On a rewrite: the validation report of the previous attempt. Address every Fail row; a Flag is read and may be left. [none] |

## Steps

1. **Header.** From the task line, copied verbatim: `task`, `title`, `role`, `tier`, `after`, `traces`; `spec: S102`, `s101`, `status: draft`, `validated: none`, author, today's date (a rewrite resets both: the file is unvalidated until its next blind check). Never change a copied field to make the body easier; a mismatch is a plan finding, reported to the caller. Then the three members only this file states:
   - `owns`: the exact repo-relative paths the task creates, modifies and tests, read from the repo and the contracts. `test` holds every test file the task creates or modifies (a tester that extends an existing test class lists it here, `modify` empty); `create` and `modify` hold non-test files the builder edits by hand. A modified file must exist on disk or be created by a task this one comes after. Keep those three lists disjoint from every task that may run beside this one (item 5 of *Read first*); where it cannot be, report it (below) rather than widen or overlap. `regenerates` holds what a build, a restore or a generator rewrites because of this task's edits and nobody edits by hand: a package version change regenerates every `packages.lock.json`, a schema change a generated client, a rendering change a snapshot. Write it as a glob where the set is derived (`**/packages.lock.json`), never enumerate the files, and never put such a file under `modify`; `[]` when the task regenerates nothing. It is outside size and disjointness.
   - `consumes`: every name from the S101 §1 this task relies on, spelled exactly as the table spells it, provided its producer is a task this one comes after (the table records no consumer; this list is the record); every existing type, method or value the task relies on and a scenario or a must will mention, as `<Name> (<repo-relative path>)`, the path read from the repo; and every type that comes from a package rather than a file, as `<Name> (package <PackageId>)`, the id read from the project file that references it. A member of a type you list (an enum value, a method on it) is covered by the type's entry: do not list it again. Existing code has no §1 row and needs none; never report a missing row for it. Never a test name: the tester's tests are named in the done-when (step 4). Names only; never the signature.
   - `produces`: every name from the S101 §1 whose *Produced by* names this task, spelled the same way.

2. **Intent.** One or two sentences in the design's words: what this task delivers and why the feature needs it. The reason, not the recipe.

3. **Behaviour.** One Gherkin scenario per behaviour the task adds, in a fenced `gherkin` block, written from the design's rule and contract (D101 §4.5 and §6, or the normalised design's R items and Interfaces); every rule with its failing case as its own scenario; a review-focus line pinned to this task as a scenario with the tag `@review-focus` on the line above it (it does not count toward the size threshold; in a slice the S101 pins to the tester, so a builder carries none and a line that names the builder by mistake is written into the tester's file and reported as a template finding). Public names only (the ones in the S101 §1 or in the header's `consumes`); never a private method, a class the builder has yet to name, or a line of code. For a tester task, the scenarios are the slice's acceptance criterion made concrete at the public API of the Foundation, or of the existing code where the plan has none; end to end only where the conventions name a runner; the tester carries every scenario of the slice, each rule with its failing case, and its threshold is the tester's (S101 definition §8.1). **For the builder task of a slice, do not restate them**: §2 is one line, `as T<nnn>: the scenarios of this slice's tester task`, naming the tester in `after`, followed by a gherkin block only for a scenario the tester does not carry (normally none). For a task that adds no behaviour (a skeleton, a registration, a reference switched, a release), write one line: *none: this task adds no behaviour; its check is <the build / the command>*. A scenario about compiling or about a file's text is not a behaviour.

4. **Done-when.** Numbered, each runnable: a test class by name under the test command from the conventions, with its expected state; a build command and its exit; a command and its output. **A test is named by its class and its scenario title, never by a method name** (definition §4.4): the class is a code span, the method names are the builder's. For a tester task: the test class exists, or the existing class gained tests, one per scenario in §2 listed by scenario title, red against the Foundation or the existing code (or green, where the builder has landed). For a builder task: the tester's task id and its test class in the same code span, and that the tests it adds for the slice's scenarios are green (*the tests T001 adds to `StatusServiceTests` are green under `<command>`*); open the tester's S102 and copy the class from its done-when; that line is the only place a builder names a test. Never the test's code; never a search of the source for the spec's own words.

5. **Constraints and stops.** Only what is specific to this task: musts (a named abstraction, a public pattern, a value or a rule from the design or from an S101 §6 assumption), must nots (a layer, a dependency, a signature it does not own, a column or key the plan ruled out), preferences by path, and the stops specific to this task. The generic stops hold by the definition and are not listed. A must that names a private method, an algorithm or the shape of a loop has crossed the line: say what must hold, not how.

6. **Out of scope.** The neighbouring task that owns the adjacent thing (by id), the follow-up the design deferred (by OOS number), the refactor that tempts. One line each; *none* if none.

7. **Write** `documentation/specs/<slug>/S102-<slug>-<NNN>-<task-slug>.md` from the template, `<NNN>` the task id's number, `<task-slug>` three to five words of the title in kebab-case (*acceptance-tests-ft-step-ok*), never the whole title; the file is found by its number. No section opens with a sentence from the template; the file holds content only. On a rewrite, the same path, in place.

8. **Check your own shape before returning.** Run the shape check on every file you wrote, through **Bash**, one call per file:

   ```
   pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/scripts/validate-s102.ps1" -S102 <the file> -S101 <the S101> -Design <the D101 path, or the cache the S101's design line names>
   ```

   (`powershell -NoProfile -ExecutionPolicy Bypass -File …` where only Windows PowerShell exists; in Codex add `-PluginRoot <plugin-root>`.) It is the same script the caller runs, and it takes a second. Fix every Fail row the file can fix (a done-when item without a code span and a result word, a key missing from the header, a section opened with the template's sentence, a count) and run it again, at most twice; a Fail whose reason begins `design:` or `S101:` is not yours to fix and becomes a *cannot write* (below). A Flag or Warn is read and left. Where no PowerShell exists, skip the check and say so in the return line. You never mark the file validated: the caller's run of the same script is the record. The second ticket-sized run paid a writer and three minutes for one missing code span; this step is where that stops.

9. **Return** the path and, on a rewrite, one line per finding saying what changed for it, then one line `header: unchanged` or `header: changed (<the fields: owns | consumes | produces>)`, which the caller uses to decide whether the plan's §1 needs settling. Then one line `self-check: clean | <k> fail left: <the rows> | skipped: no PowerShell`. A place where you had to work around a rule of the template is returned as one line under `template findings:`, for the sidecar.

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
- **Restate the tester's scenarios in a builder's S102.** The builder's §2 names the tester task; its done-when names the tester's tests.
- **List a generated file as hand-edited.** A lock file, a generated client, a snapshot goes under `regenerates`, as a glob, or the builder is told to edit by hand what only a tool should write.
- **Restate a signature.** The S101 §1 has it; the header names it.
- **Write the repo notes, or correct them.** The cut owns `repo-notes.md`; a wrong line in it is a template finding, and you read the file on disk instead.
- **Re-verify the notes.** A path or a name the notes carry is taken as given; the shape check catches a wrong one for free. Open the repo for what the notes lack, once per thing.
- **Name a test method.** A test is its class and its scenario title; the methods are the builder's.
- **Paste existing code**: an enum, a schema, a column list, a type that is already in the repo. Link it by path.
- **Repeat a global constraint**, the escalation routing or the generic stops. The S101 and the definition have them.
- **Write a done-when that searches the source** for the text of the spec, or one a person has to eyeball.
- **Write a placeholder**: `TBD`, `TODO`, "handle edge cases", "similar to T002", a path you did not verify, a name no contract defines. Report the gap instead.
- **Open a section with the template's sentence.**
- **Touch the S101 or another S102.** A mismatch between the task line and what the body needs is reported, never patched on either side.
- **Validate** your own output or call any other skill.
- **Set a status other than `draft` or a date in `validated`**; asimov-spec does, on a clean blind report. Never change a header field copied from the task line.
- **Bake a product entity into this skill.**

## Used by

- asimov-spec, step 05, once per task after the author's go, in `after` order with tasks that have no path between them written at once, and again with `findings` after a failed blind validation or a plan-level finding.
- A hand run, one task at a time, once a plan exists; there is no S102 without an S101.
