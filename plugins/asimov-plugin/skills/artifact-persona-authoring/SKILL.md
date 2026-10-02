---
name: artifact-persona-authoring
description: Author a custom persona review skill for the product repo — interview the author for the five persona fields (identity, knows cold, does not know, has, is reviewing to), check the reader against the persona-review quality bar, then render the persona template into a self-contained SKILL.md at .claude/skills/persona-<slug>/. Use when asked to "author a persona", "add a reader", "make a persona for our <role>", "new persona", or to see which personas exist before adding one; also runnable by name in Claude Code and Codex. One reader per run; the quality check is advisory; nothing is written before the author confirms a plan. Never writes a standard persona and never edits one that exists.
---

# Persona authoring

The method for turning a description of a real reader into a **custom persona review skill**: a self-contained `SKILL.md` under the product repo's `.claude/skills/persona-<slug>/` that reads a document *as that reader* and reports where it talks to its author instead of to them. The design is `documentation/features/D101-personas.html` in the Asimov repo; the standard is the persona-review definition read below.

You author **one persona per run**, and only **custom** ones. The standard personas (`skills/persona-*` in the plugin) are curated by hand and never generated or edited here.

**Narrate first**, in one sentence: *"Let's author a persona. I'll show who already exists, interview you for five fields, and write a self-contained skill to `.claude/skills/persona-<slug>/SKILL.md` in this repo; nothing is written until you confirm a plan."*

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-persona-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/persona-review-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 or 2 cannot be read either way, stop and report the path; never render from memory, the file in the plugin is the run-time source of truth.

1. **The standard**: what a persona review is, the five fields (§3), the quality bar (§7 anti-patterns), the output shape:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/skills/persona-review/persona-review-definition.md
   ```

2. **The template**: the SKILL.md skeleton you render, with its leading authoring comment and worked example:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/skills/persona-review/persona-review-template.md
   ```

**Maturity notice.** The standard opens with a YAML block (`artifact`, `maturity`, `since`). Print at most one chat line before the first question, by the table every producing skill uses: `assess` → *"The persona review is an assess-level artifact: the definition is untried and may change without notice. Feedback is welcome."*; `trial` → *"… trial-level …: the form holds, but incompatible changes may come with a migration note."*; `adopt` → nothing; `hold` → *"The persona review is on hold. Start new documents from <successor>."*; missing or other → *"Maturity level not declared for the persona review."* with the value in brackets. Never write the level into the skill you produce; never edit the definition.

## Step 1 — Show the roster

Glob both sources, `${CLAUDE_PLUGIN_ROOT}/skills/persona-*/SKILL.md` (standard, shipped) and `.claude/skills/persona-*/SKILL.md` in the working directory (custom, this repo), read each frontmatter's `name` and `description` only, and print one table: persona, kind (**standard** or **custom**, by source path, never by name), the *"review as <name>"* trigger, and what it reads for. An empty standard list usually means the plugin root did not resolve; say so. A custom slug that equals a standard one is flagged in one line.

This is the roster the author is adding to; it is also the answer when someone only asked who exists. If the words that started this run named no reader and asked for no new one, stop here.

## Step 2 — Interview the five fields

Guide, do not interrogate. If the words that started the run name a reader (*"our depot dispatcher"*), infer what you can and confirm it; then ask only the gaps, two or three at a time. Collect all five (definition §3):

1. **Identity**: who they are, in one line. A real role in the product's world, not "a business user".
2. **Knows cold**: the domain they live in, which lets them spot condescension and wrong specifics.
3. **Does not know, and does not want to**: the codebase, the architecture, the internal vocabulary, which lets them catch leaked jargon and code-altitude prose.
4. **Has**: a time budget, and a job to get back to.
5. **Is reviewing to**: what they are there to correct, and what they are **not** there to do.

Also settle the reader's **name** (the persona's handle) and a one-line description of which documents they should review.

## Step 3 — Check against the quality bar (advisory)

Before writing, hold the described persona up to definition §7 and **warn**, naming the issue, when it:

- **knows the codebase**: then it cannot catch leaked jargon or code-altitude prose, the review's core job;
- **reads as a rubber stamp**: nothing it would fail;
- **is defined in our own jargon**: then it cannot flag leaked jargon;
- **is too generic to stall**: "a business user" with no domain it knows cold.

Advisory, not blocking (D101-personas R6, R7). State the risk plainly; if the author wants to proceed, write it anyway, it is their document. Never overrule them.

## Step 4 — Slug, then a write plan

1. **Derive the slug** from the reader's name (kebab-case); the skill's folder and `name` are both `persona-<slug>`. Offer it; the author may override.
2. **Resolve the target** `.claude/skills/persona-<slug>/SKILL.md` (relative to the working directory) and check it against the Step 1 roster: a file already at that path → action **OVERWRITE**, named, with the offer of a different slug; a slug equal to a shipped standard persona → warn that a custom one would shadow it and offer a different slug (R9); otherwise → action **NEW**.
3. **Show the plan and wait for explicit confirmation**: the target path and the action. Never write silently.

## Step 5 — Render and write

Only after confirmation. Render the template into the skill:

- Substitute every `{{PLACEHOLDER}}` with the interview answers; frontmatter `name: persona-<slug>`, and a `description` that carries the *"review as <name>"* trigger phrases (R4).
- Keep the generic fail/reward catalogue inline: the skill must run standalone and read no plugin file (R3). Reorder the fails by what this reader stops on; add the domain-specific ones the interview surfaced.
- **Strip the template's leading authoring comment**: it is instructions, not content (R5).

Create the folder if absent, write the `SKILL.md`, report the path.

## Step 6 — Report, then stop

Name the written path and say the reader can now be invoked by name, *"review as <name>"*, on any document, and that `asimov-design-review` will list it in its menu from the next run. If Step 3 raised a warning the author overrode, say in one line what risk the persona carries. Then stop.

## Invariants

- **Read-only except the one skill file.** Never write or edit anything but `.claude/skills/persona-<slug>/SKILL.md` and its folder. Never the plugin, never a standard persona, never another repo file.
- **Confirm before writing.** One plan, explicit confirmation.
- **Advisory, not blocking.** The quality check warns and explains; the author decides.
- **One persona per run.** A counterpart who reads the same way is their own run and their own `persona-<slug>`; never two readers in one file.
- **Self-contained output.** The generated skill inlines its method and catalogue and names no plugin path.
- **Re-read at run-time.** Load the definition and the template on every run.
- **Paths are a hard-rule-9 literal.** `.claude/skills/persona-*` (custom) and `skills/persona-*` (standard) are shared with `asimov-design-review`, which discovers the roster from the same two paths; a fork that uses another layout changes both files in lockstep (D101-personas §6.6).
