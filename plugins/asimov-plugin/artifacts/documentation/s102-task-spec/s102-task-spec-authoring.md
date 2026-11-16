# S102 authoring

*The method file of the S102 artifact, beside its definition and template. The plan writer subagent `asimov-spec` spawns reads it by path for every task spec and every rewrite and follows it as written. A file, not a skill: nothing is substituted in it, so a sibling is named by its file name and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

One task line in, one task spec out. The S102 is the whole brief a fresh builder receives: write for a reader with nothing else open but the repo, the design, the S101 and this file. The spec fixes the files, the public names, the behaviour and the check; the builder owns every method body, every private name and every test's code. The cut was `s101-implementation-plan-authoring.md`'s (in the S101 artifact's folder); the judgement is the shape script's, `scripts/validate-s102.ps1` beside this file. A method file is a leaf: it calls no skill.

## Read first

File 1 sits beside this file, in the folder you read it from; never a relative path in a tool call, since the working directory is the product repo. If it cannot be read, stop and report the path.

**This file is the method, the template is the shape, the script is the bar.** Do not read the S102 definition or the contracts: what they require is in the steps below, the template's leading comment (above all *names, not bodies* and *the check is described, not written*, and *THE SHAPE CHECK*) and the script's rows.

1. **The S102 template**, whole: `s102-task-spec-template.md`, beside this file
2. **The S101**: the task's line (title, role, tier, after, traces) and the body it inherits: §1 (the rows this task produces, and every row whose producer it comes after), §2, §4, §5 (a line pinned to this task becomes a scenario).
3. **The design, by the ids in `traces`**: a D101's requirement wording, §6 contract, rule with its counter-example and acceptance criterion; or the cache's R, NF, AC and OOS items and Interfaces section.
4. **What you read for the cut**, when you are the writer that cut this plan: it is in your context, and you read none of it again. A writer that did not cut the plan (a rollover, a hand run) first reads the S101 whole and every S102 already written in the folder.
5. **The repo, only for what the above lacks**, everything in **one message** as parallel tool calls: one read of a declaring file for a name you must place (found by one search); one read of a file the task touches that you have not read. Never a walk, a caller, or a file opened to see how it works. Also: the headers of the S102s already written for tasks that may run beside this one (no path between them), so the owned sets stay disjoint; for a builder in a slice, its tester's S102 (§2 holds the slice's scenarios, §3 names the tests); the stack's conventions (`documentation/conventions/<stack>/README.md` and what it lists) for the build and test commands and the test project layout.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `s101` + `task` | The S101 path and the task id; or the ids of one phase's tasks in tree order, the tester first (the builder is then written with the tester's file in hand); or, in the light form, every `low` task id of the plan. |
| `light` | The light form (definition §4.7): every task named is `low` and gets the full header, one sentence of intent, a `none:` line naming its check, the done-when, and *none* in §4 and §5 unless it has a stop or a boundary of its own; one call writes them all. A task that needs behaviour in prose is not written: return `cannot write <id>: S101: tier low, but the task adds behaviour (<what>)`. [off] |
| `findings` | On a rewrite: the previous report. Address every Fail row; a Flag may be left. [none] |

## Steps

1. **Header.** Copied verbatim from the task line: `task`, `title`, `role`, `tier`, `after`, `traces`; then `spec: S102`, `s101`, `status: draft`, `validated: none`, author, today's date (a rewrite resets both). Never change a copied field to make the body easier: a mismatch is a plan finding. Then the three members only this file states:
   - `owns`: exact repo-relative paths. `test`: every test file the task creates or modifies (a tester extending a class lists it here, `modify` empty). `create` and `modify`: non-test files edited by hand; a modified file exists on disk or is created by a task this one comes after. Keep the three disjoint from every task that may run beside this one; where you cannot, report it (below), never widen or overlap. A size Warn is never a reason to drop a file or split the task: the cut sized it. `regenerates`: what a build, a restore or a generator rewrites because of this task's edits (lock files after a package change, a generated client, a snapshot), as a glob where the set is derived (`**/packages.lock.json`), never enumerated, never under `modify`; `[]` when none. Outside size and disjointness.
   - `consumes`: every §1 name this task relies on, spelled as the table spells it, whose producer this task comes after; every existing type, method or value a scenario or a must will mention, as `<Name> (<repo-relative path>)`; every package type as `<Name> (package <PackageId>)`, the id from the project file. A member of a listed type (an enum value, a method) is covered by the type's entry. Existing code needs no §1 row. Never a test name; names only, never a signature.
   - `produces`: every §1 name whose *Produced by* is this task, spelled the same way.

2. **Intent.** One or two sentences in the design's words: what the task delivers and why the feature needs it. The reason, not the recipe.

3. **Behaviour.** One Gherkin scenario per behaviour the task adds, in a fenced `gherkin` block, from the design's rule and contract; every rule with its failing case as its own scenario; public names only (the S101 §1 or the header's `consumes`), never a private method, a class the builder has yet to name, or a line of code. A review-focus line pinned to this task is a scenario with `@review-focus` on the line above it, not counted toward the threshold; the S101 pins to the task that carries the scenarios (the tester, or the test-first builder of a maintenance slice), so a builder that has a tester carries none, and a line naming such a builder by mistake goes into the tester's file and is reported as a template finding. A **tester** carries every scenario of the slice, the acceptance criterion made concrete at the public API of the Foundation or of the existing code, end to end only where the conventions name a runner, at the tester's threshold. A **builder with a tester** does not restate them: §2 is one line, `as T<nnn>: the scenarios of this slice's tester task`, naming the tester in `after`, plus a gherkin block only for a scenario the tester does not carry (normally none). A **test-first builder** (no tester of its stack in its phase: an Angular builder, or the one builder of a maintenance slice) carries the slice's scenarios itself, at the tester's threshold. A task that adds no behaviour writes one line: *none: this task adds no behaviour; its check is <the build / the command>*. Compiling, or a file's text, is not a behaviour.

4. **Done-when.** Numbered, each runnable: a test class under the test command from the conventions with its expected state; a build command and its exit; a command and its output. A test is named by its **class and scenario title, never a method name** (definition §4.4): the class in a code span, the methods are the builder's. A tester: the class exists or gained tests, one per scenario of §2 by title, red until the builder lands. A builder with a tester: the tester's task id and its test class in one code span, copied from the tester's done-when, and that the tests it adds are green (*the tests T001 adds to `StatusServiceTests` are green under `<command>`*); the only place a builder names a test. A test-first builder: its own test file or class in the code span, one test per scenario of its §2 by title, green. Never the test's code; never a search of the source for the spec's own words.

5. **Constraints and stops.** Only what is specific to this task: musts (a named abstraction, a public pattern, a value from the design or a §6 assumption), must nots (a layer, a dependency, a signature it does not own, a column the plan ruled out), preferences by path, and this task's own stops. The generic stops hold by the definition and are not listed. A must that names a private method, an algorithm or the shape of a loop has crossed the line: say what must hold, not how.

6. **Out of scope.** The neighbouring task that owns the adjacent thing (by id), the follow-up the design deferred (by OOS number), the refactor that tempts. One line each; *none* if none.

7. **Write** `specs/<slug>/S102-<slug>-<NNN>-<task-slug>.md` from the template: `<NNN>` the task number, `<task-slug>` three to five words of the title in kebab-case, never the whole title. No section opens with a template sentence. A rewrite goes to the same path, in place.

8. **Check your own shape.** Through Bash, one call per file:

   ```
   pwsh -NoProfile -File "<plugin-root>/artifacts/documentation/s102-task-spec/scripts/validate-s102.ps1" -S102 <the file> -S101 <the S101> -Design <the D101 path, or the cache the S101's design line names>
   ```

   (`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell; `-PluginRoot <plugin-root>` in Codex.) Fix every Fail the file can fix (a done-when without a code span and a result word, a missing header key, a template sentence left in, a count) and run it again, at most twice. A Fail beginning `design:` or `S101:` is not yours: it becomes a *cannot write*. Flags and Warns are left. With no PowerShell, skip and say so. You never mark the file validated: the caller's run is the record.

9. **Return** the path; on a rewrite one line per finding saying what changed, then `header: unchanged` or `header: changed (<owns | consumes | produces>)`; then `self-check: clean | <k> fail left: <the rows> | skipped: no PowerShell`; and any template findings under `template findings:`.

## When you cannot write it

A path, a name, a scenario or a check you cannot write without guessing is not written, and no file is saved with a gap or a placeholder. Return instead:

```
cannot write <task id>: design: <what the design does not settle>
  needs: <the D101 section, the ticket item or the author decision that would settle it>
```

or `S101:` (a name §1 lacks, a producer this task does not come after, two parallel tasks that cannot own disjoint files, a task line that cannot hold the task) with the plan section that would settle it. The caller stops on `design:` and routes `S101:` to the plan. A missing method body is not a gap: the builder writes it.

## Never

- Write a method body, a test body, a step list or a private name: the only code blocks are Gherkin.
- Restate the tester's scenarios in a builder that has one, or restate a signature.
- List a generated file as hand-edited: it goes under `regenerates`.
- Write, correct or re-verify the repo notes: the cut owns them, the shape check catches a wrong line.
- Name a test method; paste existing code (link it by path); repeat a global constraint, the escalation routing or the generic stops.
- Write a done-when that searches the source, or one a person has to eyeball.
- Write a placeholder (`TBD`, `TODO`, "handle edge cases", "similar to T002", an unverified path, a name no contract defines): report the gap.
- Open a section with the template's sentence.
- Touch the S101 or another S102: a mismatch is reported, never patched.
- Mark your own output validated, set a status other than `draft`, change a copied header field, or call any skill.
- Bake a product entity into this file.

## Used by

- asimov-spec, step 05: once per phase after the go (the phase's tasks in tree order, tester first), phases with no path between them at once, the `low` tasks in one call; once per task with `findings` after a failed check; and step 02 on a small plan, in the cut writer's session.
- A hand run, one task at a time, once a plan exists.
