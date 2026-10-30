---
name: artifact-risk-log-authoring
description: The only writer of the risk log, project/risk-log.html — turn what a person said about the engagement's risks into one change file (register, change, decide a state, hand over, review, opt out, repair), in the project's language, with the reason and decider the state needs, and hand it to the risk-log script, which reads, checks and writes the page. Use inside asimov-project for every risk-log write, and by hand when asked to "add a risk to the register", "set RISK-004 to Accepted", "repair the risk log". Returns what is missing to its caller instead of asking; never edits the page in place, never calls another skill.
---

# Risk log authoring

You turn what was said into one change and hand it to the script. The script reads the page, applies the change, checks the result against what the page held and writes it; you decide only what the change is. You are the only writer of the register: nothing else writes `project/risk-log.html`.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-risk-log-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/risk-log-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2).

1. **The definition**: the fields, the five states and what each requires, the rules RL1–RL17, the bar.

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/project/risk-log/risk-log-definition.md
   ```

2. **The template**, only where no PowerShell runs (the fallback below): its leading comment names every element and attribute the page holds.

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/project/risk-log/risk-log-template.html
   ```

## The script

```
pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/skills/artifact-risk-log-authoring/scripts/risk-log.ps1" -Path project/risk-log.html <action>
```

(`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell; in Codex `<plugin-root>` replaces the variable.) One action per call: `-Read` (with `-Area <text>` to learn the areas nearly the same), `-View`, `-Apply -Change <file>`, `-Repair`, `-Finish`; `-By <name>` when the caller passes a person. Exit codes: 0 done, 1 refused by a rule (the rule on stdout, nothing written), 2 an input could not be read, 3 no person (`git config user.name` unset and no `-By`). Relay the line the script prints; never reword a refusal into a success.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `said` | What the person said, as they said it. Required. |
| `verb` | add · change · state · handover · review · optout · repair, as the caller read it; or `finish`, which the caller sends first when a `risk-log.html.new` is left beside the page; or `read`, which runs step 1 alone and returns its answer, before the caller asks anything. |
| `person` | The name to pass as `-By`, when the caller has asked for it (after an exit 3). [none: the script uses git] |
| `confirmed` | The change as the person confirmed or corrected it, on the second call. [none on the first] |

## The method

0. **Finish**, when the verb is `finish`: run `-Finish` (with `-By` when given) and return what it printed (the lines the leftover adds and removes, then whether it was put in place or deleted) and its exit code; exit 3 goes back to the caller as in step 5. Nothing else in this run until the caller sends the next verb.
1. **Read.** `-Read`. With `register: none`, only `add` and `optout` can write (the first write names the language). With problems listed, return *repair needed* with the problems and stop: no verb but `repair` writes to a register that does not read in full (RL11). An identifier held twice in the `risks` list is no problem for a write, which renumbers it first (RL4), but it is for a review, which never renumbers: for `review` (and for `read`, so the caller knows before the review question) return the identifier held twice and that the repair renumbers it. With `read`, return the answer here and stop.
2. **Build the change** from `said`, one verb, the fields of the change file the script's help lists:
   - **add**: name, owner, impact, probability; area, description, mitigation when given; `language` on the first write only.
   - **change**: `target` and only the fields that change.
   - **state**: `target` and `state` `{ to, reason, decider }`.
   - **handover**: `target` (the leaving owner) and `to` (the person taking over).
   - **review**: `with` (who took part), possibly empty.
   - **optout**: `opt-out` `{ reason: elsewhere | not-worked, where, decider }`, `language` on the first write.
   - **repair**: the proposal `-Repair` returned, with every asked value given (see *Repair*).
3. **Find what is missing**, and return it instead of guessing:
   - an owner, a decider or a successor given as a role (*the project lead*, *the PM*, *the team*, *the customer*) is no person: return *a person's name is needed for <field>* (RL1);
   - a required field, a reason, a decider, a mitigation for Mitigated, a place for *handled elsewhere*: return which;
   - a score given (*score it 15*): return that impact and probability are needed instead, never a score (RL2);
   - an area: `-Read -Area <area>`; when an area in use is nearly the same, return the question *Did you mean <area>?* for the caller to ask once, and take the answer as given (RL13);
   - a request to delete or remove a risk: build nothing, return resolving with a reason as the way a risk leaves the open view.
4. **The project's language.** Read it from the page (`lang`), or on the first write from the caller. Free text the person wrote in another language (name, description, mitigation, reasons) is translated into the project's language; names of people and systems are never translated. Return the change *as it will be stored*, translation included, for the caller to confirm or correct; a correction replaces your text as written (RL16).
5. **Write**, only with `confirmed`: put the change in one JSON file in the system's temp folder (never in the repo), written as UTF-8 without a byte-order mark (the script reads it so; a shell redirect on Windows PowerShell 5.1 would not write it so, so use the file-write tool), run `-Apply -Change <file>` with `-By` when given, delete the file, and return the script's line and exit code. Exit 3 goes back to the caller, which asks for the name once and calls you again with `person`.

## Repair

`-Repair` returns `{ problems, changes }`: each change has `key`, `target`, `field`, `before`, `after`, `ask` and a `note`. Return it to the caller as one line per change, *before → after*, with every `ask: true` change as a question (its note says what it needs; a merge's question shows both sides' values). On the confirmed answers, set each asked change's `after`, and apply the change file `{ "verb": "repair", "proposal": <the proposal> }`. A repair never removes or rewrites a history line: a damaged line is restored from what is left of it, and only what the page no longer holds is asked.

## The rules the script implements

The script is the method; these are its specification and the fallback where it cannot run.

- **Read.** The page is the record. Read only the attributes and lists the template's leading comment names: on `html` the language; on `body` the register's kind and last-updated date; each `article.risk` with its identifier, state, impact, probability, owner, area, created and changed, its name, description, mitigation and history list; the register's history list; on an opt-out page the `section.opt-out`. Never read the score, the summary table, the counts or the group headings. A page holding git conflict markers, a field missing or out of range, a history line with no person, or a damaged line is a problem, and a problem means a repair before any other write.
- **Apply.** Duplicate identifiers are renumbered first (RL4); a new risk takes the highest identifier plus one (RL3); a state change sets only the state, the changed date and a history line, a field change only the fields, the changed date and one history line naming each field with its old and new value; every write adds one line to the register's history and moves its last-updated date to today; a review moves only the register's date and is refused while an identifier is held twice.
- **Check.** Render the whole page from the template to `risk-log.html.new` beside the page, read it back and compare the parsed data with the intended change (never bytes); refuse a page that drops a risk or a history line the page held, holds an identifier twice, has a history line with no person, or leaves a placeholder; on a pass, replace the page by one rename; on any refusal, delete the `.new`.
- **Areas nearly the same.** Compare whole texts after ignoring case, spaces, hyphens and punctuation: equal, or one letter apart when both are four letters or more. Never word by word.

## Where no PowerShell runs

When neither `pwsh` nor `powershell` runs, say so in one line, and apply the rules above yourself: read the page by the template's comment, build the new page whole from the template (never patch the page in place), write it to `risk-log.html.new`, read it back and check it as the rules say, and rename it into place. A `finish` the same way: read the leftover `.new` and the page, say what the leftover adds and removes, check it as the rules say, and either rename it into place with a history line of kind `finish` or delete it and say so. End your return with *No script ran the check; the page was written by the rules alone.* so the caller says it plainly.

## Never

- **Call another skill**, or ask the person a question yourself: what is missing goes back to the caller.
- **Write** any file but the change file in the temp folder, and the page only through the script or, without PowerShell, through the fallback's `.new` and rename.
- **Delete a risk** or remove a history line, under any wording.
- **Name a product entity** in your own text; the register's content is the engagement's.

## Used by

- `asimov-project`, the risk log's section: every register write.
- By hand: "add a risk to the register", "set RISK-004 to Accepted, decided by …", "repair the risk log".
