# Model choice

Canonical mapping from L3 pipeline stage → toolkit component (command or subagent) → model. This file is the human-readable index of model declarations; each command's and subagent's YAML frontmatter is the runtime source of truth (see [`D100-Asimov-architecture.md §7.3`](D100-Asimov-architecture.md#73-frontmatter-declared-models)).

> **Sync rule.** Every change to a command's or subagent's model frontmatter MUST be paired with an update to this file in the same commit. Two indices that don't agree silently break developer expectations.

---

## 1. Mapping

| Pipeline stage | Component | Model | Effort |
|---|---|---|---|
| Design | `/d101-feature-design` | `claude-opus-4-8` | `xhigh` |
| Design | `/d101-review` | `claude-sonnet-4-6` | *(default)* |
| Design | `/d101-convert-to-html` | `claude-sonnet-4-6` | *(default)* |
| Setup | `/asimov-init` | `claude-opus-4-8` | *(default)* |
| Design | `/persona-new` | `claude-opus-4-8` | *(default)* |
| Design | `/persona-list` | `claude-sonnet-4-6` | *(default)* |
| Code | `giskard-the-dotnet-developer` subagent | `claude-sonnet-4-6` | *(default)* |
| Code | `daneel-the-angular-developer` subagent | `claude-sonnet-4-6` | *(default)* |
| Code | `calvin-the-test-author` subagent | `claude-sonnet-4-6` | *(default)* |
| Review | `baley-the-code-reviewer` subagent | `claude-sonnet-4-6` | *(default)* |
| Spec | `/s101-implementation-spec` *(planned)* | `claude-opus-4-8` | `xhigh` |
| Spec | `/s101-review` *(planned)* | `claude-sonnet-4-6` | *(default)* |
| Test | S101 validator subagent *(planned)* | `claude-sonnet-4-6` | *(default)* |
| Review + Test | `/conventions-check` *(planned)* | `claude-sonnet-4-6` *or* `claude-haiku-4-5` | *(default)* |

`Model` is the literal value of the `model:` field in YAML frontmatter. `Effort` is the literal value of the `effort:` field — the Claude Code adaptive-reasoning control; `xhigh` was introduced on Opus 4.7 and is also supported on Opus 4.8 (it sits between `high` and `max`). *(default)* means the field is omitted from frontmatter.

## 2. Selection criteria

Why each model lands where it does:

- **Opus 4.8 xhigh — used for Design and Spec drafting.** These are open-ended generative tasks with many edges: a thin brief becomes a multi-section design, or a gap-free design becomes a full implementation spec. Reasoning depth and judgment dominate; throughput and cost are secondary because runs are infrequent and the cost of a weak design or spec is high (rework rippling through Code and Review). Opus 4.8 is the most capable model and shares 4.7's request surface (adaptive thinking only; `xhigh` retained), so this is a model-version bump with no behavioural contract change.

- **Opus 4.8 (default effort) — used for repo bootstrap.** `/asimov-init` authors orienting `asimov.md` prose, judges stack detection from ambiguous markers, and merges safely into existing files — broader judgment than mechanical scaffolding, though it doesn't need `xhigh`. Runs are once-per-repo, so cost is secondary.

- **Sonnet 4.6 — used for review, code generation, and validation.** These tasks have a tighter, more contractual shape: check an artifact against a definition, implement from a spec, verify acceptance criteria. The contract bounds the work; Sonnet's reasoning is sufficient. Throughput matters more here — the build subagents (Giskard, Daneel, Calvin), the reviewer (Baley), and the validator run on every code PR.

- **Haiku 4.5 — acceptable as a fallback for `/conventions-check`.** Convention checks are mechanical pattern-matching at their core. When latency or cost is a concern (e.g. running on every commit), Haiku can carry them. Sonnet remains the safer default; Haiku is a tunable choice per invocation.

## 3. Conventions for model declaration

Each command and subagent file declares its model (and optionally effort) in YAML frontmatter:

```yaml
---
description: ...
model: claude-opus-4-8
effort: xhigh
---
```

Field semantics (per Claude Code docs):

- `model` — the literal model identifier (`claude-opus-4-8`, `claude-sonnet-4-6`, `claude-haiku-4-5`).
- `effort` — the adaptive-reasoning effort level. Accepted values: `low`, `medium`, `high`, `xhigh` (Opus 4.7+ — i.e. 4.7 and 4.8), `max` (Opus-tier only). Omit the field for default behaviour.

## 4. Upgrade ritual (deferred decision)

How the toolkit rolls a model forward — e.g. when a current model is retired — remains an open architecture question tracked in [`D100 §10 Q4`](D100-Asimov-architecture.md#10-open-architecture-questions).

The first roll-forward (Opus 4.7 → Opus 4.8 for `/d101-feature-design` and the planned `/s101-*`) was done as a **single PR** updating **this file**, **D100**, the affected **D101**, and **every relevant command/subagent frontmatter** together — establishing the working precedent until the ritual is formally decided. Treat future bumps the same way; partial updates create drift that the sync rule (§above) is designed to prevent.
