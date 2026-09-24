# Security

## What this plugin is

Asimov ships Markdown files: slash-command prompts, subagent definitions, skills, document definitions and templates. It contains no executable code of its own. Everything it does, it does through Claude Code, under the permissions the user has granted Claude Code in that session and repository.

## What counts as a security issue

- A shipped prompt, skill or template that could make Claude read, write or send something the documentation does not say it does. For example a command writing outside its documented output paths, or content designed to redirect a model's instructions (prompt injection).
- Credentials, tokens or personal data committed to this repository.
- A release workflow or manifest change that would let an installed plugin fetch content from somewhere other than this repository.

Behaviour that is documented but that you consider unsafe is a design question. Open a regular issue for that.

## Reporting

Please report security issues privately through GitHub's **Report a vulnerability** button on the repository's Security tab, not in a public issue. Include the file, the behaviour you observed and, where possible, the steps to reproduce it.

You can expect an acknowledgement within a week. Fixes ship as a normal release; the advisory is published once the fix is available.

## Supported versions

Only the latest release is supported. There are no backports.
