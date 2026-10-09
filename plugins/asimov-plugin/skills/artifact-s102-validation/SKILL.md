---
name: artifact-s102-validation
description: Validate one S102 task spec against its shape, the way a JSON file is checked against its schema — header keys present and equal to the task line in the S101 tree, owned paths that exist or are created upstream, consumed names in a plan row, declared at their path or in a referenced package, no placeholder, no code block but Gherkin, no done-when that greps the source, a builder's done-when naming its tester's tests, counts against the size thresholds. The check is a script, scripts/validate-s102.ps1, run inline with no subagent; it reads the files and looks things up, never runs code and never judges content, and two runs on unchanged files agree. Use when asked to "validate this S102", "check this task spec's shape", "does task T003 conform", inside asimov-spec after every write and on every task spec in a re-check, or on a hand-edited S102. Read-only, run-nothing; it edits nothing, proposes no fix, decides nothing.
---

# S102 validation

The shape check of one task spec. It answers one question: **does this file conform to the S102 form**, the way a schema check answers whether a file is valid JSON. Every row is answered by reading text and looking something up: a key is present, a path exists, a name is declared in the file the header points at, an id is in the design, a test name matches the tester's list, a count is under a threshold. No row is answered by judgement, and none by running anything. Whether the scenarios are the *right* ones is the author's question at the cut and the reviewer's at the PR; whether the code *works* is the verifier's after the build. This check asks neither.

**The check is a script.** The S102 definition §8 says a script replaces the checklist when two runs disagree, and the first runs disagreed (a row went Flag to Pass on unchanged text) while costing some 70,000 tokens per check. So the checklist below is implemented, row for row, in `scripts/validate-s102.ps1`, and this skill's job is to run it and return what it prints. The checklist stays here as the specification of the script and as the fallback where no PowerShell exists.

## The call

```
pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/scripts/validate-s102.ps1" -S102 <S102 path> -S101 <S101 path> -Design <design path>
```

`pwsh` (PowerShell 7) or `powershell` (Windows PowerShell 5.1; add `-ExecutionPolicy Bypass`), whichever the machine has; the script runs on both. The paths are repo-relative, and the working directory is the product repo root. The design path is the D101 (`documentation/features/D101-<slug>.html`) or the normalised design (`documentation/specs/<slug>/design.md`); the S101 header's `design` line says which: `ref` for a repo file, `cache` for a normalised one. The script finds the plugin root from its own location; in Codex, where `${CLAUDE_PLUGIN_ROOT}` is not substituted, derive the root once (take this skill's file path as Codex shows it, strip everything from `skills/artifact-s102-validation` onward; if the script is not under it, Glob `<home>/.codex/plugins/cache/**/scripts/validate-s102.ps1` and take the match whose path shares the longest prefix with the skill path) and pass `-PluginRoot <root>`.

**Return the script's output verbatim** and nothing else. Exit code 2 means an input could not be read; the one line it prints says which, and that line is the report. **Never** "correct" a row, add a row, or soften one.

**Where no PowerShell is installed**, say so in one line, then answer the checklist below by hand, on the same closed read list, and return the report with `engine: llm` in place of `engine: script`; the caller records the run as one to re-check from a machine with the script.

## What the script reads, and nothing else

1. **The S102 template**, for the header keys and the section order a conforming file has (the template is the schema), and the **S101 template**'s leading comment for the role and tier values:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-template.md
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

2. **The thresholds**, the `thresholds:` block of §8.1 of the S101 definition:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

3. **The target S102**, whole.
4. **Its S101**: the frontmatter (the task's line, the phase it sits in), §1 Contracts, §2 Constraints, §4 Escalation, §5 Review focus.
5. **The design**, only to find the ids the header traces to. Not to read the design.
6. **The other S102s in the folder, headers only**, for `owns` (S3); for a builder task, its tester's S102 §2 and §3 as well (rows 4 and 5).
7. **The files the S102 names**, one lookup each: a path in `owns` is checked for existence (a directory listing, never a read); a path in a `consumes` entry is searched once for the declaration of the name; a package id is searched for in the project files of the repo.

Not the S102 definition (this checklist is its §8, row for row), not the contracts, not the conventions, not a file the spec does not name, not the code's logic. **Nothing is run**: no build, no test, no restore, no script of the repo's. The question "would this test pass today" is not asked.

## Shape checklist

In this order, every time, from the files' text and the lookups above. Each row is answered by counting or looking up, so two runs on an unchanged file agree. One row per item.

| # | Item | Result rule |
|---|---|---|
| S1 | Header fields | Every key of the template header present (`spec`, `s101`, `task`, `title`, `role`, `tier`, `after`, `traces`, `owns` with `create`, `modify`, `test`, `regenerates` lists, `consumes`, `produces`, `status`, `validated`, `author`, `date`; a missing `regenerates` reads as empty → **Flag**, not Fail); `role` and `tier` each hold one of the values the S101 template's leading comment lists; `status` is `draft`, `validated` or `done`, and `validated` is `none` or a date. A missing `s101`, `task`, `role`, `after`, `traces`, `owns` list, `consumes` or `produces`, or a `role` or `tier` outside the list → **Fail** (the builder or the plan reads it). A missing `spec`, `title`, `status`, `validated`, `author` or `date`, an extra key, or a date with `status: draft` (a leftover) → **Flag**. |
| S2 | Header equals task line | `title`, `role`, `tier`, `after`, `traces` equal the S101 tree's line for `task`, lists as sets. A difference in `role`, `after` or `traces` → **Fail**, naming the field; a difference in `title` or `tier` → **Flag** (the plan validation's F2 names it too; the builder is not stopped by it). |
| S3 | Paths resolve | Every path in `owns.modify` exists on disk, or is in the `owns.create` of an S102 whose task this one comes after (directly or transitively); a glob in `modify` that matches nothing today → **Flag**; every path in `owns.test` exists, or is new (`test` holds every test file the task creates or modifies; a test file never appears under `create` or `modify`); every path in `owns.create` does not exist while `status` is `draft` or `validated` (on `done` the file may already be built, and this part reads **n/a**); no path appears in two of the four lists. Otherwise **Fail**, naming the path. A path in the body that is neither owned nor existing → **Fail**. A test file listed under `modify` instead of `test` → **Flag**. `regenerates` may hold globs and is not checked for existence; a path in `create`, `modify` or `test` that matches a generated-file pattern (`*.lock.json`, `packages.lock.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `*.snap`, `*.g.cs`, `*.generated.*`, a path under a folder named `Generated` or `obj`) → **Flag**, naming it: it belongs under `regenerates`. |
| S4 | Names in the contracts | Every entry in `consumes` is one of three things: a row of the S101 §1 whose *Produced by* is a task this one comes after (no column records consumers; the header is the record); existing code in the form `<Name> (<repo-relative path>)`, where the path exists and a search of that file finds the name (existing code needs no §1 row, and a §1 row is never asked for it); or a package type in the form `<Name> (package <PackageId>)`, where a project file in the repo references that package (`PackageReference`/`PackageVersion Include="<PackageId>"` in a `.csproj` or `Directory.Packages.props`, the package in `package.json`). Every name in `produces` is a row whose *Produced by* names this task. An entry that resolves to none of the three → **Fail**, naming the name; a §1 name whose producer this task does not come after → **Fail** prefixed `S101:`. A test name in `consumes` → **Flag** (a test is named in the done-when, never consumed). |
| S5 | Placeholders | None of: `TBD`, `TODO`, `FIXME`, `XXX`, `similar to T0`, `handle edge cases`, `appropriate error handling`, `as needed`, `to be decided`, an empty fenced block, a `{{PLACEHOLDER}}`, or a template description left in prose: an angle-bracket phrase of two or more words outside a code span or fence (a generic such as `Task<Result>` is code and is not one). Any → **Fail**, quoting it. |
| S6 | Sections | §1–§5 present in the template's order; §2 holds at least one fenced `gherkin` block with at least one `Scenario:`, or one line beginning `none:` that names the check, or, for a builder task, one line beginning `as T<nnn>:` where T<nnn> is a tester-role task in the same phase that this task comes after (then any gherkin block after it holds only scenarios of this task's own); §3 holds at least one numbered item. A missing section, an empty §2 or §3, an `as T<nnn>:` line that names no such tester → **Fail**. |
| S7 | Boundary tokens | No fenced block whose language is anything but `gherkin`; no list under a heading that reads *Steps*; no `Scenario:` that names a path; no §3 item whose command is `grep`, `Select-String`, `findstr`, `rg`. Any → **Fail**, quoting the line. An identifier in a scenario (a CamelCase or dotted name) that is in none of the S101 §1, the header's `consumes` and `produces`, the design's text, or a search of a path the header lists → **Flag**, naming it. |
| S8 | Sizes | Count owned non-test files (`owns.create` + `owns.modify`; `regenerates` never counts) and the task's own `Scenario:` lines, those whose preceding non-blank line is not `@review-focus`; a builder's `as T<nnn>:` reference counts as no scenario. Compare the files with `owned_non_test_files` and the scenarios with `scenarios` for a builder role or `scenarios_tester` for a tester role. Over a threshold → **Warn** with the count; never Fail. |

## The ten rows

Then the ten checks of the S102 definition §8, one row each, in that order, each answered from the shape rows and one more lookup at most. Severities:

| Severity | Meaning |
|---|---|
| **Pass** | The check holds. |
| **Flag** | Holds in substance with a defect the sentence names: a header entry missing for a name that resolves, a restated constraint, a paraphrased generic stop, a scenario with no Given line. Flags go to the sidecar; a Flag never costs a rewrite. |
| **Fail** | Does not hold, and a builder would be stuck or build the wrong thing: a path that does not resolve, a consumed name with no producer and no home on disk, a scenario with no When or Then line, a done-when with no runnable form, a placeholder, a body or a test in a code block. |
| **Warn** | S8 and row 9 only: a size threshold exceeded. Never Fail. |
| **n/a** | A check with no object: the create-path part of S3 past `draft`; row 4 for a task that states *none*. Not a defect. |

| # | Row | Answered by |
|---|---|---|
| 1 | Traceability | S2 holds, and every id in `traces` is found in the design's text (word-bounded for an alphanumeric id, literal for a `§` one). An id not found → **Fail** prefixed `design:`. No design path → Pass with the sentence that ids were not looked up. |
| 2 | Scope | S3 holds. An owned project or package file (`.csproj`, `.props`, `package.json`) with lock files in the repo and an empty `regenerates` → **Flag**. |
| 3 | Interface closure | S4's result and sentence. |
| 4 | Behaviour | For a `none:` line: **n/a** when it names a build or a command, **Flag** otherwise. Else: every `Scenario:` has at least one `Given`, `When` and `Then` line (no When or Then → **Fail**; no Given → **Flag**); every S101 §5 line pinned to this task has a scenario tagged `@review-focus` in §2 (count; one missing → **Fail**); for an `as T<nnn>:` line the tester's §2 holds a `Scenario:` (open it, count; none → **Fail**); S7's identifier Flag is repeated here. |
| 5 | Done-when | Every §3 item carries a name or command in a code span and a result word (`green`, `red`, `passes`, `fails`, `exits`, `prints`, `returns`, `is`, `equals`, `contains`, `met`); an item with neither → **Fail**. For a builder task whose `after` holds a tester of the same phase: at least one item names, in a code span, a test class the tester's S102 §3 lists in a code span (a test is named by class and scenario title, never by method; definition §4.4); none → **Fail**. S7's search part is repeated here. |
| 6 | Stops | A §4 *Stops* line that names a generic condition (a file outside the owned set; a consumed name that does not resolve; a conflict with the design, the conventions or a neighbour) and carries no code span, task id, path or number of its own → **Flag**; never Fail. No *Stops* line → **Pass**. |
| 7 | Boundary | S7's Fails; a *Must* line whose code span is a call (`name(...)`) or that names a loop or an algorithm → **Fail**; a code span outside a fence that reads as a signature (`Type Name(Type param`) → **Fail**. |
| 8 | Hygiene | S5 and S6 hold; none of `passes: true`, `claimed`, `attempt <n>`, `fix round`, `[x]` in the body → else **Fail**; a §4 line equal, normalised, to an S101 §4 line → **Flag**. Header fields copied from the task line are the form, never restatement. |
| 9 | Size | S8's result and sentence. |
| 10 | Inheritance | A §4 line equal to, or containing, a normalised S101 §2 line (its text before the source dash) → **Flag**, quoting both. A contradiction is not detected by the script; it is the reviewer's. |

**The source of a Fail.** A traced id the design does not carry is `design:`; a consumed §1 name whose producer is not upstream, or a produced name with no §1 row, is `S101:`; everything else is the S102's. The loop stops on `design:`, routes `S101:` to the plan, and rewrites the rest.

**Template findings.** The script reports one when the S101 §1 still carries a *Consumed by* column. Anything else a hand run notices goes under `template findings:` after the report.

## Report

The script prints exactly this; a hand run returns the same with `engine: llm`:

```
## Validation report
target: <S102 path>
bar: buildable-blind (shape)
blind: true
engine: script (validate-s102.ps1)
| # | Check | Result | Reason |
|---|---|---|---|
| S1 | Header fields | Pass | … |
| … | … | … | … |
| 10 | Inheritance | Pass | … |
```

One sentence per reason. No summary line, no verdict, no suggestion of a fix. The caller counts the rows.

## Never

- **Run anything that executes code** beyond the script itself: no build, no test, no restore. The script lists directories and searches files for a name, and nothing more.
- **Open a file the spec does not name**, read a file's logic, or read the design beyond finding an id.
- **Judge content**: whether the scenarios are the right ones, whether a test would pass today, whether the task fits one sitting, whether a command is the conventions'. The author judged at the cut; the reviewer judges at the PR; the verifier runs the code after the build.
- **Change a row the script returned**, soften a Fail, or add a finding of your own.
- **Edit** the S102, the S101, the design or any file. **Propose** no fix; the authoring skill decides how to clear a row.
- **Return anything but the report** and the template findings.

## Used by

- asimov-spec, step 06, inline through **Bash** (no subagent), after every S102 write; asimov-spec in mode recheck, the same call per S102 in the folder.
- A hand-edited S102, by skill name, before it goes to review.
- The maintainer, to regression-test the script: a fixture repo with a plan and two task specs is enough.
