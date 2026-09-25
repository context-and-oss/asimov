// Claude Code emitter (D101 §7.4.2). Commands, personas and advisory skills emit as
// skills/<name>/SKILL.md; subagents as agents/<name>.md; {{plugin-root}} becomes
// ${CLAUDE_PLUGIN_ROOT} (substituted mechanically by the tool at load time). The artifact,
// resource and processes trees ship verbatim under the same relative paths the sources
// reference through {{plugin-root}}.

import { join } from 'node:path';
import type { SourceSet, ToolkitMeta } from '../generate.ts';
import { serialiseFrontmatter } from '../frontmatter.ts';
import type { MappingTable } from '../mapping.ts';
import { resolveTier, resolveEffort } from '../mapping.ts';
import { buildPreamble } from '../preamble.ts';
import { substitute } from '../substitute.ts';
import { agentTokens } from '../tokens.ts';
import { copyTree, writeJson, writeText } from '../fsops.ts';
import { agentToml } from './codex.ts';

export function emitClaudeCode(
  out: string,
  sources: SourceSet,
  mapping: MappingTable,
  codexMapping: MappingTable,
  meta: ToolkitMeta,
): void {
  writeJson(join(out, '.claude-plugin', 'plugin.json'), {
    name: meta.name,
    description: meta.description,
    version: meta.version,
    author: meta.author,
    license: meta.license,
  });

  // {{model-check}} has a value for every skill, but only commands place the token (D101 §6.4.5);
  // a persona or an advisory skill is model-invoked and carries no preamble.
  for (const component of [...sources.commands, ...sources.personas, ...sources.skills]) {
    const model = resolveTier(mapping, component.tier, component.file);
    const effort = resolveEffort(mapping, component.effort, component.file);
    const tokens: Record<string, string> = {
      ...sources.fragments,
      'plugin-root': '${CLAUDE_PLUGIN_ROOT}',
      'model-check': buildPreamble(mapping, component.tier, model, effort),
    };
    const frontmatter = serialiseFrontmatter(
      {
        name: component.name,
        description: component.fields['description'],
        'argument-hint': component.fields['argument-hint'],
        model,
        effort,
        'allowed-tools': component.fields['allowed-tools'],
      },
      ['name', 'description', 'argument-hint', 'model', 'effort', 'allowed-tools'],
    );
    writeText(join(out, 'skills', component.name, 'SKILL.md'), frontmatter + substitute(component.body, tokens, component.file));
  }

  // sources.agents already holds every twin next to its default (generate.ts expandTwins).
  for (const agent of sources.agents) {
    const model = resolveTier(mapping, agent.tier, agent.file);
    const effort = resolveEffort(mapping, agent.effort, agent.file);
    const tokens: Record<string, string> = {
      'plugin-root': '${CLAUDE_PLUGIN_ROOT}',
      ...agentTokens(agent, mapping.tool, model, effort, sources.scopeGuard),
    };
    const frontmatter = serialiseFrontmatter(
      {
        name: agent.name,
        description: agent.fields['description'],
        model,
        effort,
        tools: agent.fields['tools'],
      },
      ['name', 'description', 'model', 'effort', 'tools'],
    );
    writeText(join(out, 'agents', `${agent.name}.md`), frontmatter + substitute(agent.body, tokens, agent.file));
  }

  // Codex agent TOMLs ride along in the Claude plugin too (same codex/agents/ path as in the
  // Codex plugin, inert for Claude Code's loader), so /asimov-init can wire a product repo for
  // Codex from whichever tool it runs in (R9) — see agentToml() in targets/codex.ts.
  for (const agent of sources.agents) {
    writeText(join(out, 'codex', 'agents', `${agent.name}.toml`), agentToml(agent, codexMapping, sources.scopeGuard));
  }

  copyTree(sources.artifactsDir, join(out, 'artifacts'));
  copyTree(sources.resourcesDir, join(out, 'resources'));
  copyTree(sources.processesDir, join(out, 'processes'));
}
