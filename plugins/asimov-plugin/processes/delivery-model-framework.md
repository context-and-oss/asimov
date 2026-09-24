---
type: overview
name: "Delivery Model"
purpose: "The design for the Delivery Model: the phase frame, the design principles, and the map of everything that hangs off them."
---

# Delivery Model

## The one idea

**The four phases are fixed. The content of each phase is a catalogue of approaches you combine per project.**

```
Proposal  →  Scoping  →  Development  →  Operations
   ↑                                          |
   └──────────────  next engagement  ─────────┘
```

The earlier models — the project model on time-and-materials or fixed price, subscription, and business continuity — were *bundles*: choosing one fixed your scoping method, your cadence, your estimation unit and your operating arrangement in a single decision.

We keep the phases and dissolve the bundles. What used to be time-and-materials, fixed price and subscription now decomposes into approaches that can be mixed. A project can scope with Discovery, build with Kanban and hand over to the customer's own operations — a combination none of the old models allowed.

This carries a cost, and the model must address it directly: some combinations are risky (see [the selection guide](selection-guide.md)). Bundles hid those risks by forbidding the combinations. A catalogue must name them instead.

## Design principles

**1. Agentic is an execution mode, not a process.** The phases, the blocks and the artefacts stay the same whether the work is done by hand or by agents. What varies is *how* the work is produced: written in a document by a person, or generated wholly or partly by AI and then edited and approved by a person. Spec-driven development is not new — we always described before we built. What is new is that AI generates the spec and builds code from it.

Consequence: there is **no separate agentic delivery model**. Every approach is described once, with a short *how it is executed* note in two columns — traditional and agentic. Maturity becomes a dimension, not a parallel model.

**2. The document chain is defined by its content, not its format.** Each document in the chain (A100, P100, P200, D100, D101, E100, E200, BC100) is described as a set of questions that must be answered. The format is a carrier you choose:

| Carrier | Status |
|---|---|
| Office documents in SharePoint | Valid. Existing projects continue on it and can still follow this guide. |
| Readable, version-controlled files in git | **Default for new projects.** |

Agentic execution requires the git carrier — an agent cannot build from a document sitting in SharePoint. That is the reason for the default, not a tooling preference.

**3. Level and zone are set once.** The autonomy level (L1–L3) and the zone (Z1–Z3) are agreed in Proposal or Scoping and then hold unchanged through Scoping, Development and Operations. One decision per customer or project, not one per phase. Being in Operations does not imply that agents touch production; if a project wants agents to access production data or logs, that is a separate Zone 3 conversation, independent of phase.

**4. Every approach is described once.** Approaches used in more than one phase (prototyping, Kanban, launch elements) get one page and are referenced from the phases that use them. Duplicated descriptions diverge.

**5. Approaches decide *when*; disciplines decide *how well*.** Underneath the approaches sits a catalogue of **disciplines** — the practices that must be handled on any engagement regardless of which approach is chosen: estimation, risk, change handling, expectation matching, testing, handover. A discipline is both something you must have under control and something you can get better at. The approach decides how often a discipline is exercised, not whether.

Some are anchored to a phase; others — workshop facilitation, expectation matching, risk, status reporting — are **cross disciplines**, exercised in all four. Those are described once and linked from the phases that use them, rather than repeated four times.

## The four phases

| Phase | Purpose |
|---|---|
| [Phase 1. Proposal](phases/proposal.md) | Sell a Scoping: the mandate to investigate the problem properly |
| [Phase 2. Scoping](phases/scoping.md) | Turn needs into a basis for decision |
| [Phase 3. Development](phases/development.md) | Build, implement and put into operation |
| [Phase 4. Operations](phases/operations.md) | Keep it running, and close the loop to the next engagement |

## What hangs off the frame

| | |
|---|---|
| [The selection guide](selection-guide.md) | Which approach to choose per phase, and the combinations that carry risk |
| [The discipline catalogue](disciplines.md) | The 28 practices that must be under control whichever approach is chosen |
| [Cross-cutting layers](cross-cutting-layers.md) | The document chain, roles, cadence, level and zone, the Business Value Ladder |
| Responsibility checklist *(internal, not in this bundle)* | Six areas, default owners, and a per-engagement review |

These four sit beside this page rather than under it, and none of them is an index of the folder next to it. The phases are listed in the table above, the approaches in the selection guide, and the disciplines in the catalogue; the folders hold the pages, not the way in.
