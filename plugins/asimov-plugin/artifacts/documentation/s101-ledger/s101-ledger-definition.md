---
artifact: s101-ledger
maturity: assess
since: 2026-10-07
---

# Definition of the S101 ledger

The run state of one build: what `asimov-build` did with one `ready` S101, task by task and phase by phase, and what the person ruled when it stopped. It exists because the plan never changes under a build: the S101 and its S102s stay the text the person approved, and everything that happens while they are built is written here instead (`s101-implementation-plan-definition.md` §6: *plan ≠ ledger*).

Read by agents: `asimov-build` through the skill `artifact-s101-ledger`, which is the only writer. Read by people: the PR reviewer, who finds the verification and review of every phase in the PR, and the colleague who resumes a run. A person reads the body; an agent trusts the frontmatter.

Design: `documentation/features/D101-build-stage.html` §4.2, §6.4.

---

## 1. What the ledger is for

- **Resume.** A run that stopped, or died, continues from the ledger without rebuilding a task that is done (D101 R9). The frontmatter says where it stood; nothing else does.
- **Record.** Every attempt, every report from Powell and Baley, every ruling by the person, with who and when. The S101 never carries any of it (D101 R8, R10).
- **Evidence in the PR.** The ledger is committed with each phase, so the reviewer who opens the PR sees what was verified and reviewed, and by what (D100 Q5).

## 2. The bar: resumable

> **A ledger is resumable when a fresh run of `asimov-build`, reading only the ledger and the specs folder, continues exactly where the last run stopped, rebuilds nothing that passed, and refuses when the plan it was started from has changed.**

Three things make it so: the fingerprint of the approval it was started from, a status per phase and per task that is written before the next step begins, and a body that is only ever appended to.

## 3. Required content

### 3.1 Frontmatter

| Key | Value |
|---|---|
| `ledger` | `S101` |
| `slug` | the feature slug, as the S101's |
| `s101` | the plan's path |
| `fingerprint` | the S101's approval fingerprint when the run started (`s101-implementation-plan-definition.md` §6) |
| `started` | `{ by, date }` — the person who ran `asimov-build` first, from `git config user.name`, and the date |
| `phases` | one entry per phase of the plan, in the plan's order: `id`, `status`, `commit` (the hash once committed, else `none`), `go` (`{ by, date }` once given, else `none`), `tasks` |
| `phases[].tasks` | one entry per task of the phase: `id`, `status`, `attempts` (count), `agent` (the shell name of the last attempt), `model` (the model it ran on, or `session` in Codex) |

Phase statuses: `pending` → `building` → `built` → `passed` → `committed`; `discarded` from `building`, `built` or `passed` by a ruling. Task statuses are the D101 §4.3 lifecycle: `pending` → `running` → `built` → `done`; `failed` from `built`; `running` again from `failed` by a retry; `stopped` from `failed`.

### 3.2 Body

One `##` per phase, in order, opened when the phase starts building. Under it, in the order things happened:

- `### T<nnn> · attempt <k> · <agent> · <model>` — the builder's own summary and flags, verbatim as the role skill returned them.
- `### review` — Baley's report for the phase, verbatim: the resolved-target line and the three tables.
- `### verify` — Powell's report for the phase, verbatim: one row per done-when, one for the checkpoint.
- `### ruling · <YYYY-MM-DD> · <by>` — what the person chose at a stop (`resume`, `discard`, `stop`), and their note if any.
- `### commit · <hash>` — the go, by whom and when, and the files committed.

A phase with several review or verify rounds has several such headings; nothing is overwritten.

## 4. Rules

- **Append, never rewrite.** The frontmatter's statuses move; the body only grows. A ledger with a report removed is not the record.
- **Write before the next step.** A task's `running` is written before the agent is spawned, `built` before the next task starts, a phase's `passed` before the gate is shown. A dead run is then one step behind at most.
- **One ledger, one plan.** The ledger's `fingerprint` is the S101's approval fingerprint. A resume recomputes the S101's fingerprint; a mismatch refuses the run (D101 §4.6).
- **Committed with the phase.** The go's commit holds the phase's owned files and the ledger, nothing else. Between gos the ledger is a modified file in the working tree, like the phase's code.
- **Verbatim reports, words in chat.** The ledger holds the reports as the agents returned them; the chat shows one line each (D101 NF1). Nothing is summarised into the ledger.
- **No product entity in the toolkit.** The ledger in a product repo names the product's files and tests; this definition and the template never do (hard rule 7).

## 5. Anti-patterns

- **Run state in the plan.** A `status: built` on a task line of the S101, a commit hash in an S102. The plan is the approved text.
- **A ledger edited by hand.** The one allowed hand edit is deleting it, which abandons the run and its uncommitted phase (D101 §6.7).
- **A summary where the report belongs.** "Baley: 2 flags" in the body is not Baley's report; the PR reviewer needs the rows.
- **A resume that re-verifies committed phases.** Committed is committed; the commit is the evidence.

## 6. The checks

Run by `artifact-s101-ledger` before every resume; a Fail refuses the run.

| # | Check | Tests |
|---|---|---|
| L1 | Frontmatter parses as YAML and every key of §3.1 is present | Shape |
| L2 | `fingerprint` equals the S101's recomputed fingerprint | Same plan |
| L3 | Every phase and task id of the ledger exists in the S101's tree, and every task of the tree is in the ledger | Same tree |
| L4 | At most one phase is `building`, `built` or `passed`; every phase before it is `committed` or `discarded`; every phase after it is `pending` | One position |
| L5 | A `committed` phase has a commit hash that exists on the branch | Evidence |

## 7. Placement and naming

`documentation/specs/<feature-slug>/S101-<feature-slug>.ledger.md`, beside the plan it belongs to. The suffix form, not a new document code, because a ledger is run state and not a reviewed artifact; the same form as the gitignored `S101-<feature-slug>.review.md`, but committed. One ledger per plan; a plan built again after `done` starts from `draft` through `asimov-spec`, and the old ledger goes with the old plan in git.

The path is a lockstep literal with the specs folder (`CLAUDE.md` hard rule 9).
