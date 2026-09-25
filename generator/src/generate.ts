// Asimov generator — tool-neutral source/ -> the Claude Code + Codex plugin trees.
// Design: documentation/features/D101-agnostic-toolkit-codex-support.html (§6, §7).
//
//   node src/generate.ts [--repo <repo-root>] [--out <dir>]
//
// --repo defaults to the repository this generator sits in. --out defaults to the repo root
// (in-place generation, as the release workflow runs it); the PR gate passes two temp dirs
// and byte-compares them. Output trees are replaced wholesale on every run — generated files
// are never hand-edited (D101 §4.4 rule 1).
//
// Vocabulary (D100 §4): a *component* is a part of the toolkit (command, subagent, persona,
// skill, definition, template); an *artifact* is what a command writes into a product repo. The
// source/artifacts/ tree holds each artifact's definition + template and ships verbatim, as do
// source/resources/ (building blocks shared across artifacts) and source/processes/ (the
// delivery-model corpus the advisory skills read — a generated export, never edited here).

import { existsSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { parseFrontmatter, requireField } from './frontmatter.ts';
import type { MappingTable } from './mapping.ts';
import { parseMapping, tierRank } from './mapping.ts';
import { clearDir, listDir, readText } from './fsops.ts';
import { emitClaudeCode } from './targets/claude-code.ts';
import { emitCodex, emitCodexMarketplace } from './targets/codex.ts';

export interface SourceComponent {
  name: string;
  tier: string;
  effort: string;
  fields: Record<string, string>;
  body: string;
  file: string; // repo-relative, for error messages
  /** Set on a generated small twin (D101-build-subagents §4.4 / §6.4): the name of the agent it twins. */
  twinOf?: string;
}

/** source/agents/_scope-guard.md — the twin's scope rule, authored once (D101-build-subagents §6.4). */
export interface ScopeGuard {
  body: string; // injected as {{scope-guard}} into a twin; '' into a default
  twinSuffix: string; // appended to the twin's description
  defaultSuffix: string; // appended to the default's description when it has a twin; <twin> = the twin's name
}

export interface SourceSet {
  commands: SourceComponent[];
  agents: SourceComponent[];
  personas: SourceComponent[];
  /** source/skills — advisory skills (D100 §4.6): model-invoked, emitted as skills/<name>/SKILL.md like a command, without a model-check preamble. */
  skills: SourceComponent[];
  artifactsDir: string; // source/artifacts — one folder per artifact (definition + template), shipped verbatim
  resourcesDir: string; // source/resources — building blocks shared across artifacts, shipped verbatim
  processesDir: string; // source/processes — the delivery-model corpus pm-advisor reads; shipped verbatim as processes/
  scopeGuard: ScopeGuard | null;
  /** source/commands/_<name>.md → {{<name>}}: prose shared by several commands, injected identically into both targets. */
  fragments: Record<string, string>;
}

export interface ToolkitMeta {
  name: string;
  codexName: string;
  description: string;
  version: string;
  license: string;
  author: { name: string; url: string };
  marketplace: { name: string; owner: { name: string; url: string } };
}

const SCOPE_GUARD = '_scope-guard.md';

function loadComponents(dir: string, kind: string): SourceComponent[] {
  const components: SourceComponent[] = [];
  for (const entry of listDir(dir)) {
    if (!entry.endsWith('.md') || entry.startsWith('_')) continue; // _-prefixed files are shared fragments, not components
    const file = `source/${kind}/${entry}`;
    const doc = parseFrontmatter(readText(join(dir, entry)), file);
    const name = requireField(doc, 'name', file);
    if (`${name}.md` !== entry) throw new Error(`${file}: frontmatter name '${name}' does not match the filename`);
    if (kind !== 'agents' && doc.fields['twin']) throw new Error(`${file}: 'twin' is an agent-only field (D101-build-subagents R11)`);
    components.push({
      name,
      tier: requireField(doc, 'tier', file),
      effort: requireField(doc, 'effort', file),
      fields: doc.fields,
      body: doc.body,
      file,
    });
  }
  if (components.length === 0) throw new Error(`source/${kind}/ holds no components`);
  return components;
}

function loadScopeGuard(agentsDir: string): ScopeGuard | null {
  const path = join(agentsDir, SCOPE_GUARD);
  if (!existsSync(path)) return null;
  const file = `source/agents/${SCOPE_GUARD}`;
  const doc = parseFrontmatter(readText(path), file);
  return {
    body: doc.body,
    twinSuffix: requireField(doc, 'twin-suffix', file),
    defaultSuffix: requireField(doc, 'default-suffix', file),
  };
}

/**
 * An agent source declaring `twin: <tier>` is emitted twice — itself, and `<name>-<tier>` at that
 * tier with effort medium, carrying the scope guard (D101-build-subagents R11, §6.4). One prompt,
 * two agents: the twin differs only by what the generator injects (NF3).
 */
function expandTwins(agents: SourceComponent[], guard: ScopeGuard | null): SourceComponent[] {
  const out: SourceComponent[] = [];
  for (const agent of agents) {
    const twin = agent.fields['twin'];
    if (twin === undefined || twin === '') {
      out.push(agent);
      continue;
    }
    tierRank(twin); // must be a known tier
    if (guard === null) {
      throw new Error(`${agent.file}: declares twin: ${twin} but source/agents/${SCOPE_GUARD} is missing — the twin's scope guard is authored there (D101-build-subagents §6.4)`);
    }
    const twinName = `${agent.name}-${twin}`;
    const description = agent.fields['description'] ?? '';
    out.push({
      ...agent,
      fields: { ...agent.fields, description: `${description} ${guard.defaultSuffix.replace(/<twin>/g, twinName)}`.trim() },
    });
    out.push({
      name: twinName,
      tier: twin,
      effort: 'medium',
      fields: { ...agent.fields, description: `${description} ${guard.twinSuffix}`.trim() },
      body: agent.body,
      file: agent.file,
      twinOf: agent.name,
    });
  }
  return out;
}

/**
 * Command fragments: source/commands/_<name>.md is not a component but a piece of prose several
 * commands share (e.g. the file-encoding rule), reachable as {{<name>}} in any command or persona
 * body. Same value for every target — one text, one place to edit.
 */
function loadFragments(dir: string): Record<string, string> {
  const fragments: Record<string, string> = {};
  for (const entry of listDir(dir)) {
    if (!entry.startsWith('_') || !entry.endsWith('.md')) continue;
    const name = entry.slice(1, -'.md'.length);
    if (!/^[a-z][a-z-]*$/.test(name)) throw new Error(`source/commands/${entry}: fragment name must be lowercase-kebab (it becomes the token {{${name}}})`);
    fragments[name] = readText(join(dir, entry)).replace(/\n+$/, '');
  }
  return fragments;
}

function requireDir(dir: string, label: string): string {
  if (!existsSync(dir)) throw new Error(`no ${label} tree at ${dir}`);
  return dir;
}

export function loadSources(repo: string): SourceSet {
  const src = join(repo, 'source');
  if (!existsSync(src)) throw new Error(`no source/ tree at ${src}`);
  const scopeGuard = loadScopeGuard(join(src, 'agents'));
  return {
    commands: loadComponents(join(src, 'commands'), 'commands'),
    agents: expandTwins(loadComponents(join(src, 'agents'), 'agents'), scopeGuard),
    personas: loadComponents(join(src, 'personas'), 'personas'),
    skills: loadComponents(join(src, 'skills'), 'skills'),
    artifactsDir: requireDir(join(src, 'artifacts'), 'source/artifacts/'),
    resourcesDir: requireDir(join(src, 'resources'), 'source/resources/'),
    processesDir: requireDir(join(src, 'processes'), 'source/processes/'),
    scopeGuard,
    fragments: loadFragments(join(src, 'commands')),
  };
}

export function loadToolkitMeta(repo: string): ToolkitMeta {
  return JSON.parse(readText(join(repo, 'source', 'toolkit.json'))) as ToolkitMeta;
}

export function loadMapping(repo: string, tool: string): MappingTable {
  const file = `source/mappings/${tool}.md`;
  return parseMapping(readText(join(repo, file)), tool, file);
}

export function generate(repo: string, out: string): string[] {
  const sources = loadSources(repo);
  const meta = loadToolkitMeta(repo);
  const claude = loadMapping(repo, 'claude-code');
  const codex = loadMapping(repo, 'codex');

  const claudeOut = join(out, 'plugins', meta.name);
  const codexOut = join(out, 'plugins', meta.codexName);
  const codexMarketplace = join(out, '.agents', 'plugins', 'marketplace.json');

  clearDir(claudeOut);
  clearDir(codexOut);
  clearDir(join(out, '.agents', 'plugins'));

  emitClaudeCode(claudeOut, sources, claude, codex, meta);
  emitCodex(codexOut, sources, codex, meta);
  emitCodexMarketplace(codexMarketplace, meta);

  return [claudeOut, codexOut, codexMarketplace];
}

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(name);
  return i >= 0 ? process.argv[i + 1] : undefined;
}

if (process.argv[1] && resolve(process.argv[1]).endsWith('generate.ts')) {
  const repo = resolve(arg('--repo') ?? join(import.meta.dirname, '..', '..'));
  const out = resolve(arg('--out') ?? repo);
  const written = generate(repo, out);
  for (const w of written) console.log(`generated  ${w}`);
}
