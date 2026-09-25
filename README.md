# Asimov

Plugins for Claude Code and Codex. Feature design docs done properly, plus subagents that code and review the way your repo already does. One tool-neutral source tree, generated into a plugin per tool — `asimov-plugin` for Claude Code, `asimov-plugin-codex` for Codex — with the same commands, subagents and skills on both sides.

- `/d101-feature-design` – interviews you, writes a D101 (feature design) as HTML to `documentation/features/`
- `/d101-review` – checks a D101 against its bar, lists what's missing
- `/asimov-init` – sets up a repo for both tools: `asimov.md`, convention read-lists, docs landing page, Codex subagents
- `/persona-new`, `/persona-list` – author and list the reader personas (ops, architect, sponsor, or one you define) that `/d101-review` reads a design as
- Subagents: Giskard (.NET, plus a small-tier twin for fully specified one-file changes), Daneel (Angular), Calvin (tests), Baley (code review). They read your repo's convention files at run-time, no guessing.
- `pm-advisor` – a skill that answers delivery-model questions from the corpus it ships with

Why: agents write decent code when the design is actually written down. Most design docs aren't written for that. A D101 has a definition with two bars. The author clears the first before writing the technical part. Someone else decides the second.

## Install

Claude Code:

```
/plugin marketplace add context-and-oss/asimov
/plugin install asimov-plugin
```

Codex: install `asimov-plugin-codex` through Codex's plugin marketplace against the same repository — it reads `.agents/plugins/marketplace.json`.

Both marketplaces serve from the rolling `latest` release tag; `main` carries only the tool-neutral source.

- Update: `/plugin marketplace update asimov-marketplace` in Claude Code, the marketplace-update command in Codex. No auto-update.
- Local clone: generate the plugin trees first (they are gitignored on `main`), then add the clone as a marketplace:

```
cd generator && npm install && npm run generate
/plugin marketplace add <path-to-clone>
```

## Try it

```
/asimov-init
/d101-feature-design
/d101-review
```

- First one wires up the repo — for Claude Code (`CLAUDE.md` imports `asimov.md`) and for Codex (an `AGENTS.md` managed region, subagents in `.codex/agents/`).
- Second one interviews you and writes the D101. Stops after the business design; run it again for the technical design.
- Third one tells you what the document still lacks. Can also run the persona reviews.

In Codex the same commands are skills: `$asimov-plugin-codex:d101-review` and so on.

<!-- TODO: screenshot of a rendered D101 -->

## Status

- Releases: [releases page](../../releases). Major-only versions (`1.0.0`, `2.0.0`, …), any release may change a bar or a template. Both marketplaces follow the `latest` tag.
- Built: Design-stage commands, the four subagents and the small twin, persona reviews, the `pm-advisor` skill (delivery-model advice), the tool-agnostic build pipeline.
- Planned: Spec stage (`/s101-*`), `/conventions-check`, S101 validator subagent. See [D100 §9](documentation/D100-Asimov-architecture.md#9-not-yet-built).
- Every artifact carries a maturity level (`assess` / `trial` / `adopt` / `hold`). The producing command tells you if it's not at `adopt`.
- Requires a tool with plugin support and access to the models the commands are designated for. Source files name a tier, never a model; one table per tool maps tier → model: [claude-code.md](source/mappings/claude-code.md), [codex.md](source/mappings/codex.md).

## Commands

| Command | Stage | What it does |
|---|---|---|
| `/d101-feature-design` | Design | Interview → D101 as self-contained HTML. Three phases, hard stop after the business design. |
| `/d101-review` | Design | Reads a D101, resolves its phase, reports findings against §8a or §8b and leaves them in a gitignored `.review.md` beside the file for `/d101-feature-design` to pick up. Never edits the D101, no verdict. |
| `/d101-convert-to-html` | Design | Legacy markdown D101 → HTML, next to the source. |
| `/asimov-init` | Setup | Writes `asimov.md`, imports it from `CLAUDE.md` and carries it in an `AGENTS.md` managed region, delivers the Codex subagents into `.codex/agents/`, scaffolds `documentation/conventions/<stack>/`, generates the docs landing page. |
| `/persona-new` | Design | Interview → custom persona review skill in `.claude/skills/persona-<slug>/`. |
| `/persona-list` | Design | Lists standard + custom personas. |

## Subagents

| Subagent | Stage | What it does |
|---|---|---|
| `giskard-the-dotnet-developer` | Code | C#/.NET, following the repo's .NET conventions. |
| `giskard-the-dotnet-developer-small` | Code | The same prompt at the small tier, for a fully specified one-file `.cs` change; hands anything larger back. |
| `daneel-the-angular-developer` | Code | TypeScript/Angular, following the repo's Angular conventions. |
| `calvin-the-test-author` | Code | Tests (.NET for now) for the code your branch touched, in the repo's test conventions. Flags untestable code back to its author. |
| `baley-the-code-reviewer` | Review | Diff vs base against conventions + correctness. Read-only, findings only. |

Every agent that changes files signs its report with an `Asimov-Built-By: <agent> (<tool>, <model>, effort <effort>)` line, and the commit carries it as a git trailer — so you can see afterwards which agent and model produced a change.

## Personas

A persona review reads a D101 as one of its intended readers and reports where the document talks to its author instead. Ships as skills named `persona-<slug>`.

- Standard, in the plugins: `persona-poseidon` (operations), `persona-athena` (architecture, incl. §6), `persona-hermes` (cost / ROI)
- Custom, in your repo: `/persona-new` writes one to `.claude/skills/`
- Standard: [persona-review-definition.md](source/artifacts/skills/persona-review/persona-review-definition.md). Skeleton: [persona-review-template.md](source/artifacts/skills/persona-review/persona-review-template.md)

## What's inside

```
source/                                   the tool-neutral source — the only tree people edit
├── toolkit.json                          plugin + marketplace metadata
├── commands/                             slash commands (frontmatter: tier + effort, never a model name)
├── agents/                               subagents (Giskard [+ small twin], Daneel, Calvin, Baley)
├── personas/                             standard persona review skills (Poseidon, Athena, Hermes)
├── skills/                               advisory skills (pm-advisor)
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
│   ├── skills/                           lands in the product repo's skills folder
│   │   └── persona-review/               the persona review skill artifact (/persona-new)
│   │       ├── persona-review-definition.md
│   │       └── persona-review-template.md       SKILL.md skeleton for a persona review skill
│   └── root/                             lands at the product repo's root
│       └── asimov-md/                    the asimov.md context file (/asimov-init)
│           ├── asimov-md-definition.md
│           └── asimov-md-template.md
├── resources/                            building blocks shared across artifacts
│   └── diagrams/                         the 4 standard diagram notations a D101 may use
│       ├── README.md                     routing table: reader intent → diagram type
│       ├── sequence-template.svg
│       ├── activity-swimlane-template.svg
│       ├── state-machine-template.svg
│       └── flowchart-template.svg
├── processes/                            the Delivery Model corpus pm-advisor reads (generated export)
└── mappings/                             tier/effort → model, one table per tool (the only home for model names)
generator/                                deterministic build step (Node.js/TypeScript) + tests
plugins/asimov-plugin/                    GENERATED Claude Code plugin  — gitignored on main, carried by release tags
plugins/asimov-plugin-codex/              GENERATED Codex plugin        — gitignored on main, carried by release tags
.claude-plugin/marketplace.json           Claude Code marketplace manifest (hand-maintained)
.agents/plugins/marketplace.json          GENERATED Codex marketplace manifest (gitignored on main)
.github/workflows/                        PR gate (generate ×2, byte-compare, manifest check) + release (regenerate, stamp, tag off-main, publish)
site/ + netlify.toml                      the public website
documentation/                            repo docs (not inside install scope)
├── D100-Asimov-architecture.md            why + how
├── ai-transition-levels-and-zones.md      the Levels & Zones vocabulary Asimov uses (L0–L5, Z1–Z3, the L3 stages)
├── index.html + _chrome.css               the rendered documentation site
├── features/                              per-feature D101s
└── research/                              decision provenance
```

## Docs

- [Website](https://asimov-plugin.netlify.app) – what Asimov is, for someone who has never used it
- [D100 – Architecture](documentation/D100-Asimov-architecture.md) – why, components, distribution, patterns
- [D101 – Tool-agnostic toolkit & Codex support](documentation/features/D101-agnostic-toolkit-codex-support.html) – the source → generator → two-plugins design
- [D101 – Artifact maturity](documentation/features/D101-artifact-maturity.html) – the level every artifact carries, and what moves it
- [D101 definition](source/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md) – the two bars, phase vs status
- [D101 template](source/artifacts/documentation/d101-feature-design/d101-feature-design-template.html) – structure + ground rules in the leading comment
- [Diagram templates](source/resources/diagrams/README.md) – the four notations and when to use which
- [Levels & Zones](documentation/ai-transition-levels-and-zones.md) – what L3, "L3 on Zone 2" and the pipeline stages mean
- [CLAUDE.md](CLAUDE.md) – working *on* the toolkit: conventions, how to add things, hard rules

Nothing in the plugins is tied to one product. Forking means changing `documentation/` and `source/mappings/`, mostly. See D100 §8.4.

## Contributing

- Bugs and proposals: [issues](../../issues), templates provided
- Pull requests: read [CONTRIBUTING.md](CONTRIBUTING.md) first. Commands get a D101 before a prompt. Reviewer ≠ author.
- Security: [SECURITY.md](SECURITY.md), report privately
- [Code of conduct](CODE_OF_CONDUCT.md)

Maintained by Context&. Lead: [@Aborup](https://github.com/Aborup). Team: `@context-and-oss/team-asimov`.

## License

[MIT](LICENSE), Copyright (c) 2026 Context&.
