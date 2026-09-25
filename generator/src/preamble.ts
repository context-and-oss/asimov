// The model-mismatch preamble (D101 §6.4.5 / §7.4.5). Replaces the {{model-check}} token in
// every command source at emission, so the generated skill is self-contained. Downward-only:
// running the designated model or better passes silently; below alerts (never blocks); a model
// the rank list cannot place produces one neutral note.

import type { MappingTable } from './mapping.ts';
import { tierRank } from './mapping.ts';

const TOOL_LABELS: Record<string, string> = {
  'claude-code': 'Claude Code',
  codex: 'Codex',
};

export function buildPreamble(
  mapping: MappingTable,
  tier: string,
  model: string,
  effort: string | undefined,
): string {
  const label = TOOL_LABELS[mapping.tool] ?? mapping.tool;
  const rank = tierRank(tier);
  const effortNote = effort === undefined ? '' : `, effort \`${effort}\``;
  const rankList = mapping.ranks.map((r) => `\`${r.model}\` = ${r.rank}`).join(' · ');
  return [
    `**Model check — run this first, silently.** This command is designated tier **${tier}** (${label}: \`${model}\`${effortNote}). Determine from your own session context which model you are running as, then:`,
    '',
    `- Running \`${model}\`, or a model ranked **at or above** ${rank} in the list below → say nothing about models and proceed.`,
    `- Running a model ranked **below** ${rank} → before any other output, tell the developer in one sentence that this command is designated tier ${tier} (\`${model}\`) and the session is running a lower-ranked model, and ask whether to continue or switch. Never block, and never switch models yourself — a developer who chooses to continue is allowed to (mismatches are reported, never enforced).`,
    `- Running a model not in the list → add one neutral sentence naming the designated tier (${tier}) — no alert — and proceed.`,
    '',
    `Known ranks (1 = small, 2 = medium, 3 = large): ${rankList}.`,
  ].join('\n');
}
