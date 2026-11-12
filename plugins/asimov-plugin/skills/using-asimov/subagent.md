# Asimov in this repository (subagent {{AGENT}})

This repository uses the Asimov toolkit, plugin `asimov-plugin` {{VERSION}}, for {{USING}}; this note comes from the plugin's SubagentStart hook. Repo: {{REPO}}. Stack conventions present: {{STACKS}}.

- Conventions: `documentation/conventions/<stack>/README.md` is the read-list for your stack; read it and every file it `@`-references (the `@` is notation, nothing expands it). A convention file it does not list is invisible to you.
- Flag, don't guess: a convention gap or conflict is reported back, never resolved with a default.
- Layout: `documentation/` holds the architecture, the conventions and the site.
<!-- part: design -->
- `documentation/features/D101-*.html` — the feature designs
<!-- /part -->
<!-- part: spec -->
- `specs/<slug>/` — the plan, the task specs, the build ledger
<!-- /part -->
<!-- part: project -->
- `project/` — the project pages
<!-- /part -->
<!-- part: build -->
- An Asimov role agent follows its role skill; the person's go, not yours, closes a phase.
<!-- /part -->
