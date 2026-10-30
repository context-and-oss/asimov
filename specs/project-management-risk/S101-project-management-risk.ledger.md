---
ledger: S101
slug: "project-management-risk"
s101: specs/project-management-risk/S101-project-management-risk.md
fingerprint: "1bb81caedb63"
started: { by: "SimonVilandt", date: "2026-10-29" }
phases:
  - id: P0
    status: committed
    commit: "e4f7b9b"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T001, status: done, attempts: 1, agent: human-in-session, model: session }
      - { id: T002, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P1
    status: committed
    commit: "44ebe61"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T003, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P2
    status: committed
    commit: "54cec5a"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T004, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P3
    status: committed
    commit: "578747d"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T005, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P4
    status: committed
    commit: "7631c2b"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T006, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P5
    status: committed
    commit: "1878c14"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T007, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P6
    status: committed
    commit: "e875695"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T008, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P7
    status: committed
    commit: "af92fd2"
    go: { by: "SimonVilandt", date: "2026-10-29" }
    tasks:
      - { id: T009, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P8
    status: committed
    commit: "8225e61"
    go: { by: "SimonVilandt", date: "2026-10-30" }
    tasks:
      - { id: T010, status: done, attempts: 3, agent: human-in-session, model: session }
  - id: P9
    status: committed
    commit: "6a384d3"
    go: { by: "SimonVilandt", date: "2026-10-30" }
    tasks:
      - { id: T011, status: done, attempts: 2, agent: human-in-session, model: session }
      - { id: T012, status: done, attempts: 3, agent: human-in-session, model: session }
      - { id: T013, status: done, attempts: 2, agent: human-in-session, model: session }
      - { id: T014, status: done, attempts: 3, agent: human-in-session, model: session }
  - id: P10
    status: passed
    commit: none
    go: none
    tasks:
      - { id: T015, status: done, attempts: 2, agent: human-in-session, model: session }
      - { id: T016, status: done, attempts: 1, agent: human-in-session, model: session }
---

# Ledger — project-management-risk

## P0 · Foundation

### T001 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T001 (human task, built in the session that directs the run)
- Created plugins/asimov-plugin/artifacts/project/risk-log/risk-log-template.html from the mockup's layout and class names: every D101 §6.4 element and attribute, both page forms (form:kept, form:opt-out), the folded scoring anchors with the 1/5 meanings and the score caveat, state counts, summary table with state groups, risks grouped Active/Mitigated/Accepted/Occurred with Resolved last and folded, ../documentation/_chrome.css linked, component styles in one inline <style>.
- Leading comment names every placeholder, every repeated block (BEGIN/END markers) and what is rendered only (score, summary, counts, group headings, labels).
- No script element, no event handler, no score in a data-* attribute (the comment avoids the literal tag so a rendered page that keeps it still has none).
- Done-when 1: True. Done-when 2: the folder is new and holds only the template.
gaps: 0 · flags: 1
- flag: the page's labels (Last updated, Summary, Mitigation, ...) are English text in the template; RL16 puts the stored content in the project language, but the template has no form for translated labels. Left to T003/T011 to decide.

### T002 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T002 (human task, built in the session that directs the run)
- Created risk-log.ps1: comment-based help with -Path, -Read, -Area, -View, -Apply, -Change (the change file's fields per D101 §6.4), -Repair, -Finish, -By, -PluginRoot and the four exit codes; -PluginRoot defaults to three folders above the script (S101 A7); exactly one action required (exit 2 otherwise); every action prints "not built yet" and exits 2. Pure ASCII, StrictMode 2.
- Created risk-log.Tests.ps1: Pester 5 scaffold, BeforeAll sets the script path, one empty Describe.
- Done-when 1 and 2: Pester 5.9.1 exits 0 on PowerShell 7.6.7 and 5.1. Done-when 3: Get-Help -Full prints every parameter, the exit codes and the change file's fields.
gaps: 0 · flags: 0

### review
(Baley's report, verbatim, as returned in the session; see the chat transcript of 2026-10-29. Summary of rows: Conventions 2 Pass, 1 Flag (no [Console]::OutputEncoding UTF-8 in risk-log.ps1); Correctness 2 Pass, 4 Flags (exit 2 used for usage and not-built; data-with on every register line though the comment says review only; no note that placeholder values are HTML-escaped; the risk block lives only inside state-group, the resolved group holds a comment); Against the spec 9 Pass, 2 Flags (T001 data-with for a review; T002 done-when 1 depends on pwsh finding Pester 5, an environment gap). No Fail.)

### review
(Verbatim report; the review entry above is a summary recorded by mistake.)

Conventions read: `CLAUDE.md` (repo root — stands in for `documentation/conventions/`, which this repo does not have); house style from `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` and `plugins/asimov-plugin/artifacts/documentation/site/site-template.html`. Also read: `_chrome.css`, the mockup `documentation/features/mockups/d101-project-management-risk/risk-log-page.html`, D101 §6.4–§6.8, S101 §1–§2.

Reviewing: HEAD (uncommitted, untracked) — 3 files, against S102 T001 and T002.

Checks I ran: the empty Pester file passes under Pester 5.9.1 on Windows PowerShell 5.1 (exit 0, 0 tests discovered) and on `pwsh` 7.6.7 when Pester 5.9.1 is imported by explicit path. Done-when 1 as written (`Import-Module Pester -MinimumVersion 5.0` on `pwsh`) fails on this machine because `pwsh` only sees Pester 3.4.0 — an environment issue, not a file defect. `Get-Help ... -Full` on `pwsh` prints all ten parameters, the four exit codes and the change-file fields. The script is pure ASCII.

## Conventions
| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1 (whole file) | Pass | `CLAUDE.md` hard rules + validate-s102.ps1 house style: pure ASCII, help block, `Set-StrictMode`, `$ErrorActionPreference = 'Stop'`, plugin-root default matches the three-folders-up form (S102 T002 §4, S101 A7). |
| risk-log-template.html (whole file) | Pass | Leading comment in the site-template.html style, double-brace placeholders, chrome linked as `../documentation/_chrome.css`, component styles in one inline `<style>`. |
| risk-log.ps1:60-72 | Flag | validate-s102.ps1 sets `[Console]::OutputEncoding` to UTF-8 (in a `try`); this skeleton does not, so later `-Read`/`-View` output of non-ASCII names will be mangled on 5.1. Out of P0 scope, but it makes the æ/ø/å requirement of T003 harder — best placed in this file now. (base judgment — matches house style in validate-s102.ps1) |

## Correctness & safety
| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1:79-86 | Pass | Zero actions, two actions and a single action all behave correctly on both shell editions (exit 2 with the message, or the "not built yet" line). |
| risk-log.ps1:81-86 | Flag | The skeleton returns exit 2 ("an input could not be read") for both a usage error and "not built yet"; neither is that meaning, and a skill reading exit 2 would show a misleading cause. Harmless in P0; the final script should keep one meaning per code. |
| risk-log.Tests.ps1:5-10 | Pass | Valid Pester 5 shape: `BeforeAll` at file level, empty `Describe`, 0 tests, no failed containers. `$script:RiskLog` is defined but unused, which is fine for a scaffold. |
| risk-log-template.html:157 | Flag | Every `register-line` carries `data-with="{{WITH}}"`, while the leading comment says "data-with only on a review line". Non-review lines would render an empty `data-with=""`, which a reader can't tell from a review with no participants. The comment should say to omit the attribute; this affects T003/T008. |
| risk-log-template.html:8-74 | Flag | The leading comment never says that placeholder values must be HTML-escaped, including inside `data-*` attributes (`data-owner="{{OWNER}}"`). T003's non-ASCII and quote cases depend on it. (uncertain whether the writer script will handle it regardless) |
| risk-log-template.html:225-230 | Flag | The `risk` block exists only inside `state-group`; the Resolved group holds a comment "the same `risk` block, once per Resolved risk" instead of a real block, so the script must lift the block out. The leading comment's REPEATED BLOCKS list doesn't say so, which weakens "the template is the schema". |
| risk-log-template.html (whole) | Pass | No `<script>`, no `on*=` attribute, no score in any `data-*` attribute. |

## Against the spec
| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| risk-log-template.html (new file only) | T001 · §3.2, §4 owns | Pass | The only change under `project/risk-log/` is the new template. |
| risk-log-template.html:138 | T001 · §4 Must (body) | Pass | `data-artifact="risk-log"`, `data-schema="1"`, `data-register`, `data-updated`, and `lang` on `html`, all as spelled. |
| risk-log-template.html:155-160, 201, 215-219, 234 | T001 · §4 Must (elements) | Pass | `ol.register-history` inside the `details` beside the date, with `data-date/by/kind/with`; `table.summary`; `article.risk` with all eight attributes; `.risk-desc`, `.risk-mitigation`, `ol.risk-history`; `section.opt-out` with all four attributes. |
| risk-log-template.html:168-244 | T001 · §4 Must (both forms), NF2, NF3 | Pass | Kept and opt-out forms; the opt-out takes the title and first paragraph via `{{TITLE}}`/`{{DESCRIPTION}}`; folded anchors for 1 and 5 on both axes plus the "ranks, does not decide" sentence; counts at top; states ordered, Resolved last and folded. |
| risk-log-template.html:7, 75-136 | T001 · §4 Must (stylesheet, style) | Pass | `../documentation/_chrome.css`; component styles in one inline `<style>`. |
| risk-log-template.html:8-74 | T001 · §4 Must (leading comment) | Pass | Every body placeholder and every repeated block named; rendered-only parts separated from read-back parts. |
| risk-log-template.html:157 | T001 · §4 Must (`data-with` for a review) | Flag | See the correctness row: `data-with` is on every register line, not "for a review" only. |
| risk-log.ps1:62-71 | T002 · §3.3 | Pass | All ten parameters present; `-Path` mandatory, nothing else. |
| risk-log.ps1:48-53, 29-38 | T002 · §4 Must (help states) | Pass | The four exit codes and the change-file fields match D101 §6.4/§6.5. |
| risk-log.ps1:77 | T002 · §4 Must (`-PluginRoot`) | Pass | Defaults to three `Split-Path -Parent` above `$PSScriptRoot` = the plugin root. |
| risk-log.Tests.ps1 | T002 · §3.1, §3.2 | Flag (uncertain) | The environment gap above: the file is correct on 5.1 and on `pwsh` with Pester 5 imported; whether done-when 1 passes in the verifier's session depends on `pwsh` finding Pester 5. |
| risk-log.ps1, risk-log.Tests.ps1 | T002 · §5 out of scope | Pass | No action bodies built; the skeleton prints "not built yet". |

## Review focus
(From S101 §5; none of it belongs to P0.)
- UTF-8 / æ ø å (T003): the template is fine (`<meta charset="UTF-8">`, LF-only), but see the escaping Flag; the script sets no `[Console]::OutputEncoding` — see the first Conventions Flag.
- CRLF (T004): the template is LF-only with no CR; nothing in P0 blocks parse-based comparison.
- Missing impact → no score, not 0 (T010): the template renders `score {{SCORE}}` as text only, which is workable; the script must supply an empty value.
- Conflict markers, `-By`/exit 3 (T014), a leftover `.new` / the `-Finish` order (T014), no PowerShell (T012): nothing in P0 constrains them; exit 3 is documented in help, not implemented, as intended at this stage.

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P0: 2 task specs, 5 done-whens, checkpoint "The page template and the script's interface are in place with no behaviour yet, and the empty test file runs under Pester 5 on both shell editions."

Environment (as ruled): every command run from the repo root in Bash after exporting `PSModulePath="$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PSModulePath','Machine')");C:\Users\sva\AppData\Local\PowerShell\Modules"` — Pester 5.9.1 found. The commands themselves ran exactly as written.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T001 | done-when 1: `pwsh -NoProfile -Command 'Test-Path -LiteralPath plugins/asimov-plugin/artifacts/project/risk-log/risk-log-template.html'` prints `True` | pass | printed `True`, exit 0 |
| T001 | done-when 2: `git status --short -- plugins/asimov-plugin/artifacts/project/risk-log/` prints the template as a new file and nothing else | pass (uncertain) | As written it prints `?? plugins/asimov-plugin/artifacts/project/risk-log/` (the untracked folder, not the file name); that one line covers only the template — `git status --short -uall` on the same path prints exactly `?? plugins/asimov-plugin/artifacts/project/risk-log/risk-log-template.html`. Judged met by intent, but the literal output names the folder. |
| T002 | done-when 1: Pester 5 run of `risk-log.Tests.ps1` under `pwsh` exits 0 | pass | `pwsh -NoProfile -Command 'Import-Module Pester ...'` → `Tests Passed: 0, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0` ("Discovery found 0 tests"), exit 0 |
| T002 | done-when 2: same under `powershell -NoProfile -ExecutionPolicy Bypass` exits 0 | pass | → `Tests Passed: 0, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`, exit 0 |
| T002 | done-when 3: `pwsh -NoProfile -Command 'Get-Help ./plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1 -Full'` prints the ten parameters, four exit codes and change-file fields | pass | exit 0; SYNTAX/PARAMETERS list `-Path`, `-Read`, `-Area`, `-View`, `-Apply`, `-Change`, `-Repair`, `-Finish`, `-By`, `-PluginRoot`; OUTPUTS lists exit codes 0 done / 1 refused by a rule / 2 input could not be read / 3 no person; `-Change` lists the fields verb, target, fields, state, with, to, opt-out, language |
| P0 | checkpoint: `pwsh ... Invoke-Pester ... && powershell ... Invoke-Pester ...` (the Check, as written) | met | both Pester runs `Tests Passed: 0, Failed: 0, ...`; the `&&` chain exited 0 |

Working tree: `git status --short` before and after identical (` M specs/project-management-risk/S101-project-management-risk.md`, `?? plugins/asimov-plugin/artifacts/project/`, `?? plugins/asimov-plugin/skills/artifact-risk-log-authoring/`, `?? specs/project-management-risk/S101-project-management-risk.ledger.md`). The only file I wrote is the `Get-Help` output in the scratchpad (`.../scratchpad/help.txt`), outside the repo.

Note for the run: the Pester files contain no tests ("Discovery found 0 tests"), so exit 0 means no failures, as the scaffold intends — not that anything was exercised.

Verified: 5 pass · 0 fail · checkpoint met

### commit · e4f7b9b
go by SimonVilandt on 2026-10-29 · 3 files · ledger

## P1 · Register the first risk

### T003 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T003 (human task, built in the session that directs the run; test-first)
- Tests first: five scenarios of §2 added to risk-log.Tests.ps1 as seven Pester tests (the outline's two rows, the non-ASCII scenario on pwsh and on powershell); every repo and page in TestDrive, git run with GIT_CONFIG_GLOBAL on an empty file and GIT_CONFIG_NOSYSTEM=1 so no developer identity leaks in; ASCII-only file, non-ASCII built with [char]. Seen red (7 of 7 failing on "not built yet") before the code.
- risk-log.ps1 -Apply with verb add on a repo with no page: required fields (name, owner, impact 1-5, probability 1-5) refused with exit 1; the first write must name the project language (exit 1); no person -> exit 3 (git config user.name, else -By); render from the template read at run time under -PluginRoot (blocks by BEGIN/END markers, the authoring comment stripped, kept form only, register-line omits data-with unless the kind is review, the risk block lifted into the resolved group); values HTML-escaped (& < > " and braces only, so UTF-8 names stay as written); score rendered only; write to risk-log.html.new, read it back into the model and compare parsed data, then Move/Replace into place; a failed check deletes the .new and exits 1. An add on an existing page exits 2 "not built yet" (T004's).
- Fixed from P0's review flags: [Console]::OutputEncoding UTF-8; data-with only on review lines; escaping; the risk block in the resolved group.
- Done-when 1 and 2: Pester 5.9.1, 7 passed, 0 failed on PowerShell 7.6.7 and 5.1.
gaps: 0 · flags: 2
- flag: the script's own texts (history lines, the page description) are English; RL16 wants stored content in the project language. Left to T011/T012 (the definition and the authoring skill decide whether the script takes these texts from the change file).
- flag: an unbuilt action or verb still exits 2, as P0's review noted; T004-T010 replace them.

### review
Conventions read: CLAUDE.md (repo root; no `documentation/conventions/` exists), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (house style for a PowerShell script).

Reviewing: HEAD (uncommitted, working tree) — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`) against S102 T003. (`specs/project-management-risk/S101-project-management-risk.ledger.md` is also modified but not in scope; not reviewed.)

Ran the Pester file under both editions: `pwsh` 7 passed / 0 failed, `powershell` 5.1 7 passed / 0 failed. Both files are pure ASCII. Also ran the script by hand on hostile input: a name containing `& < > " {{OWNER}} $1 $& ${x}` and a multi-line description with `{{NAME}}` — written and read back clean, no placeholder re-substitution; a CRLF copy of the template under `-PluginRoot` — exit 0; a pre-existing `risk-log.html.new` containing "OLD" — silently overwritten (see Correctness row 1).

### Conventions
Stack: PowerShell script. CLAUDE.md has no PowerShell rules beyond the pure-ASCII/5.1+7 house style and hard rule 3 (template read by path at run time).

| File:line | Severity | Reason |
|---|---|---|
| (whole changeset) | Pass | Follows the `validate-s102.ps1` house style: ASCII-only source, 5.1 + 7, `Set-StrictMode`, `$ErrorActionPreference = 'Stop'`, console encoding in try/catch, plugin root derived three folders up; the template is read at run time from `$PluginRoot`, not copied into the script. |
| risk-log.ps1 `Format-Page` — `[regex]::Replace($Template, '(?s)<!--...', '', 1)` | Flag | The static `Regex.Replace` has no count overload; the `1` binds to `RegexOptions` = `IgnoreCase` (confirmed: `[regex]::Replace("ABC","b","x",1)` → `AxC`). It works (and the tests prove the comment is stripped), but the intent is misstated; base-judgment: pass `[System.Text.RegularExpressions.RegexOptions]::None` or use an instance `Regex` with a count. |
| risk-log.ps1 `$Today = (Get-Date).ToString('yyyy-MM-dd')` | Flag | Culture-sensitive format (a Buddhist/Japanese-era calendar in the current culture changes the year); CLAUDE.md mandates `YYYY-MM-DD` dates — use `[CultureInfo]::InvariantCulture`. Same exposure in the test's `Get-Today`. Base-judgment. |

### Correctness & safety

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1 `Write-Register` — `WriteAllText($new, …)` | Flag | An existing `<page>.new` from an interrupted earlier run is overwritten with no check (reproduced: a stale `.new` was clobbered and then renamed over the page). This is the review-focus case "a `.new` left by an earlier run → `-Finish` runs before any verb" (T014); not a T003 defect, since T003 only needs failure cleanup, but when T004+ reuse this function an `-Apply` that finds a `.new` should refuse (exit 1, "run -Finish first") rather than destroy the thing `-Finish` is meant to recover. Failure class: data loss on recovery path. |
| risk-log.ps1 `Write-Register` — between `WriteAllText` and the compare | Flag | The `.new` is deleted only on a failed comparison; any terminating error in between (`$ErrorActionPreference = 'Stop'` — e.g. a read-back exception, a locked file) leaves the `.new` behind with an unhandled error. The spec says a failed check deletes the `.new`; a `try/finally` that removes the `.new` unless renamed closes this. Failure class: cleanup not guaranteed. |
| risk-log.ps1 `Read-PageModel` / `Format-Model` — look-ahead for T004/T010 | Flag (uncertain — not a T003 defect) | The check compares parsed text exactly. For the CRLF review-focus case (T004), a hand-checked-out page will read multi-line `description`/`mitigation`/history `text` back with `\r\n` while the model holds `\n`, so the compare would report a false mismatch. Normalise newlines in `Read-PageModel` (or in `Format-Model`) before T004 reads real pages. The block regexes already tolerate `\r?\n`. |
| risk-log.ps1 `Get-Score` / `Format-Risk` — look-ahead for T010 | Pass | A missing impact or probability yields `''`, so the score renders empty, not 0; parsing yields `''` for a removed attribute — what T010's "no score shown, read reports a problem" needs. |
| risk-log.ps1 `Get-Person` / main `Apply` — look-ahead for T014 | Pass | `-By` unset and no git user name → exit 3 with a stated reason before any write; `git` missing is caught as well. |
| risk-log.ps1 `Write-Register` — `$repoName = Split-Path -Leaf (Split-Path -Parent $dir)` | Flag | The repo name for `<title>` is the grandparent folder of the page: right for `project/risk-log.html` at a repo root, wrong for any other `-Path`; a drive-root `$dir` makes `Split-Path -Leaf ''` throw. Low risk since the path is fixed by convention. Base-judgment. |
| risk-log.ps1 — UTF-8 (review focus, T003) | Pass | Change file read with BOM-less UTF-8 `ReadAllText`, page written with BOM-less UTF-8, HTML-escaping leaves non-ASCII intact; the tests build æ/ø/å with `[char]` and check bytes (no BOM) and the exact name/owner on both editions. |
| risk-log.Tests.ps1 `New-TestRepo` | Flag | The no-git-identity test sets `$env:GIT_CONFIG_GLOBAL` and `GIT_CONFIG_NOSYSTEM` in the Pester process and never restores them (they leak to the rest of the session), and `GIT_CONFIG_GLOBAL` needs git ≥ 2.32 — on older git the exit-3 example would pick up the developer's own identity, against §4 "never depend on the developer's git identity". Set/restore around the call, or pass per child process. |
| risk-log.Tests.ps1 non-ASCII test | Flag | The `powershell`/`pwsh` rows call the shell by bare name; a machine without `pwsh` (or 5.1) fails the test rather than skipping. Acceptable if both editions are required — say so in the comment. |

### Against the spec

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| (whole changeset) | §1 owns / `owns.modify`, `owns.test` | Pass | Only `risk-log.ps1` and `risk-log.Tests.ps1` changed; both are listed in `owns`. |
| risk-log.ps1 `Invoke-Add` / `Apply` | §2 "The first risk creates the register as RISK-001" | Pass | RISK-001, Active, score 12 beside the name, today's dates, one `created` line each in risk and register history, `lang` from `language`. |
| risk-log.ps1 `Test-Required`, `Get-Person` | §2 outline rows (exit 1 no owner; exit 3 no person) | Pass | Exit codes 1 and 3 with a reason on stdout, no page and no `.new` left; the tests assert both. |
| risk-log.ps1 `Format-Risk` | §2 "Optional fields left out are not shown" | Pass | No `risk-desc`/`risk-mitigation` element, `data-area=""`. |
| risk-log.ps1 `Format-Page` / template | §2 "states its scoring and carries no script" | Pass | No `<script`, chrome link present, anchors table and caveat sentence from the template. |
| risk-log.ps1 `Read-Template`, `Write-Register` | §4 Must: render from template under `-PluginRoot`; write via `.new`, check, rename; create the folder | Pass | Template read at run time under `$PluginRoot`; `.new` beside the page, read back, checked, then moved/replaced; folder created when absent. |
| risk-log.ps1 `Format-Risk` | §4 Must: score in no `data-*`, nothing reads it back | Pass | `data-*` carries impact/probability only; `Read-PageModel` never reads the score. The history text "(score N)" is narrative, not the score field. |
| risk-log.ps1 `Invoke-Add` | §4 Must not: read back an existing page | Pass | An existing page exits 2 "not built yet" — no read, no overwrite. |
| risk-log.Tests.ps1 | §4 Must: `TestDrive:`, no developer identity | Flag | `TestDrive:` used throughout; the identity isolation has the weaknesses in the Correctness row for `New-TestRepo`. |
| risk-log.Tests.ps1 | §3 done-when 1: one test per scenario, one per example row | Pass | Seven tests: one each for the first, optional, scoring and non-ASCII scenarios, plus two outline rows; the non-ASCII scenario is split into a pwsh and a powershell test, consistent with "each page" in the scenario. |
| risk-log.ps1 `Invoke-Add` — `language`, `Exit-Refused` | §2 / §5 Out of scope (translation T012/T014) | Pass | Titles, description and history text are English regardless of `language`; deferred to T012/T014, not built early. |

Review-focus items other than T003 UTF-8 (CRLF, hand-removed impact, conflict markers, git user unset, leftover `.new`, no PowerShell) are not due this phase; the notes above are what would make them harder: the newline-normalisation gap, the unguarded `.new` overwrite, and the cleanup-on-exception gap.

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P1: 1 task spec (T003), 2 done-whens, checkpoint "A first risk becomes RISK-001, Active, on a new register page that shows the scoring anchors and carries no script, a risk without an owner is refused, and the script's tests prove it."

Environment (as ruled by SimonVilandt): before any command I ran `export PSModulePath="$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PSModulePath','Machine')");C:\Users\sva\AppData\Local\PowerShell\Modules"` — Pester resolved to 5.9.1 in both shells. All commands run from `C:/Privat/Repositories/asimov`.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T003 | done-when 1: green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path …/risk-log.Tests.ps1 -PassThru \| ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, one test per §2 scenario / example row | pass | exit 0; last line `Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. A separate `-Output Detailed` run listed the 7 test names (below). |
| T003 | done-when 2: green under `powershell -NoProfile -ExecutionPolicy Bypass -Command '…same Pester expression…'` | pass | exit 0; last line `Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0` |
| P1 | checkpoint: P1's check (pwsh run && powershell run) | met | The two runs of done-when 1 and 2 are exactly the check's two halves as written (no `&&` between them); both exited 0. |

Per-scenario check for done-when 1 — the Detailed run showed these 7 tests:
- The first risk creates the register as RISK-001
- A first risk that cannot be written leaves no page behind (no owner)
- A first risk that cannot be written leaves no page behind (every required field present)
- Optional fields left out are not shown
- The page states its scoring and carries no script
- Names outside ASCII are written intact on both shell editions (pwsh)
- Names outside ASCII are written intact on both shell editions (powershell)

One test per scenario, one per example row of the outline, and the ASCII scenario has one test per shell edition. I read these names from the output only; I did not open the test file to check the assertions against the scenario steps.

Notes:
- I ran the pwsh command once with `-Output Detailed` and `$r` instead of the as-written pipeline, to see test names. That is a second run, not the as-written command; the as-written commands were then run in both shells, and only those two runs are the evidence for the two done-whens.
- The working-tree status hash (`git status --short | md5sum`) was identical before and after my runs: `ffe06e893a13852e0766801a9ff162e5`.

Verified: 2 pass · 0 fail · checkpoint met

### commit · 44ebe61
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P2 · Number and score risks

### T004 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T004 (human task, built in the session that directs the run; test-first)
- Tests first: the six scenarios of §2 as thirteen Pester tests (the duplicate outline's two rows, the areas outline's seven rows); fixtures written by -Apply and then hand-edited (states, identifiers, created dates, a shown score, CRLF), all in TestDrive. Seen red (13 failing, the 7 of T003 still green) before the code. The test file now restores GIT_CONFIG_GLOBAL and GIT_CONFIG_NOSYSTEM in AfterAll and computes today in the invariant culture (P1 review flags).
- risk-log.ps1: -Read prints the model as JSON (lang, register, updated, history, risks, areas, problems; with -Area also "nearly") and writes nothing; it reads only the attributes and lists of D101 §6.4, never the score, summary or counts. -Apply add now writes to an existing page: the page is read, a page with problems is refused (exit 1, "run -Repair first"), duplicate identifiers are renumbered first (the earliest-created keeps the id, ties to the upper one on the page; the others take the next numbers with a renumber line "Renumbered from RISK-007"), the new risk takes max+1 (never a gap, never a resolved id), the register history gains a write line naming the renumbering. A change carrying a score is refused (exit 1). Areas nearly the same (RL13): whole texts, ignoring case, spaces, hyphens and punctuation, equal or one edit apart when both are four letters or more.
- The write's check now also holds the new page to what the page held: no risk dropped, no history line dropped or changed, the register history's old lines kept as its tail, no identifier twice (exit 1).
- From P1's review flags: an -Apply that finds a leftover risk-log.html.new refuses (exit 1, "Run -Finish first") instead of overwriting it; the .new is removed in a finally unless renamed; CRLF pages are normalised before parsing; dates in the invariant culture; the comment-stripping regex no longer passes IgnoreCase by accident; File.Replace gets [NullString]::Value (PowerShell had turned $null into "").
- Fixed on the way: a 2D-array index Windows PowerShell 5.1 cannot parse (the distance now uses two rows), and the read-back compare now orders risks by identifier, since the page shows them in the RL12 order.
- Done-when 1 and 2: Pester 5.9.1, 20 passed, 0 failed on PowerShell 7.6.7 and 5.1.
gaps: 0 · flags: 1
- flag: -Read's problems cover missing or malformed fields only; conflict markers and the repair are T010's.

### review
Conventions read: `CLAUDE.md` (repo root; this repo has no `documentation/conventions/`), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (house style for PowerShell scripts) — plus S102 T004, the template header, D101 §6.4/RL2/RL3/RL4/RL13 and the P1 review in the ledger.

Reviewing: HEAD (uncommitted) vs S102 T004 — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`). Both done-whens run: Pester 5.9.1, 20 passed / 0 failed on `pwsh` and on Windows PowerShell 5.1. Scratch checks (stale `.new`, conflict markers, non-ASCII on both editions) run in the scratchpad; no repo file touched.

**P1 review flags — closed?** Closed: `IgnoreCase` regex (now instance `Regex`), invariant-culture date, stale `.new` refused in `-Apply` (reproduced: exit 1 "Run -Finish first"), `.new` deleted in a `finally`, CRLF normalised in `Read-PageModel`, git env vars restored in `AfterAll`. Not closed and not mentioned in the ledger: repo-name-for-`<title>` still the page's grandparent (`Write-Register`); the `pwsh`/`powershell` bare-name note on the T003 test unchanged; the `GIT_CONFIG_GLOBAL` git ≥ 2.32 caveat unchanged. All three low risk.

### Conventions (CLAUDE.md, house style)
| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1, risk-log.Tests.ps1 (whole) | Pass | Pure ASCII kept (middle dot via `[char]0x00B7`, Danish names via `[char]`); dates `YYYY-MM-DD` in invariant culture; same param/exit-code/section-comment style as `validate-s102.ps1`. |
| risk-log.ps1 `Invoke-Read` — `$PSBoundParameters.ContainsKey('Area')` | Flag | Inside a function `$PSBoundParameters` is the function's own (only `Page`), so this test is always false; only the `-or $Area` half works, so an explicit `-Area ''` never prints `nearly`. Remove the dead half or pass `$Area` in. |

### Correctness & safety
| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1 `Test-NearlySame` — `$ka -eq $kb` | Flag | Cross-edition difference, reproduced: on Windows PowerShell 5.1 `-eq` compares culture-aware, so the key of "Skærm" equals "skaerm" and `-Read -Area Skaerm` returns "Skærm" as nearly the same; `pwsh` returns `[]` for the same input. D101 says the same two areas must give the same answer on every run, and the project's own examples are Danish. Compare with `[string]::Equals($ka,$kb,[StringComparison]::Ordinal)`. (Same applies to `-eq`/`-ne` on identifiers in `Get-Problems`/`Test-Kept`/`Invoke-Renumber`, but those are ASCII.) |
| risk-log.ps1 `Get-Problems` / `Get-Current` | Flag | Look-ahead for T010 (conflict markers): a page with `<<<<<<<`/`=======`/`>>>>>>>` around the two sides of one risk reads with `problems: []`, and a following `-Apply add` exits 0, silently drops the markers and renumbers the "other side" as a new RISK-002 (reproduced). That is the opposite of the review-focus rule (merge by identifier, ask per field changed on both sides). The repair is T010's by §5, but a one-line "conflict markers present" entry in `Get-Problems` would make `-Apply` refuse ("run -Repair first") until T010 lands, and gives T010 its trigger. |
| risk-log.ps1 `Get-Problems` / `Invoke-Read` | Flag | Duplicate identifiers are deliberately not a problem, and `-Read` has no field that says so; the entry point/T010 repair would have to rescan `risks[].id` to learn that a repair/renumber is pending. A `duplicates` list in the JSON is cheap and doesn't change the spec'd empty `problems`. |
| risk-log.ps1 `Invoke-Renumber` | Flag (uncertain) | A renumbered risk gets a history line dated today but its `changed` date is not bumped, so `data-changed` and its newest history line can disagree. Neither D101 RL4 nor T004 says either way; settle it before T008/T010 reuse the function. |
| risk-log.ps1 `Get-Current` / `Test-Kept` | Flag | The baseline `$held` is the page re-read and put through the same `Invoke-Renumber`, so the check cannot catch a defect in the renumbering itself; it also compares register history without `with`. Acceptable now, but it weakens "the check compares against what the page held". |
| risk-log.ps1 `Write-Register` | Pass | `.new` removed unless renamed; `[NullString]::Value` fixes the `File.Replace` backup argument; series is max+1, no gap closed, no resolved id reused; dups renumbered earliest-created first, ties to the upper one on the page, and the new risk takes the next number after renumbering — matches RL3/RL4. |
| risk-log.ps1 `-Read` | Pass | Writes nothing (page hash unchanged in the test); reads only the attributes/lists the template names, never the score, summary or counts; UTF-8 output intact on both editions (Danish name/area read back byte-correct). |

### Against the spec (S102 T004)
| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| risk-log.Tests.ps1 (whole) | §4 Must "the write's check refuses, exit 1, a new page that drops a risk or a history line… or holds a duplicate identifier" | Flag | Implemented in `Test-Kept`, but no test makes it fire; every scenario in §2 passes through it only on the success path. The §3 done-when does not require one, so this is a coverage gap, not a spec break. |
| risk-log.Tests.ps1 CRLF test | §2 `@review-focus` CRLF scenario | Flag | Scenario met (CRLF page, `-Read` no problem, add passes its check), but the fixture's description is the single line 'First line.', so the test does not exercise the multi-line description/history text the P1 flag named. |
| risk-log.ps1 `Get-Problems` | §5 out of scope (unreadable register → repair, T010) | Pass | Reports missing fields only (no impact → `''`, not 0, and a problem); does not build the repair. The conflict-marker gap above is the only thing it leaves open. |
| risk-log.ps1 / risk-log.Tests.ps1 | §1, §2, §3, §4 | Pass | Only the two owned files changed; all six scenarios / 13 rows covered by tests; T003 tests still green; score refused (exit 1, page hash unchanged) and recomputed on write; series not reused or closed. |

Review-focus items not yet reachable in this phase (for later tasks): the T014 "`.new` before any verb" guard exists in `-Apply` only — `-Read`/`-View` ignore a stale `.new`; the `-By`/exit-3 path works as T014 needs.

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P2: 1 task spec, 2 done-whens, checkpoint "A new risk continues the series past resolved ones, a duplicate identifier is renumbered before the write, a hand-edited score is recomputed, nearly-same areas are found, and the script's tests prove each case."

Environment: as ruled, exported PSModulePath to the new-window value before running (Machine PSModulePath read via `powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PSModulePath','Machine')"` + `;C:\Users\sva\AppData\Local\PowerShell\Modules`); Pester 5.9.1 loaded under both shells. All commands run from `C:/Privat/Repositories/asimov`.

First pwsh run was with `-Output Detailed` added, to get test names; then both commands re-run exactly as written. The rows below are from the as-written runs.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T004 | done-when 1: `risk-log.Tests.ps1` green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester ... FailedCount + FailedContainersCount)'`, T003's tests still green, one test per §2 scenario/example row | pass | pwsh exit 0; last line `Tests Passed: 20, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`; test-name check below |
| T004 | done-when 2: green under `powershell -NoProfile -ExecutionPolicy Bypass -Command '...'` (same Pester expression) | pass | powershell 5.1 exit 0; last line `Tests Passed: 20, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0` |
| P2 | checkpoint: the script's tests prove each case | met | the check command (pwsh `&&` powershell) exits 0 on both |

**Test-name check (done-when 1), from the Detailed pwsh run — 20 tests:**
- T003's seven, in context "Register a risk on a new page", all present and green: The first risk creates the register as RISK-001 · A first risk that cannot be written leaves no page behind (no owner) · (every required field present) · Optional fields left out are not shown · The page states its scoring and carries no script · Names outside ASCII are written intact on both shell editions (pwsh) · (powershell).
- T004's thirteen, in context "Read, number and score risks", one per §2 scenario / example row:
  - An intact register reads back in full with no problem — 1
  - A new risk continues the series past resolved risks — 1
  - A duplicate identifier is renumbered before the write's own change (on two different days) / (on the same day) — 2 = 2 rows
  - The score shown is recomputed and never given — 1
  - Areas nearly the same are found — 7 = 7 rows (Schedule/schedule, Schedule/sched-ule, Schedule/Schedul, Cost/Costs, Customer schedule/Customer schedules, QA/QC, Supplier schedule/Customer schedule)
  - A register with CRLF line endings reads and writes as normal — 1
- 7 + 13 = 20; no scenario or example row is missing a test, and no test is outside the spec.

Working tree: `git status --short` before and after shows the same three modified files (`risk-log.Tests.ps1`, `risk-log.ps1`, the ledger) and nothing new; I wrote one output capture to the scratchpad, outside the repo.

Verified: 2 pass · 0 fail · checkpoint met

### commit · 54cec5a
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P3 · Change a risk

### T005 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T005 (human task, built in the session that directs the run; test-first)
- Tests first: the four scenarios of §2 as four Pester tests (fixtures by -Apply, then hand edits of a created date and a state). Seen red (4 failing on "verb 'change' is not built yet", the 20 earlier tests green) before the code.
- risk-log.ps1 -Apply with verb change: the target must exist (else exit 1 naming it, page byte-identical, no .new); fields limited to the seven of the change file (others exit 1); name and owner cannot be emptied; impact and probability whole numbers 1-5 (exit 1); an unchanged value is skipped and a change that changes nothing is refused (exit 1); the state is never touched; one history line of kind change per write naming each field "Impact 3 -> 4" (U+2192), old values shown as "none" when empty; changed date today, created kept; register updated today with a write line. Goes through Get-Current, so duplicates are renumbered first and the write's check holds the page to what it held.
- From P2's review flags: git conflict markers are now a problem (-Read lists them, -Apply refuses "run -Repair first"), verified by hand on both editions; Test-NearlySame compares the keys ordinally (on 5.1 "Skaerm" no longer matches "Skaerm-with-ae"; "Skarm" still does); the dead $PSBoundParameters test in -Read is gone.
- Test harness: [Console]::OutputEncoding set to UTF-8 in the Pester process (restored in AfterAll), because PowerShell 7 started from a non-UTF-8 console decoded the child's UTF-8 output with the console code page and the arrow came out garbled.
- Done-when 1 and 2: Pester 5.9.1, 24 passed, 0 failed on PowerShell 7.6.7 and 5.1.
gaps: 0 · flags: 0

### review
Conventions read: `CLAUDE.md` (repo root; this repo has no `documentation/conventions/`), plus `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` as PowerShell house style.

Reviewing: HEAD (uncommitted work as the diff) — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`) against S102 T005; S101 §1–§2 read as the plan requires; read the whole of `risk-log.ps1` and the test file header. Ran the tests (`Invoke-Pester`, Pester 5.9.1) on both editions: PowerShell 7 → 24 passed / 0 failed; Windows PowerShell 5.1 → 24 passed / 0 failed.

## Conventions
| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1`, `risk-log.Tests.ps1` | Pass | Pure ASCII with `[char]` for U+2192, one script with comment-banner sections, `Exit-Refused`/`Exit-Unreadable`, `Set-StrictMode` — matches `validate-s102.ps1` house style and `CLAUDE.md`; no hard rule touched (hard rules 1–11 concern manifests/models/paths). |
| `risk-log.Tests.ps1:~327` | Flag | `}    }` closes the `Invoke-Change` helper and the `BeforeAll` on one line — formatting slip (base judgment only). |

## Correctness & safety
| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1:383`, `:406`, `:414` | Flag | The read-back check (`Format-Model … -ne …`) and `Test-Kept` use `-ne` on strings. Confirmed on 5.1 that `-eq` is culture-aware and case-insensitive (`'æ' -eq 'ae'`, `'ß' -eq 'ss'` → True), so these checks cannot see æ turning into ae or a case-only loss — the same defect class the P2 flag named, fixed only in `Test-NearlySame`. Pre-dates T005 and hurts the T003 focus (UTF-8 name read back unchanged on both editions). Fix with `[string]::Equals(…, Ordinal)`. |
| `risk-log.ps1:364` (`Get-Areas`) | Flag | `Sort-Object -Unique` is case-insensitive (and on 5.1 probably culture-aware): "Schedule" and "schedule" collapse to one entry, "Skaerm"/"Skærm" may too, which can hide the near-duplicates RL13 wants shown. (uncertain — not run on 5.1; the culture half of the flag may not be fully closed) |
| `risk-log.ps1:329` | Flag | The marker regex fires on any lone `=======` line; if a description can hold a newline (`Get-Text` only trims), a line of seven equals signs puts the register in permanent "run -Repair first". Requiring a `<<<<<<<` line as well would be safer. (uncertain — depends on whether descriptions can be multi-line) |
| `risk-log.ps1:517` | Flag | Empty/missing `target` prints "The register holds no . Nothing written." — right exit code, message names nothing. |
| `risk-log.Tests.ps1` | Flag | Neither P2 flag taken into this attempt has a regression test: no test covers conflict markers (problem on `-Read`, refusal on `-Apply`) or the ordinal area comparison; the ledger says both were "verified by hand". Closed in code, but nothing holds them closed. |

Both P2 flags are closed in the code: markers — `Read-Register` sets `markers`, `Get-Problems` reports it, `Invoke-Read` lists it, `Get-Current` refuses with "run -Repair first" for `add` and `change`; culture-aware comparison — `Test-NearlySame` now ordinal. The `-Read` fix is also right (`$Area` empty → no `nearly`). In `Invoke-Change` itself I found no defect: values compare ordinally (a case-only rename is a real change), nothing is written on any refusal, the `.new` is removed by `Write-Register`'s `finally`, and `Test-Kept` guards earlier history lines.

## Against the spec
| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `risk-log.ps1:514–550` | T005 · §2 scenarios 1–4 | Pass | Each scenario has a code path and a matching test: changed date moves / created stays; one history line for several fields; Resolved risk renamed and still Resolved; unknown id exits 1 with page byte-identical and no `.new`. |
| `risk-log.ps1:530–540` | T005 · §4 Must (state never set; earlier history intact) | Pass | `data-state` never assigned; `Test-Kept` holds old lines. |
| `risk-log.ps1:522, 533–534` | T005 · §4 Must (seven fields; impact/probability 1–5 else exit 1) | Pass | Unknown fields, emptied name/owner, out-of-range impact/probability all refused with exit 1. |
| both files | T005 · `owns` | Pass | Only the owned script and its test file changed in code (the ledger edit is the run harness's). |
| — | T005 · §5 | Pass | No state change, no Mitigated-mitigation refusal (AC12), no handover built. |
| — | T005 · §3 done-when 1, 2 | Pass | Both commands' test file runs green; four tests named for the scenarios; T003/T004 tests still green. |

## Notes for later tasks
- **T010 (repair):** `markers` is set only by `Read-Register`, not `Read-PageModel`, so the repair must read through `Read-Register`; `Read-PageModel` on a conflicted page parses both sides into one model with duplicate ids.
- **T003 (non-ASCII read-back):** the `-ne` culture issue above is the one to close before claiming the check holds on 5.1.
- **T014:** `-Apply` with a leftover `.new` currently refuses (exit 1, "run -Finish first") — the `-Finish` verb doesn't exist yet; the "-Finish before any verb" behaviour is T014's. The exit-3 path (`Get-Person`) runs after `Read-Change`, so an unset name with a bad change file reports exit 2 first.
- **Duplicate ids:** a `change` targeting a duplicated id silently applies to the surviving (earliest-created) risk after `Get-Current` renumbers the other; the write line records the renumber, but a caller who meant the second one is not asked.

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P3: 1 task spec (T005), 2 done-whens, checkpoint "A changed field moves the risk's changed date and keeps its created date and its state, an unknown identifier writes nothing, and the script's tests prove it."

Environment: as ruled, exported `PSModulePath` in Bash before every Pester run, set to the Machine value (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PSModulePath','Machine')"`) + `;C:\Users\sva\AppData\Local\PowerShell\Modules`.

Run note: my first pwsh run added `-Output Detailed` to read test names (so not as-written); I then ran the pwsh command exactly as written and report that run below. Both gave the same result.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T005 | done-when 1: green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester ... -PassThru ...)'`, T003/T004 tests still green, one test per §2 scenario | pass | pwsh as-written → `Tests Passed: 24, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`, exit 0. Detailed run lists all four T005 scenario titles as `[+]`, each exactly once. |
| T005 | done-when 2: green under `powershell -NoProfile -ExecutionPolicy Bypass -Command '...'` | pass | powershell as-written → `Tests Passed: 24, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`, exit 0 |
| P3 | checkpoint — the `Check` string (pwsh && powershell) | met | Both halves exit 0 with 0 failures and 0 failed containers (halves run separately, not chained; each half is the identical command). |

T005 tests (green): A changed field moves the changed date and keeps the created date · Several fields changed at once give one history line · A resolved risk can be renamed and stays resolved · An identifier that does not exist writes nothing.

Earlier tests (all green): The first risk creates the register as RISK-001 · A first risk that cannot be written leaves no page behind (×2) · Optional fields left out are not shown · The page states its scoring and carries no script · Names outside ASCII are written intact on both shell editions (×2) · An intact register reads back in full with no problem · A new risk continues the series past resolved risks · A duplicate identifier is renumbered before the write's own change (×2) · The score shown is recomputed and never given · Areas nearly the same are found (×7) · A register with CRLF line endings reads and writes as normal.

Uncertain: I could not confirm which of those 20 are T003's vs T004's — the test file carries no `T003`/`T004` marker (grep found none). All 20 earlier tests ran and passed, and 24 = 20 + 4 new; if done-when 1 means a specific T003/T004 set, that mapping is not observable from the run.

Tree integrity: `git status --porcelain` and `git diff` hashes identical before and after my runs (ffe06e89… / 6a93912b…) — tree unchanged.

Verified: 2 pass · 0 fail · checkpoint met

### commit · 578747d
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P4 · Decide a risk's state

### T006 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T006 (human task, built in the session that directs the run; test-first)
- Tests first: the four scenarios of §2 as sixteen Pester tests (the set outline's eight rows, the refused outline's six rows, the Mitigated-mitigation scenario, the history scenario), plus a "Review guards" context of two tests that are not T006 scenarios: conflict markers make the register unreadable while a lone line of equals signs in a description does not, and areas differing only in case are both listed (P2/P3 review flags kept closed). Seen red (18 failing, the 24 earlier green) before the code.
- risk-log.ps1 -Apply with verb state: the target must exist and name a state; setting the state it already has is refused; every state change needs a reason; Mitigated needs a written mitigation; Accepted needs a decider; any state from any other (RL5), same identifier; one history line of kind state "Active -> Mitigated: <reason>. Decided by <decider>." (U+2192); changed date today; a field is never touched; register updated with a write line. -Apply change refuses to empty the mitigation of a Mitigated risk ("set it back to Active first").
- From P3's review flags: the write's check (Format-Model compare, Test-Kept history lines) compares ordinally (Test-Same), so on 5.1 an "ae" for an "ae-ligature" or a case-only change is no longer invisible; Get-Areas is unique by ordinal comparison and sorted ordinally (so "Schedule" and "schedule" are two); conflict markers need both a <<<<<<< and a >>>>>>> line; an empty target names itself in the refusal.
- Done-when 1 and 2: Pester 5.9.1, 42 passed, 0 failed on PowerShell 7.6.7 and 5.1.
gaps: 0 · flags: 0

### review
Conventions read: `CLAUDE.md` (repo root; this repo has no `documentation/conventions/`) and `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` as PowerShell house style. Also read: S101 §1–§2, the P3 review and P4 T006 attempt in the ledger.

Reviewing: HEAD (uncommitted work as the diff) — 2 files, against S102 T006. Read the whole of `risk-log.ps1` and the whole diff of the test file; ran Pester 5.9.1 on both editions — PowerShell 7: 42 passed / 0 failed; Windows PowerShell 5.1: 42 passed / 0 failed. Nothing edited.

## Conventions
| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1`, `risk-log.Tests.ps1` (the diff) | Pass | Pure ASCII kept (`[char]` for U+2192), same banner sections, reuses `Exit-Refused`/`Get-Field`/`Get-Text` — matches `validate-s102.ps1` and `CLAUDE.md`; no hard rule touched. |
| `risk-log.Tests.ps1:326` | Flag | P3's formatting flag still open: `}    }` closes the `Invoke-Change` helper and the `BeforeAll` on one line — not touched in this attempt and not mentioned in the ledger (base judgment only, no convention file behind it). |

## Correctness & safety
| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1:370` (`Get-Areas`) | Flag | The ordinal sort puts every capitalised area before every lowercase one and non-ASCII letters last (`Zebra`, `apple`, `Ægir`) — the order `-Read` returns and later tasks will show a person. Sort case-insensitively with an ordinal tie-break to keep "Schedule"/"schedule" distinct without scrambling the alphabet. Base judgment. |
| `risk-log.ps1:331` | Flag | Conflict markers now need both a `<<<<<<<` and a `>>>>>>>` line. Content cannot cause a false hit (`ConvertTo-Html` escapes `<`/`>`, so a lone `=======` is the only content-borne case), but a merge half-resolved by hand — one marker line deleted, the `=======` left in — now reads as a clean register; both sides' risks then parse as duplicate ids and `Invoke-Renumber` renumbers them silently instead of sending the person to repair. (uncertain — depends on whether T010's repair is meant to catch half-resolved merges) |
| `risk-log.ps1:583-584` | Flag | A reason ending in `?` or `!` gets a full stop appended ("…late?.") by `-not $text.EndsWith('.')`. Base judgment; cosmetic, but it goes into the permanent history. |
| `risk-log.ps1:533-534` | Pass | Empty-target message now names itself ("The change names no target (RISK-NNN)") — P3 flag closed. The check sits after the lookup/`Get-Current`, harmless since nothing is written. |
| `risk-log.ps1:563-595` (`Invoke-State`) | Pass | No defect found: verb inputs checked before any mutation; ordinal compares (`active` refused); already-in-state refused; all rules before `Write-Register`, so a refusal leaves no `.new` and an untouched page. |
| `risk-log.ps1:544` | Pass | The Mitigated guard sits after the "value unchanged" skip (an already-empty mitigation isn't refused); whitespace-only trimmed to empty and refused; runs before the write, so no partial in-memory change can reach the page. |

## Against the spec
| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `risk-log.ps1:563-595` | T006 · §2 scenario 1 (set when what it needs is given) | Pass | All eight example rows served by one code path: identifier, changed date, group on the page, `state` history line with reason and optional decider — the test checks each row, including the Resolved group in `<details>`. |
| `risk-log.ps1:579-582` | T006 · §2 scenario 2 (requirement missing) | Pass | All six rows refused with exit 1, page byte-identical (page-hash asserted). |
| `risk-log.ps1:544` | T006 · §2 scenario 3 | Pass | Mitigated mitigation cannot be emptied; message "set it back to Active first"; test matches `Active` and the page hash. |
| test "A risk's history only grows" | T006 · §2 scenario 4 | Pass | Three dated lines `created,change,state`; first line JSON-identical. |
| `risk-log.ps1:586-588` | T006 · §4 Must (state change never alters a field) | Pass | Only `state`, `changed`, `history` assigned. |
| `risk-log.Tests.ps1` (state context) | T006 · §4 Must (state change never alters a field) | Flag | No test asserts it: the set test never compares impact/owner/mitigation/area before and after, and `Test-Kept` checks only history, so a later edit that touched a field would pass the suite. A one-line before/after assertion would hold it. |
| `risk-log.ps1:402-424` | T006 · §4 Must (check refuses a page that drops/rewrites history) | Pass | Existing `Test-Kept` serves it, now ordinal; no new test for the refusal in the diff. |
| `risk-log.ps1:586` | T006 · §4 Must not (derive state from a field) | Pass | Nothing sets a state from a mitigation or any field. |
| both files | T006 · `owns` | Pass | Only the owned script and its test file changed in code (the ledger edit is the run's own). |
| — | T006 · §5 | Pass | No prompting for missing mitigation/decider/reason (T012/T014), no Occurred group in the view, no issue-log pointer. |
| — | T006 · §3 done-when 1, 2 | Pass | Both editions green; T003–T005 tests still pass; each scenario has a test of its own title. (The test file carries no T003/T004 marker, so done-when 1's "T003 to T005 still green" cannot be mapped to specific tests.) |

## P3 flags taken into this attempt
- `-ne` culture-aware compares → **closed**: `Test-Same` used in the write's read-back check and both `Test-Kept` loops.
- `Get-Areas` uniqueness → **closed**: ordinal now, held by the "Areas that differ only in case" guard test (passes on 5.1, so the 5.1 half I flagged uncertain is covered).
- lone `=======` marker → **closed**, held by the "Conflict markers…" guard test (which also checks the refusal, exit 1, on `-Apply`); see the half-resolved flag above for the residual.
- empty-target message → **closed**.
- missing regression tests for markers/areas → **closed**.
- `}    }` formatting slip at test line 326 → **open**.

## Notes for later tasks (review focus; none belongs to T006)
- **T010 (repair):** `markers` is set only by `Read-Register` — the repair must read through it. The both-markers rule means a half-resolved page is not flagged as conflicted (flag above). A true duplicate id is renumbered silently by `Get-Current` on any verb; `-Apply state`/`change` aimed at a duplicated id lands on the earliest-created risk — the write line records the renumber, but the person is not asked.
- **T014:** `Get-Person` runs after `Read-Change`, so unset `user.name` + a bad change file reports exit 2 before exit 3. A leftover `.new` currently refuses `-Apply` (exit 1, "run -Finish first"); `-Finish` is not built.
- **T003/T004:** the ordinal compares now make the read-back check sensitive to æ→ae and case-only changes, so a UTF-8/CRLF check will hold on both editions. `Read-PageModel` normalises CRLF before parsing; a reason/description containing a literal CRLF would fail the read-back check and be refused (uncertain — not exercised).
- **T012:** nothing in this phase obstructs the no-PowerShell fallback; the state rules are all in the script, so the skills will need to restate them.

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P4: 1 task spec (T006), 2 done-whens, checkpoint "Each state is set only with its reason, decider or mitigation, a refused state leaves the page as it was, a risk's history only grows, and the script's tests prove every case."

Environment: PSModulePath exported before every command as ruled (Machine PSModulePath + `C:\Users\sva\AppData\Local\PowerShell\Modules`), so Pester 5.9.1 was found.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T006 | done-when 1: Tests.ps1 green under the `pwsh` command, T003–T005 tests still green, one test per scenario of §2 (one per example row of an outline) | pass | `pwsh` command as written → exit 0; a separate pwsh run of the same command with `-Output Detailed` added (to read test names) → "Tests Passed: 42, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0" |
| T006 | done-when 2: Tests.ps1 green under the `powershell` (5.1) command | pass | `powershell` command as written → exit 0 |
| P4 | checkpoint (the `check`: both commands in sequence with `&&`, as written) | met | `pwsh` → exit 0, then `powershell` → exit 0 |

Scenario coverage in the Detailed run (context "Decide a risk's state"):
- "A state is set when what it needs is given" — 8 tests, one per example row: Active→Mitigated, Active→Accepted, Active→Occurred, Active→Resolved, Mitigated→Active, Accepted→Active, Occurred→Active, Resolved→Active
- "A state whose requirement is missing is not set" — 6 tests, one per example row: Active→Mitigated (a reason), Active→Accepted (a reason, no decider), Active→Resolved (no reason), Active→Occurred (no reason), Resolved→Active (no reason), Active→Active (a reason)
- "The mitigation of a Mitigated risk cannot be emptied" — 1 test
- "A risk's history only grows" — 1 test
→ 16 tests for the four §2 scenarios, matching the done-when's titles.

Earlier contexts, all green in the same run: "Register a risk on a new page" (T003) 7 tests; "Read, number and score risks" (T004) 13; "Change a risk's fields" (T005) 4; "Review guards" 2 (as described). Total 7+13+4+16+2 = 42 = "Discovery found 42 tests".

Notes: the `-Output Detailed` run is a variant of the pwsh command used only to read test names; the exit codes above are from the commands run exactly as written (output discarded). The pwsh command was run twice in total (detailed variant, then as written), both exit 0. Tree-state fingerprint (`git status --short | md5sum`) was `ffe06e893a13852e0766801a9ff162e5` both before and after all runs — it covers status, not file contents, but it shows the same modified/untracked set, and I created or edited no repo file.

Verified: 2 pass · 0 fail · checkpoint met

### commit · 7631c2b
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P5 · Hand risks to an owner

### T007 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T007 (human task, built in the session that directs the run; test-first)
- Tests first: the three scenarios of §2 as four Pester tests (the no-open-risk outline's two rows). Seen red (4 failing on "verb 'handover' is not built yet", the 42 earlier green) before the code.
- risk-log.ps1 -Apply with verb handover (target = the leaving owner, to = the successor): both required (exit 1); the same name refused; open = not Resolved, owners compared as written after trimming, ordinally; none open -> exit 1 "<owner> has no open risks", page byte-identical; one write moves every open risk (owner, changed today, a handover line "Handed over from X to Y." by the person); Resolved risks untouched; register write line naming the risks moved.
- R25: the write's check refuses a new page holding any history line without a person (Test-Unsigned, exit 1 "a history line names no person"), and -Read lists such a line as a problem; the test removes data-by from one line by hand and an add is refused with the page unchanged.
- From P4's review flags: a state reason ending in ? or ! no longer gets a full stop appended; the T006 set test now asserts the fields and created date are unchanged by a state change; areas sort alphabetically ignoring case with an ordinal tie-break (OrdinalIgnoreCase, so both editions agree; non-ASCII letters still sort after Z); the "}    }" formatting slip fixed.
- Done-when 1 and 2: Pester 5.9.1, 46 passed, 0 failed on PowerShell 7.6.7 and on 5.1 (5.1 run alone: 5 min 42 s; the suite now takes about five minutes per edition, each test spawning the script in a child process).
gaps: 0 · flags: 1
- flag: the suite's run time (about 11 minutes for the check's two editions) is near the 10-minute limit of one tool call; a verifier should run each edition as its own call.

### review
Conventions read: `CLAUDE.md` (repo root; this repo has no `documentation/conventions/`) and `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` as PowerShell house style. Also read: S102 T007 whole, the D101 ids/S101 §1–§2 as traced by the ledger, the P4 review and the T007 attempt in `specs/project-management-risk/S101-project-management-risk.ledger.md`, all of `risk-log.ps1` and the diff of `risk-log.Tests.ps1`.

Reviewing: HEAD (uncommitted work as the diff) — 2 files, against S102 T007. Ran Pester 5.9.1: Windows PowerShell 5.1 → 46 passed / 0 failed; PowerShell 7 → 46 passed / 0 failed on the second run. (A first pwsh run, started in parallel with the 5.1 run, reported 45 passed / 1 failed; I did not capture which test, and it did not reproduce when re-run with failure details — likely load-related, but unconfirmed.) Two small manual experiments run in the scratchpad (below); no repo file edited.

## Conventions
| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1`, `risk-log.Tests.ps1` (the diff) | Pass | Pure ASCII kept (no non-ASCII byte in either file), same banner sections, reuses `Exit-Refused`/`Get-Field`/`Get-Text`/`Test-Same` — matches `validate-s102.ps1` and `CLAUDE.md`; no hard rule touched. |
| `risk-log.ps1:393` | Flag | Message uses a double-quoted string with nothing to expand where the neighbouring messages use single quotes — base judgment, cosmetic. |

## Correctness & safety
| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1:305-326` vs `:404-408` | Flag | `Get-Problems` checks only *risk* history lines for a missing person, but the new write check (`Test-Unsigned`) also checks the *register* history. A hand-edited register line with `data-by=""` therefore leaves `-Read` with no problems while every write is refused — reproduced: `-Apply` → `Not written: a history line names no person. The register is as it was.` (exit 1), with no pointer to a repair. Failure class: check disagrees with its reader → page unwritable. Fix: make `Get-Problems` report the register line too, so the repair path (T010) is offered. |
| `risk-log.ps1:393` (`Test-Unsigned` in `Write-Register`) | Flag | The write-side check is only reachable through a whitespace `-By`: `Get-Person` returns `''` for `-By ' '` (`if ($By)` is true, `Trim()` yields empty) — reproduced: handover refused, exit 1, page unchanged. A blank person should be caught in `Get-Person` (exit 3, which is T014's case). |
| `risk-log.ps1:608-631` (`Invoke-Handover`) | Pass | Inputs checked before any mutation; open = state not Resolved; owners compared ordinally after `Trim()` on both sides; all moves in one `Write-Register` (all-or-none); Resolved risks untouched; each moved risk gets its own `handover` line (kind is in the template's list) with `by`; register line lists the moved ids and renumbers; none-open exits 1 before any write. |
| `risk-log.ps1:372` (`Get-Areas` sort) | Pass | Case-insensitive ordinal with an ordinal tie-break behaves the same on both editions (both suites green); case-only duplicates still kept apart. No test pins the order (see spec table). |
| `risk-log.ps1:594` | Pass | A reason ending in `?`/`!` no longer gets a full stop appended. |

## Against the spec
| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `risk-log.ps1:608-631` | T007 · §2 scenario 1 (every open risk moves) | Pass | Owner, changed date, kind `handover`, `by`, history text naming both people; Resolved RISK-006 untouched — test checks each. |
| `risk-log.ps1:618-619` | T007 · §2 outline (no open risk) | Pass | Both example rows → exit 1 "Jonas Berg has no open risks", page byte-identical (hash asserted). |
| `risk-log.Tests.ps1` ("Every history line on every risk names a person", last 6 lines) | T007 · §2 scenario 3, "refused **by the write's check** with exit 1" | Flag | The test breaks `data-by` on a risk line by hand, so the refusal comes from `Get-Current`/`Get-Problems` ("cannot be read in full … run -Repair first"); the `'no person'` match is satisfied by that read-side message, not by `Test-Unsigned`. The write's check is never exercised — deleting `Test-Unsigned` would leave the suite green. A blank `-By` would hit the write-side check. The first half of the scenario (four writes by four people, every line signed) is served and tested. |
| `risk-log.ps1:393-395` | T007 · §4 Must (all or none) | Pass | One write; page unchanged on any refusal. |
| both files | T007 · `owns` | Pass | Only the owned script and its test changed in code (the ledger edit is the run's own). |
| `risk-log.ps1:608-631` | T007 · §5 (role as new owner, departed owner) | Pass | No refusal of a role, no noticing of a departed owner. |
| `risk-log.Tests.ps1` (whole) | T007 · §3 done-when 1 | Pass | One test per scenario/outline row, titled as the spec; both editions green. |

## P4's review flags taken into this attempt
- State change never touches a field (spec-table Flag) → **closed**: the set test now compares name, owner, impact, probability, area, description, mitigation and created before and after.
- `}    }` formatting slip at test line 326 → **closed**.
- Reason ending in `?`/`!` → **code closed**, but **no test** asserts it (every reason in the set examples ends in a letter).
- Area order → **code closed**, **no test** asserts it (the only area tests check count for case-only duplicates and the sorted set; the sort comparator is unpinned).
- Half-resolved merge (one marker line deleted, `=======` left) reads as a clean register → **still open**; P4 marked it uncertain and tied it to T010 — the T007 ledger entry neither closes nor defers it, so it should be written down as handed to T010.

## Notes for later tasks (review focus; none belongs to T007)
- **T010 (repair):** `Get-Problems` now includes "a history line of RISK-NNN names no person" — the repair has no person to put there, so it must ask for one or refuse. The register-level unsigned line is not a problem at all today (first correctness Flag). Markers are still set only by `Read-Register`.
- **T014:** `Get-Person` should refuse an empty trimmed `-By` with exit 3; it is not yet an `-Apply`-first step (`Read-Change` still runs before it). A leftover `.new` still refuses `-Apply` with "run -Finish first"; `-Finish` not built.
- **T003/T004:** nothing in this phase obstructs the UTF-8/CRLF checks; owner and handover texts go through the same ordinal read-back comparison.
- **T012:** nothing in this phase blocks the no-PowerShell fallback; the handover rules live in the script alone, so the skills will have to restate them (open = any state but Resolved; owners compared as written after trimming; one write; each risk its own signed line).

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P5: 1 task spec (T007), 2 done-whens, checkpoint "Every open risk of the owner moves to the new owner with its own signed history line, resolved risks keep their owner, an owner with no open risks writes nothing, and the script's tests prove it."

Environment: as ruled, `export PSModulePath="$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PSModulePath','Machine')");C:\Users\sva\AppData\Local\PowerShell\Modules"` first in Bash. Both halves of the check run with exactly the commands as written, sequentially, each as its own call — never in parallel.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T007 | done-when 1: `risk-log.Tests.ps1` green under `pwsh -NoProfile -Command '…Invoke-Pester…'`, T003–T006 tests still green, one test per scenario of §2 (one per example row) | pass | pwsh run → "Tests Passed: 46, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0", exit=0, 423.7 s; test names: see note below |
| T007 | done-when 2: green under `powershell -NoProfile -ExecutionPolicy Bypass -Command '…Invoke-Pester…'` | pass | powershell run → "Tests Passed: 46, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0", exit=0, 1153.7 s |
| P5 | checkpoint (the `Check` command: both halves, sequentially) | met | pwsh exit 0 then powershell exit 0; 46 passed / 0 failed on each edition |

Test names per §2 scenario (read from `/c/Privat/Repositories/asimov/plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1`, context 'Hand open risks to an owner', lines 480-548 — the default Pester output does not list names, and I did not run a third time with detailed output):
- Scenario 1 → 'Every open risk of the owner moves to the new owner' (line 493): asserts RISK-002 (Occurred) and RISK-004 (Accepted) owned by Sara Nygaard, states kept, changed today, last history line kind handover by Maja Holm naming Jonas Berg and Sara Nygaard; RISK-006 (Resolved) unchanged.
- Scenario Outline 2 → 'A handover with no open risk to move writes nothing (<situation>)' (line 520), a `-ForEach` with two rows matching the two example rows ("Jonas Berg owns only RISK-006 in state Resolved", "Jonas Berg owns no risk"); each expects exit 1, "Jonas Berg has no open risks", page byte-identical.
- Scenario 3 → 'Every history line on every risk names a person' (line 533): add/change/state Mitigated/handover with four different -By → history by Ada One, Bo Two, Cy Three, Di Four; then a page with a blank data-by is refused with exit 1 and "no person", page unchanged.
- The earlier tasks' tests are in their own contexts; the 'Review guards' context holds two tests belonging to no task spec. The 46 count and green result come from the runs; the one-per-scenario mapping comes from reading the file.

Read-only boundary: tree fingerprint (`git ls-files -s -m -o --exclude-standard | sha256sum`) identical before and after both runs (5521cfa35084eb8105c1e52dd0e29aa75aae646f1c9be53840de096cd83cbb9b). No edits made; my only output files are the two run logs in the session scratchpad, outside the repo. No test re-run.

Verified: 2 pass · 0 fail · checkpoint met

### commit · 1878c14
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P6 · Review the register

### T008 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T008 (human task, built in the session that directs the run; test-first)
- Test harness first: Invoke-RiskLog now runs the script in the Pester process by default (a script's exit ends only the script and sets $LASTEXITCODE; parameters splatted by name), and only the two-edition test starts pwsh and powershell; the suite went from about 7 min (pwsh) and 19 min (5.1) to under 1.5 min on each, with the same 46 tests and no assertion changed.
- Tests: the five scenarios of §2 as six Pester tests (the review outline's two rows). Seen red (6 failing, 46 earlier green) before the code.
- risk-log.ps1 -View: the fixed 80-column view of D101 §5 S2 and the mockup's view function: "Risk log . <path>", "Updated <date> . N risks", the count per state, then each open state group with every risk in full (id, score, name; owner . area . I P . changed; description wrapped at the text column; Mitigation wrapped; "none written" for an empty description or mitigation; "no area" for an empty area), each risk closed by a rule of U+2500 to column 80, Resolved as "Resolved (n)" only; words wrapped, an over-long word cut, never a line over 80; RL12 order; labels in fixed English, content as kept; no verdict; writes nothing; an unreadable register refused with "run -Repair first"; no page -> "No register and no opt-out at <path>." exit 0.
- -Read with no page -> exit 0, register "none", empty lists.
- -Apply review: no page -> exit 1, nothing written; otherwise one register-history line of kind review (data-with = the participants, text "Reviewed[, with A, B].") by the person, last-updated today, no risk's changed date or history touched.
- From P5's review flags: Get-Problems now reports an unsigned register-history line too (the reader agrees with the write's check); a blank -By (spaces) is no person (exit 3).
- Done-when 1 and 2: Pester 5.9.1, 52 passed, 0 failed on PowerShell 7.6.7 (1 min 14 s) and 5.1 (1 min 32 s).
gaps: 0 · flags: 1
- flag: the view's labels are fixed English, as the S102 says; the stored history texts the script writes ("Created.", "Reviewed, with ...") are English too, which RL16 (content in the project language) leaves to T011/T012 to settle.

### review
Conventions read: `CLAUDE.md` (repo root — this repo has no `documentation/conventions/`), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (PowerShell house style). Also read: the T008 S102, the S101 review focus, the ledger's T008 attempt, D101 F4/RL9/RL10/RL12/S2, the mockup's `view` function.

Reviewing: HEAD (uncommitted) vs S102-008 — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`)

Ran the suite once per edition: PowerShell 7 → 52 passed / 0 failed (1 min 22 s); Windows PowerShell 5.1 → 52 passed / 0 failed. Script and tests are pure ASCII (no char > 0x7F). Probed by hand: a hand-removed `data-by` on the register line → `-Read` `problems` entry and `-View` refusal; long name + long description wrap with the widest line exactly 80 columns.

**Conventions** (CLAUDE.md + house style)

| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1` (whole diff) | Pass | House style kept: `Set-StrictMode`, `Exit-Refused`/`Exit-Unreadable` helpers, `Ordinal` string compares (the earlier flag class), pure ASCII, same code on both editions. |
| `risk-log.Tests.ps1` (new Context) | Pass | Reuses the helpers, `TestDrive:`, non-ASCII built with `[char]`. |
| `risk-log.ps1:19-47` (comment-based help) | Flag | `-View` is documented and `review` already listed in the `verb` line, but the `.PARAMETER Read` text doesn't say that a missing page now returns `register: none` — a changed contract T013/T014 will read. |

**Correctness & safety**

| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1:635-648` (`Invoke-Review`), `:701-707` (`Invoke-View`) | Flag (look-ahead → T009) | Neither branches on `register = 'opt-out'`. Forcing `data-register="opt-out"` onto a kept page: `-View` printed an empty-looking "0 risks" log and `-Apply review` exited 0 and wrote it. `Format-Page` always renders the kept form (`:211`), so a real opt-out page (whose reason/where/decider are not in the model) would be rewritten as an empty register by a review — failure class: data loss. T009 should make both refuse or branch. |
| `risk-log.ps1:484-493` + `:643` | Flag (uncertain) | `Invoke-Review` goes through `Get-Current`, which renumbers duplicate ids — so a review of a register holding duplicates adds a `renumber` line to a risk's history, against RL10's "a confirmed review adds none to any risk". It matches the "next write renumbers" rule and the register line names it, but RL10/the scenario's "no risk's history moved" don't carve it out; settle before T010. |
| `risk-log.ps1:106` | Flag | Blank `-By` is closed only when git has no name (exit 3); with `git config user.name` set, `-By '  '` falls through to the git name and writes as that person (reproduced). Consistent with "else git config", but the ledger's "a blank -By is no person (exit 3)" overstates it; settle when T014 asks for the name once. |
| `risk-log.ps1:689` | Flag (uncertain) | An empty area prints `no area`; the S102/D101 S2 only invent "none written" (description/mitigation), and the mockup prints the empty string. Harmless and in the spirit of the layout, but a new label nobody specified. |
| `risk-log.ps1:656-670` (`Format-Wrapped`) | Flag (base judgment) | Width counts UTF-16 units and the over-long-word cut can split a surrogate pair — fine for the æøå focus; only matters for emoji/wide characters. |
| `risk-log.ps1:701-707` | Pass | `-View` is read-only; a register with a missing impact is refused ("run -Repair first") before any score is formed, so `0` is never shown; `Get-Score` returns `''`. |
| `risk-log.ps1:710-713` | Pass | `-Read` with no page → `register: none`, exit 0, writes nothing. |

**Against the spec** (S102-008)

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| both files | owns (create/modify/test) | Pass | Only the owned script and test file changed; ledger/specs are the run's. |
| `risk-log.ps1:635-648` | §2 scenario 1 (review) | Pass | One `review` line by the person with `with`, `updated` moved, no risk's `changed`/history touched; refused without page → exit 1, no `.new`. |
| `risk-log.ps1:672-699` | §2 scenarios 3–4, §4 Must (layout) | Pass | Header, per-state counts, groups in fixed order, rule per risk, Resolved as count only, ends after the risks, no verdict text. Rule = 2 + 78 U+2500, as the mockup. |
| `risk-log.Tests.ps1:641` | §2 scenario 2 "on the page the Resolved group is last" | Flag | `LastIndexOf('<article class="risk"') -gt IndexOf('<details …')` is always true once a Resolved risk exists — it proves nothing about order; the neighbouring regex proves the Resolved risks sit inside the details, not that no open group follows it. "Folded" is proven (exact `<details class="resolved-group">`, no `open`). Assert the last `<article>` is a Resolved id, or that `</details>` follows the last open group. |
| `risk-log.Tests.ps1:~653` | §2 scenario 3 | Flag | The unanchored `'12'` in the "every field shown" list would also match a December date; the score assertion should be anchored to the `RISK-001` line. |
| `risk-log.Tests.ps1` (new Context) | P5 flag 1 (register-history line with no person) | Flag | Closed in code (`Get-Problems`, `:310`) and my probe confirms it — but no test holds it closed; the suite stays green if the line is removed. This is the pattern P2/P3 already flagged. |
| `risk-log.Tests.ps1` (new Context) | P5 flag 2 (blank `-By`) | Flag | Same: closed in code, no test (neither the exit-3 case nor the git-name-set case). |
| `risk-log.ps1`, test harness | review-focus T003 (æøå on both editions) | Flag (look-ahead; see harness below) | `Names outside ASCII…` still runs in a child process per edition, but it only reads the page file bytes. |

**Harness change (`Invoke-RiskLog` in-process)**

The 46 earlier tests are textually unchanged (the diff touches only the helper and adds the new Context), and all 52 pass on both editions. Argument splatting by name works for every call shape the suite uses (switch followed by a `-Something` → `$true`; no value starts with `-`); absolute paths make the cwd difference harmless; a script `exit` ends only the script and `$global:LASTEXITCODE` is reset before each call; `$ErrorActionPreference`/strict mode stay scoped to the script; `GIT_CONFIG_GLOBAL` and the console encoding are saved/restored in `BeforeAll`/`AfterAll`; the no-`-By`/exit-3 test still works (git runs from the pushed location with the empty global config). Two things are weakened or fragile:
- **No stdout round-trip across a process boundary** — nothing now exercises the script's `[Console]::OutputEncoding` line or a `-Read` of non-ASCII JSON through a child shell, which is exactly where 5.1 differs from 7. No earlier test did it either (only page bytes), so no earlier assertion is weaker — but the T003 focus ("read back unchanged on both shell editions") now has no test on the read-back path. Add one non-ASCII `-Read` in the two-edition test before T014.
- **A crash now surfaces as an exception in the test rather than exit code 1** — a test asserting a non-zero code on an unexpected exception would behave differently. None does today.

**P5 flags**: closed in code, no regression test — register-history "names no person" in `Get-Problems`; blank `-By` in `Get-Person`. Closed — reader and write check now agree on unsigned lines. Carried, not new in this diff — the P5 flag on the earlier no-person test passing for the wrong reason.

**Things that would make later tasks hard**: T009 — `-View`/`-Review` on an opt-out page (above). T010 — a duplicate-id register is shown by `-View` without a hint and a review renumbers it; `-View`/`-Read` report no `duplicates` list (earlier flag). T014 — the "ask for the name once" flow can't tell a blank `-By` from an omitted one. T011/T012 — stored history texts the script writes ("Reviewed, with …") and the view's labels are English (the ledger's own flag).

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P6: 1 task spec (T008), 2 done-whens, checkpoint "The view lists every open risk in full in the fixed order with resolved ones as a count, a confirmed review moves only the register's date and signs its history, a missing register writes nothing, and the script's tests prove it."

Environment: PSModulePath exported in Bash (Machine value + `C:\Users\sva\AppData\Local\PowerShell\Modules`) before every run, as the ruling says; the two editions run one after the other.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T008 | done-when 1: `risk-log.Tests.ps1` green under `pwsh -NoProfile -Command '…Invoke-Pester…'`, T003–T007 tests still green, one test per scenario of §2 | pass | as-written command exit 0, last line "Tests Passed: 52, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0"; context "Review view and confirmed review" holds 6 tests (below); earlier contexts (Register a risk on a new page; Read, number and score risks; Change a risk's fields; Decide a risk's state; Hand open risks to an owner) all green |
| T008 | done-when 2: green under `powershell -NoProfile -ExecutionPolicy Bypass -Command '…'` | pass | as-written command exit 0, last line "Tests Passed: 52, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0" |
| T008 | per scenario of §2, one test each / per example row | pass | context "Review view and confirmed review" → 6 passing tests: "A confirmed review moves only the register's date (with participants)", "A confirmed review moves only the register's date (no participants)", "Page and view list risks in the fixed order", "The view shows every open risk in full and writes nothing", "The view never prints a verdict", "A repo with neither a register nor an opt-out" — 5 scenarios, 2 outline rows; same 6 names on both editions |
| P6 | checkpoint | met | the six tests above pass on pwsh and on Windows PowerShell 5.1 (52/52 each) |

Notes:
- The as-written check prints no per-test names under default output; to read them I ran the same command with `-Output Detailed` added (and `$r` so the exit code still came from the failure counts) — an extra run, not a replacement for the as-written runs — once on pwsh and once on 5.1: both exit 0, 52 passed. Each edition thus ran the suite twice with identical results (pwsh 3× total, 5.1 2×).
- The "Review guards" context holds 2 tests belonging to no task spec, as stated; both pass ("Conflict markers make the register unreadable, a line of equals signs alone does not", "Areas that differ only in case are both listed").
- Working tree unchanged: `git status --short` before and after shows the same three modified files (`risk-log.Tests.ps1`, `risk-log.ps1`, ledger `S101-project-management-risk.ledger.md`); I wrote only output captures to the scratchpad, outside the repo.

Verified: 3 pass · 0 fail · checkpoint met

### commit · e875695
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P7 · Record an opt-out

### T009 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T009 (human task, built in the session that directs the run; test-first)
- Tests first: the five scenarios of §2 as nine Pester tests (the written outline's two rows, the refused outline's three rows), plus four review guards: a review of an opt-out page leaves it as it was (P6 data-loss flag), an unsigned register-history line is a problem, a blank -By with no git name is exit 3 (P5 flags), and the non-ASCII two-edition test now also reads the register back through each shell's stdout (P6 flag). The order test now asserts the last article is a Resolved one and no state group follows the resolved group (P6 flag). Seen red (9 failing, 54 green) before the code.
- risk-log.ps1 -Apply with verb optout and an "opt-out" object { reason, where, decider }: reason one of elsewhere, not-worked (else exit 1); elsewhere needs where; a decider always; the first write names the language; the page is the template's opt-out form (data-register opt-out, section.opt-out with data-reason, data-where, data-by, data-date; title "No risk register kept here"; first paragraph the reason sentence with its place), the register history one opt-out line by the person. An opt-out over a register with risks -> exit 1 "a risk is never deleted", page byte-identical; a second opt-out -> exit 1.
- -Apply add on an opt-out page replaces it with a kept register: RISK-001, the language kept, the opt-out's history line kept, and a new top line of kind replaced-opt-out naming the reason, the decider and the date.
- -View of an opt-out page prints "No risk register kept here.", the reason with its place, and "Decided by X on <date>."; -Read returns the opt-out; -Apply review on an opt-out page is refused (exit 1), so a review can never render an opt-out page as an empty register.
- The model carries optout (read from section.opt-out, compared by the write's check); Get-Problems flags an opt-out without reason, decider or date, or one holding risks. -Read's help states the register "none" answer (P6 flag).
- Done-when 1 and 2: Pester 5.9.1, 63 passed, 0 failed on PowerShell 7.6.7 (57 s) and 5.1 (1 min 49 s).
gaps: 0 · flags: 1
- flag: two design questions from P6's review stay open, for the person directing the run: should a review renumber duplicate identifiers (a renumber line on a risk, which RL10 says a review never adds), and is "no area" the right label for an empty area in the view.

### review
Conventions read: `CLAUDE.md` (repo root, as the repo's conventions), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (PowerShell house style). Also read: S102-…-009, S101 §1–§2, the ledger's P6 review and T009 attempt, the template's `form:opt-out` block, the D101 sections named. (No `documentation/conventions/` exists here.)

Reviewing: HEAD (uncommitted work) — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`); the ledger edit is the run's own.

Ran the suite on pwsh: 63 passed / 0 failed (1m24s). Did not run the Windows PowerShell 5.1 edition (the ledger reports 63 green there). Probed by hand (pwsh) with a Danish opt-out ("Åse Ørsted" decider): name and page survive write → `-Read` → `-View` → a CRLF round-trip, and a later `add` replaced the opt-out keeping its history line.

**Conventions**

| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1` (whole diff) | Pass | House style kept: `Exit-Refused`/`Exit-Unreadable` helpers, ordinal compares via `Test-Same`, `Set-StrictMode`-safe `.Contains('optout')` guards, pure ASCII, one code path for both editions. |
| `risk-log.ps1:22`, `:38` | Pass | Help text states the `-Read` "none" answer (a P6 flag) and the `opt-out` field. |
| `risk-log.Tests.ps1` (new Context) | Pass | Matches the suite's helpers and TestDrive fixtures; one test per example row as the done-when asks. |
| `CLAUDE.md` hard rules 1–11 | Pass | None apply to these two files. |

**Correctness & safety**

| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1:137-140`, `:766` | Flag | Sentence assembly: a `where` ending in a full stop gives "Risks are handled elsewhere: Jira.." (reproduced) — the doubled stop lands in the lead paragraph, the view, and the `replaced-opt-out` history line, which is append-only and never fixable. |
| `risk-log.ps1:340-345` | Flag | `Get-Problems` accepts an `elsewhere` opt-out page with an empty `data-where`, which the write refuses — the reader is looser than the writer (the earlier register-history fix "reader agrees with the write's check" sets the pattern). |
| `risk-log.ps1:772-776` | Flag | The refusal for an existing page says "The register holds risks" without checking: a kept page with zero risks (hand edit) gets a wrong message; the page is also read with `Read-Register` but never through `Get-Problems`, so a conflicted page gets the same wrong message. |
| `risk-log.ps1:271-284` | Flag | For `not-worked` the template's "Where" row renders with an empty `<dd>` (the template has no way to drop it) — cosmetic. |
| `risk-log.ps1:155-157` | Pass | The write's read-back check now covers the `optout` line, so a lossy opt-out page is refused before the rename; no `.new` remains on any refusal (tested). |
| `risk-log.ps1:537-541`, `:555-557` | Pass | Replacement keeps the opt-out's own history line, sets `optout` null, and `Test-Kept` accepts it as the tail; the new top line names reason, decider and date. |
| `risk-log.ps1:680` | Pass | A review of an opt-out page is refused (exit 1), page unchanged — closes P6's data-loss flag, held by a test. |
| `risk-log.ps1:748-755` | Pass | `-View` of an opt-out page prints the reason with its place, then the decider and the date. |

**Against the spec**

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| both files | owns | Pass | Only the owned script and test file changed. |
| `risk-log.ps1:760-780` | §2 outline 1 / §4 Must | Pass | Exit 0, page titled "No risk register kept here", `data-register="opt-out"`, `section.opt-out` attributes as D101 §6.4 names them, language kept, one `opt-out` history line by `-By`. |
| `risk-log.ps1:762-767` | §2 outline 2 / §4 Must | Pass | Exit 1 for an invalid reason, `elsewhere` with no place, or no decider; no page and no `.new` left. |
| `risk-log.ps1:772-775` | §2 scenario 4 | Pass | Opt-out over a register refused with "a risk is never deleted", page hash unchanged; a second opt-out also refused. |
| `risk-log.Tests.ps1` (Context "Opt out and replace it") | §3 done-when 1 | Pass | Nine tests for the five scenarios (written outline 2 rows, refused outline 3 rows) plus four review guards. |
| `risk-log.Tests.ps1:~669` | P6 flag (unanchored `'12'` in the view test) | Flag | Not mentioned in the T009 attempt and still open: the bare `'12'` would also match a date; anchor the score to the RISK-001 line. |
| ledger T009 vs P6 flags | P6 flags taken in | Pass | Closed with tests: opt-out review data loss, unsigned register-history line, blank `-By` with no git name (exit 3), non-ASCII read-back through each edition's stdout, the Resolved-group order assertion, the `-Read` "none" help. The two design questions (review renumbering duplicates vs RL10; the "no area" label) are carried openly. |
| review focus T003/T004 | æ/ø/å, CRLF | Pass | Non-ASCII decider and CRLF pages checked as above; the two-edition test now reads the name back through each shell. |

**Hard later (look-ahead, none belongs to T009)**
- T010: `Get-Problems` reports "an opt-out page holds risks", but `-Repair` has no rule for it; `-View` and every write refuse such a page, so the repair must decide which form wins.
- T010: `Invoke-Review` still renumbers duplicate ids through `Get-Current` (the carried RL10 question).
- T014: blank `-By` falls through to the git name when git has one (P6 flag, still true), so the "ask once" flow can't tell blank from omitted.
- T011/T012: the opt-out sentences and history texts the script writes are fixed English, like the other stored texts the ledger already flags for RL16.

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P7: 1 task spec (T009), 2 done-whens, checkpoint "An opt-out is written only with its reason, its place and its decider, a first risk replaces it and names it in the history, and the script's tests prove it."

Environment: as ruled, PSModulePath exported in Bash before every run (Machine value from `[Environment]::GetEnvironmentVariable('PSModulePath','Machine')` + `;C:\Users\sva\AppData\Local\PowerShell\Modules`); Pester 5.9.1 loaded in both editions. All commands run from `C:/Privat/Repositories/asimov`; the two halves sequentially.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T009 | done-when 1: green under `pwsh -NoProfile -Command 'Import-Module Pester ... exit (... FailedCount + FailedContainersCount)'`, T003–T008 tests still green, one test per scenario of §2 | pass | pwsh, as written → "Tests Passed: 63, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0", exit 0 (49 s) |
| T009 | done-when 1 — test coverage of §2 | pass | Detailed run lists 8 tests in context "Opt out and replace it": An opt-out with its reason and decider is written (elsewhere) / (not-worked); An opt-out missing what it needs is not written (elsewhere, no place) / (elsewhere, no decider) / (not-worked, no decider); Registering a risk replaces the opt-out; An opt-out cannot replace a register that holds risks; The view of an opt-out page states the opt-out — one per scenario, one per example row. Contexts for T003–T008 (Register a risk on a new page; Read, number and score risks; Change a risk's fields; Decide a risk's state; Hand open risks to an owner; Review view and confirmed review) all present and green, plus "Review guards". |
| T009 | done-when 2: green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester ...'` | pass | powershell 5.1, as written → "Tests Passed: 63, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0", exit 0 (78 s) |
| P7 | checkpoint — the check command (both halves `&&`-chained) | met | both halves run separately as written, each exited 0 (not run as one `&&` shell line) |

Notes:
- The pwsh half ran twice: first with `-Output Detailed` added to read test names (63 passed, exit 0, 57.6 s), then exactly as written (63 passed, exit 0). Both reported.
- Tree untouched: `git status --short` hash identical before and after (ffe06e89…); the three modified files (`risk-log.Tests.ps1`, `risk-log.ps1`, ledger) were already modified at start.

Verified: 3 pass · 0 fail · checkpoint met

### commit · af92fd2
go by SimonVilandt on 2026-10-29 · 2 files · ledger

## P8 · Repair and finish writes

### T010 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T010 (human task, built in the session that directs the run; test-first)
- Tests first: the five scenarios of §2 as six Pester tests (the leftover outline's two rows); the merge test builds a real git merge in TestDrive (base, two branches each adding RISK-007 and changing RISK-002's probability, one side's RISK-007 created earlier). Seen red (6 failing, 63 green) before the code. The view test's score assertion is now anchored to the RISK-001 line (P6/P7 flag).
- Rulings by SimonVilandt at the start of P8, on two questions P6's review raised: (1) a confirmed review of a register holding the same identifier twice is refused and points to -Repair, which renumbers it, so a review never adds a line to a risk (RL10); (2) an empty area shows in the view as "area none written", the one phrase the design uses for an empty field. Neither is written in the D101 yet.
- risk-log.ps1 -Repair: a JSON proposal { problems, changes }, writes nothing. Each change has key, target, field, before, after, ask and a note: the questions of a merge (a field changed differently on the two sides, before = both values, asked), the renumbering of true duplicates (the earliest-created keeps the identifier, ties to the first on the page; after = the next free identifier), and one entry per broken field (name, owner, impact, probability, state asked; created and changed proposed from the history; a history line with no person asked; the register's updated and kind proposed).
- A page with conflict markers is merged from git's :2: and :3: only: a risk on one side is kept; the same risk (same created date and first history line) on both is one risk, its differing fields asked, its history the union by date; two risks under one identifier stay two and are renumbered; the register history is the union, newest first (a stable sort by hand, since 5.1's is not).
- -Apply repair: the plan is computed again, the answers taken from the proposal by key (an unanswered question exits 1), the result must read without problems, one register line of kind repair "Repaired: <each change before -> after>", written through .new, check and rename; the check holds the page to the plan with only its unasked changes, and in a repair a history line with no person may gain one (Test-LineKept -Fill), nothing else.
- -Finish: nothing to finish -> exit 0; else prints what the .new changes (lines added and removed), checks it (placeholders, problems, unsigned lines, nothing the page held dropped), deletes it either way, and on a pass writes it with a finish line through the usual write; on a fail exits 1 "Deleted ..." with the page as it was.
- -View now shows a register with problems as the page holds it (a risk with no impact shows no score) and refuses only a page with conflict markers; a review refuses a register holding duplicates.
- From P7's review flags: a place ending in a full stop no longer doubles it; the reader flags an "elsewhere" opt-out with no place; an opt-out over an existing page says which of risks, problems or an empty register stops it.
- Done-when 1 and 2: Pester 5.9.1, 69 passed, 0 failed on PowerShell 7.6.7 and 5.1 (5.1: 1 min 54 s; the PowerShell 7 run passed too, but its wall time spanned the machine sleeping overnight).
gaps: 0 · flags: 1
- flag: the two rulings above change what the design says (RL4 renumbers on the next write; S2 names no label for an empty area); the D101 should record them.

### review
Conventions read: `CLAUDE.md` (repo root, as the repo's conventions; this repo has no `documentation/conventions/`), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (PowerShell house style). Also read: S102-010, the S101 ledger's T010 attempt and P7 review, the script and tests whole.

Reviewing: HEAD (uncommitted work) — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`); the ledger edit is the run's own.

Ran Pester 5.9.1 on both editions as the done-whens write it: 69 passed / 0 failed on pwsh 7 and on Windows PowerShell 5.1. Probed by hand in scratch git repos with real `-Repair`/`-Apply` calls; the æ/ø/å merge probe passed on both editions (names/owners read from `git show :2:`/`:3:` intact, including non-asked names).

**Conventions**

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1 (whole diff) | Pass | `Exit-Refused`/`Exit-Unreadable` helpers, ordinal `Test-Same`, pure ASCII, one path for both editions, only the two owned files changed. |
| risk-log.ps1:752, :793, :732 | Flag | `-contains`/`-notcontains` are case-insensitive in PowerShell, against the script's ordinal house style: history lines differing only by case count as the same in `Merge-Sides`, and a case-only change is missing from `-Finish`'s printed diff. |
| risk-log.ps1:688-690 | Flag | After the new duplicate-refusal at :686, `if ($current.Renumbered.Count -gt 0) { $text += … }` at :690 is dead code. |
| risk-log.Tests.ps1 | Flag | Neither ruling has a test (a review refusing duplicate identifiers; "area none written"), nor do the three P7 fixes (doubled full stop, "elsewhere but not where" reader problem, the three-way opt-out refusal message). Earlier tasks closed their review flags with tests. |
| ledger T010 flag | Flag | Both rulings change what the D101 says (RL4 renumbers on the next write; S2 names no label for an empty area); neither is recorded there yet — a hard-rule-6 drift risk. The ledger already notes it. |

**Correctness & safety**

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1:306-332, :820-846 | Fail | Data loss: a repair writes the page from the parsed model, and a history `<li>` that no longer matches the reader (e.g. `<span class="who">` lost in a hand edit) vanishes silently. Reproduced: RISK-001 had 2 lines; with RISK-002's impact removed, `-Read` showed 1 line and no problem for it; the confirmed repair wrote the page without it, and the write's check passed because it compares the parse to itself. This is the S102 "must not remove a history line" and the stop. Compare the count of `<li>` with the parsed lines, or list the broken line as a proposal question. |
| risk-log.ps1:745-752 (`Merge-Sides`) | Fail | Two different risks are merged into one and one is lost: identity is `id` + `created` + first history line, and that line is "Created. Impact I, Probability P (score S)" — no name. Reproduced: two branches each added a different RISK-003 on the same day by the same person with the same impact/probability → the merge treated them as one risk and asked "name FromA / FromB"; the answer kept one name and the other risk is gone. Dates are day-granular, so same-day is the common case. A true duplicate is only renumbered when the creation signature differs. |
| risk-log.ps1:737-738 (`Merge-Sides`) | Flag | Register-history lines identical in date/person/kind/text on both sides are collapsed to one — in the same probe, B's "RISK-003 registered." and "RISK-002 changed." were dropped. The "loses nothing" bar is checked only against the merged model (`$held.Model`), never against the two sides, so this cannot trip the check. |
| risk-log.ps1:726-779 (`Merge-Sides`, `Get-RepairPlan`) | Flag | `register` is forced to `kept` and `optout` to null: two sides that each recorded an opt-out merge into an empty kept register and the opt-out reason/place/decider are lost. |
| risk-log.ps1:726-779 | Flag | Every field that differs between the sides is asked, including one changed on only one side (with only `:2:`/`:3:`, as the S102 requires, there is no base to tell). The question text "changed differently on the two sides" overstates it; the proposal should say so. |
| risk-log.ps1:776-805 (`Get-RepairPlan`) | Flag | Problems the reader reports with no repair entry: a risk with no `RISK-NNN` identifier gives `changes: []`; an opt-out with no reason/decider/date, or one that holds risks, gives `changes: []` too — and `-Apply repair` then says "The register needs no repair", contradicting the problem `-Read` reports, so the run dead-ends. (The P7 "hard later" item — opt-out page holding risks has no repair rule — is still open.) A question could keep these. |
| risk-log.ps1:806-812 | Flag | Change keys are `"$who/$field"`, so two risks sharing an identifier (the typical merge case) and missing the same field get the same key, and one answer fills both. Add the index to the key. |
| risk-log.ps1:936-945 (`Invoke-View`) | Flag | The new "show a register with problems as the page holds it" regresses two cases (reproduced): an opt-out page with its `section.opt-out` lost used to be refused and now ends in a raw StrictMode exception ("The property 'reason' cannot be found", exit 1, no message); a risk with an invalid state is silently omitted (header says "2 risks", one shown, no hint). The no-impact case the S102 asks for is fine. |
| risk-log.ps1:857-880 (`Invoke-Finish`) | Pass | Prints added/removed lines, checks, deletes the `.new` either way, exits 1 with "Deleted …" on a failing page leaving it byte-identical, writes with a `finish` line on a pass (re-rendering the parsed `.new` rather than renaming the file itself — same result). |
| risk-log.ps1:826-856 (`Invoke-RepairWrite`) | Pass | Proposal read-only (writes nothing); the write recomputes the plan and ignores any `after` the proposal gives for an unasked change; unanswered question → exit 1; result must read without problems; `.new` → check → rename; `Fill` permits only a missing person to be added to a history line. |
| risk-log.ps1:755-775 (`Read-Sides`) | Pass | `git show :2:`/`:3:` only; clear refusal if git has no side; non-ASCII survived on both editions. |
| risk-log.ps1:784-796 (duplicate renumbering) | Pass | Probed with a register edited to hold RISK-001 twice: a review is refused pointing to `-Repair`; the repair renumbers RISK-002 with a `renumber` line, the earliest-created keeps the identifier, nothing lost. Ruling matches code. |
| risk-log.ps1:925 | Pass | Empty area → "area none written", as ruled. |

**Against the spec**

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| both files | owns | Pass | Only the owned script and its test file changed. |
| risk-log.ps1:820-846 | S102-010 · §4 Must not (remove or rewrite a history line) | Fail | A history line a hand edit broke is neither restored from the page nor listed as a question — it is dropped (first Correctness Fail). |
| risk-log.ps1:726-779 | S102-010 · §1 "a confirmed repair loses nothing" + §2 conflict scenario | Fail | The merge can fold two distinct risks into one (Merge-Sides Fail). The test builds its merge with `data-created` changed by hand, so the same-day case is never exercised. |
| risk-log.ps1:776-805 | S102-010 · §4 Stops | Flag | Where a repair has no way to keep a field (missing identifier, opt-out problems) it silently returns an empty proposal instead of asking or stopping with a reason. |
| risk-log.Tests.ps1 (merge test) | S102-010 · §2 scenario "Conflict markers…" | Flag | The test checks the proposal, as the S102 words it, but never applies the merge; the review focus asks for "a repair that merges both sides", and the confirmed-merge path (both sides' risks present, history union, renumber line) is untested — which is how the two merge defects above got through. |
| risk-log.ps1 / Tests | S101 review focus: no impact → no score, read reports the problem | Pass | `-View` shows `RISK-005  Risk 5` with no score; `-Read` names RISK-005 and its impact; test anchored to the RISK-005 line. |
| risk-log.ps1 / Tests | S102-010 · §2 scenarios 1, 2, leftover outline | Pass | Each has a test, one per example row; behaviour probed by hand. |
| risk-log.ps1:137-140, :344, :963-968 | P7 review flags taken in | Pass | Doubled stop, the reader's "elsewhere but not where" problem, and the clearer opt-out refusal are in the code. Two P7 items stay open: opt-out page holding risks has no repair rule (above); the cosmetic empty "Where" row for `not-worked` untouched. |
| risk-log.ps1:680-686, :925 | Ledger rulings by SimonVilandt | Pass | Both are what the code does (reproduced); both lack tests and D101 entries (see Conventions). |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### T010 · attempt 2 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T010 attempt 2 (human task, built in the session that directs the run), against P8 review round 1
- Fail 1 (a damaged history line dropped by a repair): Read-Lines now reads every <li> of a history list; one that no longer matches the template is read from what is left of it (its attributes, its text with the date and person stripped) and marked damaged; -Read lists "a history line of X is damaged" (and for the register's own lines); -Repair proposes restoring it (after = the text read, unasked); the repair clears the mark. A test damages RISK-001's change line and removes RISK-002's impact: the line is read, reported, and kept through the repair.
- Fail 2 and 3 (two risks added the same day folded into one by a merge): a risk's first history line now carries its name ("Created: <name>. Impact ..."), and the merge's identity is the identifier, the created date and that line; a test merges two branches that each add a different RISK-003 on the same day by the same person with the same impact and probability, applies the repair, and finds both risks, one renumbered RISK-004 with a renumber line, no markers left.
- Histories are joined, not unioned by key: the lines both sides share are their common start (oldest first) and are kept once; every line after it is a side's own and is kept, even one identical to the other side's. The register's own lines now say what they are about ("RISK-003 registered: <name>.", "RISK-002 changed: <field> a -> b.", "RISK-002 resolved: <reason>."), so two sides writing on one day stay two lines; the test checks both "registered" lines survive. Lines identical in every field on both sides beyond the shared start remain indistinguishable without a base: they are kept as two.
- Opt-out sides: two opt-outs merge into an opt-out (ours); a side with risks makes the register kept.
- The merge's question note now says the field differs between the sides and that, with no common base, either side may have changed it.
- Problems with no repair entry: a risk with no RISK-NNN identifier gets the next free one; an opt-out page holding risks becomes a kept register (a risk is never deleted); an opt-out missing its reason, decider, date or place is asked; a repair that can settle nothing while problems remain says so ("cannot settle this by itself", exit 1) instead of "needs no repair".
- Change keys carry the risk's place on the page ("RISK-007#3/impact"), so two risks under one identifier never share an answer; answers are matched ordinally.
- -View shows a register whose problems are a missing field or person or a damaged line, and refuses (run -Repair first) conflict markers, a risk with no identifier or state, and a broken opt-out; the StrictMode exception on an opt-out page without its section is gone.
- -contains/-notcontains replaced by the case-sensitive forms in the merge, -Finish's diff and the field and reason lists; the dead renumber line in the review removed.
- Tests added in "Review guards" for the rulings (a review refuses duplicates and points to -Repair; an empty area shows "area none written") and P7's fixes (a place ending in a full stop is not doubled; an elsewhere opt-out with no place is a problem; an opt-out over a register says what stops it), plus the damaged-line and same-day-merge tests above.
- Done-when 1 and 2: Pester 5.9.1, 75 passed, 0 failed on PowerShell 7.6.7 (1 min 6 s) and 5.1 (1 min 58 s).
gaps: 0 · flags: 1
- flag: the two rulings of attempt 1 and the new first-line and register-line texts are not in the D101 yet.

### review
Conventions read: `CLAUDE.md` (repo root, as the repo's conventions; this repo has no `documentation/conventions/`), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (PowerShell house style). Also read: S102-010, the ledger's "T010 · attempt 2" entry, the script and tests whole.

Reviewing: HEAD (uncommitted work), round 2 — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`); the ledger edit is the run's own.

Pester 5.9.1, as the done-whens write it: 75 passed / 0 failed on pwsh 7 and 75 passed / 0 failed on Windows PowerShell 5.1. Probed by hand in scratch git repos with real `-Repair`/`-Apply` calls.

Of your three Fails: the same-day merge fold is closed for new registers, and the damaged-line case you reproduced is closed — but two narrower forms of the damaged-line loss remain, and a third Fail turned up that round 1 missed: a merge with nothing to ask cannot be repaired at all.

**Conventions**

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1 (whole diff) | Pass | House style kept: `Exit-Refused` helpers, ordinal compares via `Test-Same`, pure ASCII, one path for both editions, only the two owned files changed. |
| risk-log.ps1:772, :788, :941, :1034, :602 | Pass | Round-1 Flag closed: `-ccontains`/`-cnotcontains` replace the case-insensitive forms in the merge, `-Finish`'s diff and the field/reason lists. |
| risk-log.ps1:706 | Pass | Round-1 Flag closed: the dead renumber line in `Invoke-Review` is gone. |
| risk-log.Tests.ps1 | Pass | Round-1 Flag closed: the rulings (review refuses duplicates → `-Repair`; "area none written") and the three P7 fixes (doubled full stop, "elsewhere" with no place, opt-out-over-register message) each have a test. |
| ledger T010 attempt 2 flag | Flag | The two rulings and the new texts ("Created: <name>. Impact …", "RISK-003 registered: <name>.", "RISK-002 changed: <field> a → b.") are still not in the D101 (RL4, S2, the history-line texts) — hard rule 6 drift; the ledger already names it. |

**Correctness & safety**

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1:795-803, :909-920 | Fail | A conflicted page whose sides merge with nothing to ask and no duplicate to renumber cannot be repaired: `Get-RepairPlan` returns no changes, so `-Apply repair` exits 1 "cannot settle this by itself … Edit the page by hand" and the merge is never written. Reproduced: one branch registered a risk, the other recorded a review — the commonest merge shape, since every write puts a line at the top of the register history. Same for two opt-outs. The focus line "a repair that merges both sides" is unserved there. Give the merge its own unasked change entry whenever markers are present. |
| risk-log.ps1:298-314 (`Read-Lines`) | Fail | Damage the new reader cannot see still rewrites a line, with `-Read` reporting no problem: (1) a history `<li>` whose `data-date` was lost but whose inner text is intact reads as matching with `date = ''`, and the repair writes an empty `<time></time>` although the date sat in the page; (2) a missing `</li>` makes the lazy `<li>…</li>` match swallow the next line into the first one's text as raw `<li data-date=…>` markup — two lines read as one, nothing marked damaged, and after the repair the second line's date/person/kind are gone. Both reproduced. (The stripped-`who`-span case from round 1 is closed.) Read an empty attribute from the `<time>`/`who` text and flag an empty date/kind; mark a line whose inner text holds `<li` as damaged. |
| risk-log.ps1:767-775 (`Merge-Sides`) | Flag | The same-day fold is fixed only for first lines that carry the name. A register written before this change has "Created. Impact …" with no name, so two different risks added the same day by the same person still fold into one (reproduced: the name asked as "differs between the sides", one risk lost). Treating a name difference as two risks would be safe (renumbering loses nothing). |
| risk-log.ps1:746-756, :764, :784 (`Join-Histories`) | Pass | Round-1 history loss fixed: shared start kept once, each side's own lines all kept, so two identical same-day lines stay two. Probed a confirmed field-conflict merge: both sides' change lines and register lines survive, the repair line records the answers. |
| risk-log.ps1:821, :841-853 | Pass | Round-1 dead ends closed: missing identifier → next free one; opt-out page holding risks → kept register; broken opt-out → asked. Probed all. A repair that can settle nothing now says why. |
| risk-log.ps1:821 | Flag | A risk with no identifier gets the history line "Renumbered from " with nothing after it. |
| risk-log.ps1:1011-1016 (`Invoke-View`) | Pass | The StrictMode crash and the silently dropped risk are gone: broken opt-out, missing state/identifier and conflict markers are refused; a risk with no impact still shows no score; a damaged line shows normally. |
| risk-log.ps1:816-820 | Pass | Round-1 key collision closed: every key carries the risk's place on the page ("RISK-007#3/impact"). |
| risk-log.ps1:574, :582 | Pass | The first history line and the register line now carry the name, which is what fixes the fold for new registers; the only earlier assertion on the old text was in the tests and was updated. |
| risk-log.Tests.ps1 | Flag | The focus scenario "Conflict markers after a merge become a repair" still checks only the proposal (as the S102 words it); the new same-day test does exercise a confirmed merge, but a confirmed merge with an answered field conflict is still untested (probed by hand — works), and the two repros above are untested — the missing "nothing to ask" merge is the one that would have caught the first Fail. |

**Against the spec**

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| both files | owns | Pass | Only the owned script and its test file changed. |
| risk-log.ps1:909-920 | S102-010 · §2 scenario "Conflict markers after a merge become a repair" + §1 | Fail | A merge with no questions and no duplicates is never written (first Correctness Fail). |
| risk-log.ps1:298-314 | S102-010 · §4 Must not (remove or rewrite a history line) + §1 "loses nothing" | Fail | A line with a lost `data-date`, or one fused by a missing `</li>`, is rewritten without its date or without its own structure (second Correctness Fail). |
| risk-log.ps1:298-314, :830 | S102-010 · §4 Must not ("restored from the page's own content or listed in the proposal") | Pass | A line with no `who` span is now read, listed in the proposal as an unasked change with its restored text, and kept — test covers it. |
| risk-log.ps1:767-775 | S102-010 · §1 "a confirmed repair loses nothing" | Flag | The fold persists for legacy first lines (Merge-Sides Flag). |
| risk-log.ps1 / Tests | S102-010 · §2 scenarios 1, 2, the leftover outline, "A risk with no impact shows no score" | Pass | Each has a test, one per example row; behaviour unchanged by the rebuild. |
| risk-log.ps1:704-706, :995 + Tests | Ledger rulings by SimonVilandt | Pass | Both are what the code does and now have tests; still not in the D101. |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### T010 · attempt 3 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the S101 §1-§2 instead.
built T010 attempt 3 (human task, built in the session that directs the run), against P8 review round 2
- Fail (a merge with nothing to ask is never written): a page with conflict markers now always gets an unasked change of its own ("register merge: two sides of a git merge -> one register"), so the joined register is written whether or not anything is asked. A test merges a branch that registered a risk with one that recorded a review; the repair writes both (three risks, the review line, the registration line).
- Fail (damage the reader could not see): Read-Lines now splits a history list at every opening <li, so a lost </li> can no longer fold the next line into this one; a line without its closing tag is damaged; a lost data-date is read back from the line's own <time> and the line marked damaged; a line with no kind or no valid date is damaged too, and the repair asks for what the page no longer holds (Get-LineRepair: the restore unasked, a kind or date question when needed). A two-row test (lost date, lost closing tag) reads both lines, reports the damage, and keeps both lines with their dates and kinds through the repair. In a repair, the check lets a line regain a lost person, kind or date, and nothing else (Test-LineKept -Fill per field).
- Flag (legacy first lines fold the same day): the merge's identity is now the identifier, the created date, the name and the first history line; risks differing in name are two risks (renumbering loses nothing), so registers written before the name entered the first line are safe too. Consequence, accepted: a risk renamed on one side of a merge comes out as two risks, one renumbered, for the person to resolve.
- Flag (an empty "Renumbered from "): a risk that had no identifier gets "Renumbered from no identifier".
- Flag (tests): a confirmed merge with an answered field conflict is now tested (the answer is taken and both sides' change lines kept), and so are the two round-2 repros and the nothing-to-ask merge.
- Done-when 1 and 2: Pester 5.9.1, 79 passed, 0 failed on PowerShell 7.6.7 (1 min 44 s) and 5.1 (2 min 8 s).
gaps: 0 · flags: 1
- flag: the rulings and the history texts ("Created: <name>. ...", "RISK-nnn registered: <name>.", "RISK-nnn changed: ...") and the merge's identity rule are not in the D101 yet.

### review
Conventions read: `CLAUDE.md` (repo root, as the repo's conventions; this repo has no `documentation/conventions/`), `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` (PowerShell house style). Also read: S102-010, the ledger's "T010 · attempt 3" entry, the changed parts of the script and tests (`Read-Lines`, `Test-LineKept`, `Merge-Sides`, `Get-RepairPlan`, `Get-LineRepair`, `Set-Repair`, `Invoke-RepairWrite`).

Reviewing: HEAD (uncommitted work), round 3 — 2 files (`risk-log.ps1`, `risk-log.Tests.ps1`); the ledger edit is the run's own.

Pester 5.9.1, run one edition after the other: 79 passed / 0 failed on pwsh 7 and 79 passed / 0 failed on Windows PowerShell 5.1. Probed by hand in scratch git repos with real `-Repair`/`-Apply` calls.

Both round-2 Fails are closed; no Fail found this round. On your question: the renamed-risk consequence loses no data, but it leaves a twin the person can never delete and is not told about (Flag below).

**Conventions**

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1 (whole diff) | Pass | House style kept: `Exit-Refused` helpers, ordinal `Test-Same`, case-sensitive list tests, pure ASCII, one path for both editions, only the two owned files changed. |
| risk-log.Tests.ps1 | Pass | Round-2 Flag closed: tests now cover the nothing-to-ask merge, the lost date and the lost closing tag (two rows), and a confirmed merge with an answered field conflict. |
| ledger T010 attempt 3 flag | Flag | The two rulings, the history texts ("Created: <name>. …", "RISK-nnn registered: <name>.", "RISK-nnn changed: …") and the merge's identity rule are still not in the D101 — hard-rule-6 drift; the ledger names it. |

**Correctness & safety**

| File:line | Severity | Reason |
|---|---|---|
| risk-log.ps1:855-856, :908 | Pass | Round-2 Fail 1 closed: a conflicted page always gets an unasked `register/merge` change. Reproduced the previously stuck case (one branch registered a risk, the other recorded a review) — the repair wrote both, no markers left. Two opt-outs on separate branches also repair (to an opt-out with both decision lines kept). |
| risk-log.ps1:298-328 (`Read-Lines`) | Pass | Round-2 Fail 2 closed: split at every opening `<li`; a lost `data-date` is read back from the line's `<time>` and marked damaged; a lost `</li>` no longer folds the next line in (first or last line); a missing `data-kind` or invalid date is damaged and asked. Reproduced lost date, lost closing tag (both positions) and lost kind — every line kept its date, person and kind; `-Read` reports "a history line of RISK-001 is damaged"; the proposal lists the restore. |
| risk-log.ps1:503-508 (`Test-LineKept`) | Pass | In a repair a line may only gain a field it lost (person/kind/date); anything it held must be equal — a repair cannot rewrite a field the page held. |
| risk-log.ps1:784-790 (`Merge-Sides`) | Pass | Round-2 Flag closed: identity now includes the name, so legacy "Created. Impact …" registers no longer fold two same-day risks (reproduced the earlier legacy case: both risks now kept). |
| risk-log.ps1:784-790 + :823-831 (a risk renamed on one side) | Flag | Nothing is lost: merging a branch that renamed RISK-001 with one that changed RISK-002 yields RISK-001 "Orig" and RISK-003 "Renamed", each with full history (incl. the rename line) and a `renumber` line. But the stale twin stays — the old identifier now carries the old name, and since a risk is never deleted the person can only Resolve it. The proposal says only "the same identifier twice", with no hint that the two look like one risk renamed, so the person gets no choice. A note naming the shared created date and first line would let them see it; a rename on a branch followed by any conflict will produce this. Accepted on purpose by the builder, so Flag, not Fail. |
| risk-log.ps1:309-322 (`Read-Lines`) | Flag | A lost `data-by` with the `<span class="who">` intact is not recovered — it reports "names no person" and the repair asks for the person, although the page still holds the name. Date got the recovery; person didn't. Avoidable, harmless (nothing lost), but an answer different from the span would overwrite what the page held. |
| risk-log.ps1:795-799 | Flag | Unchanged: a field changed on only one side of a merge is asked (no base — `:2:`/`:3:` only, as the S102 requires); the note says either side may have changed it. |
| risk-log.ps1:922-923 | Pass | Round-2 Flag closed: a risk with no identifier gets "Renumbered from no identifier". |

**Against the spec**

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| both files | owns | Pass | Only the owned script and its test file changed. |
| risk-log.ps1:298-328, :503-508 | S102-010 · §4 Must not (remove or rewrite a history line) + §1 "a confirmed repair loses nothing" | Pass | A damaged line is read from what is left of it, listed in the proposal, kept with its date, person and kind; only a field the page no longer holds is asked. |
| risk-log.ps1:855-856 | S102-010 · §2 scenario "Conflict markers after a merge become a repair" | Pass | The merge is written whether or not anything is asked; the focus scenario's test checks the proposal as the S102 words it, and the written merge has its own tests. |
| risk-log.ps1 / Tests | S102-010 · §2 scenarios 1, 2, leftover outline, "A risk with no impact shows no score" | Pass | Each still has a test and its behaviour is unchanged by the rebuild. |
| risk-log.ps1 | S102-010 · §4 Stops | Pass | A page with a problem the repair cannot settle says so and exits 1; every problem I reproduced across the three rounds (missing identifier, opt-out problem, nothing-to-ask merge) now has a repair path. |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P8: 1 task spec, 2 done-whens, checkpoint "An unreadable register gets a repair shown as before and after and loses nothing once confirmed, a leftover write is finished or discarded, and the script's tests prove it."

Environment: PSModulePath exported in Bash before the Pester runs as ruled (Machine PSModulePath from `powershell -NoProfile` + `C:\Users\sva\AppData\Local\PowerShell\Modules`). The two commands run sequentially, exactly as written, from the repo root.

| Task | Check | Result | Evidence |
|---|---|---|---|
| T010 | done-when 1: `risk-log.Tests.ps1` green under the `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester ... FailedCount + FailedContainersCount)'` command, T003–T009 tests still green, one test per scenario of §2 | pass | `pwsh ...` → "Tests Passed: 79, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0" in 101.3 s, exit 0. The five required tests are in the test file's Context 'Repair and finish interrupted writes' (see below); the earlier contexts (Register a risk on a new page, Read/number/score, Change a risk's fields, Decide a risk's state, Hand open risks to an owner, Review view and confirmed review, Opt out and replace it) are in the same 79-test run, which had no failure. |
| T010 | done-when 2: green under the `powershell -NoProfile -ExecutionPolicy Bypass -Command '...'` command | pass | `powershell ...` → "Tests Passed: 79, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0" in 127.3 s, exit 0 |
| P8 | checkpoint: the "Check" command (both editions chained with `&&`) | met | the two halves above are the check's two parts; each exited 0, so the `&&` chain exits 0 |

Test names vs §2 scenarios (read from the file, since Pester's default output doesn't list individual tests — Context 'Repair and finish interrupted writes', lines 808–931):
- 'An unreadable register is not written to and gets a repair proposal' (line 819)
- 'A confirmed repair loses nothing' (line 834)
- 'A leftover new file is finished or discarded (<case>)' (line 856) — `-ForEach` rows `passes` and `fails, having dropped a history line`, i.e. one test per example row
- 'A risk with no impact shows no score' (line 890, tag review-focus)
- 'Conflict markers after a merge become a repair' (line 900, tag review-focus)

The "Review guards" context (line 933 on) holds extra tests belonging to no task spec, as stated.

Working tree unchanged: `git status --short` identical before and after my runs (the three files already modified at start — risk-log.ps1, risk-log.Tests.ps1, the ledger — stayed so).

Verified: 2 pass · 0 fail · checkpoint met

### commit · 8225e61
go by SimonVilandt on 2026-10-30 · 2 files · ledger

## P9 · Risk log conversation

### T011 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md, the S101 §1-§2 and s101-ledger-definition.md (the shape) instead.
built T011 (human task, built in the session that directs the run)
- Created plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md: the maturity block (assess, since 2026-10-30); what the register is for; the bar, kept; the fields (four required, three optional, the derived score), the five states with what each requires, the register (language, last-updated date, its own history, the scoring view, or an opt-out); the page as the record, naming the template and the script by path; RL1-RL17 each with its uncovered case, RL4 carrying the ruling of 2026-10-30 (a review never renumbers) and RL11 the merge rule; the append-only rules; the departures from the Risk management discipline (Mitigated and Occurred added to the responses, no fixed areas, the score as a rank, the history for the comment field); the anti-patterns; placement.
- D100 §4.5 gains "Definition of risk log" and "Risk log template" rows, both assess.
- Done-when 1: the first five lines are the maturity block. Done-when 2: the definition new, D100 modified, nothing else.
gaps: 0 · flags: 1
- flag: RL16 says history lines the tool phrases itself are written in the project's language; the script writes them in English (built T003-T010), so a register in another language mixes the two. The definition states RL16 as designed; the gap is the script's.

### T012 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md, the S101 §1-§2 and artifact-s101-ledger/SKILL.md (the frame) instead.
built T012 (human task, built in the session that directs the run)
- Created plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md: frontmatter name and description only, trigger-shaped; reads the definition and (for the fallback) the template by path with the Codex derived-root step; calls the script by its full path; inputs from the caller; the method (read, build one change per verb, find what is missing and return it: a role as owner, a missing field or reason or decider, a score given, an area nearly one in use, a delete request answered with resolving; the project's language with the as-stored text returned for confirmation; write only with the confirmed change, through a temp-folder change file and -Apply; exit 3 back to the caller); the repair (the proposal as before and after, questions answered, verb repair); the rules the script implements (read, apply, check, areas nearly the same) as its specification; the fallback without PowerShell (the whole page rendered from the template through .new and the same checks, ending "No script ran the check"); never: call a skill, ask the person, write another file, delete.
- The four scenarios of §2 are the skill's text (a role is never written; the language step; delete becomes resolve; the no-PowerShell fallback said plainly); they are proven by a hand run (S101 A5, A13), not by a command.
- Done-when 1 and 2: the frontmatter's first lines; the file new.
gaps: 0 · flags: 0

### T013 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and artifact-s101-view/SKILL.md (the frame) instead.
built T013 (human task, built in the session that directs the run; light form)
- Created plugins/asimov-plugin/skills/artifact-risk-log-view/SKILL.md: frontmatter name and description only; calls the script's -View by its full path with the Codex derived-root step; prints it unchanged in a fenced block; relays a refusal; the layout as the script's specification and the fallback (80 columns, the RL12 order, no score for a missing impact, fixed English labels, "area none written" per the ruling, the opt-out form); never writes, never judges.
- Done-when 1 and 2: the frontmatter's first lines; the file new.
gaps: 0 · flags: 0

### T014 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the asimov-project skeleton's own rules (Step 02) instead.
built T014 (human task, built in the session that directs the run)
- asimov-project: the Step 01 table's "none yet" row, its comment and the "holds no artifact yet" line replaced by the risk log's row; the risk log's section after Step 02: before the first question (narrate and maturity; the five .gitignore patterns appended when missing, once; -Finish first on a leftover .new with its outcome shown; one question for the person on exit 3, kept for the run); the verbs table (add, change, state, handover, optout, repair, delete answered with resolving, no verb = review) with what each asks, pm-advisor offered in one line when scoring against the anchors and when opting out; asking only what the authoring skill returns (a person's name, missing fields, "Did you mean <area>?" once, the as-stored translation); the go (one summary, "Write this to the risk log?", the write through artifact-risk-log-authoring, the view through artifact-risk-log-view); the review (nothing written with neither register nor opt-out and the two ways on offered; the view, "Mark the register as reviewed today?", then "Who took part?", skippable; a register with duplicates offered the repair); what happens next. The frontmatter is unchanged (model claude-sonnet-5-5).
- /asimov-init and codex-asimov-init: the .gitignore block grows from four patterns to five with project/*.new, and every sentence that counts the patterns says five.
- The six scenarios of §2 are the skill's text and are proven by a hand run in Claude Code and Codex (S101 A5, A13); this run had no hand run, since the installed plugin predates the Project frame.
- Done-when 1 and 2: the three files changed; the frontmatter unchanged.
gaps: 0 · flags: 1
- flag: asimov-spec's Step 01 also appends the Asimov cache patterns (four, without project/*.new); it is not this task's file, so a repo initialised only by asimov-spec gets the risk log's pattern from asimov-project's first run instead.

### review
Conventions read: `CLAUDE.md` (hard rules 2, 3, 6, 9, 10; "How to add a project artifact"; the skill families; the Codex-root rule); house style from `plugins/asimov-plugin/artifacts/documentation/s101-ledger/s101-ledger-definition.md`, `plugins/asimov-plugin/skills/artifact-s101-ledger/SKILL.md`, `plugins/asimov-plugin/skills/artifact-s101-view/SKILL.md`. (No `documentation/conventions/` folder in this repo.)

Also read: S102 011–014, the S101 review focus as given, D101 §4.4, §6.2–§6.7, §7.4, the ledger diff; checked the skills' claims against the whole of `risk-log.ps1`, and the definition's departures against `risk-management.md`.

Reviewing: HEAD (uncommitted) vs S102 task specs 011, 012, 013, 014 — 7 files (ledger diff excluded from the set).

## Conventions
| File:line | Severity | Reason |
|---|---|---|
| `plugins/asimov-plugin/skills/asimov-project/SKILL.md:65-66` | Flag | Step 02's shared rule is "nothing is written before the person's go" (line 51), but the risk-log section writes `.gitignore` and runs `-Finish` (which renames a `.new` over the page) before the first question. D101 AC36/AC37 want both, so the section should say it is the one exception — otherwise a reader sees a contradiction. (A bare review in a repo with no register also writes `.gitignore`.) — CLAUDE.md |
| `plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md:81, 121` | Flag | The file ships to product repos, but cites "hard rule 9" (a toolkit CLAUDE.md rule) and "ruling 2026-10-30" (a ledger ruling), neither of which means anything there. Citing D100 is house style and fine; state the review-never-renumbers rule without the ruling's date. — CLAUDE.md |
| `plugins/asimov-plugin/skills/asimov-spec/SKILL.md:65` (outside changeset) + repo `.gitignore` | Flag (uncertain) | Hard rule 9's sixth literal makes the init block and the `asimov-spec` Step 01 block lockstep partners. Both init entry points and `asimov-project` now write five patterns; `asimov-spec` still appends four, CLAUDE.md still says "four-pattern block", and this repo's own `.gitignore` has no `project/*.new`. The design doesn't list `asimov-spec`, so this is likely a T016 decision — I did not check whether T016 covers it. — CLAUDE.md |
| `asimov-init.md`, `codex-asimov-init/SKILL.md` | Pass | Every count sentence says five (126/206; 144/232); block gains `project/*.new`, nothing else changed. — CLAUDE.md |
| `asimov-project/SKILL.md` frontmatter | Pass | Unchanged, so `model:` still matches its model-choice row (hard rule 2); frontmatter identical in the diff. — CLAUDE.md |
| Both new skills | Pass | Frontmatter `name` + `description` only; definition/template by path with the Codex derived-root step (hard rule 3). — CLAUDE.md |
| D100 §4.5 | Pass | Two rows with the right paths and `assess`, matching the definition's maturity block (hard rule 10). — CLAUDE.md |

## Correctness & safety
| File:line | Severity | Reason |
|---|---|---|
| `plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md:61` | Flag (uncertain) | The change file is "one JSON file in the system's temp folder" with no encoding stated. The script reads it as UTF-8; if written by shell redirection on Windows PowerShell 5.1 it would be ANSI/UTF-16 and "Søren"/"Jonas Bæk" would be corrupted — review focus T003 only covers the script's side. Add "write it as UTF-8 without BOM". |
| `plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md:45, 85` vs `risk-log.ps1` (outside set) | Flag | RL8 says a risk's changed date moves on anything that touches it, and D101 RL8 names "its identifier"; `Invoke-Renumber` and the repair's `id` change add a history line but leave `changed` alone. The definition is faithful to the design — the defect is the script's; route to the T003/T010 builder or amend RL8. |
| `plugins/asimov-plugin/skills/asimov-project/SKILL.md:62-67, 96` + `artifact-risk-log-authoring/SKILL.md:45` | Flag | The entry point never runs `-Read` before asking: for a register with a hand-removed impact (review focus T010 expects the read to turn the run into a repair), the view prints (no score, correct), then the person answers "Mark as reviewed?" and "Who took part?", and only then hits the refusal. Ruling 1 likewise: `-Read` doesn't list a duplicate identifier as a problem, so `-Read` alone wouldn't flag it. The refusal is correct and safe, but the questions come first; have the entry point/skill check `-Read` problems and duplicate ids in `risks` before the review question. |
| Script claims in all three files (`-Read/-View/-Apply/-Repair/-Finish`, exits 0–3, `-By`, change-file fields, repair keys, `.new` check-and-rename, "area none written", 80-column layout, review refusal) | Pass | Each matched `risk-log.ps1`; the two rulings (review refused on duplicate identifier; "area none written") are implemented as the skills state. |

## Against the spec
| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `asimov-project/SKILL.md:66` + `artifact-risk-log-authoring/SKILL.md:34-41` | T014 · §2 "A leftover write is finished before any verb" (review focus); T012 · §4 | Flag | The entry point runs `-Finish` "through the authoring skill's script call", but the skill's `verb` list (add…repair) has no finish, and its fallback section doesn't say how to finish/discard a `.new` without PowerShell. Works because the script call is listed, but the path is implicit; a `-Finish` that returns exit 3 before the name was asked is only covered by reading step 4 ("a write returns exit 3") to include it. Name finish as an input, or say step 4 applies to `-Finish`. |
| `artifact-risk-log-view/SKILL.md:43` | T013 · §1 (view as the script's specification and fallback) | Flag | The opt-out layout omits the first line `Risk log · <path>` the script prints (`risk-log.ps1:1057`), so a fallback print would differ from the script's. |
| `asimov-project/SKILL.md:65` | T014 · §2 "The first risk-log run keeps leftovers out of git" | Pass | Five patterns, exactly matching the init block; missing ones only; "added <n>" only when any; no `.gitignore` → one. |
| `asimov-project/SKILL.md:67` | T014 · §2 "No git user name means one question for the run" (review focus) | Pass | Asked once, passed as the person for the rest of the run; authoring step 5 returns exit 3 to the caller and takes `person` back. |
| `artifact-risk-log-authoring/SKILL.md:55, 60, 78` | T012 · §2 all four scenarios | Pass | Role-as-owner → "a person's name is needed"; Danish text returned as stored to confirm; delete → offer to resolve; no-PowerShell fallback ends "No script ran the check…". |
| `asimov-project/SKILL.md` rows/verbs | T014 · §2 outlines (either tool, ask before write, review default) | Pass | One row; no `asimov-risk`; review waits for confirmation then asks "Who took part?" (skippable); another artifact's row untouched; `pm-advisor` offered in one line for both cases. |
| `risk-log-definition.md` | T011 · §3, §4 | Pass | Front matter lines 1–5 as required; D100 modified + definition new; fields (4 required + 3 optional), five states, RL1–RL17 with uncovered cases, page as record, bar, RL14 closure rule, the four discipline departures (checked against `risk-management.md`); no restated template markup or script parameters. |
| All seven files | S102 `owns` for 011–014 | Pass | Nothing touched outside the four tasks' `owns` lists. |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### ruling · 2026-10-30 · SimonVilandt
resume · Stopped at P9's checkpoint: every done-when passed, but the hand run of the conversation in Claude Code and Codex the checkpoint names was not done (the installed plugin predates the Project frame). Ruling: fix Baley's P9 flags in P9's files (and RL8's changed date on renumbering in risk-log.ps1, with a test); the hand run is done after the merge, as part of the review. (The ledger script has no way to record a verify whose done-whens pass but whose checkpoint is unmet without naming a failed task; a finding for the Build stage.)

### T011 · attempt 2 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the house-style siblings named in P9's review instead.
built (attempt 2, after SimonVilandt's resume ruling on P9's stop) — the P9 review flags, one line each:
- asimov-project: the section says why steps 2-3 (the .gitignore patterns, finishing a leftover write) write before the go, the one exception to Step 02; a finish goes through the authoring skill as the verb `finish`, and exit 3 on a finish is the same one question; a new step 5 reads the register before the first question, and a register that does not read in full or holds an identifier twice goes to the repair before any review question.
- artifact-risk-log-authoring: `finish` is a named input with its own step (0) and its fallback without PowerShell; the read returns repair needed also for an identifier held twice; the change file is written as UTF-8 without a byte-order mark, with the file-write tool.
- artifact-risk-log-view: the opt-out layout opens with the same "Risk log . project/risk-log.html" line the script prints.
- risk-log-definition.md: no toolkit-only references left (hard rule 9, the ruling's date); RL4 states that a review never renumbers and that renumbering moves the risk's changed date (RL8).
- risk-log.ps1 (P8's file, touched under the ruling): a renumbered risk's changed date moves to today, in the write's renumbering and in the repair; the T004 duplicate test asserts it (the renumbered risk changed today, the other keeps its date). Pester 5.9.1: 79 passed, 0 failed on PowerShell 7.6.7 and 5.1.
- Not changed, by design: asimov-spec's Step 01 still appends four patterns and CLAUDE.md speaks of a four-pattern block; CLAUDE.md is T016's, asimov-spec no task's, so the lockstep is left for T016 and a follow-up.
gaps: 0 · flags: 1
- flag: the hand run of the conversation in Claude Code and Codex is deferred to after the merge, by the ruling.

### T012 · attempt 2 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the house-style siblings named in P9's review instead.
built (attempt 2, after SimonVilandt's resume ruling on P9's stop) — the P9 review flags, one line each:
- asimov-project: the section says why steps 2-3 (the .gitignore patterns, finishing a leftover write) write before the go, the one exception to Step 02; a finish goes through the authoring skill as the verb `finish`, and exit 3 on a finish is the same one question; a new step 5 reads the register before the first question, and a register that does not read in full or holds an identifier twice goes to the repair before any review question.
- artifact-risk-log-authoring: `finish` is a named input with its own step (0) and its fallback without PowerShell; the read returns repair needed also for an identifier held twice; the change file is written as UTF-8 without a byte-order mark, with the file-write tool.
- artifact-risk-log-view: the opt-out layout opens with the same "Risk log . project/risk-log.html" line the script prints.
- risk-log-definition.md: no toolkit-only references left (hard rule 9, the ruling's date); RL4 states that a review never renumbers and that renumbering moves the risk's changed date (RL8).
- risk-log.ps1 (P8's file, touched under the ruling): a renumbered risk's changed date moves to today, in the write's renumbering and in the repair; the T004 duplicate test asserts it (the renumbered risk changed today, the other keeps its date). Pester 5.9.1: 79 passed, 0 failed on PowerShell 7.6.7 and 5.1.
- Not changed, by design: asimov-spec's Step 01 still appends four patterns and CLAUDE.md speaks of a four-pattern block; CLAUDE.md is T016's, asimov-spec no task's, so the lockstep is left for T016 and a follow-up.
gaps: 0 · flags: 1
- flag: the hand run of the conversation in Claude Code and Codex is deferred to after the merge, by the ruling.

### T013 · attempt 2 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the house-style siblings named in P9's review instead.
built (attempt 2, after SimonVilandt's resume ruling on P9's stop) — the P9 review flags, one line each:
- asimov-project: the section says why steps 2-3 (the .gitignore patterns, finishing a leftover write) write before the go, the one exception to Step 02; a finish goes through the authoring skill as the verb `finish`, and exit 3 on a finish is the same one question; a new step 5 reads the register before the first question, and a register that does not read in full or holds an identifier twice goes to the repair before any review question.
- artifact-risk-log-authoring: `finish` is a named input with its own step (0) and its fallback without PowerShell; the read returns repair needed also for an identifier held twice; the change file is written as UTF-8 without a byte-order mark, with the file-write tool.
- artifact-risk-log-view: the opt-out layout opens with the same "Risk log . project/risk-log.html" line the script prints.
- risk-log-definition.md: no toolkit-only references left (hard rule 9, the ruling's date); RL4 states that a review never renumbers and that renumbering moves the risk's changed date (RL8).
- risk-log.ps1 (P8's file, touched under the ruling): a renumbered risk's changed date moves to today, in the write's renumbering and in the repair; the T004 duplicate test asserts it (the renumbered risk changed today, the other keeps its date). Pester 5.9.1: 79 passed, 0 failed on PowerShell 7.6.7 and 5.1.
- Not changed, by design: asimov-spec's Step 01 still appends four patterns and CLAUDE.md speaks of a four-pattern block; CLAUDE.md is T016's, asimov-spec no task's, so the lockstep is left for T016 and a follow-up.
gaps: 0 · flags: 1
- flag: the hand run of the conversation in Claude Code and Codex is deferred to after the merge, by the ruling.

### T014 · attempt 2 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the house-style siblings named in P9's review instead.
built (attempt 2, after SimonVilandt's resume ruling on P9's stop) — the P9 review flags, one line each:
- asimov-project: the section says why steps 2-3 (the .gitignore patterns, finishing a leftover write) write before the go, the one exception to Step 02; a finish goes through the authoring skill as the verb `finish`, and exit 3 on a finish is the same one question; a new step 5 reads the register before the first question, and a register that does not read in full or holds an identifier twice goes to the repair before any review question.
- artifact-risk-log-authoring: `finish` is a named input with its own step (0) and its fallback without PowerShell; the read returns repair needed also for an identifier held twice; the change file is written as UTF-8 without a byte-order mark, with the file-write tool.
- artifact-risk-log-view: the opt-out layout opens with the same "Risk log . project/risk-log.html" line the script prints.
- risk-log-definition.md: no toolkit-only references left (hard rule 9, the ruling's date); RL4 states that a review never renumbers and that renumbering moves the risk's changed date (RL8).
- risk-log.ps1 (P8's file, touched under the ruling): a renumbered risk's changed date moves to today, in the write's renumbering and in the repair; the T004 duplicate test asserts it (the renumbered risk changed today, the other keeps its date). Pester 5.9.1: 79 passed, 0 failed on PowerShell 7.6.7 and 5.1.
- Not changed, by design: asimov-spec's Step 01 still appends four patterns and CLAUDE.md speaks of a four-pattern block; CLAUDE.md is T016's, asimov-spec no task's, so the lockstep is left for T016 and a follow-up.
gaps: 0 · flags: 1
- flag: the hand run of the conversation in Claude Code and Codex is deferred to after the merge, by the ruling.

### review
Conventions read: `CLAUDE.md` (hard rules 2, 3, 6, 9, 10; "How to add a project artifact"; the skill families; the Codex-root rule) as the repo's conventions (no `documentation/conventions/`); house style `plugins/asimov-plugin/artifacts/documentation/s101-ledger/s101-ledger-definition.md`, `plugins/asimov-plugin/skills/artifact-s101-ledger/SKILL.md`, `plugins/asimov-plugin/skills/artifact-s101-view/SKILL.md`. Also re-read: the four S102s, the P9 ruling and the attempt-2 entries in the ledger, the diffs of `risk-log.ps1`, `risk-log.Tests.ps1` and `asimov-project/SKILL.md`; new files read whole, and the script's `Invoke-Renumber` and `Set-Repair`.

Reviewing: HEAD (uncommitted), round 2 — 9 files (the round-1 seven + `plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1` and `risk-log.Tests.ps1`). D100, `asimov-init.md` and `codex-asimov-init/SKILL.md` diffs unchanged since round 1.

Pester 5.9.1, `PSModulePath` as instructed, editions sequentially: PowerShell 7 → 79 passed, 0 failed, 0 skipped; Windows PowerShell 5.1 → 79 passed, 0 failed, 0 skipped (matches the ledger's figures).

## Round-1 flags

| Round-1 flag | Status |
|---|---|
| `asimov-project` writes `.gitignore`/`-Finish` before the go, against Step 02's "nothing is written before the go" | Closed — the section now opens with a paragraph naming steps 2–3 as the one exception to Step 02, and why. |
| Definition cites "hard rule 9" and a ruling date | Closed — grep finds neither; §7 now says the `project/` folder is as `asimov-project` and D100 §3/§5 name it; RL4 states the rule without a date. |
| `asimov-spec` Step 01 appends four patterns / CLAUDE.md "four-pattern block" / this repo's `.gitignore` lacks `project/*.new` | Knowingly left (T016 + follow-up), as ruled. |
| Change file written with no encoding named | Closed — authoring step 5 now says UTF-8 without BOM, written with the file-write tool, and why a 5.1 redirect wouldn't do. |
| RL8: renumbering left `changed` alone | Closed — `risk-log.ps1:534` (write-path renumbering) and `:925` (repair) now set `changed = $Today`; the T004 duplicate test asserts both sides (renumbered risk shows today, the kept one its own date); the definition's RL4 says so. |
| Ask-then-refuse ordering (no read before the questions) | Closed in intent by "Before the first question" step 5 — with a defect, see Conventions row 1. |
| `-Finish` had no verb in the authoring skill | Closed — `finish` is a named input and step 0 of the method, with a no-PowerShell fallback; section step 3 invokes it as a verb, step 4 covers exit 3 on a finish. |
| View skill's opt-out layout missed the first line | Closed — now opens with *Risk log · project/risk-log.html*, then the sentence, empty line, reason, *Decided by*, matching `risk-log.ps1:1057-1060`. |

## Conventions

| File:line | Severity | Reason |
|---|---|---|
| `plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md:46`, `asimov-project/SKILL.md:69, 97` vs `risk-log-definition.md:81` and `SKILL.md:73` | Flag | The new step 1 / step 5 send a register holding an identifier twice to the repair for **every** verb, but RL4 and the skill's own Apply rule say the next write renumbers duplicates first (D101 AC9: "after the next write"), which the script does for add/change/state/handover. Ruling 1 covers only the review. As written, an add on a duplicated register is refused by the skill although the script would renumber and write it. Limit the duplicate-identifier route to `review`, or change RL4/AC9. |
| `asimov-project/SKILL.md:69` vs `artifact-risk-log-authoring/SKILL.md:34-41` | Flag | Step 5 says "invoke the authoring skill's read once before the first question", but the skill's `verb` list has no read verb and `said` is required; the read is step 1 of every verb, so the caller cannot ask for it alone. Name a `read` input, or say the caller sends the verb it already has with no `confirmed`. |
| `asimov-project/SKILL.md:58-60` (exception paragraph) | Pass | The exception is stated in the same breath as the rule it breaks, each write said in one line. |
| `risk-log-definition.md` | Pass | No toolkit-only references remain; maturity block and D100 §4.5 unchanged and in step (hard rule 10). |

## Correctness & safety

| File:line | Severity | Reason |
|---|---|---|
| `risk-log.ps1:534`, `:925` | Pass | `changed` moves only for the renumbered risk; the write's check compares parsed data incl. `changed`, so intended and read-back models agree; `Test-Kept` compares history lines only and the `Held` baseline is renumbered the same way, so no new refusal; a review is still refused on a duplicate, so RL8's "a review moves no risk's changed date" holds. |
| `risk-log.Tests.ps1:284-297` | Flag (low) | The new assertions cover the write path (renumber during an add) only; the repair path (`Set-Repair` `id` branch, `:925`) got the same code change but no assertion. Add one `changed`-equals-today assertion to the existing repair-renumber test. |
| `artifact-risk-log-authoring/SKILL.md:62` (UTF-8) | Pass | Matches the script's UTF-8 read (`Read-Change`, `risk-log.ps1:118`). |

## Against the spec

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `asimov-project/SKILL.md:67-68` | T014 · §2 "A leftover write is finished before any verb" (review focus) | Pass | `finish` runs first, as a verb, through the authoring skill; its outcome printed before the verb's questions; exit 3 on a finish is the one question. |
| `asimov-project/SKILL.md:68` | T014 · §2 "No git user name means one question for the run" (review focus) | Pass | Asked once for a write or a finish, then passed as the person for the run. |
| `artifact-risk-log-authoring/SKILL.md:79` | T012 · §2 "With no PowerShell the skill applies the rules itself and says so" (review focus) | Pass | Fallback now covers `finish` too; the closing "No script ran the check…" line kept. |
| `asimov-project/SKILL.md:97-101` | T014 · §2 "The review is the default and waits for confirmation" | Pass | Cases unchanged: neither register nor opt-out → nothing written; register → view, "Mark the register as reviewed today?", then "Who took part?" (skippable); unreadable/duplicate → repair before any review question (see Conventions flag 1 for the other verbs). |
| `risk-log.ps1`, `risk-log.Tests.ps1` | T011 · §4 / S101 review focus T010 | Pass | The additional files stay inside the P9 ruling; only behaviour change is the RL8 `changed` date. |
| All nine files | S102 `owns` 011–014 + the ruling's one extra file | Pass | Nothing touched beyond the four tasks' `owns` plus the two script files the ruling adds. |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### T012 · attempt 3 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the house-style siblings instead.
built (attempt 3, against P9 review round 2):
- The duplicate-identifier route is limited to the review, as RL4 and AC9 say: a write renumbers a duplicate itself; only a review (and the read before the review question) returns the identifier held twice and that the repair renumbers it. A register that does not read in full still goes to the repair for every verb but `repair`.
- `read` is a named verb of the authoring skill (step 1 alone, its answer returned), and asimov-project's read before asking invokes it by that name.
- The repair-path renumbering's changed date has an assertion in the same-day merge test; honestly weak, since that fixture's risk was created today, so the write-path assertion (an older changed date moving to today) is the one that proves RL8.
- Pester 5.9.1: 79 passed, 0 failed on PowerShell 7.6.7 and 5.1.
gaps: 0 · flags: 1
- flag: the hand run is deferred to after the merge, by the ruling.

### T014 · attempt 3 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md and the house-style siblings instead.
built (attempt 3, against P9 review round 2):
- The duplicate-identifier route is limited to the review, as RL4 and AC9 say: a write renumbers a duplicate itself; only a review (and the read before the review question) returns the identifier held twice and that the repair renumbers it. A register that does not read in full still goes to the repair for every verb but `repair`.
- `read` is a named verb of the authoring skill (step 1 alone, its answer returned), and asimov-project's read before asking invokes it by that name.
- The repair-path renumbering's changed date has an assertion in the same-day merge test; honestly weak, since that fixture's risk was created today, so the write-path assertion (an older changed date moving to today) is the one that proves RL8.
- Pester 5.9.1: 79 passed, 0 failed on PowerShell 7.6.7 and 5.1.
gaps: 0 · flags: 1
- flag: the hand run is deferred to after the merge, by the ruling.

### review
Conventions read: `CLAUDE.md` (hard rules 2, 3, 6, 9, 10; "How to add a project artifact"; the skill families; the Codex-root rule) as the repo's conventions (no `documentation/conventions/`); house style `plugins/asimov-plugin/artifacts/documentation/s101-ledger/s101-ledger-definition.md`, `plugins/asimov-plugin/skills/artifact-s101-ledger/SKILL.md`, `plugins/asimov-plugin/skills/artifact-s101-view/SKILL.md`. Also read: the ledger's T012/T014 attempt-3 entries, `artifact-risk-log-authoring/SKILL.md` and `asimov-project/SKILL.md` as they now stand, the tests diff, the same-day merge test.

Reviewing: HEAD (uncommitted), round 3 — the same 9 files as round 2 (only the two skills and `risk-log.Tests.ps1` changed since).

Pester 5.9.1, `PSModulePath` as instructed, editions sequentially: PowerShell 7 → 79 passed, 0 failed, 0 skipped; Windows PowerShell 5.1 → 79 passed, 0 failed, 0 skipped.

## Round-2 flags

| Round-2 flag | Status |
|---|---|
| Duplicate-identifier route applied to every verb, against RL4/AC9 | Closed — authoring step 1 now says only a *problem* stops a write ("no verb but `repair` writes to a register that does not read in full"); a duplicate is "no problem for a write, which renumbers it first (RL4)", and only `review` (and `read`) return the identifier held twice and that the repair renumbers it. Matches the script (`Get-Problems` excludes duplicates, `Invoke-Review` refuses them) and the Apply bullet at line 73. `asimov-project` step 5 says the same ("An identifier held twice stops only the review; a write renumbers it itself (RL4)"), and the review case at line 99 is likewise review-only. |
| No named read verb for the entry point's read-before-asking | Closed — `read` is in the `verb` input (`SKILL.md:39`) as "step 1 alone, answer returned, before the caller asks anything"; `asimov-project` step 5 invokes it by name and line 99 refers to "the `read` before asking". |
| Repair-path renumber had no `changed` assertion | Closed in form, weak in substance (below). |

## Conventions

| File:line | Severity | Reason |
|---|---|---|
| `plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md:38` | Flag (low) | The `said` input is still "Required", but `read` and `finish` have nothing said; mark it "required except for `read` and `finish`". Same small gap I noted for `finish` before. |
| `SKILL.md:39, 46` vs `asimov-project/SKILL.md:70, 99` | Pass | The two files agree: `read` returns as described; a register that does not read in full goes to the repair for every verb but `repair`; a duplicate identifier stops only the review. Nothing else reads differently. |
| Frontmatter, description, Codex root step, D100 rows, init entry points | Pass | Unchanged since round 2. |

## Correctness & safety

| File:line | Severity | Reason |
|---|---|---|
| `risk-log.Tests.ps1:1019` (same-day merge test) | Flag (low) | As the builder's own note says: every risk in that fixture is created today, so its `changed` is already today and the assertion passes without the `Set-Repair` change at `risk-log.ps1:925` — it would not catch a regression there. The write-path test (284–297, a `changed` of 2026-01-05 moving to today) is what proves RL8. A repair-path test would need a duplicate-identifier fixture whose `changed` is set to an old date by hand (as the write-path test does), then `-Repair` + apply. |
| Authoring skill, `read` | Pass | `-Read` already returns the `risks` list with identifiers, so the duplicate check needs no new script support. |

## Against the spec

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `asimov-project/SKILL.md:97-101` | T014 · §2 "The review is the default and waits for confirmation" | Pass | Neither register nor opt-out → nothing written; register → view, "Mark the register as reviewed today?", then "Who took part?" (skippable); unreadable or duplicate → repair before the review question. |
| `artifact-risk-log-authoring/SKILL.md:46`, ruling 1 (review refuses a duplicate) | T012 §2 / P8 ruling | Pass | Refusal still the script's; the conversation now learns it before asking. |
| All nine files | S102 `owns` 011–014 + the two script files the ruling adds | Pass | No file outside the set touched. |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P9 (second round): 4 task specs (T011–T014), 8 done-whens, checkpoint "A person registers, changes, decides, reviews and hands over risks through the frame's entry point in Claude Code and in Codex, and the hand run of the conversation's criteria proves it."

| Task | Check | Result | Evidence |
|---|---|---|---|
| T011 | done-when 1: `Get-Content -TotalCount 5` on `risk-log-definition.md` → `---`, `artifact: risk-log`, `maturity: assess`, dated `since:`, `---` | pass | prints `---`, `artifact: risk-log`, `maturity: assess`, `since: 2026-10-30`, `---` |
| T011 | done-when 2: `git status --short -- …/risk-log/ documentation/D100-Asimov-architecture.md` → definition new, D100 modified, nothing else | pass | ` M documentation/D100-Asimov-architecture.md`, `?? …/risk-log/risk-log-definition.md`, no other lines |
| T012 | done-when 1: `Get-Content -TotalCount 3` on `artifact-risk-log-authoring/SKILL.md` | pass | `---`, `name: artifact-risk-log-authoring`, `description: The only writer of the risk log …` |
| T012 | done-when 2: `git status --short` on that file → new | pass | `?? plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md` |
| T013 | done-when 1: `Get-Content -TotalCount 3` on `artifact-risk-log-view/SKILL.md` | pass | `---`, `name: artifact-risk-log-view`, `description: Print the risk log …` |
| T013 | done-when 2: `git status --short` on that file → new | pass | `?? plugins/asimov-plugin/skills/artifact-risk-log-view/SKILL.md` |
| T014 | done-when 1: `git diff --stat` on the three files → changed | pass | asimov-init.md 7, asimov-project/SKILL.md 58, codex-asimov-init/SKILL.md 7 → `3 files changed, 60 insertions(+), 12 deletions(-)` (asimov-project grew 55 → 58 since round 1) |
| T014 | done-when 2: `Get-Content -TotalCount 8` on `asimov-project/SKILL.md` → frontmatter, `model: claude-sonnet-5-5` unchanged | pass | line 7 `model: claude-sonnet-5-5`; other frontmatter lines intact |
| P9 | checkpoint — the Check `git status --short -- <the seven paths>` | met (command, as written) | ` M D100`, ` M commands/asimov-init.md`, ` M asimov-project/SKILL.md`, ` M codex-asimov-init/SKILL.md`, `?? risk-log-definition.md`, `?? artifact-risk-log-authoring/SKILL.md`, `?? artifact-risk-log-view/SKILL.md` |

Hand run: **not done.** Per Simon Vilandt's ruling, the hand run of the conversation in Claude Code and in Codex is done after the merge, as part of the review; nothing I can see shows it was done. The checkpoint's "met" above therefore covers only the check command and the done-whens, not the sentence's claim that the behaviour was proven by a hand run.

Beyond P9's own done-whens (the extra Pester check from the ruling, not part of this phase's checks): files `risk-log.ps1` (+2 lines in `git diff --stat`) and `risk-log.Tests.ps1` (+6), both modified/uncommitted (RL8). Method: the earlier phases' Pester command as written in the S101 phase checks, `PSModulePath` = Machine value + `C:\Users\sva\AppData\Local\PowerShell\Modules`, editions sequentially.

| Task | Check | Result | Evidence |
|---|---|---|---|
| extra | `risk-log.Tests.ps1` under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester … FailedCount + FailedContainersCount)'` | pass | `Tests Passed: 79, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`, 70.9 s, exit=0 |
| extra | same under `powershell -NoProfile -ExecutionPolicy Bypass -Command '…'` | pass | `Tests Passed: 79, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`, 94.4 s, exit=0 |

Test count 79 on both editions, the same as P8's figure although `risk-log.Tests.ps1` gained 6 lines — I did not inspect where they went.

Working tree unchanged by this run: `git status --short` hash identical before and after; every command read-only (Pester runs only read the test file); scratch output to the scratchpad.

Verified: 8 pass · 0 fail · checkpoint met (check command and done-whens only; hand run not yet done). Extra Pester check: 2 pass · 0 fail.

### commit · 6a384d3
go by SimonVilandt on 2026-10-30 · 9 files · ledger

## P10 · Website and records

### T015 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md, the mockup site-project-management.html (its After this design state) and site/artifacts/documentation/s101.html (chip and source links) instead.
built T015 (human task, built in the session that directs the run)
- site/inside/project-management.html: the "More skills are planned … pm-*" bullet removed; "What lands in your repo" now names the risk log at project/risk-log.html, a table of three things you say (/asimov-project risk log; …, add …; …, accept RISK-004), the four principles, the Codex invocation, and the next two Project-frame artifacts; the delivery model and Ask it sections unchanged.
- site/artifacts/project-management/index.html: the planned chip and "none has landed yet" gone; the lede says where the frame's pages land; a Risk log section with an assess chip (equal to the definition's maturity), Produced by / Lands in / Source (Definition · Template on GitHub), and a link to the story.
- documentation/features/D101-website.html: R6 and AC6 say what the two pages now say; Draft v0.4 -> v0.5 (2026-10-30), in the same change as the pages.
- Done-when 1: node documentation/website/check-links.mjs -> "ok: 22 page(s), all links resolve", exit 0. Done-when 2: the three files modified, nothing else. Neither page contains "planned" or "Nothing yet".
gaps: 0 · flags: 0

### T016 · attempt 1 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md itself and D100 instead.
built T016 (human task, built in the session that directs the run)
- D100: §3 says the risk log is built (2026-10-30) and how it is kept; §4.3's asimov-project row is no longer a skeleton or "in flight"; §4.6 gains rows for artifact-risk-log-authoring (with its script) and artifact-risk-log-view; §5's tree shows the two skills, the script and artifacts/project/risk-log/ with its definition and template, and asimov-project no longer "a skeleton"; §5's present-state paragraph names the risk log as of 2026-10-30; §9 drops the risk log. The §4.5 rows (T011's) untouched.
- CLAUDE.md: the quick map gains the two skills, the script and the artifact folder, asimov-project no longer a skeleton; "How to add a project artifact" says the risk log is built; hard rule 9's seventh literal names the risk log's skills and definition and the project/*.new pattern in the block both init entry points write and asimov-project appends, and the cache-pattern sentence notes the init entry points' five-pattern form; Current state gains a "The risk log is built" paragraph (the run, the script, the rulings, and what is not yet done: the hand run, asimov-spec's four patterns).
- Done-when 1: both files modified, nothing else. Done-when 2: git diff --check exits 0.
gaps: 0 · flags: 1
- flag: asimov-spec's Step 01 still appends four patterns (no project/*.new) and this repo's own .gitignore has no project/*.new; recorded in CLAUDE.md's Current state as not yet done, for a follow-up.

### review
Conventions read: `CLAUDE.md` (hard rules 6, 9, 10; "How to add a project artifact"; the quick map) as the repo's conventions (`documentation/conventions/` does not exist); house style `site/artifacts/documentation/s101.html` and the *After this design* state of `documentation/features/mockups/d101-project-management-risk/site-project-management.html`. Also read for the claims: `plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md`, `skills/asimov-project/SKILL.md`, `skills/artifact-risk-log-authoring/SKILL.md`, `skills/artifact-risk-log-view/SKILL.md`, `risk-log.ps1` (parameters), the S101 and its ledger, `commands/asimov-init.md`, `skills/codex-asimov-init/SKILL.md`, `skills/asimov-spec/SKILL.md` (the `.gitignore` block).

Reviewing: HEAD (uncommitted) — 5 files, against S102 T015 and T016. (`specs/project-management-risk/S101-project-management-risk.ledger.md` also shows as modified; it's build bookkeeping and in no `owns`, so not reviewed.)

## Conventions (CLAUDE.md hard rule 6 / drift; house style)

| # | File:line | Severity | Reason |
|---|---|---|---|
| 1 | `site/artifacts/project-management/index.html:7` | **Fail** | The meta description still reads "nothing has landed in this area yet" on a page that now lists the risk log as built — the "Nothing yet" claim T015 exists to remove, in a form the AC4 word check doesn't catch (hard rule 6). |
| 2 | `site/inside/project-management.html:6` | Flag | The meta description still ends "and the artifacts to come" while the page now shows the first artifact (hard rule 6). |
| 3 | `documentation/features/D101-website.html:361, 429–431, 610` | **Fail** | The document now contradicts its own R6/AC6: line 361 "no table yet: one lede with the *planned* chip"; the decision row at 429–431 says the area page "stays planned" because "no project-management artifact exists yet"; the §4.4 table row at 610 lists project-management as definition "none", level "planned". Drift of exactly the kind hard rule 6 names, in a file T015 owns and edits in this very diff. |
| 4 | `documentation/features/D101-website.html:354, 689–690` | Flag | Line 354 says the page tells "what will land under Artifacts"; Q3's resolution path reads "closes when the first project-management artifact lands" — which has now happened, so the question is left open without a note. Author may want to close it. |
| 5 | `site/artifacts/project-management/index.html:32–38` | Flag | The `<dl>` has no `class="meta"`; `site.css:83–86` styles only `.meta`, and `s101.html:39` uses it — the Produced by / Lands in / Source rows render unstyled. S102 T015 §4 Prefer asks for `s101.html`'s form. |
| 6 | `site/inside/index.html:302` | Flag | Outside T015's `owns` (not an edit for this task), but "first of a planned family" is the last public `pm-*` "planned" claim; this diff removes the matching bullet from `inside/project-management.html`, so the two now disagree. |
| 7 | `CLAUDE.md:356, 358, 370` | Pass | Keep "four cache patterns", "in flight on PR 34", "skeleton"/"empty table" — but these are dated history entries; 370 now ends "arrived with PR 34; see the next paragraph", and `asimov-spec` Step 01 still appends four patterns, so the 2026-10-07 text was and is true. |
| 8 | `CLAUDE.md` hard rule 9 / `.gitignore` block | Pass | "four-pattern block" wording gone; now says `project/*.new` is in "the init entry points' five-pattern form", matching `commands/asimov-init.md:168–176` and `codex-asimov-init/SKILL.md:194–202`, and names `asimov-project` as the appender (matches `asimov-project/SKILL.md:67`). |
| 9 | `documentation/D100-Asimov-architecture.md` | Pass | No "in flight", "skeleton", "empty artifact table" or "planned" left for the risk log; §9 row removed; `git diff --check` clean on D100 and `CLAUDE.md`. |

## Correctness & safety (claims checked against the built files)

| File:line | Severity | Reason |
|---|---|---|
| `site/inside/project-management.html:~124, 130` | Flag | "Nothing beyond Active is set without a reason and a person" carries over from the mockup; by definition §3.2 only Accepted needs a named decider (Mitigated needs a written mitigation). The person is the history line's author (RL10), so the claim holds only in that reading. **Uncertain** — wording call for the author. |
| `site/inside/project-management.html` (table, flows, bullets) | Pass | Sorted by state then score = RL12; "mark reviewed today" question matches the skill; next number = RL3; Occurred/Mitigated/Resolved take a reason = §3.2; history only grows / no deletion = RL10 and the verbs table; score ranks, doesn't decide; opt-out in the register's place = RL15; Codex form `$asimov-plugin:asimov-project risk log`. |
| `site/artifacts/project-management/index.html` | Pass | `assess` chip equals the definition's `maturity: assess`; both GitHub paths exist in the plugin; `project/risk-log.html` and "beside `documentation/` and `specs/`" right; `#artifacts` anchor exists at `inside/project-management.html:117`; `node documentation/website/check-links.mjs` → `ok: 22 page(s), all links resolve`. |
| `CLAUDE.md` quick map + new "The risk log is built" paragraph | Pass | Both skills and the script exist; flags `-Read -View -Apply -Repair -Finish`; 79 Pester tests on 7 and 5.1 match the ledger; 11 phases / 16 tasks / every task `role: human` match the S101; `:2:`/`:3:` repair = RL11; "area none written" in `risk-log.ps1:1035`; definition and template at `assess`. |
| `documentation/D100-Asimov-architecture.md` §3, §4.3, §4.6, §5, §9 | Pass | §4.6 rows and §5 tree entries match the files; "what exists today" paragraph names them; the §4.5 rows for the pair already exist at 144–145 (T011's), so T016's stop condition does not fire. |

## Against the spec

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| `site/artifacts/project-management/index.html:7` | T015 · §1 Intent (line 27) | **Fail** | The intent is that no public page says nothing has landed once the plugin carries the register; the meta description still does. |
| `documentation/features/D101-website.html:361, 429–431, 610` | T015 · §4 Must "AC6 … say what the two pages now say" (line 43) | Flag | The literal Must is met (R6/AC6 updated, version → Draft v0.5 dated 2026-10-30), but the same document still states the opposite in these places (Conventions #3). |
| `site/artifacts/project-management/index.html:32` | T015 · §4 Prefer (line 45) | Flag | `s101.html`'s form is `<dl class="meta">`; this page omits `class="meta"`. |
| `site/inside/project-management.html`, `site/artifacts/project-management/index.html` | T015 · §4 Must (lines 40–42) | Pass | "Nothing yet" replaced by the risk log in the *After this design* state; `pm-*` planned bullet removed; "planned" chip dropped, `assess` chip with Definition and Template links added; neither page contains "planned"/"Nothing yet"; *delivery model* and *Ask it* sections untouched. |
| all five files | T015 · §4 Must not (line 44); T016 · §4 Must not (line 44) | Pass | No page added, no navigation changed, no phase-diagram box; D100 §4.5 rows, `model-choice.md` and both plugin manifests untouched. |
| `CLAUDE.md`, `D100-Asimov-architecture.md` | T016 · §4 Must (lines 40–43) | Pass | §3/§4.3/§4.6 moved; §5 shows the artifact folder and the script beside its skill; §9 drops the risk log; quick map, "How to add a project artifact", "Current state" and hard rule 9 updated. |
| T015/T016 done-whens | §3 | Pass | Link check exits 0; `git diff --check` on D100/`CLAUDE.md` clean; `git status` lists show the expected files modified (read the lists; did not run the verifier's full sequence). |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### T015 · attempt 2 · human-in-session · session
Conventions read: none (this repo has no documentation/conventions/); CLAUDE.md, s101.html and the mockup instead.
built T015 attempt 2, against P10 review round 1
- Fail (artifacts page meta description "nothing has landed"): now "Project-management artifacts: the risk log, kept in your repo's project/ through asimov-project."
- Fail (D101-website.html contradicting its own R6/AC6): line 354 says what lands under Artifacts (the risk log first); line 361 says the area page lists its artifacts with chip, definition and template; the decision row says the area page lists the frame's artifacts, never a skill as an artifact; the §4.4 chip table moves project-management out of the "none / planned" row into its own row (risk-log-definition.md, assess); Q3, Allan Borup's, keeps its question open with a note that the first artifact landed 2026-10-30 and is listed.
- Flags: the inside page's meta description names the risk log instead of "the artifacts to come"; the artifacts page's <dl> carries class="meta" as s101.html does; "Every decision has a name on it" now says every change of state carries a reason and its author, and an acceptance names who decided.
- Not changed: site/inside/index.html line 302 ("first of a planned family") is outside T015's owns; raised for the person.
- Done-whens: link check "ok: 22 page(s), all links resolve"; the three files modified, nothing else; neither page contains "planned", "Nothing yet" or "nothing has landed".
gaps: 0 · flags: 1
- flag: site/inside/index.html still calls pm-advisor "the first of a planned family".

### review
Conventions read: `CLAUDE.md` (hard rules 6, 9, 10; "How to add a project artifact") as the repo's conventions (`documentation/conventions/` does not exist); house style `site/artifacts/documentation/s101.html` and the *After this design* state of `documentation/features/mockups/d101-project-management-risk/site-project-management.html`. Also re-read for the claims: `risk-log-definition.md` §3.2 and RL5–RL7, `asimov-project/SKILL.md`.

Reviewing: HEAD (uncommitted), round 2 — the same 5 files, against S102 T015 (attempt 2) and T016. T016's files (`CLAUDE.md`, `documentation/D100-Asimov-architecture.md`) show the same diff size as in round 1 (18 and 19 lines), so my round-1 pass on them stands; the three T015 files re-diffed in full.

## Round-1 findings re-checked

| Round 1 | Now | Status |
|---|---|---|
| Fail — `site/artifacts/project-management/index.html:7` meta description "nothing has landed in this area yet" | "Project-management artifacts: the risk log, kept in your repo's project/ through asimov-project." | **Closed** |
| Fail — `D101-website.html` 361, 429–431, 610 contradicted R6/AC6 | 361 says the area page lists its artifacts, the risk log first, with chip, definition and template, and a pointer to the story; decision row 429–431 says the area page "lists the frame's artifacts" (the risk log "since 2026-10-30"); 610 drops project-management from the "none / planned" row and adds `artifacts/project-management/index.html (risk log)` · `risk-log-definition.md` · `assess` (equals the definition's `maturity`). | **Closed** |
| Flag — `D101-website.html` 354 and Q3 | 354 now "what lands under Artifacts (the risk log first)"; Q3's resolution path adds that the first artifact landed 2026-10-30 and names what is still open (`pm-*` pages, a delivery-model nav item). | **Closed** |
| Flag — `site/inside/project-management.html:7` meta description "the artifacts to come" | now "… and the risk log that lands in your repo" | **Closed** |
| Flag — `<dl>` without `class="meta"` | `<dl class="meta">`, as `s101.html:39` | **Closed** |
| Flag — "Nothing beyond Active is set without a reason and a person" | "Every change of state carries a reason and the person who made it; an acceptance also names who decided it." — matches definition §3.2 / RL5, RL7, RL10. | **Closed** |

## Conventions (hard rule 6, house style)

| File:line | Severity | Reason |
|---|---|---|
| all five files | Pass | Word check for "planned", "Nothing yet", "nothing has landed", "to come", "will land", "no table" finds nothing in the two site pages; in `D101-website.html` the only remaining `pm-*` mentions are line 299 (§2 background), OOS2 and the decision row at 434, which describe the still-open Q3 question of whether `pm-*` skills get pages — not drift. `node documentation/website/check-links.mjs` → `ok: 22 page(s), all links resolve`; `git diff --check` clean on the three T015 files. |
| `site/inside/index.html:302` | Flag | Outside T015's `owns` by design and raised to the person, as you said. "first of a planned family" is now the only public `pm-*` "planned" claim and no longer matches the inside page, where that bullet was removed. |

## Correctness & safety

| File:line | Severity | Reason |
|---|---|---|
| `site/inside/project-management.html`, `site/artifacts/project-management/index.html`, `documentation/features/D101-website.html` | Pass | The edits break nothing found: every claim on the pages still matches the definition and `asimov-project`; the `#artifacts` anchor still exists; the Version/footer moves to Draft v0.5, 2026-10-30, in both places; AC6 and R6 agree with the pages. |

## Against the spec

| File:line | S102 · line | Severity | Reason |
|---|---|---|---|
| T015 files | T015 · §4 Must (40–43), Prefer (45), Intent (27) | Pass | Every Must holds; the Prefer is met with `dl.meta`; no page tells a reader nothing has landed. |
| T015 files | T015 · §4 Must not (44) | Pass | No page added, navigation unchanged, no Project-column box in the phase diagram. |
| all five files | T015 · §3, T016 · §3 | Pass | Link check exits 0; `git diff --check` clean; `git status` shows the owned files modified plus the ledger (build bookkeeping, in no `owns`). Read the lists; did not run the verifier's full sequence. |

Findings only — no approval verdict. Route fixes to the .NET builder / Angular builder / tester; the approval call stays with the human reviewer.

### verify
Verifying P10: 2 task specs, 4 done-whens, checkpoint "The website's two Project frame pages name the risk log as available, and the architecture, the repo guide and the website's design agree with what shipped."

| Task | Check | Result | Evidence |
|---|---|---|---|
| T015 | done-when 1: `node documentation/website/check-links.mjs` exits 0 and prints `ok:` with every page's links resolving | pass | `node documentation/website/check-links.mjs` → `ok: 22 page(s), all links resolve` (exit 0) |
| T015 | done-when 2: `git status --short -- site/inside/project-management.html site/artifacts/project-management/index.html documentation/features/D101-website.html` prints the three files as modified and nothing else | pass | → ` M documentation/features/D101-website.html`, ` M site/artifacts/project-management/index.html`, ` M site/inside/project-management.html` (3 lines) |
| T016 | done-when 1: `git status --short -- documentation/D100-Asimov-architecture.md CLAUDE.md` prints both files as modified and nothing else | pass | → ` M CLAUDE.md`, ` M documentation/D100-Asimov-architecture.md` (2 lines) |
| T016 | done-when 2: `git diff --check -- documentation/D100-Asimov-architecture.md CLAUDE.md` exits 0 | pass | no output, exit 0 |
| P10 | checkpoint: the check `git status --short -- <the five files>` (as written in the plan) | met | the command lists exactly the five files, all ` M`: CLAUDE.md, documentation/D100-Asimov-architecture.md, documentation/features/D101-website.html, site/artifacts/project-management/index.html, site/inside/project-management.html |

Note (uncertain): the check command only shows the five files are modified; it does not test that the pages "name the risk log as available" or that the documents "agree with what shipped". As a supplementary read-only grep (not part of the check as written): `grep -ci "planned|nothing yet"` → 0 in both website pages; `grep -c risk` → 9 in site/inside/project-management.html, 5 in site/artifacts/project-management/index.html. I did not read the page content for agreement with the shipped plugin.

Verified: 4 pass · 0 fail · checkpoint met
