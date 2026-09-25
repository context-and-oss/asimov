# S101 / S102 spec-stage research

**Date:** 2026-09-25. **Status:** decisions taken; definitions written at `assess`; templates, commands and the Spec-stage D101 pending.

Companion to [`L3-spec-format-research.md`](L3-spec-format-research.md), which researched the *format* of a single spec (MinimumCD's five artifacts, Markdown over JSON, the validator's authority). This note researched the *layer above it*: how the field orders, parallelises and hands out the tasks a design produces, and what that means for Asimov's Spec stage. It revises two of the earlier note's locked decisions (§5).

## 1. The question

A D101 rarely fits one agent sitting. Something has to say which tasks it becomes, in what order, what may run in parallel, what each hands to the next, and where the run may stop. The working idea going in: *a D101 becomes one plan and many task specs; the task spec describes one job to one agent precisely; the plan describes order and parallelism.* The research checked whether the field agrees, what each layer has to carry, and where Asimov's earlier decisions needed revisiting.

## 2. What the field converged on

Every serious framework has three layers. The names differ; the split does not.

| Layer | Spec Kit | Kiro | OpenSpec | Conductor (Google) | superpowers | Asimov |
|---|---|---|---|---|---|---|
| What, and the contracts | `spec.md` + `plan.md` | `requirements.md` (EARS) + `design.md` | `proposal.md` + `specs/` + `design.md` | `spec.md` | brainstorm → spec | **D101** |
| Order, phases, parallelism | `tasks.md` with `[P]` | `tasks.md` with requirement refs | `tasks.md` | `plan.md` (phases › tasks › sub-tasks) | plan document | **S101** |
| One task for one agent | one line in `tasks.md` | one checkbox | one checkbox | one sub-task | one `### Task N` block | **S102** |

Two frameworks make the task a first-class object of its own rather than a line in a list: **Beads** (one issue per node in a dependency graph; `bd ready` computes claimable work) and **Claude Code agent teams** (a shared task list with `blockedBy` edges; teammates claim unblocked tasks). Asimov's S102-as-a-file sits with those two. The argument for it is superpowers' own: *"a task's implementer sees only their own task"*, which is why its plan format carries an explicit Consumes/Produces block per task. An S102 is the prompt a fresh builder receives, and nothing else.

Every format is **Markdown body + YAML frontmatter**. The one JSON hold-out is Anthropic's long-running-agent harness, which keeps the *state* file (`feature_list.json`) in JSON because "the model is less likely to inappropriately change or overwrite JSON files compared to Markdown files", and permits the agent to edit only the `passes` field. Ralph's `prd.json` does the same. That is an argument about the *ledger*, not the spec.

## 3. What the plan layer has to carry

Drawn from the corpus; each item maps to a section of `s101-implementation-plan-definition.md`.

- **A graph, not a list.** Spec Kit's `[P]` marker is the minimal form: "different files, no dependencies on incomplete tasks". Beads and agent teams have real edges and compute readiness from them. The parallelism criterion is the same everywhere: disjoint file sets and no open blockers. Agent teams add: "two teammates editing the same file leads to overwrites; break the work so each teammate owns a different set of files." → S101 §4.3.
- **Phases with checkpoints.** Spec Kit: Setup → Foundational ("MUST be complete before ANY user story") → one phase per story, each "independently completable and testable" → Polish. Conductor reverts by logical unit (track, phase, task), not by commit hash. → S101 §4.4.
- **Interfaces between tasks.** superpowers' Consumes/Produces with exact signatures, "how they learn the names and types neighboring tasks use". → S101 §4.5.
- **Global constraints and review focus, once.** superpowers' plan header carries both: constraints "copied verbatim from the spec", and "the five input classes or failure modes the spec implies but no task's tests exercise". → S101 §4.2, §4.6.
- **Model tier per task.** superpowers' rule: a task whose plan text contains the code is transcription and takes the cheapest tier; prose tasks take a mid tier; design and the final review take the most capable; "turn count beats token price". → S101 §5, aligned with `model-choice.md`.
- **Execution mode.** superpowers: subagent-driven (fresh implementer + fresh reviewer per task, whole-branch review at the end) versus native (one session, one final reviewer). Claude Code: subagents (report back) versus agent teams (shared task list, peer messaging; "start with 3–5 teammates", "5–6 tasks per teammate"). → S101 §4.1.
- **A ledger, separate from the plan.** superpowers keeps a gitignored `progress.md` per plan and warns that controllers that lost their place "have re-dispatched entire completed task sequences, the single most expensive failure observed". Anthropic and Ralph keep state in the JSON list. Asimov already has the pattern: `/d101-review`'s `.review.md` cache. → S101 §3, §7.

## 4. What the task layer has to carry

- **superpowers' task shape**: Files (create / modify with line ranges / test), Interfaces, steps with the actual code, test first with expected output, commit. And the rule: *no placeholders*: never "TBD", "add appropriate error handling", "write tests for the above" without the test, "similar to Task N". → S102 §4.3–4.7, §5.
- **MinimumCD's five artifacts** (already in the earlier note): intent, Gherkin scenarios, Musts / Must nots / Preferences / **Escalation triggers**, acceptance criteria, system constraints. → S102 §4.2, §4.5, §4.6, §4.8.
- **Kiro's traceability**: every task names the requirement ids it serves. → S102 §4.1, S101 §4.8 coverage map.
- **Sizing, three independent formulations of one rule**: "small enough to complete in one context window" (Ralph); "if your specification effort for a single change takes more than 15 minutes, the change is too large" (MinimumCD); "the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate" (superpowers). → S102 §5.
- **Escalation, two schools.** MinimumCD: an agent "cannot resolve that conflict by modifying the artifact it does not own"; it halts. superpowers: "Rulings, not stalls": the controller decides, records `Ruling: what / why / cost if wrong` in the ledger, and continues; only four things reach a human (irreversible or destructive; security-sensitive; side effect outside the worktree; a plan where every path is a guess). Asimov takes both: the *builder* never edits what it does not own and stops (MinimumCD); the *S101* names who rules and the ledger records it (superpowers). → S102 §5, S101 §4.7.

## 5. Decisions taken 2026-09-25

| Decision | Choice | Why |
|---|---|---|
| **Two documents, not one** | S101 implementation plan + N × S102 task spec | The field's plan/task split; the S102 as a separate file because it is the builder's whole context |
| **Codes** | `S101` plan, `S102` task | The second digit already means granularity in this repo: D100 system, D101 feature. A feature-scoped `S100` would break it. S101 (feature) → S102 (task) reads the same way, and the pipeline reads D101 → S101 → S102 → code. **Revises** the earlier note, which rejected the `S101-*` family on lifecycle grounds; that objection is answered by a `superseded` status, not by the name |
| **Names** | "Implementation plan", "Task spec" | Two words each, like "Feature design". "Task" matches Claude Code's task list, which an S102 instantiates into |
| **Placement** | `documentation/specs/<feature-slug>/S101-<feature-slug>.md` + `S102-<feature-slug>-<NNN>-<task-slug>.md` | D100 and the site already file them as documentation artifacts; a feature folder keeps plan and tasks together. **Revises** the earlier note's repo-root `specs/`. Lifecycle is carried by status, not by location |
| **Plan ≠ ledger** | Run state in a gitignored ledger, never in S101/S102 | The reviewed text must stay what the builder read; the `.review.md` precedent |
| **Graph recorded once** | In the S101; the template decides the encoding (frontmatter, so a validator parses it) | Two copies drift |
| **D101 §7 boundary** | §7 Implementation is S102 content; a feature with an S101 marks §7 N/A | Resolves D100 §9's open item; §7 stays as the interim for repos not yet on the Spec stage |
| **Validator authority** | Hard on shape, soft on content (unchanged from the earlier note) | Cycles, orphans, broken links and placeholders are mechanical; whether the phases are sensible is the reviewer's |
| **Artifact folders** | `artifacts/documentation/s101-implementation-plan/`, `artifacts/documentation/s102-task-spec/` | Repo convention: one folder per artifact, grouped by landing place |

## 6. Still open

1. **Command shape.** One command that writes the S101 and its S102s together (`/s101-implementation-plan`), or a second command per task? Decide in the Spec-stage D101.
2. **Ledger format.** Markdown (superpowers) or JSON (Anthropic, Ralph)? Anthropic's argument is that the model corrupts JSON less. The ledger is not a reviewed artifact, so JSON costs nothing in readability.
3. **Who rules below the human.** The S101 may name an orchestrator agent as the router for defects under a threshold. Which threshold, and is it per repo?
4. **Runtime binding.** How an S101's graph becomes Claude Code tasks (`TaskCreate` with `blockedBy`), and whether `TaskCreated` / `TaskCompleted` hooks enforce "no task without an S102" and "no completion before the validator is green". Agent teams are experimental; the S101 must stand without them.
5. **D101 reference precision.** Path plus section number, or stable anchors in the D101? Inherited from the earlier note; the coverage map (S101 §4.8) needs it.
6. **The estimate** (D100 Q7). The S101 carries the graph and the tiers; it is the natural neighbour of an estimate. Observe first.

## 7. Evidence to keep expectations sober

The June 2026 taxonomy paper (arXiv 2606.04967, six frameworks) finds that "persistent artifacts, work contracts, traceability and human review become mechanisms that reduce ambiguity and coordinate agents", that no framework covers all six of its dimensions, and that specification drift and over-reliance on generated output are the recurring risks. The Spec Kit Agents study (arXiv 2604.05278, 128 runs over 32 tasks) measured a judged-quality gain of +0.15 on a 1–5 scale with test pass rates already at 99.7–100%. The value of the layer is review and traceability, not speed.

## Sources

- [GitHub Spec Kit: tasks template](https://github.com/github/spec-kit/blob/main/templates/tasks-template.md), [plan template](https://github.com/github/spec-kit/blob/main/templates/plan-template.md), [spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Kiro feature specs](https://kiro.dev/docs/specs/feature-specs/)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec)
- [Conductor: context-driven development for Gemini CLI](https://developers.googleblog.com/conductor-introducing-context-driven-development-for-gemini-cli/)
- superpowers plugin (v6.4.1, local install): `writing-plans`, `executing-plans`, `subagent-driven-development` skills
- [Beads](https://github.com/gastownhall/beads), [Welcome to Gas Town](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04)
- [Anthropic: Effective harnesses for long-running agents](https://anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Ralph](https://github.com/snarktank/ralph)
- [Claude Code: agent teams](https://code.claude.com/docs/en/agent-teams)
- [From Prompt to Process (arXiv 2606.04967)](https://arxiv.org/abs/2606.04967), [Spec Kit Agents (arXiv 2604.05278)](https://arxiv.org/abs/2604.05278)
- [SDD tool comparison](https://github.com/RSMuthu/SDD-comparison)
- MinimumCD agentic-CD sources: see `L3-spec-format-research.md`
