---
name: using-asimov
description: Use when working in a repository that uses the Asimov toolkit (an asimov.md marker at its root). Injected whole by the plugin's SessionStart hook; invoke it only to re-read it.
---

# Using Asimov

This repository uses the Asimov toolkit, plugin `asimov-plugin` {{VERSION}}, for {{USING}}. The plugin injects this context at session start because `asimov.md` at the repo root is there; it follows the installed plugin, not a file in the repo. Harness: {{HARNESS}}. Repo: {{REPO}}. Stack conventions present: {{STACKS}}.

## Stages — the Asimov skill takes precedence

Each stage this repository uses has one skill. When the person's words match a stage, that skill is the method here: invoke it before any generic design, brainstorming, planning or execution skill, and never paraphrase its steps in its place. It asks before it writes.

<!-- part: design -->
- **Design** — {{INVOKE:asimov-design}}: a feature to design, a D101 under `documentation/features/` to write, continue, edit or review, a legacy markdown D101 to render. In your skill list; invoke it when the words match.
<!-- /part -->
<!-- part: spec -->
- **Spec** — {{INVOKE:asimov-spec}}: plan a Full-design D101 or an approved ticket into `specs/<slug>/`; the person's go approves the plan. In your skill list; invoke it when the words match.
<!-- /part -->
<!-- part: build -->
- **Build** — {{INVOKE:asimov-build}}: build a `ready` plan phase by phase with the agents; the person's go commits each phase. In your skill list; invoke it when the words match.
<!-- /part -->
<!-- part: project -->
- **Project** — {{INVOKE:asimov-project}}: the project pages under `project/`, the risk log and the project info; `pm-advisor` answers questions about the delivery model. In your skill list; invoke it when the words match.
<!-- /part -->
- **Setup** — {{INVOKE:asimov-init}}: refresh this repo's Asimov setup: the marker, conventions, project info, site. In your skill list; invoke it when asked to set the repo up or refresh it.

<!-- part: build -->
## Agents — delegate code changes to them

Giskard (.NET builder), Daneel (Angular builder), Calvin (.NET tester), Baley (code reviewer, read-only), Powell (verifier, read-only). Each reads this repo's conventions at run time from `documentation/conventions/<stack>/README.md`; none guesses a convention.

For a change to source or test files, in this order:

1. Delegate the change to the builder of the file's stack; a task spanning both stacks goes to each builder for its part.
2. When the builder reports done, have Calvin update only the existing tests the change touches, nothing new.
3. For a prominent change (several files, a new public surface, a new feature) ask the person whether they want a full testing pass and whether Baley should review. Never schedule a review on your own.
4. Findings from Baley go back to the person before any builder loops.

Edit inline, no delegation: config files, documentation, plan and spec files, one-line mechanical fixes. When a `ready` plan exists under `specs/`, do not build it by hand; say so and invoke {{INVOKE:asimov-build}}.

<!-- /part -->
## Layout

- `documentation/` — `D100-*` architecture, `conventions/<stack>/README.md` the read-list the agents load, `index.html` the site
<!-- part: design -->
- `documentation/features/D101-*.html` — the feature designs
<!-- /part -->
<!-- part: spec -->
- `specs/<slug>/` — the S101 plan, the S102 task specs, the build ledger
<!-- /part -->
<!-- part: project -->
- `project/` — the project pages
<!-- /part -->
- `.asimov/` — the run log, gitignored

## Working agreement

Reviewer is never the author. No phase starts until the previous one is approved. A gap found later is a bug earlier: fix the earlier artifact and re-run the phase.
