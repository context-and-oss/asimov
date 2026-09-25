# Mapping table — Claude Code

The one place concrete Claude model names live (D101-agnostic-toolkit-codex-support §6.4.4, rule 4).
The generator resolves each source file's `tier` + `effort` through this table when emitting the
Claude Code target; the mismatch preamble reads the rank rows through the same parser.

> **Upgrade ritual.** A new model generation is **one row changed here, a regeneration, and a test
> of the affected commands in both tools** — never an automatic alias bump. Roll the change as a
> single PR so the generated trees and this table move together (issue #20).

> **Verified 2026-09-21** (issue #20). Every model id below was accepted by Claude Code 2.1.278 in
> a one-shot run (`claude -p --model <id>`): `claude-fable-5-1`, `claude-opus-5`, `claude-opus-4-8`,
> `claude-sonnet-5`, `claude-sonnet-4-6`, `claude-haiku-4-5`. Skill and subagent frontmatter take a
> full id or an alias (`fable`, `opus`, `sonnet`, `haiku`, `inherit`); `effort` takes
> `low | medium | high | xhigh | max`, where `xhigh` is unavailable on Opus 4.6 / Sonnet 4.6 and
> Haiku 4.5 has no effort control at all (code.claude.com/docs/en/model-config, /skills, /sub-agents).
> Route probed: the Anthropic API. The same ids exist in the Context& Foundry catalog, but Claude Code
> on the Foundry route was not probed — its aliases resolve to older models there, so a full id is the
> safer form for a colleague on that route.

## Why the tiers land where they do

- **large** — open-ended generative work with many edges (design and spec drafting, repo bootstrap,
  persona authoring). Reasoning depth dominates; runs are infrequent and the cost of a weak result
  is high. Experience recorded in issue #20: the interview-driven commands need the top tier —
  smaller models go in circles and pad the output — so `large` is the most capable generally
  available model, not the Opus tier below it.
- **medium** — contract-bounded work (review against a definition, implementing from a spec,
  authoring tests). The contract bounds the work; throughput matters because these run on every PR.
  Sonnet 5 rather than Sonnet 4.6: newer, cheaper per token, and it supports `xhigh`.
- **small** — mechanical pattern-matching (listing the persona roster; the planned convention
  checks). A tunable choice where latency or cost dominates. Haiku 4.5 ignores `effort`, so a
  small-tier source should declare `effort: medium` (emitted as *omit*) until the table can express
  per-tier effort support.

## Tiers

| Tier | Model |
|---|---|
| small | claude-haiku-4-5 |
| medium | claude-sonnet-5 |
| large | claude-fable-5-1 |

## Effort

`(omit)` means the field is left out of the emitted file — the tool's default behaviour (Claude Code
inherits the session's effort level).

| Source effort | Claude Code value |
|---|---|
| low | low |
| medium | (omit) |
| high | high |
| xhigh | xhigh |
| max | max |

## Ranks

Places known models in or between tiers, for the downward-only mismatch alert. A model absent from
this table produces a neutral note, never an alert. Rank 1 = small, 2 = medium, 3 = large.

| Model | Rank |
|---|---|
| claude-haiku-4-5 | 1 |
| claude-sonnet-4-5 | 2 |
| claude-sonnet-4-6 | 2 |
| claude-sonnet-5 | 2 |
| claude-opus-4-6 | 3 |
| claude-opus-4-7 | 3 |
| claude-opus-4-8 | 3 |
| claude-opus-5 | 3 |
| claude-fable-5 | 3 |
| claude-fable-5-1 | 3 |
