---
name: asimov-init
description: Bootstrap a product repo to use the Asimov toolkit — writes an Asimov-owned asimov.md and wires it into CLAUDE.md via an @-import, scaffolds detected-stack convention read-lists, and generates the documentation/ landing site. Read-only on every other file. Supersedes /docs-init.
argument-hint: (optional) repo name override — empty auto-detects from git remote or folder name
allowed-tools: Read, Write, Glob, Grep, Bash
disable-model-invocation: true
---

# asimov-init

Makes the active product repo Asimov-ready for both Claude Code and Codex in one guided run: writes `asimov.md`, wires it into `CLAUDE.md` and `AGENTS.md`, delivers the Codex subagents, scaffolds the convention read-lists and renders the documentation site. A user decision — never invoked by the model on its own.

Read `method.md` in this skill's folder first and follow it. It carries the whole method; this file is only the entry.
