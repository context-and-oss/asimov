# Plan authoring

*The method file of the plan artifact, beside its definition and template. The plan writer subagent `asimov-spec` spawns reads it by path at every cut and re-cut and follows it as written. A file, not a skill: nothing is substituted in it, so a sibling is named by its file name and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

One design in, one plan out: the tree, the six plan sections and one section per task, in one file, in one pass. This file owns what the plan says and how it is written. `asimov-spec` owns the conversation, `scripts/validate-plan.ps1` beside this file the bar, `scripts/render-plan.ps1` the S101 and S102s the build reads, `asimov-plan-view.md` the rendering a person sees. A method file is a leaf: it reads artifacts and calls no skill.

## Read first

Files 1 to 3 sit beside this file or under the plugin root; never a relative path in a tool call, since the working directory is the product repo. If 1 cannot be read, stop and report the path; never plan from a remembered shape.

**This file is the method, the template is the shape, the script is the bar.** Do not read the S101 or S102 definitions or the contracts: what they require is in the steps below, the template's leading comment and the script's rows.

1. **The plan template**, whole: `asimov-plan-template.md`, beside this file.
2. **The thresholds**: `<plugin-root>/artifacts/dot-asimov/s101-implementation-plan/s101-implementation-plan-definition.md`, the `thresholds:` block and the ten lines after it, nothing more of the file.
3. **The design**, whole. A D101: §3 (R, NF, out of scope), §4.5 rules, §6 contracts by number, §8 acceptance criteria, §9 open questions; its `.phase-chip` must read `Full design`, else return *refused: not at Full design* and write nothing. A normalised design (`.asimov/plans/<slug>.design.md`): one section per contract member; a required member missing → *refused: design incomplete* naming it, nothing written.
4. **The conventions**: `documentation/conventions/<stack>/README.md` per stack the design touches, and of the files it lists only those that give the build and test commands, the runner and the layering. Never copied into the plan: the builder loads them. A stack with no conventions folder is a greenfield stack: the caller's `bootstrap` answers stand in for them.
5. **The repo, by a list, in one turn.** List first, from the design and the conventions: each file the design names or the criteria will change; one search per existing name a task must use, to place its declaring file; the test class of the code a slice changes; the project file of the owned project, for package ids. Then issue every read in **one message** as parallel tool calls, and every search in a second. Nothing else: no callers, no neighbouring folders, no file opened to see how it works. A repo with no project for a stack has nothing to read for it; say so in the §6 row that records the scaffold.
6. **On an update or rewrite**: the existing plan, whole.
7. **The repo's `CLAUDE.md`**, if present, for layout to respect and escalation triggers to honour.

## Inputs from the caller

Missing inputs take the default in brackets.

| Input | Meaning |
|---|---|
| `design` | The plan header's design line: `ref` (a repo path or url), `version` or `read`, and for a normalised design `cache` and `approval` (`verified` or `unverified`). Goes into the header as is; `ref` or `cache` is what you read. |
| `mode` | `new`, `update` or `rewrite` (the S101 definition §6). [`new` when no plan exists, else `update`] |
| `answers` | The author's answers to the caller's questions, and any unanswered question with its default. [none] |
| `slice` | On a normalised design, the author's answer to the fixed slice-shape question: `test-first` (one test-first builder per stack) or `pair` (a tester task, then a builder per stack, in every slice). [`test-first`] |
| `bootstrap` | For every stack the repo has no project for: the source and test roots, the solution file name and format, the target framework, the template commands and the test command, as the author answered or the defaults the caller stated. Each becomes a §2 constraint with the source *author, at the cut* and the Foundation's scaffolding task. [none: every stack has a project] |
| `cut_feedback` | The author's words at the gate, or the validation rows routed back. Overrides `answers` where they conflict. [none] |
| `keep` | Task ids whose section stays byte-identical; the plan is re-cut around them. [none] |

## Steps

### The plan

1. **Slices.** One per acceptance criterion a builder can make pass, end to end. A criterion verified by review or by hand maps to no slice; note it for the coverage map. Two criteria share a slice when `answers` or `cut_feedback` says so, or when one test class and one builder pass would make both pass in the same files; record the choice as an assumption. A ticket is cut by its test classes, not its criteria: criteria that one test class and one builder pass make pass share one slice, so a bug fix across a handful of files is one slice of one test-first builder per stack, and a plan with more tasks than files is a cut to redo. **Cut vertically**: a slice is observable at a public contract (an endpoint, a screen, a command); an internal layer (a cache, a mapper, a repository) with no public contract of its own is never a slice, because its tester would have nothing public to name. The owned-file threshold is a Warn the person reads at the cut, never a reason to split a fix. Order the slices by dependency, then by the design's order.

2. **Stacks and roles.** Per slice, the stacks it touches. A slice that **adds behaviour**: one tester task for its acceptance test, then one builder task per stack (`dotnet-builder`, `angular-builder`, or `human` where no role skill fits). A **ticket's slice** and a **maintenance slice** (every file exists, the tests extend an existing class): one test-first builder per stack and no tester task; record it in a §6 row naming the task as test-first and the test class it extends or creates. A ticket gets the tester-then-builder pair only when `slice` is `pair` or `cut_feedback` asks for it. A stack with no tester role (Angular today) takes its builder test-first the same way.

3. **Contracts, §1.** Every name one task produces and another consumes, with its exact signature or the design contract number that states it, and *Produced by* the task id; no consumer column. Existing code gets no row: the task section links it by path. A test name is never a contract. *none* when no task produces a name for another. A shape the design does not settle is a `design:` assumption (step 10), never a guess.

4. **Phase 0, Foundation, only when needed**: when §1 holds a name two tasks with no path between them both depend on; when something every slice builds against must land first (a constructor parameter a fixture needs, a test project reference, a migration, a shared type); or when `bootstrap` names a stack with no project yet. Then: the contracts of step 3 as code, public names with summaries and no bodies, compiling, cut per slice so no two parallel slice tasks own one skeleton file; and for a greenfield stack one **scaffolding task** (tier `low`) that runs the template commands from `bootstrap`, owns the folders the templates write as globs, names the commands in its §4 and keeps the template's own files as they come unless the design or a constraint says otherwise. Never a slice's behaviour, however small. A plan with nothing to found starts at P1; never a Foundation to satisfy the shape.

5. **The close, only when needed**: a phase after the last slice for work that ends the run and belongs to no criterion (a release, a reference put back, a flag flipped), often a `human` task, with a checkpoint like any phase.

6. **Order.** `after` on every task: a slice's tester (or test-first builder) after the Foundation task(s) of its stack, else after nothing; a builder after its tester; a consumer after its producer; the close after the last slice's tasks. Acyclic. Where two tasks with no path between them will touch one file, make the later slice's first task come after the earlier slice's builder and say so in an assumption naming the file.

7. **Three sentences per phase.** `delivers`: one sentence in the product's words, what the phase adds and why the next needs it; never a test, never a file. `checkpoint`: one plain sentence, what is true in the product when the phase is done, with the tests as the proof; no command, filter or path. `check`: the command that proves it, from the conventions or `bootstrap`, never invented; the verifier runs it, the view never shows it.

8. **Once, in the plan sections.** §2: the constraints the design imposes on every task and every departure from the conventions, one short line each, the value verbatim with its source, plus every `bootstrap` answer as a line with the source *author, at the cut*; never a convention restated, never a `CLAUDE.md` rule repeated. §5: the failure modes no task's check exercises, each pinned to the task that carries the scenarios of the code it concerns. §4: who rules and the stops specific to this plan as one sub-bullet each, or *none*.

9. **Coverage map, §3, both ways.** Every id of the design in scope against task ids; every task's `traces` against what it serves. An id no task serves carries its reason. A normalised design's rows carry the source's wording in *Says*. A requirement with no task and no reason is fixed now; a task with no requirement is scope dropped.

10. **Tiers and assumptions, §6.** `low` where the names, the signatures and the check determine the task; `mid` for behaviour in prose with a clear check; `high` for judgement or integration. Then every decision taken without a question, in order: the question, the options, the default taken; *How* is `default`, `decided by default` or `corrected at the cut`, with `, behaviour` appended when the decision changes what a user sees or gets. A gap no default bridges gets a row whose *Taken* begins `design:`. No §6, no plan.

### The tasks

11. **One section per task of the tree**, in tree order, heading `## T001 — <the task line's title>`. Write the tester of a slice before its builders, so the builder's section is written with the tester's scenarios in front of you. A task in `keep` is copied byte for byte.

12. **The yaml block**, first in the section and the only one: `owns` with `create`, `modify`, `test` and `regenerates`; `consumes`; `produces`. Exact repo-relative paths, or globs for a folder the task owns whole (a scaffolding task's template output). `test` holds every test file the task creates or modifies; `create` and `modify` non-test files edited by hand, a modified file one that exists or that a task this one comes after creates. Keep the three disjoint from every task that may run beside this one; where you cannot, make the later task come after (step 6), never widen or overlap. `regenerates`: what a build, a restore or a generator rewrites because of the task's edits, as a glob, never under `modify`; `[]` when none. `consumes`: every §1 name this task relies on whose producer it comes after, spelled as the table spells it; every existing type, method or value a scenario or a must will mention, as `<Name> (<repo-relative path>)`; every package type as `<Name> (package <PackageId>)`. `produces`: every §1 name whose *Produced by* is this task. Nothing else in the block: the task line and the plan header provide the rest.

13. **§1 Intent.** One or two sentences in the design's words: what the task delivers and why the feature needs it.

14. **§2 Behaviour.** One Gherkin scenario per behaviour the task adds, public names only, every rule with its failing case as its own scenario. A review-focus line pinned to this task is a scenario with `@review-focus` on the line above it. A **tester** carries every scenario of the slice. A **builder with a tester** writes one line, `as T<nnn>: the scenarios of this slice's tester task`, plus a gherkin block only for a scenario the tester does not carry. A **test-first builder** carries the slice's scenarios itself. A task that adds no behaviour writes one line: *none: this task adds no behaviour; its check is `<the build / the command>`*.

15. **§3 Done-when.** Numbered, each runnable: a test class under the test command with its expected state; a build command and its exit; a command and its output. A test is named by its **class and scenario title, never a method name**. A tester: the class exists or gained tests, one per scenario of §2 by title, red until the builder lands. A builder with a tester: the tester's task id and its test class in one code span, and that the tests it adds are green. A test-first builder: its own test file or class, one test per scenario, green. Never a search of the source.

16. **§4 Constraints and stops, §5 Out of scope.** Only what is specific to this task: musts, must nots, preferences by path, and this task's own stops; a scaffolding task's §4 names its template commands. The generic stops hold by the definition and are not listed. §5: the neighbouring task that owns the adjacent thing, the follow-up the design deferred, the refactor that tempts; *none* if none. A `low` task takes the light form: one sentence of intent, the `none:` line, the done-when, *none* in §4 and §5 unless it has a stop or a boundary of its own.

### Write and check

17. **Write** `.asimov/plans/<slug>.md` from the template: the `design` line as passed, the tree with one task per line, the six plan sections, the first paragraph naming the design and its approval (and *unverified* when the design line says so), the task sections, `status: draft`, `approved: none` on a new file (an existing `approved:` line is kept byte-identical; the render script settles it). Create the folder if absent. No prose that retells the tree, no code block but Gherkin and the yaml blocks, no template guidance sentence left in.

18. **Check your own plan.** Through Bash:

   ```
   pwsh -NoProfile -File "<plugin-root>/artifacts/dot-asimov/asimov-plan/scripts/validate-plan.ps1" -Plan .asimov/plans/<slug>.md
   ```

   (`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell; `-PluginRoot <plugin-root>` in Codex; `-Design <path>` when the plan's design line would not resolve.) Fix every Fail the plan can fix (a builder not after its tester, a coverage row missing, a path that does not resolve, a done-when without a code span and a result word, a placeholder, a count) and run it again, at most twice. A `design:` row is not yours to fix: it becomes a `design:` assumption. Flags and Warns are left. With no PowerShell, skip and say so in the return line. The caller's run is the record.

19. **Return** the path; one line `<n> phases · <m> tasks · <slug>.md written (draft v<version>)`; one line `self-check: clean | <k> fail left: <the rows> | skipped: no PowerShell`; and any template findings, one line each under `template findings:` (a place where the plan had to work around a rule of the template or a check). Print nothing else.

## Modes

- **new.** No plan exists. Version `0.1`.
- **update.** The design's items are unchanged. Start from the plan on disk, keep every task in `keep`, re-cut around them, bump the version when an approval with a fingerprint is on disk.
- **rewrite.** An id missing or added, or the content changed. Plan from the design alone; `keep` is empty; bump the version when an approval is on disk.
- **Any cut round after the first** (`cut_feedback` present). Start from the plan on disk, which may carry hand edits, apply the feedback, rewrite in place. The version stays while `approved:` is `none`.

## Never

- Write anything but `.asimov/plans/<slug>.md`: never the S101, an S102, the ledger, the design or the conventions.
- Write code, a step, a test body, or a signature outside §1; a method body or a private name anywhere.
- Put a command in a `checkpoint` or a sentence in a `check`; a test result in `delivers`.
- Copy a convention into §2; invent a stack, a runner, a path, a layout or a signature: what you cannot ground is an assumption with its options, a `bootstrap` answer, or a `design:` row.
- Put a slice's behaviour in the Foundation, cut a Foundation with nothing to found, cut an internal layer as a slice, or put a builder beside or ahead of its tester.
- Put existing code or a test name in §1; restate a signature in a task section; name a test method.
- Set a status other than `draft`; write, change or drop the `approved:` line; touch a plan whose S101 is `in progress` or `done` (return *refused* with the status).
- Ask a question or wait: a missing answer takes its default and becomes an assumption.
- Write a placeholder; open a section with the template's sentence; leave a template description in.
- Judge the plan beyond the script (step 18), render it, or call any skill.
- Bake a product entity into this file.

## Used by

- asimov-spec, step 02, at every cut round; the caller renders with `scripts/render-plan.ps1` after the go.
- A hand run: validate with `scripts/validate-plan.ps1`, print the plan with `asimov-plan-view.md`, render with `scripts/render-plan.ps1 -Approve`.
