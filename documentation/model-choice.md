# Model choice — retired 2026-09-29

A model is named only in an agent shell, never in a skill. The four Claude Code shells (`plugins/asimov-plugin/agents/*.md`) pin `claude-sonnet-4-6`; the rationale is [D100 §7.3](D100-Asimov-architecture.md#73-models-in-the-shells-only), and four identical pins need no index. Skills run on the session's model in both tools; the Codex shells (`agents/*.toml`) name no model until proposal [#7](https://github.com/context-and-oss/asimov/issues/7) settles how Codex agents are pinned. Design: [`features/D101-codex-support.html`](features/D101-codex-support.html) (R6).

Routing a delegation to a smaller or larger model by written criteria, and logging what ran, is the same proposal #7.

This file stays so that older links resolve; it carries no mapping.
