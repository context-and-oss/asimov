---
name: role-code-reviewer
description: The code-reviewer method — review the current branch's diff against its base for conformance to the active product repo's own conventions (read at run-time from documentation/conventions/<stack>/README.md for the stacks the diff touches) plus correctness and safety, and emit a structured pass/flag/fail finding report. Read-only, verdict-free — reports findings, never edits code, never approves. Use for an automated first-pass code review before a human reviewer opens the diff, and when asked to "review this the Asimov way", "as the code reviewer", or "check the diff against the conventions".
---

# role-code-reviewer

The code-reviewer method — review the current branch's diff against its base for conformance to the active product repo's own conventions (read at run-time from documentation/conventions/<stack>/README.md for the stacks the diff touches) plus correctness and safety, and emit a structured pass/flag/fail finding report.

Read `method.md` in this skill's folder first and follow it. It carries the whole method; this file is only the entry.
