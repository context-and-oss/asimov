# Asimov

Plugin for Claude Code and Codex. Feature design docs done properly, plus subagents that code and review the way your repo already does.

- `/asimov-design` – interviews you, writes a D101 (feature design) as HTML to `documentation/features/`; name a D101 and *review* and it checks it against its bar, lists what's missing
- `/asimov-init` – sets up a repo for both tools in one run: the `asimov.md` marker, the Codex agent shells, convention read-lists, project info, docs site. The Asimov context itself comes from the plugin at session start, wherever the marker is
- Personas: ops, architect and sponsor readers ship as skills; `artifact-persona-authoring` interviews you for one of your own. `/asimov-design` reads a design as them on a review
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
- Codex loads the plugin's skills, the entry points among them, and its hooks: approve the plugin's two hooks when the app asks, then every session in a repo with `asimov.md` gets the Asimov context. Run the setup as `$asimov-plugin:asimov-init` — the same skill as `/asimov-init`; it writes the marker, the conventions, the project info, the site and the agent shells in `.codex/agents/` (Codex asks before that write). See [D101-codex-support](documentation/features/D101-codex-support.html).

## Try it

```
/asimov-init
/asimov-design
/asimov-design review D101-<slug>
```

- First one wires up the repo.
- Second one interviews you and writes the D101. Stops after the business design; run it again for the technical design.
- Third one, the same skill with *review* in the words, tells you what the document still lacks. Can also run the persona reviews.

<!-- TODO: screenshot of a rendered D101 -->

## Status

- Releases: [releases page](../../releases). Major-only versions (`1.0.0`, `2.0.0`, …), any release may change a bar or a template. The marketplace follows the `latest` tag.
- Built: the Design stage (`asimov-design`, one skill for both harnesses, the review a path of it since 2026-11-13), the five subagents (each a `role-*` skill plus a thin shell per harness), the two D101 artifact skills, persona reviews, the `pm-advisor` skill (delivery-model advice), the Spec stage: `asimov-spec` (one skill for both harnesses) over the S101/S102 definitions, templates and four `artifact-s10x-*` skills, planning from a Full-design D101 or from an approved Jira ticket. Untried outside this repo as of 2026-10-02.
- Planned: `/conventions-check`. See [D100 §9](documentation/D100-Asimov-architecture.md#9-not-yet-built).
- Every artifact carries a maturity level (`assess` / `trial` / `adopt` / `hold`). The producing skill or command tells you if it's not at `adopt`.
- Needs PowerShell for the Spec- and Build-stage checks, the ledger script and the run-log hooks: `pwsh` (PowerShell 7, on Windows, Linux and macOS) or Windows PowerShell 5.1. Without it those checks cannot run and the run log stays empty; nothing else is affected.
- Requires Claude Code with plugin support and access to the models the skills and commands pin. Map in [model-choice.md](documentation/model-choice.md). Codex with plugin support runs the same entry points (`$asimov-plugin:asimov-init`, `$asimov-plugin:asimov-design`, `$asimov-plugin:asimov-spec`, `$asimov-plugin:asimov-build`); none of them binds a model in Codex, which runs the session's.

## Skills and commands you type

| Name | Stage | What it does |
|---|---|---|
| `/asimov-design` | Design | Interview → D101 as self-contained HTML. Three phases, hard stop after the business design. Name a legacy `.md` and it renders it to HTML instead. Name a D101 and *review* and it resolves the phase, offers the gap check (§8a or §8b) and the persona reads, runs what you pick and leaves the findings in a gitignored `.review.md` beside the file for the next design run; no edit, no verdict. Starts on your words too, in a repo with `asimov.md`. Both harnesses (`$asimov-plugin:asimov-design` in Codex). |
| `/asimov-init` | Setup | Writes the `asimov.md` marker (which entry points the repo uses), copies the Codex agent shells into `.codex/agents/`, scaffolds `documentation/conventions/<stack>/`, asks for the project info, generates the docs site; touches neither `CLAUDE.md` nor `AGENTS.md`. One run readies the repo for both harnesses (`$asimov-plugin:asimov-init` in Codex); the context reaches every session from the plugin's hooks. |
| `artifact-persona-authoring` | Design | Shows the persona roster (standard + custom), interviews you for a custom reader, writes it to `.claude/skills/persona-<slug>/`. A skill, both harnesses. |

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
- Custom, in your repo: `artifact-persona-authoring` writes one to `.claude/skills/`
- Standard: [persona-review-definition.md](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md). Skeleton: [persona-review-template.md](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md)

## What's inside

```
.claude-plugin/marketplace.json           marketplace manifest (Claude Code)
.agents/plugins/marketplace.json          marketplace manifest (Codex)
plugins/asimov-plugin/                    the plugin (install scope)
├── .claude-plugin/plugin.json            plugin manifest (Claude Code)
├── .codex-plugin/plugin.json             plugin manifest (Codex)
├── hooks/                               asimov-context + run-hook.cmd/.ps1 — the Asimov context injected at session start where asimov.md marks the repo (hooks.json for Claude Code, hooks-codex.json for Codex); scripts/asimov-log.ps1 — the run log
├── agents/                               subagent shells (Giskard, Daneel, Calvin, Baley) — .md for Claude Code, .toml for Codex
├── skills/                               role-* (the subagents' methods), artifact-d101-* (D101 authoring + gap review), artifact-persona-authoring (custom persona authoring), artifact-s101-*/artifact-s102-* (Spec-stage authoring + validation), asimov-init (setup entry point, both harnesses), using-asimov (the context the hooks inject), asimov-design (Design-stage entry point, both harnesses; the review a path of it), asimov-spec (Spec-stage entry point, both harnesses), asimov-build (Build-stage entry point), persona-* (Poseidon, Athena, Hermes), pm-advisor
├── artifacts/                            one folder per artifact the toolkit writes into a product repo, grouped by where it lands
│   ├── documentation/                    lands in the product repo's documentation/
│   │   ├── d101-feature-design/          the D101 artifact: definition + template side by side
│   │   │   ├── d101-feature-design-definition.md
│   │   │   └── d101-feature-design-template.html
│   │   ├── site/                         the documentation/ landing site (asimov-init)
│   │   │   ├── site-definition.md
│   │   │   ├── nav-template.html, home-template.html, section-template.html, document-template.html
│   │   │   └── _chrome.css
│   │   └── conventions/                  documentation/conventions/<stack>/README.md (asimov-init)
│   │       ├── conventions-definition.md
│   │       └── conventions-readme-template.md
│   ├── skills/                           lands in the product repo's .claude/skills/
│   │   └── persona-review/               the persona review skill artifact (artifact-persona-authoring)
│   │       ├── persona-review-definition.md
│   │       └── persona-review-template.md       SKILL.md skeleton for a persona review skill
│   ├── dot-asimov/                       lands in the product repo's .asimov/ — the run log's definition
│   └── root/                             lands at the product repo's root
│       └── asimov-md/                    the asimov.md marker (asimov-init); the context is skills/using-asimov
│           ├── asimov-md-definition.md
│           └── asimov-md-template.md
├── contracts/                            stage handoffs — design.md: what a design must contain for Spec to plan from it
├── resources/                            building blocks shared across artifacts
│   ├── diagrams/                         the 4 standard diagram notations a D101 may use
│   │   ├── README.md                     routing table: reader intent → diagram type
│   │   ├── sequence-template.svg
│   │   ├── activity-swimlane-template.svg
│   │   ├── state-machine-template.svg
│   │   └── flowchart-template.svg
│   ├── figures/                          the drawing language of an illustration: glyphs + 7 patterns
│   │   ├── README.md                     figure or diagram; routing: what the reader must see → pattern
│   │   ├── glyphs.svg
│   │   └── <pattern>-template.svg        scene · track · map · grid · page · roster · terminal
│   └── deck/                             the slide-deck skeleton: one HTML file, notes, PDF, one theme pasted in
│       ├── README.md                     how a deck is built, the token contract, where a theme is found
│       ├── deck-template.html
│       └── themes/                       asimov.css · light.css (brand themes live in the product repo)
└── processes/                            the Delivery Model corpus pm-advisor reads (generated export)

packages/                                 NuGet packages, released with the plugin under the same version
├── Asimov.Packages.slnx
├── src/
│   ├── Asimov.Conventions/               the analyzers a .NET product uses and their whole configuration; one reference, one mode
│   ├── Asimov.TestConventions/           the test layer on top of it
│   └── Asimov.Conventions.Patterns/      analyzers for the patterns a product opts into (builder, mapper, ...), off by default
└── test/
    └── Asimov.Conventions.Patterns.Tests/

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
- [D101 definition](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md) – the two bars, phase vs status
- [D101 template](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html) – structure + ground rules in the leading comment
- [Diagram templates](plugins/asimov-plugin/resources/diagrams/README.md) – the four notations and when to use which
- [Figure templates](plugins/asimov-plugin/resources/figures/README.md) – the glyphs and the seven patterns an illustration is drawn from
- [Deck](plugins/asimov-plugin/resources/deck/README.md) – the slide-deck skeleton and its themes; `tool-deck-authoring` writes one
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
