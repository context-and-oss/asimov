---
artifact: risk-log
maturity: assess
since: 2026-10-30
---

# Definition of the risk log

The register of one engagement's risks: what could go wrong, who owns each risk, how likely and how bad it is, and what is done about it. One page per product repo, `project/risk-log.html`, beside `documentation/` and `specs/`. It is the first artifact of the Project frame (D100 §3), the engagement the stages run inside; it hands nothing to a next stage and so has no stage contract.

Read by agents: `asimov-project` through the skills `artifact-risk-log-authoring`, the only writer, and `artifact-risk-log-view`, which prints it. Read by people: the team in the repo, the customer the page is shared with, and the weekly review that reads it top-down in the chat.

Design: `documentation/features/D101-project-management-risk.html`.

---

## 1. What the register is for

- **Keep risks visible.** Every risk the engagement knows of, in one place, ranked so the worst are read first, and reviewed weekly while the engagement runs.
- **Record decisions.** Every state beyond Active is a person's decision with a reason; the register never shows a risk as dealt with that nobody decided.
- **Carry what is left.** At closure the risks not Resolved transfer with the solution, through the closure report.

## 2. The bar: kept

> **A register is kept when it reads back in full, every risk on it has its four required fields, every state beyond Active carries the reason and the person its state requires, every line of its history names a date and a person, and its last-updated date says when it was last written or read with care at a confirmed review.**

A register that is written once and never reopened is not kept, however complete it looked on the day: it creates the impression of management without the management (the discipline's anti-pattern *The register that is written once*).

## 3. Required content

### 3.1 A risk

| Field | Required | What it holds |
|---|---|---|
| Identifier | yes, given by the tool | `RISK-NNN`, the highest in the register plus one (RL3) |
| Name | yes | The event that could happen, in a few words |
| Owner | yes | A named person, never a role (RL1) |
| Impact | yes | A whole number from 1 to 5 |
| Probability | yes | A whole number from 1 to 5 |
| Area | no | Free text, the person's own word (RL13) |
| Description | no | What the risk is, as the person tells it |
| Mitigation | no | The plan that lowers impact or probability; required for Mitigated (RL6) |
| Score | derived | Impact times probability, rendered and never given or read back (RL2) |
| State | yes, Active when registered | One of the five below |
| Created, changed | yes, set by the tool | Created once; changed on anything that touches the risk (RL8) |
| History | yes, by the tool | One dated line per change, naming the person (RL10) |

### 3.2 The five states

| State | Means | Requires |
|---|---|---|
| Active | Open and being watched | Nothing beyond the fields; a reason when set back from another state |
| Mitigated | The plan in its mitigation is in place | A written mitigation and a reason (RL6) |
| Accepted | The team lives with it, by decision | A reason and the named person who decided (RL7) |
| Occurred | It happened and is handled elsewhere now | A reason saying what happened and where it is handled (RL17) |
| Resolved | It no longer threatens the engagement | A reason |

Any state can be set from any other, under the same identifier, each with a reason (RL5). Active to Active is no change. A risk is never deleted: resolving is how a risk leaves the open view, and the entry and its history stay.

### 3.3 The register

- **The language**, asked when the register or an opt-out is first written, kept on the page (`lang`); content is kept in it (RL16).
- **The last-updated date**, moved on every write and every confirmed review (RL9).
- **The register's own history**, one line per write, review, repair or finish, newest first, each naming the person; a review line may name who took part.
- **The view of the scoring**: what 1 and 5 mean on both axes, folded, and the sentence that the score ranks risks and does not decide what to do.
- **Or an opt-out** in the register's place: *No risk register kept here*, with one of two reasons (`elsewhere`, with the place; `not-worked`), the person who decided and the date (RL15). The first risk registered replaces it, and the register's first new history line names the opt-out it replaced.

### 3.4 The page is the record

`project/risk-log.html` is the register; there is no second store. What the tool reads back is only the attributes and lists the template names (`plugins/asimov-plugin/artifacts/project/risk-log/risk-log-template.html`, its leading comment); everything derived (the score, the summary table, the counts, the group headings) is rendered on every write and never read, so a hand edit to it is overwritten by the next write. A hand edit to a field or a history line is a repair (RL11). The page carries no script and links the documentation site's shared chrome.

The script that reads, renders, checks and writes the page is `plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1`; its interface is its own help.

## 4. Rules

Each with the adjacent case it does not cover. The full examples are the design's (D101 §4.4).

- **RL1 · Four required fields.** A risk is written only with a name, an owner who is a named person, an impact and a probability. *Not covered:* "the project lead" as owner is no person; the name is asked for.
- **RL2 · The score is computed.** The score shown is impact times probability. *Not covered:* "score it 15" is declined, and impact and probability are asked for instead; a risk with no impact shows no score, not 0.
- **RL3 · Identifiers continue the series.** A new risk takes the highest identifier plus one, resolved risks counted. *Not covered:* a gap is never closed, and a resolved risk's identifier is never reused.
- **RL4 · Duplicates are renumbered.** Two risks sharing an identifier (after a merge): the next write gives the later-created one the next identifier, with its history and a *Renumbered from* line, before its own change; created the same day, the one further down the page. *Not covered:* a confirmed review never renumbers; it is refused and points to the repair, so a review adds no line to a risk (RL10). Renumbering moves the renumbered risk's changed date (RL8).
- **RL5 · Any state from any state, each with a reason.** *Not covered:* Active to Active writes nothing.
- **RL6 · Mitigated needs a written mitigation.** *Not covered:* the mitigation of a Mitigated risk cannot be emptied; the risk is first set back to Active.
- **RL7 · Accepted needs a reason and a decider.** *Not covered:* "we live with it" with no name is not set.
- **RL8 · A risk's dates.** Created is set once; changed moves on anything that touches the risk. *Not covered:* a confirmed review moves no risk's changed date.
- **RL9 · The register's date.** Last-updated moves on every write and every confirmed review, each with a history line naming the person. *Not covered:* a review declined moves nothing.
- **RL10 · History only grows.** Every change adds a dated line naming the person; no action removes or rewrites a line. *Not covered:* a wrong line is corrected by a new line, never tidied; a confirmed review adds a line to the register's history and none to a risk's.
- **RL11 · An unreadable register is repaired, never overwritten.** The tool proposes each change as before and after and writes it only on the person's go, losing nothing. *Not covered:* a register that reads in full gets no repair. A merge's two sides (git's `:2:` and `:3:`) are joined by identifier: a risk on one side is kept, the same risk on both is one risk whose differing fields are asked, two risks under one identifier stay two and are renumbered, and every history line of either side is kept.
- **RL12 · The order.** By state (Active, Mitigated, Accepted, Occurred, Resolved), then by score, highest first, then by identifier. *Not covered:* the order never follows dates.
- **RL13 · An area is the person's word.** The tool never proposes one; only an area nearly the same as one in use (equal after ignoring case, spaces, hyphens and punctuation, or one letter apart at four letters or more) is asked about once. *Not covered:* no area, or one unlike any in use, asks nothing.
- **RL14 · Closure.** When the engagement closes, the register is reviewed first, the risks no longer relevant are resolved, and every risk not Resolved carries into the closure report. *Not covered:* a Resolved risk is not carried.
- **RL15 · An opt-out needs its reason and decider**, and for *handled elsewhere* the place. *Not covered:* an opt-out never replaces a register that holds risks.
- **RL16 · Content in the project's language.** Text told in another language is shown as it will be stored and written only once confirmed or corrected; names of people and systems are never translated. *Not covered:* text written in the project's language is stored as written.
- **RL17 · Occurred needs what happened and where it is handled.** *Not covered:* a risk that did not happen because the mitigation worked is Resolved, not Occurred.

The append-only rules, as for every record the toolkit keeps:

- **Append, never rewrite.** Fields and states change; history only grows.
- **Write through the check.** Every write goes to `risk-log.html.new` beside the page, is read back and checked against what the page held, and replaces the page by one rename; a failed check deletes the `.new`. A `.new` left by an interrupted write is finished or discarded before anything else.
- **One writer.** Only `artifact-risk-log-authoring`, through its script, writes the page.

## 5. Where the register departs from the discipline

The delivery model's *Risk management* discipline (`plugins/asimov-plugin/processes/disciplines/risk-management.md`) describes a risk register; the corpus is not edited here, so the departures are recorded instead:

- **Two more states.** The discipline's responses are avoid, reduce or accept. The register keeps *Accepted* as a decision with a decider, and adds *Occurred* for a risk that happened and is now handled as an issue, and *Mitigated* for a reduction in place.
- **No fixed set of areas.** The register's area is the person's own word; it never proposes a category.
- **The score as a rank only.** The discipline derives the score as likelihood times impact; the register does too, and states on the page that the score ranks risks and does not decide what to do.
- **The history in place of a comment field.** The discipline adds a comment field for how a risk developed; the register keeps that as its append-only history.

## 6. Anti-patterns

- **The register written once.** Opened at kick-off, never reviewed: not kept, however full.
- **A role as owner.** "The project lead" owns nothing; a person does.
- **Accepting by default.** A risk that sits Active for months is not accepted; Accepted is a decision with a name.
- **A score given by hand.** The score is derived; a number typed in is a judgement disguised as arithmetic.
- **Tidying the history.** A line that was wrong is corrected by a new one.

## 7. Placement and naming

The page lands at `project/risk-log.html` in the product repo, one per repo; its interrupted write at `project/risk-log.html.new`, which the `.gitignore` block both init entry points write (`project/*.new`) keeps out of git. The `project/` folder is the Project frame's place in a product repo, as `asimov-project` and D100 §3 and §5 name it. The definition and template live at `plugins/asimov-plugin/artifacts/project/risk-log/`.
