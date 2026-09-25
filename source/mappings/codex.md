# Mapping table — Codex

The one place concrete Codex model names live (D101-agnostic-toolkit-codex-support §6.4.4, rule 4).
The generator resolves each source file's `tier` + `effort` through this table when emitting the
Codex target: subagent TOMLs get `model` + `model_reasoning_effort` from here; Codex SKILL.md files
get **no** model fields at all (Codex silently ignores them — D101 §6.8), only the informational
mismatch preamble.

> **Upgrade ritual.** A new model generation is **one row changed here, a regeneration, and a test
> of the affected commands in both tools** — never an automatic alias bump. Roll the change as a
> single PR so the generated trees and this table move together (issue #20).

> **Verified 2026-09-21** (issue #20) against the Context& Foundry instance Codex is configured for
> (`model_provider = "azure"`, catalog `~/.codex/models.azure.json`). The catalog exposes the three
> GPT-5.6 capability tiers as deployments — `gpt-5.6-sol` (flagship, highest reasoning ceiling),
> `gpt-5.6-terra` (balanced default), `gpt-5.6-luna` (cost-efficient) — and each answered a
> `codex exec` probe: sol at `xhigh` and `max`, terra and luna at `low` and `max`
> (developers.openai.com/api/docs/models for the tiering). `gpt-6-astra` is also deployed and ranks
> with sol. The provider's reasoning-effort vocabulary is `none, minimal, low, medium, high, xhigh,
> max`: `ultra` — the v1.0 seed value — is rejected, and `minimal` is refused whenever Codex's
> `web_search` tool is enabled, so neither is mapped.

> **Catalog update 2026-09-22.** The Context& Foundry catalog Codex loads (`models.azure.json`) now names the
> deployments `gpt-5.6-sol-eu`, `gpt-5.6-terra-eu`, `gpt-5.6-luna-eu` and lists their reasoning levels as
> `low, medium, high, xhigh, max`. Two things the first live run taught: Codex validates a subagent TOML's
> `model` and `model_reasoning_effort` against that catalog at spawn time (a catalog entry with an empty
> `supported_reasoning_levels` blocks every Asimov agent with "Reasoning effort … is not supported"), and
> the model names here must match the catalog's slugs exactly — a renamed deployment is one row per tier
> here, a regeneration, and a re-run of `/asimov-init` in each product repo to re-deliver the TOMLs.
> The pre-rename slugs stay as rank rows so a session still on them is ranked, not merely noted.

## Why the tiers land where they do

The same reasoning as the Claude Code table: the interview-driven commands get the flagship (issue
#20's recorded experience), contract-bounded work the balanced tier, mechanical work the cheap one.
The three GPT-5.6 tiers were made for exactly this split.

## Tiers

| Tier | Model |
|---|---|
| small | gpt-5.6-luna-eu |
| medium | gpt-5.6-terra-eu |
| large | gpt-5.6-sol-eu |

## Effort

Codex's vocabulary matches the source vocabulary one-to-one on this provider; the translation stays
explicit here, never a pass-through (D101 §6.8), so a future divergence is one row.

| Source effort | Codex value |
|---|---|
| low | low |
| medium | medium |
| high | high |
| xhigh | xhigh |
| max | max |

## Ranks

Places known models in or between tiers, for the downward-only mismatch alert. A model absent from
this table produces a neutral note, never an alert. Rank 1 = small, 2 = medium, 3 = large.

| Model | Rank |
|---|---|
| gpt-5.6-luna-eu | 1 |
| gpt-5.6-luna | 1 |
| gpt-5.6-terra-eu | 2 |
| gpt-5.6-terra | 2 |
| gpt-5.6-sol-eu | 3 |
| gpt-5.6-sol | 3 |
| gpt-6-astra | 3 |
