---
type: approach
name: "Prototyping"
anchored-to: Development
also-used-in: Scoping
purpose: "The Prototyping approach. A loop that answers open questions by building something to look at, rather than by writing about it."
---

# Prototyping

*An approach in the **Development** phase. Also used inside **Scoping**, where the prototype is the basis for a decision rather than a deliverable.*

## 1. Purpose

Answer an open question by making something people can react to. Not to build a product — to remove doubt. The output of a prototyping cycle is a **decision**, and the prototype itself is usually thrown away or rewritten.

This is where agentic execution changes the economics most. A working code prototype used to be too expensive to use as a thinking tool, so we drew wireframes and argued about them. It now costs roughly what a wireframe used to, and it settles arguments a picture cannot.

## 2. When to choose it — and when not

**Choose it when**

- The idea is new and nobody knows whether it is worth building.
- Stakeholders disagree about what should be built, and the disagreement survives every meeting.
- The requirement cannot be written down until someone has seen something.
- The estimate is uncertain enough that de-risking it is cheaper than padding it.

**Do not choose it when**

- The question is *"how long will it take?"* — a prototype answers *what*, not *when*.
- What is needed is production software. A prototype that quietly becomes the product is the classic failure of this approach.
- Nobody on the customer side can react within days. A prototype that waits a fortnight for feedback has lost its only advantage.

## 3. What it locks

**Nothing — deliberately.** That is the point and the danger. Prototyping produces knowledge, not commitment, and it must be visibly separated from what is being promised.

## 4. Activities

**The loop: prototype → review → refine**

1. **Frame the question.** One question per cycle, written down. *"Will dispatchers accept an automatic assignment?"* — not *"build a dispatch screen"*.
2. **Choose a fidelity** from the ladder: wireframe → Figma → agent-built code prototype. Choose by the question, not by ambition. Do not build a code prototype to answer something a sketch settles.
3. **Build it.** Hours to days. If it takes longer, the question was too big.
4. **Review with the people who decide** — not their representatives. Record the reaction, not just the conclusion.
5. **Decide:** refine, change direction, or stop. Stopping is a successful outcome.

*Disciplines:* Workshop facilitation · Expectation matching · Outcome definition · Stakeholder analysis.

**Every cycle, without exception**

- Restate what the prototype is *not*. Each showing, not just the first.
- Record what remains unclarified — the list of open questions is the real deliverable.

## 5. Output and artefacts

| Artefact | Note |
|---|---|
| The prototype | Not a deliverable. Say so in writing |
| Decision record | What was asked, what was seen, what was decided |
| Open-questions list | What the prototype did *not* settle |
| Input to **A100** / **D101** | The prototype becomes the seed of the specification — the strongest reason to do it before writing one |

## 6. Who does what

| Responsibility | Default owner |
|---|---|
| Framing the question | FDE |
| Choosing the fidelity | FDE with ASWE |
| Building the prototype | ASWE |
| Running the review | FDE |
| Recording what is not settled | FDE |
| Saying "this is not the product", every time | FDE — and it belongs in writing, not only in the room |

## 7. What it requires of the customer

| Requirement | Concrete |
|---|---|
| Deciders in the room | The people who can say yes, not observers |
| Fast reaction | Feedback within days; the loop dies at a weekly cadence |
| Tolerance for throwing work away | A prototype that must be kept stops being a prototype |
| A signature on what it is not | See below — this is the requirement that protects both sides |

## 8. Execution — traditional and agentic

| | Traditional | Agentic |
|---|---|---|
| Fidelity reached | Wireframe or clickable mockup. Code prototypes reserved for high-stakes questions | A working code prototype in the time a mockup used to take |
| What can be tested | Layout, flow, comprehension | Real behaviour against real-shaped data — including whether the idea works at all |
| Cost of a wrong direction | Days | Hours, which is what makes trying three directions reasonable |
| Risk | The customer mistakes a mockup for progress | **Worse, not better.** A working prototype looks finished. The faster it is to build, the more convincing it is, and the more carefully its status must be stated |

## 9. Combines well with — and watch out for

**Combines well with**

- **Discovery** in Scoping. Value-led scoping and prototyping ask the same kind of question.
- **Analysis**, as a way to de-risk an estimate before a fixed price is set.
- Any Development approach — a prototyping cycle can sit inside a sprint or a Kanban flow when a question blocks the work.

**Watch out for**

- **Prototyping instead of scoping.** Permitted, but it answers questions without producing an overview. If a project starts here, run one of the Scoping approaches before committing to anything.
- **The prototype that becomes the product.** It has no tests, no observability, no architecture worth the name. If it is to be kept, that is a decision to take deliberately and pay for, not a thing that happens by drift.
- **Prototyping without a written boundary.** Align expectations verbally *and* in writing — in the contract or in other documentation both parties have approved. It must state plainly that the prototype is not a deliverable, what remains unclarified, and what has to happen before a finished solution can be priced.
