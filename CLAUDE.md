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
│   ├── d101-feature-design.md                 ← authors D101s directly as HTML
│   ├── d101-review.md                         ← review hub: resolves the phase, offers + runs the gap review (§8a/§8b) and the business/technical persona reviews (delegated to persona skills)
│   ├── d101-convert-to-html.md                ← legacy MD → HTML
│   ├── asimov-init.md                         ← bootstraps a repo for Asimov (asimov.md + CLAUDE.md + conventions + site)
│   ├── persona-new.md                         ← interviews for a custom persona → writes .claude/skills/persona-<slug>/
│   └── persona-list.md                        ← lists persona review skills (standard + custom)
├── agents/                                    ← subagent shells: identity + harness fields only; the method is a role skill. One .md (Claude Code) + one .toml (Codex, prototype) per subagent
│   ├── giskard-the-dotnet-developer.{md,toml} ← .NET developer (Giskard) → skills/role-dotnet-builder — D101-subagents
│   ├── daneel-the-angular-developer.{md,toml} ← Angular developer (Daneel) → skills/role-angular-builder
│   ├── calvin-the-test-author.{md,toml}       ← test author (Calvin) → skills/role-dotnet-tester
│   └── baley-the-code-reviewer.{md,toml}      ← reviewer (Baley) → skills/role-code-reviewer — D101-subagents
├── skills/                                    ← skills (shipped; active in any repo). The harness-portable layer: what both Claude Code and Codex read
│   ├── asimov-spec/                           ← asimov-skill (user-invoked): the Spec-stage planning run — questions, the cut, the gate, the loop. SKILL.md + agents/openai.yaml (Codex)
│   ├── asimov-spec-validate/                  ← asimov-skill (user-invoked): both validations on an existing plan; writes only the sidecar
│   ├── artifact-s101-authoring/SKILL.md       ← artifact skill: cut a D101 into an S101 and return the cut summary
│   ├── artifact-s102-authoring/SKILL.md       ← artifact skill: one S102 from one graph entry (or a lone ticket)
│   ├── artifact-s101-validation/SKILL.md      ← artifact skill: the plan checks, graph-only (at the cut) or full
│   ├── artifact-s102-validation/SKILL.md      ← artifact skill: the blind S102 check, loaded by a fresh read-only subagent
│   ├── role-dotnet-builder/SKILL.md                ← role skill: the .NET builder method (Giskard's body)
│   ├── role-angular-builder/SKILL.md               ← role skill: the Angular builder method (Daneel's body)
│   ├── role-dotnet-tester/SKILL.md                 ← role skill: the .NET tester method (Calvin's body)
│   ├── role-code-reviewer/SKILL.md                 ← role skill: the changeset review method, all stacks (Baley's body)
│   ├── artifact-d101-authoring/SKILL.md       ← artifact skill: how to write/change a D101 (rendering procedure + invariants); used by /d101-feature-design, /d101-convert-to-html and any hand edit
│   ├── artifact-d101-gap-review/SKILL.md      ← artifact skill: the D101 gap review (section walk + §8a/§8b + report); /d101-review delegates to it
│   ├── persona-poseidon/SKILL.md              ← operational-reality reader
│   ├── persona-athena/SKILL.md                ← technical-feasibility reader
│   ├── persona-hermes/SKILL.md                ← cost/ROI reader
│   ├── pm-advisor/SKILL.md                    ← advises on the delivery model in processes/ (routing table; read-only)
│   └── codex-asimov-init/SKILL.md             ← Codex-only setup entry point ($asimov-plugin:codex-asimov-init), counterpart of commands/asimov-init.md
├── artifacts/                                 ← one folder per artifact the toolkit writes into a product repo; sub-folder = where it lands
│   ├── documentation/                         ← artifacts that land in the product repo's documentation/
│   │   ├── d101-feature-design/               ← the D101 artifact: definition + template side by side
│   │   │   ├── d101-feature-design-definition.md  ← the two bars for D101s (§8a business-complete, §8b gap-free)
│   │   │   └── d101-feature-design-template.html  ← visual + structural contract every D101 follows
│   │   ├── s101-implementation-plan/          ← the S101 artifact (Spec stage): the task graph for one D101
│   │   │   ├── s101-implementation-plan-definition.md  ← the dispatch-ready bar; §8.1 size thresholds; §9 the specs folder + sidecar
│   │   │   └── s101-implementation-plan-template.md    ← graph once in YAML frontmatter, body by task id, Assumptions last
│   │   ├── s102-task-spec/                    ← the S102 artifact (Spec stage): one task for one builder
│   │   │   ├── s102-task-spec-definition.md   ← the buildable-blind bar; validated blind
│   │   │   └── s102-task-spec-template.md     ← header copied from the graph entry; eight sections
│   │   ├── site/                              ← the documentation/ landing site (asimov-init)
│   │   │   ├── site-definition.md             ← what the rendered site must contain
│   │   │   ├── site-template.html            ← landing-page template
│   │   │   └── _chrome.css                    ← shared site chrome, copied verbatim
│   │   └── conventions/                       ← documentation/conventions/ (asimov-init)
│   │       ├── conventions-definition.md      ← what a per-stack read-list must contain
│   │       └── conventions-readme-template.md ← conventions/<stack>/README.md read-list skeleton
│   ├── skills/                                ← artifacts that land in the product repo's .claude/skills/
│   │   └── persona-review/                    ← the persona review skill artifact (persona-new)
│   │       ├── persona-review-definition.md       ← the reader-persona review standard (one skill per persona)
│   │       └── persona-review-template.md         ← SKILL.md skeleton for a persona review skill (per reader)
│   ├── root/                                  ← artifacts that land at the product repo's root
│   │   └── asimov-md/                         ← the asimov.md context file (asimov-init)
│   │       ├── asimov-md-definition.md        ← what asimov.md must contain and how CLAUDE.md is touched
│   │       └── asimov-md-template.md          ← body of the file
│   └── project-management/                    ← project-management artifacts (planned; empty until the first lands)
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
├── model-choice.md                            ← (stage → command → model) canonical map; maintainer contract, not read at run-time
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
| [`documentation/model-choice.md`](documentation/model-choice.md) | Before changing a command's or subagent's model |
| [`plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html) | When authoring a D101 (its leading comment holds the authoring ground rules + component catalogue) |
| [`plugins/asimov-plugin/resources/diagrams/README.md`](plugins/asimov-plugin/resources/diagrams/README.md) | Before drawing any diagram in a D101 (routing table: reader intent → diagram type → template; each template's leading comment holds its notation, node budget and geometry) |
| [`documentation/features/D101-codex-support.html`](documentation/features/D101-codex-support.html) | Before changing a manifest, a Codex-only skill or how a skill finds plugin files |

## Conventions

### Document codes
- `D100` — architecture doc (system-level)
- `D101` — feature design doc
- `S101` — implementation plan: one per D101, the task graph; written by `asimov-spec` to `documentation/specs/<slug>/S101-<slug>.md`
- `S102` — task spec: one per task, the brief a build subagent receives; `documentation/specs/<slug>/S102-<slug>-NNN-<task>.md`
- `T100` — test strategy (none yet)

### L3 pipeline stages
*Intent → Design → Spec → Code → Review → Test → Approve → Deploy → Observe*. The toolkit covers the AI-assisted middle (Design through Test). See D100 §3.

### File naming
- Commands: `commands/<command-name>.md` (kebab-case, slash-stripped — e.g. `d101-feature-design.md` for `/d101-feature-design`)
- Asimov-skills: `skills/asimov-<phase>[-<action>]/SKILL.md` + `agents/openai.yaml` beside it (e.g. `asimov-spec`, `asimov-spec-validate`); phase-named, so `asimov-design`/`asimov-build` are the future siblings
- Subagents: `agents/<subagent-name>.md` (kebab-case)
- D101s: `documentation/features/D101-<feature-slug>.html` (kebab-case after `D101-`; authored as HTML)
- Artifact folders: `artifacts/<landing-place>/<artifact-slug>/` (kebab-case; the landing place is where the artifact ends up in a product repo — e.g. `artifacts/documentation/d101-feature-design/` for a D101, which lands in `documentation/features/`). Each folder holds the artifact's definition and template side by side
- Definitions: `<artifact>-definition.md` inside the artifact folder — the same `<artifact>` slug as the folder, so definition and template sort side by side and carry their artifact name when opened alone
- Templates: `<artifact>-template.<ext>` inside the artifact folder — the extension is the one the template renders as (`.html` for D101s and the site, `.md` for text bodies, `.svg` for diagrams). Specialised variants: `<artifact>-<variant>-template.<ext>`
- Resources: `resources/<kind>/` — building blocks shared across artifacts, never an artifact themselves
- Diagram templates: `resources/diagrams/<notation>-template.svg` (notation, not section — e.g. `state-machine-template.svg`)

### Artifact maturity
Every artifact carries one level — `assess` / `trial` / `adopt` / `hold` (Technology Radar rings) — as a YAML block (`artifact`, `maturity`, `since`) at the top of its definition. The producing command prints the level as one chat line before its first question (nothing for `adopt`) and never changes it. Levels move on evidence, never time: `trial` needs one artifact reviewed by a non-author, `adopt` a second repo plus a revision driven by use; rewriting the bar drops back to `assess`. D100 §4.5 mirrors the level (hard rule 10). Design: `documentation/features/D101-artifact-maturity.html`.

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

1. Decide which L3 stage the command belongs to (Design / Spec / Code / Review + Test, or ad-hoc like `/conventions-check`).
2. Add a row to `documentation/model-choice.md` (stage → command → model).
3. Cover it in the D101 of its artifact family — the D101 commands share `documentation/features/D101-d101-feature-design.html`; a command for a new artifact gets that artifact's D101, written with `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`. Run `/d101-feature-design` — twice: once for requirements + business design (which lands the file at phase `Business design` with §6 open), then again for the technical design. Must clear both bars in `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md` — §8a before you move to §6, §8b before you request review.
4. Add a row to `documentation/D100-Asimov-architecture.md` §4.3 *Slash commands*.
5. Author the command file at `plugins/asimov-plugin/commands/<command-name>.md` with YAML frontmatter (`description`, `argument-hint`, `model`).
6. Test locally — see "How to test" below.

## How to add a new subagent

A subagent is two layers. The **role skill** at `plugins/asimov-plugin/skills/role-<stack>-<role>/SKILL.md` carries the whole method — the six-field skeleton of D100 §7.2.1 (Role, Stack competence, Reads, Workflow, Boundaries, Output; plus Target for diff-scoped roles). It is the harness-portable layer: Claude Code and Codex both read it, and a main agent can use it directly where no subagent exists. The **shell** under `plugins/asimov-plugin/agents/` carries only identity and harness fields and points at the skill — one file per harness (`<name>.md` for Claude Code with `skills:` preloading the role skill; `<name>.toml` for Codex, a prototype whose discovery location is unverified). Subagent kinds follow the Accelerate roles — *planner / builder / tester / reviewer*, planner reserved (see D100 §4.4). Four exist (Giskard/.NET + Daneel/Angular builders, Calvin/.NET tester, Baley/reviewer); the S102 verification subagent (Test stage) is planned but not built yet. The blind S102 *validation* of the Spec stage uses no Asimov subagent: it is the harness's generic read-only agent loading `artifact-s102-validation`.

Naming: role skills are `role-<stack>-<accelerate-role>` (`role-dotnet-builder`, `role-angular-builder`, `role-dotnet-tester`), subject first like the shells (`giskard-the-dotnet-developer`) and the conventions folders (`conventions/<stack>/`). A role that spans stacks drops the stack (`role-code-reviewer`: only its read-list is stack-specific, so it is not split). The skill body names roles, never Asimov personas — persona names live in the shells only.

1. Add a row to `documentation/model-choice.md` (stage → subagent → model). The model sits in the `.md` shell; skills declare none.
2. Cover it in the one subagent D101, `documentation/features/D101-subagents.html` — a row in its roster and, if the role is new in kind (planner, verifier), its own rules; never a new document per role.
3. Add a row to `documentation/D100-Asimov-architecture.md` §4.4 *Subagents* and, for the skill, §4.6 *Skills*.
4. Author the role skill at `plugins/asimov-plugin/skills/role-<stack>-<role>/SKILL.md` — frontmatter `name` + `description` only, description trigger-shaped and narrow.
5. Author the shells: `plugins/asimov-plugin/agents/<name>.md` (YAML frontmatter `name`, `description`, `model`, `skills:` list, `tools` if restricted; a three-line body naming the persona, the role and the skill) and `plugins/asimov-plugin/agents/<name>.toml` (same `name`/`description`, `developer_instructions` telling it to load the skill first, no model).
6. Test locally — see "How to test" below.

## How to add a persona review skill

A **persona review** reads a design document *as one of its intended readers* and reports where the document talks to its author instead of to that reader — the concrete form of `/d101-review` check 7. Personas ship as Claude Code **skills** named `persona-<slug>`, in two kinds: **standard** generic archetypes curated in the plugin (`plugins/asimov-plugin/skills/persona-*`, available on install) and **custom** product-specific readers authored into the **product repo** at `.claude/skills/persona-<slug>/SKILL.md`. A concrete reader is a product entity (hard rule 7), so custom personas stay local; only the *form* and the generic archetypes ship in the toolkit. The `persona-` prefix is the namespace (skill discovery is flat — a folder can't group them). Design: `documentation/features/D101-personas.html`.

What the toolkit owns:

1. `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md` — the canonical standard: what a persona review is, the five persona fields, the generic fail/reward catalogue, the output shape, and how it relates to `/d101-review` and Baley.
2. `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md` — the SKILL.md skeleton a persona is authored from. Its leading comment holds the authoring ground rules + an anonymised worked example.

To add a custom persona today: copy `persona-review-template.md`, fill in every `{{PLACEHOLDER}}` with the product-specific reader (keep the generic fails/rewards, reorder them, add domain-specific ones), strip the leading comment, and save as `.claude/skills/persona-<slug>/SKILL.md` in the product repo. The generated skill is **self-contained** — it inlines the method rather than reading the definition at run-time (a skill is an authored artifact, not a re-running command, so hard rule 3 does not apply to it). The `/persona-new` command automates this interview-and-scaffold step, and `/persona-list` shows the whole roster (standard + custom).

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

An **asimov-skill** is a user-invoked skill that replaces a slash command: one `SKILL.md` that both Claude Code (`/asimov-<name>`) and Codex (`$asimov-plugin:asimov-<name>`) read, started only when a person names it. It carries the **conversation** of one run — which file, which questions, where it waits, what it prints — and **no method**: every cut, write and check is an `artifact-*` skill invoked by name (hard rule 3). The layer rule: an asimov-skill composes skills; a skill reads artifacts and calls no skill. `asimov-spec` and `asimov-spec-validate` are the first two; design and decisions in `documentation/features/D101-spec-stage.html` §4.2, §4.7, §6.1.

1. Add a row to `documentation/model-choice.md` marked *Claude Code only* (Codex ignores the frontmatter model). The CI check reads `skills/asimov-*/SKILL.md` by folder name.
2. Cover it in its stage's D101 (the Spec stage shares `D101-spec-stage.html`).
3. Add a row to D100 §4.3 and §4.6.
4. Author `plugins/asimov-plugin/skills/asimov-<name>/SKILL.md`: frontmatter `name`, `description`, `disable-model-invocation: true`, `argument-hint`, `model` (+ `effort`), `allowed-tools`; a body that narrates first, reads `$ARGUMENTS` (and says that a literal `$ARGUMENTS` means Codex, where the input is the text after the invocation), and invokes the artifact skills via the Skill tool. Paths as `${CLAUDE_PLUGIN_ROOT}/...` plus the Codex derived-root step of `D101-codex-support.html` §6.2 (cut the root from the skill's own path, verify by reading the definition, search the cache); never a `../../` path, which Codex resolves from the working directory.
5. Author `plugins/asimov-plugin/skills/asimov-<name>/agents/openai.yaml`: `interface.display_name`, `short_description`, `default_prompt`, and `policy.allow_implicit_invocation: false`.
6. A fresh subagent, where the design needs one, is the harness's generic read-only agent (`Explore` in Claude Code) given fixed text and paths; never a new file under `agents/`.
7. Test locally — see "How to test" below.

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
3. **Commands and skills reference definitions and templates by *path*, not by inlining content.** A command's or skill's prompt body says "read `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md`"; it doesn't paste the definition into the prompt. This keeps the doc-in-the-repo as the runtime source of truth (D100 §7.4). The same rule holds one layer up: a command references an `artifact-*` or `role-*` skill by name and never restates its method — the skill is the single home of the procedure, the command owns only the conversation sequence.
4. **D101s mature through two bars, and each bar's verdict belongs to a different person.** *Business-complete* (`d101-feature-design-definition.md` §2.1, checked by §8a) is the **author's** call — it's the gate that stops them writing §6 before the business shape holds. *Gap-free* (§2.2, checked by §8b) is the **human reviewer's** (≠ author) call. The author runs `/d101-review` or a self-preview to surface weak sections before requesting review; automating the gap-free verdict would collapse the reviewer-not-author gate. Never review a `Business design` document against §8b — a deliberately open §6 is *open*, not a failure.
   **Phase ≠ status.** The rendered D101 carries both axes in its top bar: **phase** (`Business design` → `Full design`, moved by the author) and **status** (`Draft` → `Approved`, moved by the business approver, normally only after §6 exists because the estimate depends on it). Neither implies the other; no command ever records an approval.
5. **An accepted deviation never covers a check.** A rule of `d101-feature-design-definition.md` may be deliberately declined and recorded in the D101 (§4.9) — named rule, one-sentence reason, accepter, date, written next to the element it excuses. It may **never** be written against a check from §8: that would replace *reaching* the gap-free bar with *being excused from* it, and the bar is what makes the reviewer-not-author gate mean anything. Two further limits are equally load-bearing: the record never stops the finding being reported (`/d101-review` prints it as **Accepted**, which never becomes Pass — the human reviewer must see what they are signing), and it is never stored outside the D101. `/d101-review` may honour a deviation but must never write or propose one. Design: `documentation/features/D101-d101-feature-design.html` (accepted deviations, §4.4 and §6.4).
6. **No drift between D100, D101s, and code/manifests.** When you change one, run a quick grep for related references in the other docs. When a D101 is renamed, superseded or its R/NF/AC numbers change, grep for the old file name and the old numbers in `documentation/`, `CLAUDE.md`, `README.md`, `plugins/asimov-plugin/**` (definitions, templates, skills, commands) and repo config comments such as `.gitignore` — the definitions ship to every product repo, so a stale pointer there travels with each release.
7. **Don't bake product-specific identifiers into definitions, templates, or command prompts.** Path conventions (e.g. `documentation/features/`) are acceptable shared conventions; product entity names are not (D100 §8.4 reusability).
8. **Reusability across products is a goal, not a hope.** When in doubt, name something generically and add an example as illustration.
9. **Path-convention fork point:** the path convention `documentation/features/D101-*` is baked into `plugins/asimov-plugin/commands/d101-feature-design.md` (the `.html` output path + listing glob), `plugins/asimov-plugin/commands/d101-review.md` (the `.html`/`.md` auto-detect glob), and `plugins/asimov-plugin/commands/d101-convert-to-html.md` (the `.md` source glob), and into the two artifact skills `skills/artifact-d101-authoring/SKILL.md` (its trigger description and *Paths* section, including the `mockups/d101-<slug>/` sibling) and `skills/artifact-d101-gap-review/SKILL.md` (the mockup path it follows). `asimov-init.md` shares the same `documentation/` taxonomy (`features/`, `conventions/`, `reference/`, root `D100-*`/`E100-*`) and adds two more literals of its own: the `asimov.md` root location and the `<stack>` slugs under `conventions/`. `skills/codex-asimov-init/SKILL.md` shares the `documentation/` taxonomy and the `<stack>` slugs — not the `asimov.md` root location, which it does not write — and adds two of its own: the `AGENTS.md` managed-region marker pair (`asimov:start` / `asimov:end`) and the `.codex/agents/` delivery folder. The `D101-<slug>.review.md` sibling-file convention (`d101-feature-design-definition.md` §4.10) is a third literal shared by `d101-review.md` (writer) and `d101-feature-design.md` (reader + deleter) and must move with the other two, and so must the `documentation/features/*.review.md` pattern in `.gitignore`, which fuses both literals. The D101 template's leading comment and `asimov-md-template.md`'s taxonomy table repeat the `documentation/features/D101-*` path as authoring guidance. A fork that uses a different layout changes the literal in *all* of these files — they must stay in lockstep. The delivery-model corpus path `plugins/asimov-plugin/processes/` is a fourth literal, and its lockstep partner is **not** inside the corpus — the corpus never names its own location. The literal lives in `skills/pm-advisor/SKILL.md` (the `${CLAUDE_PLUGIN_ROOT}/processes/` routing root) and in the vault's export target (`export-delivery-model.ps1 -Target plugin`, per `processes/README.md` *Refreshing*), which writes to this path from outside the repo. A fork that relocates the corpus changes the skill **and** tells the vault; editing this repo alone leaves the next export writing to the old path. The specs folder `documentation/specs/<slug>/` (with `S101-<slug>.md`, `S102-<slug>-NNN-<task>.md` and the two gitignored siblings `S101-<slug>.review.md` and `ticket.md`) is a fifth literal, shared by `skills/asimov-spec/SKILL.md`, `skills/asimov-spec-validate/SKILL.md`, `skills/artifact-s101-authoring/SKILL.md`, `skills/artifact-s102-authoring/SKILL.md`, the `documentation/specs/*/S101-*.review.md` and `documentation/specs/*/ticket.md` patterns in `.gitignore`, both Spec-stage definitions (§9) and templates (leading comments), `asimov-md-template.md`'s command table and D100 §5 and §9; `asimov-spec` also carries the `documentation/features/D101-*.html` literal as its input path. Intentionally not a config — we don't have a config mechanism for one toggle.
10. **A maturity level and its D100 mirror move in the same commit.** The `maturity`/`since` block in an artifact's definition is the source; the *Maturity* column in D100 §4.5 is the mirror. Change one, change the other, and name the evidence for a promotion in the commit message. Same shape as rule 2.
11. **Both plugin manifests carry the same `version`, moved together in one commit.** `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` must show the same number; each tool detects an update by it, so bumping one and not the other leaves that tool on the old plugin. Same shape as rule 2.

## Research notes

Design decisions in this repo were informed by research captured in `documentation/research/`. When you reopen a decision, check whether the research still applies before re-deciding.

- [`industry-design-doc-standards.md`](documentation/research/industry-design-doc-standards.md) — DoR, INVEST, Rust RFC, MADR, EARS, Kiro, Augment, etc.
- [`L3-spec-format-research.md`](documentation/research/L3-spec-format-research.md) — format research for a single spec (Markdown + frontmatter, validator authority); two of its decisions revised by the next note
- [`S101-S102-spec-stage-research.md`](documentation/research/S101-S102-spec-stage-research.md) — the plan layer: how the field orders and parallelises tasks (Spec Kit, Kiro, OpenSpec, Conductor, superpowers, Beads, agent teams), and the S101/S102 decisions taken 2026-09-25
- [`additional-command-ideas.md`](documentation/research/additional-command-ideas.md) — which community/vendor slash commands fit the toolkit's L3 scope and reusability bar, and which don't

## Contributing

The contribution process for people outside the maintainer team is in `CONTRIBUTING.md` at the repo root (issue first for behaviour changes, D101 before prompt, reviewer ≠ author, MIT in = MIT out). Keep it and this file in step: the hard rules live here, the process lives there.

## Current state

Built: the three Design-stage slash commands (`/d101-feature-design`, `/d101-review`, `/d101-convert-to-html`) and the setup command `/asimov-init` (repo bootstrap — supersedes the former `/docs-init`), the three build subagents (Giskard/.NET + Daneel/Angular builders, Calvin/tests tester), the reviewer (Baley), and the supporting definitions and templates. Marketplace + plugin are scaffolded; D101s are authored directly as HTML.

**Subagents are split into role skills + shells** (2026-09-28, for Codex support without maintaining each method twice): the method lives in `skills/{role-dotnet-builder,role-angular-builder,role-dotnet-tester,role-code-reviewer}`, the agent files are thin per-harness shells (`.md` for Claude Code, `.toml` for Codex). The `.toml` shells are a prototype — Codex discovery of a plugin-level `agents/` folder is unverified. Design: `features/D101-subagents.html` (Draft v0.2, 2026-09-28), which supersedes `D101-build-subagents` and `D101-baley-the-code-reviewer`. The same principle applied to the D101 commands (2026-09-28): `skills/artifact-d101-authoring` holds the rendering procedure, mockup rules and authoring invariants that `/d101-feature-design` and `/d101-convert-to-html` used to inline (and that a hand edit of a D101 never got), and `skills/artifact-d101-gap-review` holds the section walk, the §8a/§8b run and the report that `/d101-review` used to run inline. The three commands keep only the conversation — phases, stops, file choice, menu, notes file — and invoke the skills; the template's leading comment stays the single home of the component catalogue. Skill families: `role-*` (a subagent's method), `artifact-*` (how to author or review an artifact), `persona-*`, `pm-*`, `asimov-*` (user-invoked entry points, one file for both harnesses), `codex-*` (Codex-only entry points). Design: `features/D101-d101-feature-design.html`, rewritten 2026-09-28 as the one D101 for the whole artifact — commands, skills, phases and axes, accepted deviations, review handoff — superseding `D101-d101-review`, `D101-d101-convert-to-html`, `D101-accepted-deviations` and `D101-review-handoff`. The `pm-advisor` skill (over the Delivery Model corpus in `plugins/asimov-plugin/processes/`) is in; it is the first of a planned `pm-*` family whose shared D101 is not yet written.

`/d101-feature-design` runs in three phases — requirements, business design, technical design — and **stops** after the business design, writing the file with §6 declared open. The technical design needs a second invocation. `/d101-review` is the review hub: it resolves the phase, then offers and runs the gap review against the matching bar plus the business- and technical-persona reviews (the persona reviews delegated to the persona skills). See D100 §4.3 and `d101-feature-design-definition.md` §2.

The **persona** layer is built: its standard, template, and design (`persona-review-definition.md`, `persona-review-template.md`, `features/D101-personas.html` at `Full design`), the `/persona-new` + `/persona-list` commands, and the three shipped standard personas (`skills/persona-{poseidon,athena,hermes}`). Persona skills are named `persona-<slug>` — **standard** generic archetypes shipped in the plugin, **custom** readers authored by `/persona-new` into a product repo's `.claude/skills/`.

The **accepted-deviation** mechanism is built (hard rule 5): `d101-feature-design-definition.md` §4.9 plus two §7 anti-patterns and the §8 no-check limit, the `.accepted` markup and ground rule 14 in the D101 template, the `Accepted` severity and validity branch in `/d101-review`, the authoring branch in `/d101-feature-design`, and the design in `features/D101-d101-feature-design.html` (§4.4, §6.4). Its live use is NF3 of that same document, which carries the deviation that used to sit on NF2/NF3 of the old review D101.

The **review-handoff** mechanism is built (`d101-feature-design-definition.md` §4.10): `/d101-review` gains `Write`, scoped by prompt discipline to a sibling `D101-<slug>.review.md`, written by default after every run; `/d101-feature-design` checks for it, offers it against a fingerprint check, folds accepted findings in, and deletes it once a write consumes it. Gitignored, never a record — design in `features/D101-d101-feature-design.html` (R10–R11).

The **artifact-maturity** convention is built: every artifact under `artifacts/` opens with its maturity block, the three producing commands print the level as one chat line (Step 1b), D100 §4.5 mirrors it, and hard rule 10 keeps the two in step. Design: `features/D101-artifact-maturity.html` (`Full design`). Today: D101 `trial`, everything else `assess`.

The **Spec stage** is built (2026-10-02) and untried on a real D101: the two definitions (`artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md`, bar *dispatch-ready*; `artifacts/documentation/s102-task-spec/s102-task-spec-definition.md`, bar *buildable blind*; both `assess`) and their templates, the four artifact skills (`artifact-s101-authoring`, `artifact-s102-authoring`, `artifact-s101-validation`, `artifact-s102-validation`) and the two asimov-skills (`asimov-spec`, `asimov-spec-validate`, one `SKILL.md` each for Claude Code and Codex plus `agents/openai.yaml`). Specs land in a product repo at `documentation/specs/<slug>/`, with a gitignored `S101-<slug>.review.md` sidecar. The **design source** is a D101 at Full design or a Jira ticket that meets the bar in the S101 definition §3.1 (approval by a named person, decision, rules with counter-examples, acceptance criteria, out of scope); a ticket is fetched where the harness has the Atlassian connector or pasted after the skill's name, cached gitignored as `ticket.md` with the plan's ids in the margin, and the S101 links it and carries each id with its wording. Jira stays the record. There is no S102 without a plan: a one-task ticket gets a one-task S101 (decided 2026-10-02, D101-spec-stage v0.13). `asimov-spec` takes its target from the words of the message that names it (a D101 slug or path, a Jira link or key, or pasted ticket text; no flags), reads the design and the repo, asks at most five questions with defaults, writes the S101 draft and **shows the cut**, then waits for the author's go before any S102 is written; after the go it writes each S102, validates it blind in a fresh read-only subagent (`Explore` in Claude Code), validates the plan as a whole, and finishes once. A third failed validation of one task, or a finding that names a D101 gap, stops the run. Update vs rewrite on a re-run is decided by comparing the D101's R/NF/AC ids with the S101's coverage map, then one question. Task tiers (`low`/`mid`/`high`) map to models in `model-choice.md` §1.1. Design: `features/D101-spec-stage.html` (`Full design`, Draft v0.11; §5 is the chat as the UI, with a mockup under `features/mockups/d101-spec-stage/`). Research: `documentation/research/S101-S102-spec-stage-research.md`. Open: Q8 (checklist → script if two runs disagree), Q9 (who writes an Angular-only slice's acceptance test), Q11 is resolved 2026-10-02: `${CLAUDE_PLUGIN_ROOT}` in Claude Code, the derived-root step of `D101-codex-support.html` §6.2 in Codex.

Not built yet: `/conventions-check`, the S102 verification subagent (Test stage), the Build workflow (dispatch, ledger, `asimov-build`, Baley reading the S102), and the Design-stage commands as asimov-skills (`asimov-design`, `asimov-design-review`) — D100 §9.

**Codex support** (2026-10-01): the same plugin folder installs in Codex. Built: the Codex marketplace manifest `.agents/plugins/marketplace.json` (same `asimov-marketplace`, same plugin folder as `.claude-plugin/marketplace.json`); the Codex plugin manifest `plugins/asimov-plugin/.codex-plugin/plugin.json` (same `asimov-plugin`, `"skills": "./skills/"`) beside `.claude-plugin/plugin.json`; and the Codex-only setup entry point `skills/codex-asimov-init/` (`$asimov-plugin:codex-asimov-init`, the counterpart of `/asimov-init`, whose command file is unchanged). It derives the plugin root from its own file path (Step 1) and writes four targets: an `AGENTS.md` managed region (`asimov:start` / `asimov:end` markers) rendered directly from `asimov-md-template.md`, byte-for-byte copies of the plugin's `agents/*.toml` into the product repo's `.codex/agents/`, the `documentation/conventions/<stack>/README.md` read-lists, and the documentation site. `asimov.md` and the `@asimov.md` import in `CLAUDE.md` are written by `/asimov-init` only. The other skills that read plugin files (`artifact-d101-authoring`, `artifact-d101-gap-review`, `pm-advisor`) use `${CLAUDE_PLUGIN_ROOT}` and so find them only in Claude Code; Codex does not load `commands/`, so the slash commands are Claude Code only. Design: `features/D101-codex-support.html`.

**Plugin layout is per artifact, not per file kind** (restructured 2026-09-10; the former `definitions/` and `templates/` folders are gone). `artifacts/<landing-place>/<artifact-slug>/` holds an artifact's definition and template together, grouped by where the artifact lands in a product repo; `resources/` holds the building blocks shared across artifacts. `model-choice.md` is a maintainer contract no command reads at run-time, so it lives outside install scope next to D100.
