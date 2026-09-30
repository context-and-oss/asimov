# Asimov

A plugin for Claude Code and Codex. Feature design docs done properly, plus subagents that code and review the way your repo already does. One plugin folder, installed by both tools; the method lives once, in skills.

- `/d101-feature-design` – interviews you, writes a D101 (feature design) as HTML to `documentation/features/`
- `/d101-review` – checks a D101 against its bar, lists what's missing
- `/asimov-init` – sets up a repo for both tools: `asimov.md`, the Codex context and subagents, convention read-lists, docs landing page
- `/persona-new`, `/persona-list` – author and list the reader personas (ops, architect, sponsor, or one you define) that `/d101-review` reads a design as
- Subagents: Giskard (.NET), Daneel (Angular), Calvin (tests), Baley (code review). They read your repo's convention files at run-time, no guessing.
- `pm-advisor` – a skill that answers delivery-model questions from the corpus it ships with

Why: agents write decent code when the design is actually written down. Most design docs aren't written for that. A D101 has a definition with two bars. The author clears the first before writing the technical part. Someone else decides the second.

## Install

Claude Code:

```
/plugin marketplace add context-and-oss/asimov
/plugin install asimov-plugin
```

Codex:

```
codex plugin marketplace add context-and-oss/asimov
codex plugin add asimov-plugin@asimov-marketplace
```

Start a new session afterwards. The same repository serves both tools; Codex plugins are not available in the Codex IDE extension.

- Local clone, Claude Code: `claude --plugin-dir <clone>/plugins/asimov-plugin` for one session, or `/plugin marketplace add <path-to-clone>`
- Local clone, Codex: `codex plugin marketplace add <path-to-clone>`, then `codex plugin add asimov-plugin@asimov-marketplace`

## Try it

Claude Code:

```
/asimov-init
/d101-feature-design
/d101-review
```

Codex — the same entries are plugin skills, named in the prompt:

```
$asimov-plugin:asimov-init
$asimov-plugin:d101-feature-design
$asimov-plugin:d101-review documentation/features/D101-my-feature.html
```

- First one wires up the repo for both tools: `asimov.md` imported from `CLAUDE.md`, the same context in an `AGENTS.md` managed region, and the Codex subagents in `.codex/agents/`. It is always your call — the model never runs it on its own.
- Second one interviews you and writes the D101. Stops after the business design; run it again for the technical design.
- Third one tells you what the document still lacks. Can also run the persona reviews.

Codex reads the subagents from `.codex/agents/` only in a repo you have marked **trusted**, and only from the next session after `/asimov-init` delivered them. When `asimov-init` writes into `.codex/agents/`, Codex asks for your approval — its sandbox protects that folder; approve it, or run `asimov-init` from Claude Code once (it writes the same files). Codex skills take no arguments: whatever follows the skill mention in the prompt is the input.

## After a plugin update

1. Refresh the plugin with the tool's own command — Claude Code: `/plugin marketplace update asimov-marketplace`; Codex: `codex plugin marketplace upgrade asimov-marketplace`.
2. Claude Code: `/reload-plugins`, or start a new session. Codex: start a new session.
3. Run `/asimov-init` again only if the release notes say the agent shells changed — they are copies in your repo's `.codex/agents/` and do not follow the plugin on their own.

Neither tool auto-updates a third-party plugin by default.

<!-- TODO: screenshot of a rendered D101 -->

## Status

- Releases: [releases page](../../releases). Major-only versions (`1.0.0`, `2.0.0`, …), any release may change a bar or a template. The marketplace follows the `latest` tag.
- Built: Design-stage entry points, the four subagents (each a `role-*` skill plus a thin shell per tool), the two D101 artifact skills, persona reviews, the `pm-advisor` skill (delivery-model advice), Codex support.
- Planned: Spec stage (`/s101-*`; the S101 and S102 definitions exist), `/conventions-check`, S102 validator subagent, the update flow (`/asimov-update` and a session-start notice). See [D100 §9](documentation/D100-Asimov-architecture.md#9-not-yet-built).
- Every artifact carries a maturity level (`assess` / `trial` / `adopt` / `hold`). The producing skill tells you if it's not at `adopt`.
- Skills run on whatever model your session uses, in both tools. The Claude Code subagents pin Sonnet 4.6; the Codex subagents inherit your session's model for now.

## Entry points

Invoked as `/<name>` in Claude Code and `$asimov-plugin:<name>` in Codex.

| Skill | Stage | What it does |
|---|---|---|
| `d101-feature-design` | Design | Interview → D101 as self-contained HTML. Three phases, hard stop after the business design. |
| `d101-review` | Design | Reads a D101, resolves its phase, reports findings against §8a or §8b and leaves them in a gitignored `.review.md` beside the file for `d101-feature-design` to pick up. Never edits the D101, no verdict. |
| `d101-convert-to-html` | Design | Legacy markdown D101 → HTML, next to the source. |
| `asimov-init` | Setup | Writes `asimov.md`, imports it from `CLAUDE.md`, carries it in an `AGENTS.md` managed region, delivers the Codex subagents to `.codex/agents/`, scaffolds `documentation/conventions/<stack>/`, generates the docs landing page. User-only in both tools. |
| `persona-new` | Design | Interview → custom persona review skill, written to `.claude/skills/persona-<slug>/` and mirrored to `.agents/skills/persona-<slug>/`. |
| `persona-list` | Design | Lists standard + custom personas, both copies. |

## Subagents

| Subagent | Stage | What it does |
|---|---|---|
| `giskard-the-dotnet-developer` | Code | C#/.NET, following the repo's .NET conventions. |
| `daneel-the-angular-developer` | Code | TypeScript/Angular, following the repo's Angular conventions. |
| `calvin-the-test-author` | Code | Tests (.NET for now) in the repo's test conventions. Flags untestable code back to its author. |
| `baley-the-code-reviewer` | Review | Diff vs base against conventions + correctness. Read-only, findings only. |

Each subagent's method lives in a `role-*` skill; the agent file is a thin shell — `.md` for Claude Code (ships with the plugin), `.toml` for Codex (delivered into your repo's `.codex/agents/` by `/asimov-init`). The `.md` shell pins the model (Sonnet 4.6); the `.toml` shell names none and inherits the session's.

## Personas

A persona review reads a D101 as one of its intended readers and reports where the document talks to its author instead. Ships as skills named `persona-<slug>`.

- Standard, in the plugin: `persona-poseidon` (operations), `persona-athena` (architecture, incl. §6), `persona-hermes` (cost / ROI)
- Custom, in your repo: `/persona-new` writes one to `.claude/skills/` (the source) and `.agents/skills/` (the Codex copy)
- Standard: [persona-review-definition.md](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md). Skeleton: [persona-review-template.md](plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md)

## What's inside

```
.claude-plugin/marketplace.json           Claude Code marketplace manifest
.agents/plugins/marketplace.json          Codex marketplace manifest — same plugin, same path
plugins/asimov-plugin/                    the plugin (install scope), read as-is by both tools — no build step
├── .claude-plugin/plugin.json            Claude Code plugin manifest
├── .codex-plugin/plugin.json             Codex plugin manifest — same name, version, description
├── skills/                               one SKILL.md per skill, read in full by both tools
│   ├── asimov-init/ · d101-*/ · persona-new/ · persona-list/   entry points (the former commands)
│   ├── role-*/                           the subagents' methods
│   ├── artifact-d101-*/                  D101 authoring + gap review
│   ├── persona-*/                        Poseidon, Athena, Hermes
│   └── pm-advisor/                       delivery-model advice over processes/
├── agents/                               subagent shells — <name>.md (Claude Code, pins the model) + <name>.toml (Codex, inherits)
├── artifacts/                            one folder per artifact the toolkit writes into a product repo, grouped by where it lands
│   ├── documentation/                    lands in the product repo's documentation/
│   │   ├── d101-feature-design/          the D101 artifact: definition + template side by side
│   │   ├── s101-implementation-plan/ · s102-task-spec/   the Spec-stage definitions (templates not built yet)
│   │   ├── site/                         the documentation/ landing site (/asimov-init)
│   │   └── conventions/                  documentation/conventions/<stack>/README.md (/asimov-init)
│   ├── skills/persona-review/            the persona review skill artifact (/persona-new)
│   └── root/asimov-md/                   the asimov.md context file (/asimov-init) — also the AGENTS.md region
├── resources/diagrams/                   the 4 standard diagram notations a D101 may use
└── processes/                            the Delivery Model corpus pm-advisor reads (generated export)
documentation/                            repo docs (not inside install scope)
├── D100-Asimov-architecture.md            why + how
├── ai-transition-levels-and-zones.md      the Levels & Zones vocabulary Asimov uses (L0–L5, Z1–Z3, the L3 stages)
├── index.html + _chrome.css               the rendered documentation site
├── features/                              one D101 per artifact or role family
└── research/                              decision provenance
```

## Docs

- [Website](https://asimov-plugin.netlify.app) – what Asimov is, for someone who has never used it
- [D100 – Architecture](documentation/D100-Asimov-architecture.md) – why, components, distribution, patterns
- [D101 – Codex support](documentation/features/D101-codex-support.html) – one plugin folder for two tools, skills both tools read, a thin agent shell per tool
- [D101 definition](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md) – the two bars, phase vs status
- [D101 template](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html) – structure + ground rules in the leading comment
- [Diagram templates](plugins/asimov-plugin/resources/diagrams/README.md) – the four notations and when to use which
- [Levels & Zones](documentation/ai-transition-levels-and-zones.md) – what L3, "L3 on Zone 2" and the pipeline stages mean
- [CLAUDE.md](CLAUDE.md) – working *on* the toolkit: conventions, how to add things, hard rules

Nothing in the plugin is tied to one product. Forking means changing `documentation/`, mostly. See D100 §8.4.

## Contributing

- Bugs and proposals: [issues](../../issues), templates provided
- Pull requests: read [CONTRIBUTING.md](CONTRIBUTING.md) first. Entry points get a D101 before a prompt. Reviewer ≠ author.
- Security: [SECURITY.md](SECURITY.md), report privately
- [Code of conduct](CODE_OF_CONDUCT.md)

Maintained by Context&. Lead: [@Aborup](https://github.com/Aborup). Team: `@context-and-oss/team-asimov`.

## License

[MIT](LICENSE), Copyright (c) 2026 Context&.
