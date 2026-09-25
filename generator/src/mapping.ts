// The one mapping-table parser (D101 §7.5: the generator and the mismatch-preamble injection
// read ranks through the same code — one truth about model ordering).
//
// A mapping file (source/mappings/<tool>.md) is markdown carrying three tables under the
// headings '## Tiers', '## Effort' and '## Ranks'. Everything else in the file is prose for
// humans (the upgrade ritual, the tier rationale) and is ignored here.

export interface MappingTable {
  tool: string;
  tiers: Map<string, string>; // tier -> concrete model name
  effort: Map<string, string>; // source effort -> tool value ('(omit)' = leave the field out)
  ranks: { model: string; rank: number }[]; // file order preserved (deterministic)
}

function tableRows(section: string, file: string, heading: string): string[][] {
  const rows: string[][] = [];
  for (const line of section.split('\n')) {
    const t = line.trim();
    if (!t.startsWith('|')) continue;
    const cells = t
      .split('|')
      .slice(1, -1)
      .map((c) => c.trim());
    if (cells.every((c) => /^[-\s:]*$/.test(c))) continue; // separator row
    rows.push(cells);
  }
  if (rows.length < 2) throw new Error(`${file}: no table rows under '${heading}'`);
  return rows.slice(1); // drop the header row
}

function section(text: string, heading: string, file: string): string {
  const start = text.indexOf(`\n## ${heading}`);
  if (start < 0) throw new Error(`${file}: missing '## ${heading}' section`);
  const rest = text.slice(start + 1);
  const end = rest.indexOf('\n## ', 1);
  return end < 0 ? rest : rest.slice(0, end);
}

export function parseMapping(text: string, tool: string, file: string): MappingTable {
  const tiers = new Map<string, string>();
  for (const [tier, model] of tableRows(section(text, 'Tiers', file), file, 'Tiers')) {
    if (!tier || !model) throw new Error(`${file}: malformed Tiers row`);
    tiers.set(tier, model);
  }
  const effort = new Map<string, string>();
  for (const [src, value] of tableRows(section(text, 'Effort', file), file, 'Effort')) {
    if (!src || !value) throw new Error(`${file}: malformed Effort row`);
    effort.set(src, value);
  }
  const ranks: { model: string; rank: number }[] = [];
  for (const [model, rank] of tableRows(section(text, 'Ranks', file), file, 'Ranks')) {
    if (!model || !rank || !/^\d+$/.test(rank)) throw new Error(`${file}: malformed Ranks row`);
    ranks.push({ model, rank: Number(rank) });
  }
  for (const tier of ['small', 'medium', 'large']) {
    if (!tiers.has(tier)) throw new Error(`${file}: tier '${tier}' missing from Tiers table`);
  }
  return { tool, tiers, effort, ranks };
}

export function resolveTier(mapping: MappingTable, tier: string, file: string): string {
  const model = mapping.tiers.get(tier);
  if (model === undefined) throw new Error(`${file}: tier '${tier}' not in the ${mapping.tool} mapping table`);
  return model;
}

/** Returns the tool's effort value, or undefined when the mapping says '(omit)'. */
export function resolveEffort(mapping: MappingTable, effort: string, file: string): string | undefined {
  const value = mapping.effort.get(effort);
  if (value === undefined) throw new Error(`${file}: effort '${effort}' not in the ${mapping.tool} mapping table`);
  return value === '(omit)' ? undefined : value;
}

export function tierRank(tier: string): number {
  const rank = { small: 1, medium: 2, large: 3 }[tier];
  if (rank === undefined) throw new Error(`unknown tier '${tier}' (expected small | medium | large)`);
  return rank;
}
