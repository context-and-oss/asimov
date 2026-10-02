---
name: artifact-s101-authoring
description: How to cut one design source, a D101 at Full design or a ticket cache carrying the plan's ids, into one S101 implementation plan (documentation/specs/<slug>/S101-<slug>.md) — slices from the acceptance criteria, a Foundation phase 0 with the skeleton per stack, one builder task per stack and one tester task per slice, the interfaces, the constraints stated once, the coverage map, the assumptions — write it from the template, and return the cut summary a person reads before any task spec is written. Use when asked to "cut this D101 into a plan", "write the S101 for this feature", "re-cut the plan with this correction", or inside asimov-spec at every cut round. Writes the S101 only; never an S102, never a question, never a validation.
---

# S101 authoring

The decomposition: one D101 in, one S101 draft out, plus the cut summary for chat. This skill owns *what the plan says and how it is written*. It does not own the conversation (asimov-spec asks, shows the cut, waits for the go), and it does not validate (artifact-s101-validation does). A skill is a leaf: it reads artifacts and calls no other skill.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 or 2 cannot be read either way, stop and report the path; never plan from a remembered bar.

1. **The S101 definition** — the bar (§2), the required content (§4, with §4.3 the graph rules, §4.4 phase = slice, §4.9 assumptions), the rules (§5), the lifecycle and the update-vs-rewrite rule (§6), the thresholds (§8.1):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

2. **The S101 template** — its leading comment holds the ids, the values and what never goes in the plan; its body is the shape you write:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

3. **The design source**, whole. A D101: §3 (R, NF, out of scope), §4.5 rules, §6 (the contracts, by number), §8 (the acceptance criteria), §9 (open questions that change the breakdown); resolve the phase from its `.phase-chip`, and anything but `Full design` is not yours to plan — return *refused: not at Full design* and write nothing. A ticket cache (`documentation/specs/<slug>/ticket.md`, written by asimov-spec): the decision and rules as `[R..]`, the acceptance criteria as `[AC..]`, the out-of-scope items as `[OOS..]`, the approval line; a cache without ids is not yours to plan — return *refused: ticket not checked against the bar* and write nothing.

4. **The repo's conventions**: `documentation/conventions/<stack>/README.md` for each stack the D101 §6 touches, and every file the README lists (the Read tool does not expand `@`-imports). From them: the build and test commands, the test runner a checkpoint may name, the layering a global constraint repeats verbatim.

5. **On an update or rewrite**, the existing `S101-<slug>.md` and every `S102-*.md` in the folder.

6. **The repo's `CLAUDE.md`**, if present, for layout you should respect.

## Inputs from the caller

asimov-spec passes these in its call; a hand run states them in the prompt. Missing inputs take the default in brackets.

| Input | Meaning |
|---|---|
| `design` | The design source: kind `d101` with its path, or kind `ticket` with the cache path, url, key and fetched date. Goes into the S101 header as is. |
| `mode` | `new`, `update`, `rewrite` (definition §6) or `finalise` (below). asimov-spec decides it; a hand run with an existing S101 states it. [`new` when no S101 exists, else `update`] |
| `answers` | The author's answers to the questions asimov-spec asked, and any unanswered question with the default it took. [none] |
| `cut_feedback` | Free text the author wrote at the gate, or a validation row the caller routes to the plan. The same channel as `answers`; it overrides them where they conflict. [none] |
| `keep` | In any mode: task ids whose S102 is written and clears its bar. Their id, file name, role, tier, phase, dependencies and owned lists do not change, and their S102 files stay byte-identical; the plan is re-cut around them. [none] |

## Steps

Work in this order; each step feeds the next.

1. **Slices.** One per acceptance criterion of the design source a builder can make pass, end to end. A criterion verified by review or by hand (a document exists, a reviewer confirms a wording) maps to no slice; note it for the coverage map as *verified by review*. Two criteria share a slice only when `answers` or `cut_feedback` says so. Order the slices by dependency, then by the D101's order.

2. **Stacks and roles.** Per slice, the stacks it touches, read from the D101 §6 contracts or the ticket's decision, and the conventions folders present. One builder task per stack (`dotnet-builder`, `angular-builder`, or `human` where no role skill fits), plus one tester task for the slice's acceptance test. The tester role is the stack's tester where one exists; where none does (an Angular-only slice today), take the builder of that stack test-first and record the choice as an assumption.

3. **Phase 0, Foundation.** One skeleton task per stack: the classes, interfaces and public methods with summaries and no bodies, compiling; in Angular with minimal templates so a build proves it. Cut the skeleton files per slice, so that no two slice tasks that may run in parallel own the same skeleton file; where two slices need one type, the type is Foundation's and the slices consume it. Every slice task depends on its stack's skeleton task. Tier `low`: it is a transcription of the interfaces.

4. **Interfaces.** Every name one task produces and another consumes: exact signature, or the D101 §6 contract number that already states it. Existing code a task consumes is linked by path. No consumed name without a producer in the graph or a path on disk. These names go verbatim into `produces` / `consumes` and into the body's §3 table.

5. **Owned sets.** Per task, three lists, `create`, `modify` and `test`, exact and repo-relative paths; the S102 repeats them list for list. Check every pair of tasks that neither depends on the other, directly or transitively: the unions must be disjoint. A shared file makes one task the owner and the other its dependant; decide it here, not at run time.

6. **Once.** Global constraints verbatim from the design source (D101 §6, or the ticket's decision and rules) or the conventions, each with its source; the review focus (the failure modes no task's test exercises, each pinned to a task); the escalation routing (who rules, from `answers` or the default: the person directing the run).

7. **Coverage map, both ways.** Every id of the design source in scope (a D101's R, NF, §6.x.y and AC; a ticket's R, AC and OOS from the cache margin) against task ids; every task against what it serves (its `traces`). For a ticket, every row carries the source's wording in the *Says* column, one line, so the plan stands with the ticket link alone; for a D101 the column may read —. A requirement with no task is a gap you fix now by adding or widening a task; a task with no requirement is scope you drop.

8. **Tiers.** `low` where the S102 will carry the code (skeleton, transcription), `mid` for prose steps with a clear check, `high` for judgement or integration. Record a non-obvious tier as an assumption.

9. **Assumptions.** Every decision taken without a question, in the order taken: the question it would have been, the options, the default taken; *How* is `default`, `decided by default` (the budget was spent) or `corrected at the cut` (what `cut_feedback` changed). A gap no default can bridge gets a row whose *Taken* cell begins `design:` and names what the design source is missing; the caller shows it at the gate. No assumptions section, no plan.

10. **Write** `documentation/specs/<slug>/S101-<slug>.md` from the template: the `design` block as passed (one kind, the other block dropped), the graph in the frontmatter, the body by id with the plan line naming the D101 or the ticket and its approval, Assumptions last, status `draft`. Create the folder if absent. Ids: `P0`, `P1..Pn`; `T001..` in file order, the number being the S102's NNN.

11. **Return the cut summary** (below), then the file path.

## Modes

- **new.** No S101 exists. Write the file; version `0.1`.
- **update** (the design source's items unchanged, content refined). Start from the S101 on disk; keep every task in `keep` as it is; re-cut only around them. Bump the version. A task not in `keep` may be re-cut freely; its old S102 is rewritten by the loop.
- **rewrite** (an id missing or added, or the content changed). Plan from the D101 alone, as `new`, and bump the version. The caller has deleted every old S102 before you are called; `keep` is empty.
- **finalise** (after the plan validation). Start from the S101 on disk and change only §6 Coverage map and §7 Assumptions, so both agree with the task specs as written: a trace a task gained or lost, an assumption a rewrite resolved. No re-cut, no change to the frontmatter, no version bump; `keep` is every task. Return the path and one line per cell you changed, no summary.
- **Any cut round after the first** (`cut_feedback` present, mode `new`, `update` or `rewrite`). Start from the S101 **on disk**, which may carry the author's hand edits, apply the feedback to it, rewrite in place with the same version, and return the summary again. Never read the previous summary as the graph.

## The cut summary

Returned as chat text, the same shape every run so a reader learns it once. Nothing about the plan that is not in the file.

```
The cut · S101-<slug>.md · draft v<version>

Phase P0 · Foundation
  checkpoint: <one line>
  task  title                      role             stack    owns     depends on  traces
  T001  <title>                    dotnet-builder   .NET     3 files  —           §6.1 §6.2
  T002  <title>                    angular-builder  Angular  2 files  —           §6.3

Phase P1 · <slice name> · AC1
  checkpoint: <one line>
  task  title                      role             stack    owns     depends on  traces
  T003  <title>                    dotnet-builder   .NET     2 files  T001        AC1 R1
  T004  <title>                    dotnet-tester    .NET     1 file   T001        AC1
  …

Assumptions · decided without a question
  A1 · <taken> (<default | decided by default | corrected at the cut>)
  …

<n> phases · <m> tasks · S101-<slug>.md written (draft) · no S102 yet
```

Stack is derived from the role. The `owns` count is the union of the three lists; a `create` + `modify` count above the threshold in definition §8.1 is marked `!` after it, never hidden. An assumption row that begins `design:` is printed as its own line under the assumptions, so the author sees the gap before saying go. The graph checks are not yours; asimov-spec runs artifact-s101-validation and prints them under the summary.

## Never

- **Write an S102**, or anything outside `documentation/specs/<slug>/`.
- **Set a status other than `draft`**, or touch an S101 at `ready` or later; return *refused* with the status and let the caller handle it.
- **Ask a question or wait for a go.** The questions were asked before you were called; a decision you lack an answer for takes its default and becomes an assumption.
- **Re-cut an S101 the author edited by hand.** asimov-spec reads that file as the graph and does not call you for it; if you are called with `cut_feedback` of the form *read again*, return *not mine* and do nothing.
- **Validate** the plan or an S102, or call any other skill. A skill is a leaf.
- **Delete** a file. The caller deletes.
- **Invent** a stack, a runner, a path or a signature the design source, the conventions or the repo do not give you. What you cannot ground becomes an assumption with its options, or, when it is a gap in the design no default can bridge, an assumption row whose *Taken* cell begins `design:`, so the author sees it at the gate.
- **Read the ticket anywhere but the cache**, or fix the cache. The caller fetched it and checked it against the bar; a defect in it is a `design:` row, and the author fixes the ticket.
- **Touch a task in `keep`**, or anything but §6 and §7 in `finalise`.
- **Bake a product entity into this skill.** The plan in a product repo names whatever it needs; this method names none.

## Used by

- asimov-spec, step 02, once per cut round; step 07, with a plan-level validation row as `cut_feedback` and every clearing task in `keep`; step 08, in mode `finalise`.
- A hand run without the asimov-skill: the summary you return is what the person reads before calling artifact-s102-authoring per task.
