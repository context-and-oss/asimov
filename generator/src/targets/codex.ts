// Codex emitter (D101 §7.4.3). Same SKILL.md bodies; {{plugin-root}} becomes the
// generator-computed path relative to each skill's own directory (Codex hands each skill its
// absolute directory in context — probe-verified, D101 §6.8). SKILL.md files carry NO model
// fields (Codex silently ignores them); model designation reaches Codex only through the agent
// TOMLs, which the bootstrap command delivers into product repos.

import { join } from 'node:path';
import type { ScopeGuard, SourceComponent, SourceSet, ToolkitMeta } from '../generate.ts';
import { serialiseFrontmatter } from '../frontmatter.ts';
import type { MappingTable } from '../mapping.ts';
import { resolveTier, resolveEffort } from '../mapping.ts';
import { buildPreamble } from '../preamble.ts';
import { substitute } from '../substitute.ts';
import { agentTokens } from '../tokens.ts';
import { copyTree, writeJson, writeText } from '../fsops.ts';

/** skills/<name>/SKILL.md sits two levels below the plugin root. */
const SKILL_RELATIVE_PLUGIN_ROOT = '../..';

function tomlString(value: string): string {
  return `"${value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

function tomlMultiline(value: string): string {
  const escaped = value.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
  return `"""\n${escaped}"""`;
}

export function emitCodex(out: string, sources: SourceSet, mapping: MappingTable, meta: ToolkitMeta): void {
  writeJson(join(out, '.codex-plugin', 'plugin.json'), {
    name: meta.codexName,
    description: meta.description,
    version: meta.version,
    author: meta.author,
    license: meta.license,
  });

  for (const component of [...sources.commands, ...sources.personas, ...sources.skills]) {
    const model = resolveTier(mapping, component.tier, component.file);
    const effort = resolveEffort(mapping, component.effort, component.file);
    const tokens: Record<string, string> = {
      ...sources.fragments,
      'plugin-root': SKILL_RELATIVE_PLUGIN_ROOT,
      'model-check': buildPreamble(mapping, component.tier, model, effort),
    };
    // No model/effort fields: Codex ignores them in SKILL.md frontmatter (D101 §6.8) — the
    // preamble above is the designation's only carrier in a Codex skill.
    const frontmatter = serialiseFrontmatter(
      {
        name: component.name,
        description: component.fields['description'],
        'argument-hint': component.fields['argument-hint'],
      },
      ['name', 'description', 'argument-hint'],
    );
    writeText(join(out, 'skills', component.name, 'SKILL.md'), frontmatter + substitute(component.body, tokens, component.file));
  }

  for (const agent of sources.agents) {
    writeText(join(out, 'codex', 'agents', `${agent.name}.toml`), agentToml(agent, mapping, sources.scopeGuard));
  }

  copyTree(sources.artifactsDir, join(out, 'artifacts'));
  copyTree(sources.resourcesDir, join(out, 'resources'));
  copyTree(sources.processesDir, join(out, 'processes'));
}

// The agent TOMLs are bootstrap payload, not a plugin component (Codex plugins do not carry
// agents — D101 §6.4.3): /asimov-init copies them from {{plugin-root}}/codex/agents/ into the
// product repo's .codex/agents/. They are emitted into BOTH plugin trees under the same
// codex/agents/ path — inert for each tool's own loader — so the bootstrap command finds them
// at the same relative location whichever tool it runs in (R9).
export function agentToml(agent: SourceComponent, mapping: MappingTable, guard: ScopeGuard | null): string {
  const model = resolveTier(mapping, agent.tier, agent.file);
  const effort = resolveEffort(mapping, agent.effort, agent.file) ?? 'medium';
  // Agent bodies live in product repos with no plugin at hand — a {{plugin-root}} here has
  // no value for this target and fails generation (substitute() enforces it).
  const body = substitute(agent.body, agentTokens(agent, mapping.tool, model, effort, guard), agent.file);
  return [
    `name = ${tomlString(agent.name)}`,
    `description = ${tomlString(agent.fields['description'] ?? '')}`,
    `model = ${tomlString(model)}`,
    `model_reasoning_effort = ${tomlString(effort)}`,
    `developer_instructions = ${tomlMultiline(body)}`,
  ].join('\n');
}

export function emitCodexMarketplace(file: string, meta: ToolkitMeta): void {
  writeJson(file, {
    name: meta.marketplace.name,
    owner: meta.marketplace.owner,
    plugins: [
      {
        name: meta.codexName,
        source: './plugins/asimov-plugin-codex',
        description: meta.description,
      },
    ],
  });
}
