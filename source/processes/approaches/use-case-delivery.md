---
type: approach
name: "Use-case delivery"
anchored-to: Development
purpose: "The Use-case delivery approach. Validate one use case at small scale, then scale to the next, with each going live on its own."
---

# Use-case delivery

*An approach in the **Development** phase: validate one use case at small scale, then scale to the next. The delivery shape of a subscription engagement.*

## 1. Purpose

Deliver value one use case at a time. A **pilot use case** proves the idea at small scale; once it holds, further use cases **scale** the same pattern. Each goes into operation when it is ready, so value arrives continuously rather than at a release date.

This is the approach for a standing engagement where the relationship outlives any single scope — and where the customer buys capacity and direction rather than a defined deliverable.

## 2. When to choose it — and when not

**Choose it when**

- The collaboration is long-running and trust is high. Nothing here works with a customer who needs a contract to point at.
- Scope must be able to change. The next use case is chosen from what the last one taught.
- Value is easier to demonstrate per use case than per release.
- The engagement is large enough to sustain a standing team.

**Do not choose it when**

- The customer needs a fixed price against a fixed scope. This approach is built to change scope.
- There is a hard external deadline for a coherent system. Use cases land individually; they do not converge on a date by themselves.
- The customer cannot supply a real product owner. Without one, use-case selection follows whoever asks most often rather than what is worth most.

## 3. What it locks

**Direction and capacity, not scope.** The commitment is a team at a rhythm, and a roadmap that says what kind of value comes next — not a list someone signed.

## 4. Activities

**Per use case: validate**

1. **Define the use case** — what business outcome it serves, and what "it works" means in numbers.
2. **Build the smallest thing that proves it**, at small scale, with real users rather than a demo audience.
3. **Measure against the outcome.** Did the value appear? This is the gate, not a demo.
4. **Decide:** scale it, adjust it, or drop it. Dropping is a legitimate result and should happen sometimes — if it never does, the validation step is theatre.

**Per use case: scale**

- Widen to the full user group, harden, instrument, and put it into operation on its own schedule.
- Feed what was learned back into the roadmap before choosing the next use case.

**Continuously**

- **Feature roadmap** kept current — the artefact that replaces a plan.
- **Estimation in effort points on PBI**, not hours. The unit is comparative, not predictive; it exists to size relative to past work.
- **Sprint demo** on the team's rhythm; **quarterly business demo** at sponsor level, where the conversation is value delivered rather than work done.

*Disciplines:* Outcome definition · Value laddering · Planning · Estimation · Adoption · Testing · Deployment · Status reporting.

## 5. Output and artefacts

| Artefact | Note |
|---|---|
| Use-case definition | Per use case: the outcome, the measure, the scope of the pilot |
| Feature roadmap | Replaces the project plan |
| Backlog in effort points | The estimation unit binds this approach to a subscription contract |
| **D100** | Maintained continuously — it is the only durable record when there is no release |
| **E200** | Exercised per use case, not per release |
| Quarterly business demo | The sponsor-level artefact |

## 6. Who does what

| Responsibility | Default owner |
|---|---|
| Choosing the next use case | Customer's product owner, with FDE |
| Defining the outcome and its measure | FDE |
| Validation call — did it work? | FDE with the customer, on the measure |
| Building and scaling | ASWE |
| Roadmap upkeep | Project Owner |
| Sprint demo | ASWE |
| Quarterly business demo | Customer Owner, with FDE on the value story |
| Deciding a use case is dropped | Customer's product owner — we recommend, they decide |

## 7. What it requires of the customer

| Requirement | Concrete |
|---|---|
| A real product owner | Empowered to choose the next use case and to stop one |
| Real users for validation | A pilot with no users is a demo |
| Willingness to measure | The outcome measure agreed before the build, not argued after |
| Sponsor at the quarterly demo | Otherwise the value story never reaches the person paying |
| Acceptance that scope is not a list | The commitment is capacity and direction |

## 8. Execution — traditional and agentic

| | Traditional | Agentic |
|---|---|---|
| Pace | A use case per few sprints | Faster per use case — which moves the constraint to how quickly the customer can absorb and adopt each one |
| Validation | Build, then measure | Cheap enough to test two framings of the same use case before choosing |
| The roadmap | Rewritten periodically | Under more pressure: it goes stale faster when delivery accelerates |
| Documentation | D100 drifts behind | Generated from the codebase and kept current, which matters more here than anywhere — there is no release to force a documentation moment |

## 9. Combines well with — and watch out for

**Combines well with**

- **Discovery** in Scoping. The same value-led thinking, and Discovery produces exactly the MVP use case this approach starts from.
- **Business Continuity** in Operations — a standing engagement usually keeps running.
- The **Business Value Ladder**, which gives use-case selection a reason beyond preference.

**Watch out for**

- **Launch / hyper care does not apply as a closing stretch.** Each use case goes live on its own, so the deployment elements — test and approval, E200, cut-over check — live inside every use-case cycle instead. Only the parts that assume one coordinated go-live fall away.
- **Use-case delivery + Analysis or fixed price.** The customer pays to lock a scope and then runs a way of working built to change it. If the contract is fixed, bound this approach to a named set of use cases.
- **Validation that never fails.** If no pilot is ever dropped, the gate is not real and the approach has quietly become "build the backlog, slowly".
- **The roadmap nobody reads.** Without a maintained roadmap this becomes a queue with extra ceremony.
