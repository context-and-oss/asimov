# L3 spec-format research — handoff

**Status:** in design. Three decisions locked, several open. Next step: draft `specs/README.md`.

> **Revised 2026-09-25** by [`S101-S102-spec-stage-research.md`](S101-S102-spec-stage-research.md), which researched the plan layer above the single spec and took the decisions. Two locked decisions below changed: the `S101-*` family naming is **adopted** (S101 implementation plan, S102 task spec; lifecycle is carried by a `superseded` status, not by the name), and placement is **`documentation/specs/<feature-slug>/`**, not a repo-root `specs/`. The format research (Markdown body + YAML frontmatter, no JSON body, validator hard on shape and soft on content) stands and is inherited by both definitions.

Companion to [`ai-transition-levels-and-zones.md`](../ai-transition-levels-and-zones.md), which defines the levels. This doc captures the research and design decisions for the spec layer that turns the planned L3 workflow into a concrete, validatable format.

## Goal

Move from L2 (D101 → code) to L3 (D101 → spec → code). At L3, the spec is the agent's executable contract — small enough that an agent can build it without asking a human, structured enough to validate mechanically, and committed so the contract is auditable.

The user's working definition: *"A spec is a small task we are able to give to an agent where it can build it without asking any human. A single D101 often produces multiple specs."*

## Research synthesis (MinimumCD agentic-CD model)

Primary sources: [first-class artifacts](https://beyond.minimumcd.org/docs/agentic-cd/specification/first-class-artifacts/), [agent-assisted specification](https://beyond.minimumcd.org/docs/agentic-cd/specification/agent-assisted-specification/).

### Five mandatory artifacts (authority order, highest first)

1. **Intent** — hypothesis: *"We believe [change] will result in [outcome] because [reason]."* Problem statement, no how-to.
2. **User-Facing Behavior** — BDD scenarios in Gherkin (Given-When-Then). Observable outcomes.
3. **Feature Description (Constraint Architecture)** — Musts / Must Nots / Preferences / Escalation Triggers.
4. **Acceptance Criteria** — done definition + evaluation design (test cases with known-good outputs).
5. **System Constraints** — security, perf budgets, architectural rules.

**Conflict rule.** *"When an agent detects a conflict between artifacts, it cannot resolve that conflict by modifying the artifact it does not own."* Agent halts and escalates.

**Pipeline-input claim.** *"These artifacts are pipeline inputs, not reference documents."* They gate progression; malformed specs don't run.

### Grain rule (canonical)

> "You specify the next single unit of work. One thin vertical slice of functionality — a single scenario, a single behavior."

> "If your specification effort for a single change takes more than 15 minutes, the change is too large. Split it."

### Authoring loop

Human drafts → agent critiques → human decides → agent refines. Per-stage validation + set-level consistency validation before implementation begins. *"If the review agent identifies issues, resolve them before generating any test code or implementation."*

## Industry landscape

| Tool | Spec format | Notes |
|---|---|---|
| GitHub spec-kit | Markdown templates + slash commands | Body is MD; integration plugins for TOML/YAML/Skills |
| AWS Kiro | Three MD files per feature: `requirements.md` (EARS notation) + `design.md` + `tasks.md` | EARS = "WHEN [trigger] THE SYSTEM SHALL [behavior]" |
| Anthropic Skills (`SKILL.md`) | MD body + YAML frontmatter | Same pattern |
| MinimumCD examples | MD with Gherkin code-fences | Implicit machine-parseable |

**Convergence.** Everyone serious uses **markdown body + YAML frontmatter**. Nobody uses JSON for the spec body.

## Why not JSON (for the body)

1. **Humans review specs before agents run them.** Even at L3 the reviewer is in the loop on the spec gate. JSON is a hostile review format — quoting/escaping noise drowns the content.
2. **Gherkin doesn't live in JSON.** Given-When-Then is already structured natural language designed to be both parsed and read. Encoding it as JSON arrays loses readability without adding precision a Gherkin parser doesn't already give.
3. **Validation doesn't require JSON.** YAML frontmatter validated by JSON Schema + a small markdown linter blocks the same defects with no readability cost.

## Locked decisions

| Decision | Choice |
|---|---|
| **Grain** | Vertical slice, ~PR-sized, ~30 min to draft. Split if larger. |
| **Placement** | `specs/<feature>/<NNN>-<slug>.md` at repo root (not under `documentation/`). |
| **Validator authority** | Hard on shape, soft on content. Local pre-commit hook running the same rules as CI. |

### What that pins down

- Specs live *outside* `documentation/` — they're agent inputs, not docs. Top-level peer to `src/`, `infrastructure/`, etc. Matches Kiro (`.kiro/specs/`) and spec-kit (`specs/`) conventions.
- Per-feature folder; counter resets at 001 inside each feature (`specs/permissions/001-...`, `specs/permissions/002-...`).
- Validator **rejects**: malformed frontmatter, missing required H2 sections, unparseable Gherkin, broken D101/file links, missing acceptance criteria.
- Validator **does not judge**: whether the hypothesis is sensible, whether the ACs are faithful — that's the reviewer.

### What was rejected and why

- **`S101-*` family naming.** Inherits wrong shape — readers assume same lifecycle as `D101-*` (long-lived, maintained doc). Specs are short-lived agent inputs.
- **JSON body.** Hostile to human review; loses Gherkin readability; doesn't help validation.
- **One AC per spec.** AC build-cost varies too widely to be a useful sizing axis.
- **One spec per D101.** That's just L2 in disguise — loses every benefit of the spec layer.

## Sketch of the format (synthetic example)

````markdown
---
spec_id: PERM-014
d101: features/D101-permissions.md   # superseded 2026-10-02: the S101 header is design: {ref, version}
status: draft        # draft | ready | implemented | superseded
slice: "Add 'reefer:export' permission to Operator role"
estimated_minutes: 90
authority_overrides: []
---

# Spec — Add `reefer:export` to Operator role

## Intent
**Hypothesis.** We believe adding `reefer:export` to the Operator role
will let support staff export their own customer's data without ops
escalations, because the current escalation rate is ~12/week.

## User-Facing Behavior
```gherkin
Scenario: Operator exports a reefer list
  Given a user in role "Operator" on account A
  When they request POST /reefers/export
  Then the response is 200 with a CSV body
  And the CSV contains only account A's reefers
```

## Constraints
**Musts**
- Permission check uses `IPermissionEvaluator` (no inline role checks).
- Audit log entry written via `IAuditLogger`.

**Must Nots**
- Do not bypass `AccountFilteredAdxQueryProvider`.

**Preferences**
- Reuse existing CSV writer at `src/.../CsvExportWriter.cs`.

**Escalation Triggers**
- If existing CSV writer doesn't support streaming → stop, escalate.

## Acceptance Criteria
- AC1: Unit test for `PermissionEvaluator` with Operator + `reefer:export` returns allow.
- AC2: Integration test exporting reefers cross-account returns 403.
- AC3: Audit log entry verified in test against `IAuditLogger` mock.

## System Constraints
- p95 response time < 800ms for ≤10k reefers.
- No new NuGet dependencies.

## References
- D101: `features/D101-permissions.md` §4.3, §6
- Code: `src/shared/.../PermissionEvaluator.cs`
- Convention: `conventions/dotnet/service-pattern.md`
````

## Open decisions

1. **Lifecycle states.** Probably `draft` → `ready` → `implemented` → `superseded`. Is there an `in-progress` state? Who transitions each step — agent or human?
2. **Validator implementation language.** PowerShell (matches Windows shell), Node (matches Angular tooling already in repo), Python, or .NET console. Affects where the script lives and how the pre-commit hook invokes it.
3. **D101 reference precision.** Just file path, or path + section anchor (`features/D101-permissions.md#4-3`)? Latter requires stable, lint-checked section anchors in D101s.
4. **"Small enough" enforcement.** Validator measures (line count? scenario count?) or human judgment with a guardrail note in `specs/README.md`?
5. **Worked example before format-freeze.** Reverse-spec one slice of an existing feature first (e.g., a small permissions change), or lock the format and discover problems on the first real spec.

## Next step

Draft `specs/README.md` defining:

- The format (frontmatter schema, required H2 sections, Gherkin requirement)
- The lifecycle states and who transitions each step
- What the validator blocks vs warns on
- An inline worked example

Iterate that one doc to gap-free first, the way you'd iterate a D101. Validator script and first real spec are downstream of it. This is the "format for the format" — the contract that makes the spec layer earn its existence.

## Cross-cutting notes (clean-up backlog)

These already exist in the tree and will need revisiting once the format lands:

- `documentation/README.md` declares an `S101` family in its naming table. The name predates this design conversation; will move to the new `specs/<feature>/<NNN>-<slug>.md` placement once `specs/README.md` is ratified.
- `documentation/conventions/README.md` references "per-feature implementation spec (`S101-*-spec.md`)" in the same way.
- Memory entry `project_l2_to_l3_workflow.md` uses "S101" vocabulary. Update only after the format is ratified, not before.

## Sources

- [Specifications: First-Class Artifacts (MinimumCD)](https://beyond.minimumcd.org/docs/agentic-cd/specification/first-class-artifacts/)
- [Agent-Assisted Specification (MinimumCD)](https://beyond.minimumcd.org/docs/agentic-cd/specification/agent-assisted-specification/)
- [Specification overview (MinimumCD)](https://beyond.minimumcd.org/docs/agentic-cd/specification/)
- [Spec-driven development: Using Markdown as a programming language (GitHub Blog)](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-using-markdown-as-a-programming-language-when-building-with-ai/)
- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Kiro Specs documentation](https://kiro.dev/docs/specs/)
- [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/)
