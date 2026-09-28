---
artifact: s101-implementation-plan
maturity: assess
since: 2026-09-25
---

# Definition of S101

The written standard an S101 (implementation plan) must meet before any of its tasks is handed to a build subagent. An S101 turns one gap-free D101 into an ordered, dependency-aware set of S102 task specs, and states everything the run needs *once*: constraints, interfaces, checkpoints, escalation routing. It is the Spec stage's **planning** document; the S102 is its **task** document (`s102-task-spec-definition.md`).

Read by humans (the author, the reviewer who is not the author, the person directing the run) and by the planned `/s101-implementation-plan` and `/s101-review` commands at run-time. The orchestrator that dispatches S102s reads it as its control document.

Design: not yet written; the Spec stage's D101 is pending. Research: `documentation/research/S101-S102-spec-stage-research.md`.

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

**The verdict belongs to a reviewer who is not the author.** Coding does not start until the S101 is approved (the spec-before-code gate, D100 §3). The author runs `/s101-review` as a self-preview; the reviewer's approval is the gate. No command records the approval.

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
- **The D101's §7 Implementation is superseded for a feature that has an S101.** §7 was the interim home for file layout, reuse-vs-new and wiring (`d101-feature-design-definition.md` §4.8). That content is S102 content. A feature with an S101 marks §7 N/A and points at the specs folder.

## 4. Required content

### 4.1 Header

The D101 it plans (path and version), the goal in one sentence, the author, the date, the status (§6), and the execution mode the plan assumes (one builder at a time, subagent-driven with review per task, agent team). The mode is a default the run may override; the graph must be valid for the most parallel mode the plan allows.

### 4.2 Global constraints

Everything every S102 must respect, one line each, values verbatim from the D101 §6 or the conventions: version floors, forbidden dependencies, naming rules, performance budgets, the layers no task may bypass. Every S102 implicitly includes this section. A constraint that applies to one task alone belongs in that S102, not here.

### 4.3 The task graph

One entry per S102: its id, its title, the S102 file, the builder role it is written for (Giskard, Daneel, Calvin, or a human), the model tier the plan recommends, the tasks it depends on, the phase it belongs to, and the file set it owns. The graph is recorded **once**; the template decides where (frontmatter, so a validator reads it mechanically) and the body refers to tasks by id. Two copies drift.

Rules the graph must satisfy:

- **Acyclic.** A validator rejects a cycle.
- **Parallel means disjoint.** Two tasks may run together only if their owned file sets do not intersect and neither depends on the other, directly or transitively. A shared file is a dependency, and the plan says which task owns it.
- **Foundational first.** Work that every task needs (a migration, a shared type, a scaffold) is its own early task, and the tasks that need it depend on it. It is not folded into whichever task happens to run first.
- **Every task reachable, every task traced.** No orphan S102, and every S102 names the D101 requirement or acceptance criterion it serves.

### 4.4 Phases and checkpoints

Tasks are grouped into phases. Each phase ends in a **checkpoint**: a state a reviewer can verify without reading the code, ideally one of the D101's acceptance criteria met, or a named subset of the §6 contracts live. A phase is the unit a run can stop at cleanly, and the unit a revert targets. The D101's user-facing outcomes give the natural phase boundaries: setup, foundation, one phase per independently verifiable outcome, polish.

### 4.5 Interfaces

What each task **produces** that another task **consumes**: exact names and shapes, or the number of the D101 §6 contract that already states them. A builder sees only its own S102; this section is how neighbours agree on a name before either exists. An interface named in an S102 as consumed and named by no S102 as produced is a plan defect, not a builder's problem.

### 4.6 Review focus

The handful of inputs or failure modes the D101 implies but no task's tests exercise, most likely to bite first. One line each: the input or condition, and the behaviour a reasonable person expects. Each line is then pinned to the task that owns the code, as a test in that S102. An empty section means the check was run and found nothing, not that it was skipped.

### 4.7 Escalation routing

What a builder stops on, and who rules. A builder never resolves a conflict between its S102 and the D101, the conventions or another task by editing an artifact it does not own; it stops and reports (`s102-task-spec-definition.md` §5). The S101 says where the report goes and who decides: by default the person directing the run, optionally an orchestrator agent for defects below a named threshold. Every ruling is recorded in the ledger with what was decided, why, and what it costs if wrong. A stop that reaches a human is for the four cases only: an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, or a plan so broken that every path forward is a guess. Everything else gets a ruling and the run continues.

### 4.8 Coverage map

Every D101 requirement and acceptance criterion in scope, against the S102 ids that deliver it. It is the reviewer's first stop and the check that makes the S101 a plan for *this* D101 and not a plausible plan for a feature like it. A requirement with no task is a gap; a task with no requirement is scope the D101 never asked for.

## 5. Rules

- **Plan, don't build.** No code, no file-level steps, no test bodies in the S101. Those are the S102's. A plan that carries the recipe is one long task pretending to be a graph.
- **State it once.** Constraints, interfaces and review focus appear in the S101 and are referenced, not copied, by the S102s. A rule copied into six tasks is six chances to drift.
- **Link, don't duplicate.** D101 contracts by section number, conventions by path, existing code by path. Never a pasted schema, enum or column list.
- **Size to the D101, not to a length.** An S101 is as long as its graph. A feature that needs one task gets a one-task plan; that is not a reason to skip it, because the constraints and the escalation routing still have to be written down somewhere the builder reads.
- **Model tier is a recommendation, per task.** The tiers and their rule (a task whose S102 carries the code is transcription and takes the cheapest tier; a task written as prose takes a mid tier; a design or integration task takes the most capable) follow `documentation/model-choice.md`. The plan names a tier; the run may override it.
- **No product entity in the toolkit.** Product names, service names and ticket ids belong in the S101 in a product repo and never in this definition or the template (hard rule 7).

## 6. Lifecycle

One status axis, carried in the header: `draft` → `ready` (dispatch-ready, approved by the reviewer) → `in progress` (first task dispatched) → `done` (every checkpoint met) → `superseded` (the feature was re-planned; the new S101 names this one). The author moves `draft` → `ready` only after the reviewer's approval; the orchestrator moves `ready` → `in progress` → `done`; a human marks `superseded`. A `done` or `superseded` S101 stays in the repo as the record of how the feature was built; it is not deleted.

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

A validator, when built, is **hard on shape, soft on content**: it rejects a missing header field, a cycle, an orphan task, a broken link, an intersecting parallel pair; it does not judge whether the phases are sensible or the review focus is the right five. That is the reviewer's.

## 9. Placement and naming

An S101 lives in the product repo at `documentation/specs/<feature-slug>/S101-<feature-slug>.md`, beside its S102s (`S102-<feature-slug>-<NNN>-<task-slug>.md`). `<feature-slug>` is the D101's slug, so `documentation/features/D101-permissions.html` plans to `documentation/specs/permissions/S101-permissions.md`. Markdown body with YAML frontmatter, as every spec format in current use (research §2). The specs folder is a shared path convention in the sense of hard rule 7 and joins the lockstep set of hard rule 9 when the first command writes to it.
