# Model choice

Canonical mapping from L3 pipeline stage → toolkit component (command or subagent) → model, and the model recommended for each entry point. This file is the human-readable index of model declarations; each component's YAML frontmatter is the runtime source of truth (see [`D100-Asimov-architecture.md §7.3`](D100-Asimov-architecture.md#73-frontmatter-declared-models)).

> **Sync rule.** Every change to a command's or subagent's model frontmatter MUST be paired with an update to this file in the same commit. Two indices that don't agree silently break developer expectations. A skill declares no model (§1.3).

---

## 1. Mapping

| Pipeline stage | Component | Model | Effort |
|---|---|---|---|
| Code | `giskard-the-dotnet-developer` subagent | `claude-sonnet-5-5` | *(default)* |
| Code | `daneel-the-angular-developer` subagent | `claude-sonnet-5-5` | *(default)* |
| Code | `calvin-the-test-author` subagent | `claude-sonnet-5-5` | *(default)* |
| Review | `baley-the-code-reviewer` subagent | `claude-sonnet-5-5` | *(default)* |
| Test | `powell-the-verifier` subagent | `claude-sonnet-5-5` | *(default)* |
| Review + Test | `/conventions-check` *(planned)* | `claude-sonnet-5-5` *or* `claude-haiku-4-5` | *(default)* |

`Model` is the literal value of the `model:` field in YAML frontmatter. `Effort` is the literal value of the `effort:` field — the Claude Code adaptive-reasoning control; `xhigh` was introduced on Opus 4.7 and is supported on every later Opus and Sonnet, Opus 5.5 and Sonnet 5.5 included (it sits between `high` and `max`). *(default)* means the field is omitted from frontmatter.

No skill has a row: every skill, the `asimov-*` entry points included, declares no model and runs on the session's (§1.3). In Codex and OpenCode the shells' `model` does not bind either; there every agent runs the session's model.

### 1.1 Task tiers in an S101

An S101 recommends a **tier** per task, not a model (`s101-implementation-plan-definition.md` §5, the template's `tier` field). The tiers map to models here, so the plan stays valid across a model bump and check 10 of the S101 definition has something to check against:

| Tier | When | Model |
|---|---|---|
| `low` | The change is fully determined by the names, the signatures and the check (the Foundation skeleton, a one-line read, a registration); the builder still writes the code | `claude-haiku-4-5` |
| `mid` | Behaviour in prose with a clear check — most builder and tester tasks | `claude-sonnet-5-5` |
| `high` | Judgement or integration — a design choice left to the builder, a cross-stack seam | `claude-opus-5-5` |

The tier is a recommendation; `asimov-build` maps it to the model through the Agent tool's `model` field (`haiku` / `sonnet` / `opus`) in Claude Code, and this table is the one its Step 00 mirrors; Codex runs the session's model.

### 1.2 Subagents an asimov-skill spawns without a shell

`asimov-spec` runs its writer in one subagent of the harness's generic `general-purpose` type, spawned at the first cut with `model: opus` and `effort: high` and continued by message (`SendMessage`) for every later call of the run; a subagent otherwise inherits the session's model. One writer, three scripts:

| Call | Does | Model · effort |
|---|---|---|
| **plan writer** (`general-purpose`): `asimov-plan-authoring.md` (the method file, given by absolute path; since 2026-11-17 the one file writes the whole plan, tree, plan sections and every task section, in one call) | cuts the plan and runs the plan check on it, the one judgement-heavy step of the run; re-cut by message on the author's words or a failed check | `claude-opus-5-5` (`model: opus`), `effort: high` |
| **plan check**: `asimov-plan-validation.md` | a script, `artifacts/dot-asimov/asimov-plan/scripts/validate-plan.ps1`, run inline through Bash before the cut is shown | no model: one tool call |
| **render**: the S101 and S102s from the plan, and the approval | a script, `artifacts/dot-asimov/asimov-plan/scripts/render-plan.ps1`, run inline through Bash at the go | no model: one tool call |
| **ledger** (`asimov-build`): `s101-ledger-operations.md` | a script, `artifacts/dot-asimov/s101-ledger/scripts/ledger.ps1`, one call per operation, run inline through Bash | no model: one tool call |

Added 2026-10-07 and reshaped 2026-10-08. The first shape (writers inheriting Opus at xhigh, two LLM validators on Sonnet) came after a two-task run spent a quarter of its tokens on four shape checks that walked the codebase like a builder. The second came after the same ticket's third run still took thirty minutes and 690k tokens with the checks already scripted: the time was in xhigh thinking across sixty tool calls and in two more validator cold starts, and the developer's table showed the writers on the session's model, not the pinned one, so no `model` had reached the Agent call. Now only the plan is cut on Opus, at high rather than xhigh (the bar is a script and the author reads the cut; xhigh bought nothing the script could measure), the task specs are written on Sonnet, both checks are scripts, and `asimov-spec` itself needs no more than Sonnet since it carries a conversation and reads reports (§1.3). The validation skills name this table as the one the calls mirror; a change here changes `asimov-spec`'s spawn text in the same commit (the shape of hard rule 2). The build subagents' own rows above are their default when no plan names a tier.

### 1.3 Entry points run on the session's model

An asimov-skill declares neither `model` nor `effort` (since 2026-11-19; CI fails a `SKILL.md` that does). The person picks the session's model, and the skill passes a model only where it spawns an agent (§1, §1.1, §1.2). What is recommended:

| Entry point | Recommended | Effort |
|---|---|---|
| `asimov-design` | Opus 5.5 or above | `xhigh` |
| `asimov-init` | Opus 5.5 or above | default |
| `asimov-spec` | Sonnet 5.5 or above | default |
| `asimov-build` | Sonnet 5.5 or above | default |
| `asimov-project` | Sonnet 5.5 or above | default |

Why the pin left, which dated from when the entry points were slash commands: only Claude Code read it, so one skill behaved differently per harness; an entry point is a conversation over many turns and model-invocable since 2026-11-13, so a pin changed the model mid-session on the words of a message, without the person choosing it; it lowered a session on a stronger model to Sonnet for spec and build; and a full model id went stale with every release. The calls where the model decides the result, the plan writer and the builders by tier, carry it on the call.

## 2. Selection criteria

Why each model lands where it does:

- **Opus 5.5 xhigh — recommended for Design drafting and, since 2026-11-13, the D101 review inside `asimov-design`; Opus 5.5 high for the Spec stage's cut.** These are open-ended generative tasks with many edges: a thin brief becomes a multi-section design, or a design becomes a phase tree with its contracts and coverage. Reasoning depth and judgment dominate; throughput and cost are secondary because runs are infrequent and the cost of a weak design is high (rework rippling through Code and Review). Opus 5.5 is the current Opus: the same 1M context and `xhigh` effort as 4.8 at a lower price per token. Its API default effort is `medium`, one level below 4.8's, so `xhigh` is the effort recommended for a design session (§1.3). The cut (§1.2) runs at `high`: its bar is enforced by a script and read by the author at the gate, and at `xhigh` a sixty-call cut spent most of its eleven minutes thinking between tool calls.

- **Opus 5.5 (default effort) — recommended for repo bootstrap.** `asimov-init` authors orienting `asimov.md` prose, judges stack detection from ambiguous markers, and merges safely into existing files — broader judgment than mechanical scaffolding, though it doesn't need `xhigh`. Runs are once-per-repo, so cost is secondary.

- **Sonnet 5.5 — used for code review, code generation and verification, and enough for both orchestrators.** These tasks have a tighter, more contractual shape: implement from a spec, write a task spec from a plan and a template whose bar is a script, run acceptance criteria, dispatch and read reports. The contract bounds the work; Sonnet's reasoning is sufficient, and Sonnet 5.5 is the current Sonnet, cheaper per token than 4.6 with the same 1M context. Throughput matters more here — the build subagents (Giskard, Daneel, Calvin), the reviewer (Baley), the Spec-stage task writers, the verifier (Powell) and the two orchestrators `asimov-spec` and `asimov-build`, which carry a conversation and read reports rather than drafting, run often. Validation at the Spec stage is no model at all: two scripts (§1.2).

- **Fable 5.1 — considered, not pinned.** The most capable model, at about twice Opus 5.5's price per token. Raised for `asimov-spec` in the review of the Spec stage (2026-10-02). It is not pinned until a real planning run shows Opus 5.5 at `high` falling short on the cut, and access to it differs per subscription; a developer's run whose session model was Fable showed the writers inheriting it, which is why every writer call now passes `model` explicitly.

- **Haiku 4.5 — acceptable as a fallback for `/conventions-check`.** Convention checks are mechanical pattern-matching at their core. When latency or cost is a concern (e.g. running on every commit), Haiku can carry them. Sonnet remains the safer default; Haiku is a tunable choice per invocation.

## 3. Conventions for model declaration

Each command and subagent file declares its model (and optionally effort) in YAML frontmatter; a skill declares neither (§1.3):

```yaml
---
description: ...
model: claude-opus-5-5
effort: xhigh
---
```

Field semantics (per Claude Code docs):

- `model` — the literal model identifier (`claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-4-5`).
- `effort` — the adaptive-reasoning effort level. Accepted values: `low`, `medium`, `high`, `xhigh` and `max` (Opus 4.7 and later; Sonnet 5 and later). Omit the field for default behaviour.

## 4. Upgrade ritual (deferred decision)

How the toolkit rolls a model forward — e.g. when a current model is retired — remains an open architecture question tracked in [`D100 §10 Q4`](D100-Asimov-architecture.md#10-open-architecture-questions).

The first roll-forward (Opus 4.7 → Opus 4.8 for the then `/d101-feature-design`, now `asimov-design`, and the then-planned Spec-stage command, now `asimov-spec`) was done as a **single PR** updating **this file**, **D100**, the affected **D101**, and **every relevant command/subagent frontmatter** together — establishing the working precedent until the ritual is formally decided. The second roll-forward (Opus 4.8 → Opus 5.5 and Sonnet 4.6 → Sonnet 5.5 for every pin at once, 2026-10-02, prompted by a review comment on the Spec stage) followed the same shape. Treat future bumps the same way; partial updates create drift that the sync rule (§above) is designed to prevent.
