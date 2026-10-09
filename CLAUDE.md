# CLAUDE.md — Asimov

This repo is **Asimov** — a marketplace for Claude Code and Codex publishing one plugin (`asimov-plugin`, one plugin folder both tools install) that ships L3 workflow tooling. Slash commands, subagents, definitions, and document templates for the Design → Spec → Code → Review+Test stages of the L3 pipeline.

You are working *on* the toolkit. Commands and subagents *built by* the toolkit run in product repos; this repo is where their definitions, prompts, and templates live.

## Quick map

```
.claude-plugin/marketplace.json                ← marketplace manifest (declares asimov-marketplace)
.agents/plugins/marketplace.json               ← Codex marketplace manifest (same asimov-marketplace, same plugin folder)
plugins/asimov-plugin/                         ← the plugin (install scope)
├── .claude-plugin/plugin.json                 ← plugin manifest
├── .codex-plugin/plugin.json                  ← Codex plugin manifest (same asimov-plugin; "skills": "./skills/")
├── commands/                                  ← slash commands (auto-discovered; Claude Code only)
│   └── asimov-init.md                         ← bootstraps a repo for Asimov (asimov.md + CLAUDE.md + conventions + site)
├── agents/                                    ← subagent shells: identity + harness fields only; the method is a role skill. One .md (Claude Code) + one .toml (Codex, prototype) per subagent
│   ├── giskard-the-dotnet-developer.{md,toml} ← .NET developer (Giskard) → skills/role-dotnet-builder — D101-subagents
│   ├── daneel-the-angular-developer.{md,toml} ← Angular developer (Daneel) → skills/role-angular-builder
│   ├── calvin-the-test-author.{md,toml}       ← test author (Calvin) → skills/role-dotnet-tester
│   ├── baley-the-code-reviewer.{md,toml}      ← reviewer (Baley) → skills/role-code-reviewer — D101-subagents
│   └── powell-the-verifier.{md,toml}          ← verifier (Powell, Test stage) → skills/role-s102-verifier — D101-subagents roster, D101-build-stage
├── skills/                                    ← skills (shipped; active in any repo). The harness-portable layer: what both Claude Code and Codex read
│   ├── asimov-design/                         ← asimov-skill (user-invoked): the Design-stage interview — requirements, business design, the stop, the technical design in a second run; a named legacy .md is rendered to HTML. SKILL.md + agents/openai.yaml (Codex)
│   ├── asimov-design-review/                  ← asimov-skill (user-invoked): the Design-stage review hub — resolves the phase, offers the gap review (§8a/§8b) and the persona reads, runs the picks, writes the .review.md notes
│   ├── asimov-spec/                           ← asimov-skill (user-invoked): the Spec-stage planning run — questions, the cut (shown as the plan view), the gate, the loop. SKILL.md + agents/openai.yaml (Codex)
│   ├── asimov-build/                          ← asimov-skill (user-invoked): the Build-stage run — a ready plan built phase by phase by the Asimov agents, Baley then Powell per phase, the ledger, the person's go commits each phase. SKILL.md + agents/openai.yaml (Codex)
│   ├── artifact-s101-authoring/SKILL.md       ← artifact skill: cut a design (a D101, or a normalised design cache) into an S101, the plan part of contracts/specification.md
│   ├── artifact-s102-authoring/SKILL.md       ← artifact skill: one S102 from one task line — names, behaviour, done-when; never code
│   ├── artifact-s101-validation/SKILL.md      ← artifact skill: the plan checks, graph-only (at the cut) or full; its method is scripts/validate-s101.ps1, run inline by asimov-spec (no subagent)
│   ├── artifact-s102-validation/SKILL.md      ← artifact skill: the S102 shape check, a schema check; its method is scripts/validate-s102.ps1, run inline by asimov-spec (no subagent)
│   ├── artifact-s101-view/SKILL.md            ← artifact skill: the plan view a person reads in chat (the cut, the review, the run); the S101 file is for agents
│   ├── artifact-s101-ledger/SKILL.md          ← artifact skill: the build ledger — start, position (five checks), record every attempt/report/ruling, close; the only writer of S101-<slug>.ledger.md
│   ├── role-dotnet-builder/SKILL.md                ← role skill: the .NET builder method (Giskard's body)
│   ├── role-angular-builder/SKILL.md               ← role skill: the Angular builder method (Daneel's body)
│   ├── role-dotnet-tester/SKILL.md                 ← role skill: the .NET tester method (Calvin's body)
│   ├── role-code-reviewer/SKILL.md                 ← role skill: the changeset review method, all stacks (Baley's body); a vs-spec target and third table when given task specs
│   ├── role-s102-verifier/SKILL.md                 ← role skill: the verifier method (Powell's body): run a built phase's done-whens and checkpoint as written, change nothing
│   ├── artifact-d101-authoring/SKILL.md       ← artifact skill: how to write/change a D101 (rendering procedure + invariants + the legacy .md render); used by asimov-design and any hand edit
│   ├── artifact-d101-gap-review/SKILL.md      ← artifact skill: the D101 gap review (section walk + §8a/§8b + report); asimov-design-review delegates to it
│   ├── artifact-persona-authoring/SKILL.md    ← artifact skill: shows the persona roster, interviews for a custom persona, writes .claude/skills/persona-<slug>/ (both harnesses; replaced /persona-new + /persona-list)
│   ├── persona-poseidon/SKILL.md              ← operational-reality reader
│   ├── persona-athena/SKILL.md                ← technical-feasibility reader
│   ├── persona-hermes/SKILL.md                ← cost/ROI reader
│   ├── pm-advisor/SKILL.md                    ← advises on the delivery model in processes/ (routing table; read-only)
│   └── codex-asimov-init/SKILL.md             ← Codex-only setup entry point ($asimov-plugin:codex-asimov-init), counterpart of commands/asimov-init.md
├── scripts/                                   ← code the skills run through Bash where a checklist must give the same answer twice
│   ├── validate-s101.ps1                      ← the S101 plan check, graph-only or full (PowerShell 5.1 and 7); the template is its schema, the design's ids its coverage set
│   └── validate-s102.ps1                      ← the S102 shape check (PowerShell 5.1 and 7); the template is its schema, the S101 definition §8.1 its thresholds
├── artifacts/                                 ← one folder per artifact the toolkit writes into a product repo; sub-folder = where it lands
│   ├── documentation/                         ← artifacts that land in the product repo's documentation/
│   │   ├── d101-feature-design/               ← the D101 artifact: definition + template side by side
│   │   │   ├── d101-feature-design-definition.md  ← the two bars for D101s (§8a business-complete, §8b gap-free)
│   │   │   └── d101-feature-design-template.html  ← visual + structural standard every D101 follows
│   │   ├── s101-implementation-plan/          ← the S101 artifact (Spec stage): the task graph for one design
│   │   │   ├── s101-implementation-plan-definition.md  ← the dispatch-ready bar; §4.4 checkpoint sentence + check command; §6 the fingerprint command; §8.1 size thresholds; §9 the specs folder + sidecar + design cache + repo notes
│   │   │   └── s101-implementation-plan-template.md    ← graph once in YAML frontmatter, body by task id, Assumptions last
│   │   ├── s102-task-spec/                    ← the S102 artifact (Spec stage): one task for one builder
│   │   │   ├── s102-task-spec-definition.md   ← the buildable-blind bar; validated blind
│   │   │   └── s102-task-spec-template.md     ← header copied from the graph entry; eight sections
│   │   ├── s101-ledger/                       ← the ledger artifact (Build stage): the run state of one plan, committed with each phase
│   │   │   ├── s101-ledger-definition.md      ← the resumable bar; statuses, append-only body, five checks
│   │   │   └── s101-ledger-template.md        ← frontmatter as machine state, body as the record
│   │   ├── site/                              ← the documentation/ landing site (asimov-init)
│   │   │   ├── site-definition.md             ← what the rendered site must contain
│   │   │   ├── site-template.html            ← landing-page template
│   │   │   └── _chrome.css                    ← shared site chrome, copied verbatim
│   │   └── conventions/                       ← documentation/conventions/ (asimov-init)
│   │       ├── conventions-definition.md      ← what a per-stack read-list must contain
│   │       └── conventions-readme-template.md ← conventions/<stack>/README.md read-list skeleton
│   ├── skills/                                ← artifacts that land in the product repo's .claude/skills/
│   │   └── persona-review/                    ← the persona review skill artifact (artifact-persona-authoring)
│   │       ├── persona-review-definition.md       ← the reader-persona review standard (one skill per persona)
│   │       └── persona-review-template.md         ← SKILL.md skeleton for a persona review skill (per reader)
│   ├── root/                                  ← artifacts that land at the product repo's root
│   │   └── asimov-md/                         ← the asimov.md context file (asimov-init)
│   │       ├── asimov-md-definition.md        ← what asimov.md must contain and how CLAUDE.md is touched
│   │       └── asimov-md-template.md          ← body of the file
│   └── project-management/                    ← project-management artifacts (planned; empty until the first lands)
├── contracts/                                 ← stage handoffs: what one stage's output must contain for the next stage to consume it. Not artifacts; read by skills by path
│   ├── design.md                              ← what a design must contain, nothing about who reads it or how; a design skill's output, a spec skill's input
│   └── specification.md                       ← what a specification (one plan, one or more tasks) must contain before Build; the line: names and signatures are the spec's, every body and test the builder's
├── resources/                                 ← building blocks shared across artifacts (not artifacts themselves)
│   └── diagrams/                              ← the 4 standard diagram notations a D101 may use
│       ├── README.md                          ← routing table: reader intent → diagram type
│       ├── sequence-template.svg              ← UML sequence
│       ├── activity-swimlane-template.svg     ← UML activity with swimlanes
│       ├── state-machine-template.svg         ← UML state machine
│       └── flowchart-template.svg             ← flowchart, ISO 5807 symbols
└── processes/                                 ← the Delivery Model corpus pm-advisor reads (generated export; do not edit here)
    ├── README.md                              ← meta-entry: vocabulary, draft caveat, "start at the framework"
    ├── delivery-model-framework.md            ← the map: the one idea, design principles, phase table
    ├── selection-guide.md                     ← which approach per phase; risky combinations
    ├── disciplines.md                         ← the 28-discipline catalogue
    ├── cross-cutting-layers.md                ← document chain, roles, cadence, level & zone, BVL
    ├── phases/                                ← proposal · scoping · development · operations
    ├── approaches/                            ← scrum · kanban · use-case-delivery · prototyping · launch-hyper-care
    └── disciplines/                           ← one page per discipline
documentation/                                 ← repo-level docs (NOT inside install scope)
├── D100-Asimov-architecture.md                ← WHY the toolkit exists + HOW it's built + the L3 process
├── model-choice.md                            ← (stage → command → model) canonical map; maintainer standard, not read at run-time
├── ai-transition-levels-and-zones.md          ← the Levels & Zones vocabulary Asimov uses (L0–L5, Z1–Z3, the nine L3 stages)
├── index.html                                 ← rendered landing page (this repo eats its own /asimov-init output)
├── _chrome.css                                ← rendered site chrome (copy of artifacts/documentation/site/_chrome.css)
├── features/D101-*.html                       ← per-feature D101s (authored as HTML)
└── research/                                  ← research notes that informed design decisions
```

## Key documents — read these first

| Doc | When |
|---|---|
| [`documentation/D100-Asimov-architecture.md`](documentation/D100-Asimov-architecture.md) | Always first — scope, intent, and system architecture (marketplace / plugin / pattern decisions) |
| [`plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md`](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md) | Before writing or reviewing any D101 |
| [`plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md`](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md) | Before authoring or reviewing a persona review skill (the reader-audience review layer) |
| [`plugins/asimov-plugin/contracts/design.md`](plugins/asimov-plugin/contracts/design.md) | Before changing what the Spec stage reads from a design, or adding a design form (research: `documentation/research/design-contract-research.md`) |
| [`plugins/asimov-plugin/contracts/specification.md`](plugins/asimov-plugin/contracts/specification.md) | Before changing what an S101 or an S102 carries, or where the line between the spec and the builder runs (research: `documentation/research/specification-contract-research.md`) |
| [`documentation/model-choice.md`](documentation/model-choice.md) | Before changing a command's or subagent's model |
| [`plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html) | When authoring a D101 (its leading comment holds the authoring ground rules + component catalogue) |
| [`plugins/asimov-plugin/resources/diagrams/README.md`](plugins/asimov-plugin/resources/diagrams/README.md) | Before drawing any diagram in a D101 (routing table: reader intent → diagram type → template; each template's leading comment holds its notation, node budget and geometry) |
| [`documentation/features/D101-codex-support.html`](documentation/features/D101-codex-support.html) | Before changing a manifest, a Codex-only skill or how a skill finds plugin files |
| [`documentation/features/D101-build-stage.html`](documentation/features/D101-build-stage.html) | Before changing how a plan is built: the batches, Baley then Powell, the ledger, the gate, the stops |

## Conventions

### Document codes
- `D100` — architecture doc (system-level)
- `D101` — feature design doc
- `S101` — implementation plan: one per design (a D101, or a ticket that meets `contracts/design.md`), the task graph; written by `asimov-spec` to `documentation/specs/<slug>/S101-<slug>.md`
- `S102` — task spec: one per task, the brief a build subagent receives; `documentation/specs/<slug>/S102-<slug>-NNN-<task>.md`
- `T100` — test strategy (none yet)

### L3 pipeline stages
*Intent → Design → Spec → Code → Review → Test → Approve → Deploy → Observe*. The toolkit covers the AI-assisted middle (Design through Test). See D100 §3.

### File naming
- Commands: `commands/<command-name>.md` (kebab-case, slash-stripped — e.g. `asimov-init.md` for `/asimov-init`); Claude Code only, so a new entry point is normally an asimov-skill
- Asimov-skills: `skills/asimov-<phase>[-<action>]/SKILL.md` + `agents/openai.yaml` beside it (`asimov-design`, `asimov-design-review`, `asimov-spec`, `asimov-build`); phase-named; a re-check is a path of the stage's skill, never a sibling (`asimov-spec-validate` was folded into `asimov-spec` on 2026-10-07)
- Subagents: `agents/<subagent-name>.md` (kebab-case)
- D101s: `documentation/features/D101-<feature-slug>.html` (kebab-case after `D101-`; authored as HTML)
- Artifact folders: `artifacts/<landing-place>/<artifact-slug>/` (kebab-case; the landing place is where the artifact ends up in a product repo — e.g. `artifacts/documentation/d101-feature-design/` for a D101, which lands in `documentation/features/`). Each folder holds the artifact's definition and template side by side
- Definitions: `<artifact>-definition.md` inside the artifact folder — the same `<artifact>` slug as the folder, so definition and template sort side by side and carry their artifact name when opened alone
- Templates: `<artifact>-template.<ext>` inside the artifact folder — the extension is the one the template renders as (`.html` for D101s and the site, `.md` for text bodies, `.svg` for diagrams). Specialised variants: `<artifact>-<variant>-template.<ext>`
- Resources: `resources/<kind>/` — building blocks shared across artifacts, never an artifact themselves
- Diagram templates: `resources/diagrams/<notation>-template.svg` (notation, not section — e.g. `state-machine-template.svg`)
- Contracts: `contracts/<stage-output>.md` (`design.md`, `specification.md`) — a plain noun for what a stage hands over, no code prefix. A contract lists members only: never its producers, readers, paths or a particular form

### Artifact maturity
Every artifact carries one level — `assess` / `trial` / `adopt` / `hold` (Technology Radar rings) — as a YAML block (`artifact`, `maturity`, `since`) at the top of its definition. The producing skill or command prints the level as one chat line before its first question (nothing for `adopt`) and never changes it. Levels move on evidence, never time: `trial` needs one artifact reviewed by a non-author, `adopt` a second repo plus a revision driven by use; rewriting the bar drops back to `assess`. D100 §4.5 mirrors the level (hard rule 10). Design: `documentation/features/D101-artifact-maturity.html`.

### Dates
Always `YYYY-MM-DD` (e.g. `2026-05-21`). Never American month/day. Never relative ("last Thursday").

### Manifest names vs repo name vs prose names
- Repo: `asimov` (GitHub)
- Marketplace manifest name: `asimov-marketplace` (in `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`)
- Plugin manifest name: `asimov-plugin` (in `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`; also the directory name `plugins/asimov-plugin/`)
- Friendly prose: "Asimov Plugin" (capitalised, used in headings + sentences)

### Codex-only skills
A skill only Codex should run is named `codex-<name>` (today: `skills/codex-asimov-init/`). Its frontmatter carries `disable-model-invocation: true` and `user-invocable: false`, so Claude Code neither lists nor runs it; its `agents/openai.yaml` carries `allow_implicit_invocation: false`. Codex invokes it as `$asimov-plugin:<skill-name>` (`$asimov-plugin:codex-asimov-init`). It never uses `${CLAUDE_PLUGIN_ROOT}` (Codex does not substitute it) and never a `../../` path (resolved from the working directory): it derives the plugin root from its own file path — two levels above the skill folder, verified by reading the first template, falling back to a Glob under `<home>/.codex/plugins/cache/` — as `skills/codex-asimov-init/SKILL.md` Step 1 does.

## How to add a new slash command

A slash command is Claude Code only. A new entry point is normally an asimov-skill (next section); a command remains the right shape only for something Codex should not run.

1. Decide which L3 stage the command belongs to (Design / Spec / Code / Review + Test, or ad-hoc like `/conventions-check`).
2. Add a row to `documentation/model-choice.md` (stage → command → model).
3. Cover it in the D101 of its artifact family — the Design-stage asimov-skills share `documentation/features/D101-design-stage.html`; a command for a new artifact gets that artifact's D101, written with `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`. Run `/asimov-design` — twice: once for requirements + business design (which lands the file at phase `Business design` with §6 open), then again for the technical design. Must clear both bars in `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md` — §8a before you move to §6, §8b before you request review.
4. Add a row to `documentation/D100-Asimov-architecture.md` §4.3 *Slash commands and asimov-skills*.
5. Author the command file at `plugins/asimov-plugin/commands/<command-name>.md` with YAML frontmatter (`description`, `argument-hint`, `model`).
6. Test locally — see "How to test" below.

## How to add a new subagent

A subagent is two layers. The **role skill** at `plugins/asimov-plugin/skills/role-<stack>-<role>/SKILL.md` carries the whole method — the six-field skeleton of D100 §7.2.1 (Role, Stack competence, Reads, Workflow, Boundaries, Output; plus Target for diff-scoped roles). It is the harness-portable layer: Claude Code and Codex both read it, and a main agent can use it directly where no subagent exists. The **shell** under `plugins/asimov-plugin/agents/` carries only identity and harness fields and points at the skill — one file per harness (`<name>.md` for Claude Code with `skills:` preloading the role skill; `<name>.toml` for Codex, a prototype whose discovery location is unverified). Subagent kinds follow the Accelerate roles — *planner / builder / tester / reviewer*, planner reserved (see D100 §4.4). Five exist (Giskard/.NET + Daneel/Angular builders, Calvin/.NET tester, Baley/reviewer, Powell/verifier at the Test stage). Neither *validation* of the Spec stage uses a subagent since 2026-10-08: the task-spec check is the script `scripts/validate-s102.ps1` and the plan check the script `scripts/validate-s101.ps1`, both run inline by `asimov-spec` through Bash (`artifact-s102-validation` and `artifact-s101-validation` are their specifications and the fallback where no PowerShell exists). The Spec stage's writers are the harness's `general-purpose` agent with the model passed on the call: the plan writer on Opus at high effort, the task writers on Sonnet (`model-choice.md` §1.2).

Naming: role skills are `role-<stack>-<accelerate-role>` (`role-dotnet-builder`, `role-angular-builder`, `role-dotnet-tester`), subject first like the shells (`giskard-the-dotnet-developer`) and the conventions folders (`conventions/<stack>/`). A role that spans stacks drops the stack (`role-code-reviewer`: only its read-list is stack-specific, so it is not split; `role-s102-verifier`: the test runner is the repo's). The skill body names roles, never Asimov personas — persona names live in the shells only.

1. Add a row to `documentation/model-choice.md` (stage → subagent → model). The model sits in the `.md` shell; skills declare none.
2. Cover it in the one subagent D101, `documentation/features/D101-subagents.html` — a row in its roster and, if the role is new in kind (planner, verifier), its own rules; never a new document per role.
3. Add a row to `documentation/D100-Asimov-architecture.md` §4.4 *Subagents* and, for the skill, §4.6 *Skills*.
4. Author the role skill at `plugins/asimov-plugin/skills/role-<stack>-<role>/SKILL.md` — frontmatter `name` + `description` only, description trigger-shaped and narrow.
5. Author the shells: `plugins/asimov-plugin/agents/<name>.md` (YAML frontmatter `name`, `description`, `model`, `skills:` list, `tools` if restricted; a three-line body naming the persona, the role and the skill) and `plugins/asimov-plugin/agents/<name>.toml` (same `name`/`description`, `developer_instructions` telling it to load the skill first, no model).
6. Test locally — see "How to test" below.

## How to add a persona review skill

A **persona review** reads a design document *as one of its intended readers* and reports where the document talks to its author instead of to that reader — the concrete form of `asimov-design-review` check 7. Personas ship as Claude Code **skills** named `persona-<slug>`, in two kinds: **standard** generic archetypes curated in the plugin (`plugins/asimov-plugin/skills/persona-*`, available on install) and **custom** product-specific readers authored into the **product repo** at `.claude/skills/persona-<slug>/SKILL.md`. A concrete reader is a product entity (hard rule 7), so custom personas stay local; only the *form* and the generic archetypes ship in the toolkit. The `persona-` prefix is the namespace (skill discovery is flat — a folder can't group them). Design: `documentation/features/D101-personas.html`.

What the toolkit owns:

1. `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md` — the canonical standard: what a persona review is, the five persona fields, the generic fail/reward catalogue, the output shape, and how it relates to `asimov-design-review` and Baley.
2. `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md` — the SKILL.md skeleton a persona is authored from. Its leading comment holds the authoring ground rules + an anonymised worked example.

To add a custom persona today: copy `persona-review-template.md`, fill in every `{{PLACEHOLDER}}` with the product-specific reader (keep the generic fails/rewards, reorder them, add domain-specific ones), strip the leading comment, and save as `.claude/skills/persona-<slug>/SKILL.md` in the product repo. The generated skill is **self-contained** — it inlines the method rather than reading the definition at run-time (a skill is an authored artifact, not a re-running command, so hard rule 3 does not apply to it). The `artifact-persona-authoring` skill automates this: it shows the roster (standard + custom) first, then interviews and scaffolds. A plain skill, not an asimov-skill, because it calls no other skill; named outside `persona-*` so the roster glob never takes it for a reader.

## How to add an advisory skill

An **advisory skill** answers questions from a body of reference material shipped in the plugin, rather than performing an action. `pm-advisor` is the first — it advises on the delivery model in `plugins/asimov-plugin/processes/`. It is the first member of a planned `pm-*` family.

1. Choose the family prefix (`pm-` for delivery/project-management advice) and a `<slug>`.
2. Author `plugins/asimov-plugin/skills/<prefix><slug>/SKILL.md` with YAML frontmatter carrying **only** `name` and `description` — no `model`, no `argument-hint`. The `description` is the trigger: name the topics and the phrasings that should activate it.
3. Give the body: a **navigation section** (which file to read first, how links resolve), an **intent → file routing table** over the reference corpus, and the **rules of engagement** (read before advising; recommend don't decide; stay inside the material; advisory only — never writes).
4. Reference the corpus by path (`${CLAUDE_PLUGIN_ROOT}/...`), never by inlining its content (hard rule 3).
5. No `documentation/model-choice.md` row (skills declare no model). No `plugin.json` / `marketplace.json` change (skills auto-discover).
6. D101 coverage joins the family's shared D101 when that is written — not one per skill.
7. Test locally — see "How to test" below.

## How to add an asimov-skill

An **asimov-skill** is a user-invoked skill that replaces a slash command: one `SKILL.md` that both Claude Code (`/asimov-<name>`) and Codex (`$asimov-plugin:asimov-<name>`) read, started only when a person names it. It carries the **conversation** of one run — which file, which questions, where it waits, what it prints — and **no method**: every cut, write and check is an `artifact-*` skill invoked by name (hard rule 3). The layer rule: an asimov-skill composes skills; a skill reads artifacts and calls no skill. `asimov-spec` was the first, `asimov-design` and `asimov-design-review` followed on 2026-10-02 and `asimov-build` on 2026-10-07; design and decisions in `documentation/features/D101-spec-stage.html` §4.2, §4.7, §6.1 and `documentation/features/D101-design-stage.html`.

1. Add a row to `documentation/model-choice.md` marked *Claude Code only* (Codex ignores the frontmatter model). The CI check reads `skills/asimov-*/SKILL.md` by folder name.
2. Cover it in its stage's D101 (the Design stage shares `D101-design-stage.html`, the Spec stage `D101-spec-stage.html`).
3. Add a row to D100 §4.3 and §4.6.
4. Author `plugins/asimov-plugin/skills/asimov-<name>/SKILL.md`: frontmatter `name`, `description`, `disable-model-invocation: true`, `argument-hint`, `model` (+ `effort`), `allowed-tools`; a body that narrates first, reads `$ARGUMENTS` (and says that a literal `$ARGUMENTS` means Codex, where the input is the text after the invocation), and invokes the artifact skills via the Skill tool. Paths as `${CLAUDE_PLUGIN_ROOT}/...` plus the Codex derived-root step of `D101-codex-support.html` §6.2 (cut the root from the skill's own path, verify by reading the definition, search the cache); never a `../../` path, which Codex resolves from the working directory.
5. Author `plugins/asimov-plugin/skills/asimov-<name>/agents/openai.yaml`: `interface.display_name`, `short_description`, `default_prompt`, and `policy.allow_implicit_invocation: false`.
6. A fresh subagent, where the design needs one, is the harness's generic read-only agent (`Explore` in Claude Code) given fixed text and paths; never a new file under `agents/`.
7. Test locally — see "How to test" below.

## How to add a stage contract

A **contract** under `plugins/asimov-plugin/contracts/` says what one stage's output must contain for the next stage to consume it, in whatever form that output takes. It is an interface: it lists members, each grounded in a published model, and nothing else. Its users point at it; it never points at them. `contracts/design.md` (Design → Spec) is the first; `contracts/specification.md` (Spec → Build) the second, written 2026-10-05.

1. Research first and write the note in `documentation/research/` (what the known models require; the decisions and why). The member list is the shortest the sources support.
2. Author `contracts/<stage-output>.md`: the members (required, required-when-present, optional), one line each on what the member must say and the models it rests on, and the rules. No producer, reader, path, skill or form named.
3. Each producing form's definition gains a "how X meets `contracts/<name>.md`" table (the D101 definition §3.1 is the model). A form that is not a repo file is normalised by the consuming stage into a shape that stage's definition fixes (S101 definition §9).
4. The consuming skills read the contract by path (hard rule 3) and the form through its members.
5. Sync: D100 §4.5 and §5, the quick map above, hard rule 3, and the D101 of the stage that consumes it.

## How to add a design form

A new kind of design (a page in another tool, another tracker) needs no new skill. Either its definition states how it provides every member of `contracts/design.md`, as the D101 definition §3.1 does, or `asimov-spec` normalises it into `documentation/specs/<slug>/design.md` in the shape the S101 definition §9 fixes. The only code-like change is the fetch: `asimov-spec` Step 01 says what it can read where; pasted text is the baseline every form has.

## How to test the plugin locally

### Claude Code

```
/plugin marketplace add <path-to-your-clone>
```

Then in any product repo:

```
/plugin install asimov-plugin
```

The slash commands become available. To pick up changes after editing:

```
/plugin marketplace update asimov-marketplace
```

No auto-reload.

### Codex

```
codex plugin marketplace add <path-to-your-clone>
codex plugin add asimov-plugin@asimov-marketplace
```

Codex loads the plugin's skills in a new session. A local marketplace is cached per version, so to pick up changes after editing, remove and add again:

```
codex plugin remove asimov-plugin@asimov-marketplace
codex plugin add asimov-plugin@asimov-marketplace
```

Then, in a product repo, run `$asimov-plugin:codex-asimov-init`.

## Hard rules

These are enforcement rules, not style preferences. Violations break the toolkit's contract.

1. **Manifest names and folder names stay in sync.** The `plugins/<name>/` directory, the `name` field in both plugin manifests (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`) and the plugin entry in both marketplace manifests (`.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`) — all the same string.
2. **Command/asimov-skill/subagent model in frontmatter MUST match the row in `documentation/model-choice.md`** — in the same commit (see model-choice.md §1 sync rule). CI checks `commands/*.md`, `agents/*.md` and `skills/asimov-*/SKILL.md`.
3. **Commands and skills reference definitions, templates and contracts by *path*, not by inlining content.** A command's or skill's prompt body says "read `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md`"; it doesn't paste the definition into the prompt. This keeps the doc-in-the-repo as the runtime source of truth (D100 §7.4). The same rule holds one layer up: a command references an `artifact-*` or `role-*` skill by name and never restates its method — the skill is the single home of the procedure, the command owns only the conversation sequence.
4. **D101s mature through two bars, and each bar's verdict belongs to a different person.** *Business-complete* (`d101-feature-design-definition.md` §2.1, checked by §8a) is the **author's** call — it's the gate that stops them writing §6 before the business shape holds. *Gap-free* (§2.2, checked by §8b) is the **human reviewer's** (≠ author) call. The author runs `asimov-design-review` or a self-preview to surface weak sections before requesting review; automating the gap-free verdict would collapse the reviewer-not-author gate. Never review a `Business design` document against §8b — a deliberately open §6 is *open*, not a failure.
   **Phase ≠ status.** The rendered D101 carries both axes in its top bar: **phase** (`Business design` → `Full design`, moved by the author) and **status** (`Draft` → `Approved`, moved by the business approver, normally only after §6 exists because the estimate depends on it). Neither implies the other; no command ever records an approval.
5. **An accepted deviation never covers a check.** A rule of `d101-feature-design-definition.md` may be deliberately declined and recorded in the D101 (§4.9) — named rule, one-sentence reason, accepter, date, written next to the element it excuses. It may **never** be written against a check from §8: that would replace *reaching* the gap-free bar with *being excused from* it, and the bar is what makes the reviewer-not-author gate mean anything. Two further limits are equally load-bearing: the record never stops the finding being reported (`asimov-design-review` prints it as **Accepted**, which never becomes Pass — the human reviewer must see what they are signing), and it is never stored outside the D101. `asimov-design-review` may honour a deviation but must never write or propose one. Design: `documentation/features/D101-design-stage.html` (accepted deviations, §4.4 and §6.4).
6. **No drift between D100, D101s, and code/manifests.** When you change one, run a quick grep for related references in the other docs. When a D101 is renamed, superseded or its R/NF/AC numbers change, grep for the old file name and the old numbers in `documentation/`, `CLAUDE.md`, `README.md`, `plugins/asimov-plugin/**` (definitions, templates, skills, commands) and repo config comments such as `.gitignore` — the definitions ship to every product repo, so a stale pointer there travels with each release.
7. **Don't bake product-specific identifiers into definitions, templates, or command prompts.** Path conventions (e.g. `documentation/features/`) are acceptable shared conventions; product entity names are not (D100 §8.4 reusability).
8. **Reusability across products is a goal, not a hope.** When in doubt, name something generically and add an example as illustration.
9. **Path-convention fork point:** the path convention `documentation/features/D101-*` is baked into `plugins/asimov-plugin/skills/asimov-design/SKILL.md` (the `.html` output path, the listing glob and the legacy `.md` render path) and `plugins/asimov-plugin/skills/asimov-design-review/SKILL.md` (the `.html`/`.md` listing glob), and into the two artifact skills `skills/artifact-d101-authoring/SKILL.md` (its trigger description and *Paths* section, including the `mockups/d101-<slug>/` sibling) and `skills/artifact-d101-gap-review/SKILL.md` (the mockup path it follows). `asimov-init.md` shares the same `documentation/` taxonomy (`features/`, `conventions/`, `reference/`, root `D100-*`/`E100-*`) and adds two more literals of its own: the `asimov.md` root location and the `<stack>` slugs under `conventions/`. `skills/codex-asimov-init/SKILL.md` shares the `documentation/` taxonomy and the `<stack>` slugs — not the `asimov.md` root location, which it does not write — and adds two of its own: the `AGENTS.md` managed-region marker pair (`asimov:start` / `asimov:end`) and the `.codex/agents/` delivery folder. The `D101-<slug>.review.md` sibling-file convention (`d101-feature-design-definition.md` §4.10) is a third literal shared by `asimov-design-review` (writer) and `asimov-design` (reader + deleter) and must move with the other two, and so must the `documentation/features/*.review.md` pattern in `.gitignore`, which fuses both literals. The D101 template's leading comment and `asimov-md-template.md`'s taxonomy table repeat the `documentation/features/D101-*` path as authoring guidance. A fork that uses a different layout changes the literal in *all* of these files — they must stay in lockstep. The delivery-model corpus path `plugins/asimov-plugin/processes/` is a fourth literal, and its lockstep partner is **not** inside the corpus — the corpus never names its own location. The literal lives in `skills/pm-advisor/SKILL.md` (the `${CLAUDE_PLUGIN_ROOT}/processes/` routing root) and in the vault's export target (`export-delivery-model.ps1 -Target plugin`, per `processes/README.md` *Refreshing*), which writes to this path from outside the repo. A fork that relocates the corpus changes the skill **and** tells the vault; editing this repo alone leaves the next export writing to the old path. The specs folder `documentation/specs/<slug>/` (with `S101-<slug>.md`, `S102-<slug>-NNN-<task>.md`, the committed ledger `S101-<slug>.ledger.md` and the three gitignored siblings `S101-<slug>.review.md`, `design.md` and `repo-notes.md`) is a fifth literal, shared by `skills/asimov-spec/SKILL.md`, `skills/asimov-build/SKILL.md`, the five `skills/artifact-s10x-*/SKILL.md`, `skills/artifact-s101-ledger/SKILL.md`, the `documentation/specs/*/S101-*.review.md`, `documentation/specs/*/design.md` and `documentation/specs/*/repo-notes.md` patterns in `.gitignore` and the same four-pattern block (with `documentation/features/*.review.md`) that `commands/asimov-init.md` and `skills/codex-asimov-init/SKILL.md` write into a product repo's `.gitignore` (Step 7, item 6) and that `skills/asimov-spec/SKILL.md` Step 01 appends when missing, both Spec-stage definitions (§9), the ledger definition (§7) and the three templates (leading comments), `asimov-md-template.md`'s command table and D100 §5 and §9; `asimov-spec` also carries the `documentation/features/D101-*.html` literal as its input path. Intentionally not a config — we don't have a config mechanism for one toggle.
10. **A maturity level and its D100 mirror move in the same commit.** The `maturity`/`since` block in an artifact's definition is the source; the *Maturity* column in D100 §4.5 is the mirror. Change one, change the other, and name the evidence for a promotion in the commit message. Same shape as rule 2.
11. **Both plugin manifests carry the same `version`, moved together in one commit.** `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` must show the same number; each tool detects an update by it, so bumping one and not the other leaves that tool on the old plugin. Same shape as rule 2.

## Research notes

Design decisions in this repo were informed by research captured in `documentation/research/`. When you reopen a decision, check whether the research still applies before re-deciding.

- [`industry-design-doc-standards.md`](documentation/research/industry-design-doc-standards.md) — DoR, INVEST, Rust RFC, MADR, EARS, Kiro, Augment, etc.
- [`L3-spec-format-research.md`](documentation/research/L3-spec-format-research.md) — format research for a single spec (Markdown + frontmatter, validator authority); two of its decisions revised by the next note
- [`S101-S102-spec-stage-research.md`](documentation/research/S101-S102-spec-stage-research.md) — the plan layer: how the field orders and parallelises tasks (Spec Kit, Kiro, OpenSpec, Conductor, superpowers, Beads, agent teams), and the S101/S102 decisions taken 2026-09-25
- [`design-contract-research.md`](documentation/research/design-contract-research.md) — what a design must contain before planning, across twelve traditions (DoR, INVEST, SbE, Shape Up, Google design docs, Rust RFC, ADR, 29148, EARS, Kiro, Spec Kit, PR/FAQ); the decisions behind `contracts/design.md`, 2026-10-02
- [`specification-contract-research.md`](documentation/research/specification-contract-research.md) — what a specification must contain before building, across fifteen traditions (INVEST, Scrum, 29148, IEEE 1016, SbE, Shape Up, Kiro, Spec Kit, OpenSpec, superpowers, Beads, Google, DbC, agent briefs, verification standards), and where they put the line between the spec and the implementer; the decisions behind `contracts/specification.md`, 2026-10-05
- [`additional-command-ideas.md`](documentation/research/additional-command-ideas.md) — which community/vendor slash commands fit the toolkit's L3 scope and reusability bar, and which don't

## Contributing

The contribution process for people outside the maintainer team is in `CONTRIBUTING.md` at the repo root (issue first for behaviour changes, D101 before prompt, reviewer ≠ author, MIT in = MIT out). Keep it and this file in step: the hard rules live here, the process lives there.

## Current state

Built: the two Design-stage asimov-skills `asimov-design` and `asimov-design-review` (2026-10-02; they replace the former `/d101-feature-design`, `/d101-review` and `/d101-convert-to-html` commands, the legacy render now a path in `asimov-design`) and the setup command `/asimov-init` (repo bootstrap — supersedes the former `/docs-init`), the three build subagents (Giskard/.NET + Daneel/Angular builders, Calvin/tests tester), the reviewer (Baley), the verifier (Powell, 2026-10-07), and the supporting definitions and templates. Marketplace + plugin are scaffolded; D101s are authored directly as HTML.

**Subagents are split into role skills + shells** (2026-09-28, for Codex support without maintaining each method twice): the method lives in `skills/{role-dotnet-builder,role-angular-builder,role-dotnet-tester,role-code-reviewer}`, the agent files are thin per-harness shells (`.md` for Claude Code, `.toml` for Codex). The `.toml` shells are a prototype — Codex discovery of a plugin-level `agents/` folder is unverified. Design: `features/D101-subagents.html` (Draft v0.2, 2026-09-28), which supersedes `D101-build-subagents` and `D101-baley-the-code-reviewer`. The same principle applied to the D101 commands (2026-09-28): `skills/artifact-d101-authoring` holds the rendering procedure, mockup rules and authoring invariants that the then `/d101-feature-design` and `/d101-convert-to-html` commands used to inline (and that a hand edit of a D101 never got), and `skills/artifact-d101-gap-review` holds the section walk, the §8a/§8b run and the report that the then `/d101-review` command used to run inline. The asimov-skills keep only the conversation — phases, stops, file choice, menu, notes file — and invoke the skills; the template's leading comment stays the single home of the component catalogue. Skill families: `role-*` (a subagent's method), `artifact-*` (how to author or review an artifact), `persona-*`, `pm-*`, `asimov-*` (user-invoked entry points, one file for both harnesses), `codex-*` (Codex-only entry points). Design: `features/D101-design-stage.html` (renamed 2026-10-02 from `D101-d101-feature-design` when the commands became asimov-skills), rewritten 2026-09-28 as the one D101 for the whole artifact — commands, skills, phases and axes, accepted deviations, review handoff — superseding `D101-d101-review`, `D101-d101-convert-to-html`, `D101-accepted-deviations` and `D101-review-handoff`. The `pm-advisor` skill (over the Delivery Model corpus in `plugins/asimov-plugin/processes/`) is in; it is the first of a planned `pm-*` family whose shared D101 is not yet written.

`asimov-design` runs in three phases — requirements, business design, technical design — and **stops** after the business design, writing the file with §6 declared open. The technical design needs a second invocation; a legacy `.md` named in the message is rendered to HTML instead. `asimov-design-review` is the review hub: it resolves the phase, then offers and runs the gap review against the matching bar plus the business- and technical-persona reviews (the persona reviews delegated to the persona skills). See D100 §4.3 and `d101-feature-design-definition.md` §2.

The **persona** layer is built: its standard, template, and design (`persona-review-definition.md`, `persona-review-template.md`, `features/D101-personas.html` at `Full design`), the `artifact-persona-authoring` skill (2026-10-02; it replaced the `artifact-persona-authoring` + `/persona-list` commands), and the three shipped standard personas (`skills/persona-{poseidon,athena,hermes}`). Persona skills are named `persona-<slug>` — **standard** generic archetypes shipped in the plugin, **custom** readers authored by `artifact-persona-authoring` into a product repo's `.claude/skills/`.

The **accepted-deviation** mechanism is built (hard rule 5): `d101-feature-design-definition.md` §4.9 plus two §7 anti-patterns and the §8 no-check limit, the `.accepted` markup and ground rule 14 in the D101 template, the `Accepted` severity and validity branch in `asimov-design-review`, the authoring branch in `asimov-design`, and the design in `features/D101-design-stage.html` (§4.4, §6.4). Its live use is NF3 of that same document, which carries the deviation that used to sit on NF2/NF3 of the old review D101.

The **review-handoff** mechanism is built (`d101-feature-design-definition.md` §4.10): `asimov-design-review` gains `Write`, scoped by prompt discipline to a sibling `D101-<slug>.review.md`, written by default after every run; `asimov-design` checks for it, offers it against a fingerprint check, folds accepted findings in, and deletes it once a write consumes it. Gitignored, never a record — design in `features/D101-design-stage.html` (R10–R11).

The **artifact-maturity** convention is built: every artifact under `artifacts/` opens with its maturity block, the three producing commands print the level as one chat line (Step 1b), D100 §4.5 mirrors it, and hard rule 10 keeps the two in step. Design: `features/D101-artifact-maturity.html` (`Full design`). Today: D101 `trial`, everything else `assess`.

The **Spec stage** is built (2026-10-02) and untried on a real design: the two definitions (`artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md`, bar *dispatch-ready*; `artifacts/documentation/s102-task-spec/s102-task-spec-definition.md`, bar *buildable blind*; both `assess`) and their templates, the four artifact skills (`artifact-s101-authoring`, `artifact-s102-authoring`, `artifact-s101-validation`, `artifact-s102-validation`) and the asimov-skill `asimov-spec` (one `SKILL.md` for Claude Code and Codex plus `agents/openai.yaml`; its sibling `asimov-spec-validate` was folded into it on 2026-10-07). Specs land in a product repo at `documentation/specs/<slug>/`, with two gitignored siblings: the `S101-<slug>.review.md` sidecar and, for a design that is not a repo file, the `design.md` cache. **What a design is** is the contract `plugins/asimov-plugin/contracts/design.md` (members only, grounded in `documentation/research/design-contract-research.md`): a D101 at Full design meets it (D101 definition §3.1), and a Jira ticket whose thread does is normalised into the cache in the shape the S101 definition §9 fixes, with ids given once. There is no S102 without a plan: a one-task ticket gets a one-task S101 (decided 2026-10-02, D101-spec-stage v0.15). `asimov-spec` takes its target from the words of the message that names it (a D101 slug or path, a Jira link or key, or pasted ticket text; no flags), reads the design and the repo, asks at most five questions with defaults, writes the S101 draft and **shows the cut**, then waits for the author's go before any S102 is written; after the go it writes each S102, validates it blind in a fresh read-only subagent (`Explore` in Claude Code), validates the plan as a whole, and finishes once. A third failed validation of one task, or a finding that names a design gap (`design:`), stops the run. Update vs rewrite on a re-run is decided by comparing the design's items with the S101's coverage map, then one question. Task tiers (`low`/`mid`/`high`) map to models in `model-choice.md` §1.1. Design: `features/D101-spec-stage.html` (`Full design`, Draft v0.15; §5 is the chat as the UI, with a mockup under `features/mockups/d101-spec-stage/`). Research: `documentation/research/S101-S102-spec-stage-research.md`, `documentation/research/design-contract-research.md`. Open: Q8 (checklist → script if two runs disagree), Q9 (who writes an Angular-only slice's acceptance test), Q12 (can the blind subagent reach Jira itself). Q11 is resolved 2026-10-02: `${CLAUDE_PLUGIN_ROOT}` in Claude Code, the derived-root step of `D101-codex-support.html` §6.2 in Codex.

**The Spec stage was re-based on `contracts/specification.md`** (2026-10-05), after the first real run (a Backend ticket, eleven tasks) showed every S102 carrying full method bodies and test classes, acceptance criteria that grepped the spec's own code, and private names fixed as contract. The contract draws the line: the specification fixes scope, the public names and signatures, the behaviour and the check; the builder owns every body, every private name and every test. In its wake: the S101 is a **phase tree** with one task per line (`id`, `title`, `role`, `tier`, `after`, `traces`; files and contract names live in the S102 headers), a body of six sections (Contracts, Constraints the design imposes, Coverage, Escalation, Review focus, Assumptions) and no phase prose; a tester task precedes the builder tasks in every slice, the Foundation holds the contracts as code plus whatever every slice builds against and never a slice's behaviour, and a close phase after the last slice is allowed. The S102 is five sections (Intent, Behaviour or an explicit *none*, Done-when, Constraints and stops, Out of scope) with `owns` / `consumes` / `produces` in its header, no code block but Gherkin, no steps, and no done-when that searches the source. **The person never reads the S101 file**: `artifact-s101-view` renders the fixed plan view in chat at the cut, at the end of a run and for the reviewer (the fifth Spec-stage artifact skill). Template workarounds a run had to make are reported to the sidecar's *Template findings*, not written into the plan. Research: `documentation/research/specification-contract-research.md`. `features/D101-spec-stage.html` still describes the 2026-10-02 shape and is rewritten after the first run on the new form.

**The Spec-stage flow was reworked** (2026-10-06, `D101-spec-stage.html` v0.17, Q13): people approve plans, agents approve task specs. The author's go at the cut is the S101's approval, written by `asimov-spec` into the header as `approved: { by, date, fingerprint }` (the fingerprint rule is the S101 definition §6: since 2026-10-07 the SHA-256 of what the plan view shows, the `phases:` tree and §2/§3/§6, 12 hex, never printed; the version is the approval's name); a clean blind check marks an S102 `status: validated` with the date; `asimov-spec` sets `ready` itself when the approval still matches the plan and every S102 is validated, and asks for the approval again when the finalise or a plan-level re-cut changed the S101. Nobody sets a status by hand and no reviewer step remains in the Spec stage (D100 §3 names the exception). The checks run before the cut is shown (a Fail is re-cut unseen, up to three times); every authoring and validation call runs in a fresh subagent (a `general-purpose` writer, an `Explore` validator) and the chat shows one line per call; a finding is one line in words and the raw reports go only to the sidecar; every message ends with what happens next. A `ready` plan named again is the re-check: intact, it offers a blind re-check; edited by hand, it re-validates everything and asks for the approval again. The S101 validation's F5 reads the `validated` marks instead of receiving reports. The §5 mockup `features/mockups/d101-spec-stage/plan-run.html` shows the new transcript.

**The Spec stage was sized for ticket work** (2026-10-07, plugin 0.5.0), after the first ticket-sized run (a two-criteria, two-file bug fix) cost 27 subagent calls and some 2.3M tokens for specs the build then did not use. Ten changes, all in the definitions, templates and skills: the Foundation exists only when the plan needs one (a name shared by tasks that may run together, or something every slice builds against), so a bug fix is one slice of two tasks, tester then builder; two criteria that pass in the same files share a slice and the slice question is not asked for a design with two or fewer criteria; a later slice's tester may come after an earlier slice's builder when they share a file, and maintenance work extends the existing test class; existing code is closed by the repo, never by §1 (an S102 header links it as `Name (path)`, the validators open the path, and §1 lists only names tasks produce for each other; a test name is never a contract); a scenario pinned from the review focus carries `@review-focus` and does not count toward the scenario threshold; the fingerprint covers what the view shows (the tree, §2, §3, §6, with a Constraints block added to the view), is computed once per approval and never printed, and every write that changes an approved part after an approval bumps the version, which is what the person sees (*approved v0.2*), while a §1-only change leaves both; the task specs of one batch and every blind check run at once, and the finalise runs only when a task spec was rewritten; task-level Flags reach the chat as a count and a Flag must name what would change; the design gate reports every missing member in one pass with a draft comment per member and says up front that the approval must be renewed. `D101-spec-stage.html` still describes the 2026-10-06 flow and is rewritten after the next run on this form.

**The Spec stage was tuned on the second ticket run's feedback** (2026-10-07, same plugin version, uncommitted on top of the ticket sizing), a two-task bug fix that still cost twelve subagents and about 1.1M tokens and whose plan view nobody could read at a glance. Fourteen findings, all in the definitions, templates and skills: a phase carries two fields, `checkpoint` (one sentence a person reads; the view prints it) and `check` (the command the verifier runs; never shown), because the validator had rewarded a shell command as the checkpoint; task titles are three to seven words and phase names two to five, the view is 80 columns wide, and the S102 file slug is three to five words of the title; the cut writes a gitignored `repo-notes.md` beside the S101 (files, names with paths, package types, the test fixture and runner, the commands) that the task-spec writers start from and the validators use only as a map; a Fail means a builder would be stuck or build the wrong thing, and a missing header entry for a name that resolves, a leftover date, a paraphrased generic stop or a restated constraint are Flags that never cost a rewrite; checks 6 and 10 of the S102 are matched line against line on subject and value, never by impression; the tester task carries a slice's scenarios (threshold five) and the builder's §2 is one line naming it, its done-when naming the tester's tests, so nothing is written twice; `consumes` has a form for a package type (`Name (package Id)`), a modified test file goes under `test`, a member of a consumed type needs no entry, and the stale execution-mode sentence left the S101 definition; the finalise runs only when a rewrite changed an S102 header or a plan finding names §1/§3/§6; full-mode validation carries the graph rows when the S101 is unchanged since the cut (`graph_passed`); the fingerprint command no longer reads awk's `$0`, which the harness substituted with the invocation's words so the approval silently never matched (the same command sits in the S101 definition §6, `asimov-spec`, `asimov-build` and `artifact-s101-ledger`); the design contract's "required when they exist" members are read as such, so a ticket with no open questions is not asked to say so; an approval the skill could not read in the source (pasted text) is recorded and printed as `unverified`, and a proxy approval as `who for whom`; every line after the go carries `[k/n]` and the step's time; and both init entry points write the four cache patterns into the product repo's `.gitignore`. Feedback file: the developer's run notes on SEC-1778, kept outside the repo. The same day a package-update run listed every `packages.lock.json` under `owns.modify`, the only move the header allowed, so the owned set gained a fourth list, `owns.regenerates` (globs allowed; files a build, restore or generator rewrites because of the task's edits, never edited by hand; outside size and disjointness; the builder runs the tool and never opens them; Baley checks them only for being what the hand edits imply; `asimov-build` commits them with the phase, resets them on a discard and leaves them out of Powell's tree hash): `contracts/specification.md` *Scope*, both S102 artifacts, the S102 skills, the S101 definition §4.3 and validation G4/G7, `asimov-build`, `role-code-reviewer`, `D101-build-stage.html` and the research note's decisions table. And the **blind check became a shape check** (same day, a developer's report that the validator "builds the entire thing"): `artifact-s102-validation` answers every row by reading text and looking a thing up (a key, a path, a declared name, an id in the design, a test name in the tester's list, a count), never by running a build or a test and never by judging content; its read list is closed (the template, the thresholds, the three files, the headers beside them, one lookup per named path) and the contracts and the S102 definition left it; both validators run on Sonnet through the Agent tool's `model` field (`model-choice.md` §1.2, new) and the fixed call carries a run ban. The one content defect the earlier validator found (a scenario that already passed) is now the author's to see at the cut and the reviewer's at the PR, by design. **A second developer's run the same day (SEC-1733, seven tasks, stopped after two: fifteen subagents, about 1.5M tokens, zero findings that would have cost anything in the build) turned the shape check into a script**, `scripts/validate-s102.ps1` (PowerShell 5.1 and 7; the S102 template is its schema, the thresholds come from the S101 definition §8.1; `asimov-spec` runs it inline through Bash, no subagent, and the skill's checklist is now the script's specification and the fallback where no PowerShell exists), and settled four more of its findings: S101 §1 lost its *Consumed by* column (the S102 header is the only record of consumption; the check is "the name is in §1 and the producer is upstream"), `owns` takes globs and a parallel overlap is a Flag the build serialises rather than a Fail that re-cuts, a `check` follows the done-when rule (never a search of the source) and §2 never repeats a `CLAUDE.md` rule, and the S102 gained a light form (§4.7) for `low` tasks, all of which one writer writes in one call after the go.

**The third run of SEC-1778 (2026-10-08, on the tree above) measured the shape, not the checks**: six cold-start subagents, some 690k tokens and thirty minutes for the same two-task fix, with the script doing its three checks in a second and no finding that mattered. The cut had walked the repo for 64 tool calls to write notes the writers then re-verified, one format Fail (a done-when without a code span) cost a 119k-token rewrite round, and the writers paid to reconcile the two definitions. Five changes: a **small plan** (a design with two or fewer acceptance criteria, in mode `new` or `rewrite`) is cut and has every task spec drafted by **one writer in one call** (`asimov-spec` Step 02 composes `artifact-s101-authoring` then `artifact-s102-authoring` in the same subagent; the drafts sit beside the S101 at the gate unvalidated, are deleted by any re-cut and at a stop, and are checked after the go; the hard rule reads "no S102 is checked or marked before the go, and none is written before it but a small plan's drafts"); the **S102 authoring skill runs `validate-s102.ps1` on its own output** and fixes format Fails before returning (its `self-check:` line), the caller's run being the record; the **cut reads the repo by a list, never a walk** (the files the design names, the test class, the owned project file, one declaring file per name; about fifteen calls for a ticket), and the task-spec writers take the notes as given; three **definition contradictions** closed: a review-focus line is pinned to the slice's **tester** (the file that carries the scenarios), never its builder; a test is named by its **class and scenario title**, never by a method name (the methods are the builder's, per the contract), in both the tester's and the builder's done-when; and the plan validator's package rule accepts a reference from **any** project file, as the script does; the S101 template's *Stops specific to this plan* is a sub-list; and `asimov-spec` **appends the four cache patterns to the product repo's `.gitignore`** when missing, so a repo initialised before 2026-10-07 commits no cache. **The same day, the deep dive on where the thirty minutes went** (the fixed reading per subagent, 133 KB of standards before the first repo file; two LLM validator cold starts; xhigh thinking across sixty tool calls; writers inheriting the session's model) made four more changes: the **plan check is a script**, `scripts/validate-s101.ps1` (both modes, every G/F row and the ten checks by enumeration; a D101's ids read from its `id`/`ac-id` spans, a cache's from its numbered items; identical on PowerShell 5.1 and 7), so a small plan has exactly one LLM subagent; the **writers no longer read the definitions or the contracts** (the authoring skill is the method, the template the shape, the script the bar; the S101 writer reads the template, the §8.1 thresholds block and the design, the S102 writer the template and the plan), and `asimov-spec` reads only the maturity blocks, §9 and `contracts/design.md`; the **models moved**: `asimov-spec` runs on Sonnet 5.5 at default effort, the plan writer on Opus 5.5 at `high` (`model: opus`, `effort: high` on the Agent call; the one Opus call of a run), the task writers on Sonnet 5.5 (`model: sonnet`), every writer call passing its model explicitly because a developer's run showed writers inheriting the session's model; `model-choice.md` §1 and §1.2 and D100 §4.3 carry the new rows. The S101 validation skill keeps its checklist as the script's specification; `graph_passed` is gone, since re-answering every row costs a second.

**The Build stage is built** (2026-10-07, `D101-build-stage.html` at Full design) and untried on a real plan: `asimov-build` takes a `ready` S101 (approval fingerprint intact, a feature branch, a clean tree) and builds it phase by phase; each task goes to a fresh subagent of the shell its role names with the S102 as its only brief and the tier's model, tasks with disjoint owned files in one batch at once; once a phase is built, Baley reviews its diff against the task specs (the reviewer skill's new *vs. spec* target and third table) and then Powell, the new verifier (`agents/powell-the-verifier.{md,toml}`, `skills/role-s102-verifier`), runs every done-when and the checkpoint as written, the tree hashed before and after; a failed task is rebuilt with the findings, three attempts, the third a stop. The checkpoint is shown and the person's go commits the phase's owned files and the ledger as one commit. Run state is the committed `documentation/specs/<slug>/S101-<slug>.ledger.md` (`artifacts/documentation/s101-ledger/`, bar *resumable*, `assess`; written only by `skills/artifact-s101-ledger`), so a run resumes anywhere and the PR carries the reports (D100 Q5 resolved); the run changes nothing else in the specs but the S101 status `ready` → `in progress` → `done`. Every stop reaches the person, who rules: resume with a note, discard the phase, or stop. `execution_mode` left the S101: one execution mode, an Asimov agent per task, both harnesses. Open: Q1 fewer gates than every phase; Q2 whether Codex can spawn the copied shells from a skill (a spike before AC3).

Not built yet: `/conventions-check` — D100 §9. Still a command: `/asimov-init`.

**Codex support** (2026-10-01): the same plugin folder installs in Codex. Built: the Codex marketplace manifest `.agents/plugins/marketplace.json` (same `asimov-marketplace`, same plugin folder as `.claude-plugin/marketplace.json`); the Codex plugin manifest `plugins/asimov-plugin/.codex-plugin/plugin.json` (same `asimov-plugin`, `"skills": "./skills/"`) beside `.claude-plugin/plugin.json`; and the Codex-only setup entry point `skills/codex-asimov-init/` (`$asimov-plugin:codex-asimov-init`, the counterpart of `/asimov-init`, whose command file is unchanged). It derives the plugin root from its own file path (Step 1) and writes four targets: an `AGENTS.md` managed region (`asimov:start` / `asimov:end` markers) rendered directly from `asimov-md-template.md`, byte-for-byte copies of the plugin's `agents/*.toml` into the product repo's `.codex/agents/`, the `documentation/conventions/<stack>/README.md` read-lists, and the documentation site. `asimov.md` and the `@asimov.md` import in `CLAUDE.md` are written by `/asimov-init` only. `pm-advisor` uses `${CLAUDE_PLUGIN_ROOT}` alone and so finds its corpus only in Claude Code; the `artifact-d101-*` skills derive the plugin root in Codex since 2026-10-02, as the Spec-stage skills do. Codex does not load `commands/`, so the remaining slash command (`/asimov-init`) is Claude Code only. Design: `features/D101-codex-support.html`.

**Plugin layout is per artifact, not per file kind** (restructured 2026-09-10; the former `definitions/` and `templates/` folders are gone). `artifacts/<landing-place>/<artifact-slug>/` holds an artifact's definition and template together, grouped by where the artifact lands in a product repo; `resources/` holds the building blocks shared across artifacts. `model-choice.md` is a maintainer standard no command reads at run-time, so it lives outside install scope next to D100.
