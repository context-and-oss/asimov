# S101 / S102 spec-stage research

**Date:** 2026-09-25, brainstorm continued 2026-09-28 and 2026-09-29. **Status:** definitions written at `assess`; the Spec-stage D101 is at `Full design` (`documentation/features/D101-spec-stage.html`, Draft v0.10, 2026-10-01), revised after its first read by a non-author (the gate, §7) and awaiting review; the component list for the first build round is settled (§7.1); templates and commands pending.

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

1. **Command shape.** ~~One command that writes the S101 and its S102s together (`/s101-implementation-plan`), or a second command per task?~~ **Resolved 2026-09-29:** one command, with the validation loop built in (§7). A separate `/s102-task-spec` for a lone S102 waits until one is needed.
2. **Ledger format.** Markdown (superpowers) or JSON (Anthropic, Ralph)? Anthropic's argument is that the model corrupts JSON less. The ledger is not a reviewed artifact, so JSON costs nothing in readability.
3. **Who rules below the human.** The S101 may name an orchestrator agent as the router for defects under a threshold. Which threshold, and is it per repo?
4. **Runtime binding.** How an S101's graph becomes Claude Code tasks (`TaskCreate` with `blockedBy`), and whether `TaskCreated` / `TaskCompleted` hooks enforce "no task without an S102" and "no completion before the validator is green". Agent teams are experimental; the S101 must stand without them.
5. **D101 reference precision.** Path plus section number, or stable anchors in the D101? Inherited from the earlier note; the coverage map (S101 §4.8) needs it.
6. **The estimate** (D100 Q7). The S101 carries the graph and the tiers; it is the natural neighbour of an estimate. Observe first.

## 7. Brainstorm towards the Spec-stage D101 (2026-09-28 → 2026-10-01, in progress)

The questions the D101 has to answer: how a D101 becomes one S101 and N S102s; how big an S102 may be; the format; how we verify everything is clarified; how a design is best broken down; and how *what to build*, *how to build*, *what to verify* and *how to verify* are kept apart. Settled so far:

| Point | Decision | Why |
|---|---|---|
| **Primary cut** | Vertical slice per verifiable outcome (D101 AC), split per stack only where the slice crosses .NET and Angular | Checkpoints mean "the outcome works", not "the code exists"; the coverage map becomes trivial. Cutting per §6 contract or per layer was rejected: a contract is rarely verifiable alone, and layers leave nothing working until the last one |
| **No third level (no S103)** | The slice is a **phase in the S101**, not a document. A single-stack slice is one S102; a multi-stack slice is 2–3 S102s in the same phase with the interface named in S101 §4.5 and the checkpoint equal to the slice's AC | Spec Kit groups tasks under a user story that is a heading, not a file; Conductor's phases › tasks › sub-tasks live in one plan. A slice file would be empty (single-stack) or two briefs in one (multi-stack), and then no longer one builder's whole context |
| **S101 §4.4 to tighten** | A phase *is* a slice and names its AC | Follows from the above |
| **Traceability ids** | The D101's `R`/`NF` (requirements), `§6.x.y` (contracts) and `AC` (acceptance criteria); §7 already keys its blocks to §6 by number | The S101 coverage map hangs on ids that exist |
| **Validation ≠ verification** (2026-09-29) | **Validation** is the spec check *before* code: do the S101 and every S102 clear their bars, and do they agree with each other (S101 §8, S102 §8). **Verification** is the code check *after* build: run the acceptance criteria an S102 names against what was built. Both definitions today say "validator" for both; the wording is to be split, and the D100 §9 "S102 validator" agent becomes the *verification* agent | Two checks, two moments, two inputs (text vs. running code). One word for both made the brainstorm talk past itself |
| **The authoring loop** (2026-09-29) | `/s101-implementation-plan` writes the S101 skeleton (graph, interfaces, constraints, escalation), then per task: write the S102 → validate it → fix → repeat until green; then, with every S102 in place, validate the plan as a whole (coverage both ways, interface closure across S102s, disjoint file sets, no cycle, no contradicted global constraint); a finding may add a task, split one, or add a name to S101 §4.5, and a changed S102 re-enters its own loop. Then the author runs `/s101-review` as a self-preview and the reviewer ≠ author approves | The two bars are checked where they are cheapest to fix: one task at a time while it is being written, the whole once everything exists |
| **S102 validation runs blind** (2026-09-29) | The per-S102 validation in the loop is dispatched to a fresh read-only subagent that sees only the S102, its S101, the D101 and the repo, and loads the validation skill. The plan-level validation runs inline | *Buildable blind* is a fresh-context property; the model that just wrote the S102 has the conversation in context and fills the gaps from memory. No new agent file: a generic read-only subagent with the skill |
| **Skeleton first: phase 0** (2026-09-29) | The first phase of every S101 is **Foundation**: one S102 per stack that writes the skeleton (classes, interfaces, public methods with summaries, no bodies, compiling). It is a transcription of S101 §4.5, so it takes the cheapest tier. Every slice task depends on it. Checkpoint: the solution builds and a reviewer can read the shape before any logic exists. Slices then own their own files, so no two parallel slices modify the same skeleton file (the plan validation checks it) | The interfaces in the plan become code before anyone builds against them, and test-first still holds: tests compile against the skeleton, fail red, then the body is written. Rejected: skeleton inside each S102 (parallel builders then agree names only on paper) and skeleton written during planning (the Spec stage would write code) |
| **Phase = slice, X tasks per phase** (2026-09-29) | Phase 0 Foundation; phases 1..n one per slice (one S102 single-stack, 2–3 multi-stack); optionally a final polish phase for cross-cutting D101 requirements. Each phase names its checkpoint | Confirms and extends the "no S103" row |
| **Two workflows** (2026-09-29) | **Spec workflow**: D101 → S101 + S102s → validation → reviewer approval; writes only under `documentation/specs/`. **Build workflow**: `ready` S101 → phase by phase → S102 to a builder → verification per S102 → Baley on the diff → checkpoint → next phase; writes only source and the ledger, never the specs. The boundary is the reviewer's approval | Keeps the reviewed text what the builder read (plan ≠ ledger), and lets the first round build the Spec workflow alone. What the Spec workflow owes the Build workflow now: the graph machine-readable in S101 frontmatter, and every acceptance criterion runnable. Both are already in the definitions |
| **Tests: builder inline + Calvin per slice** (2026-09-29) | Option 3 below. The builder writes unit tests inside its own S102, test-first. Calvin gets one S102 per slice that writes the slice's acceptance test from the AC and scenarios; that test *is* the phase's checkpoint, and with phase 0 in place it compiles against the skeleton before any slice is built | The L3 effort profile (`site/ai-transition.html`) has no human Test bar: tests are agent-written and the human *reviews* them. A separate AC-test S102 is the artifact a human can read and approve before the code exists, which is "Test vs. Spec" made reviewable. Option 1 hides the tests inside the builder's work |
| **Shape checks by a fixed checklist, script as fallback** (2026-09-29, revised the same day) | The validation skills answer a fixed, numbered shape checklist (frontmatter fields, cycle, orphan task, path resolves, placeholder tokens, consumed name with a producer, sizes) with the model; a script (Node, since Claude Code runs on it) replaces the checklist only if two runs on an unchanged plan disagree (D101 AC15, Q8) | Start without a runtime dependency in product repos. The earlier row chose a script for determinism; the cost of a runtime nobody had named outweighed it until drift is observed |
| **Review vs. Spec** (2026-09-29, Build workflow) | Baley reads the S102 as an input and reviews the diff against it, not only against conventions and correctness | The L3 stage is *Review vs. Spec*. Nothing the Spec workflow must add: the S102 filename is the stable id |
| **Two human gates** (2026-09-29) | Spec approval (reviewer ≠ author says the S101 is dispatch-ready) and outcome approval (the site's *Approve*, after Review and Test). Named differently, never merged | Without the first there is nothing to review "vs."; two gates with the same name invite rubber-stamping twice |
| **No fingerprints in the specs** (2026-09-29, refined the same day) | Update-vs-rewrite is decided in two steps: first the D101's R/AC ids against the ids the S101's coverage map traces (an id missing or added forces *rewrite*); only when the ids agree, one question ("refined, or changed in content?", default refined). A resumed run re-validates every existing S102 and keeps the ones that clear. No hashes of D101 criteria or S102 bodies | Both hashes automated a judgement a human makes in seconds, and made every re-run a noisy S101 diff; validation already answers "is this task done?". The id comparison was added because a renumbered D101 answered "refined" would update the plan against ids that moved |
| **ADRs** (2026-09-29) | Open. The site's technical spec carries ADRs; Asimov has D101 §6 and accepted deviations. Not built now | Observe whether §6 decisions need their own record |
| **Interaction: plan from the D101, ask ≤5** (2026-09-29) | `/s101-implementation-plan` reads the D101 and the repo first, asks at most five questions, one at a time, each with a recommended default, only about the task cut, the phase boundaries and open D101 items that change the breakdown; everything else it decides and records as an assumption in the S101; it finishes once, when everything is written and validated | The field converges on it (§10): explore before asking, ask only what cannot be discovered, front-load, stop once. A per-step interview repeats the D101's intent work (Kiro's heavy mode); no questions guesses the cut |
| **Asimov-skills, not commands** (2026-10-01) | The two commands become user-invoked skills, `asimov-spec` and `asimov-spec-validate`, one `SKILL.md` each for Claude Code and Codex (Claude Code merged commands into skills; Codex retired custom prompts and its plugins read only `skills/`). Phase-named, with `asimov-design`/`asimov-design-review` and `asimov-build`/`asimov-build-verify` as the siblings. Layer rule: an asimov-skill composes skills and carries no method; a skill reads artifacts and calls no skill, so the update check of existing S102s moves from `artifact-s101-authoring` to `asimov-spec`. D101 v0.11. |
| **The gate: show the cut, wait for the go** (2026-10-01) | Before the first S102 is written, the command shows the cut (phases with checkpoints, tasks with role, stack, owned files, dependencies, traces; assumptions; graph-only checks) and waits. *go* expands; free text re-cuts and shows again, no round limit; a hand-edited S101 is read as the graph, not re-cut; *stop* leaves the S101 alone on disk and the next run opens at the same gate. The go is not one of the five questions and is recorded nowhere. The cut summary is the authoring skill's output; the gate is the command's question; the S101 validation gains a graph-only mode for it | The first non-author read of the D101 (2026-10-01) asked where the human was between the five questions and the end: with the "stop once" row, the first thing the author saw was N finished task specs. The cheapest point to correct a plan is before its expansion. A soft gate in the run was chosen over a hard stop with a second invocation (as `/d101-feature-design` does) for the plan-mode feel: read, correct, go, in one conversation; and over a gate per artifact (many stops for one reader). Design: D101 R24–R25, §5 (the chat as the UI, with a mockup), §4.7 |
| **Re-plan: update in place, rewrite on changed intent** (2026-09-29, revised the same day) | Run against a D101 that already has an S101, the command updates it in place (same file, version bumped). If the D101's requirements or acceptance criteria changed, it rewrites the plan: S101 and every S102 anew, S102 files outside the new graph deleted. No `superseded` status and no kept copy: git carries the previous plan | OpenSpec's rule ("update when it's the same work refined; start new when the intent fundamentally changed"); Codex's always-replace discards the reviewer's reading. The earlier row kept a `superseded` S101 beside the new one, which needs a second file name for the same slug; git already keeps it |
| **Size: soft warnings, thresholds in the definition** (2026-09-29) | The plan validation warns, never refuses, when an S102 exceeds the size thresholds; the numbers live in the S101 definition, not in code. Candidates from the evidence (§9): more than 3 owned non-test files (harder at 7), more than ~100 lines or ~60 minutes expected, more than one behaviour scenario or no single runnable check | Evidence is strong on direction and weak on the exact number, and the number moves about every four months (METR doubling time). A gate on a moving number would be wrong within a year |

### 7.1 First build round: the Spec workflow (settled 2026-09-29)

Follows the skill split (method in skills, conversation in commands, identity in agent shells). Everything below the Build workflow waits.

| Kind | Item | Role |
|---|---|---|
| Template | `artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md` | Graph in frontmatter; body refers to tasks by id |
| Template | `artifacts/documentation/s102-task-spec/s102-task-spec-template.md` | One task, one builder |
| Skill | `artifact-s101-authoring` | The decomposition procedure (AC → slices → phases → stack split → interfaces → phase-0 skeleton task), writing the S101, and returning the cut summary the command shows at the gate |
| Skill | `artifact-s102-authoring` | Writing one S102 from the template. Called per task by `artifact-s101-authoring`; stands alone for a lone S102 from the board |
| Skill | `artifact-s101-validation` | S101 §8 as a fixed checklist, in two modes: graph-only on the S101 alone (at the gate), full including the cross-S102 checks |
| Skill | `artifact-s102-validation` | S102 §8 for one file, shape checklist first; the skill the blind subagent loads |
| Asimov-skill | `asimov-spec` (was `/s101-implementation-plan` until 2026-10-01) | The conversation, the gate and the loop (§7, *The gate* and *The authoring loop*) |
| Asimov-skill | `asimov-spec-validate` (was `/s101-review`) | Runs both validations, reports, never moves status |
| Agents | none new | The blind validator is a generic read-only subagent with the skill; Giskard, Daneel and Calvin read an S102 as their brief |
| Docs | `documentation/features/D101-spec-stage.html` | Written before the commands (CLAUDE.md recipe) |
| Docs | Both definitions | Validation/verification wording; skeleton as the canonical foundation task; phase = slice with its AC (S101 §4.4) |
| Docs | D100 §4.3, §4.4, §9, Q5; `model-choice.md` (two rows); hard rule 9 (`documentation/specs/` joins the lockstep set) | Sync |

**Waits for the Build workflow:** the verification agent (D100 §9's "S102 validator", renamed), a dispatch command that reads the S101 graph and finds claimable tasks, the ledger (format open, §6.2), Baley reading the S102 (*Review vs. Spec*), the outcome-approval gate, a standalone `/s102-task-spec` command. The site's "Spec and Test are planned" line is updated when the Spec workflow ships.

**Who writes the tests of an S102?** Resolved 2026-09-29 to option 3 (row *Tests: builder inline + Calvin per slice* above). The options as discussed:

1. The builder, test-first, inside its S102 (as `s102-task-spec-definition.md` §4.7 reads today; superpowers' model). Calvin then only extends coverage or takes test-only tasks.
2. Calvin gets its own S102 per slice, writing the tests from the slice's AC and scenarios; the builder's S102 has to make them green. D100's tester role taken literally, and reviewer ≠ author at test level.
3. Both: the builder writes unit tests inline; Calvin writes the slice's acceptance test against the AC as a separate S102 that *is* the phase's checkpoint. **Chosen.** It separates *how it is built* (the builder's tests) from *what is verified* (Calvin's AC test) into two files with two authors, at the cost of one extra S102 per slice.

Not yet discussed: the S102 size rule in practice (one sitting; what the command measures) and the exact format of both files (frontmatter fields, required sections). The "everything clarified" check and the decomposition procedure are settled above (*The authoring loop*, *Skeleton first*); their detail belongs to the D101 and the two authoring skills.

## 8. Evidence on task size (2026-09-29)

No framework states a numeric size for a *task*; superpowers has one for a *step* (2–5 minutes). What holds up empirically is files touched, lines changed and estimated human time.

| Source | Finding |
|---|---|
| SWE-bench-Live (arXiv 2505.23419, 2025-06) | Single-file patches under five lines are solved about one time in two (48 %). Three or more files, or over 100 lines: under 10 %. Seven or more files: never solved |
| SWE-bench Verified by difficulty (Ganhotra, 2025-04) | Under 15 min: 81 % resolved, 1.03 files avg. 15 min–1 h: 62 %, 1.28 files. Over 1 h: 27 %, 2.0 files, 56 % multi-file |
| METR time horizons (v1.1, 2026-05) | 80 %-success horizon for mainstream frontier models about 50–90 minutes of expert work; 50 % horizon 5–12 hours; doubling time about 129 days |
| Chroma context rot (2025-07) | Performance degrades with input length well below the window limit |
| IFScale (arXiv 2507.11538) | Compliance falls roughly linearly with instruction count; the nearest proxy for "too many acceptance criteria", and indirect |
| "Beyond Resolution Rates" (2026) | Twelve never-solved tasks need only simple patches: size is necessary, not sufficient |
| Acceptance-criteria count vs success | Not found |

Rules in the field, all conventions: MinimumCD (one scenario, one session, one commit; over 15 minutes to specify is too large; sub-two-hour chunks), Anthropic's harness post (one user-visible feature, about five checks), Ralph (one context window), Spec Kit (one story, "completable without additional context"), superpowers ("split only where a reviewer could reject one task while approving its neighbour"), Claude Code agent teams (5–6 tasks per teammate, each teammate owns different files).

**Measurable proxies the S102 already carries:** the owned file set (§4.3) and the Gherkin scenarios (§4.5). Lines and minutes need an estimate field the planner guesses and the plan carries as a recommendation.

## 9. Plan-mode interaction in the field (2026-09-29)

Checked against the docs or the installed skill files: Claude Code plan mode, superpowers (brainstorming, writing-plans, executing-plans, subagent-driven-development), GitHub Spec Kit (clarify, plan, tasks, analyze), Kiro specs and Quick Spec, OpenSpec, Google Conductor, Cursor plan mode, Codex plan mode and ExecPlans, Aider architect mode, Cline plan/act.

| Point | Where they converge | Where they differ |
|---|---|---|
| Inputs | Explore the repo read-only before asking (all) | Spec Kit and Conductor halt without their constitution / product files |
| Questions | Ask only what cannot be discovered (Codex, OpenSpec); one at a time, multiple choice, recommended default (Spec Kit ≤5, Conductor 3–4, superpowers, Codex); if unanswered take the default and record an assumption (Codex) | Kiro standard mode iterates per phase; writing-plans and speckit.plan ask nothing |
| Approval stops | Stop hard only when a whole artifact is ready | None (OpenSpec, Aider), one (Claude Code, Codex, Cursor), one per artifact (Kiro, Conductor) |
| Presentation | A plan file the user can edit (Claude Code Ctrl+G, Cursor, superpowers, Spec Kit, Kiro, OpenSpec) | Codex presents in chat as a complete replacement each time |
| Analysis | Coverage and consistency checks with severities (speckit.analyze CRITICAL–LOW, capped at 50; OpenSpec verify) | Spec Kit plan gates ERROR; OpenSpec and analyze only advise |
| Revising | Update in place plus sync (Kiro Sync Files, Spec Kit, OpenSpec); new plan only when the intent changed (OpenSpec) | Codex: any new plan is a complete replacement |
| Sizing | Reviewer-rejectable unit (superpowers); one session with a verify step (OpenSpec); "completable without additional context" (Spec Kit) | No tool states a number for a task |

Two prompts worth keeping in view when the command is written: Codex plan mode ("eliminate unknowns by discovering facts, not by asking the user"; a plan is "decision complete"; "do not ask 'should I proceed?'") and Spec Kit `/speckit.clarify` (questions ranked by impact × uncertainty, each with a recommended option and a "why it matters" line, written back to disk after each accepted answer).

## 10. Evidence to keep expectations sober

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
- Task size (§8): [SWE-bench-Live](https://arxiv.org/html/2505.23419v2), [SWE-bench Verified by difficulty](https://jatinganhotra.dev/blog/swe-agents/2025/04/15/swe-bench-verified-easy-medium-hard.html), [METR time horizons](https://metr.org/time-horizons/), [Chroma context rot](https://www.trychroma.com/research/context-rot), [IFScale](https://arxiv.org/abs/2507.11538), [MinimumCD small-batch sessions](https://beyond.minimumcd.org/docs/agentic-cd/architecture/small-batch-sessions/)
- Plan-mode interaction (§9): [Claude Code permission modes](https://code.claude.com/docs/en/permission-modes), [Spec Kit command templates](https://github.com/github/spec-kit/tree/main/templates/commands), [Kiro specs](https://kiro.dev/docs/specs/), [OpenSpec reviewing changes](https://github.com/Fission-AI/OpenSpec/blob/main/docs/reviewing-changes.md), [Conductor new-track skill](https://github.com/gemini-cli-extensions/conductor), [Cursor planning](https://cursor.com/docs/agent/planning), [Codex plan-mode template](https://github.com/openai/codex/blob/main/codex-rs/collaboration-mode-templates/templates/plan.md), [Codex ExecPlans](https://github.com/openai/openai-cookbook/blob/main/articles/codex_exec_plans.md)
