---
ledger: S101
slug: "project-management-risk"
s101: specs/project-management-risk/S101-project-management-risk.md
fingerprint: "1bb81caedb63"
started: { by: "SimonVilandt", date: "2026-10-29" }
phases:
  - id: P0
    status: passed
    commit: none
    go: none
    tasks:
      - { id: T001, status: done, attempts: 1, agent: human-in-session, model: session }
      - { id: T002, status: done, attempts: 1, agent: human-in-session, model: session }
  - id: P1
    status: pending
    commit: none
    go: none
    tasks:
      - { id: T003, status: pending, attempts: 0, agent: none, model: none }
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
