# Contributing to Asimov

Asimov is a toolkit for Claude Code and Codex: slash commands, subagents, skills, definitions and templates, authored once in a tool-neutral `source/` tree and generated into a plugin per tool. There is no runtime code beyond the generator. A contribution is a change to a prompt, a definition, a template or a document — always in `source/`, never in a generated tree — and it is reviewed like code.

## What belongs here

Asimov ships **generic** tooling for the AI-assisted stages of the L3 pipeline ([what L3 means](documentation/ai-transition-levels-and-zones.md)). Anything that only makes sense for one product stays in that product's repo. In particular:

- Definitions, templates and command prompts carry no product-specific identifiers (CLAUDE.md hard rule 8). Path conventions such as `documentation/features/` are fine; product entity names are not.
- Standard personas are generic archetypes. A reader specific to one product is a **custom** persona, authored with `/persona-new` into the product repo, not into the plugin.
- When in doubt, name it generically and add an example as illustration (hard rule 9).

## Before you start

**Open an issue first** for anything that adds or changes behaviour: a new command, subagent, standard persona or artifact; a change to a definition's bar; a change to a template's structure. Use the *Proposal* issue template. This saves you from writing a design that the maintainers would decline.

**Small fixes go straight to a pull request**: typos, broken links, a wrong path, a clarification that does not change what a command does.

## How a change is made

Every command and subagent in Asimov has a design document (a D101) before it has a prompt. Contributions follow the same path:

1. Read [`CLAUDE.md`](CLAUDE.md): the conventions, the "How to add" recipes and the hard rules. They are enforcement rules, not style preferences.
2. Read [`documentation/D100-Asimov-architecture.md`](documentation/D100-Asimov-architecture.md) for where your change sits.
3. For a new command or subagent, author the D101 with `/d101-feature-design` and clear the business-complete bar (§8a) before writing the technical design. The definition is [`d101-feature-design-definition.md`](source/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md).
4. Author the change in `source/`. Keep the D100 rows and the `tier`/`effort` frontmatter in sync in the same commit (hard rules 4, 7 and 11); a concrete model name belongs only in `source/mappings/`.
5. Test it locally in a product repo (below).
6. Open a pull request against `main`.

## Testing locally

Generate the plugin trees first — they are gitignored on `main`, so a fresh clone has none:

```
cd generator && npm install && npm run generate && npm test
```

Then, in Claude Code:

```
/plugin marketplace add <path-to-your-clone>
/plugin install asimov-plugin
```

In Codex, install `asimov-plugin-codex` from the same clone through Codex's plugin marketplace mechanism. Then run the command or subagent in any product repo. After editing, regenerate and refresh:

```
/plugin marketplace update asimov-marketplace
```

There is no auto-reload.

## Pull requests

- One change per pull request. A refactor and a behaviour change are two pull requests.
- The description says what changed and why. For a command or subagent, link the D101.
- CI must be green: the gate refuses generated files in the diff, generates twice and byte-compares, checks the marketplace manifest against the generated plugin manifest, and runs the generator's tests.
- **The reviewer is never the author.** A maintainer other than the author approves. This is the toolkit's own rule applied to the toolkit.
- Dates are `YYYY-MM-DD`. Prose is English.
- Do not commit `*.review.md` files or raw images; `.gitignore` excludes them at the standard locations (`documentation/features/`, `documentation/**/images/_raw/`). A D101 kept elsewhere needs its own ignore entry.

A maintainer may ask you to run `/d101-review` on your D101 and address the findings before review. Accepted deviations are recorded in the D101 itself, never in the pull request (hard rule 6).

## Maintainers and decisions

- **Lead maintainer:** [@Aborup](https://github.com/Aborup).
- **Maintainers:** the `@context-and-oss/team-asimov` team. They review, merge, triage issues and cut releases.
- **Steward:** Context&, which owns the repository, the name and the licence.

Maintainers decide by agreement in the pull request or issue. When they disagree, the lead maintainer decides. Architectural decisions are recorded in D100; design decisions in the relevant D101.

## Licence

Asimov is released under the [MIT licence](LICENSE). By contributing you agree that your contribution is licensed under the same terms. There is no contributor licence agreement to sign.
