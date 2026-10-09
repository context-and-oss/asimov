---
artifact: s101-implementation-plan
maturity: assess
since: 2026-09-25
---

# Definition of S101

The written standard an S101 (implementation plan) must meet before any of its tasks is handed to a build subagent. An S101 turns one **design**, a D101 at `Full design` or a ticket that meets the bar in §3.1, into an ordered, dependency-aware set of S102 task specs, and states everything the run needs *once*: contracts, constraints, coverage, escalation routing. It is the **plan** part of a specification as `contracts/specification.md` defines it; the S102 is the **task** part (`s102-task-spec-definition.md`).

Read by agents: `asimov-spec` through the artifact skills `artifact-s101-authoring` and `artifact-s101-validation`, and the orchestrator that dispatches S102s, which reads it as its control document. A person sees the plan through the view those asimov-skills print (the cut, the end of a run, the reviewer's read); the file itself is written for the agents and kept exact and short.

Design: `documentation/features/D101-spec-stage.html`. Research: `documentation/research/S101-S102-spec-stage-research.md`, `documentation/research/specification-contract-research.md`.

---

## 1. What an S101 is for

At L3 the agent builds from a written spec and the human directs and reviews. One design rarely fits one agent sitting; it becomes several tasks, and *someone* has to decide their order, what may run in parallel, what each hands to the next, and what a finished phase looks like. That is the S101's job. Without it those decisions are made in chat, invisibly, per run.

An S101 answers four questions:

- **Which tasks, in which order?** The task graph: every S102, its dependencies, its phase.
- **What may run at the same time?** Tasks with disjoint file sets and no open blockers.
- **What does each task rely on from the others?** The contracts, stated once, so a builder that sees only its own task knows the names and shapes its neighbours use.
- **What must hold everywhere?** The constraints the design imposes and the review focus, stated once instead of copied into every task.

It is the reviewable, design-traceable *source* for whatever runtime task list executes it. The runtime list is disposable; the S101 is the record of what was planned.

## 2. The bar: dispatch-ready

An S101 clears one bar. **Dispatch-ready** means the person or orchestrator running it can dispatch every S102 to a fresh builder, in graph order, without going back to the author. Concretely:

- the S101 provides every plan member of `contracts/specification.md` (§3.2), and every S102 the graph names exists and clears its own bar (`s102-task-spec-definition.md` §2);
- every requirement and acceptance criterion of the design in scope is covered by at least one S102, and every S102 traces to at least one;
- the graph has no cycle, every slice's builder task comes after its tester task, and every task that may run beside another owns a file set disjoint from it;
- every phase ends in a checkpoint a person can read in one sentence, with a check a reviewer can run without reading the code;
- every name an S102 consumes is produced by an S102 and stated in §1, or exists in the repo at the path the S102 links;
- the escalation routing names who rules when a builder stops.

**The plan is approved by its author; a task spec by the agent that checks it.** Coding does not start until the S101 is `ready` (the spec-before-code gate, D100 §3). The author's *go* at the cut is the approval: `asimov-spec` writes it into the header with the author, the date and a fingerprint of the plan (§6), and sets `ready` once every S102 is validated and the fingerprint still matches. A plan changed after the go is shown again and approved again. No skill approves a plan on its own; no person is asked to approve a task spec; nobody sets a status by hand.

Two words for two checks. **Validation** is the spec check *before* code: does the S101 clear this bar, does every S102 clear its own, and do they agree with each other (§8, `s102-task-spec-definition.md` §8). **Verification** is the code check *after* build: run the done-when of each S102 against what was built. This definition covers validation; verification belongs to the Build workflow.

The author sees the plan twice. Once as the **cut**: the S101 alone, no S102 beside it, checked and then shown by `asimov-spec` before any task spec is written; the author says *go*, corrects it, or stops. That go is the approval. Once more at the end, when every S102 exists and the plan has been validated as a whole: `ready` when the plan on disk is the one approved, or what changed and the question to approve again when it is not. The author reads the plan as the view `artifact-s101-view` prints and the findings as one line each; a raw report never reaches a person.

## 3. Relationship to other documents

| Doc | Stage | What it answers |
|---|---|---|
| **D101** | Design | What feature, what scope, what rules, what verifiable outcomes; the contracts (§6) |
| **Any other design** | Design | A ticket thread or a page that meets `contracts/design.md` (§3.1): the whole design of a bug fix or a small change that needs no D101. Its tool stays its record |
| **`contracts/specification.md`** | Spec → Build | What a specification must contain, plan and task members, and the line between what the spec fixes and what the builder decides (§3.2) |
| **S101** | Spec | In what order and by whom the feature is built; what every task must respect |
| **S102** | Spec | Exactly what one task delivers and how done is observed; what a builder receives |
| Conventions | Cross-cutting | How code is written generally; the builder loads them, the S101 names only departures |
| Runtime task list / ledger | Execution | Which task is claimed, done, in a fix round; **never part of the S101** |

- **One design produces exactly one S101.** A D101 at `Full design`, or any other design that meets the contract (§3.1). A D101 at `Business design` produces none; §6 is open and no task can be cut. A design missing a member of the contract produces none either; what is missing is added to the design, never to a copy.
- **One S101 produces one or more S102s.** Three to eight is typical for a feature. Two is the floor for a change a builder can make pass: the slice's tester, then its builder. One is legitimate where the stack has no tester role and the builder works test-first. A bug fix from the board skips the D101, not the S101, and skips the Foundation too when it has nothing to found (§4.4): its ticket is the design, and the plan is one slice. There is no S102 without a plan.
- **The S101 owns the graph; the S102 owns the task.** Order, phases, checkpoints and the names between tasks live here. Files, behaviour, done-when and the task's own constraints live in the S102. Neither repeats the other.
- **The S101 is not the ledger.** Run state lives in a gitignored ledger the orchestrator keeps. Writing state into the plan makes every run a diff on a reviewed document.
- **The S101 is not the validation report either.** A run's findings and the assumptions it decided by default land in a gitignored sidecar beside the plan (§9); the assumptions themselves are plan content (§4.9), the findings are not.
- **The D101's §7 Implementation is superseded for a feature that has an S101.** That content is S102 content. A feature with an S101 marks §7 N/A and points at the specs folder.

### 3.1 The bar on the design

What a design must contain for a plan to be cut from it is the contract `contracts/design.md` in the plugin; the S101 reads a design only through its members. A D101 meets the contract at `Full design`, and its definition §3.1 says which section provides which member. A design that is not a file in the repo (a ticket thread, a page elsewhere) is normalised by `asimov-spec` into `documentation/specs/<feature-slug>/design.md`, in the shape §9 fixes, with ids assigned once in reading order; on a re-run the ids the plan's coverage map already holds are kept and a new item takes the next free number (the contract's rule). The coverage map (§4.8) then carries each id with the source's wording, so the plan stands with only the link beside it. A design that misses a required member is refused with what is missing; the fix goes into the design, never into a copy.

### 3.2 How the S101 meets `contracts/specification.md`

The contract's plan members, and where the S101 provides each. The task members are the S102's (`s102-task-spec-definition.md` §3.2).

| Contract member | Provided by |
|---|---|
| Reference | the `design` line of the header, and the first line of the body |
| Order | the `phases` tree: tasks under phases in build order, `after` on every task, `checkpoint` and `check` on every phase |
| Coverage | §3 Coverage |
| Escalation | §4 Escalation |
| Contracts | §1 Contracts; the graph names none, an S102 names them and never restates them |
| Constraints | §2 Constraints |
| Assumptions | §6 Assumptions |
| Review focus (optional) | §5 Review focus |
| Tier (optional, a task member) | `tier` on every task in the tree, copied into the S102 header |

The contract's rules bind the plan as they bind the tasks: *names, not bodies* (no code anywhere in an S101, and signatures only in §1), *the check is described, not written* (a checkpoint is one sentence a person reads; the command that proves it is the phase's `check`, a name the verifier runs, never a body), *state it once*, *link, don't copy*, *traceable both ways*, *complete, or not a specification*.

## 4. Required content

### 4.1 Header

The design it plans, by reference: a repo path and version for a D101, or a url and read time plus the path of the normalised cache (§3.1) and whether its approval was **verified** (read in the source by the skill) or **unverified** (the design reached the skill as pasted text, so nobody checked who approved it or when); the goal in one sentence, the author, the date, the status and the approval (§6). The graph must be valid for the most parallel execution the tree allows: two tasks with no path between them may be built at once.

### 4.2 Constraints

What the design imposes on every task, and where the plan departs from the conventions: one short line each, the value verbatim from the design (D101 §6, or the decision and rules of a normalised design) or the convention departed from, with the source, and nothing explanatory, because the author reads these lines in the plan view and approves them with the go. The conventions themselves are not repeated, and neither is a rule of the repo's `CLAUDE.md` or `AGENTS.md`: the builder loads both with its role (D100 §7.2.1), and a plan that copies them is six chances to drift and one more thing for a reviewer to read. A §2 line whose source is a convention file or the repo's instructions is a *departure* from it, or it does not belong here. Every S102 implicitly includes this section. A constraint that applies to one task alone belongs in that S102, not here.

### 4.3 The task graph

A tree in the frontmatter: every phase in build order, and under each phase its tasks. A task is one line: its id, its title, the builder role it is written for (exactly one of the roles the template's leading comment lists: a `role-*` skill such as `dotnet-builder`, `angular-builder` or `dotnet-tester`, or `human`), the model tier the plan recommends, the tasks it comes after, and the design ids it traces to. The title is a short name, three to seven words, because the view is read at a glance and the title is the task's file slug; what the task covers in full is the S102's intent. The task's S102 file is `S102-<feature-slug>-<NNN>-<task-slug>.md`, NNN the task's number and the slug three to five words of the title, found by the number's glob.

The graph is recorded **once** and carries only what orders the work. The files a task owns, the names it produces and the names it consumes are task members: they live in the S102 header (`s102-task-spec-definition.md` §4.1, §4.3, §4.4), and validation reads disjointness and interface closure from the S102 headers and §1 Contracts. The body refers to tasks and phases by id and never narrates the graph.

Rules the graph must satisfy:

- **Acyclic.** Validation rejects a cycle.
- **Parallel means disjoint.** Two tasks run together only if neither comes after the other, directly or transitively, and their hand-edited file sets (`create`, `modify`, `test` from their S102 headers; a path or a glob such as `src/Services/Export/**`) do not intersect. A shared file is a dependency, and the plan says which task owns it. An intersection between two tasks with no path between them is a **Flag**, not a defect that re-cuts the plan: the Build stage picks its batches by disjointness and serialises the pair, so what is lost is parallelism, and the author sees the pair in the view's findings. A file both tasks `regenerate` (a lock file, a generated client) is not a shared file: the regenerating command is idempotent over the hand-edited files, so both may run it (`s102-task-spec-definition.md` §4.1). Two slices that need the same skeleton file get the skeleton cut so each owns its own, decided at planning time.
- **Foundation first, when there is one.** A plan has a Foundation when §1 holds a name that two tasks with no path between them both depend on, or when something every slice builds against must land before any slice (§4.4). Then every slice task comes after a Foundation task, and nothing every slice needs is folded into whichever task happens to run first. A plan with nothing to found has no Foundation: its first phase is a slice, and no phase is named one to satisfy the shape.
- **Tester before builder.** In a slice, the builder task comes after the tester task, so the slice's test exists and is red before any body is written. The tester task comes after the Foundation, where there is one, and after nothing else, with one exception: a slice that extends a file an earlier slice owns (the same service class, the same test class) comes after that slice's builder, and §6 names the file. Sequencing two slices is a decision the plan records; overlapping their files is a defect.
- **Every task reachable, every task traced.** No orphan S102, and every S102 names the design requirement or acceptance criterion it serves.

### 4.4 Phases and checkpoints

A phase is the **Foundation**, a **slice**, or the **close**. The slices are always there; the Foundation and the close exist when the run needs them. A slice is the work that makes one design acceptance criterion pass, end to end; the plan has one phase per acceptance criterion a builder can make pass, and a criterion verified by review or by hand maps to no phase, is marked so in the coverage map, and holds `done` back until a reviewer has signed it (§6). Two criteria share a phase when the author says so, or when one test class and one builder pass would make both pass in the same files; the plan then records the choice in §6, and nobody is asked to split what one tester and one builder deliver together.

- **Phase 0, Foundation, when the plan needs one.** It does when §1 holds a name that two tasks with no path between them both depend on (a skeleton both compile against), or when something every slice builds against must land before any slice. Then: the contracts of §1 as code, classes, interfaces and public methods with summaries and no bodies, compiling, one S102 per stack, cut per slice so no two parallel slices own the same skeleton file. With them, whatever every slice builds against and no slice should be the first to touch: a constructor parameter, a project reference, a migration, a shared type. Never a slice's behaviour: a method with a body that makes an acceptance criterion pass belongs to that criterion's slice, however small. Its checkpoint: the solution builds and a reviewer can read the shape before any logic exists. A plan whose slices build against nothing new, a bug fix in two existing files, has no Foundation; a phase 0 that founds nothing is a task that does nothing.
- **Phases 1..n, one per slice.** One tester S102 that writes the slice's acceptance test, or adds it to the existing test class of the code the slice changes, then one builder S102 per stack the slice touches. That test is the phase's **checkpoint**: green, written at API level against the Foundation's public methods, or against the existing public surface where the plan has no Foundation, end to end only where the repo's conventions name a runner. It compiles before any slice body exists, fails red, and the builder S102s make it pass. A new test class per slice is the default for new code, not a rule: maintenance work extends what is there.
- **The close, when the run needs one.** A phase after the last slice for the work that ends the run and belongs to no criterion: a release, a temporary reference put back, a flag flipped. Often a `human` task. It has a checkpoint like any other phase and is never squeezed into the last slice.

A checkpoint is two fields on the phase. **`checkpoint`** is one plain sentence saying what is true when the phase is done, written for the person who reads the plan view (*the status tests are green, including the two new cases*; *the solution builds with every public name in place*): no command, no test filter, no path. **`check`** is the command that proves the sentence, named from the repo's conventions (*the test command filtered to the slice's test class*; *the build command*), run by the verifier at the Build stage and never shown in the view. It follows the same rule as a task's done-when (`s102-task-spec-definition.md` §4.4): a named test, a build, or a command whose output is the system's behaviour, never a search of the source for the plan's own words. A deletion is proved by the build and the tests staying green, not by a grep that finds nothing. The sentence without the command is a wish; the command without the sentence is what the first runs produced, a shell line the author had to decode at the gate. A phase is the unit a run can stop at cleanly, and the unit a revert targets.

### 4.5 Contracts

What each task **produces** for another task: exact names and signatures (class, method, parameters and return types, event, endpoint), or the number of the design contract that already states them, and the task that produces each. Stated here once; an S102 names a contract it consumes or produces and never restates its signature. A builder sees only its own S102; this section is how neighbours agree on a name before either exists. **Who consumes a name is not recorded here.** The S102 header's `consumes` is the only home of consumption: a name in this table may be consumed by any task that comes after its producer, and the check is "the name is in §1 and the producer is upstream", never a column kept in step by hand. The first runs carried a *Consumed by* column, and a task spec that consumed a name the column did not list was a plan defect that cost a re-cut and a re-approval for a difference in bookkeeping.

**Existing code never has a row here.** A type, a method or a value the repo already holds is linked by path in the header of the S102 that relies on it, and validation resolves it against the repo on disk. §1 is the agreement between tasks, not an index of the codebase: the planner cannot know which existing identifiers a task spec will mention, and a row per identifier makes every mention a re-cut. A test name is never a contract either; the done-when names the test. A name an S102 consumes that no S102 produces and no path resolves is a plan defect, not a builder's problem.

### 4.6 Review focus

The handful of inputs or failure modes the design implies but no task's check exercises, most likely to bite first. One line each: the input or condition, and the behaviour a reasonable person expects. Each line is then pinned to the task that carries the scenarios of the code it concerns: in a slice the **tester** (`s102-task-spec-definition.md` §4.3, the one file that holds the slice's scenarios), and the builder reaches it through its one-line §2; a task outside a slice (a Foundation or a close task) is pinned directly. The pinned line becomes a scenario in that S102, tagged `@review-focus`; a pinned scenario does not count toward the scenario threshold of §8.1, so the pin and the threshold never pull against each other. A line pinned to a slice's builder would ask the builder to carry a scenario its tester already has, which is the duplication §4.3 removes; the second ticket-sized run spent a rewrite reconciling the two readings. An empty section means the check was run and found nothing, not that it was skipped.

### 4.7 Escalation routing

What a builder stops on, and who rules. A builder never resolves a conflict between its S102 and the design, the conventions or another task by editing an artifact it does not own; it stops and reports (`s102-task-spec-definition.md` §5). The S101 says where the report goes and who decides: by default the person directing the run, optionally an orchestrator agent for defects below a named threshold. The generic stops (a file outside the owned set, a consumed name that does not resolve, a conflict with the design or a neighbour) are the S102 definition's and are not repeated; the S101 lists the stops specific to this plan. Every ruling is recorded in the ledger with what was decided, why, and what it costs if wrong. A stop that reaches a human is for the four cases only: an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, or a plan so broken that every path forward is a guess. Everything else gets a ruling and the run continues.

### 4.8 Coverage map

Every requirement, contract and acceptance criterion of the design in scope, against the S102 ids that deliver it. It is the reviewer's first stop and the check that makes the S101 a plan for *this* design and not a plausible plan for a feature like it. A requirement with no task is a gap; a task with no requirement is scope the design never asked for. An id with no task says why: *verified by review* for a criterion checked by hand, *out of scope here, per OOSn* for an item the design assigns elsewhere. For a normalised design, every row also carries the source's wording of the item, one line, because the ids were assigned by the normalisation (§3.1); for a D101 the wording column may be left out. The ids this map traces are also what a re-run compares against the design to decide between an update and a rewrite (§6).

### 4.9 Assumptions

Every decision *about the feature* the plan took without asking the author: the question it would have been, the options, the default taken, and *decided by default* where the question budget was spent before it came up. Written last in the body, in the order taken. The author's corrections at the cut join the list, so the reviewer sees what was decided and what was corrected in one place. A workaround of the template's own rules (a phase that did not fit, a field listed twice to satisfy a check) is not an assumption about the feature; it is a finding about the toolkit and goes to the sidecar (§9), where the maintainer reads it. A plan with an empty Assumptions section claims the author answered everything; a plan with none hides its guesses.

## 5. Rules

- **Plan, don't build.** No code, no steps, no test bodies in the S101. Signatures appear in §1 Contracts and nowhere else. A plan that carries the recipe is one long task pretending to be a graph.
- **State it once.** Contracts, constraints and escalation appear in the S101 and are referenced, not copied, by the S102s. A rule copied into six tasks is six chances to drift.
- **Link, don't duplicate.** Design contracts by section number, conventions by path, existing code by path. Never a pasted schema, enum or column list.
- **Size to the design, not to a length.** An S101 is as long as its graph. A feature that needs one task gets a one-task plan; that is not a reason to skip it, because the constraints and the escalation routing still have to be written down somewhere the builder reads.
- **Model tier is a recommendation, per task.** Three tiers, named in the template: `low` for a task fully determined by the name, the signature and the check (a one-line read, a registration, a type), `mid` for behaviour in prose with a clear check, `high` for judgement or integration. No tier means the S102 carries code: the builder writes the body at every tier (`contracts/specification.md`, *names, not bodies*). The plan names a tier only; which model a tier means is the toolkit's call (`model-choice.md` in the Asimov repo), and the run may override it. A product repo never needs that file to validate a plan.
- **No product entity in the toolkit.** Product names, service names and ticket ids belong in the S101 in a product repo and never in this definition or the template (hard rule 7).

## 6. Lifecycle

One status axis, carried in the header: `draft` → `ready` (dispatch-ready: approved by the author and every S102 validated) → `in progress` (first task dispatched) → `done` (every checkpoint met, and every criterion the coverage map marks *verified by review* signed off by a reviewer). `asimov-spec` writes and rewrites `draft` through the authoring skill and moves `draft` → `ready` itself, by the rule below; the Build workflow moves `ready` → `in progress` → `done`. Nobody moves a status by hand.

**The approval** sits beside the status in the header: `approved: none` until the author's go at the cut, then `approved: { by: "<name>", date: "<YYYY-MM-DD>", fingerprint: "<hash>" }`, written by `asimov-spec` and by no other skill. The **fingerprint** covers what the author saw. The plan view renders the tree, the constraints, the coverage and the assumptions, so the fingerprint is the SHA-256 of exactly those parts, first 12 hex characters: the `phases:` block of the frontmatter and the body sections §2 Constraints, §3 Coverage and §6 Assumptions:

```
awk '/^phases:/{p=1} p&&/^---$/{p=0} /^## /{s=0} /^## (2|3|6)\./{s=1} p||s' <file> | sha256sum | cut -c1-12
```

The command carries no `$`-prefixed token on purpose: a skill's text is a prompt the harness substitutes `$ARGUMENTS`, `$0`, `$1`… into, so an awk that read `$0` hashed the invocation's words instead of the line. Every skill that computes the fingerprint (`asimov-spec`, `asimov-build`, `artifact-s101-ledger`) carries this exact command; they move together.

§1 Contracts, §4 Escalation and §5 Review focus are the agents' plumbing: a row added there after the go does not break the approval, because the author never approved a lookup table. The approval **holds** while the fingerprint matches those parts of the file. The fingerprint is machine state: computed when an approval is written, compared when a later run or the Build stage opens the plan, and never printed to a person. **What a person sees is the version**, the approval's name: `0.1` at the first write, unchanged through the cut rounds before the go, and bumped by every write that changes an approved part once an approval is on disk (a re-cut; a finalise that changed §3 or §6), so that two approved plans never share a number and "approved v0.3" says which one. A write that changes only §1, §4 or §5 moves neither the fingerprint nor the version: the approval holds and its name stays. `ready` is set when the approval holds and every S102 in the tree is `validated` (`s102-task-spec-definition.md` §6). Any change to the tree, §2, §3 or §6 after the go, by a re-cut, by the finalise step or by hand, breaks the match: `asimov-spec` shows the plan again with what changed and asks the author to approve it again before `ready`; a `ready` plan named again with a broken fingerprint is re-checked and approved again by the same skill. An unchanged plan is not asked twice. A `done` S101 stays in the repo as the record of how the feature was built; it is not deleted. A criterion *verified by review* has no checkpoint, so green tests alone leave the plan `in progress`; who signed it and when is run state and lives in the ledger, never in the plan.

The cut is a `draft` S101 with no S102 beside it. No status value marks it; the folder does.

A re-run against a design that already has an S101 takes one of two paths. **Update in place** when the source's items are the ones the coverage map traces (for a D101, the R, NF and AC ids; for a normalised design, the items the map's wording column names, compared with the source as read now) and the author confirms the content is refined, not changed: same file, version bumped, and every S102 that still clears its bar left byte-identical. **Rewrite** when an item is missing or added, or the author says the content changed: the S101 and every S102 written anew, S102 files no longer in the graph deleted. There is no `superseded` status and no kept copy; git carries the previous plan. An S101 at `ready` or later is never rewritten by a skill; the author sets it back to `draft` first, the one hand edit of a status this definition allows.

## 7. Anti-patterns

- **The graph in chat.** Order and parallelism decided in the run prompt and never written down. The next run re-decides them.
- **The graph narrated.** A body that retells the frontmatter in paragraphs. The agent has the tree; the person has the view; the prose serves neither.
- **One long task.** A single S102 that is the whole feature. That is L2 with a file attached; the plan exists to cut it.
- **Parallel by hope.** Two tasks marked parallel that both touch the same file. The second one to finish overwrites the first.
- **Builder before tester.** A slice whose builder runs beside or ahead of its tester, so "red first" is a race and the builder's brief has to say "if the test exists".
- **Behaviour in the Foundation.** A method body that makes a criterion pass, cut into phase 0 because it was small. Its test then lives two phases away.
- **The Foundation for its own sake.** A phase 0 with nothing to found, cut because the template shows one. Two tasks became three, and the first one did nothing.
- **The codebase in §1.** A contracts row for every existing identifier a scenario happens to mention. The table is for names that do not exist yet; the repo closes the rest.
- **Interfaces by guess.** A consumer that names a method no producer defines. The builder invents one, and the neighbour invents a different one.
- **State in the plan.** Checkboxes ticked, `passes: true` flipped, fix rounds noted inside the S101. The reviewed document and the run log become one file.
- **Conventions copied.** A constraints section that restates the house style the builder loads anyway. It is long, it drifts, and it buries the one constraint the design actually imposed.
- **Silent scope.** A task with no design requirement behind it. Either the design is missing a requirement or the task is not this feature.

## 8. The checks

One canonical list. Every check is asked of the S101 alone, with the design and the S102s open beside it. The verdict is the reviewer's (§2).

| # | Check | Tests |
|---|---|---|
| 1 | Does the S101 provide every plan member of `contracts/specification.md`, and does every S102 the graph names exist and clear its own bar? | Completeness |
| 2 | Does every requirement and acceptance criterion of the design in scope map to at least one S102 or a stated reason, and every S102 to at least one requirement? | Coverage, both ways |
| 3 | Is the graph acyclic, does every slice's builder come after its tester and every slice task after the Foundation where there is one, and does every pair that may run together own disjoint file sets (from the S102 headers)? | Graph validity |
| 4 | Does every phase end in a checkpoint a person reads as one sentence, with a check a reviewer can run without reading code? | Stoppable phases |
| 5 | Is every name an S102 consumes produced by an S102 and stated in §1, existing in the repo at the path the S102 links, or numbered in the design? | Interface closure |
| 6 | Are the constraints the design's and the departures from the conventions only, stated once with values verbatim, and does no S102 contradict them? | Constraint consistency |
| 7 | Does the review focus name the uncovered failure modes, and is each pinned to a task? | Review focus |
| 8 | Does the escalation routing name the plan's own stops and who rules? | Escalation |
| 9 | Is the S101 free of code, steps and test bodies, free of run state, and free of prose that retells the graph? | Separation |
| 10 | Is every model tier a recommendation consistent with its meaning in §5? | Model choice |

Validation (`artifact-s101-validation`) is **hard on shape, soft on content**: it fails a missing header field, a missing plan member, a cycle, a builder ahead of its tester, an orphan task, a broken link, an intersecting parallel pair, a consumed name with no producer and no path on disk; it does not judge whether the phases are sensible, whether a Foundation was needed, or whether the review focus is the right five. That is the reviewer's. It runs in two modes: **graph-only** on the S101 alone, at the cut, where a check that needs the S102s is reported as *not yet*, never as Pass; and **full** once every S102 exists, re-answering every row. The check is a script, `scripts/validate-s101.ps1` (since 2026-10-08; the checklist in `artifact-s101-validation` is its specification and the fallback): every row is answered by enumeration from the files' text and from lookups, in about a second, so two runs on an unchanged plan agree by construction and nothing is carried between modes. The two LLM validators it replaced cost a two-task run some 120k tokens and gave different answers on unchanged text. **A Fail means a builder would be stuck or build the wrong thing.** A defect the run should know about but that would stop no builder (a long title, a command inside a checkpoint sentence) is a Flag, whatever row it falls under.

### 8.1 Size thresholds

Validation warns, never fails, when an S102 exceeds a threshold; the plan is still written. The numbers live here, not in a skill, so they move with the evidence (research §8) and not with a release. Both validation skills read them.

```yaml
thresholds:                      # per S102; above the number → Warn
  owned_non_test_files: 3        # create + modify, tests excluded; success falls sharply from 3, to nil at 7
  scenarios: 3                   # a builder task's own behaviour scenarios; a scenario tagged @review-focus (§4.6) is not counted; more is usually two tasks
  scenarios_tester: 5            # a tester task's scenarios: it carries the whole slice (every rule with its failing case), so the bar is higher
```

A cycle, an orphan or an intersecting parallel pair is shape and fails; size only warns. A builder task in a slice does not restate the scenarios its tester carries (`s102-task-spec-definition.md` §4.3); only the scenarios of its own count against its threshold.

## 9. Placement and naming

An S101 lives in the product repo at `documentation/specs/<feature-slug>/S101-<feature-slug>.md`, beside its S102s (`S102-<feature-slug>-<NNN>-<task-slug>.md`, the task slug three to five words of the title). `<feature-slug>` is the D101's slug, so `documentation/features/D101-permissions.html` plans to `documentation/specs/permissions/S101-permissions.md`; for a ticket it is the ticket key in kebab-case, so `PROJ-123` plans to `documentation/specs/proj-123/S101-proj-123.md`. Markdown body with YAML frontmatter, as every spec format in current use (research §2).

**The repo notes.** The cut reads the repo once; the task-spec writers that follow should not read it again from nothing. So the authoring skill writes what it learned beside the plan as a gitignored cache, `documentation/specs/<feature-slug>/repo-notes.md`, and refreshes it at every cut: the files the plan touches with one line on what each holds, the existing types, methods and values the tasks will name with the path that declares each, the types that come from a package with the package id and the project that references it, the test project, fixture and runner in use, the build and test commands as the conventions give them, and anything the cut had to look up twice. Facts with paths, never a plan, never a decision, never code. The task-spec writers read it first and take its paths and names as given (the shape check looks each one up for free; a wrong line is a template finding, not a reason to re-walk the repo); a validator may read it only as a list of where to look, and answers every row against the code on disk, never against the notes. The notes hold what the cut read and nothing looked up for their sake: the cut opens the files the design names, the test class of what a slice changes, the owned project file and one declaring file per name a task must use, and no more; a sparse notes file is correct. A missing file (a fresh checkout) costs nothing but the re-reading; nothing refuses on it.

```markdown
# Repo notes — <feature-slug>

Written: <YYYY-MM-DD> · by the cut of S101-<feature-slug>.md v<version>

## Files the plan touches
- <repo-relative path> — <what it holds, one line>

## Existing names the tasks will use
- <Name> (<repo-relative path>) — <one line: what it is>
- <Name> (package <PackageId>, referenced by <project file>) — <one line>

## Tests
- project: <path> · fixture: <name (path)> · runner: <the test command from the conventions>

## Commands
- build: <command> · test: <command> · filter form: <how the runner filters to one class>

## Looked up twice
- <anything the cut had to find more than once, with where it is>
```

For a plan cut from a design that is not a file in the repo, the normalised design sits beside it as a gitignored cache, `documentation/specs/<feature-slug>/design.md`: the contract's members, quoted from the source and numbered, in this shape:

```markdown
# Design — <title>

Reference: <url> · read <YYYY-MM-DD HH:MM>
Approval: <who> · <YYYY-MM-DD> · <where: a comment, a status> · verified | unverified: pasted text
(a proxy approval reads "<who> for <whom>"; unverified means the text reached the skill pasted, so nobody checked who wrote the approval or when)

## Problem
<quoted>

## Decision
<quoted, as many paragraphs as the source has>

## Rules
- R1 · <quoted> — does not cover: <quoted>
(or: none stated)

## Acceptance criteria
- AC1 · <quoted>

## Out of scope
- OOS1 · <quoted> — because: <quoted>

## Open questions
- <quoted> · decides: <who>
(or: none)

## Assumptions
- <quoted>
(or: none stated)

## Interfaces
- <name> · <shape or number>          (omit when the source names none)

## Non-functional requirements
- NF1 · <quoted> · <measure>          (omit when none)

## Alternatives
- <quoted> — not chosen because: <quoted>          (omit when none)

## Risks
- <quoted>          (omit when none)

## Source
<the description and every comment, verbatim, with author and date>
```

`asimov-spec` writes it at the start of a run from the fetch or from pasted text, and rewrites it when it is missing on a re-check; the authoring and validation skills read it as the design. It is never committed and never edited by hand: a correction goes into the source, and the next run reads it.

Beside the plan, both asimov-skills write one gitignored sidecar, `S101-<feature-slug>.review.md`. Overwritten by the next run, read by no skill, never a record; the same role as `asimov-design-review`'s `D101-<slug>.review.md`. One shape, so a reader learns it once:

```markdown
# Validation — S101-<feature-slug>

S101: documentation/specs/<feature-slug>/S101-<feature-slug>.md v<version>
Design: <design.ref> v<design.version> | <design.ref> read <design.read> · cache <design.cache>
Date: <YYYY-MM-DD>
Mode: graph-only | full
Blind: true | false
Engine: script | llm (plan) · script | llm (task specs)
Approval: <by> · <date> · <fingerprint> · holds | superseded | none

## Plan report
<the S101 validation report, verbatim>

## Task reports
### <task id> · <S102 file>
<its last S102 validation report, verbatim; one block per S102 in file order>

## Assumptions decided by default
<the rows of S101 §6 whose How is "decided by default", verbatim; "none" if none>

## Template findings
<each place the plan had to work around a rule of the template or a check, one line; "none" if none>
```

`Blind` is false when any S102 report was produced by the caller's own reading rather than by the script or a fresh subagent; `Engine` records which check ran as the script and which, on a machine without PowerShell, as an LLM reading of the checklist.

The specs folder, with its two gitignored siblings `S101-<feature-slug>.review.md` and `design.md`, is a shared path convention in the sense of hard rule 7 and a lockstep literal in the sense of hard rule 9: both asimov-skills, the four artifact skills, `.gitignore`, `CLAUDE.md` and D100 §5 and §9 move together.
