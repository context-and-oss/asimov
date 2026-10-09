---
artifact: s102-task-spec
maturity: assess
since: 2026-09-25
---

# Definition of S102

The written standard an S102 (task spec) must meet before a build subagent is dispatched on it. An S102 is one task: the brief a fresh builder receives, sized to be built in one sitting without asking a human, validated blind by a reader that never saw the conversation, and verifiable afterwards against the code it produced. It is the **task** part of a specification as `contracts/specification.md` defines it; the S101 (`s101-implementation-plan-definition.md`) is the **plan** part that orders the tasks.

Read by the build subagents as their whole brief, by Powell, the verifier, as the checks to run, by the person who wants to know what the agent was told, and at run-time by the asimov-skills `asimov-spec` and `asimov-spec (re-check)` through the artifact skills `artifact-s102-authoring` and `artifact-s102-validation`.

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
- every name the task consumes is in the S101's contracts, produced by a task this one comes after, or is existing code the header links by path and the repo resolves;
- the behaviour it adds is stated as scenarios a test can be written from, or the task says it adds none;
- every done-when is checkable by running something and reading the result;
- the stop conditions name what halts the builder beyond the generic ones;
- nothing is left as a placeholder, and nothing is pre-written that the builder owns (§5).

The bar is **validated blind** right after the S102 is written: a fresh subagent with no conversation history, given only the S102, its S101 and the design, answers the checks of §8 as shape questions (§8) and reports. Blind means no conversation; the repo is consulted only to look a name or a path up, never read or run. The model that wrote the S102 has the conversation in context and leaves a key, a path or a name out without noticing; a fresh reader that must find each one in a file notices. An S102 that fails is rewritten and validated again; a third failure, or a finding that names a gap in the design rather than in the S102, stops the run and is reported instead of rewritten. A clean report is the S102's approval: `asimov-spec` marks the file `validated` with the date (§6), no person is asked to approve a task spec, and the S101's check 1 reads those marks. The builder itself does not judge the bar; it builds or it stops.

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
| Scope | the header's `owns` (create, modify, test, regenerates); the only home of the owned set |
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

- **`owns`**: the files the task may create, modify and test, as repo-relative paths or globs (`src/Services/Export/**` for a folder the task owns whole), and the files it **regenerates**. Together they are the task's owned set and the only place it is stated; the S101 reads it for disjointness. `test` holds every test file the task creates or modifies; `create` and `modify` hold non-test files the builder edits by hand, so a tester task that extends an existing test class lists it under `test` and leaves `modify` empty. `regenerates` holds what a build, a restore or a generator rewrites as a consequence of those edits and nobody edits by hand: lock files after a package change, a generated client after a schema change, a snapshot after a rendering change. It may hold globs (`**/packages.lock.json`), because the set is derived and enumerating it is the tool's job; it counts toward no size threshold and takes no part in disjointness, because the regenerating command is idempotent over the hand-edited files and two tasks may both run it. The builder never opens a regenerated file: it runs the command and reports when the result is not what the task implies. A generated file listed under `modify` tells a builder to edit by hand what only a tool should write; one listed nowhere leaves the Build stage a dirty tree it cannot commit. Anything outside the set is out of scope for this task, and a builder that needs to touch a file outside it has hit a stop condition, not a judgement call.
- **`consumes`**: every name this task relies on, and the only record of who consumes what (the S101 §1 names producers, never consumers). A name another task produces is spelled as the S101 §1 Contracts spells it and its producer is a task this one comes after; the signature lives there and the S102 never restates it. Existing code is written `<Name> (<repo-relative path>)`: it has no row in §1 and needs none, because validation opens the path and finds the member. A type that comes from a package rather than a file is written `<Name> (package <PackageId>)`, and validation resolves it against the package reference of the project the owned files belong to. A member of a consumed type (an enum value, a method on the type) is covered by the type's entry and is not listed on its own. A test is never consumed: the builder's done-when names the tester's tests (§4.4). A consumed name with no producer in §1, no member at its path and no package reference is a plan defect (`s101-implementation-plan-definition.md` §4.5); the builder stops, it does not invent.
- **`produces`**: every name a later task will rely on, spelled as the S101 §1 spells it. The S101 fixed the signature at planning time so neighbours agree before either exists.

### 4.2 Intent

One or two sentences: what this task delivers and why the feature needs it, in the design's words. A builder that understands the intent makes the right call on the one thing the spec forgot; one that does not, guesses. The reason, never the recipe.

### 4.3 Behaviour

The observable behaviour the task adds, as scenarios a test can be written from: given a state, when an action, then an outcome. Gherkin in fenced code blocks, one scenario per behaviour, so validation can count them and a tester can lift them. A rule carries its counter-example as its own scenario, as the D101 does (`d101-feature-design-definition.md` §6.3). The scenarios describe what the system does, never how: no class, method or private name appears in a scenario unless it is a public name from the S101 §1 or existing code the header consumes. A scenario pinned from the S101 §5 Review focus carries the Gherkin tag `@review-focus` on the line above its `Scenario:` and is not counted toward the size threshold (`s101-implementation-plan-definition.md` §8.1). In a slice the pin names the tester, which carries the line as one tagged scenario among the slice's others; the builder's one-line §2 (below) covers it, and the tag is never a reason to write the scenario twice.

A task that adds no observable behaviour (a skeleton, a registration, a reference switched, a release) says so in one line and names what its check is instead. A scenario about compiling or about a file's text is not a behaviour.

**In a slice, the tester carries the scenarios.** The tester task's §2 holds every scenario of the slice, each rule with its failing case; that is the slice made concrete, and its threshold is the tester's (`s101-implementation-plan-definition.md` §8.1). The builder task of the same slice does not restate them: its §2 is one line, `as T<nnn>: the scenarios of this slice's tester task`, naming the tester it comes after, followed only by a scenario the tester does not carry (normally none). Two copies of ten scenarios are twenty lines to keep in step and one more Warn per task; the reference is what the builder reads anyway, because its done-when names the tester's tests.

### 4.4 Done-when

Numbered, each checkable by running something and reading the result: a named test that passes, a build that is green, a command whose output matches. The test is named and its expected outcome stated; its code is not here (`contracts/specification.md`, *the check is described, not written*). **A test is named by its class and its scenario, never by its method.** The test class is the spec's (it is a file in `owns.test`, written as a code span); the method names are the builder's, as every name inside a body is (`contracts/specification.md`, *every body and test the builder's*), so no spec fixes them. For a tester task, done-when says which test class exists, or which existing class gained tests, one per scenario of §2 listed by scenario title, and what state they are in (red against the Foundation or the existing code, or green). For a builder task, done-when names the tester's task id and its test class in the same code span, says the tests that task adds for the slice's scenarios are green, and names no method. That reference is the only place a builder names a test: a test is never a contract row and never a `consumes` entry.

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

### 4.7 The light form, for a `low` task

The contract has a ceiling (*one task, one sitting*) and this definition gives it a floor. A task whose tier is `low` is, by the S101 definition §5, fully determined by the names, the signatures and the check: a version bump, a registration, a one-line read, the deletion of a dead method, a skeleton. Its S102 is the **light form**: the header complete (§4.1, the owned set above all, because the Build stage dispatches, reviews, verifies and commits by it), §1 one sentence, §2 the `none:` line naming the check, §3 the done-when, §4 and §5 *none* unless the task has a stop or a boundary of its own. Nothing else, and no section opened to fill it. It is the same file with the same shape check (§8); what changes is who writes it and when: the `low` tasks of a plan are written together, by one writer in one call after the go, instead of one writer per task. The first ticket-sized runs spent two writers, two validators and a re-cut on a task spec of 126 lines for a one-line change; the floor is where that stops. A task that turns out to need behaviour in prose was not `low`; the writer reports it, and the plan's tier is wrong, not the form.

## 5. Rules

- **Names, not bodies.** The S102 names public classes, methods, parameters and types as the S101 §1 spells them, and states behaviour. It carries no method body, no private structure, no test code and no steps. A body in a task spec is a transcript, not a brief; the builder writes it.
- **The check is described, not written.** Done-when names the test and its outcome, the build, the command and its output. Never the test's code; never a search of the source for the spec's own words.
- **No placeholders.** A placeholder is a decision the specification owns and left open: a missing path, a name no contract defines, a behaviour "to be handled", a done-when that cannot run, "similar to task N" with no content. A missing body is not a placeholder; it is the builder's work.
- **Own your files; stop at the edge.** The builder changes only the owned set, by hand what `create`, `modify` and `test` list and through the tool what `regenerates` lists. Needing a file outside it is a stop.
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
| 2 | Is every path in `owns` exact (a glob only under `regenerates`), does every modified file exist on disk or in the `owns.create` of a task this one comes after, and is no generated file listed as hand-edited? | Scope |
| 3 | Is every name in `consumes` either a §1 row produced by a task this one comes after, existing code whose member exists on disk at the path the header gives, or a package type the project references; and is every name in `produces` stated in §1 as this task's? | Interface closure |
| 4 | Is every behaviour a scenario a test can be written from, with the rule's failing case, and free of private names; or does the task state it adds none and name its check; or, for a slice's builder, does it name its tester's scenarios? | Behaviour |
| 5 | Is every done-when a named test, a build or a command with its expected result, runnable, and none a search of the source for the spec's text; and does a builder's name the tests its tester's done-when lists? | Done-when |
| 6 | Are the stop conditions task-specific, and the generic ones not repeated? | Stops |
| 7 | Is the S102 free of method bodies, test code, steps, private structure and restated signatures? | Boundary |
| 8 | Is it free of placeholders, pasted existing code, copied S101 content and run state? | Hygiene |
| 9 | Could a builder finish it in one sitting (owned non-test files and scenarios against `s101-implementation-plan-definition.md` §8.1)? | Size |
| 10 | Does it contradict a global constraint in its S101, or state one that belongs there? | Inheritance |

Validation (`artifact-s102-validation`) is a **shape check**, the way a JSON file is checked against its schema: it reads the file's text and looks things up (a key is present, a path exists, a name is declared in the file the header points at, an id is in the design, a test name matches the tester's list, a count is under a threshold), and it never runs a build or a test and never reads the code's logic. It fails a path that does not resolve and is not created upstream, a consumed name with no producer and no home on disk, a placeholder, a done-when with no runnable form, a code block that is a body or a test, a done-when that greps the source, a constraint contradicted. It does not judge whether the scenarios are the right ones, whether a test would pass today, or whether the task fits one sitting: the author judges the cut, the reviewer judges the PR, the verifier runs the code after the build. The first runs let the validator walk the codebase like a builder and run the tests; that doubled the cost of every check and made two validators disagree, and the one content defect it found belongs to the author's read of the cut, not to a format check. **A Fail means a builder would be stuck or build the wrong thing.** A defect the run should know about but that would stop no builder (a header entry missing for a name that resolves anyway through a type the header already consumes, a date left over, a stop that paraphrases a generic one, a constraint restated) is a Flag, whatever row it falls under; a Flag never costs a rewrite. The shape checks come first and are answered against a fixed, numbered checklist, so two runs on an unchanged file agree; the size check warns, never fails. The two checks that compare wording (6 Stops, 10 Inheritance) are answered by matching subject and value against the S101 and the generic stops, never by impression, so two validators agree on them too. The report is one row per check, Pass / Flag / Fail / Warn with one sentence, and nothing else: the skill edits nothing and proposes no fix. The check is a script (`scripts/validate-s102.ps1`) and costs a second, so the authoring skill runs it on its own output before returning and fixes what it can; the caller's run of the same script is the record that marks the file validated. A format Fail that reaches the caller used to cost a writer round; now it is the exception. A place where the S102 had to work around a rule of the template is reported as a template finding in the sidecar (`s101-implementation-plan-definition.md` §9), not as a Fail.

## 9. Placement and naming

An S102 lives beside its S101 at `documentation/specs/<feature-slug>/S102-<feature-slug>-<NNN>-<task-slug>.md`, `<NNN>` the task's number in the S101 graph, counting from `001` inside the feature folder, and `<task-slug>` three to five words of the task's title in kebab-case, never the whole title (a title is short by the S101 definition §4.3, and a file name is found by its number). For a plan cut from a normalised design the folder is the ticket key in kebab-case. Markdown body with YAML frontmatter; scenarios in Gherkin code fences, so validation can parse them. The path is a lockstep literal of hard rule 9, moved together with the S101's (`s101-implementation-plan-definition.md` §9).
