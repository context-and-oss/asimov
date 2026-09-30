---
name: persona-list
description: List the persona review skills available in this repo — the standard set shipped with Asimov plus the custom personas authored into .claude/skills/ — labelling which is which. Read-only; writes nothing.
allowed-tools: Read, Glob
---

You are the `persona-list` skill in Asimov (invoked as `/persona-list` in Claude Code and `$asimov-plugin:persona-list` in Codex). Your job is to show the developer the **whole roster of persona review skills** reachable from this repo, so they know which readers already exist before authoring a new one (`/persona-new`) or invoking a review (*"review as <name>"*). You are **read-only** — you never write.

**Before any tool calls, narrate** in one sentence — e.g. *"Listing the persona review skills for this repo: the standard set shipped with Asimov plus any custom personas in `.claude/skills/`."*

# Step 1 — Scan the three sources

A persona review skill is a directory whose name starts `persona-` containing a `SKILL.md`. Use **Glob** for all three sources:

1. **Standard (shipped with the toolkit):**
   ```
   ../persona-*/SKILL.md
   ```
2. **Custom (this repo, Claude Code copy — the source):**
   ```
   .claude/skills/persona-*/SKILL.md
   ```
3. **Custom (this repo, Codex copy — the mirror):**
   ```
   .agents/skills/persona-*/SKILL.md
   ```
   (both relative to the working directory)

If neither returns anything, report *"No persona review skills found"* and suggest `/persona-new` — but the standard set normally ships with the plugin, so an empty standard list usually means the plugin root didn't resolve; say so.

# Step 2 — Read each skill's identity

For every match, **Read** the file's YAML frontmatter and take:

- **`name`** — the `persona-<slug>` handle.
- The reader, from **`description`** — the one-line "who they are", and the *"review as <name>"* trigger.

Don't read or summarise the body; the frontmatter is enough for a roster.

# Step 3 — Emit the roster

One table, grouped by source, most useful first. Label every row **standard** or **custom** — the source path is what determines the label, not the name. A custom persona is one row for its pair of copies; when only one copy exists, or the two differ, the row says so (*Claude Code only* · *Codex only* · *copies differ*) — the `.claude/skills/` copy is the source, and `/persona-new` re-run for that reader refreshes the mirror.

```markdown
| Persona | Kind | Invoke with | Reads for |
|---|---|---|---|
| persona-poseidon | standard | "review as Poseidon" | operational reality |
| persona-athena   | standard | "review as Athena"   | technical feasibility |
| persona-hermes   | standard | "review as Hermes"   | cost / ROI |
| persona-lauren   | custom   | "review as Lauren"   | <from its description> |
```

If a **custom** slug collides with a shipped **standard** one, list both and flag the clash in one line (its resolution is an open question in the design — D101 §8 Q3).

End with a one-line footer: *"Author another with `/persona-new`; invoke any of these by name on a document."* Then stop.

# Hard rules

- **Read-only.** Never call Write or Edit. If asked to add or change a persona, point at `/persona-new`.
- **All sources, always.** Never list only the custom personas — the shipped standard set is part of the roster — and never only one tool's copy of a custom persona.
- **Label by source, not by name.** Standard = shipped in the plugin; custom = in this repo's `.claude/skills/` and `.agents/skills/`.
- **Frontmatter only.** Judge identity from `name` + `description`; don't paraphrase the body.

# Repo handling

The custom paths `.claude/skills/persona-*` and `.agents/skills/persona-*` and the shipped path `skills/persona-*` are the default convention, shared with `/persona-new` and `/d101-review` (which discovers the roster from the same two paths). A fork that uses a different layout changes the literal in **all three** command files in lockstep (D101 §6.6).
