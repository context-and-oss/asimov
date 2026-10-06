---
artifact: s102-task-spec
maturity: assess
since: 2026-09-25
---

# Definition of S102

The written standard an S102 (task spec) must meet before a build subagent is dispatched on it. An S102 is one task: the brief a fresh builder receives, sized to be built in one sitting without asking a human, validated blind by a reader that never saw the conversation, and verifiable afterwards against the code it produced. It is the **task** part of a specification as `contracts/specification.md` defines it; the S101 (`s101-implementation-plan-definition.md`) is the **plan** part that orders the tasks.

Read by the build subagents as their whole brief, by the Build workflow's verification as the checks to run, by the person who wants to know what the agent was told, and at run-time by the asimov-skills `asimov-spec` and `asimov-spec-validate` through the artifact skills `artifact-s102-authoring` and `artifact-s102-validation`.

Design: `documentation/features/D101-spec-stage.html`. Research: `documentation/research/S101-S102-spec-stage-research.md`, `documentation/research/specification-contract-research.md`.

---

## 1. What an S102 is for

A builder that sees only its own task, in a fresh context, needs everything the author decided in one place: what to build, where, against which names, how to know it is done, and when to stop and ask. The S102 is that place. It is written *for* an agent, and it is the artifact a human reviews when they want to know what the agent was told.

It answers five questions:

- **What, and why?** The intent, in one or two sentences, traced to the design.
- **Where?** The files it owns, exactly. Nothing else is touched.
- **Against what?** The names it consumes and produces, as the plan's contracts spell them.
- **Done when?** The check that proves it: a named test, a build, a command and its result.
- **Stop when?** The conditions under which the builder reports instead of deciding.

What it does not answer is *how*. The builder writes every method body, chooses every private name, and writes every test. That is the line `contracts/specification.md` draws, and the reason a builder is a role and not a transcriber.

## 2. The bar: buildable blind

An S102 clears one bar. **Buildable blind** means a competent builder with no conversation history, no access to the author and only the repo, the design, the S101 and this file in front of it, builds the task and knows when it is finished. The builder never has to make a decision the specification owns (scope, a public name, what counts as done) and makes every decision the builder owns (the code). Concretely:

- every file path is exact, and every modified file exists or is created by a task this one comes after;
- every name the task consumes is in the S101's contracts, produced by a task this one comes after or linked as existing code;
- the behaviour it adds is stated as scenarios a test can be written from, or the task says it adds none;
- every done-when is checkable by running something and reading the result;
- the stop conditions name what halts the builder beyond the generic ones;
- nothing is left as a placeholder, and nothing is pre-written that the builder owns (§5).

The bar is **validated blind** right after the S102 is written: a fresh subagent with no conversation history, given only the S102, its S101, the design and the repo, answers the checks of §8 and reports. Blind means no conversation, not no repo. The model that wrote the S102 has the conversation in context and fills the gaps from memory; a fresh reader finds them. An S102 that fails is rewritten and validated again; a third failure, or a finding that names a gap in the design rather than in the S102, stops the run and is reported instead of rewritten. A clean report is the S102's approval: `asimov-spec` marks the file `validated` with the date (§6), no person is asked to approve a task spec, and the S101's check 1 reads those marks. The builder itself does not judge the bar; it builds or it stops.

**Validation** is this check, before code. **Verification** is the Build workflow's check after code: run the done-when of §4.4 against what was built. Two checks, two moments, two inputs; this definition covers the first and shapes the second.

## 3. Relationship to other documents

| Doc | Stage | What it answers |
|---|---|---|
| **D101 or ticket** | Design | What and why; the contracts (D101 §6) or the ticket's decision this task realises (`s101-implementation-plan-definition.md` §3.1) |
| **`contracts/specification.md`** | Spec → Build | The task members this S102 provides (§3.2) and the line between what it fixes and what the builder decides |
| **S101** | Spec | Where this task sits: its phase, what it comes after, the contracts it names, the constraints it inherits |
| **S102** | Spec | What this one task delivers, where, and how done is observed |
| Conventions | Cross-cutting | House style the builder loads anyway (D100 §7.2.1); the S102 names only a departure |
| Runtime task / ledger | Execution | Claimed, in progress, fix round, done; **never part of the S102** |

- **One of several under an S101, or the only one.** The S102 inherits the S101's constraints, contracts and escalation routing without repeating them; it states only what is specific to this task.
- **Never without a plan.** A bug fix from the board skips the D101, not the S101: its ticket is the design and its plan may have one task (`s101-implementation-plan-definition.md` §3). The task then traces to the ids the plan assigned to the ticket's items.
- **It supersedes the D101's §7 Implementation.** File layout and reuse-vs-new were carried in §7 as an interim (`d101-feature-design-definition.md` §4.8). The owned set and the out-of-scope list are where that content now lives. A feature with S102s marks §7 N/A.
- **The S102 is the instruction, not the record of the run.** Which builder claimed it, how many fix rounds it took, what the reviewer found: ledger. The S102 changes only when the author re-specifies the task.

### 3.2 How the S102 meets `contracts/specification.md`

The contract's task members, and where the S102 provides each. The plan members are the S101's (`s101-implementation-plan-definition.md` §3.2).

| Contract member | Provided by |
|---|---|
| Intent | §1 Intent, with the design ids in the header's `traces` |
| Scope | the header's `owns` (create, modify, test); the only home of the owned set |
| Done-when | §3 Done-when |
| Behaviour | §2 Behaviour, or its explicit *none* |
| Task constraints and stop conditions | §4 Constraints and stops |
| Out of scope | §5 Out of scope, or its explicit *none* |
| Tier (optional) | the header's `tier`, copied from the graph |
| Contracts (a plan member) | named, never restated: the header's `consumes` and `produces`, spelled as the S101 §1 spells them |

The contract's rules bind the task: *names, not bodies*, *the check is described, not written*, *one task, one sitting*, *state it once*, *link, don't copy*, *traceable both ways*, *complete, or not a specification*.

## 4. Required content

### 4.1 Header

The S101 it belongs to and its task id in that graph; the title; the design ids it serves; the builder role it is written for (exactly one of the roles the S101 template's leading comment lists); the model tier recommended; the tasks it comes after; the status (§6); the author and the date. Role, tier, `after` and traces are copied from the graph entry so the brief stands alone; the plan validation checks they still match.

The header also carries the three machine-read members of the task:

- **`owns`**: the files the task may create, modify and test, exact and repo-relative. Together they are the task's owned set and the only place it is stated; the S101 reads it for disjointness. A new test file is listed under `test` alone. Anything outside the set is out of scope for this task, and a builder that needs to touch a file outside it has hit a stop condition, not a judgement call.
- **`consumes`**: every name this task relies on that another task produces or existing code provides, spelled as the S101 §1 Contracts spells it. The signature lives there; the S102 never restates it. A consumed name with no producer anywhere is a plan defect (`s101-implementation-plan-definition.md` §4.5); the builder stops, it does not invent.
- **`produces`**: every name a later task will rely on, spelled as the S101 §1 spells it. The S101 fixed the signature at planning time so neighbours agree before either exists.

### 4.2 Intent

One or two sentences: what this task delivers and why the feature needs it, in the design's words. A builder that understands the intent makes the right call on the one thing the spec forgot; one that does not, guesses. The reason, never the recipe.

### 4.3 Behaviour

The observable behaviour the task adds, as scenarios a test can be written from: given a state, when an action, then an outcome. Gherkin in fenced code blocks, one scenario per behaviour, so validation can count them and a tester can lift them. A rule carries its counter-example as its own scenario, as the D101 does (`d101-feature-design-definition.md` §6.3). The scenarios describe what the system does, never how: no class, method or private name appears in a scenario unless it is a public name from the S101 §1.

A task that adds no observable behaviour (a skeleton, a registration, a reference switched, a release) says so in one line and names what its check is instead. A scenario about compiling or about a file's text is not a behaviour.

### 4.4 Done-when

Numbered, each checkable by running something and reading the result: a named test that passes, a build that is green, a command whose output matches. The test is named and its expected outcome stated; its code is not here (`contracts/specification.md`, *the check is described, not written*). For a tester task, done-when says which test class exists with one test per scenario and what state it is in (red against the Foundation, or green). For a builder task, done-when names the test the tester wrote and says it is green.

These are what verification runs the built code against in the Build workflow, and what the reviewer reads to decide the task is done. A done-when nothing can run is a wish; a done-when that searches the code for the text of the spec is a transcript check and is not allowed.

### 4.5 Constraints and stops

Only what is specific to this task; the S101 carries the global ones:

- **Must**: what the implementation has to do or use (a named abstraction, a public pattern, a value from the design).
- **Must not**: what it may not do (bypass a layer, add a dependency, change a signature it does not own, use a column the plan ruled out).
- **Prefer**: what to reuse or mirror when there is a choice, by path.
- **Stops**: the conditions specific to this task under which the builder stops and reports instead of deciding. The generic stops (a file outside the owned set, a consumed name that does not resolve, a conflict with the design, the conventions or a neighbouring task) hold for every S102 by this definition (§5) and are not repeated.

A must that names a private method, an algorithm or the shape of a loop has crossed the line: that is the builder's.

### 4.6 Out of scope

What a builder might reasonably think belongs here and does not: the neighbouring task that owns it, the follow-up the design deferred, the refactor that tempts. One line each. It is cheaper to say it than to review it out.

## 5. Rules

- **Names, not bodies.** The S102 names public classes, methods, parameters and types as the S101 §1 spells them, and states behaviour. It carries no method body, no private structure, no test code and no steps. A body in a task spec is a transcript, not a brief; the builder writes it.
- **The check is described, not written.** Done-when names the test and its outcome, the build, the command and its output. Never the test's code; never a search of the source for the spec's own words.
- **No placeholders.** A placeholder is a decision the specification owns and left open: a missing path, a name no contract defines, a behaviour "to be handled", a done-when that cannot run, "similar to task N" with no content. A missing body is not a placeholder; it is the builder's work.
- **Own your files; stop at the edge.** The builder changes only the owned set. Needing a file outside it is a stop.
- **Never edit what you do not own.** A conflict between this S102 and the design, the conventions or a neighbouring task is not resolved by the builder changing any of them. It stops, reports to the route the S101 names, and waits for a ruling. The ruling is recorded in the ledger, not in the S102. Rework from a wrong ruling is cheap; a builder that quietly rewrote the contract is not.
- **One task, one sitting.** If the task cannot be built and verified in one builder sitting, it is two tasks. One context window; one test cycle a reviewer could reject on its own.
- **Inherit, don't repeat.** Global constraints, contracts, escalation routing and the review focus live in the S101. The S102 names a contract and states only what is specific to it.
- **Link, don't paste.** Existing types, enums, schemas and column lists are referenced by path, never pasted, so the S102 does not go stale when they move.
- **No product entity in the toolkit.** Product names and ticket ids belong in an S102 in a product repo, never in this definition or the template (hard rule 7).

## 6. Lifecycle

One status axis in the header: `draft` → `validated` (the blind check cleared; the date in `validated`) → `done` (done-when met, verification green). The authoring skill writes `draft` with `validated: none`; `asimov-spec` moves `draft` → `validated` on a clean blind report and fills the date, the agent's approval of the task spec; a rewrite after a failed check or a plan finding returns it to `draft`; the Build workflow moves `validated` → `done`. The builder never changes the file, and nobody sets a value by hand. Claimed, in progress and fix rounds are ledger states, not S102 states. A `done` S102 stays as the record of what the agent was told.

There is no `superseded`. An S102 that fails validation, or that a plan-level finding names, is rewritten in place by the loop; an update of the plan leaves an S102 that still clears byte-identical; a rewrite of the plan replaces every S102 and deletes the files outside the new graph. Git carries what was there.

## 7. Anti-patterns

- **The transcript.** An S102 that carries the method body, the test class and the exact lines to insert. The planner built the feature and called it a plan; the builder pastes; the tier means nothing.
- **The feature in one task.** An S102 that touches every layer and takes a day. It is an S101 wearing the wrong header.
- **The placeholder recipe.** "Implement the service" with no owned file, no contract name, no check. The builder writes a plausible service; the neighbour expected a different one.
- **The invented name.** A consumed method no contract defines. The builder picks one; two builders pick two.
- **The grep criterion.** A done-when that searches the source for the text of the spec. It checks that the builder copied, not that the code works, and a line break fails it.
- **Behaviour by decree.** A Gherkin scenario about a file compiling or a string being present. Behaviour is what the system does for a caller.
- **The copied signature.** A Consumes list that restates what the S101 §1 already says. It drifts the first time the plan is corrected.
- **The boilerplate brief.** Every section opening with the sentence from the template. The builder reads it eleven times; the one line that matters is buried.
- **Silent scope creep.** The builder fixes the adjacent thing while it is there. The owned set is the fence; the out-of-scope list is the sign on it.
- **The self-edited contract.** A builder that changes the design or a neighbour's S102 to make its own task consistent. The conflict was the finding; editing it away hid it.
- **State in the spec.** `passes: true`, checkboxes ticked, fix notes appended. The instruction and the run log become one file.

## 8. The checks

Asked of the S102 with the S101 and the design beside it. The verdict is the S101 reviewer's.

| # | Check | Tests |
|---|---|---|
| 1 | Does the header trace to an S101 task, match its task line (title, role, tier, after, traces), and name design ids? | Traceability |
| 2 | Is every path in `owns` exact, and does every modified file exist on disk or in the `owns.create` of a task this one comes after? | Scope |
| 3 | Is every name in `consumes` in the S101 §1, produced by a task this one comes after or linked as existing code, and every name in `produces` stated there as this task's? | Interface closure |
| 4 | Is every behaviour a scenario a test can be written from, with the rule's failing case, and free of private names; or does the task state it adds none and name its check? | Behaviour |
| 5 | Is every done-when a named test, a build or a command with its expected result, runnable, and none a search of the source for the spec's text? | Done-when |
| 6 | Are the stop conditions task-specific, and the generic ones not repeated? | Stops |
| 7 | Is the S102 free of method bodies, test code, steps, private structure and restated signatures? | Boundary |
| 8 | Is it free of placeholders, pasted existing code, copied S101 content and run state? | Hygiene |
| 9 | Could a builder finish it in one sitting (owned non-test files and scenarios against `s101-implementation-plan-definition.md` §8.1)? | Size |
| 10 | Does it contradict a global constraint in its S101, or state one that belongs there? | Inheritance |

Validation (`artifact-s102-validation`) is hard on shape and soft on content: it fails a missing header field, a path that does not resolve and is not created upstream, a consumed name with no producer, a placeholder, a done-when with no runnable form, a code block that is a body or a test, a done-when that greps the source. It does not judge whether the scenarios are the right ones. That is the reviewer's. The shape checks come first and are answered against a fixed, numbered checklist, so two runs on an unchanged file agree; the size check warns, never fails. The report is one row per check, Pass / Flag / Fail / Warn with one sentence, and nothing else: the skill edits nothing and proposes no fix. A place where the S102 had to work around a rule of the template is reported as a template finding in the sidecar (`s101-implementation-plan-definition.md` §9), not as a Fail.

## 9. Placement and naming

An S102 lives beside its S101 at `documentation/specs/<feature-slug>/S102-<feature-slug>-<NNN>-<task-slug>.md`, `<NNN>` the task's number in the S101 graph, counting from `001` inside the feature folder. For a plan cut from a normalised design the folder is the ticket key in kebab-case. Markdown body with YAML frontmatter; scenarios in Gherkin code fences, so validation can parse them. The path is a lockstep literal of hard rule 9, moved together with the S101's (`s101-implementation-plan-definition.md` §9).
