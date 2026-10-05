# Research: what a specification must contain before building

> **Provenance.** Online research conducted 2026-10-05 to ground `plugins/asimov-plugin/contracts/specification.md`, the contract between the Spec and Build stages. Performed by a general-purpose subagent using WebSearch / WebFetch / curl; primary pages were read where reachable (raw GitHub files, PDFs via pdftotext), and ISO/IEC/IEEE 29148:2018 is cited from the standard's text where no public page carries the clause. Companion to [`design-contract-research.md`](design-contract-research.md) (2026-10-02), which asked what a design must hand over, and to [`S101-S102-spec-stage-research.md`](S101-S102-spec-stage-research.md) (2026-09-25), which asked how the field orders and parallelises tasks; its sources are reused here, its conclusions are not repeated.
>
> **What it informs.** The members of `contracts/specification.md`, their scope (plan or task), and the line between what the specification fixes and what the builder decides.

---

## 1. Question

A builder who never spoke to the author receives a specification: a plan for one design plus a brief per task, in whatever form. What must that specification contain so the builder can build it and know when it is done, according to models others have already argued for? And where do those models put the line between what the spec fixes and what the implementer decides: names and signatures, method bodies, private structure, the test itself?

## 2. Sources read

Fifteen traditions, plus the pages in §5:

| # | Source | What it prescribes (short) |
|---|---|---|
| 1 | INVEST and SMART tasks (Wake 2003); Scrum Guide 2020 | Story *Testable* ("I could write a test for it"), *Small*; task *Measurable*: "can we mark it as done?", "tests are included"; Developers plan "by decomposing Product Backlog items into smaller work items of one day or less"; Definition of Done is "a formal description of the state of the Increment"; "How this is done is at the sole discretion of the Developers" |
| 2 | ISO/IEC/IEEE 29148:2018; IEEE 1016-1998 (SDD) | 29148: a constraint is an "externally imposed limitation on the system, its design, or implementation"; each requirement carries a *Verification Method* attribute (Test, Demonstration, Inspection, Analysis) and traces up and down. 1016: ten design-entity attributes; *Interface* ("how other entities interact with this entity") in one view, *Processing* ("the algorithm used by the entity") and *Data* ("data elements internal to the entity") in the detailed design view "needed by programmers prior to implementation" |
| 3 | Specification by Example (Adzic); Gherkin `Rule`/`Example`; Example Mapping (Wynne); Cucumber "better Gherkin" | "An objective means to measure when a piece of work is complete"; a Rule groups "several scenarios that belong to this business rule"; red question cards mean not ready; "Your scenarios should describe the intended behaviour of the system, not the implementation" |
| 4 | Shape Up (Singer) | Scopes are "integrated slices" that "can be finished independently"; "Scope mapping isn't planning. You need to walk the territory before you can draw the map"; imagined vs discovered tasks; must-haves define done; "Done means deployed"; "Programmers write their own tests" |
| 5 | Kiro specs; GitHub Spec Kit | Kiro `tasks.md`: "Discrete, trackable tasks" with "Clear descriptions and expected outcomes", "Dependencies between tasks", "Optional vs required tasks"; `design.md`: "Data models and interfaces", "Error handling approach", "Testing strategy". Spec Kit: `[ID] [P?] [Story] Description`, "Include exact file paths in descriptions", `[P]` = "different files, no dependencies", phases with **Checkpoint** lines, "Tests are OPTIONAL", `contracts/` produced by `/plan` |
| 6 | OpenSpec (Fission-AI); Conductor (Google Labs) | OpenSpec: a change is `proposal.md` + `specs/` (requirement + `#### Scenario:` blocks) + `design.md` + `tasks.md` checklist; "A spec is a behavior contract, not an implementation plan"; "Avoid in specs: Internal class/function names". Conductor: `product.md`, `tech-stack.md`, `workflow.md`, per track `spec.md` + `plan.md` of "Phases, Tasks, and Sub-tasks" |
| 7 | obra/superpowers `writing-plans` (read 2026-10-05) | "What they cannot know is what you decided: which files, which names and signatures, which values from the spec, which tests prove each task. Document those"; per task *Files* (create/modify/test), *Interfaces* (Consumes/Produces, "exact signatures"), steps test-first with "the command to run and the output that means it passed"; header with Goal, Architecture, Spec path, Global Constraints, Review Focus |
| 8 | Beads (Yegge) | Issue fields `--title/--description/--design/--acceptance/--append-notes`; dependency types `blocks|tracks|related|parent-child|discovered-from`; `bd ready` = "tasks with no open blockers"; `bd lint` requires *Acceptance Criteria* on task, bug and feature; `bd gate create --type=human` blocks an issue on a person |
| 9 | Google (SWE book ch. 10; eng-practices *Small CLs*; *Modern Code Review*); Ousterhout | Design doc covers "goals of the design, its implementation strategy"; a small CL "makes a minimal change that addresses just one thing", "100 lines is usually a reasonable size"; at Google "the median number of lines modified is 24". Ousterhout: "The interface consists of everything that a developer working in a different module must know in order to use the given module", formal and informal |
| 10 | Design by Contract (Meyer) | Preconditions, postconditions, invariants; the routine states what it ensures ("Insert x so that it will be retrievable through key") and nothing about how; "These specifications (or contracts) govern the interaction of the element with the rest of the world" |
| 11 | Cockburn use cases; XP (Jeffries 3 Cs, task cards; Beck and Cunningham CRC) | *Scope*: "what system is being considered black-box under design"; *Level*: Summary / Primary task / Subfunction; success and failed end conditions; extensions. XP: "the card is a token representing the requirement", "The programmers break them down into tasks, and estimate their cost", the Customer "defines one or more automated acceptance tests"; CRC responsibilities are "short verb phrases, each containing an active verb" |
| 12 | Mikado Method; Beck "tidy first" (via Fowler) | A goal graph of prerequisites, "small, conquerable piece-meals", leaves first, revert what breaks; "for each desired change, make the change easy (warning: this may be hard), then make the easy change" as separate steps |
| 13 | Agent briefs: Claude Code docs (best practices, sub-agents), *Building effective agents*; agents.md and OpenAI AGENTS.md; SWE-bench / SWE-agent; Cursor rules; Aider conventions | "The most useful specs are self-contained: they name the files and interfaces involved, state what is out of scope, and end with an end-to-end verification step that proves the feature works"; a subagent "doesn't see your conversation history"; agents need "'ground truth' from the environment" and "stopping conditions". AGENTS.md: setup commands, code style, testing instructions, "Files closer to your current directory override earlier guidance". SWE-bench: `problem_statement`, `FAIL_TO_PASS`, gold `patch` withheld. Cursor: "Provide concrete examples", "Avoid vague guidance" |
| 14 | Change hygiene: Conventional Commits; SmartBear; Google small CLs; DORA | One type per commit, "make multiple commits whenever possible"; "Review fewer than 400 lines of code at a time"; "any batch of code that takes longer than a week to complete and check is too big", INVEST slicing, start "at the service or API layer" |
| 15 | Requirement to verification: 29148 verification method; Volere fit criterion; IEEE 829 / 29119-3 | Fit criterion: "A measurement of the requirement such that it is possible to non-subjectively test whether the solution fits the original requirement"; test design spec gives "test cases and the expected results as well as test pass criteria", procedure spec "how to run each test"; the test is described, not coded |

## 3. Cross-source count

How many of the fifteen traditions name the member as required, with the sources that carry the strongest wording. *Scope* says whether the member is stated once in the plan (and holds for every task) or once per task.

| Candidate member | Scope | Count | Strongest anchors |
|---|---|---|---|
| Done-when: a runnable or observable check | task | 13 | Scrum DoD; SMART "can we mark it as done?"; superpowers "the command to run and the output that means it passed"; Claude Code "Give Claude a check it can run: tests, a build, a screenshot"; SWE-bench `FAIL_TO_PASS`; Beads lint *Acceptance Criteria*; Volere fit criterion; 29148 verification method; IEEE 829 pass criteria; Adzic "objective means to measure"; XP confirmation; Shape Up must-haves; Spec Kit "Independent Test" |
| Behaviour as scenarios, with the failing case | task | 9 | Gherkin `Rule` + `Example`; Example Mapping; OpenSpec "Cover both happy path and edge cases"; Cockburn main scenario + extensions + failed end condition; DbC pre/postconditions; Kiro EARS criteria; Spec Kit Given/When/Then; 29148 abnormal responses; Claude Code "example test cases: ... is true, ... is false" |
| Size: one sitting, one change | task | 8 | Scrum "one day or less"; XP tasks; Google "100 lines is usually a reasonable size"; SmartBear "fewer than 400 lines"; DORA "longer than a week ... is too big"; superpowers "smallest unit that carries its own test cycle"; OpenSpec "one intent you can say in a sentence", "one focused session"; Conventional Commits one type per commit |
| Order, dependencies, parallelism | plan | 7 | Spec Kit `[P]` + phases + "Dependencies & Execution Order"; Beads `blocks` + `bd ready`; Kiro "Dependencies between tasks"; Conductor phases; superpowers Consumes from earlier tasks; Mikado leaves first; Shape Up "After Bucket Access is done we can implement Invite Clients" |
| Intent traced to design ids | task | 7 | Kiro "each task references requirements" (earlier note); Spec Kit `[Story]` label on every task; superpowers "which values from the spec"; IEEE 1016 *Purpose* "shall designate the specific functional and performance requirements for which this entity was created"; 29148 traceability; Volere; Beads `discovered-from` / `parent-child` |
| Interfaces between tasks: names and signatures | plan | 7 | superpowers Produces "exact function names, parameter and return types ... how they learn the names and types neighboring tasks use"; Spec Kit `contracts/`; Kiro "Data models and interfaces"; IEEE 1016 *Interface* attribute and interface description view; DbC; Ousterhout; Google design doc APIs |
| Global constraints | plan | 6 | superpowers "Global Constraints (exact values from spec)"; Spec Kit *Technical Context* + *Constitution Check*; 29148 design constraints; Conductor `tech-stack.md` / `workflow.md`; AGENTS.md / CLAUDE.md / Cursor / Aider conventions; Kiro technology stack |
| Reference to the design it plans | plan | 6 | superpowers "Spec path"; Spec Kit tasks "Input: Design documents"; Kiro three files per spec folder; OpenSpec one change folder; Conductor track `spec.md` + `plan.md`; Beads parent issue |
| Out of scope for the task | task | 6 | Claude Code "state what is out of scope", reviewer checks "nothing outside the task's scope changed"; Google "addresses just one thing"; OpenSpec one intent; Cockburn *Scope*; SWE-agent "minimal changes to non-tests files"; Shape Up ~ nice-to-haves |
| Owned file scope | task | 5 | superpowers *Files* Create/Modify/Test with line ranges; Spec Kit "Include exact file paths in descriptions", `[P]` = "different files"; Claude Code "name the files and interfaces involved"; Google small CL; agent teams "each teammate owns a different set of files" (earlier note) |
| Checkpoints | plan | 5 | Spec Kit "**Checkpoint**: ... fully functional and testable independently", "STOP and VALIDATE"; Shape Up scope done + hill chart; Conductor phases; superpowers commit + fresh review per task; Anthropic "stopping conditions" |
| Coverage of the design's ids | plan | 5 | superpowers self-review "Spec coverage: ... Can you point to a task that implements it?"; Spec Kit every task labelled by story; Kiro; 29148 bidirectional traceability; IEEE 1016 *Purpose* |
| Task-specific constraints and stop conditions | task | 5 | superpowers *Review Focus*; MinimumCD escalation triggers (earlier note); Anthropic stopping conditions; SWE-agent "you DON'T have to modify the testing logic or any of the tests"; Cockburn minimal guarantees |
| Escalation: who rules when a builder stops | plan | 4 | Beads `bd gate create --type=human --blocks`; Shape Up circuit breaker and betting table; superpowers rulings (earlier note); Scrum "sole discretion of the Developers" bounds what escalates |
| Assumptions taken without the author | plan | 4 | Spec Kit "NEEDS CLARIFICATION" markers and Assumptions; 29148 "shall be documented"; Example Mapping red cards; Cockburn open issues |

*Done-when* and *scenarios* are the near-universal task members; the agent-oriented sources add *files* and *out of scope* as their own strong requirement; *interfaces between tasks* and *order* are the plan members everybody with a plan layer carries. *Escalation* and *assumptions* are minority members with one strong anchor each.

### 3.1 The spec/implementation boundary

Where the surveyed models put the line between what the spec fixes and what the implementer decides. Quotes are verbatim from the pages in §5.

**(a) Public names and signatures.** Required at the plan/task level by the agent-oriented sources, fixed as the module boundary by the design traditions, and kept *out* of the requirements level by the behaviour traditions.

- superpowers: "What they cannot know is what you decided: which files, which names and signatures, which values from the spec, which tests prove each task. Document those." A code step carries "the exact signature (name, parameters, return type), the file it lives in, and the specific values the spec pins." The *Interfaces* block exists because "A task's implementer sees only their own task; this block is how they learn the names and types neighboring tasks use."
- Claude Code best practices: "The most useful specs are self-contained: they name the files and interfaces involved, state what is out of scope, and end with an end-to-end verification step that proves the feature works."
- Spec Kit: `contracts/` is a Phase 1 output of `/plan`; tasks "Include exact file paths in descriptions". Kiro `design.md`: "Data models and interfaces".
- IEEE 1016 *Interface*: "A description of how other entities interact with this entity. The interface attribute shall describe the methods of interaction and the rules governing those interactions." The interface description view carries "identification, function, and interfaces" and "should be provided for all design entities."
- Ousterhout: "The interface consists of everything that a developer working in a different module must know in order to use the given module." Lecture notes: the interface is "anything about the module that must be known to other modules", formal (signatures) and informal (behaviour, ordering, side effects).
- Design by Contract: "These specifications (or contracts) govern the interaction of the element with the rest of the world."
- Against, at the requirements level: OpenSpec "Avoid in specs: Internal class/function names; Library or framework choices; Step-by-step implementation details; Detailed execution plans (those belong in `design.md` or `tasks.md`)." Cucumber: "if your wording would need to change whenever the implementation changes, rework it". Scrum: "No one else tells them how to turn Product Backlog items into Increments of value."

Reading: every source that *hands work to someone who cannot ask* fixes the names at the boundary between tasks; every source that *describes behaviour* keeps them out of the behaviour statement. The two positions do not conflict: they are two levels.

**(b) Method bodies and code.** No surveyed source requires code in the brief; one allows it as the exception; several withhold it on purpose.

- superpowers (the counter-position named in the question, as the skill reads on 2026-10-05): "The implementer writes the body. A body appears only for an algorithm the signature and tests do not determine, or for exact copy the spec fixes." And: "A plan longer than the code it describes has written the code instead." Self-review: "a function body the signature and tests already determine is a transcript. Fix both." The `S101-S102-spec-stage-research.md` note (2026-09-25) recorded the earlier shape, "steps with the actual code"; the skill has since moved the line to signatures plus tests.
- IEEE 1016 *Processing*: "A description of the rules used by the entity to achieve its function. The processing attribute shall describe the algorithm used by the entity to perform a specific task ... It is the most detailed level of refinement for this entity." It sits in the detailed design description, "the details needed by programmers prior to implementation", a separate view from the interface description. The standard allows an algorithm in the design, in its own view, and does not require it.
- SWE-bench withholds the solution: `patch` is the "Gold solution patch (don't look at this if you're trying to solve the problem)". The agent gets `problem_statement` and the repo.
- Beck and Cunningham: responsibilities are "a handful of short verb phrases, each containing an active verb"; the cards omit "details such as syntax".
- Shape Up: "Scope mapping isn't planning. You need to walk the territory before you can draw the map." "The team naturally starts off with some imagined tasks ... Then, as they get their hands dirty, they discover all kinds of other things that we didn't know in advance."
- Scrum: "How this is done is at the sole discretion of the Developers."

Reading: the body is the builder's. The one source that once put code in the plan now treats a determined body as a defect ("a transcript") and keeps code only where signature plus test leave the algorithm open.

**(c) Private structure.** Hidden by the design traditions; the file layout is nevertheless fixed by the agent-oriented sources, because files are the unit of parallel ownership.

- Ousterhout, information hiding: each module "should encapsulate certain knowledge or design decisions" that "is only known to the one module" and "the interface does not reflect this information (much)."
- IEEE 1016 *Data*: "A description of data elements internal to the entity", detailed design view only.
- OpenSpec, quick test: "If implementation can change without changing externally visible behavior, it likely does not belong in the spec."
- Cockburn *Scope*: "what system is being considered black-box under design".
- Counter-position on files: superpowers *File Structure* "Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in." Spec Kit: `[P]` tasks are "different files, no dependencies"; the validation list warns against "same-file conflicts". Google: a small CL "includes related test code" and "addresses just one thing".

Reading: internals below the file are the builder's; the file set is the plan's, not as design but as the ownership unit that makes parallel work and review possible.

**(d) The test code vs the test described.** The requirement traditions describe the check and name its method; superpowers writes the assertions; the benchmark withholds the test and names it.

- Volere: fit criterion is "A measurement of the requirement such that it is possible to non-subjectively test whether the solution fits the original requirement." The measure, not the test.
- 29148: each requirement carries a *Verification Method*, "Test, Demonstration, Inspection or Analysis". IEEE 829: the test design specification describes "test cases and the expected results as well as test pass criteria"; the procedure specification "how to run each test, including any set-up preconditions and the steps".
- Cucumber: "Your scenarios should describe the intended behaviour of the system, not the implementation." Adzic's pattern 12 is "Automating validation without changing specifications": the automation is layered under the scenario, never written into it.
- superpowers: "A test step: the test's name and its assertions, as code, with the spec's exact values in them." A verification step is "the command to run and the output that means it passed."
- Spec Kit: "Tests are OPTIONAL - only include them if explicitly requested in the feature specification"; when included, "Tests (if included) MUST be written and FAIL before implementation", as tasks with file paths.
- SWE-bench / SWE-agent: `FAIL_TO_PASS` names the tests that must turn green; the agent is told "I've already taken care of all changes to any of the test files ... you DON'T have to modify the testing logic or any of the tests in any way!"
- Claude Code: "write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing".
- XP: the Customer "defines one or more automated acceptance tests to show that the feature is working"; Shape Up: "Programmers write their own tests".

Reading: everyone fixes *what the check is* (named test, command, expected result, pass criterion). Only superpowers writes the assertions into the brief; the standards, Cucumber and Adzic deliberately keep the scenario above the test code; SWE-bench shows that naming the test, without handing it over, is enough for a builder to know when it is done.

## 4. Decisions

Taken 2026-10-05, after the first real `asimov-spec` run (a Backend ticket cut into eleven tasks) showed every task carrying full method bodies and test classes, acceptance criteria that grepped the spec's own code, and private method names fixed as contract. The format had followed the validator; the contract is written so the format can follow the contract instead.

| Decision | Choice | Why |
|---|---|---|
| **One contract for the whole handover of one design** | One file, members marked *plan* or *task* | S101 plus S102s is one form of it; D100 names one `specification.md`. Every plan-layer source (Spec Kit, Kiro, Conductor, OpenSpec, superpowers) carries both levels in one artefact |
| **The boundary: names and signatures are the specification's, bodies are the builder's** | A rule, *Names, not bodies*: public class, method, parameter and return names and types, events and endpoints are fixed; method bodies, private structure, production code and test code are not | §3.1 (a) and (b): every source that hands work to someone who cannot ask fixes the names at the task boundary, and no source requires code. The one source that put code in the plan (superpowers, as the 2026-09-25 note read it) now calls a determined body "a transcript" and writes "The implementer writes the body" (upstream `main`, verified 2026-10-05; the installed 6.4.1 copy still has the earlier shape). IEEE 1016 keeps *Processing* in its own view, allowed and never required |
| **No exception for mechanical changes** | Rejected | The exception was the gradient: a planner model can always write the code, so "code where it is transcription" became code everywhere, and tiers, test-first and the builder/tester split lost their meaning. A one-line change is a one-line task with a name and a check, not a pasted line |
| **The check is described, not written** | A rule: done-when names the test, the command and the expected result; the test's code is written during the build | §3.1 (d): Volere, 29148, IEEE 829, Cucumber and Adzic all fix the measure and keep the test code below the specification; SWE-bench shows naming the tests is enough to know when done. Only superpowers writes assertions into the brief |
| **Done-when is a required task member** | Kept, runnable | 13 of 15; the near-universal member |
| **Behaviour: required when the task adds any, "none" said explicitly** | Changed from always-required | 9 of 15, but a skeleton or a wiring task adds no behaviour, and forcing scenarios on it produced "it compiles" in Gherkin. An explicit *none* keeps the reader from guessing and the validator from counting fiction |
| **Scope (owned files) is a required task member** | Kept | 5 of 15, all agent-oriented; §3.1 (c): internals below the file are the builder's, the file set is the ownership unit that makes parallel work and review possible |
| **Order, with checkpoints folded in** | One member: dependencies, what may run together, and where the run can stop with the check that holds there | 7 and 5 of 15 with the same anchors (Spec Kit phases + `[P]` + Checkpoint, Shape Up scopes); a one-task plan has one stop, its done-when |
| **Coverage both ways is required** | Kept | 29148 bidirectional traceability; the plan's bar depends on it |
| **Escalation is required** | Kept, though 4 of 15 | It is what makes "cannot ask the author" workable: Beads blocks an issue on a person, Shape Up names the circuit breaker, Anthropic asks for stopping conditions. Scrum's "sole discretion of the Developers" bounds what escalates: the how never does |
| **Contracts (names between tasks): required when they exist** | "none" allowed | 7 of 15; a one-task plan produces nothing another task consumes |
| **Global constraints: required when they exist** | "none" allowed | 6 of 15; a small fix may inherit everything from the conventions |
| **Task constraints and stop conditions, out of scope, assumptions: required when they exist** | "none" allowed | Minority members with one strong anchor each; silence must not be read as absence |
| **Size is a rule, not a member** | *One task, one sitting* | 8 of 15, but a measure of the cut, not content a builder reads; Scrum one day, Google ~100 lines, SmartBear 400, DORA a week |
| **Review focus and tier: optional** | Kept as optional members | Review focus is superpowers' alone; tier is the plan's recommendation of judgement needed, grounded in XP's task estimate, and the run may override it |
| **Intent is a required task member** | Kept, traced to design ids | 7 of 15; IEEE 1016 *Purpose* "shall designate the specific functional and performance requirements for which this entity was created" |
| **Who writes the test is not a member** | Form, not contract | XP's customer tests and Shape Up's "programmers write their own tests" disagree; the contract fixes that the check is named and described, and leaves the writer to the form |

## 5. Sources

Fetched 2026-10-05 unless noted. Raw GitHub files were read in full via curl; PDFs via pdftotext.

- Bill Wake, INVEST in Good Stories, and SMART Tasks: https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/
- Scrum Guide 2020: https://scrumguides.org/scrum-guide.html
- ISO/IEC/IEEE 29148:2018: standard text; public attribute list at https://www.reqview.com/doc/iso-iec-ieee-29148-templates/ (ISO OBP preview https://www.iso.org/obp/ui?_escaped_fragment_=iso%3Astd%3Aiso-iec-ieee%3A29148%3Aed-2%3Av1%3Aen returned 403)
- IEEE Std 1016-1998, §5.3 and §6.2 (PDF): https://people.eecs.ku.edu/~saiedian/Teaching/Stds/1016.pdf
- Gojko Adzic, Specification by Example, ch. 1 (PDF): https://manning-content.s3.amazonaws.com/download/0/e31349c-e7f9-457d-834d-3a29e71e9136/adzic_ch01.pdf (via https://gojko.net/books/specification-by-example/)
- Cucumber, Gherkin reference: https://cucumber.io/docs/gherkin/reference/
- Cucumber, Writing better Gherkin: https://cucumber.io/docs/bdd/better-gherkin/
- Matt Wynne, Example Mapping: https://cucumber.io/blog/bdd/example-mapping-introduction/
- Shape Up, Get One Piece Done (ch. 11): https://basecamp.com/shapeup/3.2-chapter-11
- Shape Up, Map the Scopes (ch. 12): https://basecamp.com/shapeup/3.3-chapter-12
- Shape Up, Show Progress (ch. 13): https://basecamp.com/shapeup/3.4-chapter-13
- Shape Up, Decide When to Stop (ch. 14): https://basecamp.com/shapeup/3.5-chapter-14
- Shape Up, Hand Over Responsibility (ch. 10): https://basecamp.com/shapeup/3.1-chapter-10
- Kiro, Specs: https://kiro.dev/docs/specs/ and https://kiro.dev/docs/specs/feature-specs/requirements-first/ (https://kiro.dev/docs/specs/concepts/ returned 404; best-practices page carried no task rules)
- GitHub Spec Kit, tasks template: https://raw.githubusercontent.com/github/spec-kit/main/templates/tasks-template.md
- GitHub Spec Kit, plan template: https://raw.githubusercontent.com/github/spec-kit/main/templates/plan-template.md
- OpenSpec README: https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/README.md
- OpenSpec, Concepts: https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/docs/concepts.md
- OpenSpec, Writing Good Specs: https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/docs/writing-specs.md
- Conductor (Google Labs) announcement: https://developers.googleblog.com/conductor-introducing-context-driven-development-for-gemini-cli/ (https://github.com/google-labs-code/conductor returned 404)
- obra/superpowers, writing-plans skill: https://raw.githubusercontent.com/obra/superpowers/main/skills/writing-plans/SKILL.md
- Beads README: https://raw.githubusercontent.com/steveyegge/beads/main/README.md
- Beads AGENTS.md: https://raw.githubusercontent.com/steveyegge/beads/main/AGENTS.md
- Beads CLI reference: https://raw.githubusercontent.com/steveyegge/beads/main/docs/CLI_REFERENCE.md
- Software Engineering at Google, ch. 10 Documentation: https://abseil.io/resources/swe-book/html/ch10.html
- Google eng-practices, Small CLs: https://google.github.io/eng-practices/review/developer/small-cls.html
- Sadowski et al., Modern Code Review: A Case Study at Google (PDF): https://storage.googleapis.com/gweb-research2023-media/pubtools/4476.pdf
- Ousterhout, CS190 Modular Design lecture notes: https://web.stanford.edu/~ouster/cgi-bin/cs190-winter18/lecture.php?topic=modularDesign (book page https://web.stanford.edu/~ouster/cgi-bin/book.php has no chapter text; the ch. 4 sentence is confirmed via web search of reader notes)
- Eiffel, Design by Contract introduction: https://www.eiffel.com/values/design-by-contract/introduction/
- Alistair Cockburn, use case template: https://www.cs.otago.ac.nz/coursework/cosc461/uctempla.htm (https://alistair.cockburn.us/coaching/use-case-fundamentals/ returned 404)
- Ron Jeffries, Card, Conversation, Confirmation: https://ronjeffries.com/xprog/articles/expcardconversationconfirmation/
- Ron Jeffries, What is Extreme Programming: https://ronjeffries.com/xprog/what-is-extreme-programming/ (http://www.extremeprogramming.org/rules/iterationplanning.html failed on a certificate error; https://wiki.c2.com/?TaskCard renders by script only)
- Beck and Cunningham, A Laboratory for Teaching Object-Oriented Thinking (CRC): https://c2.com/doc/oopsla89/paper.html
- Mikado Method: https://mikadomethod.info/
- Martin Fowler, An example of preparatory refactoring (quotes Beck's "make the change easy"): https://martinfowler.com/articles/preparatory-refactoring-example.html (https://newsletter.kentbeck.com/p/tidy-first returned 404)
- Claude Code, Best practices: https://code.claude.com/docs/en/best-practices
- Claude Code, Subagents: https://code.claude.com/docs/en/sub-agents
- Anthropic, Building effective agents: https://www.anthropic.com/research/building-effective-agents
- agents.md: https://agents.md/
- OpenAI, AGENTS.md for Codex: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- SWE-bench datasets guide: https://www.swebench.com/SWE-bench/guides/datasets/
- SWE-agent command-line tutorial: https://swe-agent.com/latest/usage/cl_tutorial/
- Cursor, Rules: https://cursor.com/docs/context/rules
- Aider, Specifying coding conventions: https://aider.chat/docs/usage/conventions.html
- Conventional Commits 1.0.0: https://www.conventionalcommits.org/en/v1.0.0/
- SmartBear, Best practices for peer code review: https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/
- DORA, Working in small batches: https://dora.dev/capabilities/working-in-small-batches/
- Volere, Atomic Requirements (PDF): https://www.volere.org/wp-content/uploads/2018/12/06-Atomic-Requirements.pdf; field list at https://www.reqview.com/doc/volere-template/
- IEEE 829 / ISO/IEC/IEEE 29119-3 outline: https://en.wikipedia.org/wiki/Software_test_documentation
- IEEE 1016 viewpoints outline: https://en.wikipedia.org/wiki/Software_design_description

Reused from `S101-S102-spec-stage-research.md` without re-fetching: MinimumCD escalation triggers, Claude Code agent teams file ownership, superpowers rulings and the task-size evidence table (§8 there).
