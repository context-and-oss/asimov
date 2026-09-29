---
name: persona-new
description: Author a custom persona review skill by interviewing the developer for the five persona fields, then rendering the persona template into a self-contained SKILL.md in the product repo's .claude/skills/. One reader per run; advisory quality check; never writes without a confirmed plan.
argument-hint: (optional) the reader in a phrase — e.g. "our depot dispatcher" — or empty to start the interview cold
allowed-tools: Read, Write, Glob
---

# persona-new

Interviews the developer for a custom persona — a product-specific reader — and writes it as a self-contained review skill into the product repo, one copy per tool.

Read `method.md` in this skill's folder first and follow it. It carries the whole method; this file is only the entry.
