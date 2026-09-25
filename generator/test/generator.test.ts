import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { parseFrontmatter, serialiseFrontmatter } from '../src/frontmatter.ts';
import { parseMapping, resolveEffort, resolveTier } from '../src/mapping.ts';
import { substitute } from '../src/substitute.ts';
import { generate, loadMapping } from '../src/generate.ts';
import { walk } from '../src/fsops.ts';

const REPO = join(import.meta.dirname, '..', '..');
const PLUGINS = ['asimov-plugin', 'asimov-plugin-codex'];

test('frontmatter: parse and serialise round-trip with fixed key order', () => {
  const doc = parseFrontmatter('---\nname: x\ndescription: a b c\ntier: medium\neffort: medium\n---\nBody.\n', 't');
  assert.equal(doc.fields['name'], 'x');
  assert.equal(doc.body, 'Body.\n');
  const out = serialiseFrontmatter({ name: 'x', tier: 'medium', skipped: undefined }, ['name', 'tier', 'skipped']);
  assert.equal(out, '---\nname: x\ntier: medium\n---\n');
});

test('frontmatter: missing block fails', () => {
  assert.throws(() => parseFrontmatter('no frontmatter here', 't'), /no frontmatter/);
});

test('mapping: parses tiers, effort and ranks; (omit) resolves to undefined', () => {
  const text = [
    '# T',
    '',
    '## Tiers',
    '| Tier | Model |',
    '|---|---|',
    '| small | m-s |',
    '| medium | m-m |',
    '| large | m-l |',
    '',
    '## Effort',
    '| Source effort | Value |',
    '|---|---|',
    '| medium | (omit) |',
    '| xhigh | ultra |',
    '',
    '## Ranks',
    '| Model | Rank |',
    '|---|---|',
    '| m-m | 2 |',
    '| m-l | 3 |',
  ].join('\n');
  const m = parseMapping(text, 'test', 't');
  assert.equal(resolveTier(m, 'large', 't'), 'm-l');
  assert.equal(resolveEffort(m, 'medium', 't'), undefined);
  assert.equal(resolveEffort(m, 'xhigh', 't'), 'ultra');
  assert.deepEqual(m.ranks, [
    { model: 'm-m', rank: 2 },
    { model: 'm-l', rank: 3 },
  ]);
});

test('substitute: unknown token fails, known token resolves', () => {
  assert.equal(substitute('a {{plugin-root}} b', { 'plugin-root': 'X' }, 't'), 'a X b');
  assert.throws(() => substitute('a {{nope}} b', { 'plugin-root': 'X' }, 't'), /no value for this target/);
});

test('generate: two runs over the real source tree are byte-identical (NF1)', () => {
  const a = mkdtempSync(join(tmpdir(), 'asimov-gen-a-'));
  const b = mkdtempSync(join(tmpdir(), 'asimov-gen-b-'));
  try {
    generate(REPO, a);
    generate(REPO, b);
    const filesA = walk(a);
    const filesB = walk(b);
    assert.deepEqual(filesA, filesB, 'file lists differ between runs');
    assert.ok(filesA.length > 10, 'suspiciously few files generated');
    for (const rel of filesA) {
      assert.ok(
        readFileSync(join(a, rel)).equals(readFileSync(join(b, rel))),
        `byte difference between runs: ${rel}`,
      );
    }
  } finally {
    rmSync(a, { recursive: true, force: true });
    rmSync(b, { recursive: true, force: true });
  }
});

test('generate: emitted Claude skill carries model + preamble; Codex twin carries neither model field nor Claude token', () => {
  const out = mkdtempSync(join(tmpdir(), 'asimov-gen-c-'));
  try {
    generate(REPO, out);
    const claude = readFileSync(join(out, 'plugins', 'asimov-plugin', 'skills', 'd101-review', 'SKILL.md'), 'utf8');
    assert.match(claude, /^model: claude-/m);
    assert.match(claude, /Model check — run this first, silently/);
    assert.match(claude, /\$\{CLAUDE_PLUGIN_ROOT\}/);
    assert.doesNotMatch(claude, /\{\{/);
    const codex = readFileSync(join(out, 'plugins', 'asimov-plugin-codex', 'skills', 'd101-review', 'SKILL.md'), 'utf8');
    assert.doesNotMatch(codex, /^model:/m);
    assert.match(codex, /Model check — run this first, silently/);
    assert.doesNotMatch(codex, /CLAUDE_PLUGIN_ROOT/);
    assert.doesNotMatch(codex, /\{\{/);
    const toml = readFileSync(join(out, 'plugins', 'asimov-plugin-codex', 'codex', 'agents', 'baley-the-code-reviewer.toml'), 'utf8');
    assert.match(toml, /^model = "/m);
    assert.match(toml, /^model_reasoning_effort = "/m);
    assert.match(toml, /^developer_instructions = """/m);
    const tomlInClaude = readFileSync(join(out, 'plugins', 'asimov-plugin', 'codex', 'agents', 'baley-the-code-reviewer.toml'), 'utf8');
    assert.equal(tomlInClaude, toml, 'the two plugin trees must carry identical Codex agent TOMLs');
    // Command fragments ({{file-io}} from source/commands/_file-io.md) reach every command in both trees and are never a skill of their own.
    for (const plugin of PLUGINS) {
      for (const skill of ['asimov-init', 'd101-feature-design', 'd101-review', 'd101-convert-to-html', 'persona-new', 'persona-list']) {
        const text = readFileSync(join(out, 'plugins', plugin, 'skills', skill, 'SKILL.md'), 'utf8');
        assert.match(text, /UTF-8 in, UTF-8 out/, `${plugin}/${skill}: file-io rule missing`);
      }
      assert.ok(!existsSync(join(out, 'plugins', plugin, 'skills', '_file-io')), `${plugin}: fragment emitted as a skill`);
      assert.ok(!existsSync(join(out, 'plugins', plugin, 'skills', 'file-io')), `${plugin}: fragment emitted as a skill`);
    }
  } finally {
    rmSync(out, { recursive: true, force: true });
  }
});

test('generate: artifact + resource trees ship verbatim into both plugins; the retired folders are gone', () => {
  const out = mkdtempSync(join(tmpdir(), 'asimov-gen-d-'));
  try {
    generate(REPO, out);
    const artifacts = walk(join(REPO, 'source', 'artifacts'));
    const resources = walk(join(REPO, 'source', 'resources'));
    assert.ok(artifacts.length >= 11 && resources.length >= 5, 'source artifact/resource trees look incomplete');
    for (const plugin of PLUGINS) {
      const root = join(out, 'plugins', plugin);
      for (const rel of artifacts) {
        assert.ok(existsSync(join(root, 'artifacts', rel)), `${plugin}: artifacts/${rel} missing`);
      }
      for (const rel of resources) {
        assert.ok(existsSync(join(root, 'resources', rel)), `${plugin}: resources/${rel} missing`);
      }
      assert.ok(!existsSync(join(root, 'definitions')), `${plugin}: retired definitions/ emitted`);
      assert.ok(!existsSync(join(root, 'templates')), `${plugin}: retired templates/ emitted`);
    }
  } finally {
    rmSync(out, { recursive: true, force: true });
  }
});

test('generate: an advisory skill and the processes corpus ship into both plugins; manifests carry license + author url (D100 §4.6)', () => {
  const out = mkdtempSync(join(tmpdir(), 'asimov-gen-g-'));
  try {
    generate(REPO, out);
    const processes = walk(join(REPO, 'source', 'processes'));
    assert.ok(processes.length >= 40, `source/processes/ looks incomplete (${processes.length} files)`);
    for (const plugin of PLUGINS) {
      const root = join(out, 'plugins', plugin);
      const skill = readFileSync(join(root, 'skills', 'pm-advisor', 'SKILL.md'), 'utf8');
      assert.match(skill, /^name: pm-advisor$/m);
      assert.doesNotMatch(skill, /\{\{/, `${plugin}: unresolved token in pm-advisor`);
      assert.doesNotMatch(skill, /Model check — run this first/, `${plugin}: an advisory skill carries no model-check preamble`);
      if (plugin === 'asimov-plugin') {
        assert.match(skill, /^model: claude-/m);
        assert.match(skill, /\$\{CLAUDE_PLUGIN_ROOT\}\/processes\/README\.md/);
      } else {
        assert.doesNotMatch(skill, /^model:/m);
        assert.match(skill, /\.\.\/\.\.\/processes\/README\.md/);
      }
      for (const rel of processes) {
        assert.ok(existsSync(join(root, 'processes', rel)), `${plugin}: processes/${rel} missing`);
      }
      const manifest = plugin === 'asimov-plugin' ? join(root, '.claude-plugin', 'plugin.json') : join(root, '.codex-plugin', 'plugin.json');
      const json = JSON.parse(readFileSync(manifest, 'utf8')) as { name: string; license: string; author: { name: string; url: string } };
      assert.equal(json.name, plugin);
      assert.equal(json.license, 'MIT');
      assert.match(json.author.url, /^https:\/\//);
    }
  } finally {
    rmSync(out, { recursive: true, force: true });
  }
});

test('source: every artifact definition opens with a maturity block naming its own folder; no template carries one', () => {
  // D101-artifact-maturity AC1 + AC2, run as a test instead of a grep.
  const base = join(REPO, 'source', 'artifacts');
  const block = /^---\r?\nartifact: ([a-z0-9-]+)\r?\nmaturity: (assess|trial|adopt|hold)\r?\nsince: \d{4}-\d{2}-\d{2}\r?\n---/;
  let definitions = 0;
  for (const rel of walk(base)) {
    const text = readFileSync(join(base, rel), 'utf8');
    if (rel.endsWith('-definition.md')) {
      const m = block.exec(text);
      assert.ok(m, `${rel}: no valid maturity block`);
      assert.equal(m[1], rel.split('/').at(-2), `${rel}: artifact slug does not match its folder`);
      definitions++;
    } else {
      assert.doesNotMatch(text, /^maturity:/m, `${rel}: a template must not carry a maturity block`);
    }
  }
  assert.ok(definitions >= 5, `expected at least five artifact definitions, found ${definitions}`);
});

test('generate: every plugin-root path a skill reads resolves inside its own plugin tree', () => {
  // The paths the commands read at run-time must exist where the token points — in both tools.
  // Claude Code: ${CLAUDE_PLUGIN_ROOT}/<path>; Codex: ../../<path> relative to skills/<name>/.
  const out = mkdtempSync(join(tmpdir(), 'asimov-gen-e-'));
  try {
    generate(REPO, out);
    const checks: { plugin: string; re: RegExp; base: (root: string, skillDir: string) => string }[] = [
      { plugin: 'asimov-plugin', re: /\$\{CLAUDE_PLUGIN_ROOT\}\/([A-Za-z0-9_][A-Za-z0-9_./*-]*)/g, base: (root) => root },
      { plugin: 'asimov-plugin-codex', re: /(?<![./])\.\.\/\.\.\/([A-Za-z0-9_][A-Za-z0-9_./*-]*)/g, base: (_root, skillDir) => join(skillDir, '..', '..') },
    ];
    let seen = 0;
    for (const { plugin, re, base } of checks) {
      const root = join(out, 'plugins', plugin);
      for (const rel of walk(join(root, 'skills'))) {
        const skillFile = join(root, 'skills', rel);
        const text = readFileSync(skillFile, 'utf8');
        for (const m of text.matchAll(re)) {
          const ref = (m[1] ?? '').replace(/\.+$/, '');
          // A glob (skills/persona-*/SKILL.md, codex/agents/*.toml) is checked up to its first wildcard segment.
          const segments = ref.split('/');
          const wild = segments.findIndex((s) => s.includes('*'));
          const stable = wild < 0 ? ref : segments.slice(0, wild).join('/');
          const target = join(base(root, dirname(skillFile)), stable);
          assert.ok(existsSync(target), `${plugin}/skills/${rel}: ${ref} does not resolve in the plugin`);
          seen++;
        }
      }
    }
    assert.ok(seen > 10, `suspiciously few plugin-root references checked (${seen})`);
  } finally {
    rmSync(out, { recursive: true, force: true });
  }
});

test('generate: a `twin: small` agent is emitted twice in both trees; the twin differs only by the injected parts (D101-build-subagents R11, R14, NF3)', () => {
  const out = mkdtempSync(join(tmpdir(), 'asimov-gen-f-'));
  try {
    generate(REPO, out);
    const claudeMap = loadMapping(REPO, 'claude-code');
    const codexMap = loadMapping(REPO, 'codex');
    const esc = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const stripFrontmatter = (s: string) => s.replace(/^---[\s\S]*?\n---\n/, '');
    const guard = stripFrontmatter(readFileSync(join(REPO, 'source', 'agents', '_scope-guard.md'), 'utf8').replace(/\r\n/g, '\n')).trim();
    const normalise = (s: string) =>
      stripFrontmatter(s).replace(guard, '').replace(/Asimov-Built-By: [^\n]*/g, 'Asimov-Built-By: X').replace(/\n{3,}/g, '\n\n');

    const claudeAgents = join(out, 'plugins', 'asimov-plugin', 'agents');
    const dflt = readFileSync(join(claudeAgents, 'giskard-the-dotnet-developer.md'), 'utf8');
    const twin = readFileSync(join(claudeAgents, 'giskard-the-dotnet-developer-small.md'), 'utf8');
    const smallModel = resolveTier(claudeMap, 'small', 't');
    const mediumModel = resolveTier(claudeMap, 'medium', 't');
    assert.match(twin, /^name: giskard-the-dotnet-developer-small$/m);
    assert.match(twin, new RegExp(`^model: ${esc(smallModel)}$`, 'm'));
    assert.doesNotMatch(twin, /^effort:/m, 'the twin declares effort medium, emitted as inherit');
    assert.match(twin, /^description: .*Small-tier twin/m);
    assert.match(dflt, /^description: .*Has a small-tier twin, giskard-the-dotnet-developer-small/m);
    assert.ok(twin.includes(guard), 'twin carries the scope guard');
    assert.ok(!dflt.includes('you are the small twin'), 'default carries no scope guard');
    assert.match(twin, new RegExp(`Asimov-Built-By: giskard-the-dotnet-developer-small \\(claude-code, ${esc(smallModel)}, effort inherit\\)`));
    assert.match(dflt, new RegExp(`Asimov-Built-By: giskard-the-dotnet-developer \\(claude-code, ${esc(mediumModel)}, effort inherit\\)`));
    assert.equal(normalise(twin), normalise(dflt), 'twin and default differ beyond the injected parts');

    const codexSmall = resolveTier(codexMap, 'small', 't');
    for (const plugin of PLUGINS) {
      const toml = readFileSync(join(out, 'plugins', plugin, 'codex', 'agents', 'giskard-the-dotnet-developer-small.toml'), 'utf8');
      assert.match(toml, new RegExp(`^model = "${esc(codexSmall)}"$`, 'm'));
      assert.match(toml, /^model_reasoning_effort = "medium"$/m);
      assert.ok(toml.includes(guard), `${plugin}: Codex twin carries the scope guard`);
      assert.match(toml, new RegExp(`Asimov-Built-By: giskard-the-dotnet-developer-small \\(codex, ${esc(codexSmall)}, effort medium\\)`));
    }

    // The scope-guard fragment is not a component: never emitted on its own.
    assert.ok(!existsSync(join(claudeAgents, '_scope-guard.md')));
    assert.ok(!existsSync(join(out, 'plugins', 'asimov-plugin-codex', 'codex', 'agents', '_scope-guard.toml')));

    // An agent without a twin gets no guard and no suffix, but still signs its report.
    const daneel = readFileSync(join(claudeAgents, 'daneel-the-angular-developer.md'), 'utf8');
    assert.doesNotMatch(daneel, /small twin/i);
    assert.match(daneel, new RegExp(`Asimov-Built-By: daneel-the-angular-developer \\(claude-code, ${esc(mediumModel)}, effort inherit\\)`));
    assert.doesNotMatch(daneel, /\{\{/);
  } finally {
    rmSync(out, { recursive: true, force: true });
  }
});
