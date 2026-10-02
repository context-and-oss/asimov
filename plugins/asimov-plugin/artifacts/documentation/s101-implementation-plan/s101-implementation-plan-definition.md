---
artifact: s101-implementation-plan
maturity: assess
since: 2026-09-25
---

# Definition of S101

The written standard an S101 (implementation plan) must meet before any of its tasks is handed to a build subagent. An S101 turns one gap-free D101 into an ordered, dependency-aware set of S102 task specs, and states everything the run needs *once*: constraints, interfaces, checkpoints, escalation routing. It is the Spec stage's **planning** document; the S102 is its **task** document (`s102-task-spec-definition.md`).

Read by humans (the author, the reviewer who is not the author, the person directing the run) and at run-time by the asimov-skills `asimov-spec` and `asimov-spec-validate` through the artifact skills `artifact-s101-authoring` and `artifact-s101-validation`. The orchestrator that dispatches S102s reads it as its control document.

Design: `documentation/features/D101-spec-stage.html`. Research: `documentation/research/S101-S102-spec-stage-research.md`.

---

## 1. What an S101 is for

At L3 the agent builds from a written spec and the human directs and reviews. One D101 rarely fits one agent sitting; it becomes several tasks, and *someone* has to decide their order, what may run in parallel, what each hands to the next, and what a finished phase looks like. That is the S101's job. Without it those decisions are made in chat, invisibly, per run.

An S101 answers four questions:

- **Which tasks, in which order?** The task graph: every S102, its dependencies, its phase.
- **What may run at the same time?** Tasks with disjoint file sets and no open blockers.
- **What does each task rely on from the others?** The interfaces, stated once, so a builder that sees only its own task knows the names and shapes its neighbours use.
- **What must hold everywhere?** Global constraints and the review focus, stated once instead of copied into every task.

It is the reviewable, D101-traceable *source* for whatever runtime task list executes it (a subagent loop, an agent team, a person working through it by hand). The runtime list is disposable; the S101 is the record of what was planned.

## 2. The bar: dispatch-ready

An S101 clears one bar. **Dispatch-ready** means the person or orchestrator running it can dispatch every S102 to a fresh builder, in graph order, without going back to the author. Concretely:

- every S102 the graph names exists and clears its own bar (§2 of `s102-task-spec-definition.md`);
- every D101 requirement and acceptance criterion in scope is covered by at least one S102, and every S102 traces to at least one;
- the graph has no cycle, and every task marked parallel owns a file set disjoint from every other task it can run beside;
- every phase ends in a checkpoint a reviewer can verify without reading the code;
- the interfaces every consumer relies on are named by a producer;
- the escalation routing names who rules when a builder stops.

**The verdict belongs to a reviewer who is not the author.** Coding does not start until the S101 is approved (the spec-before-code gate, D100 §3). The author runs `asimov-spec-validate` as a self-preview; the reviewer's approval is the gate. No skill records the approval.

Two words for two checks. **Validation** is the spec check *before* code: does the S101 clear this bar, does every S102 clear its own, and do they agree with each other (§8, `s102-task-spec-definition.md` §8). **Verification** is the code check *after* build: run the acceptance criteria an S102 names against what was built. This definition covers validation; verification belongs to the Build workflow.

The author sees the plan twice before the reviewer does. Once as the **cut**: the S101 alone, no S102 beside it, shown by `asimov-spec` before any task spec is written; the author says *go*, corrects it, or stops. That go is the author's call that the cut holds, recorded nowhere, and not an approval. Once more at the end, when every S102 exists and the plan has been validated as a whole. The reviewer's verdict comes after both.

## 3. Relationship to other documents

| Doc | Stage | What it answers |
|---|---|---|
| **D101** | Design | What feature, what scope, what rules, what verifiable outcomes; the contracts (§6) |
| **S101** | Spec | In what order and by whom the feature is built; what every task must respect |
| **S102** | Spec | Exactly how one task is built; what a builder receives |
| Conventions | Cross-cutting | How code is written generally; the S101 links, never copies |
| Runtime task list / ledger | Execution | Which task is claimed, done, in a fix round; **never part of the S101** |

- **One D101 at `Full design` produces exactly one S101.** A D101 at `Business design` produces none; §6 is open and no task can be cut.
- **One S101 produces one or more S102s.** Three to eight is typical for a feature; one is legitimate for a small change. A lone bug fix from the board skips the D101 and the S101 and gets a single S102 (`s102-task-spec-definition.md` §3).
- **The S101 owns the graph; the S102 owns the recipe.** File paths, signatures, steps and test code live in the S102. The S101 names the task and its edges, and never repeats its body.
- **The S101 is not the ledger.** Run state (claimed, in progress, fix round, done) lives in a gitignored ledger the orchestrator keeps, as `/d101-review`'s `.review.md` cache does for reviews. Writing state into the plan makes every run a diff on a reviewed document.
- **The S101 is not the validation report either.** A run's findings and the assumptions it decided by default land in a gitignored sidecar beside the plan (§9); the assumptions themselves are plan content (§4.9), the findings are not.
- **The D101's §7 Implementation is superseded for a feature that has an S101.** §7 was the interim home for file layout, reuse-vs-new and wiring (`d101-feature-design-definition.md` §4.8). That content is S102 content. A feature with an S101 marks §7 N/A and points at the specs folder.

## 4. Required content

### 4.1 Header

The D101 it plans (path and version), the goal in one sentence, the author, the date, the status (§6), and the execution mode the plan assumes (one builder at a time, subagent-driven with review per task, agent team). The mode is a default the run may override; the graph must be valid for the most parallel mode the plan allows.

### 4.2 Global constraints

Everything every S102 must respect, one line each, values verbatim from the D101 §6 or the conventions: version floors, forbidden dependencies, naming rules, performance budgets, the layers no task may bypass. Every S102 implicitly includes this section. A constraint that applies to one task alone belongs in that S102, not here.

### 4.3 The task graph

One entry per S102: its id, its title, the S102 file, the builder role it is written for (exactly one of the roles the S101 template's leading comment lists: a `role-*` skill such as `dotnet-builder`, `angular-builder` or `dotnet-tester`, or `human`), the model tier the plan recommends, the phase it belongs to, the tasks it depends on, the files it owns in three lists (create, modify, test), the names it produces, the names it consumes, and the D101 ids it traces to. The graph is recorded **once**, in the frontmatter so validation reads it mechanically, and the body refers to tasks by id. Two copies drift.

Rules the graph must satisfy:

- **Acyclic.** Validation rejects a cycle.
- **Parallel means disjoint.** Two tasks may run together only if their owned file sets do not intersect and neither depends on the other, directly or transitively. A shared file is a dependency, and the plan says which task owns it. Two slices that need the same skeleton file get the skeleton cut so each owns its own, decided at planning time.
- **Foundation first.** The skeleton every slice builds against is phase 0 (§4.4), and every slice task depends on it. Any other work every task needs (a migration, a shared type) joins it; it is never folded into whichever task happens to run first.
- **Every task reachable, every task traced.** No orphan S102, and every S102 names the D101 requirement or acceptance criterion it serves.

### 4.4 Phases and checkpoints

A phase is a **slice**, or the Foundation. A slice is the work that makes one D101 acceptance criterion pass, end to end; the plan has one phase per acceptance criterion a builder can make pass, and a criterion verified by review or by hand maps to no phase and is marked so in the coverage map. Two criteria share a phase only when the author says so.

- **Phase 0, Foundation.** The skeleton: classes, interfaces and public methods with summaries and no bodies, compiling, one S102 per stack. It is the interfaces of §4.5 as code, cut per slice so no two parallel slices own the same skeleton file. Its checkpoint: the solution builds and a reviewer can read the shape before any logic exists.
- **Phases 1..n, one per slice.** One builder S102 per stack the slice touches, plus one tester S102 that writes the slice's acceptance test. That test is the phase's **checkpoint**: green, written at API level against the skeleton's public methods, end to end only where the repo's conventions name a runner. It compiles against the skeleton before any slice body exists, fails red, and the builder S102s make it pass.

A checkpoint is a state a reviewer can verify without reading the code. A phase is the unit a run can stop at cleanly, and the unit a revert targets. A shared type two slices need is not a slice; it goes to the Foundation.

### 4.5 Interfaces

What each task **produces** that another task **consumes**: exact names and shapes, or the number of the D101 §6 contract that already states them. A builder sees only its own S102; this section is how neighbours agree on a name before either exists. An interface named in an S102 as consumed and named by no S102 as produced is a plan defect, not a builder's problem.

### 4.6 Review focus

The handful of inputs or failure modes the D101 implies but no task's tests exercise, most likely to bite first. One line each: the input or condition, and the behaviour a reasonable person expects. Each line is then pinned to the task that owns the code, as a test in that S102. An empty section means the check was run and found nothing, not that it was skipped.

### 4.7 Escalation routing

What a builder stops on, and who rules. A builder never resolves a conflict between its S102 and the D101, the conventions or another task by editing an artifact it does not own; it stops and reports (`s102-task-spec-definition.md` §5). The S101 says where the report goes and who decides: by default the person directing the run, optionally an orchestrator agent for defects below a named threshold. Every ruling is recorded in the ledger with what was decided, why, and what it costs if wrong. A stop that reaches a human is for the four cases only: an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, or a plan so broken that every path forward is a guess. Everything else gets a ruling and the run continues.

### 4.8 Coverage map

Every D101 requirement and acceptance criterion in scope, against the S102 ids that deliver it. It is the reviewer's first stop and the check that makes the S101 a plan for *this* D101 and not a plausible plan for a feature like it. A requirement with no task is a gap; a task with no requirement is scope the D101 never asked for. A criterion verified by review or by hand is listed with *verified by review* in place of task ids, so the gap check does not fire on it. The ids this map traces are also what a re-run compares against the D101 to decide between an update and a rewrite (§6).

### 4.9 Assumptions

Every decision the plan took without asking the author: the question it would have been, the options, the default taken, and *decided by default* where the question budget was spent before it came up. Written last in the body, in the order taken. The author's corrections at the cut join the list, so the reviewer sees what was decided and what was corrected in one place. A plan with an empty Assumptions section claims the author answered everything; a plan with none hides its guesses.

## 5. Rules

- **Plan, don't build.** No code, no file-level steps, no test bodies in the S101. Those are the S102's. A plan that carries the recipe is one long task pretending to be a graph.
- **State it once.** Constraints, interfaces and review focus appear in the S101 and are referenced, not copied, by the S102s. A rule copied into six tasks is six chances to drift.
- **Link, don't duplicate.** D101 contracts by section number, conventions by path, existing code by path. Never a pasted schema, enum or column list.
- **Size to the D101, not to a length.** An S101 is as long as its graph. A feature that needs one task gets a one-task plan; that is not a reason to skip it, because the constraints and the escalation routing still have to be written down somewhere the builder reads.
- **Model tier is a recommendation, per task.** Three tiers, named in the template: `low` for a task whose S102 carries the code (transcription: the skeleton, a mechanical change), `mid` for prose steps with a clear check, `high` for judgement or integration. The plan names a tier only; which model a tier means is the toolkit's call (`model-choice.md` in the Asimov repo), and the run may override it. A product repo never needs that file to validate a plan.
- **No product entity in the toolkit.** Product names, service names and ticket ids belong in the S101 in a product repo and never in this definition or the template (hard rule 7).

## 6. Lifecycle

One status axis, carried in the header: `draft` → `ready` (dispatch-ready, approved by the reviewer) → `in progress` (first task dispatched) → `done` (every checkpoint met). `asimov-spec` writes and rewrites `draft` and sets nothing else; the author moves `draft` → `ready` only after the reviewer's approval; the Build workflow moves `ready` → `in progress` → `done`. A `done` S101 stays in the repo as the record of how the feature was built; it is not deleted.

The cut is a `draft` S101 with no S102 beside it. No status value marks it; the folder does.

A re-run against a D101 that already has an S101 takes one of two paths. **Update in place** when the D101's requirement and acceptance-criterion ids are the ones the coverage map traces and the author confirms the content is refined, not changed: same file, version bumped, and every S102 that still clears its bar left byte-identical. **Rewrite** when an id is missing or added, or the author says the content changed: the S101 and every S102 written anew, S102 files no longer in the graph deleted. There is no `superseded` status and no kept copy; git carries the previous plan. An S101 at `ready` or later is never rewritten by a skill; the author sets it back to `draft` first.

## 7. Anti-patterns

- **The graph in chat.** Order and parallelism decided in the run prompt and never written down. The next run re-decides them.
- **One long task.** A single S102 that is the whole feature. That is L2 with a file attached; the plan exists to cut it.
- **Parallel by hope.** Two tasks marked parallel that both touch the same file. The second one to finish overwrites the first.
- **Interfaces by guess.** A consumer that names a method no producer defines. The builder invents one, and the neighbour invents a different one.
- **State in the plan.** Checkboxes ticked, `passes: true` flipped, fix rounds noted inside the S101. The reviewed document and the run log become one file.
- **Recipe in the plan.** Test bodies and step lists in the S101. The plan becomes the task and the S102s become stubs.
- **Silent scope.** A task with no D101 requirement behind it. Either the D101 is missing a requirement or the task is not this feature.

## 8. The checks

One canonical list. Every check is asked of the S101 alone, with the D101 and the S102s open beside it. The verdict is the reviewer's (§2).

| # | Check | Tests |
|---|---|---|
| 1 | Does every S102 the graph names exist and clear its own bar? | Completeness |
| 2 | Does every D101 requirement and acceptance criterion in scope map to at least one S102, and every S102 to at least one requirement? | Coverage, both ways |
| 3 | Is the graph acyclic, and does every task marked parallel own a file set disjoint from every task it can run beside? | Graph validity |
| 4 | Does every phase end in a checkpoint a reviewer can verify without reading code? | Stoppable phases |
| 5 | Is every interface an S102 consumes named by an S102 that produces it, or by a D101 §6 contract? | Interface closure |
| 6 | Are the global constraints stated once, with values verbatim from the D101 or conventions, and does no S102 contradict them? | Constraint consistency |
| 7 | Does the review focus name the uncovered failure modes, and is each pinned to a task? | Review focus |
| 8 | Does the escalation routing name what stops a builder and who rules? | Escalation |
| 9 | Is the S101 free of recipe (code, steps, test bodies) and free of run state? | Separation |
| 10 | Is every model tier a recommendation consistent with `model-choice.md`? | Model choice |

Validation (`artifact-s101-validation`) is **hard on shape, soft on content**: it fails a missing header field, a cycle, an orphan task, a broken link, an intersecting parallel pair, a consumed name with no producer; it does not judge whether the phases are sensible or the review focus is the right five. That is the reviewer's. It runs in two modes: **graph-only** on the S101 alone, at the cut, where a check that needs the S102s is reported as *not yet*, never as Pass; and **full** once every S102 exists. The shape checks are answered against a fixed, numbered checklist so two runs on an unchanged plan agree; a script replaces the checklist only if they do not.

### 8.1 Size thresholds

Validation warns, never fails, when an S102 exceeds a threshold; the plan is still written. The numbers live here, not in a skill, so they move with the evidence (research §8) and not with a release. Both validation skills read them.

```yaml
thresholds:                      # per S102; above the number → Warn
  owned_non_test_files: 3        # create + modify, tests excluded; success falls sharply from 3, to nil at 7
  scenarios: 3                   # behaviour scenarios; more is usually two tasks
  steps: 12                      # one action each; more is usually two tasks
```

A cycle, an orphan or an intersecting parallel pair is shape and fails; size only warns.

## 9. Placement and naming

An S101 lives in the product repo at `documentation/specs/<feature-slug>/S101-<feature-slug>.md`, beside its S102s (`S102-<feature-slug>-<NNN>-<task-slug>.md`). `<feature-slug>` is the D101's slug, so `documentation/features/D101-permissions.html` plans to `documentation/specs/permissions/S101-permissions.md`. Markdown body with YAML frontmatter, as every spec format in current use (research §2).

Beside the plan, both asimov-skills write one gitignored sidecar, `S101-<feature-slug>.review.md`. Overwritten by the next run, read by no skill, never a record; the same role as `/d101-review`'s `D101-<slug>.review.md`. One shape, so a reader learns it once:

```markdown
# Validation — S101-<feature-slug>

S101: documentation/specs/<feature-slug>/S101-<feature-slug>.md v<version>
D101: documentation/features/D101-<feature-slug>.html v<version, from its status chip>
Date: <YYYY-MM-DD>
Mode: graph-only | full
Blind: true | false

## Plan report
<the S101 validation report, verbatim>

## Task reports
### <task id> · <S102 file>
<its last S102 validation report, verbatim; one block per S102 in file order>

## Assumptions decided by default
<the rows of S101 §7 whose How is "decided by default", verbatim; "none" if none>
```

`Blind` is false when any S102 report was produced inline rather than in a fresh subagent.

The specs folder is a shared path convention in the sense of hard rule 7 and a lockstep literal in the sense of hard rule 9: both asimov-skills, both authoring skills, `.gitignore`, `CLAUDE.md` and D100 §9 move together.
