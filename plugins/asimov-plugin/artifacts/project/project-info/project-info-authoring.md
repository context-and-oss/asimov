# Project info authoring

*The authoring method of the project info, beside its definition and template. `asimov-project` reads it by path at every write, and `asimov-init` when a repo has no project info yet; both follow it as written. A file, not a skill: nothing is substituted in it, so a sibling is named by its file name and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

You turn what was said into one change and hand it to the script. The script renders the page from the template, reads it back and checks that it says what was intended; you decide only what the change is. You are the only writer of the project info: nothing else writes `project/info.html`. The page is the one file: there is no source beside it (PI1), and a copy in another repository is made by copying it, never by editing it (PI2).

## Read first

Load with the file-read tool. Both files sit beside this file, in the folder you read it from; never a relative path in a tool call, since the working directory is the product repo. If file 1 cannot be read, stop and report the path.

1. **The definition**: the fields, the areas table, the rules PI1–PI6, the bar.

   ```
   project-info-definition.md — beside this file
   ```

2. **The template**, only where no PowerShell runs (the fallback below): its leading comment names every element the page holds and which are read back.

   ```
   project-info-template.html — beside this file
   ```

## The script

The script is `scripts/project-info.ps1` beside this file; a command line names it absolute, under `<plugin-root>`, the plugin root the caller derived:

```
pwsh -NoProfile -File "<plugin-root>/artifacts/project/project-info/scripts/project-info.ps1" -Path project/info.html <action>
```

(`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell.) One action per call: `-Read`, `-Apply -Change <file>`, `-Render`; `-Repo <name>` when the repository's name is not what the git remote says. Exit codes: 0 done, 1 refused by a rule (the rule on stdout, nothing written), 2 an input could not be read. Relay the line the script prints; never reword a refusal into a success.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `said` | What the person said, as they said it. Required for a write. |
| `verb` | `create` (no page yet), `change` (a page exists), `render` (the template changed; keep every value), or `read` (step 1 alone, the answer returned before the caller asks anything). |
| `confirmed` | The change as the person confirmed or corrected it, on the second call. [none on the first] |

## The method

1. **Read.** `-Read`. With `present: false`, only `create` can write. With problems listed, return *the page does not read in full* with the problems and stop: a hand-damaged page is repaired by the person, never guessed at. With `read`, return the model here and stop.
2. **Build the change** from `said`, the members of the change file the script's help lists:
   - **create**: `name`, `lede`, `lang`, `fields` (Project number, Customer, then the people by role, "" for not set), `areas` (in order, each with its repository or "" for not decided), `shared` when given.
   - **change**: only the members that change. An area list is always given whole (the order is part of the record); a renamed area keeps its row.
   - **render**: no change file; run `-Render` and return its line.
3. **Find what is missing**, and return it instead of guessing:
   - no name or no one line: return which (PI 3.1);
   - no area: return that at least one is needed, and that for a product spanning several systems the areas are its systems (PI 3.2);
   - an area with no repository: it is written as "not decided"; say so in the summary rather than ask;
   - no area whose repository is this one: return that the page must mark what this repository holds (PI4), with the repository's name as the script sees it (the `repo` member of `-Read`);
   - a description, a stack, a link or a status offered for an area: return that the page carries none of these (PI6); the area's architecture document says what it is.
4. **Say what will be stored.** Return the change as it will be stored, two tables and the lines, for the caller to confirm or correct; a correction replaces your text as written.
5. **Write**, only with `confirmed`: put the change in one JSON file in the system's temp folder (never in the repo), written as UTF-8 without a byte-order mark (use the file-write tool, not a shell redirect), run `-Apply -Change <file>`, delete the file, and return the script's line and exit code.

## The rules the script implements

The script is the method; these are its specification and the fallback where it cannot run.

- **Read.** The page is the record. Read only what the template's leading comment names: `html[lang]`, the `h1`, `p.lead`, the rows of `table.kv` (field, value; "not set" is empty), the rows of `table.areas` (area, repository; a `.this` mark means this repository), `p.shared`. Never read the links, the marks' styling, the headings.
- **Apply.** A member given replaces, a member absent keeps. Language is rendered from `lang`, never from a field. An area is held here when its repository equals the repository's name, ignoring case, spaces and hyphens (PI3, PI4); the mark and the link to the area's architecture document (`documentation/D100-<Area>-*`) are rendered from that. The landscape link is the `D100-*` whose name holds no area.
- **Check.** Render the whole page from the template to `info.html.new` beside the page, read it back and compare name, lede, language, fields and areas with the intended change (never bytes); refuse a page that leaves a placeholder or that reads back differently; on a pass, replace the page by one rename; on a refusal, delete the `.new`.
- **Refuse** a change with no name, no one line, no area, an unnamed area, two areas of one name, or no area held here.

## Where no PowerShell runs

When neither `pwsh` nor `powershell` runs, say so in one line and apply the rules above yourself: read the page by the template's comment, build the new page whole from the template (never patch it in place), write it to `info.html.new`, read it back and check it as the rules say, and rename it into place. End your return with *No script ran the check; the page was written by the rules alone.* so the caller says it plainly.

## Never

- **Call another skill**, or ask the person a question yourself: what is missing goes back to the caller.
- **Write** any file but the change file in the temp folder, and the page only through the script or, without PowerShell, through the fallback's `.new` and rename.
- **Add** a description, a stack, a status or a date to the page, under any wording (PI5, PI6).
- **Edit a copy** of the page in another repository: a copy is replaced by copying the canonical page.

## Used by

- `asimov-project`, the project info's section: every write.
- `asimov-init`: when a repo has no `project/info.html`, the first target of its plan.
- `artifact-site-authoring` reads the page; it never writes it.
- By hand: "write the project info", "add an area", "re-render the project info".
