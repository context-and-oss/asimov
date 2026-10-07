# D100 — Asimov Architecture

Architecture of the `asimov` repo — the marketplace that ships the L3 workflow's AI-assisted stages as one installable plugin, to Claude Code and Codex from one plugin folder.

---

## 1. Document information

| Field | Value |
|---|---|
| Version | 0.3 |
| Last updated | 2026-10-01 |
| Status | Draft |
| Owner | Context&; lead maintainer [@Aborup](https://github.com/Aborup), maintainer team `@context-and-oss/team-asimov` |

## 2. Purpose & audience

**Purpose.** Describe the toolkit as a system: which components exist, how they're packaged, how they reach developers, and the architectural patterns they share. A developer (human or AI) reading this doc should be able to orient before touching any specific command, subagent, definition, or template.

**Primary audience.** Context& developers maintaining the toolkit, and developers using it in product repos.

**Secondary audience.** Architects deciding how the toolkit evolves; AI Transition reviewers tracking toolkit readiness.

## 3. System context

The toolkit sits inside the L3 workflow defined in the *AI Transition — Levels & Zones* framework (the part Asimov uses is summarised in [`ai-transition-levels-and-zones.md`](ai-transition-levels-and-zones.md)) — specifically, teams making the workflow change to **L3 on Zone 2**. The L3 pipeline has nine stages — *Intent → Design → Spec → Code → Review → Test → Approve → Deploy → Observe*.

The toolkit covers the **AI-assisted** portion of the pipeline — Design, Spec, Code, Review, and Test. Each stage maps to a tool: **Design** → the `/d101-*` commands; **Spec** → the `asimov-spec` and `asimov-spec-validate` asimov-skills, which write and validate the S101 implementation plan and its S102 task specs; **Code** → the build subagents (Giskard and Daneel write production code, Calvin authors the tests); **Review** → the reviewer subagent (Baley, conventions + correctness on the diff, and *against the spec* when given task specs); **Test** → the verifier subagent (Powell), which runs a built phase's done-whens and checkpoint as written (*"Agent vs Spec"*; *verification*, as distinct from the Spec stage's *validation* of the specs themselves). The three are run in that order, phase by phase, by the `asimov-build` asimov-skill, with the person's go after every phase (`features/D101-build-stage.html`). See §4.3, §4.4. Intent is captured upstream (e.g. Jira). Approve is the human gate. Deploy and Observe live in existing CI/CD and monitoring.

At L3 the unit of work shifts from a line (L2) to a whole spec, and the human role from **maker** to **director and reviewer**.

The toolkit does **not** enforce the L3 process — that lives in product repos. It gives the developer the right command at each AI-assisted stage; the surrounding process rests on four rules, enforced in product repos via PR settings and Copilot instructions, not by the toolkit:

- **Reviewer ≠ author** — nobody approves their own design or code. The plan is the exception, decided 2026-10-06: its author approves it at the cut, where they are its first and only human reader, and each task spec is approved by the fresh agent that validated it blind (`D101-spec-stage.html` Q13).
- **No phase starts until the previous one is approved** — above all, coding does not start until the spec is approved (the spec-before-code gate).
- **Copilot reviews before any human reviewer** — automated review runs first; its findings are in front of the human when they open the artifact.
- **A gap found in a later phase is a bug in an earlier one** — fix the earlier artifact and re-run the phase; don't paper over it.

## 4. Components

The toolkit ships as a single marketplace containing one plugin — one plugin folder, installed by Claude Code and by Codex. Seven kinds of **component** live in it; the stage contracts (§4.5) are the newest.

> **Terminology.** A *component* is a part of the toolkit itself — the marketplace, the plugin, a slash command, a subagent, a skill, a definition or template. An *artifact* is something the toolkit writes into a product repo — a D101, a persona review skill, the `asimov.md` context file — and is what the `artifacts/` folder (§4.5) is organised around. The two words are not interchanged in this document.

### 4.1 Marketplace

Declared twice at the repo root: `.claude-plugin/marketplace.json` for Claude Code and `.agents/plugins/marketplace.json` for Codex. Both carry the marketplace name `asimov-marketplace` and one plugin entry, pointing at the same plugin folder.

Alternatives considered:

| Option | Rejected because |
|---|---|
| Multiple plugins, one per pipeline stage (`asimov-design`, `asimov-spec`, …) | Fragments the unit-of-update; developers would install 4–5 separate plugins and update each. The L3 workflow is a single contract — splitting it across plugins breaks that. |
| Per-feature plugins (one plugin per slash command) | Overkill for the handful of components the toolkit ships. Adds manifest overhead with no separation benefit. |
| Multiple marketplaces (per team or per pipeline stage) | Same fragmentation cost as multiple plugins, plus extra install steps. |

### 4.2 Asimov Plugin

The sole plugin in the marketplace. Lives under `plugins/asimov-plugin/` with two plugin manifests side by side — `.claude-plugin/plugin.json` for Claude Code and `.codex-plugin/plugin.json` for Codex, both named `asimov-plugin`. The plugin's job is to expose every slash command, subagent, and skill the toolkit publishes. Developers install once; in Claude Code, commands, subagents, and the shipped skills (§4.6) become available across all product repos. Codex loads the skills only (§4.3, §4.6).

### 4.3 Slash commands and asimov-skills

Developer-driven entry points. A slash command is a markdown file under `plugins/asimov-plugin/commands/` (Claude Code only); an asimov-skill is a `SKILL.md` under `plugins/asimov-plugin/skills/asimov-<name>/` that both harnesses read (below). Each declares its model in YAML frontmatter. Per-entry-point design lives in `features/D101-<feature>.html`.

| Command | Stage | Model | D101 |
|---|---|---|---|
| `asimov-design` asimov-skill (writes via `artifact-d101-authoring`; a named legacy `.md` is rendered the same way) | Design | Opus 5.5 xhigh *(Claude Code only)* | [`D101-design-stage.html`](features/D101-design-stage.html) |
| `asimov-design-review` asimov-skill (gap review via `artifact-d101-gap-review`, persona reads via `persona-*`) | Design | Sonnet 5.5 *(Claude Code only)* | [`D101-design-stage.html`](features/D101-design-stage.html) |
| `/asimov-init` | Setup (ad-hoc) | Opus 5.5 | [`D101-asimov-init.html`](features/D101-asimov-init.html) |
| `asimov-spec` (asimov-skill; cuts via `artifact-s101-authoring`, shows the plan via `artifact-s101-view`, writes via `artifact-s102-authoring`, validates via `artifact-s101-validation` and the blind `artifact-s102-validation`) | Spec | Opus 5.5 xhigh (Claude Code only) | [`D101-spec-stage.html`](features/D101-spec-stage.html) |
| `asimov-spec-validate` (asimov-skill; both validations, writes only the sidecar) | Spec | Sonnet 5.5 (Claude Code only) | [`D101-spec-stage.html`](features/D101-spec-stage.html) |
| `asimov-build` (asimov-skill; dispatches each task to its Asimov agent, Baley then Powell per phase, the ledger via `artifact-s101-ledger`, the person's go commits each phase) | Code + Review + Test | Sonnet 5.5 (Claude Code only) | [`D101-build-stage.html`](features/D101-build-stage.html) |
| `/conventions-check` *(planned)* | Review + Test | Sonnet 5.5 or Haiku 4.5 | — |

Command file paths follow the pattern `plugins/asimov-plugin/commands/<command-name>.md`. Slash commands are Claude Code only — Codex does not load `commands/`; `/asimov-init` alone has a Codex counterpart, the skill `codex-asimov-init` (§4.6).

An **asimov-skill** is a user-invoked skill rather than a command file: `plugins/asimov-plugin/skills/asimov-<name>/SKILL.md` plus `agents/openai.yaml` beside it, one file read by both Claude Code (`/asimov-<name>`) and Codex (`$asimov-plugin:asimov-<name>`), started only when a person names it (`disable-model-invocation` / `policy.allow_implicit_invocation: false`). It composes `artifact-*` skills and carries the conversation, never a method; the frontmatter `model` binds in Claude Code only (§7.1). The Spec stage was the first to use the shape, the Design stage followed on 2026-10-02 (`features/D101-design-stage.html`) and the Build stage on 2026-10-07 (`features/D101-build-stage.html`).

**`asimov-spec` shows the cut, as the plan view, before it expands it.** Its design is anything that meets `contracts/design.md`: a D101 at `Full design`, or a Jira ticket normalised into `documentation/specs/<slug>/design.md`, named in the message that invokes the skill (a slug or path, a link or key, or pasted ticket text; no arguments). A ticket is fetched where the harness can or pasted, cached gitignored beside the plan for the blind reader, and the S101 links it and carries each id with the ticket's wording, so Jira stays the record; a one-task ticket gets a one-task plan, never a task spec without one. It reads the design and the repo, asks at most five questions with defaults, cuts and checks the S101 draft in fresh subagents (a Fail is re-cut unseen, up to three times) and shows the cut as the plan view with what the checks left, one line per finding, then waits: *go* approves the plan (written into the header with the author, the date and a fingerprint of the plan), then every S102 is written and blind-validated and the plan validated, each call in a fresh subagent with one line in chat; free text re-cuts, *stop* leaves the S101 alone. A clean blind check marks the S102 `validated`, the agent's approval. One finish: `ready` when the plan is still the one approved, or what changed and the question to approve again; the raw reports go to a gitignored `S101-<slug>.review.md` sidecar, never to the chat. Nobody sets a status by hand. See `features/D101-spec-stage.html` §4.3, §4.6, §5, §6.2.

**`asimov-build` builds a ready plan phase by phase, in the L3 order, with the person's go after every phase.** It refuses a plan that is not `ready`, an approval whose fingerprint no longer matches, the default branch and a dirty tree. A phase's tasks are built in batches (every task whose `after` are done and whose owned files are disjoint from the batch runs at once), each by a fresh subagent of the shell its role names, with the S102 as its only brief and the tier's model; then Baley reviews the phase's diff against its task specs (a third axis, *against the spec*), then Powell runs every done-when and the checkpoint, the working tree hashed before and after; a failed task is rebuilt with the findings, three attempts across review and verification, the third a stop. The checkpoint is shown, the go commits the phase's owned files and the ledger as one commit, nothing is committed before. Run state lives in `documentation/specs/<slug>/S101-<slug>.ledger.md` (`artifact-s101-ledger`, the only writer; committed with each phase so a run resumes on another machine and the PR carries the reports); the run writes nothing else into the specs but the S101 status `ready` → `in progress` → `done`. Every stop reaches the person, who rules: resume with a note, discard the phase, or stop; a `design:` finding is the Spec stage's. Never a PR, never a push. Design: `features/D101-build-stage.html`.

**`asimov-design` runs in three phases with a stop in the middle.** Phase A settles requirements (§2, §3) and writes nothing. Phase B settles the business design (§4, §5 UI Design, §8, §9), writes the file with the document phase marked `Business design`, §6 *declared open* and §7 Implementation *pending*, and **stops the run**. Phase C — the technical design plus the build recipe (§6, §7 Implementation, §10) — is reachable only in a *later* invocation against a file already at `Business design`, and flips it to `Full design`. §7 Implementation is the code-grounded recipe realising the §6 contracts; it sits **outside the two bars** (`d101-feature-design-definition.md` §4.8) and is the interim home for build-readiness notes until the Spec stage (S101/S102) is in use for the feature (§9).

The stop is deliberate and is the skill's main design decision. Settling the mechanism before the business shape holds anchors the design to whatever was convenient to build, and a business design the developer has only seen as chat is a business design they have not read. Both axes are visible in the rendered document: **phase** (`Business design` → `Full design`, the author's call) and **status** (`Draft` → `Approved`, the business approver's). See `d101-feature-design-definition.md` §2.

**`asimov-design-review` is the review hub, not only the gap check.** It resolves the phase from the file, then offers the reviews that phase calls for and runs the ones the developer picks: the **gap review** against the matching bar (§8a or §8b, so a deliberately open §6 reads as *open*, not a failure — delegated to the `artifact-d101-gap-review` skill); the **business-persona review** of §2/§4; and the **technical-persona review** of §4 (and §6 once written). The two persona reviews are **delegated to the persona skills** (§7.2 / `D101-personas.html`), which the skill discovers and sorts into a business or a technical bucket by whether each reader declares it knows the mechanism (`persona-review-definition.md` §7). The hub reads the status axis for context but moves neither axis. See `D101-design-stage.html`.

**Review findings survive the session that produced them.** `asimov-design-review` writes a sibling `D101-<slug>.review.md` — every finding it just emitted to chat, plus a fingerprint of the D101 (its meta-strip date, phase and status) at review time. A later `asimov-design` run reads it, offers it as input if the fingerprint still matches (naming the discrepancy if it doesn't), folds each finding in the way a chat comment would be, and deletes the file once that same run writes the D101. The file is a disposable cache, never a record: it carries no state a re-run of the stateless gap review couldn't reproduce, and it is gitignored at the standard `documentation/features/` location — never committed, never a review log. This is the one place `asimov-design-review` writes anything; `Write` was added to its tool grant for exactly this path, a scope enforced by prompt discipline (Claude Code's tool grant is not path-scoped) rather than a sandbox, stated as such in its hard rules. Design: `features/D101-design-stage.html`.

`/conventions-check` is **ad-hoc** — invokable at any point in a session, not strictly tied to its Review + Test placement. Listed under Review + Test as its primary integration point, but developers can run it during Code or even Design phases when they want a convention check.

### 4.4 Subagents

Long-running, autonomous workers. Each is two layers: a **role skill** under `plugins/asimov-plugin/skills/role-<stack>-<role>/` that carries the whole method (§7.2.1) and is the harness-portable part, and a thin **shell** under `plugins/asimov-plugin/agents/` per harness — `<name>.md` for Claude Code (frontmatter `skills:` preloads the role skill) and `<name>.toml` for Codex (prototype — Codex loads no plugin-level `agents/`, so the `codex-asimov-init` skill copies them into the product repo's `.codex/agents/`, §4.6) — carrying only identity, model, tool restrictions and the pointer to the skill. Five exist: the three build subagents, the reviewer and the verifier.

Subagent *kinds* follow the **Accelerate multi-agent roles** — *planner / builder / tester / reviewer* (the L3 multi-agent vocabulary; see [`ai-transition-levels-and-zones.md`](ai-transition-levels-and-zones.md)). Three kinds ship today: **build subagents** (builders + tester — they produce code and tests), the **reviewer** (it checks the changeset) and the **verifier** (Powell, the tester role at the Test stage — it runs what the spec promised). *Planner* is reserved (architect/spec roles, not built).

| Subagent (shell) | Role skill | Accelerate role | Stage | Model | D101 |
|---|---|---|---|---|---|
| `giskard-the-dotnet-developer` (.NET developer) | `role-dotnet-builder` | Builder | Code | Sonnet 5.5 | [`D101-subagents.html`](features/D101-subagents.html) |
| `daneel-the-angular-developer` (Angular developer) | `role-angular-builder` | Builder | Code | Sonnet 5.5 | [`D101-subagents.html`](features/D101-subagents.html) |
| `calvin-the-test-author` (test author) | `role-dotnet-tester` | Tester | Code | Sonnet 5.5 | [`D101-subagents.html`](features/D101-subagents.html) |
| `baley-the-code-reviewer` (code reviewer) | `role-code-reviewer` | Reviewer | Review | Sonnet 5.5 | [`D101-subagents.html`](features/D101-subagents.html) |
| `powell-the-verifier` (verifier) | `role-s102-verifier` | Tester | Test | Sonnet 5.5 | [`D101-subagents.html`](features/D101-subagents.html) (roster) · [`D101-build-stage.html`](features/D101-build-stage.html) (the run) |

All five share one D101 (`features/D101-subagents.html`): the roles differ in competence, boundary and target, not in mechanism, and the shared mechanism lives in §7.2.1. How Powell and Baley are run inside a build is `features/D101-build-stage.html`.

**Role vs. stage — note the split.** The *tester* role spans two pipeline stages: Calvin **authors** tests during **Code** (build time — writing a test is a build activity), while Powell **runs** the S102s' done-whens and the phase's checkpoint at the **Test** stage (the built code checked against the spec — *"Agent vs Spec"*), writing nothing. **Review** — conventions, correctness and, given task specs, the diff against the spec — is Baley's, and is distinct from the verification at Test; in a build Baley runs before Powell, the L3 order. So *who builds the tests* (Calvin, Code) is not *who verifies* (Powell, Test). Neither is the Spec stage's *validation*, which checks the specs before any code exists (§4.3). The blind S102 validation runs in a fresh generic read-only subagent, not in an Asimov-named one: it is a context boundary, not a role.

Subagent shells follow the pattern `plugins/asimov-plugin/agents/<subagent-name>.md` (Claude Code) and `.toml` (Codex); role skills follow `plugins/asimov-plugin/skills/role-<stack>-<accelerate-role>/SKILL.md` — subject first, like the shell names and the `conventions/<stack>/` folders. A role that spans stacks drops the stack (`role-code-reviewer`): its method is one, only its read-list is stack-specific, so it is not split per stack. The skill body names roles, never Asimov personas; persona names live in the shells.

### 4.5 Definitions and templates

Documents humans read; also read by slash commands and subagents at runtime. They are the cross-cutting **standards** the rest of the toolkit aligns to (the stage handoffs, what one stage's output must contain for the next stage to consume it, are a separate kind and live in `plugins/asimov-plugin/contracts/`; `contracts/design.md` is the first, read by the Spec-stage skills by path) — not features. Treated like a product repo's `documentation/conventions/` directory rather than like features.

They are laid out **per artifact, not per file kind**: an *artifact* is something the toolkit writes into a product repo, and its folder `artifacts/<landing-place>/<artifact-slug>/` holds the definition and the template side by side, grouped by where the artifact lands (a D101 lands in the product repo's `documentation/`, so its folder is `artifacts/documentationasimov-design/`). Building blocks that several artifacts draw on but that are not artifacts themselves — the diagram notations — live in `resources/`. A persona review skill lands in the product repo's `.claude/skills/`, so its pair sits in `artifacts/skills/persona-review/`; the `/asimov-init` outputs sit under `artifacts/documentation/site/`, `artifacts/documentation/conventions/` and `artifacts/root/asimov-md/` by the same rule. `model-choice.md` is the one exception: no command reads it at run-time, it is a standard for the people maintaining the toolkit, so it lives outside install scope in `documentation/` next to this file.

| Standard | Location | Purpose | Maturity |
|---|---|---|---|
| Definition of D101 | `plugins/asimov-plugin/artifacts/documentationasimov-designasimov-design-definition.md` | Written standard for the Design stage — the **two bars** a D101 matures through: *business-complete* (a business reviewer can agree to what will be built and why, before any technical design exists) and *gap-free* (an implementer who never saw the conversation can act on it). §8 carries one canonical numbered check-list marking which bar each check belongs to | trial |
| Definition of persona review | `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md` | Written standard for a **persona review** — reading a design document *as one of its intended readers* and reporting where it talks to its author instead of its reader. Defines the five persona fields, the generic fail/reward catalogue, and the output shape; the concrete form of `asimov-design-review` check 7 | assess |
| Definition of documentation site | `plugins/asimov-plugin/artifacts/documentation/site/site-definition.md` | Written standard for the landing site `/asimov-init` renders — the bucket order, one card per concept, what may be added and what is never invented | assess |
| Definition of asimov.md | `plugins/asimov-plugin/artifacts/root/asimov-md/asimov-md-definition.md` | Written standard for the Asimov-owned context file and its single `@asimov.md` import into `CLAUDE.md` | assess |
| Definition of convention read-list | `plugins/asimov-plugin/artifacts/documentation/conventions/conventions-definition.md` | Written standard for the per-stack read-list the build subagents load (§7.2.1) — managed region, detected stacks only, never the rules themselves | assess |
| Model choice | `documentation/model-choice.md` | Canonical (stage → command/asimov-skill/subagent → model) mapping, plus the S101 task tiers (`low`/`mid`/`high` → model) | — |
| D101 template | `plugins/asimov-plugin/artifacts/documentationasimov-designasimov-design-template.html` | Visual + structural standard every D101 follows; authoring ground rules + component catalogue live in its leading HTML comment | trial |
| Persona template | `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md` | SKILL.md skeleton a persona review skill is authored from — one skill per reader; leading comment holds the ground rules + an anonymised worked example | assess |
| Standard persona set | `plugins/asimov-plugin/skills/persona-*` | Curated generic reader archetypes shipped as plugin skills — the day-one personas. The v1 set is three, one per orthogonal stake: **Poseidon** (operational reality), **Athena** (technical feasibility), **Hermes** (cost/ROI). Each a self-contained `SKILL.md` following `persona-review-template.md`, named `persona-<god>` (Greek-god handles, distinct from the Asimov-canon subagents) | — |
| Diagram templates | `plugins/asimov-plugin/resources/diagrams/` (`README.md` is the routing table) | The four standard notations a D101 diagram may use — UML sequence, UML activity with swimlanes, UML state machine, ISO 5807 flowchart. Each template file's leading comment carries its own notation, node-budget and geometry contract | — |
| Documentation site templates | `plugins/asimov-plugin/artifacts/documentation/site/site-template.html` + `plugins/asimov-plugin/artifacts/documentation/site/_chrome.css` | Landing-page + shared-chrome templates `/asimov-init` renders the `documentation/` site from | assess |
| Asimov context template | `plugins/asimov-plugin/artifacts/root/asimov-md/asimov-md-template.md` | Body of the `asimov.md` context file `/asimov-init` writes to a product repo root and wires into `CLAUDE.md` via `@asimov.md` | assess |
| Convention read-list template | `plugins/asimov-plugin/artifacts/documentation/conventions/conventions-readme-template.md` | Skeleton `documentation/conventions/<stack>/README.md` `/asimov-init` scaffolds per detected stack (the subagent read-list, §7.2.1) | assess |
| Definition of S101 | `plugins/asimov-plugin/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md` | Written standard for the Spec stage's **plan** — one per design (a Full-design D101, or any design that meets `contracts/design.md`): the task graph as a phase tree (one task per line: role, tier, `after`, traces; files and names live in the S102 headers; a tester task before the builders in every slice; Foundation as phase 0 with the contracts as code, a close phase when the run needs one), the contracts stated once, the constraints the design imposes, the review focus, the escalation routing, the coverage map back to the design, the assumptions. One bar, *dispatch-ready*, judged by a reviewer ≠ author; validated in two modes (graph-only at the cut, full at the end); size thresholds in §8.1; never the ledger | assess |
| Definition of S102 | `plugins/asimov-plugin/artifacts/documentation/s102-task-spec/s102-task-spec-definition.md` | Written standard for the Spec stage's **task** — the brief one fresh builder receives: intent traced to the design, owned files and contract names in the header, behaviour as Gherkin or an explicit *none*, done-when as named tests and commands, musts / must nots / stops, out of scope; names and signatures, never a method body, a test or a step (`contracts/specification.md`). One bar, *buildable blind*, validated blind by a fresh subagent right after it is written; no placeholders; the builder never edits what it does not own | assess |
| S101 template | `plugins/asimov-plugin/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md` | Structure every S101 follows: the phase tree once in YAML frontmatter (tasks under phases, one line each), a body of six sections (Contracts, Constraints, Coverage, Escalation, Review focus, Assumptions); the leading comment holds the ids, values and what never goes in | assess |
| S102 template | `plugins/asimov-plugin/artifacts/documentation/s102-task-spec/s102-task-spec-template.md` | Structure every S102 follows: header copied from the task line plus `owns` / `consumes` / `produces`, then five sections: intent, behaviour, done-when, constraints and stops, out of scope; the only code blocks are Gherkin | assess |
| Definition of S101 ledger | `plugins/asimov-plugin/artifacts/documentation/s101-ledger/s101-ledger-definition.md` | Written standard for the Build stage's **run state** — one ledger per plan, beside it, committed with each phase: the approval's fingerprint, a status per phase and task written before the next step, the reports and rulings verbatim in an append-only body. One bar, *resumable*; five checks a resume runs; the only writer is `artifact-s101-ledger`. Plan ≠ ledger | assess |
| S101 ledger template | `plugins/asimov-plugin/artifacts/documentation/s101-ledger/s101-ledger-template.md` | Structure every ledger follows: frontmatter as machine state (phases and tasks with their statuses, attempts, agent, model), body as the record (one heading per attempt, review, verify, ruling and commit) | assess |

**Stage contracts are a separate kind.** A definition sets the bar for one artifact; a contract under `plugins/asimov-plugin/contracts/` says what one stage's output must contain for the next stage to consume it, whatever form that output takes, and names neither its producers nor its readers. `contracts/design.md` is the first (what a design must contain before Spec plans from it; the D101 definition §3.1 says how a D101 meets it, the S101 definition §3.1/§9 how any other design is read), grounded in `documentation/research/design-contract-research.md`. `contracts/specification.md` (2026-10-05) is the second: what a specification, one plan and one or more tasks, must contain before Build runs from it, and the line between what the spec fixes (scope, public names and signatures, behaviour, the check) and what the builder decides (every body, every private name, every test); the S101 definition §3.2 and the S102 definition §3.2 say how the two forms meet it. Grounded in `documentation/research/specification-contract-research.md`. Contracts carry no maturity block; the D101 that introduces them covers them.

**A rule can be declined on the record.** `d101-feature-design-definition.md` §4.9 defines an **accepted deviation**: a decision that one named rule of the definition is deliberately not met at one named place in a D101, written *into that D101* next to the element it excuses and carrying the rule, a one-sentence reason, the accepter's name and the date. It exists because a review that re-reports a settled finding spends the author's decision on every run, and the signal decays. Three limits keep it from becoming a waiver system: it covers one rule *instance* and never a §8 check, it never stops the finding being reported (`asimov-design-review` prints it as the severity **Accepted**, which never resolves to Pass), and it lapses when the text it annotates is rewritten. Deliberately **not** a side file — a waiver keyed to a requirement number rots when numbering moves, and it hides the deviation from the human reviewer who owns the gap-free verdict. The mechanism spans `d101-feature-design-definition.md` §4.9/§7/§8, the D101 template, and both D101 commands; its design is `features/D101-design-stage.html`.

**Every artifact carries a maturity level.** The *Maturity* column mirrors the YAML block (`artifact`, `maturity`, `since`) at the top of each artifact's definition. Levels are the Technology Radar rings — `assess` → `trial` → `adopt`, plus `hold` — and move on evidence of use by someone other than the author, never on time. The producing command prints the level as one chat line before its first question and never changes it. Rows marked — are not artifacts (a maintainer contract, shipped skills, a resource). Design: `documentation/features/D101-artifact-maturity.html`.

**Personas are a fourth reviewer, in two kinds.** `asimov-design-review` judges a D101 against its bar; Baley judges a code diff against conventions and correctness; a **persona review** judges a design document against *a reader* — a named audience — and reports where the document forfeits its own review (the reader skims and rubber-stamps). It is the concrete form of `asimov-design-review` check 7 — and `asimov-design-review` can run it: the hub offers the persona reviews alongside the gap check and delegates them to the persona skills (§4.3). Personas come in two kinds, both delivered as Claude Code skills named `persona-<slug>`: **standard** — generic archetypes shipped with the toolkit as plugin skills (`plugins/asimov-plugin/skills/persona-*`), available on install; and **custom** — product-specific readers authored by `artifact-persona-authoring` into the product repo's `.claude/skills/`. Generic archetypes carry no product entity, so they may travel with the toolkit; a concrete reader is a product entity (§8.4, hard rule 7), so it stays local. The authoring skill lists both before it interviews, and `asimov-design-review` lists both on its menu. The `persona-` prefix is the namespace (skill discovery is flat — a folder can't group them). See `persona-review-definition.md` and the design `features/D101-personas.html`.

### 4.6 Skills

A `SKILL.md` under `plugins/asimov-plugin/skills/<name>/`, discovered automatically on install. Most are **model-invoked**: activated when a task matches the skill's `description`; they declare no model and take no arguments (the Codex setup entry point excepted). The `asimov-*` family is **user-invoked**: started only by name, with a model bound in Claude Code (§4.3). `skills/` is the one folder both harnesses load — Codex reads nothing else from the plugin (`.codex-plugin/plugin.json` names `./skills/` only).

| Skill | Kind | Purpose |
|---|---|---|
| `role-dotnet-builder`, `role-angular-builder`, `role-dotnet-tester`, `role-code-reviewer` | Role method | The whole method of one subagent (the six-field skeleton of §7.2.1), portable across harnesses. Preloaded into the matching shell in `agents/` (§4.4); also usable directly by a main agent where no subagent exists. Named `role-<stack>-<accelerate-role>`; the cross-stack reviewer drops the stack. |
| `artifact-d101-authoring`, `artifact-d101-gap-review` | Artifact method | How to produce or judge one artifact, independent of any entry point: the D101 rendering procedure + authoring invariants + the legacy markdown render (used by `asimov-design` and any hand edit of a `D101-*.html`), and the D101 gap review — section walk, §8a/§8b, report — that `asimov-design-review` delegates to. Both read the definition and template by path (§7.4), deriving the plugin root in Codex; the asimov-skill keeps only the conversation. Named `artifact-<code>-<action>`. |
| `artifact-persona-authoring` | Artifact method | Author a custom persona review skill into the product repo: show the roster (standard + custom), interview the five fields, check the quality bar, render the template on a confirmed plan. A plain skill (it calls no skill), read by both harnesses; it replaced the `artifact-persona-authoring` and `/persona-list` commands on 2026-10-02. Named outside `persona-*` so the roster glob never takes it for a reader. |
| `artifact-s101-ledger` | Artifact method | The Build stage's ledger: start, position (the five checks), one operation per state move and per record appended, close. The only writer of `S101-<slug>.ledger.md`; never a spec, never an agent, never a commit. Design: `features/D101-build-stage.html` §6.4. |
| `role-s102-verifier` | Role method | Powell's method: run a built phase's done-whens and checkpoint exactly as written, change nothing, report per check with the command and its last line. Preloaded into the `powell-the-verifier` shells. Drops the stack: one method, the test runner is the repo's. |
| `artifact-s101-authoring`, `artifact-s101-view`, `artifact-s102-authoring`, `artifact-s101-validation`, `artifact-s102-validation` | Artifact method | The Spec stage's five methods: cut one design into an S101; render the fixed plan view a person reads in chat (the cut, the end of a run, the reviewer's read; the S101 file itself is for agents); write one S102 from one task line; validate the plan (graph-only or full, inline); validate one S102 blind (loaded by a fresh read-only subagent). Each reads its definition and template by path and calls no other skill — a skill is a leaf. Design: `features/D101-spec-stage.html` §6.4–§6.7. |
| `asimov-spec`, `asimov-spec-validate` | Asimov-skill | User-invoked entry points (§4.3): the conversation, the gate and the loop of one planning run, and the two validations on an existing plan. Compose the five Spec-stage artifact skills; carry no method. Ship with `agents/openai.yaml` for Codex. |
| `asimov-build` | Asimov-skill | User-invoked entry point (§4.3): the conversation of one build run — the refusals, the batches, Baley then Powell per phase, the gate, the stops and rulings. Composes `artifact-s101-ledger`, `artifact-s101-view` and the five agent shells; carries no method. Ships with `agents/openai.yaml` for Codex. |
| `persona-poseidon`, `persona-athena`, `persona-hermes` | Persona review | Read a design document as one of its intended readers; the concrete form of `asimov-design-review` check 7. Their definition + template pair lives in `artifacts/skills/persona-review/` (§4.5). |
| `pm-advisor` | Advisory | Advises on the delivery model held in `plugins/asimov-plugin/processes/`. Carries an intent → file routing table, reads the relevant page at run time, and advises from it. Read-only: it never writes, and never edits `processes/` (a generated export). First member of a planned `pm-*` family; the family's shared D101 is not yet written. |
| `codex-asimov-init` | Setup entry point (Codex only) | The Codex counterpart of `/asimov-init` (§4.3), invoked as `$asimov-plugin:codex-asimov-init`. Codex-only via frontmatter — `disable-model-invocation: true` + `user-invocable: false` (and `allow_implicit_invocation: false` in its `agents/openai.yaml`). Derives the plugin root from its own file path, because Codex does not substitute `${CLAUDE_PLUGIN_ROOT}` (§7.4). Writes four targets: an `AGENTS.md` managed region (`<!-- asimov:start -->` / `<!-- asimov:end -->`) rendered directly from `asimov-md-template.md`, byte-for-byte copies of `agents/*.toml` into the product repo's `.codex/agents/`, the `documentation/conventions/<stack>/README.md` read-lists, and the documentation site. `asimov.md` and the `@asimov.md` import in `CLAUDE.md` stay with `/asimov-init`. Names no model. Design: [`D101-codex-support.html`](features/D101-codex-support.html). |

The `processes/` corpus `pm-advisor` reads is exported from the Learn/Engineer/Deliver vault, not maintained here: `processes/README.md` is its meta-entry and carries the draft-status caveat; `processes/delivery-model-framework.md` is its map. It ships in install scope so the skill can resolve it under `${CLAUDE_PLUGIN_ROOT}/processes/`. That variable is a Claude Code substitution, so the three skills that use it — `artifact-d101-authoring`, `artifact-d101-gap-review`, `pm-advisor` — find their files only in Claude Code (§7.4).

## 5. Repo layout

```
asimov/
├── .claude-plugin/
│   └── marketplace.json                  ← Claude Code marketplace manifest (§4.1)
├── .agents/
│   └── plugins/
│       └── marketplace.json              ← Codex marketplace manifest (§4.1)
├── plugins/
│   └── asimov-plugin/
│       ├── .claude-plugin/
│       │   └── plugin.json               ← Claude Code plugin manifest (§4.2)
│       ├── .codex-plugin/
│       │   └── plugin.json               ← Codex plugin manifest (§4.2)
│       ├── commands/                     ← slash commands (§4.3); Claude Code only
│       │   ├── asimov-init.md
│       │   └── conventions-check.md       ← not built yet
│       ├── agents/                       ← subagent shells (§4.4): identity + harness fields, method in a role skill
│       │   ├── giskard-the-dotnet-developer.{md,toml}   ← .md = Claude Code, .toml = Codex (prototype)
│       │   ├── daneel-the-angular-developer.{md,toml}
│       │   ├── calvin-the-test-author.{md,toml}
│       │   ├── baley-the-code-reviewer.{md,toml}
│       │   └── powell-the-verifier.{md,toml}   ← the verifier (Test stage): runs a built phase against its task specs
│       ├── skills/                       ← skills (§4.6); the harness-portable layer
│       │   ├── asimov-spec/                      ← asimov-skill: the Spec-stage planning run (user-invoked)
│       │   │   ├── SKILL.md
│       │   │   └── agents/openai.yaml            ← Codex metadata: allow_implicit_invocation: false
│       │   ├── asimov-spec-validate/             ← asimov-skill: validate an existing plan
│       │   │   ├── SKILL.md
│       │   │   └── agents/openai.yaml
│       │   ├── asimov-build/                     ← asimov-skill: the Build-stage run (user-invoked)
│       │   │   ├── SKILL.md
│       │   │   └── agents/openai.yaml
│       │   ├── role-dotnet-builder/SKILL.md      ← role method (Giskard)
│       │   ├── role-angular-builder/SKILL.md     ← role method (Daneel)
│       │   ├── role-dotnet-tester/SKILL.md       ← role method (Calvin)
│       │   ├── role-code-reviewer/SKILL.md       ← role method (Baley); a vs-spec target when given task specs
│       │   ├── role-s102-verifier/SKILL.md       ← role method (Powell)
│       │   ├── artifact-d101-authoring/SKILL.md  ← how to write/change a D101
│       │   ├── artifact-d101-gap-review/SKILL.md ← the D101 gap review
│       │   ├── artifact-s101-authoring/SKILL.md  ← cut a design into an S101 (the plan part of contracts/specification.md)
│       │   ├── artifact-s101-view/SKILL.md       ← the plan view a person reads in chat
│       │   ├── artifact-s102-authoring/SKILL.md  ← one S102 from one task line; never code
│       │   ├── artifact-s101-validation/SKILL.md ← the plan checks, graph-only or full
│       │   ├── artifact-s102-validation/SKILL.md ← the blind S102 check (fresh subagent)
│       │   ├── artifact-s101-ledger/SKILL.md     ← the build ledger: start, position, record, close
│       │   ├── persona-poseidon/SKILL.md
│       │   ├── persona-athena/SKILL.md
│       │   ├── persona-hermes/SKILL.md
│       │   ├── pm-advisor/SKILL.md
│       │   └── codex-asimov-init/SKILL.md        ← Codex-only setup entry point (counterpart of /asimov-init)
│       ├── artifacts/                    ← one folder per artifact, grouped by where it lands in a product repo (§4.5)
│       │   ├── documentation/            ← artifacts that land in documentation/
│       │   │   ├── d101-feature-design/  ← definition + template side by side
│       │   │   │   ├── d101-feature-design-definition.md
│       │   │   │   └── d101-feature-design-template.html
│       │   │   ├── s101-implementation-plan/  ← Spec stage: the plan (one per design)
│       │   │   │   ├── s101-implementation-plan-definition.md
│       │   │   │   └── s101-implementation-plan-template.md   ← graph in frontmatter, body by task id
│       │   │   ├── s102-task-spec/       ← Spec stage: one task for one builder
│       │   │   │   ├── s102-task-spec-definition.md
│       │   │   │   └── s102-task-spec-template.md             ← header from the graph entry, eight sections
│       │   │   ├── s101-ledger/          ← Build stage: the run state of one plan, committed with each phase
│       │   │   │   ├── s101-ledger-definition.md
│       │   │   │   └── s101-ledger-template.md
│       │   │   ├── site/                 ← the documentation/ landing site (/asimov-init)
│       │   │   │   ├── site-definition.md
│       │   │   │   ├── site-template.html
│       │   │   │   └── _chrome.css
│       │   │   └── conventions/          ← documentation/conventions/<stack>/README.md (/asimov-init)
│       │   │       ├── conventions-definition.md
│       │   │       └── conventions-readme-template.md
│       │   ├── skills/                   ← artifacts that land in .claude/skills/
│       │   │   └── persona-review/       ← the persona review skill artifact (artifact-persona-authoring)
│       │   │       ├── persona-review-definition.md
│       │   │       └── persona-review-template.md
│       │   ├── root/                     ← artifacts that land at the product repo's root
│       │   │   └── asimov-md/            ← the asimov.md context file (/asimov-init)
│       │   │       ├── asimov-md-definition.md
│       │   │       └── asimov-md-template.md
│       │   └── project-management/       ← project-management artifacts (planned; empty until the first lands)
│       ├── contracts/                    ← stage handoffs (§4.5): what one stage's output must contain for the next to consume it
│       │   └── design.md                 ← what a design must contain; nothing about its readers
│       ├── resources/                    ← building blocks shared across artifacts (§4.5)
│       │   └── diagrams/                 ← standard diagram notations
│       │       ├── README.md             ← routing table: intent → diagram type
│       │       ├── sequence-template.svg
│       │       ├── activity-swimlane-template.svg
│       │       ├── state-machine-template.svg
│       │       └── flowchart-template.svg
│       └── processes/                    ← delivery-model corpus pm-advisor reads (§4.6); generated export — not edited here
│           ├── README.md                 ← meta-entry: vocabulary + draft caveat
│           ├── delivery-model-framework.md  ← the map
│           ├── selection-guide.md · disciplines.md · cross-cutting-layers.md
│           ├── phases/                   ← proposal, scoping, development, operations
│           ├── approaches/               ← scrum, kanban, use-case-delivery, prototyping, launch-hyper-care
│           └── disciplines/              ← 28 discipline pages
└── documentation/
    ├── D100-Asimov-architecture.md       ← this file
    ├── model-choice.md                   ← which model runs which command/subagent (§7.3); maintainer standard, outside install scope
    ├── ai-transition-levels-and-zones.md ← the Levels & Zones vocabulary Asimov uses (L0–L5, Z1–Z3, the nine L3 stages)
    ├── index.html                        ← rendered landing page (this repo eats its own /asimov-init output)
    ├── _chrome.css                       ← rendered site chrome (copy of artifacts/documentation/site/_chrome.css)
    ├── features/
    │   └── D101-*.html                   ← one D101 per artifact or role family: design-stage (asimov-skills, skills, mechanisms), subagents, personas, asimov-init, website, artifact-maturity
    └── research/                         ← research notes behind the decisions in this doc
```

The diagram shows the full intended shape. What exists today: the two Design-stage asimov-skills, the setup command `/asimov-init`, its Codex counterpart `codex-asimov-init` with the two Codex manifests (§4.1, §4.2, §4.6), the five subagents as role skills plus shells (Giskard, Daneel, Calvin, Baley, Powell), the two D101 artifact skills, the persona review layer (the `artifact-persona-authoring` skill, the three standard persona skills, and the persona definition + template), the HTML D101 template, the four diagram templates, the site templates, and the `pm-advisor` skill over the Delivery Model corpus in `processes/`. Also there, as of 2026-10-02: the whole Spec workflow — the design contract `contracts/design.md` with the D101 definition's §3.1, the two Spec-stage definitions and templates under `artifacts/documentation/s101-implementation-plan/` and `artifacts/documentation/s102-task-spec/`, the four `artifact-s10x-*` skills, and the `asimov-spec` / `asimov-spec-validate` asimov-skills with their Codex metadata. Also there, as of 2026-10-07: the Build workflow — the ledger definition and template under `artifacts/documentation/s101-ledger/`, the `artifact-s101-ledger` and `role-s102-verifier` skills, the Powell shells, the vs-spec target in `role-code-reviewer`, and the `asimov-build` asimov-skill with its Codex metadata. Not built yet: the `/conventions-check` command file. A product repo gains `documentation/specs/<slug>/` the first time `asimov-spec` runs in it, and `S101-<slug>.ledger.md` beside the plan the first time `asimov-build` does.

## 6. Distribution & install

| Aspect | How it works |
|---|---|
| Repo | Public GitHub repo `asimov`, MIT-licensed, owned by Context&. |
| Install | `/plugin marketplace add <owner>/asimov` once per developer. Claude Code reads `.claude-plugin/marketplace.json` from the default branch; the plugin entry in it points at the `latest` tag. |
| Install (Codex) | `codex plugin marketplace add <owner>/asimov` once per developer, then `codex plugin add asimov-plugin@asimov-marketplace`. Codex reads `.agents/plugins/marketplace.json`; its plugin entry points at the same `plugins/asimov-plugin/` folder. |
| Update | `/plugin marketplace update asimov-marketplace` refreshes the local cache to the newest release. No auto-update; releases are announced on the GitHub releases page. |
| Update (Codex) | `codex plugin marketplace upgrade asimov-marketplace` refreshes the Git marketplace snapshot to the newest release, then start a new session. No auto-update. |
| Auth | None for the public repo. Local development installs from a clone with `/plugin marketplace add <path-to-clone>`. |
| Auth (Codex) | None for the public repo. Local development installs from a clone with `codex plugin marketplace add <path-to-clone>`. |
| Versioning | Releases are semver majors (`1.0.0`, `2.0.0`, …) cut by the release workflow, which stamps `plugin.json` on a tag-only commit and moves the `latest` tag. Any release may change a bar or a template. |

There is no production deployment to provision — the toolkit is a developer tool consumed by Claude Code and Codex, not a runtime service.

## 7. Architectural patterns

### 7.1 Slash command shape

A command is a markdown file with YAML frontmatter + prompt body:

- **Frontmatter** declares the model (e.g. `model: claude-opus-5-5` + `effort: xhigh`), tool restrictions, and any runtime hints CC honours.
- **Body** is the prompt that runs against the model.

The exact prompt text and interview heuristics are implementation detail; they live in the command file itself and are designed against the relevant `features/D101-<feature>.html`.

**Asimov-skill shape.** The same frontmatter + body, in `skills/asimov-<name>/SKILL.md` instead of `commands/`, with `disable-model-invocation: true` so only a person starts it, and `agents/openai.yaml` beside it carrying `policy.allow_implicit_invocation: false` for Codex. Claude Code binds `model`/`effort` and substitutes `${CLAUDE_PLUGIN_ROOT}`; Codex ignores the model and substitutes nothing, so in Codex the skill derives the plugin root from its own file path, verifies it by reading a known file, and searches the plugin cache if that fails (the method of `features/D101-codex-support.html` §6.2; never a `..` path, which Codex resolves from the working directory). The body is the conversation only: every method is an `artifact-*` skill invoked by name, and the fresh subagent for the blind S102 check is the harness's generic read-only agent (`Explore` in Claude Code), never an Asimov-named one. Decided 2026-10-01 (`features/D101-spec-stage.html` §4.7); the Design stage moved to the same shape on 2026-10-02 (`features/D101-design-stage.html`), leaving `/asimov-init` as the one remaining command (the persona commands became the `artifact-persona-authoring` skill the same day).

### 7.2 Subagent shape

A subagent is a markdown file under `agents/` with frontmatter that declares model and, where the role needs it narrowed, a tool budget (today only the reviewer does; the builders and the tester inherit the full set). Subagents differ from slash commands in two ways:
- **No human in the loop during execution.** A slash command interviews; a subagent runs to completion and returns a report.
- **Output contract is explicit.** Subagents emit either code/tests (build subagents) or a structured finding report (the reviewer, and the planned validator).

#### 7.2.1 The convention-overlay mechanism (shared)

All the shipped subagents share one mechanism; this subsection is its canonical description, referenced by the per-feature D101s instead of being re-derived in each (hard rule 3).

- **Reusable core, local overlay.** Each subagent's repo-independent *base info* follows a shared six-field skeleton — **Role, Stack competence, Reads, Workflow, Boundaries, Output** — and lives in its **role skill** (`skills/role-<stack>-<role>/SKILL.md`, §4.6), which travels with the plugin and is what every harness reads; the agent file is a shell that preloads it. The active product repo's conventions are a local overlay loaded at run-time, applied on top of the base.
- **One canonical entry file per stack, by exact path.** A subagent reads `documentation/conventions/<stack>/README.md` (e.g. `dotnet/`, `angular/`, `test/`). That README `@`-references every convention file in its stack; the subagent reads each referenced file itself — the Read tool does **not** auto-expand `@`-imports, so the README is a load-bearing read-list, not a transclusion. A convention file the README doesn't reference is invisible.
- **Flag, don't guess.** Where a convention is missing (**gap**), the subagent proceeds on base competence and flags the uncovered choice. Where the task contradicts a convention (**conflict**), it stops and flags rather than silently picking a side. Each non-trivial decision **cites** the convention file that backed it.
- **Asimov-canon personas mapped to Accelerate roles.** Subagent *kinds* follow the Accelerate multi-agent roles — *planner / builder / tester / reviewer* (see §4.4). The persona names are Isaac Asimov canon; the file name combines persona + role (`giskard-the-dotnet-developer`) so identity and auto-delegation discoverability live in one identifier.

Two subagents add a **Target** field on top of this base — the changeset they work on, a branch-vs-base diff: the **tester** (Calvin) authors tests only for what the diff touched, and the **reviewer** (Baley) reviews only what it touched. The reviewer further differs in a way no build subagent does: it is **read-only and verdict-free** (it reports findings; it never edits code or approves it — reviewer ≠ author, §3). The shared overlay-reading and flag-don't-guess behaviour is otherwise identical.

### 7.3 Frontmatter-declared models

Every command and subagent declares its model in frontmatter. Developers pick the right command for the work; the command picks the right model. Two consequences:

- The model in the command/subagent file is the **runtime source of truth**.
- `documentation/model-choice.md` is the **human-readable index** of those declarations — the canonical reference for "which model runs which step".

Keeping them in sync is enforced by CI: the PR workflow (`.github/workflows/Asimov-PR.yml`) fails when a command's or subagent's `model:` has no matching row in `model-choice.md` (§10, Q1).

### 7.4 Definitions, templates and contracts as the run-time source of truth

The definitions and templates under `artifacts/` are read both by humans and by commands. Commands embed the relevant document by reference at run-time, not as a frozen copy in the prompt — so updating `d101-feature-design-definition.md`, `s101-implementation-plan-definition.md` or `s102-task-spec-definition.md` immediately changes the bar every command applies. Same for the D101/S101/S102 templates, and for the stage contracts under `contracts/`: `contracts/design.md` is read by path by the six Spec-stage skills, so a change to what a design must contain reaches every plan on the next run. In Codex, where the plugin-root variable is not substituted, the Spec-stage skills derive the plugin root from their own path the way `codex-asimov-init` does (`features/D101-codex-support.html` §6.2). Commands and skills name those files by path under `${CLAUDE_PLUGIN_ROOT}`, which Claude Code substitutes at run-time. Codex substitutes nothing and resolves a relative path from the working directory, so a Codex-only skill cannot rely on the variable: `codex-asimov-init` derives the plugin root from its own file path instead (see [`features/D101-codex-support.html`](features/D101-codex-support.html)).

This is the analogue of a product repo's `conventions/` — the standard everything in the codebase aligns to. The pattern: one canonical doc, many consumers, change in one place.

### 7.5 Repo-scoped output

Asimov-skills and commands write into the **active product repo's working tree**, not into the toolkit repo. `asimov-design` produces `documentation/features/D101-<slug>.html` in whichever product repo the developer is currently working in — once at the end of its business-design phase, again at the end of its technical-design phase (§4.3). The toolkit itself is read-only from a runtime perspective.

## 8. Cross-cutting mechanisms

### 8.1 Model selection

Per §7.3. Model name resolution and execution belong to CC. The toolkit declares; CC dispatches.

### 8.2 Configuration & secrets

None per developer. No API keys, no environment variables, no per-repo wiring. The marketplace install is the only configuration touchpoint, and it uses CC's existing GitHub credentials.

### 8.3 Lifecycle independence

Toolkit updates flow via `/plugin marketplace update` (Claude Code) or `codex plugin marketplace upgrade` (Codex, §6), not by merging into product repos — the load-bearing reason the toolkit is a **separate repo**. Templates, slash commands, and subagent prompts move on their own cadence; bundling them into a product repo would drag every product release through every tooling iteration.

Alternatives considered: (a) co-locate the toolkit in a product repo's `.claude-plugin/` — rejected because the toolkit serves multiple systems and tooling updates shouldn't churn any single product's release pipeline; (b) one toolkit repo per system — rejected because the L3 workflow is one contract across systems; per-system forks would diverge.

### 8.4 Reusability

Asimov-skills, slash commands, subagents, definitions, and templates avoid baking in product-specific names beyond what is load-bearing — reusability across products and organisations is a goal, not a hope (§8.3). Path conventions (e.g. `documentation/features/`) are acceptable shared conventions; product entity names are not.

### 8.5 Failure modes (system-wide)

Failure modes specific to a single command or subagent live in that feature's D101. System-wide:

| Failure | Surface | Recovery |
|---|---|---|
| `/plugin marketplace add` fails — no GitHub access | CC reports the network or auth error | Developer checks that Claude Code can reach GitHub; the repo itself is public |
| Manifest typo (`marketplace.json` / `plugin.json`) breaks install | Install fails silently or with a generic schema error | CI parses both manifests and checks the plugin name agrees (`.github/workflows/Asimov-PR.yml`, Q2) |
| Command declares a model CC doesn't recognise | CC errors at invocation | Update frontmatter + `model-choice.md` together |
| Template or definition file missing | Command fails partway, reports missing path | Update the command's reference path; bump toolkit version |
| Stale CC install — change committed, developer hasn't updated | Old command behaviour | `/plugin marketplace update`; no auto-update by design |
| CC itself unavailable | All commands fail | Developers fall back to writing D101/S101/S102 by hand against the templates. No degraded mode in the plugin. |

## 9. Not yet built

Planned components that slot into the structure above when added:

| Item | Adds to layout |
|---|---|
| `/conventions-check` slash command | `plugins/asimov-plugin/commands/conventions-check.md` |

**The D101 §7 boundary is settled by the S102 definition.** §7 Implementation was the *interim* home for code-grounded build-readiness notes (project layout, reuse-vs-new, method-level wiring). That is S102 content (`s102-task-spec-definition.md` §3): a feature that has an S101 marks §7 N/A and points at its `documentation/specs/<feature-slug>/` folder. §7 stays in the template for repos and features not yet on the Spec stage (`d101-feature-design-definition.md` §4.8). Research and decisions: `documentation/research/S101-S102-spec-stage-research.md`.

**The specs folder is a lockstep literal.** `documentation/specs/<slug>/`, with `S101-<slug>.md`, `S102-<slug>-NNN-<task>.md`, the committed `S101-<slug>.ledger.md` and the two gitignored siblings `S101-<slug>.review.md` and `design.md`, is written by `asimov-spec` and `asimov-build` and read by `asimov-spec-validate`, the five `artifact-s10x-*` skills and `artifact-s101-ledger`; `.gitignore` and `CLAUDE.md` hard rule 9 name it too. A fork that moves it changes all of them (hard rule 9).

**The Build workflow was built from `D101-build-stage.html`** (2026-10-07), the first D101 written after the Spec stage's first real run, as that run's OOS1–OOS3 asked. Untried on a real plan.

## 10. Open architecture questions

| # | Question | Decider | Resolution path |
|---|---|---|---|
| Q1 | Are command-frontmatter model declarations and `documentation/model-choice.md` kept in sync by review discipline, or by a small CI lint? | alb (Context& lead) | **Resolved 2026-09-15:** by CI. `.github/workflows/Asimov-PR.yml` fails the PR when a `model:` has no matching row (hard rule 2). |
| Q2 | Should the marketplace lint its manifests (`marketplace.json`, `plugin.json`) before merging changes to the default branch? Manifest typos break install silently. | alb (Context& lead) | **Resolved 2026-09-15:** yes. The same workflow parses both manifests and checks the plugin name agrees (hard rule 1). |
| Q3 | Where does the D101 template's structure live as the single source of truth — in product repos or in `asimov`? Keeping it in both risks drift. | alb (Context& lead) | Observe drift over the first stretch of real use, then decide |
| Q4 | Model versions are pinned per command (e.g. `claude-opus-5-5`). What's the upgrade ritual when CC ships a new model or retires a current one — single PR bumping all commands, or per-command rollout? *First bump (4.7 → 4.8) was done as a single PR (this file + model-choice.md + the D101 + frontmatter together); the second (Opus 4.8 → 5.5, Sonnet 4.6 → 5.5, every pin, 2026-10-02) the same way — provisional precedent; formalise vs. CI lint still open (see Q1).* | alb (Context& lead) | Decide whether to formalise the single-PR ritual / add a CI lint |
| Q5 | The S102 verification subagent produces a report that has to land somewhere reviewable on a PR. Is the toolkit's job to format the report, or just to produce structured output for an external poster? | alb (Context& lead) | **Resolved 2026-10-07:** the ledger. Powell's and Baley's reports go verbatim into `S101-<slug>.ledger.md`, which is committed with each phase, so the PR carries them; no poster, no format beyond the ledger's (`features/D101-build-stage.html` §4.5). |
| Q6 | How is the toolkit itself tested before a release? Manual run-through of each D101's acceptance criteria by a developer ≠ the author, or something more automated? No T100 / T101-equivalent exists yet. | alb (Context& lead) | Author T100 / T101 alongside the next commands; today, manual AC run-throughs by a reviewer ≠ author. |
| Q7 | A D101 goes to the business approver together with an **estimate** — that's why sign-off waits for the technical design (`d101-feature-design-definition.md` §2.3). The D101 has no place for one today. Does the estimate belong in §1 / a new section, in the S101 (which carries the task graph and the model tiers, so it is the natural neighbour), or outside the documents entirely? | alb (Context& lead) | Observe over the first few phase-C run-throughs where the estimate actually gets written down, then decide |

## 11. References

**Repo docs:**
- [`features/D101-design-stage.html`](features/D101-design-stage.html) — the Design stage: the D101 artifact, its two asimov-skills and two skills, phases and axes, accepted deviations, review handoff
- [`features/D101-subagents.html`](features/D101-subagents.html) — the four subagents: role skills, per-harness shells, the convention overlay
- [`features/D101-codex-support.html`](features/D101-codex-support.html) — Codex support: the second manifest pair and the `codex-asimov-init` skill
- [`features/D101-spec-stage.html`](features/D101-spec-stage.html) — the Spec stage: the two asimov-skills, the five artifact skills, the gate, the two artifacts (describes the 2026-10-02 shape; the 2026-10-05 re-basing on `contracts/specification.md` is recorded in CLAUDE.md *Current state* until the D101 is rewritten)

**Definitions and templates:**
- `plugins/asimov-plugin/artifacts/documentationasimov-designasimov-design-definition.md` — Design-stage bars (business-complete §8a, gap-free §8b)
- `plugins/asimov-plugin/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md` — Spec-stage plan bar (dispatch-ready)
- `plugins/asimov-plugin/artifacts/documentation/s102-task-spec/s102-task-spec-definition.md` — Spec-stage task bar (buildable blind)
- `plugins/asimov-plugin/contracts/design.md` — what a design must contain before the Spec stage plans from it (stage contract; research in `documentation/research/design-contract-research.md`)
- `plugins/asimov-plugin/contracts/specification.md` — what a specification must contain before the Build stage runs from it, and the spec/builder line (stage contract; research in `documentation/research/specification-contract-research.md`)
- `documentation/model-choice.md`
- `plugins/asimov-plugin/artifacts/documentationasimov-designasimov-design-template.html`
- `plugins/asimov-plugin/resources/diagrams/` — the four standard diagram notations a D101 diagram may use (`README.md` is the routing table)
- `plugins/asimov-plugin/artifacts/documentation/site/site-template.html` + `plugins/asimov-plugin/artifacts/documentation/site/_chrome.css` (documentation site)
- `plugins/asimov-plugin/artifacts/root/asimov-md/asimov-md-template.md` + `plugins/asimov-plugin/artifacts/documentation/conventions/conventions-readme-template.md` (`/asimov-init` repo bootstrap)
- `plugins/asimov-plugin/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md` + `plugins/asimov-plugin/artifacts/documentation/s102-task-spec/s102-task-spec-template.md` (Spec-stage templates)

**External framework references:**
- *AI Transition — Levels & Zones* (Context&) — L0–L5 / Z1–Z3 framework, L3 pipeline stage names; the part Asimov uses is summarised in `documentation/ai-transition-levels-and-zones.md`
- Claude Code plugin / marketplace documentation (Anthropic) — runtime contract for `.claude-plugin/*.json` shapes
- Codex plugin documentation (OpenAI) — runtime contract for `.agents/plugins/marketplace.json` and `.codex-plugin/plugin.json` shapes
