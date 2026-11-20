# Plan validation

*The validation method of the plan artifact, beside its definition and template. `asimov-spec` runs its script, `scripts/validate-plan.ps1` beside this file, before the cut is shown and on every re-check, and the plan writer runs the same script on its own output; this file is read by path only where no PowerShell exists. A file, not a skill: nothing is substituted in it, so a sibling is named by its file name and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

One check of the whole specification: does the plan clear its bar, which is the bar of what it renders to (definition §2). The script renders the plan in memory exactly as `scripts/render-plan.ps1` renders it to disk, then answers the S101 rows on the rendered S101 with every rendered S102 beside it, and the S102 rows on each rendered S102. Every row is answered by enumeration and lookup, never by judgement, so two runs on an unchanged plan agree. **It runs nothing**: no build, no test; it looks a thing up (an id in the design, a path on disk, a name in a file the task names, a package in a project file, a count against a threshold). **It opens nothing the plan does not name.**

## The call

```
pwsh -NoProfile -File "<plugin-root>/artifacts/dot-asimov/asimov-plan/scripts/validate-plan.ps1" -Plan .asimov/plans/<slug>.md [-Design <design path>]
```

`pwsh` (PowerShell 7) or `powershell` (Windows PowerShell 5.1; add `-ExecutionPolicy Bypass`), whichever the machine has; the script runs on both. The repo root is derived from the plan path (`<root>/.asimov/plans/<slug>.md`), so the script runs from any working directory (`-RepoRoot` overrides it); the plugin root from its own location, four folders above it (`-PluginRoot <plugin-root>` overrides, needed in Codex). Without `-Design` the script reads the plan's `design` line: the cache when there is one, else the ref when it is a file in the repo.

**Return the script's output verbatim** and nothing else. Exit code 2 means an input could not be read; the one line it prints says which, and that line is the report. The report ends in one `summary:` line, `<k> fail · <f> flag · <w> warn · <n> tasks`, which is what a caller counts. **Never** correct a row, add a row, or soften one.

**Where no PowerShell is installed**, say so in one line, then answer the rows below by hand in a fresh read-only subagent on the validation model (`model-choice.md` §1.2), on the same closed read list, and return the report with `engine: llm` in place of `engine: script`; the caller records the run as one to re-check from a machine with the script.

## What the script reads, and nothing else

1. The plan, whole. 2. The S101 template (keys, role and tier values, plan section titles), the S102 template (yaml block keys, task section titles) and the S101 definition's `thresholds:` block, under `<plugin-root>/artifacts/dot-asimov/`. 3. The design, only to list its ids (a D101's `id` and `ac-id` spans; a cache's numbered items) and to find a word in it. 4. The repo: a directory listing for a path in `owns`, one search of a named file for a consumed name, the project files for a package id. Not the definitions, not the contracts, not the conventions, not a file the plan does not name, not the code's logic.

## The plan rows

Answered on the rendered S101 with every rendered S102's header beside it. One row each, Pass / Flag / Fail / Warn with one sentence naming the task, pair, file or id it is about.

| # | Item | Result rule |
|---|---|---|
| G1 | Frontmatter | `spec: plan`; every S101 template key present; `design` a flow map with `ref` and `version`, or `read` + `cache` + `approval` for a normalised design (no `approval` → Flag); `approved` `none` or `by` + `date` + `fingerprint`; `status` `draft` or `ready`; a title heading; every phase with `id`, `name`, `delivers`, `checkpoint`, `check`, `tasks`; every task with `id`, `title`, `role`, `tier`, `after`, `traces`, role and tier from the templates' lists, ids `T001..` in order with no gap. A task line carrying `owns`, `produces`, `consumes`, `file` or `phase` → Flag (the yaml block's); a title over 60 or a phase name over 40 characters → Flag. Otherwise Fail. |
| G2 | No cycle | Every `after` id exists; no task reaches itself → else Fail, naming the cycle. |
| G3 | Phases | `P0`, when present, is first and named Foundation; every phase holds a task; every slice (a phase with traces) holds a builder, every builder comes after a tester of its own stack or is test-first and owns a test file; every slice task comes after a P0 task of its stack when P0 has one; a close phase (empty traces after the last slice) comes after a slice task; a phase with no traces before the last slice → Fail. A tester after an earlier slice's builder: Pass when a §6 row names the shared file, Flag otherwise. |
| G4 | Parallel = disjoint | For every pair with no path between them, the unions of their `create`, `modify` and `test` lists intersect (globs expanded against the repo) → Flag naming the pair and the file; `regenerates` takes no part. |
| G5 | Contracts table | §1 has Name, Shape, Produced by, or reads *none*; every producer is a task in the tree → else Fail. A *Consumed by* column, a row produced by existing code, a test name → Flag. |
| G6 | Coverage both ways | Every R, NF and AC of the design appears in §3 with task ids or a stated reason; every id in the map exists in the design; every task's `traces` is non-empty and in the design; every task id appears in the map; every phase's traces exist; a normalised design's rows have a non-empty *Says*. A miss → Fail, prefixed `design:` when the id is not in the design. |
| G7 | Sizes | Per task, `create` + `modify` above the threshold → Warn. Never Fail. |
| G8 | Body | §1–§6 present in the template's order; every task and phase id the plan sections name exists; §6 non-empty; no code fence, no step list, no checkbox in the plan sections (Fail / Flag); a signature outside §1 → Flag. |
| G9 | Task sections | One section per task of the tree, opening with its yaml block; no section for a task outside the tree; no task twice → else Fail. A heading title differing from the task line → Flag (the task line is rendered). |
| F3 | Interface closure across tasks | Every `consumes` entry is a §1 row produced by a task this one comes after, existing code `Name (path)` whose path exists, or a package type `Name (package Id)` referenced by a project file; every `produces` entry is a §1 row naming this task → else Fail. |
| F4 | Constraints | A task §4 line that restates a §2 line on subject and value → Flag, quoting both. A contradiction is not detected by the script. |
| 1–10 | The ten checks of the S101 definition §8 | Completeness (members, first paragraph, three sentences per phase, G9); Coverage (G6); Graph validity (G2–G4); Stoppable phases (a checkpoint that reads as a claim or carries a command, a check that is empty, searches the source or has no runnable form, a delivers that reads as a test result); Interface closure (G5, F3); Constraint consistency (a §2 line without a source, F4); Review focus (each §5 line a condition, an arrow and a task; a line pinned to a builder whose slice has a tester → Flag); Escalation (route, plan-specific stops, the human-always cases); Separation (G8, run state); Model choice (tiers; a `low` task with a Scenario → Flag). |

## The task rows

Answered on each rendered S102, prefixed with the task id (`T003 S3`). The header equals the task line by construction, so the S102 checklist's S2 does not exist here.

| # | Item | Result rule |
|---|---|---|
| S1 | Header block | `owns` with `create`, `modify`, `test`, `regenerates` (a missing `regenerates` → Flag), `consumes` and `produces` present → else Fail; an extra key, or a key the task line or the plan header provides (`task`, `title`, `role`, `tier`, `after`, `traces`, `status`, `validated`, `author`, `date`) → Flag. |
| S3 | Paths resolve | Every `modify` path exists or is in the `create` of an upstream task (a glob that matches nothing → Flag); every `create` path does not exist; no path in two lists; a generated file under `create`, `modify` or `test` → Flag; a test file under `modify` → Flag; a path in the body that is neither owned nor existing → Fail (inside a command, first resolved against a `--prefix`, `-C` or `cd` folder; still unresolved → Flag). |
| S4 | Names in the contracts | As F3 for this task, with the name's declaration looked up in the file an existing-code entry names; a test name in `consumes` → Flag. |
| S5 | Placeholders | `TBD`, `TODO`, `FIXME`, `XXX`, `similar to T0`, `handle edge cases`, `appropriate error handling`, `as needed`, `to be decided`, a `{{PLACEHOLDER}}`, an empty fence, or a template description (an angle-bracket phrase of two or more words outside a code span) → Fail, quoting it. |
| S6 | Sections | §1–§5 in the template's order; §2 holds a gherkin Scenario, a `none:` line naming the check, or for a builder an `as T<nnn>:` line naming a tester of the same phase it comes after; §3 holds a numbered item → else Fail. |
| S7 | Boundary tokens | A fence whose language is not gherkin, a list under a *Steps* heading, a Scenario naming a path, a done-when with `grep`, `rg`, `Select-String` or `findstr` → Fail. An identifier in a scenario found in no §1 row, header entry, design or consumed path → Flag. |
| S8 | Sizes | `create` + `modify` over the threshold, or own scenarios over the role's threshold (`@review-focus` not counted) → Warn. |
| 1–10 | The ten checks of the S102 definition §8 | Traceability (every traced id in the design, `design:` when not); Scope (S3; an owned project file with lock files in the repo and an empty `regenerates` → Flag); Interface closure (S4); Behaviour (`n/a` for a `none:` line naming a build or command; every Scenario with Given, When and Then; one `@review-focus` scenario per §5 line pinned to this task; the tester's §2 holds a Scenario for an `as T<nnn>:` line); Done-when (every item a code span and a result word; a builder with a tester of its stack names a test class the tester's §3 names; never a search); Stops (a generic stop repeated without anything of this task → Flag); Boundary (a Must naming a call, a loop or an algorithm; a restated signature → Fail); Hygiene (S5, S6, run state, a copied §4 routing line); Size (S8); Inheritance (a §4 line restating a §2 line → Flag). |

**The source of a Fail.** A traced id the design does not carry, or a plan defect the design does not settle, begins `design:`; everything else is the plan's. The caller stops on `design:` and re-cuts the rest unseen.

**Template findings.** A place where the plan visibly worked around a rule of the template or of this checklist is reported as one line under `template findings:` after the report, never as a Fail. The caller writes them to the sidecar for the maintainer.

## Report

```
## Validation report
target: .asimov/plans/<slug>.md
bar: dispatch-ready
engine: script (validate-plan.ps1) | llm
| # | Check | Result | Reason |
|---|---|---|---|
| G1 | Frontmatter | Pass | … |
| … | … | … | … |
| 10 | Model choice | Pass | … |
| T001 S1 | Header block | Pass | … |
| … | … | … | … |
| T003 10 | Inheritance | Pass | … |

summary: <k> fail · <f> flag · <w> warn · <n> tasks
```

One sentence per reason. No verdict, no fix. The caller keeps the rows for the sidecar; a person never reads the table.

## Never

- **Run anything that executes code**, or **open a file the plan does not name**.
- **Edit** or **propose a fix**. The caller routes a Fail to the writer as `cut_feedback`.
- **Judge** whether the phases are sensible, the scenarios the right ones, the cut too fine or too coarse, or a test would pass today.
- **Flag an impression.** A Flag names what would change.
- **Answer the rows by hand when the script can run.**
- **Render the plan** for a person; `asimov-plan-view.md` does.
- **Move a status**, write the sidecar or the rendered files; `render-plan.ps1` and the caller do.

## Used by

- asimov-spec, step 03 (before the cut is shown; a Fail is re-cut unseen) and the re-check of a ready plan.
- asimov-plan-authoring.md, step 18, on the writer's own output.
- By hand, on a plan someone edited, before rendering it again.
