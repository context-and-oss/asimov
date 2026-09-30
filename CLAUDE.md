# CLAUDE.md — Asimov

This repo is **Asimov** — one plugin (`asimov-plugin`), installed by **Claude Code and Codex** from the same folder, that ships L3 workflow tooling: skills (the entry points and every method), subagents, definitions, and document templates for the Design → Spec → Code → Review+Test stages of the L3 pipeline. No build step — the folder in the repository is what both tools install.

You are working *on* the toolkit. Skills and subagents *built by* the toolkit run in product repos; this repo is where their definitions, prompts, and templates live. Everything in the plugin is read as-is by the tool it is for: a Claude Code file is never read by Codex and vice versa, and the shared layer — skills — is what both tools document as their own format.

## Quick map

```
.claude-plugin/marketplace.json                ← Claude Code marketplace manifest (declares asimov-marketplace)
.agents/plugins/marketplace.json               ← Codex marketplace manifest — same marketplace name, same plugin, same path
plugins/asimov-plugin/                         ← the plugin (install scope); read as-is by both tools
├── .claude-plugin/plugin.json                 ← Claude Code plugin manifest
├── .codex-plugin/plugin.json                  ← Codex plugin manifest — same name, version, description; bump version on every plugin change
├── agents/                                    ← subagent shells: identity, tool fields and (in the .md) the model; the method is a role skill. One .md (Claude Code, `skills:` preload) + one .toml (Codex, delivered into a repo's .codex/agents/ by asimov-init) per subagent
│   ├── giskard-the-dotnet-developer.{md,toml} ← .NET developer (Giskard) → skills/role-dotnet-builder — D101-subagents
│   ├── daneel-the-angular-developer.{md,toml} ← Angular developer (Daneel) → skills/role-angular-builder
│   ├── calvin-the-test-author.{md,toml}       ← test author (Calvin) → skills/role-dotnet-tester
│   └── baley-the-code-reviewer.{md,toml}      ← reviewer (Baley) → skills/role-code-reviewer — D101-subagents
├── skills/                                    ← the shared layer both tools read: one SKILL.md per skill, read in full by both
│   ├── asimov-init/                           ← entry point, user-only in both tools (disable-model-invocation; agents/openai.yaml):
│   │                                             asimov.md + CLAUDE.md import + AGENTS.md region + .codex/agents/ shells + conventions + site
│   ├── d101-feature-design/                   ← entry point: authors D101s directly as HTML (drafts via artifact-d101-authoring)
│   ├── d101-review/                           ← entry point: review hub — gap review (artifact-d101-gap-review) + persona reads
│   ├── d101-convert-to-html/                  ← entry point: legacy MD → HTML
│   ├── persona-new/                           ← entry point: custom persona → .claude/skills/ (source) + .agents/skills/ (Codex mirror)
│   ├── persona-list/                          ← entry point: lists persona skills (standard + custom, both copies)
│   ├── role-dotnet-builder/ · role-angular-builder/ · role-dotnet-tester/ · role-code-reviewer/   ← the subagents' methods
│   ├── artifact-d101-authoring/ · artifact-d101-gap-review/   ← how to write/change a D101 · the D101 gap review
│   ├── persona-poseidon/ · persona-athena/ · persona-hermes/  ← the standard readers
│   └── pm-advisor/                            ← advises on the delivery model in processes/ (read-only)
├── artifacts/                                 ← one folder per artifact the toolkit writes into a product repo; sub-folder = where it lands
│   ├── documentation/                         ← artifacts that land in the product repo's documentation/
│   │   ├── d101-feature-design/               ← the D101 artifact: definition + template side by side
│   │   │   ├── d101-feature-design-definition.md  ← the two bars for D101s (§8a business-complete, §8b gap-free)
│   │   │   └── d101-feature-design-template.html  ← visual + structural contract every D101 follows
│   │   ├── s101-implementation-plan/          ← the S101 artifact (Spec stage): the task graph for one D101
│   │   │   └── s101-implementation-plan-definition.md  ← the dispatch-ready bar; template not built yet
│   │   ├── s102-task-spec/                    ← the S102 artifact (Spec stage): one task for one builder
│   │   │   └── s102-task-spec-definition.md   ← the buildable-blind bar; template not built yet
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
├── model-choice.md                            ← retired 2026-09-29 (kept as a pointer): models live in the agent shells only (hard rule 2)
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
| [`documentation/features/D101-codex-support.html`](documentation/features/D101-codex-support.html) | Before touching anything two-tool: manifests, the skill shape, the shells, `asimov-init`, the README's install steps |
| [`plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html) | When authoring a D101 (its leading comment holds the authoring ground rules + component catalogue) |
| [`plugins/asimov-plugin/resources/diagrams/README.md`](plugins/asimov-plugin/resources/diagrams/README.md) | Before drawing any diagram in a D101 (routing table: reader intent → diagram type → template; each template's leading comment holds its notation, node budget and geometry) |

## Conventions

### Document codes
- `D100` — architecture doc (system-level)
- `D101` — feature design doc
- `S101` — implementation plan: one per D101, the task graph (definition written; template + command not built yet)
- `S102` — task spec: one per task, the brief a build subagent receives (definition written; template + command not built yet)
- `T100` — test strategy (none yet)

### L3 pipeline stages
*Intent → Design → Spec → Code → Review → Test → Approve → Deploy → Observe*. The toolkit covers the AI-assisted middle (Design through Test). See D100 §3.

### File naming
- Skills: `skills/<skill-name>/SKILL.md` (kebab-case; an entry-point skill keeps the name of the command it replaced — `d101-feature-design` — and is invoked as `/<name>` in Claude Code, `$asimov-plugin:<name>` in Codex)
- Subagents: `agents/<subagent-name>.md` + `agents/<subagent-name>.toml` — one pair per agent, same name and description in both
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
- Marketplace manifest name: `asimov-marketplace` — in `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`
- Plugin manifest name: `asimov-plugin` (also the directory name `plugins/asimov-plugin/`) — in `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`, with the same `version`
- Friendly prose: "Asimov Plugin" (capitalised, used in headings + sentences)

## How to add an entry-point skill (the former slash commands)

An **entry-point skill** is what a developer invokes by name — `/<name>` in Claude Code, `$asimov-plugin:<name>` in Codex. It is a skill like every other in the plugin: one `SKILL.md`, no model. The tools take no arguments the same way (Codex passes none), so the method reads its input from the prompt and asks when none is given.

1. Decide which L3 stage the command belongs to (Design / Spec / Code / Review + Test, or ad-hoc like `/conventions-check`).
2. Decide whether it is a **user decision** (like `asimov-init`): then `disable-model-invocation: true` in `SKILL.md` and an `agents/openai.yaml` with `policy.allow_implicit_invocation: false` beside it. Never on a role skill — a user-only skill cannot be preloaded or reached by a subagent.
3. Cover it in the D101 of its artifact family — the D101 commands share `documentation/features/D101-d101-feature-design.html`; a command for a new artifact gets that artifact's D101, written with `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`. Run `/d101-feature-design` — twice: once for requirements + business design (which lands the file at phase `Business design` with §6 open), then again for the technical design. Must clear both bars in `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md` — §8a before you move to §6, §8b before you request review.
4. Add a row to `documentation/D100-Asimov-architecture.md` §4.3 *Slash commands*.
5. Author `plugins/asimov-plugin/skills/<name>/SKILL.md`: frontmatter `name`, `description`, `argument-hint`, `allowed-tools` and the flags from step 2; the body is the whole method — plugin files referenced relative to the skill folder (`../../artifacts/…`), the UTF-8 file rule as its first hard rule if it writes files. Bump `version` in both plugin manifests.
6. Test locally — see "How to test" below.

## How to add a new subagent

A subagent is two layers. The **role skill** at `plugins/asimov-plugin/skills/role-<stack>-<role>/SKILL.md` carries the whole method — the six-field skeleton of D100 §7.2.1 (Role, Stack competence, Reads, Workflow, Boundaries, Output; plus Target for diff-scoped roles). It is the harness-portable layer: Claude Code and Codex both read it, and a main agent can use it directly where no subagent exists. The **shell** under `plugins/asimov-plugin/agents/` carries only identity and harness fields and points at the skill — one file per harness (`<name>.md` for Claude Code with `skills:` preloading the role skill; `<name>.toml` for Codex, delivered into a product repo's `.codex/agents/` by `asimov-init` because a Codex plugin cannot carry agents — its `developer_instructions` invoke `$asimov-plugin:<role-skill>` first). The Claude Code shell pins the model (`model: claude-sonnet-4-6`, hard rule 2); the Codex shell names none and inherits the session's until #7 settles how Codex agents are pinned (D101-codex-support R6). Subagent kinds follow the Accelerate roles — *planner / builder / tester / reviewer*, planner reserved (see D100 §4.4). Four exist (Giskard/.NET + Daneel/Angular builders, Calvin/.NET tester, Baley/reviewer); the S102 validator is planned but not built yet.

Naming: role skills are `role-<stack>-<accelerate-role>` (`role-dotnet-builder`, `role-angular-builder`, `role-dotnet-tester`), subject first like the shells (`giskard-the-dotnet-developer`) and the conventions folders (`conventions/<stack>/`). A role that spans stacks drops the stack (`role-code-reviewer`: only its read-list is stack-specific, so it is not split). The skill body names roles, never Asimov personas — persona names live in the shells only.

1. The model is a shell fact, never a skill fact: the Claude Code shell pins it (`model:`), the Codex shell names none and inherits the session's (hard rule 2).
2. Cover it in the one subagent D101, `documentation/features/D101-subagents.html` — a row in its roster and, if the role is new in kind (planner, validator), its own rules; never a new document per role.
3. Add a row to `documentation/D100-Asimov-architecture.md` §4.4 *Subagents* and, for the skill, §4.6 *Skills*.
4. Author the role skill at `plugins/asimov-plugin/skills/role-<stack>-<role>/SKILL.md` — frontmatter `name` + `description` only, description trigger-shaped and narrow; the body is the six-field method. Never mark a role skill user-only.
5. Author the shells: `plugins/asimov-plugin/agents/<name>.md` (YAML frontmatter `name`, `description`, `skills:` list, `tools` if restricted, `model` (`claude-sonnet-4-6` on all four today); a three-line body naming the persona, the role and the skill) and `plugins/asimov-plugin/agents/<name>.toml` (same `name`/`description`, `developer_instructions` invoking `$asimov-plugin:<role-skill>` first, `sandbox_mode = "read-only"` where the `.md` restricts tools — no model until #7). Bump `version` in both plugin manifests.
6. Test locally — see "How to test" below.

## How to add a persona review skill

A **persona review** reads a design document *as one of its intended readers* and reports where the document talks to its author instead of to that reader — the concrete form of `/d101-review` check 7. Personas ship as Claude Code **skills** named `persona-<slug>`, in two kinds: **standard** generic archetypes curated in the plugin (`plugins/asimov-plugin/skills/persona-*`, available on install) and **custom** product-specific readers authored into the **product repo** at `.claude/skills/persona-<slug>/SKILL.md` (the source, read by Claude Code) with a byte-identical mirror at `.agents/skills/persona-<slug>/SKILL.md` (read by Codex). A concrete reader is a product entity (hard rule 7), so custom personas stay local; only the *form* and the generic archetypes ship in the toolkit. The `persona-` prefix is the namespace (skill discovery is flat — a folder can't group them). Design: `documentation/features/D101-personas.html`.

What the toolkit owns:

1. `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md` — the canonical standard: what a persona review is, the five persona fields, the generic fail/reward catalogue, the output shape, and how it relates to `/d101-review` and Baley.
2. `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md` — the SKILL.md skeleton a persona is authored from. Its leading comment holds the authoring ground rules + an anonymised worked example.

To add a custom persona today: copy `persona-review-template.md`, fill in every `{{PLACEHOLDER}}` with the product-specific reader (keep the generic fails/rewards, reorder them, add domain-specific ones), strip the leading comment, and save as `.claude/skills/persona-<slug>/SKILL.md` in the product repo, plus the identical copy at `.agents/skills/persona-<slug>/SKILL.md` for Codex. The generated skill is **self-contained** — it inlines the method rather than reading the definition at run-time (a skill is an authored artifact, not a re-running command, so hard rule 3 does not apply to it). The `/persona-new` command automates this interview-and-scaffold step, and `/persona-list` shows the whole roster (standard + custom).

## How to add an advisory skill

An **advisory skill** answers questions from a body of reference material shipped in the plugin, rather than performing an action. `pm-advisor` is the first — it advises on the delivery model in `plugins/asimov-plugin/processes/`, which it reaches as `../../processes/` from its own folder. It is the first member of a planned `pm-*` family.

1. Choose the family prefix (`pm-` for delivery/project-management advice) and a `<slug>`.
2. Author `plugins/asimov-plugin/skills/<prefix><slug>/SKILL.md` with YAML frontmatter carrying **only** `name` and `description` — no `model`, no `argument-hint`. The `description` is the trigger: name the topics and the phrasings that should activate it.
3. Give the body: a **navigation section** (which file to read first, how links resolve), an **intent → file routing table** over the reference corpus, and the **rules of engagement** (read before advising; recommend don't decide; stay inside the material; advisory only — never writes).
4. Reference the corpus by path relative to the skill folder (`../../processes/...`), never by inlining its content (hard rule 3) and never through a tool-specific variable (hard rule 12).
5. No model in the skill (hard rule 2). No `plugin.json` / `marketplace.json` entry (skills auto-discover), but bump `version` in both plugin manifests.
6. D101 coverage joins the family's shared D101 when that is written — not one per skill.
7. Test locally — see "How to test" below.

## How to test the plugin locally

Claude Code — one session, straight from the folder (overrides an installed `asimov-plugin` for that session):

```
claude --plugin-dir <path-to-your-clone>/plugins/asimov-plugin
```

or add the clone as a marketplace (read in place; edits show up after `/reload-plugins` or a new session, no version bump needed):

```
/plugin marketplace add <path-to-your-clone>
/plugin install asimov-plugin
```

Codex — add the clone as a local marketplace, install, start a new session; after editing, remove and add the plugin again (Codex copies a local plugin into its cache):

```
codex plugin marketplace add <path-to-your-clone>
codex plugin add asimov-plugin@asimov-marketplace
```

Then run the skill in any product repo — `/<name>` in Claude Code, `$asimov-plugin:<name>` in Codex. To test the subagents in Codex, run `asimov-init` in a repo you have marked trusted and start a new session. `claude plugin validate plugins/asimov-plugin` checks the Claude Code side of the manifest and every skill's frontmatter.

## Hard rules

These are enforcement rules, not style preferences. Violations break the toolkit's contract.

1. **Manifest names, versions and folder names stay in sync.** `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` carry the same `name`, `version` and `description`; both marketplace manifests name the same marketplace and point at `plugins/asimov-plugin`; the plugin name is the directory name. Four files, one string.
2. **A model is named only in an agent shell, never in a skill.** Skills (`skills/*/SKILL.md`) carry no `model` or `effort` and run on the session's model in both tools — a skill-level pin would hold for one turn anyway, and would put a Claude name into the layer both tools read. The Claude Code shells (`agents/*.md`) pin their model (`claude-sonnet-4-6` on all four, the pre-Codex choice; rationale in D100 §7.3); the Codex shells (`agents/*.toml`) name none and inherit the session's until #7 settles how Codex agents are pinned. `documentation/model-choice.md` stays retired — four identical pins need no index; a roll-forward changes the four shells and D100 §7.3 in one PR (D101-codex-support R6).
3. **Commands and skills reference definitions and templates by *path*, not by inlining content.** A skill's body says "read `../../artifacts/documentation/d101-feature-design/d101-feature-design-definition.md`" (relative to its own folder); it doesn't paste the definition into the prompt. This keeps the doc-in-the-repo as the runtime source of truth (D100 §7.4). The same rule holds one layer up: an entry-point skill references an `artifact-*` or `role-*` skill by name and never restates its method — the skill is the single home of the procedure, the entry point owns only the conversation sequence.
4. **D101s mature through two bars, and each bar's verdict belongs to a different person.** *Business-complete* (`d101-feature-design-definition.md` §2.1, checked by §8a) is the **author's** call — it's the gate that stops them writing §6 before the business shape holds. *Gap-free* (§2.2, checked by §8b) is the **human reviewer's** (≠ author) call. The author runs `/d101-review` or a self-preview to surface weak sections before requesting review; automating the gap-free verdict would collapse the reviewer-not-author gate. Never review a `Business design` document against §8b — a deliberately open §6 is *open*, not a failure.
   **Phase ≠ status.** The rendered D101 carries both axes in its top bar: **phase** (`Business design` → `Full design`, moved by the author) and **status** (`Draft` → `Approved`, moved by the business approver, normally only after §6 exists because the estimate depends on it). Neither implies the other; no command ever records an approval.
5. **An accepted deviation never covers a check.** A rule of `d101-feature-design-definition.md` may be deliberately declined and recorded in the D101 (§4.9) — named rule, one-sentence reason, accepter, date, written next to the element it excuses. It may **never** be written against a check from §8: that would replace *reaching* the gap-free bar with *being excused from* it, and the bar is what makes the reviewer-not-author gate mean anything. Two further limits are equally load-bearing: the record never stops the finding being reported (`/d101-review` prints it as **Accepted**, which never becomes Pass — the human reviewer must see what they are signing), and it is never stored outside the D101. `/d101-review` may honour a deviation but must never write or propose one. Design: `documentation/features/D101-d101-feature-design.html` (accepted deviations, §4.4 and §6.4).
6. **No drift between D100, D101s, and code/manifests.** When you change one, run a quick grep for related references in the other docs. When a D101 is renamed, superseded or its R/NF/AC numbers change, grep for the old file name and the old numbers in `documentation/`, `CLAUDE.md`, `README.md`, `plugins/asimov-plugin/**` (definitions, templates, skills, commands) and repo config comments such as `.gitignore` — the definitions ship to every product repo, so a stale pointer there travels with each release.
7. **Don't bake product-specific identifiers into definitions, templates, or command prompts.** Path conventions (e.g. `documentation/features/`) are acceptable shared conventions; product entity names are not (D100 §8.4 reusability).
8. **Reusability across products is a goal, not a hope.** When in doubt, name something generically and add an example as illustration.
9. **Path-convention fork point:** the path convention `documentation/features/D101-*` is baked into `skills/d101-feature-design/SKILL.md` (the `.html` output path + listing glob), `skills/d101-review/SKILL.md` (the `.html`/`.md` auto-detect glob), and `skills/d101-convert-to-html/SKILL.md` (the `.md` source glob), and into the two artifact skills `skills/artifact-d101-authoring/SKILL.md` (its trigger description and *Paths* section, including the `mockups/d101-<slug>/` sibling) and `skills/artifact-d101-gap-review/SKILL.md` (the mockup path it follows). `asimov-init.md` shares the same `documentation/` taxonomy (`features/`, `conventions/`, `reference/`, root `D100-*`/`E100-*`) and adds two more literals of its own: the `asimov.md` root location and the `<stack>` slugs under `conventions/`. The `D101-<slug>.review.md` sibling-file convention (`d101-feature-design-definition.md` §4.10) is a third literal shared by `d101-review.md` (writer) and `d101-feature-design.md` (reader + deleter) and must move with the other two, and so must the `documentation/features/*.review.md` pattern in `.gitignore`, which fuses both literals. The D101 template's leading comment and `asimov-md-template.md`'s taxonomy table repeat the `documentation/features/D101-*` path as authoring guidance. A fork that uses a different layout changes the literal in *all* of these files — they must stay in lockstep. The delivery-model corpus path `plugins/asimov-plugin/processes/` is a fourth literal, and its lockstep partner is **not** inside the corpus — the corpus never names its own location. The literal lives in `skills/pm-advisor/SKILL.md` (the `../../processes/` routing root) and in the vault's export target (`export-delivery-model.ps1 -Target plugin`, per `processes/README.md` *Refreshing*), which writes to this path from outside the repo. A fork that relocates the corpus changes the skill **and** tells the vault; editing this repo alone leaves the next export writing to the old path. Intentionally not a config — we don't have a config mechanism for one toggle.
10. **A maturity level and its D100 mirror move in the same commit.** The `maturity`/`since` block in an artifact's definition is the source; the *Maturity* column in D100 §4.5 is the mirror. Change one, change the other, and name the evidence for a promotion in the commit message. Same shape as rule 1.
11. **One `SKILL.md` per skill; the 8 kB cap is watched, not enforced.** A skill's method lives in its `SKILL.md`, read in full by both tools. Codex truncates a skill entry at 8,000 bytes only for plugins in its portable Agent-Plugins manifest format; ours is the legacy `.codex-plugin` manifest, so skills stay single-file (decided 2026-09-30). If the plugin ever adopts the portable format, split every skill over 8 kB (today the five writing entry points `d101-feature-design`, `asimov-init`, `d101-review`, `d101-convert-to-html`, `persona-new`, the two `artifact-*` skills and `role-code-reviewer`) into a short entry plus a method file *before* switching (D101-codex-support NF3, §6.8).
12. **No tool-specific path variables in skills.** `${CLAUDE_PLUGIN_ROOT}` is Claude-only and stays out of `skills/`; a skill reaches plugin files relative to its own folder (`../../artifacts/…`), which both tools tell it when they load the skill (D101-codex-support R10).
13. **Shell parity and delivery.** Every agent is a pair — `agents/<name>.md` for Claude Code, `agents/<name>.toml` for Codex — with identical `name` and `description` and no method text; the `.toml` reaches a product repo only through `asimov-init` (Codex plugins cannot carry agents). A user-only flag never goes on a role skill.
14. **Bump the plugin version on every plugin change.** Both plugin manifests move together in the same commit as any change under `plugins/asimov-plugin/**`; both tools detect an update by that version (D101-codex-support version rule). Until CI enforces it, the reviewer checks it.

## Research notes

Design decisions in this repo were informed by research captured in `documentation/research/`. When you reopen a decision, check whether the research still applies before re-deciding.

- [`industry-design-doc-standards.md`](documentation/research/industry-design-doc-standards.md) — DoR, INVEST, Rust RFC, MADR, EARS, Kiro, Augment, etc.
- [`L3-spec-format-research.md`](documentation/research/L3-spec-format-research.md) — format research for a single spec (Markdown + frontmatter, validator authority); two of its decisions revised by the next note
- [`S101-S102-spec-stage-research.md`](documentation/research/S101-S102-spec-stage-research.md) — the plan layer: how the field orders and parallelises tasks (Spec Kit, Kiro, OpenSpec, Conductor, superpowers, Beads, agent teams), and the S101/S102 decisions taken 2026-09-25
- [`additional-command-ideas.md`](documentation/research/additional-command-ideas.md) — which community/vendor slash commands fit the toolkit's L3 scope and reusability bar, and which don't

## Contributing

The contribution process for people outside the maintainer team is in `CONTRIBUTING.md` at the repo root (issue first for behaviour changes, D101 before prompt, reviewer ≠ author, MIT in = MIT out). Keep it and this file in step: the hard rules live here, the process lives there.

## Current state

Built: the three Design-stage entry points (`d101-feature-design`, `d101-review`, `d101-convert-to-html`) and the setup entry point `asimov-init` (repo bootstrap for both tools — supersedes the former `/docs-init`), the three build subagents (Giskard/.NET + Daneel/Angular builders, Calvin/tests tester), the reviewer (Baley), and the supporting definitions and templates. **Codex support landed 2026-09-29** (`features/D101-codex-support.html`): one plugin folder with a manifest per tool, the six commands turned into entry-point skills, no model in any skill, the Codex shells delivered by `asimov-init`. D101s are authored directly as HTML.

**Subagents are split into role skills + shells** (2026-09-28, for Codex support without maintaining each method twice): the method lives in `skills/{role-dotnet-builder,role-angular-builder,role-dotnet-tester,role-code-reviewer}`, the agent files are thin per-harness shells (`.md` for Claude Code, `.toml` for Codex). The `.toml` shells are delivered into a product repo's `.codex/agents/` by `asimov-init` and spawned by name there (a Codex plugin cannot carry agents — verified 2026-09-29, `documentation/research/codex-support-probes.md`). Design: `features/D101-subagents.html` (Draft v0.2, 2026-09-28), which supersedes `D101-build-subagents` and `D101-baley-the-code-reviewer`. The same principle applied to the D101 commands (2026-09-28): `skills/artifact-d101-authoring` holds the rendering procedure, mockup rules and authoring invariants that `/d101-feature-design` and `/d101-convert-to-html` used to inline (and that a hand edit of a D101 never got), and `skills/artifact-d101-gap-review` holds the section walk, the §8a/§8b run and the report that `/d101-review` used to run inline. The three commands keep only the conversation — phases, stops, file choice, menu, notes file — and invoke the skills; the template's leading comment stays the single home of the component catalogue. Skill families: `role-*` (a subagent's method), `artifact-*` (how to author or review an artifact), `persona-*`, `pm-*`. Design: `features/D101-d101-feature-design.html`, rewritten 2026-09-28 as the one D101 for the whole artifact — commands, skills, phases and axes, accepted deviations, review handoff — superseding `D101-d101-review`, `D101-d101-convert-to-html`, `D101-accepted-deviations` and `D101-review-handoff`. The `pm-advisor` skill (over the Delivery Model corpus in `plugins/asimov-plugin/processes/`) is in; it is the first of a planned `pm-*` family whose shared D101 is not yet written.

`/d101-feature-design` runs in three phases — requirements, business design, technical design — and **stops** after the business design, writing the file with §6 declared open. The technical design needs a second invocation. `/d101-review` is the review hub: it resolves the phase, then offers and runs the gap review against the matching bar plus the business- and technical-persona reviews (the persona reviews delegated to the persona skills). See D100 §4.3 and `d101-feature-design-definition.md` §2.

The **persona** layer is built: its standard, template, and design (`persona-review-definition.md`, `persona-review-template.md`, `features/D101-personas.html` at `Full design`), the `/persona-new` + `/persona-list` commands, and the three shipped standard personas (`skills/persona-{poseidon,athena,hermes}`). Persona skills are named `persona-<slug>` — **standard** generic archetypes shipped in the plugin, **custom** readers authored by `/persona-new` into a product repo's `.claude/skills/` with a mirror in `.agents/skills/` for Codex.

The **accepted-deviation** mechanism is built (hard rule 5): `d101-feature-design-definition.md` §4.9 plus two §7 anti-patterns and the §8 no-check limit, the `.accepted` markup and ground rule 14 in the D101 template, the `Accepted` severity and validity branch in `/d101-review`, the authoring branch in `/d101-feature-design`, and the design in `features/D101-d101-feature-design.html` (§4.4, §6.4). Its live use is NF3 of that same document, which carries the deviation that used to sit on NF2/NF3 of the old review D101.

The **review-handoff** mechanism is built (`d101-feature-design-definition.md` §4.10): `/d101-review` gains `Write`, scoped by prompt discipline to a sibling `D101-<slug>.review.md`, written by default after every run; `/d101-feature-design` checks for it, offers it against a fingerprint check, folds accepted findings in, and deletes it once a write consumes it. Gitignored, never a record — design in `features/D101-d101-feature-design.html` (R10–R11).

The **artifact-maturity** convention is built: every artifact under `artifacts/` opens with its maturity block, the three producing commands print the level as one chat line (Step 1b), D100 §4.5 mirrors it, and hard rule 10 keeps the two in step. Design: `features/D101-artifact-maturity.html` (`Full design`). Today: D101 `trial`, everything else `assess`.

The **Spec stage** is defined but not tooled: `artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md` (the plan: task graph, phases, interfaces, constraints, escalation routing; bar *dispatch-ready*) and `artifacts/documentation/s102-task-spec/s102-task-spec-definition.md` (one task: files, interfaces, behaviour, steps, acceptance criteria; bar *buildable blind*), both `assess`. They land in a product repo at `documentation/specs/<feature-slug>/`. Research: `documentation/research/S101-S102-spec-stage-research.md`.

Not built yet: the S101/S102 templates, the `/s101-*` entry points, the Spec-stage D101, `/conventions-check`, the S102 validator subagent (D100 §9), and the update flow — `/asimov-update` and a session-start notice when the plugin is newer than the repo's Asimov files (deferred 2026-09-29; the README carries the steps until then).

**Plugin layout is per artifact, not per file kind** (restructured 2026-09-10; the former `definitions/` and `templates/` folders are gone). `artifacts/<landing-place>/<artifact-slug>/` holds an artifact's definition and template together, grouped by where the artifact lands in a product repo; `resources/` holds the building blocks shared across artifacts. `model-choice.md` is retired (2026-09-29): Asimov names no model; the file stays as a one-paragraph pointer so old links resolve.
