<!--
  asimov.md template — the Asimov marker that asimov-init writes to the ROOT of a product repo.

  WHAT IT IS (since 2026-11-12)
  - A marker, not the context. Its presence tells the plugin's hooks (hooks/asimov-context) to
    inject the using-asimov skill at session start and the subagent note at subagent start, from
    the installed plugin; nothing imports this file (no `@asimov.md` in CLAUDE.md, no region in
    AGENTS.md). Its keys name the entry points the repo uses, and the hook cuts the context to
    them: `enabled` or `disabled`, one per line, absent meaning enabled. asimov-design-review
    follows asimov-design; asimov-init is always in. All four disabled is the opt-out: the marker
    stays, nothing is loaded.
  - The body is three lines for people. The hook reads nothing else: the repo name comes from
    the folder, the stacks from documentation/conventions/.

  HOW asimov-init USES THIS FILE
  - Read at run-time (the file in the plugin is the source of truth — D100 §7.4).
  - Substitute each {{ASIMOV-*}} with `enabled` or `disabled` as the person chose.
  - The rendered file is REGENERATED WHOLESALE on every run (D101 R2). It is Asimov-owned:
    developers keep their own context in CLAUDE.md or AGENTS.md, never here.
  - Keep this generic and reusable — no product-specific entity names (D100 §8.4).
  - The frontmatter is read by the hook with a line parser: one `key: value` per line, never
    nested, never quoted.
-->
---
asimov-design: {{ASIMOV-DESIGN}}
asimov-spec: {{ASIMOV-SPEC}}
asimov-build: {{ASIMOV-BUILD}}
asimov-project: {{ASIMOV-PROJECT}}
---

# Asimov

This repository uses the Asimov toolkit (https://github.com/context-and-oss/asimov). With `asimov-plugin` installed, Claude Code and Codex load the Asimov context from the plugin at session start; this file only marks the repository and says which entry points are in use. Refresh the setup with `/asimov-init`.
