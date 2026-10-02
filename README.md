# Asimov

Plugin for Claude Code and Codex. Feature design docs done properly, plus subagents that code and review the way your repo already does.

- `/asimov-design` – interviews you, writes a D101 (feature design) as HTML to `documentation/features/`
- `/asimov-design-review` – checks a D101 against its bar, lists what's missing
- `/asimov-init` – sets up a repo: `asimov.md`, convention read-lists, docs landing page
- `/persona-new`, `/persona-list` – author and list the reader personas (ops, architect, sponsor, or one you define) that `/asimov-design-review` reads a design as
- Subagents: Giskard (.NET), Daneel (Angular), Calvin (tests), Baley (code review). They read your repo's convention files at run-time, no guessing.

Why: agents write decent code when the design is actually written down. Most design docs aren't written for that. A D101 has a definition with two bars. The author clears the first before writing the technical part. Someone else decides the second.

## Install

Claude Code:

```
/plugin marketplace add context-and-oss/asimov
/plugin install asimov-plugin
```

- Local clone: `/plugin marketplace add <path-to-clone>`
- Update: `/plugin marketplace update asimov-marketplace` (no auto-update)

Codex:

```
codex plugin marketplace add context-and-oss/asimov
codex plugin add asimov-plugin@asimov-marketplace
```

- Local clone: `codex plugin marketplace add <path-to-clone>`
- Update: `codex plugin marketplace upgrade asimov-marketplace`, then start a new session
- Codex loads the plugin's skills. Run the setup as `$asimov-plugin:codex-asimov-init` — it writes the Asimov context into an `AGENTS.md` region (not `asimov.md`/`CLAUDE.md`, which `/asimov-init` handles in Claude Code) and copies the Codex agent shells into your repo's `.codex/agents/` (Codex asks before that write). The five other slash commands are Claude Code only — see [D101-codex-support](documentation/features/D101-codex-support.html).

## Try it

```
/asimov-init
/asimov-design
/asimov-design-review
```

- First one wires up the repo.
- Second one interviews you and writes the D101. Stops after the business design; run it again for the technical design.
- Third one tells you what the document still lacks. Can also run the persona reviews.

<!-- TODO: screenshot of a rendered D101 -->

## Status

- Releases: [releases page](../../releases). Major-only versions (`1.0.0`, `2.0.0`, …), any release may change a bar or a template. The marketplace follows the `latest` tag.
- Built: the Design stage (`asimov-design` and `asimov-design-review`, user-invoked skills for both harnesses), the four subagents (each a `role-*` skill plus a thin shell per harness), the two D101 artifact skills, persona reviews, the `pm-advisor` skill (delivery-model advice), and the Spec stage: `asimov-spec` and `asimov-spec-validate` (user-invoked skills, one file for Claude Code and Codex) over the S101/S102 definitions, templates and four `artifact-s10x-*` skills, planning from a Full-design D101 or from an approved Jira ticket. Untried outside this repo as of 2026-10-02.
- Planned: `/conventions-check`, the S102 verification subagent, the Build workflow. See [D100 §9](documentation/D100-Asimov-architecture.md#9-not-yet-built).
- Every artifact carries a maturity level (`assess` / `trial` / `adopt` / `hold`). The producing skill or command tells you if it's not at `adopt`.
- Requires Claude Code with plugin support and access to the models the skills and commands pin. Map in [model-choice.md](documentation/model-choice.md). Codex with plugin support runs the setup skill (`codex-asimov-init`) and the Design- and Spec-stage skills (`$asimov-plugin:asimov-design`, `$asimov-plugin:asimov-design-review`, `$asimov-plugin:asimov-spec`, `$asimov-plugin:asimov-spec-validate`); none of them binds a model in Codex, which runs the session's.

## Skills and commands you type

| Name | Stage | What it does |
|---|---|---|
| `/asimov-design` | Design | Interview → D101 as self-contained HTML. Three phases, hard stop after the business design. Name a legacy `.md` and it renders it to HTML instead. Both harnesses (`$asimov-plugin:asimov-design` in Codex). |
| `/asimov-design-review` | Design | Reads a D101, resolves its phase, offers the gap check (§8a or §8b) and the persona reads, runs what you pick and leaves the findings in a gitignored `.review.md` beside the file for `/asimov-design` to pick up. Never edits the D101, no verdict. Both harnesses. |
| `/asimov-init` | Setup | Writes `asimov.md`, imports it from `CLAUDE.md`, scaffolds `documentation/conventions/<stack>/`, generates the docs landing page. Codex counterpart: the skill `codex-asimov-init`, which writes the `AGENTS.md` region and the `.codex/agents/` copies in place of `asimov.md` and the `CLAUDE.md` import, plus the same conventions and site. |
| `/persona-new` | Design | Interview → custom persona review skill in `.claude/skills/persona-<slug>/`. |
| `/persona-list` | Design | Lists standard + custom personas. |

## Subagents

| Subagent | Stage | What it does |
|---|---|---|
| `giskard-the-dotnet-developer` | Code | C#/.NET, following the repo's .NET conventions. |
| `daneel-the-angular-developer` | Code | TypeScript/Angular, following the repo's Angular conventions. |
| `calvin-the-test-author` | Code | Tests (.NET for now) in the repo's test conventions. Flags untestable code back to its author. |
| `baley-the-code-reviewer` | Review | Diff vs base against conventions + correctness. Read-only, findings only. |

Each subagent's method lives in a `role-*` skill; the agent file is a thin shell (`.md` for Claude Code, `.toml` for Codex, the latter a prototype).

## Personas

A persona review reads a D101 as one of its intended readers and reports where the document talks to its author instead. Ships as skills named `persona-<slug>`.

- Standard, in the plugin: `persona-poseidon` (operations), `persona-athena` (architecture, incl. §6), `persona-hermes` (cost / ROI)
- Custom, in your repo: `/persona-new` writes one to `.claude/skills/`
- Standard: [persona-review-definition.md](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md). Skeleton: [persona-review-template.md](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md)

## What's inside

```
.claude-plugin/marketplace.json           marketplace manifest (Claude Code)
.agents/plugins/marketplace.json          marketplace manifest (Codex)
plugins/asimov-plugin/                    the plugin (install scope)
├── .claude-plugin/plugin.json            plugin manifest (Claude Code)
├── .codex-plugin/plugin.json             plugin manifest (Codex)
├── commands/                             slash commands (asimov-init, persona-new, persona-list; Claude Code only)
├── agents/                               subagent shells (Giskard, Daneel, Calvin, Baley) — .md for Claude Code, .toml for Codex
├── skills/                               role-* (the subagents' methods), artifact-d101-* (D101 authoring + gap review), artifact-s101-*/artifact-s102-* (Spec-stage authoring + validation), asimov-design + asimov-design-review (Design-stage entry points, both harnesses), asimov-spec + asimov-spec-validate (Spec-stage entry points, both harnesses), persona-* (Poseidon, Athena, Hermes), pm-advisor, codex-asimov-init (Codex setup entry point)
├── artifacts/                            one folder per artifact the toolkit writes into a product repo, grouped by where it lands
│   ├── documentation/                    lands in the product repo's documentation/
│   │   ├── d101-feature-design/          the D101 artifact: definition + template side by side
│   │   │   ├── d101-feature-design-definition.md
│   │   │   └── d101-feature-design-template.html
│   │   ├── site/                         the documentation/ landing site (/asimov-init)
│   │   │   ├── site-definition.md
│   │   │   ├── site-template.html
│   │   │   └── _chrome.css
│   │   └── conventions/                  documentation/conventions/<stack>/README.md (/asimov-init)
│   │       ├── conventions-definition.md
│   │       └── conventions-readme-template.md
│   ├── skills/                           lands in the product repo's .claude/skills/
│   │   └── persona-review/               the persona review skill artifact (/persona-new)
│   │       ├── persona-review-definition.md
│   │       └── persona-review-template.md       SKILL.md skeleton for a persona review skill
│   └── root/                             lands at the product repo's root
│       └── asimov-md/                    the asimov.md context file (/asimov-init)
│           ├── asimov-md-definition.md
│           └── asimov-md-template.md
├── contracts/                            stage handoffs — design.md: what a design must contain for Spec to plan from it
├── resources/                            building blocks shared across artifacts
│   └── diagrams/                         the 4 standard diagram notations a D101 may use
│       ├── README.md                     routing table: reader intent → diagram type
│       ├── sequence-template.svg
│       ├── activity-swimlane-template.svg
│       ├── state-machine-template.svg
│       └── flowchart-template.svg
└── processes/                            the Delivery Model corpus pm-advisor reads (generated export)
documentation/                            repo docs (not inside install scope)
├── D100-Asimov-architecture.md            why + how
├── model-choice.md                        which model runs which command/subagent (maintainer contract)
├── ai-transition-levels-and-zones.md      the Levels & Zones vocabulary Asimov uses (L0–L5, Z1–Z3, the L3 stages)
├── index.html + _chrome.css               the rendered documentation site
├── features/                              one D101 per artifact or role family
└── research/                              decision provenance
```

## Docs

- [Website](https://asimov-plugin.netlify.app) – what Asimov is, for someone who has never used it
- [D100 – Architecture](documentation/D100-Asimov-architecture.md) – why, components, distribution, patterns
- [D101 definition](plugins/asimov-plugin/artifacts/documentationasimov-designasimov-design-definition.md) – the two bars, phase vs status
- [D101 template](plugins/asimov-plugin/artifacts/documentationasimov-designasimov-design-template.html) – structure + ground rules in the leading comment
- [Diagram templates](plugins/asimov-plugin/resources/diagrams/README.md) – the four notations and when to use which
- [Levels & Zones](documentation/ai-transition-levels-and-zones.md) – what L3, "L3 on Zone 2" and the pipeline stages mean
- [CLAUDE.md](CLAUDE.md) – working *on* the toolkit: conventions, how to add things, hard rules

Nothing in the plugin is tied to one product. Forking means changing `documentation/`, mostly. See D100 §8.4.

## Contributing

- Bugs and proposals: [issues](../../issues), templates provided
- Pull requests: read [CONTRIBUTING.md](CONTRIBUTING.md) first. Commands get a D101 before a prompt. Reviewer ≠ author.
- Security: [SECURITY.md](SECURITY.md), report privately
- [Code of conduct](CODE_OF_CONDUCT.md)

Maintained by Context&. Lead: [@Aborup](https://github.com/Aborup). Team: `@context-and-oss/team-asimov`.

## License

[MIT](LICENSE), Copyright (c) 2026 Context&.
