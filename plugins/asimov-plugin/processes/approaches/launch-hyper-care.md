---
type: approach
name: "Launch / hyper care"
anchored-to: Development
purpose: "The Launch and hyper care approach. The closing stretch where a coherent solution goes into production and is nursed through its first weeks."
---

# Launch / hyper care

*The closing stretch of the **Development** phase.*

## 1. Purpose

Put a coherent set of functionality into production and carry it through the period where problems surface fastest. It is not a separate project and not an afterthought: it is how the other approaches end.

The old delivery model drew it as its own box for a reason, and then never filled the box in. It is routinely omitted from planning and is a classic source of budget overruns — the work is real, it is skilled, and nobody estimated it.

## 2. When to choose it — and when not

**It applies when** a coherent set of functionality goes live at once: after a Scrum build, after an Analysis-driven build, or at the end of a prototyping track that became a real solution.

**It does not apply to use-case delivery.** Each use case goes into operation as it completes, so the deployment work lives inside every use-case cycle instead. What falls away is only the part that assumes one coordinated go-live: the hyper care period as a distinct phase, and the single handover moment.

**Never skip it because the build finished early.** The build finishing early is not evidence that the launch will.

## 3. What it locks

**A date, and a team's attention.** This is the one stretch where the calendar is a commitment rather than a forecast, and where people must actually be available rather than nominally allocated.

## 4. Activities

**Before: the deployment plan**

- What is deployed, in what order, with what dependencies.
- Test and approval procedure — who signs off, against what.
- Cut-over: what happens to data, what runs in parallel, when the old thing stops.
- **The rollback path**, decided before it is needed. If there is no way back, say so out loud and price the risk.
- *Disciplines:* Deployment · Testing · Planning · Risk management.

**At cut-over**

- Run the plan. Deviations get recorded as they happen, not reconstructed afterwards.
- Keep a named person on the decision to proceed or roll back. That decision must not be made by committee at two in the morning.

**Hyper care — the weeks after**

- Elevated response: a named person available, a route for the customer to reach them, an agreed response time.
- Triage: what is a defect, what is a change, what is a training problem. Confusing the three is how hyper care turns into development nobody scoped or agreed.
- Daily then weekly review of what came in, feeding both the fix list and the adoption work.
- **Exit criteria, agreed in advance.** Hyper care ends on a defined condition — a volume of incidents, a period without severity-one issues — not when someone stops asking.
- *Disciplines:* Hyper care · Adoption · Issue handling · Status reporting.

**Closing**

- Support planning and handover to whoever operates it.
- Closure report, evaluation, NPS.
- *Disciplines:* Handover to operations · Evaluation.

## 5. Output and artefacts

| Artefact | Note |
|---|---|
| Deployment plan | Including the rollback path |
| **E200** | Deployment procedure — test and approval, technical deployment |
| **E100** | IT environment: access, contacts, system documentation |
| **BC100** | Handover documentation |
| **D100**, closed | After living through the whole project |
| Hyper care log | What came in, how it was classified, what it changed |
| Closure report, evaluation, NPS | The project's end |

## 6. Who does what

| Responsibility | Default owner |
|---|---|
| Deployment plan | ASWE, agreed with Project Owner |
| Go / no-go at cut-over | Project Owner, on the ASWE's technical judgement |
| Rollback decision | Project Owner — named in advance, not chosen in the moment |
| Hyper care staffing | Project Owner with Team Lead |
| Triage: defect, change or training | ASWE classifies; Project Owner decides what it costs |
| Customer communication during hyper care | Customer Owner |
| Declaring hyper care over | Project Owner, against the agreed exit criteria |

## 7. What it requires of the customer

| Requirement | Concrete |
|---|---|
| Test participation | Named testers, available in the window, not "the business" |
| Approval authority | Someone who can accept, present at cut-over |
| Availability during hyper care | Reachable at the agreed response time, including their own IT if we depend on it |
| Agreement on exit criteria | Set before go-live. This is the requirement most often skipped and most often regretted |
| A route for their users | Their people must know where to report a problem |

## 8. Execution — traditional and agentic

| | Traditional | Agentic |
|---|---|---|
| The pipeline | Manual gates before release | Deterministic CI/CD; no manual gates inside the pipeline. The human decision moves to the go/no-go, where it belongs |
| Fixing during hyper care | A developer patches | An agent can produce a fix quickly — which makes triage discipline more important, not less, because the cheapness of a fix is a poor reason to make one |
| Documentation | Written under time pressure, often badly | Generated from the codebase, so handover documentation stops being the thing that slips |
| Production access | — | **Fixing in production is a Zone 3 question**, not a Development one. If agents are to touch production logs or data during hyper care, that is agreed per customer and in advance — not decided at cut-over |

## 9. Combines well with — and watch out for

**Combines well with**

- **Scrum** and **Analysis**-driven builds, which converge on a release.
- **Handover to operations** in the Operations phase — the two are almost continuous, and a good launch is most of a good handover.

**Watch out for**

- **Use-case delivery.** It does not apply as a closing stretch; see above.
- **Hyper care without exit criteria.** It becomes open-ended support, and because the end was never decided it was never budgeted either. Nobody notices until what was set aside for the period is spent, or exceeded.
- **Launch planned as a milestone rather than as work.** It has activities, owners and a cost. A date in a plan is not a launch plan.
- **Treating hyper care as a defect budget.** Most of what arrives is training and expectation, not defects — which is why adoption belongs here rather than after.
