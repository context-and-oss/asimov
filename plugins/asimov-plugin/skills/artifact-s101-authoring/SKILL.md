---
name: artifact-s101-authoring
description: How to cut one design that meets contracts/design.md, a D101 at Full design or a normalised design cache, into one S101 implementation plan (documentation/specs/<slug>/S101-<slug>.md) — the plan part of a specification under contracts/specification.md: slices from the acceptance criteria, a Foundation phase 0 only when the plan needs one (the contracts as code, whatever every slice builds against), a tester task before the builder tasks in every slice that adds behaviour and one test-first builder per stack in a maintenance slice, a close phase when the run needs one, the contracts stated once, the constraints the design imposes, the coverage map, the assumptions — and write it from the template. Use when asked to "cut this D101 into a plan", "write the S101 for this feature", "re-cut the plan with this correction", or inside asimov-spec at every cut round. Writes the S101 only; never an S102, never a question, never the view (artifact-s101-view prints the plan); it runs the graph script on its own cut before returning.
---

# S101 authoring

One design in, one S101 draft out. This skill owns what the plan says and how it is written. asimov-spec owns the conversation, `skills/artifact-s101-validation/scripts/validate-s101.ps1` the bar, artifact-s101-view the rendering. A skill is a leaf: it reads artifacts and calls no other skill.

## Read first

`${CLAUDE_PLUGIN_ROOT}` is substituted in Claude Code. In Codex it stays literal: derive `<plugin-root>` from this skill's own path (strip everything from `skills/artifact-s101-authoring` onward), verify by reading file 1, else Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-template.md` and take the match that shares the longest prefix with the skill path; with no match, stop and report (`D101-codex-support.html` §6.2). If 1 or 2 cannot be read, stop and report the path; never plan from a remembered shape.

**This skill is the method, the template is the shape, the script is the bar.** Do not read the definitions or the contracts: what they require is in the steps below, the template's leading comment and the script's rows. The definitions are cited by section where a rule comes from.

1. **The S101 template**, whole: `${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md`
2. **The thresholds**: in `${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md`, the `thresholds:` block and the ten lines after it, nothing more of the file.
3. **The design**, whole. A D101: §3 (R, NF, out of scope), §4.5 rules, §6 contracts by number, §8 acceptance criteria, §9 open questions; its `.phase-chip` must read `Full design`, else return *refused: not at Full design* and write nothing. A normalised design (`documentation/specs/<slug>/design.md`): one section per contract member; a required member missing → *refused: design incomplete* naming it, nothing written.
4. **The conventions**: `documentation/conventions/<stack>/README.md` per stack the design touches, and of the files it lists only those that give the build and test commands, the runner and the layering (the Read tool does not expand `@`-imports). Never copied into the plan: the builder loads them.
5. **The repo, by a list, in one turn.** List first, from the design and the conventions: each file the design names or the criteria will change; one search per existing name a task must use, to place its declaring file; the test class of the code a slice changes; the project file of the owned project, for package ids. Then issue every read in **one message** as parallel tool calls, and every search in a second. Nothing else: no callers, no neighbouring folders, no file opened to see how it works, no second read. You are planning, not building; a ticket-sized cut is about fifteen tool calls after these.
6. **On an update or rewrite**: the existing `S101-<slug>.md` and the headers of every `S102-*.md` in the folder.
7. **The repo's `CLAUDE.md`**, if present, for layout to respect and escalation triggers to honour.

## Inputs from the caller

Missing inputs take the default in brackets.

| Input | Meaning |
|---|---|
| `design` | The S101 header's design line: `ref` (a repo path or url), `version` or `read`, and for a normalised design `cache` and `approval` (`verified` or `unverified`). Goes into the header as is; `ref` or `cache` is what you read. |
| `mode` | `new`, `update`, `rewrite` (definition §6) or `finalise`. [`new` when no S101 exists, else `update`] |
| `answers` | The author's answers to the caller's questions, and any unanswered question with its default. [none] |
| `slice` | On a normalised design, the author's answer to the fixed slice-shape question: `test-first` (one test-first builder per stack) or `pair` (a tester task, then a builder per stack, in every slice). [`test-first`] |
| `cut_feedback` | The author's words at the gate, or a validation row routed to the plan. Overrides `answers` where they conflict. [none] |
| `keep` | Task ids whose S102 is written and clears. Their line does not change and their file stays byte-identical; the plan is re-cut around them. [none] |

## Steps

1. **Slices.** One per acceptance criterion a builder can make pass, end to end. A criterion verified by review or by hand maps to no slice; note it for the coverage map. Two criteria share a slice when `answers` or `cut_feedback` says so, or when one test class and one builder pass would make both pass in the same files; record the choice as an assumption. A ticket is cut by its test classes, not its criteria: criteria that one test class and one builder pass make pass share one slice, so a bug fix across a handful of files is one slice of one test-first builder per stack (step 2), and a plan with more tasks than files is a cut to redo. The owned-file threshold (§8.1) is a Warn the person reads at the cut, never a reason to split a fix: record the count as an assumption instead. Order the slices by dependency, then by the design's order.

2. **Stacks and roles.** Per slice, the stacks it touches (the D101 §6 contracts or the ticket's decision, and the conventions folders present). A slice that **adds behaviour**: one tester task for its acceptance test (a new class, or tests added to the existing class of the code it changes), then one builder task per stack (`dotnet-builder`, `angular-builder`, or `human` where no role skill fits). A **ticket's slice** (a normalised design, whether or not the fix adds a name), and a **maintenance slice** of any design (every file exists, the tests extend an existing class): one test-first builder per stack and no tester task, the default; it adds the tests first, then the fix, owns both and carries the slice's scenarios; record it in a §6 row naming the task as test-first and the test class it extends or creates. A ticket gets the tester-then-builder pair only when `slice` is `pair` or `cut_feedback` asks for it. A stack with no tester role (Angular today) takes its builder test-first the same way: it owns its spec file under `test` and names it in its done-when; record the choice as an assumption.

3. **Contracts, §1.** Every name one task produces and another consumes, with its exact signature or the design contract number that states it, and *Produced by* the task id; no consumer column (the S102 headers record consumption). Existing code gets no row: the S102 links it by path. A test name is never a contract. *none* when no task produces a name for another. A shape the design does not settle is a `design:` assumption (step 10), never a guess.

4. **Phase 0, Foundation, only when needed**: when §1 holds a name two tasks with no path between them both depend on, or when something every slice builds against must land first (a constructor parameter a fixture needs, a test project reference, a migration, a shared type). Then: the contracts of step 3 as code, one task per stack, public names with summaries and no bodies, compiling (Angular with minimal templates so a build proves it), cut per slice so no two parallel slice tasks own one skeleton file; a type two slices need is Foundation's. Never a slice's behaviour, however small. Tier `low`. A plan with nothing to found starts at P1; never a Foundation to satisfy the shape, and for a ticket never one whose only purpose is a name the slice's own tests compile against: the test-first builder owns that name.

5. **The close, only when needed**: a phase after the last slice for work that ends the run and belongs to no criterion (a release, a reference put back, a flag flipped), often a `human` task, with a checkpoint like any phase; never squeezed into the last slice.

6. **Order.** `after` on every task: a slice's tester (or test-first builder) after the Foundation task(s) of its stack, else after nothing; a builder after its tester; a consumer after its producer; the close after the last slice's tasks. Acyclic. Where two tasks with no path between them will touch one file (the same service, test class or registration), make the later slice's first task come after the earlier slice's builder and say so in an assumption naming the file: the normal shape of maintenance work.

7. **Three sentences per phase.** `delivers`: one sentence in the product's words, what the phase adds and why the next needs it (*adds the internal role set and the check for whether a caller is staff; every list below filters through it*); the first line a person reads under the phase name; never a test, never a file. `checkpoint`: one plain sentence, what is true in the product when the phase is done, with the tests as the proof (*external users no longer see internal roles in the user list, and the user service tests prove it, including the mixed-account case*; *the solution builds with every public name in place and no bodies*); no command, filter or path. `check`: the command that proves it, from the conventions, never invented (the build command for a Foundation, the test command filtered to the slice's test class, a command and its result for a close); the verifier runs it, the view never shows it.

8. **Once, in the body.** §2: the constraints the design imposes on every task (D101 §6 values, the ticket's decision and rules) and every departure from the conventions, one short line each, the value verbatim with its source; never a convention restated, never a `CLAUDE.md` or `AGENTS.md` rule repeated. §5: the failure modes no task's check exercises, each pinned to the task that carries the scenarios of the code it concerns (a slice's tester, or the test-first builder of a maintenance slice; a Foundation or close task directly). §4: who rules (from `answers`, or the person directing the run) and the stops specific to this plan as one sub-bullet each, or *none*, including the ones the repo's `CLAUDE.md` names.

9. **Coverage map, §3, both ways.** Every id of the design in scope (a D101's R, NF, §6.x.y and AC; a cache's R, NF and AC) against task ids; every task's `traces` against what it serves. An id no task serves carries its reason: *verified by review*, or *out of scope here, per OOSn*. An OOS id that bounds a task may have a row, delivered by that task; none is required. A normalised design's rows carry the source's wording in *Says*; a D101's may read —. A requirement with no task and no reason is fixed now; a task with no requirement is scope dropped.

10. **Tiers and assumptions, §6.** `low` where the names, the signatures and the check determine the task; `mid` for behaviour in prose with a clear check; `high` for judgement or integration. Then every decision taken without a question, in order: the question, the options, the default taken; *How* is `default`, `decided by default` or `corrected at the cut`, with `, behaviour` appended when the decision changes what a user sees or gets (an output, a visible rule, a stored value): the view prints those rows, so the author sees them before the go. A gap no default bridges gets a row whose *Taken* begins `design:`. A workaround of the template or a check is a template finding (step 13), not an assumption. No §6, no plan.

11. **Write** `documentation/specs/<slug>/S101-<slug>.md` from the template: the `design` line as passed (the template's other one dropped), the tree with one task per line, the six body sections, the first paragraph naming the design and its approval (and *unverified* when the design line says so), `status: draft`, `approved: none` on a new file (an existing `approved:` line is kept byte-identical). Create the folder if absent. Ids `P0`, `P1..Pn`, `T001..` in order of appearance. A phase `name` is two to five words; a task `title` three to seven, under 60 characters, never the sentence that says what it covers (the S102's intent). No prose that retells the tree, no code, no signature outside §1, no template guidance sentence left in: the file holds content only.

12. **Check your own graph.** Through Bash:

   ```
   pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/skills/artifact-s101-validation/scripts/validate-s101.ps1" -S101 <the S101> -Mode graph-only
   ```

   (`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell; `-PluginRoot <plugin-root>` in Codex.) Fix every Fail the plan can fix (a builder not after its tester, a cross-slice `after`, a coverage row missing or naming an id the design lacks, a command in a `checkpoint`, a title over the length) and run it again, at most twice. A `design:` row is not yours to fix: it becomes a `design:` assumption. Flags and Warns are left. With no PowerShell, skip and say so in the return line. The caller's run is the record.

13. **Return** the path; one line `<n> phases · <m> tasks · S101-<slug>.md written (draft v<version>)`; one line `self-check: clean | <k> fail left: <the rows> | skipped: no PowerShell`; and any template findings, one line each under `template findings:`.

## Modes

- **new.** No S101 exists. Version `0.1`.
- **update.** The design's items are unchanged. Start from the S101 on disk, keep every task in `keep`, re-cut around them, bump the version.
- **rewrite.** An id missing or added, or the content changed. Plan from the design alone, bump the version; the caller has deleted every S102 and `keep` is empty.
- **finalise.** After the plan validation. Start from the S101 on disk and change only §1, §3 and §6 so they agree with the task specs as written (a produced name with no row, a trace gained or lost, an assumption a rewrite resolved). No re-cut, no change to the tree; `keep` is every task. Bump the version when §3 or §6 changed; a §1-only change bumps nothing. Return the path, `finalise: §1 +2 rows · §3 1 row changed · §6 +1` or `finalise: nothing changed`, then one line per cell.
- **Any cut round after the first** (`cut_feedback` present). Start from the S101 on disk, which may carry hand edits, apply the feedback, rewrite in place. The version stays while `approved:` is `none`; once an approval with a fingerprint is on disk, every write that changes the tree, §2, §3 or §6 bumps it (`0.3` → `0.4`), a write to §1, §4 or §5 alone does not (definition §6).

## Never

- Write an S102, or anything outside `documentation/specs/<slug>/`: you write the S101 only.
- Write code, a step, a test body, or a signature outside §1.
- Put a command in a `checkpoint` or a sentence in a `check`; a test result in `delivers`.
- Write a task title or a phase name that is a sentence.
- Copy a convention into §2.
- Put a slice's behaviour in the Foundation, cut a Foundation with nothing to found, or a builder beside or ahead of its tester.
- Put existing code or a test name in §1.
- Set a status other than `draft`; write, change or drop the `approved:` line; touch an S101 at `ready` or later (return *refused* with the status).
- Ask a question or wait: a missing answer takes its default and becomes an assumption.
- Re-cut an S101 the author edited by hand: on `cut_feedback` of the form *read again*, return *not mine*.
- Judge the plan beyond the graph script (step 12), validate an S102, render the plan, or call any skill.
- Delete a file: the caller deletes.
- Invent a stack, a runner, a path or a signature: what you cannot ground is an assumption with its options, or a `design:` row.
- Read the ticket anywhere but the cache, or fix the cache: a defect in it is a `design:` row.
- Touch a task in `keep`, or anything but §1, §3 and §6 in `finalise`.
- Bake a product entity into this skill.

## Used by

- asimov-spec: step 02 per cut round; step 07 with a plan-level row as `cut_feedback` and every clearing task in `keep`; step 08 in mode `finalise`.
- A hand run: print the plan with artifact-s101-view before calling artifact-s102-authoring per task.
