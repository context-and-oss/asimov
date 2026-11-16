# Risk log view

*The view of the risk log, beside its definition and template. `asimov-project` reads it by path at every view of the register and follows it as written. A file, not a skill: nothing is substituted in it, so a sibling is named by its file name and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

The page is for the repo and the customer; the chat sees the register through this view. One layout, every time, so the review reads it once and learns it. The view says nothing the page does not hold and carries no verdict: whatever the caller says about the register comes after it, on a line of its own.

## The call

The script is `scripts/risk-log.ps1` beside this file; a command line names it absolute, under `<plugin-root>`, the plugin root the caller derived (never a relative path in a tool call: the working directory is the product repo):

```
pwsh -NoProfile -File "<plugin-root>/artifacts/project/risk-log/scripts/risk-log.ps1" -Path project/risk-log.html -View
```

(`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell.) Print what it prints, in a fenced block so the columns hold, and nothing before or after it. Exit 1 means the register cannot be read in full: relay its line, which names the repair, and stop. With no page, the script says there is neither a register nor an opt-out; relay that.

## The layout

The script holds the layout; this is its specification and the fallback where no PowerShell runs.

```
Risk log · project/risk-log.html
Updated <date> · <n> risks
<n> Active · <n> Mitigated · <n> Accepted · <n> Occurred · <n> Resolved

<State>
  RISK-NNN  <score>  <name>
                <owner> · <area, or "area none written"> · I<impact> P<probability> · changed <date>
                <description, wrapped at this column, or "Description: none written">
     Mitigation <mitigation, wrapped at the text column, or "none written">
  ──────────────────────────────────────────────────────────────────────────────

Resolved (<n>)
```

- **80 columns**, never wider: names and texts wrap at column 16, a word longer than a line is cut.
- **The order** is RL12: Active, Mitigated, Accepted, Occurred, then Resolved as a count only; within a state by score, highest first, then by identifier. A state with no risk is left out.
- **No score** when impact or probability is missing; never 0.
- **Labels** in the view's fixed English; a risk's content as it is kept, in the project's language.
- **An opt-out page** prints the same first line (*Risk log · project/risk-log.html*), then *No risk register kept here.*, an empty line, the reason with its place, and *Decided by <person> on <date>.*

Where no PowerShell runs, say so in one line, read the page by the template's leading comment (`risk-log-template.html`, beside this file), and print this layout yourself, exactly.

## Never

- **Write** anything: not the page, not the review date. A view is not a review; only a confirmed review, written through `risk-log-authoring.md` beside this file, moves the register's date.
- **Judge**: no advice, warning or ranking beyond the order, no line about a high score or a missing mitigation.
- **Change the layout**: a register that does not fit it is a finding for the maintainer, not a reason to improvise.

## Used by

- `asimov-project`, the risk log's section: the review and every view after a write.
- By hand: "show the risk log".
