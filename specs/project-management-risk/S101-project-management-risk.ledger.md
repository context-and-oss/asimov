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
    status: passed
    commit: none
    go: none
    tasks:
      - { id: T003, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P2
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T004, status: pending, attempts: 0, agent: none, model: none }
  - id: P3
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T005, status: pending, attempts: 0, agent: none, model: none }
  - id: P4
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T006, status: pending, attempts: 0, agent: none, model: none }
  - id: P5
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T007, status: pending, attempts: 0, agent: none, model: none }
  - id: P6
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T008, status: pending, attempts: 0, agent: none, model: none }
  - id: P7
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T009, status: pending, attempts: 0, agent: none, model: none }
  - id: P8
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T010, status: pending, attempts: 0, agent: none, model: none }
  - id: P9
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T011, status: pending, attempts: 0, agent: none, model: none }
      - { id: T012, status: pending, attempts: 0, agent: none, model: none }
      - { id: T013, status: pending, attempts: 0, agent: none, model: none }
      - { id: T014, status: pending, attempts: 0, agent: none, model: none }
  - id: P10
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T015, status: pending, attempts: 0, agent: none, model: none }
      - { id: T016, status: pending, attempts: 0, agent: none, model: none }
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
