---
artifact: s102-task-spec
maturity: assess
since: 2026-09-25
---

# Definition of S102

The written standard an S102 (task spec) must meet before a build subagent is dispatched on it. An S102 is one task: the exact brief a fresh builder receives, sized to be built in one sitting without asking a human, validated blind by a reader that never saw the conversation, and verifiable afterwards against the code it produced. It is the Spec stage's **task** document; the S101 (`s101-implementation-plan-definition.md`) is the plan that orders the tasks.

Read by humans (the author, the reviewer, the person directing the run), by the build subagents as their whole brief, by the Build workflow's verification as the criteria to run, and at run-time by the asimov-skills `asimov-spec` and `asimov-spec-validate` through the artifact skills `artifact-s102-authoring` and `artifact-s102-validation`.

Design: `documentation/features/D101-spec-stage.html`. Research: `documentation/research/S101-S102-spec-stage-research.md`.

---

## 1. What an S102 is for

A builder that sees only its own task, in a fresh context, needs everything in one place: what to build, where, against which names, how to know it is done, and when to stop and ask. The S102 is that place. It is written *for* an agent, and it is the artifact a human reviews when they want to know what the agent was told.

It answers five questions:

- **What, and why?** The intent, in one sentence, traced to the design source.
- **Where?** The files it creates, modifies and tests, exactly. This is also the set it owns; nothing else is touched.
- **Against what?** The interfaces it consumes and produces, by exact name and shape.
- **Done when?** Acceptance criteria verification can run.
- **Stop when?** The escalation triggers, and the rule that the builder never edits what it does not own.

## 2. The bar: buildable blind

An S102 clears one bar. **Buildable blind** means a competent builder with no conversation history, no access to the author and only the repo, the design source (the D101, or the ticket) and this file in front of it, builds the task and knows when it is finished. Concretely:

- every file path is exact and exists or is declared new;
- every name the task consumes is defined by a producer task or by existing code linked by path;
- every step a builder must take is stated, with the code to write where the task is transcription;
- every acceptance criterion is checkable by running something and reading the result;
- the escalation triggers name the conditions that stop the builder;
- nothing is left as a placeholder (§5).

The bar is **validated blind** right after the S102 is written: a fresh subagent with no conversation history, given only the S102, its S101, the D101 and the repo, answers the checks of §8 and reports. Blind means no conversation, not no repo. The model that wrote the S102 has the conversation in context and fills the gaps from memory; a fresh reader finds them. An S102 that fails is rewritten and validated again; a third failure, or a finding that names a gap in the D101 rather than in the S102, stops the run and is reported instead of rewritten. The verdict then belongs to the S101's reviewer as part of the S101 review (`s101-implementation-plan-definition.md` §8 check 1). The builder itself does not judge the bar; it builds or it stops.

**Validation** is this check, before code. **Verification** is the Build workflow's check after code: run the acceptance criteria of §4.8 against what was built. Two checks, two moments, two inputs; this definition covers the first and shapes the second.

## 3. Relationship to other documents

| Doc | Stage | What it answers |
|---|---|---|
| **D101 or ticket** | Design | What and why; the contracts (D101 §6) or the ticket's decision this task realises (`s101-implementation-plan-definition.md` §3.1) |
| **S101** | Spec | Where this task sits: its dependencies, its phase, the constraints it inherits |
| **S102** | Spec | Exactly how this one task is built and checked |
| Conventions | Cross-cutting | House style the builder loads anyway (D100 §7.2.1); the S102 links, never copies |
| Runtime task / ledger | Execution | Claimed, in progress, fix round, done; **never part of the S102** |

- **One of several under an S101, or the only one.** The S102 inherits the S101's global constraints and escalation routing without repeating them; it states only what is specific to this task.
- **Never without a plan.** A bug fix from the board skips the D101, not the S101: its ticket is the design source and its plan may have one task (`s101-implementation-plan-definition.md` §3). The task then traces to the ids the plan assigned to the ticket's items.
- **It supersedes the D101's §7 Implementation.** File layout, reuse-vs-new and method-level wiring were carried in §7 as an interim (`d101-feature-design-definition.md` §4.8). That is S102 content. A feature with S102s marks §7 N/A.
- **The S102 is the instruction, not the record of the run.** Which builder claimed it, how many fix rounds it took, what the reviewer found: ledger. The S102 changes only when the author re-specifies the task.

## 4. Required content

### 4.1 Header

The S101 it belongs to and its task id in that graph, the requirements, contracts and acceptance criteria of the design source it serves by id, the builder role it is written for (exactly one of the roles the S101 template's leading comment lists: a `role-*` skill such as `dotnet-builder`, `angular-builder` or `dotnet-tester`, or `human`), the model tier recommended, the tasks it depends on, the status (§6), the author and the date. Role, tier, dependencies and traces are copied from the graph entry so the brief stands alone; the plan validation checks they still match.

### 4.2 Intent

One or two sentences: what this task delivers and why the feature needs it, in the D101's words. A builder that understands the intent makes the right call on the one thing the spec forgot; one that does not, guesses.

### 4.3 Files

Three lists, exact paths: **create**, **modify** (with the region where the change goes when the file is large), **test**. Together they are the task's owned set. Anything outside it is out of scope for this task, and a builder that needs to touch a file outside it has hit an escalation trigger, not a judgement call. This is the set the S101 checks for disjointness against parallel tasks.

### 4.4 Interfaces

**Consumes**: every name this task relies on that another task produces or existing code provides. Exact signature; for existing code, the path. **Produces**: every name a later task will rely on. Exact signature, chosen here so neighbours agree before either exists. A consumed name with no producer anywhere is a plan defect (`s101-implementation-plan-definition.md` §4.5); the builder stops, it does not invent.

### 4.5 Behaviour

The observable behaviour the task adds, as scenarios a test can be written from: given a state, when an action, then an outcome. Gherkin in fenced code blocks, one scenario per behaviour, so validation can count them and a tester can lift them. Business rules carry their counter-example, as the D101 does (`d101-feature-design-definition.md` §6.3).

### 4.6 Constraints

Four short lists, only what is specific to this task (the S101 carries the global ones):

- **Musts**: what the implementation has to do or use (a named abstraction, a logging call, a pattern).
- **Must nots**: what it may not do (bypass a layer, add a dependency, change a signature it does not own).
- **Preferences**: what to reuse or prefer when there is a choice, by path.
- **Escalation triggers**: the conditions under which the builder stops and reports instead of deciding (§5).

### 4.7 Steps

The order of work, test first: write the failing test, run it and see it fail, write the minimal implementation, run it and see it pass, commit. Each step is one action. Where the task is **transcription** (the author knows exactly what the code is), the code is in the step, and the task takes the cheapest model tier. Where the task needs judgement, the step says what to achieve and what to check, and the tier goes up. A step that describes what to do without showing how, for code the author could have written, is a placeholder (§5).

### 4.8 Acceptance criteria

Numbered, each checkable by running something: a named test that passes, a command whose output matches, a file that exists with a named shape. These are what verification runs the built code against in the Build workflow, and what the reviewer reads to decide the task is done. An acceptance criterion nothing can run is a wish.

### 4.9 Out of scope

What a builder might reasonably think belongs here and does not: the neighbouring task that owns it, the follow-up the D101 deferred, the refactor that tempts. One line each. It is cheaper to say it than to review it out.

## 5. Rules

- **No placeholders.** Never `TBD`, `TODO`, "add appropriate error handling", "handle edge cases", "write tests for the above" without the test, "similar to task N" without the content. A builder reads tasks out of order and alone; every task carries what it needs.
- **The how is welcome here.** File paths, signatures, libraries, patterns: everything the D101 forbids as design is what the S102 exists to state. The line is the D101's, not the builder's.
- **Code to write is inline; code that exists is linked.** The instruction for new code is the code. Existing types, enums, schemas and column lists are referenced by path, never pasted, so the S102 does not go stale when they move.
- **Own your files; stop at the edge.** The builder changes only the owned set (§4.3). Needing a file outside it is an escalation trigger.
- **Never edit what you do not own.** A conflict between this S102 and the D101, the conventions or a neighbouring task is not resolved by the builder changing any of them. It stops, reports to the route the S101 names, and waits for a ruling. The ruling is recorded in the ledger, not in the S102. Rework from a wrong ruling is cheap; a builder that quietly rewrote the contract is not.
- **One task, one context.** If the task cannot be built and verified in one builder sitting, it is two tasks. The heuristics converge: one context window; one test cycle a reviewer could reject on its own; a spec that takes more than a short sitting to write is describing more than one thing.
- **Inherit, don't repeat.** Global constraints, escalation routing and the review focus live in the S101. The S102 states only what is specific to it.
- **No product entity in the toolkit.** Product names and ticket ids belong in an S102 in a product repo, never in this definition or the template (hard rule 7).

## 6. Lifecycle

One status axis in the header: `draft` → `ready` (clears the bar, reviewed) → `done` (acceptance criteria met, verification green). `draft` is the only value a skill writes; the later values follow the S101's (the author moves `draft` → `ready` with the plan, the Build workflow moves `ready` → `done`), and the builder never changes the file. Claimed, in progress and fix rounds are ledger states, not S102 states. A `done` S102 stays as the record of what the agent was told.

There is no `superseded`. An S102 that fails validation, or that a plan-level finding names, is rewritten in place by the loop; an update of the plan leaves an S102 that still clears byte-identical; a rewrite of the plan replaces every S102 and deletes the files outside the new graph. Git carries what was there.

## 7. Anti-patterns

- **The feature in one task.** An S102 that touches every layer and takes a day. It is an S101 wearing the wrong header.
- **The placeholder recipe.** "Implement the service" with no signature, no test, no file. The builder writes a plausible service; the neighbour expected a different one.
- **The invented name.** A consumed method the S102 never defined. The builder picks one; two builders pick two.
- **The pasted schema.** An enum or column list copied from the code into the task. It is wrong by the second sprint.
- **Silent scope creep.** The builder fixes the adjacent thing while it is there. The owned set is the fence; the out-of-scope list is the sign on it.
- **The self-edited contract.** A builder that changes the D101 or a neighbour's S102 to make its own task consistent. The conflict was the finding; editing it away hid it.
- **State in the spec.** `passes: true`, checkboxes ticked, fix notes appended to the S102. The instruction and the run log become one file, and the reviewed text is no longer what the builder read.

## 8. The checks

Asked of the S102 with the S101 and the design source beside it. The verdict is the S101 reviewer's.

| # | Check | Tests |
|---|---|---|
| 1 | Does the header trace to an S101 task and to named ids of the design source (a D101's, or the ids the plan assigned to a ticket's items)? | Traceability |
| 2 | Is every file path exact, and does every modified file exist? | Files |
| 3 | Is every consumed name produced by a named task or by existing code linked by path? | Interface closure |
| 4 | Is every behaviour a scenario a test can be written from, and does every rule carry a counter-example? | Behaviour |
| 5 | Are the steps test-first, one action each, with the code inline where the task is transcription? | Steps |
| 6 | Is every acceptance criterion checkable by running something? | Runnable |
| 7 | Are the escalation triggers stated, and do they include leaving the owned file set? | Escalation |
| 8 | Is the S102 free of placeholders, of pasted existing code, and of run state? | Hygiene |
| 9 | Could a builder finish it in one sitting? | Size |
| 10 | Does it contradict a global constraint in its S101, or state one that belongs there? | Inheritance |

Validation (`artifact-s102-validation`) is hard on shape and soft on content: it fails a missing header field, a path that does not resolve, a consumed name with no producer, a placeholder token, an acceptance criterion with no runnable form. It does not judge whether the scenarios are the right ones. That is the reviewer's. The shape checks come first and are answered against a fixed, numbered checklist, so two runs on an unchanged file agree; the size check (row 9) counts owned non-test files, scenarios and steps against the thresholds in `s101-implementation-plan-definition.md` §8.1 and warns, never fails. The report is one row per check, Pass / Flag / Fail / Warn with one sentence, and nothing else: the skill edits nothing and proposes no fix.

## 9. Placement and naming

An S102 lives beside its S101 at `documentation/specs/<feature-slug>/S102-<feature-slug>-<NNN>-<task-slug>.md`, `<NNN>` counting from `001` inside the feature folder. For a ticket-sourced plan the folder is the ticket key in kebab-case. Markdown body with YAML frontmatter; scenarios in Gherkin code fences, so validation can parse them. The path is a lockstep literal of hard rule 9, moved together with the S101's (`s101-implementation-plan-definition.md` §9).
