# Contributing to Asimov

Asimov is a plugin for Claude Code and Codex — one folder both tools install, no build step: skills, subagents, definitions and templates. There is no compiled code. A contribution is a change to a prompt, a definition, a template or a document, and it is reviewed like code.

## What belongs here

Asimov ships **generic** tooling for the AI-assisted stages of the L3 pipeline ([what L3 means](documentation/ai-transition-levels-and-zones.md)). Anything that only makes sense for one product stays in that product's repo. In particular:

- Definitions, templates and command prompts carry no product-specific identifiers (CLAUDE.md hard rule 7). Path conventions such as `documentation/features/` are fine; product entity names are not.
- Standard personas are generic archetypes. A reader specific to one product is a **custom** persona, authored with `/persona-new` into the product repo, not into the plugin.
- When in doubt, name it generically and add an example as illustration (hard rule 8).

## Before you start

**Open an issue first** for anything that adds or changes behaviour: a new command, subagent, standard persona or artifact; a change to a definition's bar; a change to a template's structure. Use the *Proposal* issue template. This saves you from writing a design that the maintainers would decline.

**Small fixes go straight to a pull request**: typos, broken links, a wrong path, a clarification that does not change what a command does.

## How a change is made

Every command and subagent in Asimov has a design document (a D101) before it has a prompt. Contributions follow the same path:

1. Read [`CLAUDE.md`](CLAUDE.md): the conventions, the "How to add" recipes and the hard rules. They are enforcement rules, not style preferences.
2. Read [`documentation/D100-Asimov-architecture.md`](documentation/D100-Asimov-architecture.md) for where your change sits.
3. For a new command or subagent, author the D101 with `/d101-feature-design` and clear the business-complete bar (§8a) before writing the technical design. The definition is [`d101-feature-design-definition.md`](plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md).
4. Author the change. Keep the D100 rows in sync, name no model anywhere, keep every skill as `SKILL.md` + `method.md`, and bump the plugin version in both manifests in the same commit (hard rules 2, 6, 11 and 14).
5. Test it locally in a product repo (below).
6. Open a pull request against `main`.

## Testing locally

Claude Code:

```
claude --plugin-dir <path-to-your-clone>/plugins/asimov-plugin
```

or add the clone as a marketplace (`/plugin marketplace add <path-to-your-clone>`, then `/plugin install asimov-plugin`; edits show after `/reload-plugins`).

Codex:

```
codex plugin marketplace add <path-to-your-clone>
codex plugin add asimov-plugin@asimov-marketplace
```

Then run the skill or subagent in any product repo (`/<name>` in Claude Code, `$asimov-plugin:<name>` in Codex). After editing, Codex needs the plugin removed and added again and a new session. A change must work in both tools before it is merged.

## Pull requests

- One change per pull request. A refactor and a behaviour change are two pull requests.
- The description says what changed and why. For a command or subagent, link the D101.
- CI must be green.
- **The reviewer is never the author.** A maintainer other than the author approves. This is the toolkit's own rule applied to the toolkit.
- Dates are `YYYY-MM-DD`. Prose is English.
- Do not commit `*.review.md` files or raw images; `.gitignore` excludes them at the standard locations (`documentation/features/`, `documentation/**/images/_raw/`). A D101 kept elsewhere needs its own ignore entry.

A maintainer may ask you to run `/d101-review` on your D101 and address the findings before review. Accepted deviations are recorded in the D101 itself, never in the pull request (hard rule 5).

## Maintainers and decisions

- **Lead maintainer:** [@Aborup](https://github.com/Aborup).
- **Maintainers:** the `@context-and-oss/team-asimov` team. They review, merge, triage issues and cut releases.
- **Steward:** Context&, which owns the repository, the name and the licence.

Maintainers decide by agreement in the pull request or issue. When they disagree, the lead maintainer decides. Architectural decisions are recorded in D100; design decisions in the relevant D101.

## Licence

Asimov is released under the [MIT licence](LICENSE). By contributing you agree that your contribution is licensed under the same terms. There is no contributor licence agreement to sign.
