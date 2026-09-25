---
type: discipline
name: "Specification"
kind: phase
anchored-to: Development
also-used-in: Scoping
purpose: "Writing down what must be built, how, and how we will know it works, well enough that someone else can build it."
---

# Specification

*Spans **Scoping** and **Development**: the solution description is written in one, the feature designs in the other.*

## Purpose

Turn understanding into something buildable. A specification answers three questions — what it must do, how it should be built, and how we will know it works — plus a fourth that is easy to forget: what it must *not* do.

This is the discipline agentic delivery has changed most, and changed in a direction that makes it more important rather than less.

## Why it matters

A specification is where ambiguity goes to be resolved. Every question it fails to answer gets answered later by whoever is building — quickly, privately, and sometimes wrongly. That was true when a person was building. It is more true when an agent is, because an agent will not stop to ask.

It is also a contractual artefact. The solution and project descriptions are annexes to the project agreement, which means what the specification says is what we owe. Writing it loosely to keep options open keeps options open for the customer too.

And it is the memory of the engagement. People leave, six months pass, and what the specification says is what anyone can still find out.

## How it is done

**Cover the four types.** Functional — what it should do: user stories, acceptance criteria, input and output examples, edge cases. Technical — how it should be built: architecture decisions and their reasoning, contracts, data models, integration points, performance constraints. Quality — how we know it works: test scenarios, machine-verifiable acceptance criteria, benchmarks, security requirements. Constraints — what it must not do: guardrails, backward-compatibility rules, conventions, files and interfaces that are off limits.

**Follow the chain.** The solution description is written in Scoping and gives the whole picture. Each feature gets its own design in Development. The solution overview is opened early, maintained through the work, and closed at handover.

**Get approval between design and build**, not after. The customer approves the feature design; then it is built. That ordering is the point of the chain, and reversing it turns approval into acceptance of a fait accompli.

**Write acceptance criteria that can actually be checked.** "Works as expected" is not a criterion. If a machine could not decide whether it passed, neither can a person under time pressure.

**Keep it current or close it.** A specification that no longer describes the system is worse than none, because people trust it.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can write a feature design covering function, technical approach and acceptance criteria, from a decided scope |
| **Show it** | You can write a specification precise enough to be built from without follow-up questions, including the edge cases and the constraints. You get it approved before building |
| **Build it** | You can specify a whole solution: architecture with reasoning recorded, interfaces, quality requirements — and keep the chain coherent as the solution changes |
| **Own it** | You can set what a good specification looks like here, and judge when a spec is complete enough to build from and when it is not. You can tell when precision is being used to avoid a decision |

## How to get better

**Internally**

- The **AI Transition** material on the specification layer and its four types — the sharpest statement we have of what a specification must contain.
- The **teaching deck**'s sprint-by-sprint document flow, which shows the chain in motion including where approval sits.
- The **Engineer track**'s spec templates and the schema they validate against. Specification and the pipeline are the same subject.

**Externally**

- Gojko Adzic, *Specification by Example* — on acceptance criteria that are also tests, which is the practical form of the quality spec.
- Karl Wiegers, *Software Requirements* — thorough, traditional, and still the best reference for what a requirement needs to contain.
- Michael Nygard's writing on **architecture decision records** — a light format for capturing why a technical decision was made, which is the part of a technical spec that ages best.

## Common failure

**Only the functional half.** What it should do, with nothing about how it should be built or how we would know it works.

**No constraints.** The fourth type is the one nobody writes, and it is the one that prevents an agent — or a new developer — from doing something reasonable and wrong.

**Approval after the build.** The customer is shown what exists and asked to agree to it.

**Specification as ritual.** Written because the process says so, then ignored during the build. Whatever was actually built becomes the specification retroactively.

**Precision hiding a missing decision.** Ten pages of detail around the one question nobody wanted to settle.

## Artefacts

The solution description from Scoping · the feature designs · the solution overview, opened early and closed at handover · the IT environment and deployment procedure documents. In the git carrier these are version-controlled beside the code; in the document carrier they live where the project's documents live.

## How it varies by approach

Analysis produces the most complete specification up front. Scrum specifies per feature, just ahead of the build. Use-case delivery specifies per use case. Kanban specifies per item, and lightly. Prototyping inverts it: the prototype *is* the specification, and the written version follows.

**Traditional vs agentic.** The largest shift in the whole model. Traditionally a person read the design and used judgement to fill the gaps. Agentically the specification is what the agent builds from, so gaps become defects, and the spec becomes a first-class versioned artefact rather than a document. The paradox is real and worth stating plainly: **to have agents do more of the work, humans do more of the thinking, earlier.** Total effort does not fall — it moves from typing code to describing what the code must be.
