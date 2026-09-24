---
type: discipline
name: "Testing"
kind: phase
anchored-to: Development
purpose: "Establishing that what was built does what the specification said, and that the customer agrees."
---

# Testing

*A **Development** discipline, and one of the two things the customer must do rather than watch.*

## Purpose

Establish that the solution does what was specified, at the levels that matter — unit, integration, acceptance and security — and get the customer's acceptance of the completed work. Testing is both a technical activity and a contractual one, and the second half is the one that gets neglected.

## Why it matters

The obvious reason is quality. The less obvious one is that acceptance is a commercial event: a feature the customer has tested and accepted is finished, and one they have not is still open no matter how done it looks to us.

Under agentic delivery there is a third reason that changes the weight of this discipline entirely. When an agent writes the implementation, **the tests become the thing a human actually reads.** Verification moves from reviewing the code to checking the outcome against the specification — which means the quality of the test scenarios is now the quality of the review.

## How it is done

**Decide the test levels and who owns each.** Unit and integration sit with the build. Acceptance sits with the customer. Security — dependency scanning, vulnerability checks, bill of materials — runs in the pipeline and belongs to the Engineer track's guardrails.

**Write acceptance criteria as part of the specification, not afterwards.** A criterion invented at test time is a negotiation, not a check.

**Get the customer testing on a rhythm.** The default is that the customer tests completed items after every sprint, or at another agreed frequency. What matters is that it is agreed and that it happens — a customer who tests everything at the end has converted the whole delivery into one large acceptance risk.

**Make the test and approval procedure explicit** before deployment. Who signs off, against what, and by when. That procedure is part of the deployment documentation.

**Do not let testing be where scope is discovered.** A test that fails because the customer expected something different is a specification problem surfacing late, and it should be recorded as one.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can write and run tests against acceptance criteria, and support the customer through their testing |
| **Show it** | You can design test scenarios that catch what matters — including the edge cases — and get the customer testing on rhythm rather than at the end |
| **Build it** | You can set up the test strategy for an engagement: levels, ownership, automation, and where the quality gates sit. You make the customer's acceptance a routine event rather than a milestone |
| **Own it** | You can judge when a solution is ready to go live on incomplete evidence, and be right. You set the standard for what "tested" means here |

## How to get better

**Internally**

- The old delivery model's **Test** page, and the test and approval procedure in the deployment documentation.
- The **Engineer track**'s material on test levels, quality gates and the pipeline stages — pre-commit, pull request, post-commit.
- The **specification** discipline. Testability is decided when the acceptance criteria are written, not when the tests are.

**Externally**

- Lisa Crispin and Janet Gregory, *Agile Testing* — the standard work on testing as a whole-team activity rather than a phase.
- Gojko Adzic, *Specification by Example* — acceptance criteria that are executable, which is the practical bridge between spec and test.
- The **DORA** research on test automation and its relationship to delivery performance — useful when arguing for the investment.

## Common failure

**Testing only at the end.** All the acceptance risk arrives at once, in the window that has the least slack.

**Acceptance testing that never quite happens.** It is agreed, the people who were to do it have a day job, it slips, and acceptance becomes a signature on something nobody examined. That holds until the first production problem. Plan it as real work, with named people and time set aside on both sides.

**Criteria written at test time.** Whatever was built defines what passing means.

**Automated tests that assert the implementation.** They pass forever and catch nothing, which is worse than no tests because they create confidence.

**Rubber-stamping agent output.** The named risk at L3, and the one this discipline exists to prevent: approving because the tests are green without asking whether the tests test the right thing.

## Artefacts

Test scenarios and acceptance criteria, part of the feature design · the test and approval procedure in the deployment documentation · test results and the customer's acceptance record.

## How it varies by approach

Scrum tests per sprint, with the customer accepting completed items. Use-case delivery tests per use case, and acceptance is the validation gate. Kanban tests per item, which requires automation to be viable at all. Launch and hyper care adds the coordinated test and approval procedure before go-live.

**Traditional vs agentic.** The largest change of any discipline in this catalogue. Traditionally tests supported a human review of human-written code. Agentically, **verification is outcome-based**: the human checks the result against the specification rather than reading the implementation, so the test suite carries the weight that code review used to. Two consequences follow — test scenarios must be written *before* the build, as part of the quality specification, and a green pipeline is evidence about the tests as much as about the code.
