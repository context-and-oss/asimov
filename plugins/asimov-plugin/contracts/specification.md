# Contract: specification

What a specification must contain before anything is built from it. A specification is what the Spec stage hands over for one design, in whatever form it takes. It has two parts: **one plan**, which says what holds for the whole and how the work is ordered, and **one or more tasks**, each the brief for one unit of work that is built and verified on its own. This contract says what must be in them; not how they are written, where they live, or who reads them. Every member belongs to exactly one part: the *Scope* column says *plan* or *task*, and a plan member is stated once and holds for every task. The members and their weight come from the models surveyed in `documentation/research/specification-contract-research.md`; the *Grounded in* column names the models, the note holds what each of them says.

## Required members

| Member | Scope | Must say | Grounded in |
|---|---|---|---|
| **Reference** | plan | Which design it plans and which version of it: enough for a reader to open the same text later. The design meets `contracts/design.md`. | Spec Kit, Kiro, superpowers, ISO 29148 |
| **Order** | plan | Every task; what each depends on; which may run at the same time; and where the run can stop, with the check that holds there. | Spec Kit, Kiro, Beads, Shape Up, Mikado |
| **Coverage** | plan | Every id of the design in scope against the tasks that deliver it, and every task against the ids it serves. An id with no task says why. | ISO 29148, IEEE 1016, Spec Kit, superpowers |
| **Escalation** | plan | What stops a builder, and who rules. | Beads, Shape Up, Anthropic, Scrum |
| **Intent** | task | What the task delivers and why, traced to the design's ids. | IEEE 1016, Spec Kit, Kiro, Volere |
| **Scope** | task | The files the task may create, modify and test. Nothing else is touched. | superpowers, Spec Kit, Claude Code, Google |
| **Done-when** | task | How done is observed: a named test that passes, a build, a command and its expected result. Each checkable by running it. | Scrum, SMART tasks, Volere, ISO 29148, IEEE 829, SWE-bench, Claude Code |

## Members that are required when they exist

Each is stated, or the specification says *none*. Silence is a gap.

| Member | Scope | Must say | Grounded in |
|---|---|---|---|
| **Contracts** | plan | Every name one task produces and another consumes: class, method, parameter and return types, event, endpoint; each with its signature, once. | superpowers, IEEE 1016, Ousterhout, Design by Contract, Spec Kit |
| **Constraints** | plan | What every task must respect, verbatim from the design or the conventions, with the source. | ISO 29148, superpowers, Spec Kit, AGENTS.md |
| **Behaviour** | task | The observable behaviour the task adds, as scenarios a test can be written from, each rule with the case that fails. | Gherkin, Example Mapping, Cockburn, Design by Contract, ISO 29148 |
| **Task constraints and stop conditions** | task | What this task alone must do and must not do, and the conditions under which the builder stops and reports instead of deciding. | superpowers, SWE-agent, Anthropic, Cockburn |
| **Out of scope** | task | What a builder might think belongs to the task and does not, with the task or decision that owns it. | Claude Code, OpenSpec, Cockburn, Google |
| **Assumptions** | plan | Every decision taken without the author: the question, the options, the choice. | Spec Kit, ISO 29148, Example Mapping, Cockburn |

## Optional members

| Member | Scope | Must say, when present | Grounded in |
|---|---|---|---|
| **Review focus** | plan | The failure modes the design implies that no task's check exercises, each pinned to a task. | superpowers |
| **Tier** | task | The weight of judgement the task needs, as a recommendation the run may override. | XP, Shape Up |

## Rules

- **Names, not bodies.** A specification fixes the public names and signatures tasks share and the behaviour each task adds. Method bodies, private structure, production code and test code are the builder's. A body in a specification is a transcript, not a plan.
- **The check is described, not written.** Done-when names the test, the command and the expected result. The code of the test is written during the build, not in the specification.
- **One task, one sitting.** A task a builder cannot build and verify in one sitting is two tasks.
- **State it once.** Contracts, constraints and escalation are stated in the plan and referenced by every task, never copied into it.
- **Link, don't copy.** Existing code, conventions and the design by path or id; never pasted.
- **Traceable both ways.** Every task names the design ids it serves; every design id in scope names a task, or the reason it has none.
- **Complete, or not a specification.** A missing required member means nothing is built from it. The gap is fixed in the specification, never in the builder's head.
