# AI Transition — Levels & Zones

Asimov's vocabulary — L2, L3, "L3 on Zone 2", the nine pipeline stages, the planner / builder / tester / reviewer roles — comes from Context&'s *AI Transition — Levels & Zones* framework (April 2026). This page carries the part of it Asimov leans on, so the rest of this repo reads on its own. It is a summary, not the framework; Context& maintains the original.

## Levels — where a developer operates

Six levels of AI autonomy, adapted from the SAE levels for autonomous driving. Each level changes not just who does the work but what the work is.

| Level | Name | Who writes the code | Human role | Typical risk |
|---|---|---|---|---|
| L0 | No AI | The human | Maker | Knowledge lives in people's heads |
| L1 | Autocomplete | The human; AI finishes the line | Maker, faster | Accepting wrong suggestions unread |
| L2 | Copilot | The human, with AI generating functions, tests and explanations on request | Maker who reviews AI | More code than humans can review |
| L3 | Agent, human in the loop | The agent, from a written spec | Director and reviewer | Rubber-stamping |
| L4 | Autonomous | The agent, which also drafts the spec; the human reviews outcomes | Specifier and auditor | Silent failures, strategic drift |
| L5 | Fully autonomous | An agent fleet, end to end | Strategist | Nobody understands the system |

Most teams work at L2 today. L3 is the sensible default for production work with agents.

## The shift at L3 — a spec layer appears

At L0–L2 documentation *describes* a system after it is built, and drifts. At L3 a human writes the spec and the agent writes the code, so what used to be implicit knowledge must become an explicit written artifact — an agent cannot read minds. The spec is the product; code is the output. The total thinking does not shrink; it moves from *how to build* to *how to describe*.

The L3 pipeline has nine stages:

> Intent → Design → Spec → Code → Review vs. spec → Test vs. spec → Approve → Deploy → Observe

Asimov covers the five AI-assisted stages in the middle: **Design** (the D101 commands), **Spec** (S101 implementation plan + S102 task specs; definitions written, commands planned), **Code** (the build subagents), **Review** (Baley), **Test** (the validator, planned). Intent is captured upstream, Approve is the human gate, and Deploy and Observe live in existing CI/CD and monitoring. See [D100 §3](D100-Asimov-architecture.md).

## Agent roles

From L3 upward, multi-agent work splits into four roles: **planner** (architecture and spec), **builder** (writes the code), **tester** (writes the tests), **reviewer** (checks the changeset). Asimov's subagents are named by role: Giskard and Daneel build, Calvin tests, Baley reviews; planner is reserved (D100 §4.4).

## Zones — how deeply AI is integrated in an engagement

| Zone | Name | What AI touches | Risk |
|---|---|---|---|
| Z1 | Embedded | AI built into everyday tools — IDE completions, PR summaries, document assistants. The default, not a choice | Low |
| Z2 | Intentional | Someone deliberately engages AI to produce work — design, spec, code, review, tests. Code and project context reach the provider | Medium |
| Z3 | Data & environment | AI touches real data — databases, environments, production logs, personal data | High |

Levels and zones compose. "L3 on Zone 2" means a developer working at agent level with human oversight, on an engagement where AI is used intentionally on code and project context but never on real data. That is the setting Asimov is built for; most of the L3 value is available there.

## Related

- [D100 — Asimov architecture](D100-Asimov-architecture.md) — where the toolkit sits in the L3 pipeline (§3) and the subagent roles (§4.4)

Source: Context&, *The AI Transition — Levels & Zones*, April 2026.
