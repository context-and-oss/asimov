---
name: artifact-s101-authoring
description: How to cut one design that meets contracts/design.md, a D101 at Full design or a normalised design cache, into one S101 implementation plan (documentation/specs/<slug>/S101-<slug>.md) — the plan part of a specification under contracts/specification.md: slices from the acceptance criteria, a Foundation phase 0 with the contracts as code and whatever every slice builds against, a tester task before the builder tasks in every slice, a close phase when the run needs one, the contracts stated once, the constraints the design imposes, the coverage map, the assumptions — and write it from the template. Use when asked to "cut this D101 into a plan", "write the S101 for this feature", "re-cut the plan with this correction", or inside asimov-spec at every cut round. Writes the S101 only; never an S102, never a question, never a validation, never the view (artifact-s101-view prints the plan).
---

# S101 authoring

The decomposition: one design in, one S101 draft out. This skill owns *what the plan says and how it is written*. It does not own the conversation (asimov-spec asks, shows the cut, waits for the go), it does not validate (artifact-s101-validation does), and it does not render the plan for a person (artifact-s101-view does). A skill is a leaf: it reads artifacts and calls no other skill.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1, 2 or 3 cannot be read either way, stop and report the path; never plan from a remembered bar.

1. **The S101 definition** — the bar (§2), how the S101 meets the specification contract (§3.2), the required content (§4, with §4.3 the graph rules, §4.4 the phases, §4.9 assumptions), the rules (§5), the lifecycle and the update-vs-rewrite rule (§6), the thresholds (§8.1):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

2. **The S101 template** — its leading comment holds the tree, the values and what never goes in the plan; its body is the shape you write:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

3. **The specification contract**, `${CLAUDE_PLUGIN_ROOT}/contracts/specification.md`: the plan members you provide and the rules that bind them, above all *names, not bodies*. **The design contract**, `${CLAUDE_PLUGIN_ROOT}/contracts/design.md`: the members you read a design through. The shape of a normalised design is the S101 definition §9.

4. **The design**, whole, through those members. A D101: §3 (R, NF, out of scope), §4.5 rules, §6 (the contracts, by number), §8 (the acceptance criteria), §9 (open questions that change the breakdown), as its definition §3.1 maps them; resolve the phase from its `.phase-chip`, and anything but `Full design` is not yours to plan — return *refused: not at Full design* and write nothing. A normalised design (`documentation/specs/<slug>/design.md`, written by asimov-spec): its sections, one per member of the contract; a cache missing a required member is not yours to plan — return *refused: design incomplete* naming the member, and write nothing.

5. **The repo's conventions**: `documentation/conventions/<stack>/README.md` for each stack the design touches, and every file the README lists (the Read tool does not expand `@`-imports). From them: the build and test commands a checkpoint names, the runner a slice test may use, and the layering a constraint may depart from. You do not copy them into the plan: the builder loads them.

6. **On an update or rewrite**, the existing `S101-<slug>.md` and the headers of every `S102-*.md` in the folder.

7. **The repo's `CLAUDE.md`**, if present, for layout you should respect and for escalation triggers the plan must honour.

## Inputs from the caller

asimov-spec passes these in its call; a hand run states them in the prompt. Missing inputs take the default in brackets.

| Input | Meaning |
|---|---|
| `design` | The S101 header's design line: `ref` (a repo path or a url), `version` or `read`, and `cache` when the design was normalised. Goes into the header as is; `ref` or `cache` is what you read. |
| `mode` | `new`, `update`, `rewrite` (definition §6) or `finalise` (below). asimov-spec decides it; a hand run with an existing S101 states it. [`new` when no S101 exists, else `update`] |
| `answers` | The author's answers to the questions asimov-spec asked, and any unanswered question with the default it took. [none] |
| `cut_feedback` | Free text the author wrote at the gate, or a validation row the caller routes to the plan. The same channel as `answers`; it overrides them where they conflict. [none] |
| `keep` | In any mode: task ids whose S102 is written and clears its bar. Their id, title, role, tier, `after` and traces do not change, and their S102 files stay byte-identical; the plan is re-cut around them. [none] |

## Steps

Work in this order; each step feeds the next.

1. **Slices.** One per acceptance criterion of the design a builder can make pass, end to end. A criterion verified by review or by hand (a document exists, a reviewer confirms a wording) maps to no slice; note it for the coverage map as *verified by review*. Two criteria share a slice only when `answers` or `cut_feedback` says so. Order the slices by dependency, then by the design's order.

2. **Stacks and roles.** Per slice, the stacks it touches, read from the D101 §6 contracts or the ticket's decision, and the conventions folders present. One tester task for the slice's acceptance test, then one builder task per stack (`dotnet-builder`, `angular-builder`, or `human` where no role skill fits). The tester role is the stack's tester where one exists; where none does (an Angular-only slice today), take the builder of that stack test-first and record the choice as an assumption.

3. **Contracts.** Every name one task produces and another consumes: class, method, parameters and return types, event, endpoint; the exact signature, or the design contract number that already states it. Existing code a task consumes is linked by path. This is §1 of the body, with *Produced by* and *Consumed by* naming task ids; the S102s copy the names from here and never the signatures. A design that does not settle a shape a slice needs is a `design:` assumption (step 10), never a guess.

4. **Phase 0, Foundation.** The contracts of step 3 as code: one task per stack, the classes, interfaces and public methods with summaries and no bodies, compiling; in Angular with minimal templates so a build proves it. With them, whatever every slice builds against and no slice should be the first to touch: a constructor parameter a slice's test fixture needs, a test project reference, a migration, a shared type. Never a slice's behaviour: a method body that makes a criterion pass belongs to that criterion's slice, however small. Cut the skeleton per slice, so that no two slice tasks that may run together will own the same skeleton file; where two slices need one type, the type is Foundation's and the slices consume it. Tier `low`.

5. **The close, when the run needs one.** A phase after the last slice for work that ends the run and belongs to no criterion: a release, a temporary reference put back, a flag flipped. Often a `human` task. It has a checkpoint like any phase; it is never squeezed into the last slice.

6. **Order.** `after` on every task: a slice's tester comes after the Foundation task(s) of its stack; a slice's builder comes after its tester; a task that consumes a name comes after the task that produces it; the close comes after the last slice's tasks. Acyclic. Two tasks with no path between them may run together; you do not own files here, so where you can already see that two such tasks will touch one file (the same service class, the same registration), make one come after the other now and say so in an assumption. The S102 authoring fixes the owned sets and the full validation checks the pairs.

7. **Checkpoints.** One per phase, a state a reviewer verifies without reading code: the Foundation's build command, green; a slice's acceptance test class by name, green; the close's command and result. Named from the conventions, never invented.

8. **Once.** The constraints the design imposes on every task (D101 §6 values, the ticket's decision and rules) and every place the plan departs from the conventions, verbatim with the source; never a convention restated. The review focus (the failure modes no task's check exercises, each pinned to a task). The escalation routing (who rules, from `answers` or the default: the person directing the run; the stops specific to this plan, including the ones the repo's `CLAUDE.md` names).

9. **Coverage map, both ways.** Every id of the design in scope (a D101's R, NF, §6.x.y and AC; a normalised design's R, NF and AC) against task ids; every task against what it serves (its `traces`). An id no task serves carries its reason: *verified by review*, or *out of scope here, per OOSn* when the design assigns it elsewhere. For a normalised design, every row carries the source's wording in the *Says* column, one line; for a D101 the column may read —. A requirement with no task and no reason is a gap you fix now by adding or widening a task; a task with no requirement is scope you drop.

10. **Tiers and assumptions.** `low` where the task is fully determined by the names, the signatures and the check (the Foundation, a one-line read, a registration), `mid` for behaviour in prose with a clear check, `high` for judgement or integration; no tier means the S102 carries code. Then every decision about the feature taken without a question, in the order taken: the question it would have been, the options, the default taken; *How* is `default`, `decided by default` (the budget was spent) or `corrected at the cut` (what `cut_feedback` changed). A gap no default can bridge gets a row whose *Taken* cell begins `design:` and names what the design is missing; the caller shows it at the gate. A place where you had to work around a rule of the template or a check is **not** an assumption: return it as a template finding (below) for the sidecar. No assumptions section, no plan.

11. **Write** `documentation/specs/<slug>/S101-<slug>.md` from the template: the `design` line as passed (one line, the template's other one dropped), the tree in the frontmatter with one task per line, the body in the template's six sections, the first paragraph naming the design and its approval, status `draft`, and `approved: none` on a new file (an `approved:` line already on disk is kept byte-identical; the caller owns it). Create the folder if absent. Ids: `P0`, `P1..Pn`; `T001..` in order of appearance, the number being the S102's NNN. No prose that retells the tree; no code; signatures in §1 only.

12. **Return** the path, one line `<n> phases · <m> tasks · S101-<slug>.md written (draft v<version>)`, and the template findings if any, one line each under `template findings:`. The view of the plan is the caller's to print (artifact-s101-view); the graph checks are the caller's to run (artifact-s101-validation).

## Modes

- **new.** No S101 exists. Write the file; version `0.1`.
- **update** (the design's items unchanged, content refined). Start from the S101 on disk; keep every task in `keep` as it is; re-cut only around them. Bump the version. A task not in `keep` may be re-cut freely; its old S102 is rewritten by the loop.
- **rewrite** (an id missing or added, or the content changed). Plan from the design alone, as `new`, and bump the version. The caller has deleted every old S102 before you are called; `keep` is empty.
- **finalise** (after the plan validation). Start from the S101 on disk and change only §1 Contracts, §3 Coverage and §6 Assumptions, so they agree with the task specs as written: a consumer a task gained, a trace a task gained or lost, an assumption a rewrite resolved. No re-cut, no change to the tree, no version bump; `keep` is every task. Return the path, one summary line of what changed (`finalise: §1 +2 rows · §3 1 row changed · §6 +1`, or `finalise: nothing changed`), then one line per cell; the caller shows the summary to the author when the change calls for a new approval.
- **Any cut round after the first** (`cut_feedback` present, mode `new`, `update` or `rewrite`). Start from the S101 **on disk**, which may carry the author's hand edits, apply the feedback to it, rewrite in place with the same version, and return again.

## Never

- **Write an S102**, or anything outside `documentation/specs/<slug>/`.
- **Write code, a step or a test body** anywhere in the plan, or a signature outside §1. The plan is names and order.
- **Copy a convention** into §2. The builder loads them; the plan names what the design imposes and where it departs.
- **Put a slice's behaviour in the Foundation**, or a builder beside or ahead of its tester.
- **Set a status other than `draft`, or write, change or drop the `approved:` line**; the caller does both on the author's word. Never touch an S101 at `ready` or later; return *refused* with the status and let the caller handle it.
- **Ask a question or wait for a go.** The questions were asked before you were called; a decision you lack an answer for takes its default and becomes an assumption.
- **Re-cut an S101 the author edited by hand.** asimov-spec reads that file as the graph and does not call you for it; if you are called with `cut_feedback` of the form *read again*, return *not mine* and do nothing.
- **Validate** the plan or an S102, **render** it for a person, or call any other skill. A skill is a leaf.
- **Delete** a file. The caller deletes.
- **Invent** a stack, a runner, a path or a signature the design, the conventions or the repo do not give you. What you cannot ground becomes an assumption with its options, or, when it is a gap in the design no default can bridge, an assumption row whose *Taken* cell begins `design:`.
- **Read the ticket anywhere but the cache**, or fix the cache. The caller fetched it and checked it against the bar; a defect in it is a `design:` row, and the author fixes the ticket.
- **Touch a task in `keep`**, or anything but §1, §3 and §6 in `finalise`.
- **Bake a product entity into this skill.** The plan in a product repo names whatever it needs; this method names none.

## Used by

- asimov-spec, step 02, once per cut round; step 07, with a plan-level validation row as `cut_feedback` and every clearing task in `keep`; step 08, in mode `finalise`.
- A hand run without the asimov-skill: print the plan with artifact-s101-view before calling artifact-s102-authoring per task.
