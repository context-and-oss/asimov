# Research — additional slash command ideas from the Claude Code ecosystem

> **Provenance.** Online survey conducted 2026-05-21 to identify candidate slash commands worth adding to the Asimov Plugin beyond the Q2 + Q3 inventory in `documentation/D100-Asimov-architecture.md` §4.3. Performed in the main session using WebSearch / WebFetch.
>
> **Question driving the research.** Which popular community / vendor slash commands fit the toolkit's L3 scope (Design → Spec → Code → Review+Test → Approve) and reusability bar (charter §1.2), and which look popular but don't fit?
>
> **What this is *not*.** Not a backlog. Not a commitment. A filtered list of candidates to discuss before any of them get a D101.

---

## 1. Filter criteria

A candidate is a "strong fit" only when it passes all five:

| # | Criterion | From |
|---|---|---|
| F1 | Slots into an L3 pipeline stage *or* is a clearly ad-hoc developer utility (like `/conventions-check`) | Charter §1.1, D100 §4.3 |
| F2 | Doesn't duplicate an existing or Q3-planned artifact | D100 §4.3, §4.4, §9 |
| F3 | Reusable across products — no product-specific identifiers in the prompt | Hard rule 6, charter §1.2 |
| F4 | References definitions / templates by path, doesn't inline the contract | Hard rule 3, D100 §7.4 |
| F5 | Produces an artifact a reviewer or a downstream subagent can act on (gap-free principle generalised) | Definition of D101 §8 |

"Borderline" = passes F1–F2 but has open design questions on F3–F5. "Reject" = fails F1 or F2 outright.

## 2. Sources surveyed

- *awesome-claude-code* — hesreallyhim's curated index ([github.com/hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)). 44k stars; canonical aggregator. Browsed for breadth.
- *Claude Command Suite* — qdhenry, professional slash command pack ([github.com/qdhenry/Claude-Command-Suite](https://github.com/qdhenry/Claude-Command-Suite)). Organised by lifecycle stage; 100+ commands. The richest single source.
- *claude-code-spec-workflow* — Pimzino, spec-driven Requirements → Design → Tasks → Implementation flow ([github.com/Pimzino/claude-code-spec-workflow](https://github.com/Pimzino/claude-code-spec-workflow)). Direct L3 analogue.
- *spec-based-claude-code* — papaoloba, SDD via custom slash commands ([github.com/papaoloba/spec-based-claude-code](https://github.com/papaoloba/spec-based-claude-code)).
- *GSD (Get Shit Done)* — 23k-star workflow with 29 skills + 12 agents ([codecentric blog](https://www.codecentric.de/en/knowledge-hub/blog/the-anatomy-of-claude-code-workflows-turning-slash-commands-into-an-ai-development-system)).
- *Anthropic first-party plugins* — `code-review`, `commit-commands` ([github.com/anthropics/claude-code](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md)).
- */grill-me skill* — Matt Pocock's three-line interview-first skill ([mcpmarket.com/tools/skills/grill-me](https://mcpmarket.com/tools/skills/grill-me), [Mr. Buzzoni on X](https://x.com/polydao/status/2044533933115629787)).
- *Reverse-engineering family* — wshobson's reverse-engineering plugin, Extract skill, System Archeology skill ([claudepluginhub.com](https://www.claudepluginhub.com/plugins/wshobson-reverse-engineering-plugins-reverse-engineering-2), [mcpmarket.com/tools/skills/reverse-engineer-documenter](https://mcpmarket.com/tools/skills/reverse-engineer-documenter)).
- *Boris Cherny's prompting tips* — Anthropic, the original "grill me on these changes" framing ([threads.com/@boris_cherny](https://www.threads.com/@boris_cherny/post/DUMZxTWElFm/6-level-up-your-promptinga-challenge-claude-say-grill-me-on-these-changes-and-do)).

## 3. Strong candidates

Ranked by how cleanly they fit the criteria, not by guessed value.

### 3.1 `/d101-review`

**Stage.** Design.

**What it does.** Reads a draft D101 and runs the seven (eight if user-facing with UI) gap-free checks from `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md §8` against it, plus the quality rules in §5–§6. Returns a structured finding list (per-section pass / flag / fail with one-sentence reason). Author runs it before requesting human review — same role as `/s101-review` plays for the Spec stage (D100 §4.3).

**Why it fits.** Closes an obvious symmetry gap: Spec has `/s101-review` but Design has nothing equivalent on the toolkit side. The process doc (§3.1) currently leans on Copilot's `.github/instructions/d101.instructions.md` for the first pass — but Copilot can't read the definition by path the way a toolkit command can, and the definition is the authoritative bar. A toolkit command keeps the doc-in-the-repo as runtime source of truth (hard rule 3).

**Inputs.** Path to a D101, or no arg → finds the most recently-modified `documentation/features/D101-*.md`.

**Model.** Sonnet 4.6 (matches `/s101-review`'s tier per `documentation/model-choice.md`).

**Prior art.** `/code-review` plugin (Anthropic first-party) — same "read artifact, emit structured findings" shape. `/spec-list` / `/spec-status` (Pimzino) for the operational tone.

**Open question before D101.** Is the structured finding format identical to what Copilot will produce via `d101.instructions.md`, or deliberately complementary? Process doc §3.1 says Copilot reviews first; toolkit command should probably ride after, focused on the bits Copilot is weakest at (counter-examples for conditional rules, named deciders on TBDs).

### 3.2 `/d101-reverse`

**Stage.** Design (reverse-engineered variant).

**What it does.** Reads an existing feature implementation (entry-point file or directory) and drafts a D101 that documents *what is there*, populating §9 *Changes from source* with the as-built / as-designed delta. Then drops into the same interview mode as `/d101-feature-design` for any gaps it can't infer.

**Why it fits.** The D101 template already has §9 reserved for reverse-engineered D101s — the slot exists, but no command produces them. The reverse-engineering pattern is well-trodden in the ecosystem (wshobson's plugin, the Extract skill, System Archeology skill). Fits the gap-free bar because the §8 check is unchanged — only the input differs.

**Inputs.** A file path, directory, or feature name + a hint at where the implementation lives.

**Model.** Opus 4.8 xhigh (same as `/d101-feature-design` — drafting is the load-bearing work; reading code is preparation).

**Caveat.** Tempting to inline a code-reading heuristic; resist. The command should reuse `d101-feature-design-definition.md` and `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-template.html` by reference, exactly as `/d101-feature-design` does (hard rule 3).

**Open question before D101.** Two variants or one? "Document existing code as-is" vs "document existing code + propose changes". Probably one command with a flag; surfacing the distinction in §9 is the discipline that matters.

### 3.3 `/trace`

**Stage.** Ad-hoc — primarily Review + Test, but useful at Spec authoring too.

**What it does.** Given a feature slug, reads `D101-<slug>.md` §6 and `S101-<slug>.md` acceptance criteria, walks the code/tests, and produces a coverage matrix: each D101 criterion → which S101 criterion verifies it → which test(s) exercise it. Flags orphans on both sides (D101 criterion not in S101; S101 criterion not in tests; test not traceable to any criterion).

**Why it fits.** Two concrete pain points show up in the process doc: §3.3 says the human reviewer reads the validator comment "before opening the diff", and core rule 4 says "a gap found in a later phase is a bug in an earlier phase." `/trace` is the diagnostic that locates which phase the gap is in. The S101 validator subagent already does per-criterion coverage for one direction (S101 → code); `/trace` extends it back to D101.

**Inputs.** Feature slug.

**Model.** Sonnet 4.6.

**Open question before D101.** Does the validator subagent eventually subsume this? If yes, `/trace` is a Q3-bridge tool; if no, it's a permanent ad-hoc utility. Worth deciding before committing.

### 3.4 `/manifest-lint`

**Stage.** Toolkit-internal (meta — like `/conventions-check`).

**What it does.** Validates `marketplace.json` and each `plugin.json` against the Claude Code marketplace schema. Cross-checks the three-way name match required by hard rule 1 (manifest name = directory name = marketplace entry).

**Why it fits.** D100 §10 Q2 names this as an open question: "Manifest typos break install silently. Should the marketplace lint its manifests before merging changes to the default branch?" The answer is yes; a slash command is the lowest-friction venue (compared to a CI check).

**Inputs.** None — operates on the toolkit repo it's invoked from.

**Model.** Haiku 4.5 (mechanical, schema-driven).

**Open question before D101.** Slash command or pre-commit hook? Both are cheap; the command form is more discoverable and ad-hoc-friendly.

## 4. Borderline candidates

These pass F1–F2 but have an unresolved tension on F3–F5. Listed so we can decide *no*, not because they're tentatively *yes*.

### 4.1 `/model-choice-sync`

**Stage.** Toolkit-internal.

**What it does.** Reads every `commands/*.md` and `agents/*.md`, extracts the `model:` frontmatter field, and diffs against the rows in `documentation/model-choice.md`. Reports drift.

**Why it might fit.** D100 §10 Q1: "Are command-frontmatter model declarations and `documentation/model-choice.md` kept in sync by review discipline, or by a small CI lint?" Same shape as `/manifest-lint`, same rationale.

**Tension.** This belongs in CI, not a dev's terminal. The dev is already in a slash-command context that has a model; they don't need to lint. If we're adding both `/manifest-lint` and `/model-choice-sync`, that's a sign we should write a single `/toolkit-doctor` instead. Worth holding until both feel necessary; then merge.

### 4.2 `/feature-status`

**Stage.** Operational.

**What it does.** For a feature slug, shows the L3 progression: D101 exists? approved? S101 exists? approved? code PR open? validator report posted? Approve recorded? One screen, no clicking.

**Why it might fit.** Pimzino's `/spec-status` and `/spec-list` are popular in spec-driven workflows for exactly this reason. The L3 pipeline has more gates than most spec workflows, so the value is higher.

**Tension.** The data lives in GitHub (PR state) and in the file system (artifacts). The command would need `gh` calls and would couple the toolkit to GitHub specifically. Charter §1.2 reusability suggests we keep GitHub coupling out of the plugin's prompts. Possibly belongs in product-repo tooling rather than the toolkit.

### 4.3 `/challenge`

**Stage.** Pre-Design (before a feature brief is even written).

**What it does.** Boris Cherny / Matt Pocock-style adversarial interview about whether a feature *should* exist, before /d101-feature-design is invoked. Stress-tests the motivation, not the design.

**Why it might fit.** The interview built into `/d101-feature-design` assumes the developer already wants to ship the feature — it grills on completeness, not on the premise. There's a distinct gap between "is this worth doing?" (intent) and "is this fully specified?" (design). `/challenge` would live in the Intent layer, which the toolkit currently treats as external (§3 system context).

**Tension.** Charter §1.1 says Intent is captured upstream and the toolkit covers "Design through Test". Adding `/challenge` is a scope move — defensible, but a scope move. If we want it, it should land alongside a charter amendment, not sneak in as a sibling command.

## 5. Notable rejects from popular lists

Listed because someone will eventually ask "why isn't /commit in here?". Calling them out keeps that conversation cheap.

| Candidate | Source | Why reject |
|---|---|---|
| `/commit` | Anthropic first-party `commit-commands` plugin | Outside L3 scope (Deploy/CI territory), and product repos already have git tooling. Reusability win is zero. |
| `/code-review` | Anthropic first-party `code-review` plugin | Duplicates the planned S101 validator subagent (D100 §4.4). |
| `/onboarding-guide` | Claude Command Suite (`/docs:create-onboarding-guide`) | Outside L3 scope. Already a built-in Claude Code skill. |
| `/security-audit` | Claude Command Suite (`/security:security-audit`) | Outside L3 scope. There's already a built-in `/security-review` skill in Claude Code. |
| `/refactor-code` | Claude Command Suite (`/dev:refactor-code`) | Refactor work doesn't fit the D101→S101→Code path cleanly — it has no "what / why" Design phase in the L3 sense. Different track, deserves a separate decision. |
| `/bug-create` / `/bug-analyze` / `/bug-fix` / `/bug-verify` | Pimzino's bug-fix workflow | Plausible-looking parallel pipeline; rejected for now because it would fork the process before we have evidence the L3 pipeline is too heavy for bugfixes. Revisit if bugfix friction shows up in retro. |
| `/handoff` | Claude Command Suite (`/session:handoff`) | Session-state tooling, not L3 artifact tooling. Belongs in personal dotfiles or a separate plugin. |
| `/standup-report` | Claude Command Suite (`/team:standup-report`) | Team-ops, not L3. |
| `/architecture-documentation` | Claude Command Suite (`/docs:create-architecture-documentation`) | The toolkit's D100 *is* architecture documentation, but it's a one-off per repo and the existing template + the D100 archetype already cover this. A generator that doesn't reference a template would drift; one that does duplicates the human-authored process. |

## 6. On `/grillme` specifically

The original `/grill-me` is a three-line skill ([mcpmarket.com/tools/skills/grill-me](https://mcpmarket.com/tools/skills/grill-me)) that forces Claude to interview the developer with 40+ questions before writing code. The popular framing ([Boris Cherny's tip](https://www.threads.com/@boris_cherny/post/DUMZxTWElFm/6-level-up-your-promptinga-challenge-claude-say-grill-me-on-these-changes-and-do)) is broader: "say grill me on these changes and don't make a PR until I pass your test."

**The interview half is already built in.** `/d101-feature-design` Step 2 explicitly is interview mode — drives the conversation, refuses to draft until the gap-free check passes, captures `TBD — verify` for unknowns rather than guessing (`plugins/asimov-plugin/commands/d101-feature-design.md`, Step 2 and Hard Rules). Adding a parallel `/grillme` would either duplicate that or weaken the existing command's interview discipline.

**The "challenge" half is a different shape.** Boris Cherny's framing — *"prove to me this works"*, *"grill me on these changes"* — is post-implementation review against intent. That's the validator subagent's job in our pipeline, plus the human review gate. Not a slash command we need.

**The pre-Design challenge variant** — grill me on whether the feature should exist — is the only flavour of `/grillme` that doesn't overlap. Captured as `/challenge` in §4.3 above. Rejected for now on scope grounds (Intent is upstream of the toolkit per charter §1.1).

**Recommendation.** Don't ship `/grillme`. The interview discipline it represents is already inside `/d101-feature-design` and `/s101-implementation-spec`. If we ever feel the interview is too easy on the developer, the fix is to tighten the prompt and the definition — not to add a second command with overlapping behaviour.

## 7. Recommended next steps

1. **Pick zero or one strong candidate to scope for Q3** alongside the already-planned `/s101-*` commands and subagents. The four strong candidates in §3 are listed in (subjective) order of value-to-cost; `/d101-review` is the cleanest pick because it closes a documented symmetry gap with `/s101-review`.
2. **Punt the other strong candidates to Q4** — they're useful but not load-bearing for the Q3 L3 release. Note them in D100 §9 (deferred) if a decision is made.
3. **Decide §4.1 + §4.2** as charter / scope questions before they're written. `/feature-status` in particular needs a scope ruling on GitHub coupling.
4. **For `/grillme` and the rest of §5**: park the list in this file. The next time someone proposes one, the conversation starts from "have you read §5/§6 of `additional-command-ideas.md`?" rather than from scratch.
