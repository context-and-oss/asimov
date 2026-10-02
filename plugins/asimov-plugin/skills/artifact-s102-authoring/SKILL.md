---
name: artifact-s102-authoring
description: How to write one S102 task spec (documentation/specs/<slug>/S102-<slug>-NNN-<task>.md) for one builder role from one task entry in an S101 graph, or for a lone task from the board with no S101 — header copied from the graph, intent, files, interfaces by exact signature, behaviour as Gherkin, task-specific constraints, steps test first with the code inline where the task is transcription, runnable acceptance criteria, out of scope — so that a builder with no conversation history can build it. Use when asked to "write the S102 for task T003", "write a task spec for this ticket", "rewrite this S102 against these findings", or inside asimov-spec at every task. Writes one S102; never the S101, never another S102, never a placeholder.
---

# S102 authoring

One graph entry in, one task spec out. The S102 is the whole brief a fresh builder receives, so this skill writes for a reader who has nothing else open: no chat, no author, only the repo, the D101 and this file. It does not decide the cut (artifact-s101-authoring did), and it does not judge the result (artifact-s102-validation does, blind). A skill is a leaf: it reads artifacts and calls no other skill.

## Read first

Load with the file-read tool. `${CLAUDE_PLUGIN_ROOT}` is the plugin root; where the harness does not set it, resolve the same paths relative to this skill's folder (`../../artifacts/...`). If 1 or 2 cannot be read, stop and report the path.

1. **The S102 definition** — the bar (§2), the required content (§4), the rules (§5, above all *no placeholders* and *inherit, don't repeat*), the anti-patterns (§7), the checks the blind reader will ask (§8):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-definition.md
   ```

2. **The S102 template** — its leading comment holds the header rule, the values and what never goes in; its body is the shape you write:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-template.md
   ```

3. **The S101**: the task's entry in the frontmatter graph (role, tier, phase, depends_on, owns, produces, consumes, traces) and the body sections it inherits: §1 global constraints, §3 interfaces (the exact signatures), §4 review focus (a line pinned to this task becomes a scenario and a test here), §5 escalation routing.

4. **The D101 sections the entry traces to**: the requirement wording for the intent, the §6 contract for the shapes, the rule and its counter-example for the scenarios, the acceptance criterion the slice makes pass.

5. **The repo code the task links to**: every path in `owns` that exists (read the region you will change), every existing type the interfaces section links, the conventions for this stack (`documentation/conventions/<stack>/README.md` and what it lists) for the test command, the test naming and the commit style.

6. **For a lone task**: the ticket text the caller passes in place of the S101 and D101.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `s101` + `task` | Path of the S101 and the task id (`T003`). The normal case. |
| `ticket` + `brief` | For a lone task: the ticket id and its text. No S101, no D101; the S102 then carries its own global constraints and escalation route. |
| `findings` | On a rewrite: the validation report of the previous attempt. Address every Flag and Fail row; keep what cleared. [none] |

## Steps

1. **Header** from the graph entry, copied verbatim: `s101`, `task`, `title`, `traces`, `role`, `tier`, `depends_on`; `status: draft`, author, today's date. A lone task carries `ticket` instead of `s101` + `task`. Never change a copied field to make the body easier; a mismatch is a plan finding, reported to the caller.

2. **Intent.** One or two sentences in the D101's words: what this task delivers and why the feature needs it. The reason, not the recipe.

3. **Files.** The owned set, split into create / modify / test, exactly the graph entry's `owns`. A modify entry on a large file names the region. Every path exact and repo-relative; a path that neither exists nor is created here is a defect you fix before writing.

4. **Interfaces.** Consumes: every name from the entry's `consumes`, with the exact signature from the S101 §3 and the producing task id, or the path for existing code. Produces: every name from `produces`, signature fixed here as the S101 spells it. A consumed name the S101 does not spell is a plan gap: stop and report it (below).

5. **Behaviour.** One Gherkin scenario per behaviour, in fenced `gherkin` blocks, written from the D101 rule and the §6 contract; every rule with its counter-example as its own scenario. For a tester task, the scenarios are the slice's acceptance criterion made concrete at API level against the skeleton's public methods, end to end only where the conventions name a runner.

6. **Constraints.** Only what is specific to this task: musts, must nots, preferences by path, escalation triggers. The global constraints and the routing are inherited from the S101 by reference; a global constraint restated here is a finding. The three standing triggers (a file outside the owned set, a consumed name that does not resolve, a conflict with the D101, the conventions or a neighbour) are always listed, plus the task's own.

7. **Steps.** Test first, one action each: the failing test in full, the command that runs it and the failure to expect, the implementation, the command again, the commit. Where the task is transcription (tier `low`, or any step whose code you know exactly), the code is in the step, complete. Where the task needs judgement, the step says what to achieve and what to check. A step you cannot write for code the author could have written is a placeholder: do not write it (below).

8. **Acceptance criteria.** Numbered; each a test by name under a command, a command with its expected output, or a file with a named shape. Nothing a person has to eyeball.

9. **Out of scope.** The neighbouring task that owns the adjacent thing (by id), the follow-up the D101 deferred (by OOS number), the refactor that tempts. One line each.

10. **Write** `documentation/specs/<slug>/S102-<slug>-<NNN>-<task-slug>.md` from the template, `<NNN>` the task id's number, `<task-slug>` kebab-case from the title. On a rewrite, the same path, in place.

11. **Return** the path and, on a rewrite, one line per finding saying what changed for it.

## When you cannot write it

A step, a signature or a scenario you cannot write without guessing is not written. Do not save a file with a gap or a placeholder in it. Return instead:

```
cannot write <task id>: <what is missing>
  needs: <the D101 section, the S101 interface or the author decision that would settle it>
  source: D101 | S101 | repo
```

The caller treats a `source: D101` gap as a stop (the D101 is fixed first, not the S102) and a `source: S101` gap as a plan finding. Reporting the gap is the method; filling it from memory is the failure the blind validation exists to catch.

## Never

- **Paste existing code**: an enum, a schema, a column list, a type that is already in the repo. Link it by path.
- **Repeat a global constraint** or the escalation routing. The S101 has them; a lone task is the one exception.
- **Write a placeholder**: `TBD`, `TODO`, "handle edge cases", "add appropriate error handling", "similar to T002", a step that says what without how. Report the gap instead.
- **Touch the S101 or another S102.** A mismatch between the entry and what the body needs is reported, never patched on either side.
- **Validate** your own output or call any other skill.
- **Set a status other than `draft`**, or change a header field copied from the graph.
- **Widen the owned set.** A file the task turns out to need and the entry does not own is a plan finding, not an addition.
- **Bake a product entity into this skill.**

## Used by

- asimov-spec, step 05, once per task after the author's go, and again with `findings` after a failed blind validation or a plan-level finding.
- A lone task from the board, directly, followed by artifact-s102-validation by hand.
