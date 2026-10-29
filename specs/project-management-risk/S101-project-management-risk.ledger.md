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
    status: passed
    commit: none
    go: none
    tasks:
      - { id: T005, status: done, attempts: 1, agent: human-in-session, model: session }
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
