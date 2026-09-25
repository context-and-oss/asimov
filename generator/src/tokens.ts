// Agent-body tokens shared by both emitters (D101-build-subagents §6.4; token grammar per
// D101-agnostic-toolkit-codex-support §6.4.2 — one implementation, a value for every variant).
//
//   {{designation}}  "<agent> (<tool>, <model>, effort <effort|inherit>)" — the provenance trailer's
//                    payload, resolved per target so each tool's emission names its own model.
//   {{scope-guard}}  the twin's scope rule (source/agents/_scope-guard.md) for a twin, '' for a default.

import type { ScopeGuard, SourceComponent } from './generate.ts';

export function agentTokens(
  component: SourceComponent,
  tool: string,
  model: string,
  effort: string | undefined,
  guard: ScopeGuard | null,
): Record<string, string> {
  return {
    designation: `${component.name} (${tool}, ${model}, effort ${effort ?? 'inherit'})`,
    'scope-guard': component.twinOf !== undefined ? (guard?.body ?? '') : '',
  };
}
