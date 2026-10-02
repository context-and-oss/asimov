---
artifact: d101-feature-design
maturity: trial
since: 2026-09-10
---

# Definition of D101

The written standard a D101 (feature design document) must meet before downstream work — Spec (S101/S102), Code, Review+Test — can act on it. This document defines the Design stage's **two bars**: the **business-complete bar**, which a D101 clears before any technical design exists, and the **gap-free bar**, which it clears before an implementer can act on it (§2).

Read both by humans (authors, reviewers) and by the `/d101-feature-design` and `/d101-review` slash commands at run-time.

---

## 1. What a D101 is for

A D101 has two purposes. A document that meets only one is not gap-free.

### 1.1 Clarify business intent with stakeholders

The D101 is the artifact a product or business reviewer signs off on. They read it without the original conversation and understand:

- *What* the team is going to build, in terms the business uses
- *Why* now, what problem it solves
- *What rules* govern the behaviour (eligibility, ordering, edge cases)
- *What's deliberately out of scope* — and why

This is the **upstream** purpose — before implementation begins. A misaligned D101 produces a wrong feature, no matter how well it's implemented.

### 1.2 Provide a verifiable basis for the implementation

The D101 is what the human reads in the Approve phase to decide if the implementation matches the design. Every acceptance criterion is something a reviewer (or a test) can check against the running system, the code, the logs, or a defined manual step.

This is the **downstream** purpose — after implementation lands. A D101 without verifiable outcomes cannot be approved, only trusted.

## 2. The two bars

A D101 matures through **two** bars, not one. The first is reached before any technical design exists; the second adds it. Both are named, because a document that has cleared only the first is in a legitimate, reviewable state — not a failed attempt at the second.

### 2.1 The business-complete bar

> **A D101 is business-complete when a product or business reviewer can agree to what will be built and why, without the technical design existing yet.**

Everything the business signs up to is settled: purpose, requirements, concept model, rules with their counter-examples, UI surfaces, acceptance criteria, and open questions with their deciders. The technical design (§6) is *declared open* — see §4.6 — not left silently thin.

The bar exists because business shape and mechanism fail differently, and at different times. Settling the mechanism first anchors the business design to whatever was convenient to build. A document that reaches this bar and **stops** has forced the business conversation to happen while changing the answer is still cheap.

Its check is §8a. Reaching it is the **author's** call — the bar's whole function is that the author stops moving forward until the business shape holds.

### 2.2 The gap-free bar

> **A D101 is gap-free when an implementer who never saw the conversation can act on it without design-level questions.**

*Design-level* means questions about *what* or *why*. Questions about *how* (file paths, signatures, libraries, data structures) belong to the Spec stage (the S102) and are expected.

A gap-free D101 has cleared the business-complete bar first and has a populated §6. Its check is §8b, and that verdict is a **reviewer's** (≠ author) call.

The template's Implementation section (§7) sits *below* this bar — build-readiness authored after gap-free, gating nothing. See §4.8.

### 2.3 Phase is not status

Two independent axes, both carried in the rendered D101's top bar:

| Axis | Values | Who moves it | What it means |
|---|---|---|---|
| **Phase** | `Business design` → `Full design` | The author | How far the authoring has got. `Business design` = §8a cleared, §6 open. `Full design` = §6 written, §8b is now the applicable bar. |
| **Status** | `Draft` → `Approved` | The business approver named in §1 | Whether the business has signed off. |

They do not track each other, and neither implies the other. A `Full design` document is still `Draft` until the approver signs — and sign-off normally waits for the technical design, because the estimate that accompanies it depends on §6 existing.

## 3. Relationship to other documents

| Doc | Stage | What it answers |
|---|---|---|
| Charter (programme- or repo-level) | Before D101 | Why does this product / repo exist at all? |
| **D101** | Design | What feature, with what scope, what business rules, what verifiable outcomes? |
| S101 | Spec | In what order, by whom, and in parallel with what — the task graph, phases, interfaces and constraints for one D101 (`s101-implementation-plan-definition.md`) |
| S102 | Spec | Exactly how one task is built — file paths, signatures, edge cases, code-level acceptance criteria (`s102-task-spec-definition.md`) |
| ADR / MADR | Cross-cutting | Why was this architectural option chosen over alternatives? |
| Conventions | Cross-cutting | How do we write code generally? |

**One D101 at `Full design` produces one S101 and one or more S102s.** A D101 is sized to a *feature*; an S102 is sized to *one task a fresh builder finishes in one sitting*; the S101 is as long as its graph. A complex feature (e.g. a status dashboard covering instrumentation + UI + alerting) may produce 3–8 S102s. Each S102 traces back to a subset of the D101's requirements, and the S101's coverage map shows every requirement has a task. D101 length is therefore variable and follows the feature; S102 size is fixed by convention to keep tasks predictable.

Until the Spec stage is in use for a feature, the template's Implementation section (§7) is an **interim home** for some of this how-level detail — file layout, reuse-vs-new, method-level wiring — carried in the D101 without being dressed as design. It sits outside the two bars; see §4.8.

### 3.1 How a D101 meets `contracts/design.md`

The Spec stage reads any design through the members of the design contract (`plugins/asimov-plugin/contracts/design.md`). A D101 at `Full design` provides them here:

| Member | Where in the D101 |
|---|---|
| Reference | The file path and the version in the status chip (template sections are named by number below; this definition's own sections are marked *this definition*) |
| Approval | Who: the business approver named in §1. When: the *Last updated* date in §1 at the write that set `Full design`. Where: the phase chip, which is the author's move after the business approver agreed to §2–§5 (*this definition* §2.3). The status chip's `Approved` is the business sign-off on the whole; the Spec stage plans from `Full design` and does not wait for it, because the estimate depends on §6 |
| Problem | §2 Purpose |
| Decision | §4 Business design and §6 Technical design |
| Acceptance criteria | §8, each checkable and rooted in §3/§4 (*this definition* §6.1, §6.2) |
| Out of scope | The out-of-scope rows of §3, each with its reason |
| Ids | R, NF, AC and OOS numbers as written; §6.x.y for contracts |
| Rules | The numbered business rules in §4, each with its counter-example (*this definition* §6.3) |
| Open questions | §9, each with a decider (*this definition* §4.3) |
| Assumptions | No section of its own: a `TBD — verify` with a named decider (*this definition* §4.3) is one, and the decisions table in §4 names what each choice took for granted |
| Interfaces | §6 contracts, by number |
| Non-functional requirements | The NF rows of §3 |
| Alternatives | The decisions table in §4: the alternative considered and why it was rejected (*this definition* §4.3) |
| Risks | Failure handling at design level (*this definition* §4.5) |

A D101 at `Business design` does not meet the contract: §6 is open, so the decision and the interfaces are not there yet.

## 4. Required content

Every D101 covers, at minimum, the items below. The D101 template determines the section layout; this section determines what *must* be present somewhere in those sections.

### 4.1 Business intent

- **Concept model** — the domain vocabulary. Named entities, what they mean, how they relate.
- **Flows** — numbered; each with trigger, steps, outcome, and error paths.
- **Business rules** — numbered; each with at least one positive example *and* one counter-example (see §6.3).
- **Edge cases and constraints** — quotas, eligibility, ordering, concurrency rules that the user experiences.
- **UI surfaces (user-facing features only):** the screens the feature introduces or changes, their layout, key states (empty, loading, error, populated), and primary interactions. The reference form is an interactive HTML mockup committed alongside the D101 (the template's ground rules define where). This is business-altitude content — *what the user sees* — and the template gives it its own top-level section (§6 is the technical design that follows it). A backend-only feature keeps that section's heading and marks it N/A rather than dropping it, so the section numbering stays contiguous.

All of the above is stated in the vocabulary the business uses — the *what* and *why*, not the code mechanism. Code identifiers appear at most as parenthetical anchors; the mechanism that realises the intent lives in the technical-design section (§6). A business-intent section that only makes sense to someone who knows the codebase is at the wrong altitude (§7 *Business design at code altitude*).

### 4.2 Scope

- **Functional requirements** — numbered, atomic, testable (see §5).
- **Non-functional constraints** — only those that drive design decisions. Don't parrot generic SLOs.
- **Non-goals** — things that could reasonably be in scope but are explicitly chosen not to be. State *why* each one is out, not just *that* it is. *"Deferred to v2"* is valid; *"belongs in another doc"* is valid (name the other doc).

### 4.3 Decisions and tradeoffs

- **Decisions already made** — architectural commitments, tool choices, conventions adopted.
- **Alternatives considered and rejected** — with the reason for rejection. A decision without its rejected alternatives is a decision that will be re-litigated.
- **Open questions** — every open question names a **decider** and a resolution path. Anonymous TBDs are a blocker.

### 4.4 Verifiable outcomes

- **Acceptance criteria** — see §6.
- **Cross-references** — every acceptance criterion references the requirement (§3) or rule (§4) it verifies.

### 4.5 Failure handling at design level

- For each named error path in a flow, the system's response at the design level (which may be *"fails the operation; surfaces in admin tooling"* — the *how* is the S102's job).
- Failure modes the *design* depends on belong in the D101. Routine error handling belongs in code conventions.

### 4.6 Declaring the technical design open

While a D101 stands in the `Business design` phase (§2.3), §6 carries a single *still to write* block instead of its subsections. That block is required content, not a placeholder:

- **It names what is outstanding, item by item**, in terms of the consequence of not knowing — *"how each answer is composed"*, *"the cost ceiling and where it concentrates"*, *"which tenant and which cluster per environment"*. A bare *"TBD"*, a *"technical design to follow"*, or a restatement of the §6 subsection headings does not satisfy this.
- **It states plainly that the document is not gap-free** and that no S102 can be written from it yet. A reader who opens the file must not have to infer that from a thin section.
- **It is not an N/A.** N/A means *this section does not apply to this feature*; open means *it applies and is not settled yet*. Written as one-line stubs the two read identically, so they are kept distinct in shape: **N/A gives a reason, open gives a list.**

The outstanding list is what makes the phase honest. A §6 that is open but whose list is vague has hidden the gap rather than declared it — and hiding it is worse than an over-eager §6, because a reader cannot tell the difference between *unsettled* and *unwritten*.

### 4.7 The technical design is a blueprint, not a decision log

The technical-design section (§6) states *what to build* — the mechanism, declaratively, the way a blueprint states walls and dimensions. It does **not** re-argue how the team arrived there. An implementer needs the shape of the thing, not the journey to it.

- **Declarative, not narrative.** Each part says what exists and how it behaves: the component and its responsibility, the data shape, the configuration and its default, the failure and its recovery. *"We chose X because Y, rather than Z"* is not part of the instruction.
- **Rationale has one home: the Decisions treatment (§4.3).** A choice worth recording — with the alternative it ruled out and why — goes in a decisions block (Decided | Alternative | Why), not woven into the spec prose. Business/product choices sit in the business design's Decisions section; a mechanism-level choice that must be recorded uses that same three-column shape inside the technical design rather than a paragraph. Everywhere else in §6, *why* appears at most as a one-clause parenthetical where a choice would otherwise read as arbitrary.
- **Litmus.** Strip every *because / we chose / rather than / the reason is* clause from §6 — the build instruction must still be complete and unambiguous. Whatever had to stay was spec; whatever was removable was rationale, and belongs in Decisions or nowhere.

This is the technical-side counterpart of the business-altitude rule (§7 *Business design at code altitude*): that rule keeps mechanism out of the business sections; this one keeps rationale out of the build spec.

### 4.8 The implementation section is a build recipe, beyond the two bars

The template carries an **Implementation** section (its §7) below the technical design. Where the technical design states *what to build* — the contracts and shapes a reviewer signs off — the implementation section states *how a builder builds it*: the project layout, what is genuinely new versus reused, the source classes and methods each unit reuses, and the setup and wiring. It is code-grounded throughout, and its per-unit blocks key back to the technical-design contracts by number. Class names in it are illustrative — the shape is the instruction, not the exact identifier; it links to the source rather than copying it (the template's *link, don't duplicate* ground rule — no pasted enum values, schemas, or column lists that live in code).

**It sits outside both bars.** Neither §8a nor §8b gates it, and it moves neither the phase nor the status chip. Check 6 — *could one or more S102s be written from this* — is asked of the technical design and the business design alone; a D101 is gap-free with its implementation section empty. The implementation section is authored *after* the gap-free bar, as build-readiness for the implementer or a build subagent, and its absence is never a reason to send a D101 back.

**It is the interim home for build notes until the Spec stage is in use.** Much of what it records — file-level layout, reuse-vs-new, method-level wiring — is S102 territory (§3; `s102-task-spec-definition.md` §3). Until a feature has an S101 and its S102s, this section lets a D101 carry that detail without dressing it as business or contract design. A feature that has an S101 marks §7 N/A and points at its `documentation/specs/<feature-slug>/` folder.

Its shape — Full-design phase only, a *pending* stub while the technical design is open, an N/A stub when the build is pure reuse — is defined in the template's authoring ground rules (rule 13) and N/A policy.

### 4.9 Accepted deviations

A rule this definition sets can be *deliberately* not met. When the author and the accepter have looked at a finding and chosen to live with it, that choice is recorded **in the D101, next to the thing it excuses** — never in a side file, and never as a silent omission.

The problem it solves is narrow and real: without a record, a review re-reports a finding the team has already considered, so the same decision is spent again on every run and the review's signal decays. A deviation recorded in the document costs the reader one line and the author nothing.

An accepted deviation carries four things:

- **The rule it departs from**, named — *"atomic requirement (§5)"*, *"every requirement produces an acceptance criterion (§6.2)"*.
- **Why**, in one sentence.
- **Who accepted it** — a named person. An unsigned deviation is a suppression, and §7 treats it exactly as an anonymous TBD.
- **When** — a date, so a reader can tell an old accommodation from a current one.

Three limits are what make it safe rather than corrosive:

1. **It covers one named instance, never a check.** *"R6 is compound; accepted"* is a deviation. *"Check 1 does not apply here"* is not. No accepted deviation may cover a whole §8 check — that would let a document be *accepted* to the gap-free bar instead of reaching it.
2. **It never silences the review.** `/d101-review` reports an accepted deviation on every run, with its reason and its accepter. What it stops doing is asking the author to decide again. Visibility is the entire mechanism: the reviewer who owns the §8b verdict must see what they are signing.
3. **It is bound to the text it annotates.** Rewrite the requirement, rule, or section it sits on and the acceptance lapses — new text needs a new decision.

**Accepted is not Pass.** A section or check whose only outstanding item is an accepted deviation reads **Accepted**, never Pass. This is the same move as *open* in §4.6: a deliberate state gets its own name, so a reader can mistake it neither for a shortfall nor for a clean bill.

An accepted deviation is a worse outcome than a fix, and the mechanism is deliberately narrow so that stays true — the ceiling on what it can excuse is one named rule instance at a time. Its design is `documentation/features/D101-d101-feature-design.html` (§4.4, §6.4).

### 4.10 Review notes — a cache, not a record

`/d101-review` may write its findings to a sibling file, `<same directory as the target>/D101-<slug>.review.md`, so they survive past the chat session that produced them and reach a later `/d101-feature-design` run as input. The sibling is derived from wherever the target D101 actually resolved to — normally `documentation/features/`, but a target reviewed from a non-standard path gets its notes written beside it, never redirected to the standard location. The file is **read-only findings a review would have produced anyway** — never a place new judgement gets made, and never something an author edits by hand.

This is only safe because the gap review is **stateless**: every run derives its findings from the D101 alone, from scratch, with no memory of prior runs. That makes the review-notes file a disposable cache rather than a record of history:

- It carries **no state the D101 itself and a re-run of the review couldn't reproduce.** Losing the file costs one re-run, never a lost decision.
- It is **consumed once and then deleted** by `/d101-feature-design`, the moment it has been used as input to a rewrite of the same D101. An item left unaddressed does not vanish with the file — it resurfaces on the next `/d101-review` run, because the D101 that produced it is unchanged.
- It carries a **fingerprint of the D101 it was written against** (§1's *Last updated* date, the phase-chip value, and the status chip's **literal text including its version number**, e.g. `Draft v0.3`, at review time), so a consumer can tell whether the D101 changed underneath it before the notes were used. The version number matters: it advances on every write, so two edits made on the same calendar day still produce different fingerprints even though the date alone would read as unchanged. A mismatch is reported, not silently trusted — the fingerprint is still a coarse proxy, not a hash, and says so.
- It is **git-ignorable.** It is working state between two commands, not a design artifact — committing it turns review commentary into something that looks like a permanent record, which duplicates a PR's own review thread (out of scope — see the design).

Its design, including the exact file shape and the hard-rule caveat this needs (`/d101-review` gains `Write`, but the *scope* of what it writes is a prompt discipline, not a sandboxed guarantee — the same category of promise the never-move-either-axis rule already relies on), is `documentation/features/D101-d101-feature-design.html` (R10–R11, §6.4).

## 5. Requirement quality rules

Each requirement must satisfy all five:

- **Testable.** Observable against the system, code, logs, or a defined human-review step. If you can't say how the requirement would be verified, it is not a requirement.
- **Unambiguous.** Two independent readers would formalise the requirement the same way. If two readers reasonably disagree on what the requirement means, it is a defect.
- **Atomic.** No compound *and* / *but*. If a sentence describes two behaviours, split it into two requirements. If a behaviour is conditional, split into a positive ("when C, then A") and an unwanted-behaviour ("when not C, then not A").
- **Solution-free.** Describes *what* observable, not *how* mechanism. *"Use Repository pattern with dependency injection"* is implementation; it belongs in an S102 or in conventions, not in a D101 requirement.
- **Complete.** The requirement set covers the relevant input space, including failure modes. Behaviour unspecified for whole regions of the input space is a defect, not a "smart default".

A requirement that fails any of these is a draft note, not a requirement.

## 6. Verification mandate

The D101 is the contract between business sign-off and downstream verification. The following rules make that contract enforceable.

### 6.1 Every acceptance criterion is checkable

An acceptance criterion answers: *"How does a reviewer or test know this is done?"* Judgment-only phrasing ("works well", "is fast enough", "is intuitive") is rejected unless paired with an explicit measurable rule. *"Portal login success rate ≥ 99 % = green; 95–99 % = yellow; < 95 % = red"* is a checkable criterion. *"The login screen is responsive"* is not.

Verifiability can be automated (a unit/integration test, a metric query, an alert rule) or manual (a defined human-review step). What's not allowed is implicit.

### 6.2 Acceptance criteria root back to §3 / §4

Every acceptance criterion references either a numbered requirement (§3) or a numbered rule (§4). Acceptance criteria floating with no backing are a sign either the requirement set is incomplete or the AC is invented.

The reverse is also expected: every requirement should produce at least one acceptance criterion. A requirement with no AC is either untestable (defect — see §5) or pure decoration.

### 6.3 Business rules carry counter-examples

A business rule of the form *"if X then Y"* must be accompanied by:

- A **positive example** illustrating the rule firing as intended.
- A **counter-example** illustrating an adjacent case where the rule does *not* fire.

The counter-example forces clarity on what the rule does *not* say. Rules without counter-examples are routinely over-applied during implementation, because the implementer infers a broader scope than the author intended.

Plain functional requirements (R-rows) do **not** require counter-examples; only business *rules* — conditional, scoping, or eligibility rules — do.

### 6.4 Failure modes are part of the design

If a flow has a "what if this step fails" answer that materially affects the business outcome (data loss, orphaned records, silent inconsistency), the D101 captures it. Failure modes left to the S102 leak design decisions into specification.

## 7. Anti-patterns

A D101 in any of these states clears neither bar — except where an entry says otherwise, they are all failures of the *business* design and so block §8a as well as §8b:

- **TBD without a named decider.** Every open question states *who* decides and *by when* (or *under what condition*). Anonymous TBDs accumulate and never close.
- **Code-paraphrase as design.** Lines like *"nullify `OrderedByUserId`, then delete `Filters`, then delete `AlarmsLastViewed`"* are implementation detail dressed as design. The business intent — *"preserve the audit trail of who ordered what; erase the user's personalisation"* — is what belongs in the D101.
- **Business design at code altitude.** §2 *Purpose* and §4 *Business Design* are written in the vocabulary the business uses, not the code's. A narrative built out of interface / class / method names, framework calls (`SaveChangesAsync`), DI registrations, or file paths is implementation dressed as design — even when no single sentence mixes the two layers (the sharper, per-section form of *Mixed business / technical without a boundary* below). **Litmus:** strip every code identifier from §2 and §4 — if the section still conveys the *what* and *why*, it's at the right altitude; if it collapses into blanks, rewrite it at business altitude and push the mechanism to §6. A code identifier in parentheses as an anchor is fine (*"the shared messenger abstraction (`ICommunicator`)"*); a narrative that *depends* on the reader knowing that identifier is not. *Bad:* *"The Web API stops registering `ICommunicator`, `ICommandDispatcher`, and the dead `ICommandService` family; endpoints inject `IMessageRepository` and call `AddCommandAsync<TCommand>` directly."* *Good:* *"The Web API no longer depends on the shared messenger or dispatcher abstractions, and an unused command-tracking family is removed; outbound commands are written straight to the messaging store through one interface."*
- **Implicit code coupling.** Naming a code-level convention as a load-bearing design fact without flagging the coupling. *"`GetIntegrationPermissions()` filters by name containing 'Integration'"* is a fragile coupling, not a design truth — flag it explicitly or refactor.
- **Compound requirements.** *"The system shall do A and B"* splits into two requirements. *"Shall A but only when C"* splits into a positive (*A when C*) and an unwanted-behaviour (*not-A when not C*).
- **Implementation recipes as requirements.** *"Use the Service pattern"*, *"Use NSwag-generated clients"* are *how*. They belong in an S102 or in conventions.
- **Missing non-goals.** A scope with no out-of-scope list is silently overstuffed. Every D101 names what it deliberately does *not* cover.
- **Missing alternatives.** A decision recorded without the alternatives it ruled out is a decision that will be re-opened the moment an implementer prefers the rejected option.
- **Acceptance criteria with no backward link.** An AC that does not reference a requirement or rule is testing something the D101 didn't promise — either remove the AC or add the missing requirement.
- **Intent-drift gaps.** A design left vague enough that an agent (AI or human under time pressure) fills the gap with a "reasonable default" the business never approved.
- **Mixed business / technical without a boundary.** Business behaviour and technical mechanism interleaved in the same paragraph. The template's business/technical split (§4 business design, §6 technical design) exists for this reason — respect it.
- **Mechanism invented ahead of the business shape.** §6 filled with a plausible-sounding mechanism the author has not actually settled, while §4 is still moving. It reads as progress and isn't: it anchors the business design to whatever was convenient to build, and the anchor is invisible to a reviewer because nothing marks the mechanism as a guess. If it isn't settled, declare §6 open (§4.6).
- **A silently thin §6.** §6 present but hollow — no statement that it is open, no list of what is outstanding. The reader cannot tell *unsettled* from *unwritten*, so they assume the design is finished and thin. Fails check 9.
- **Deviation without an accepter.** An accepted deviation (§4.9) that names no person, or no date, is a suppression dressed as a decision — it reads as *"someone decided this"* while nobody is answerable for it. Treat it exactly as an anonymous TBD: the underlying finding stands, unaccepted.
- **A deviation that swallows a check.** An accepted deviation written against a whole §8 check rather than one named rule instance (§4.9 limit 1). It converts *reaching* the bar into *being excused from* it, and no number of reasons makes that a design.
- **Rationale woven into the build spec.** The technical design narrates *why* — decision-journeys, *"we chose X because Y"*, trade-off essays — instead of stating *what* to build. A blueprint shows the wall, not the argument for the wall. A gap-free (§8b) quality failure specific to §6: move the rationale to a decisions block (§4.3, §4.7) and leave the spec declarative. *Bad:* *"We keep one whole message per reefer rather than merging columns, because merging would cost a join per read and the cache already holds the object whole — so a status lookup is a memory read."* *Good (spec):* *"Status is served from the in-memory per-reefer cache (one whole latest message each); no query."* — with the merge-vs-whole choice, if worth recording, in a Decisions row.

## 8. The checks

One canonical numbered list serves both bars. The **Bar** column says which bar each check belongs to, so a numbered reference (*"check 7"*) means the same thing everywhere in the toolkit — the numbers never shift when a check changes bar membership.

Every check is asked of the **document alone**, never of the conversation that produced it.

| # | Check | What it tests | Bar |
|---|---|---|---|
| 1 | Could two engineers implement this differently and both claim to follow the design? | Unambiguity (§5) | both |
| 2 | For every observable behaviour named, is there a check that proves it works? | Verifiability (§6.1) | both |
| 3 | For every business rule, do I know what it does *not* cover? | Counter-examples (§6.3) | both |
| 4 | For every open question, do I know who decides? | Ownership (§4.3) | both |
| 5 | For every "out of scope", do I know why it's out? | Non-goals with rationale (§4.2) | both |
| 6 | Could one or more S102s be written from this without going back to the business? | Downstream actionability | §8b only |
| 7 | Could a product or business reviewer who doesn't know the codebase understand §2 and §4 — or does the narrative depend on named types, methods, framework calls, file paths, or any other code-level mechanism? | Business altitude (§7) | both |
| 8 | *(User-facing features only.)* Is the UI specified concretely enough to build, with an interactive artifact demonstrating the primary surface(s)? | UI completeness (§4.1) | both |
| 9 | Is §6 declared open with a named list of what is outstanding? | Honest phase (§4.6) | §8a only |
| 10 | Is the phase `Full design` — §6 populated, no *still to write* block left? | Phase (§2.3) | §8b only |

Check 8 is conditional on the feature being user-facing. A backend-only feature **skips** it rather than failing it.

No accepted deviation (§4.9) may be written against a check in this table. A deviation excuses one named rule *instance*; the check that instance belongs to then reports **Accepted** — carrying the reason and the accepter — rather than Pass. A document is never excused from a check, only ever from a named case within one.

Check 7's abstract question — *would the reader understand it?* — has a concrete, reader-in-the-loop form: a **persona review** puts a specific named reader in front of §2/§4 (and §6, for a feasibility reader) and narrates where they stall. `/d101-review` tests check 7 by the altitude litmus; a persona review tests it by the reader. They are complementary — run both. See `persona-review-definition.md`.

### 8a. The business-complete check

Checks **1, 2, 3, 4, 5, 7, (8), 9**. Check 6 does not apply — a document at this bar deliberately cannot be turned into an S102 yet, and marking that a failure would defeat the bar.

If any applicable answer is *no*, the document has not reached the business-complete bar. It is the **author's** call, and the response is to keep working on §2–§5 rather than to move on to §6.

### 8b. The gap-free check

Checks **1, 2, 3, 4, 5, 6, 7, (8), 10**. Check 9 no longer applies — the open-§6 block it tests for should be gone.

If any applicable answer is *no*, the D101 is not gap-free. Send it back. The bar is not *"would I implement it"* — the bar is *"could an implementer who wasn't in the design conversation act on this alone, and could a reviewer verify the result against this document"*.

This verdict belongs to a **reviewer (≠ author)**.
