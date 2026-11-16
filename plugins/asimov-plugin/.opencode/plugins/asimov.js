/**
 * Asimov plugin for OpenCode V2.
 *
 * OpenCode has no plugin folder of skills, agents and hooks the way Claude Code and Codex do:
 * a plugin is a JavaScript module the host loads, and everything else is registered from it.
 * This module does three things on setup():
 *
 *   1. Registers every skills/<name>/SKILL.md of the plugin as a native skill through
 *      ctx.skill.transform(), so the host's `skill` tool lists and loads them by folder name.
 *   2. Registers every agents/<name>.md shell as a subagent through ctx.agent.transform(): the
 *      shell's body plus its role skill as the system prompt, no model (the session's), edit
 *      denied where the shell's tools: line has no Write/Edit. The `subagent` tool reaches them
 *      by shell name.
 *   3. Injects the Asimov context — the same text hooks/asimov-context prints for Claude Code
 *      and Codex at SessionStart — into the first user message through the session hooks
 *      `context`, `compaction` and `generate`. The script decides, as everywhere: asimov.md at
 *      the session's directory is the switch; no marker, no context. The plugin only runs it
 *      and hands the result on, with a short OpenCode tool mapping after it.
 *
 * Not here: the run log (OpenCode has no session-end event) and a model per agent (Claude Code's
 * `claude-sonnet-5-5` is no OpenCode id without a provider). Both are open in
 * documentation/features/D101-opencode-support.html §6.
 *
 * No dependencies. Loaded by the repo root's index.js (directory form, a local path in
 * `plugins`) or package.json `main` (npm/git form).
 */

import path from 'path';
import fs from 'fs';
import { execFileSync } from 'child_process';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = path.resolve(__dirname, '../..');          // plugins/asimov-plugin
const SKILLS_DIR = path.join(PLUGIN_ROOT, 'skills');
const AGENTS_DIR = path.join(PLUGIN_ROOT, 'agents');
const CONTEXT_SCRIPT = path.join(PLUGIN_ROOT, 'hooks', 'asimov-context');
const DEBUG = !!process.env.ASIMOV_OPENCODE_DEBUG;

const log = (...args) => console.error('[asimov]', ...args);
const debug = (...args) => { if (DEBUG) console.error('[asimov:debug]', ...args); };

// ---------------------------------------------------------------------------
// Frontmatter: name and description out of a SKILL.md, the body without it.
// Not a YAML parser; plain `key: value` lines and continuation lines are all the
// skills use (every description is one line under 300 characters, by rule).
// ---------------------------------------------------------------------------
const splitFrontmatter = (content) => {
  const m = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
  if (!m) return { frontmatter: {}, body: content };
  const frontmatter = {};
  let last = null;
  for (const raw of m[1].split('\n')) {
    const line = raw.replace(/\r$/, '');
    const i = line.indexOf(':');
    if (i > 0 && !/^\s/.test(line)) {
      last = line.slice(0, i).trim();
      const v = line.slice(i + 1).trim();
      frontmatter[last] = /^(>[+-]?|\|[+-]?)$/.test(v) ? '' : v;
    } else if (last && line.trim()) {
      frontmatter[last] = `${frontmatter[last]} ${line.trim()}`.trim();
    }
  }
  for (const k of Object.keys(frontmatter)) {
    frontmatter[k] = frontmatter[k].replace(/^(["'])([\s\S]*)\1$/, '$2');
  }
  return { frontmatter, body: m[2] };
};

// ---------------------------------------------------------------------------
// Bash for the context script: the same search run-hook.cmd does, in JS.
// ---------------------------------------------------------------------------
const findBash = () => {
  if (process.platform !== 'win32') return 'bash';
  const candidates = [
    'C:\\Program Files\\Git\\bin\\bash.exe',
    'C:\\Program Files (x86)\\Git\\bin\\bash.exe',
    process.env.LOCALAPPDATA && path.join(process.env.LOCALAPPDATA, 'Programs', 'Git', 'bin', 'bash.exe'),
  ].filter(Boolean);
  for (const c of candidates) if (fs.existsSync(c)) return c;
  const skip = [/\\System32\\/i, /\\Sysnative\\/i, /\\WindowsApps\\/i];   // the WSL launchers
  for (const dir of (process.env.PATH || '').split(';')) {
    if (!dir || skip.some((re) => re.test(dir + '\\'))) continue;
    const p = path.join(dir, 'bash.exe');
    if (fs.existsSync(p)) return p;
  }
  return null;
};
let _bash;
const bash = () => (_bash === undefined ? (_bash = findBash()) : _bash);

// ---------------------------------------------------------------------------
// The context: run hooks/asimov-context with a SessionStart or SubagentStart payload,
// as the harness hooks do, and take its additionalContext. Cached per event, directory
// and marker mtime, since the session hooks fire on every agent step.
// ---------------------------------------------------------------------------
const _contextCache = new Map();

const runContextScript = (event, directory, agentType) => {
  const marker = path.join(directory, 'asimov.md');
  let mtime = null;
  try { mtime = fs.statSync(marker).mtimeMs; } catch { return null; }   // no marker, no context
  const key = `${event}|${directory}|${mtime}`;
  if (_contextCache.has(key)) return _contextCache.get(key);

  let text = null;
  const sh = bash();
  if (!sh) {
    log('no bash found; skills are registered but the Asimov context is not injected');
  } else {
    try {
      const payload = JSON.stringify({ hook_event_name: event, cwd: directory, agent_type: agentType || 'unknown' });
      const out = execFileSync(sh, [CONTEXT_SCRIPT], {
        input: payload,
        encoding: 'utf8',
        timeout: 15000,
        windowsHide: true,
        env: { ...process.env, ASIMOV_HARNESS: 'opencode' },
      });
      const line = out.trim().split('\n').filter(Boolean).pop();
      if (line) {
        const json = JSON.parse(line);
        text = json.additionalContext || json.hookSpecificOutput?.additionalContext || null;
      }
    } catch (err) {
      log('context script failed:', err?.message || err);
    }
  }
  _contextCache.set(key, text);
  return text;
};

const CONTEXT_MARKER = '<ASIMOV_CONTEXT>';

const TOOL_MAPPING = `**Asimov in OpenCode — tool mapping:**
- Plugin root: \`${PLUGIN_ROOT}\`. Where a skill writes \`\${CLAUDE_PLUGIN_ROOT}\` or says to derive the plugin root from its own path, use this path.
- Invoke a skill → the native \`skill\` tool with the bare folder name as id (\`asimov-plugin:asimov-design\` → \`skill\` with \`id: "asimov-design"\`). A person starts one by naming it.
- \`$ARGUMENTS\` in a skill → the words of the person's message after the skill's name.
- Run a shell command → \`shell\`; read, write and edit files → \`read\`, \`write\`, \`edit\` or \`patch\`.
- Spawn a subagent → \`subagent\` with \`agent: "<id>"\` (\`description\`, \`prompt\`; pass \`sessionID\` to continue one). The Asimov agents are registered under their shell names, bare (\`asimov-plugin:baley-the-code-reviewer\` → \`agent: "baley-the-code-reviewer"\`); a generic read-only agent (\`Explore\`) → \`agent: "explore"\`, \`general-purpose\` → \`agent: "general"\`. A \`model\` on the call is ignored: a subagent runs the session's model.
- No todo tool: track a plan in the file the skill names.`;

const wrapContext = (text) => `${CONTEXT_MARKER}\n${text.trim()}\n\n${TOOL_MAPPING}\n</ASIMOV_CONTEXT>`;

// ---------------------------------------------------------------------------
// Sessions: the record carries directory and, for a subagent, parentID. Cached;
// neither changes for a session.
// ---------------------------------------------------------------------------
const _sessionCache = new Map();
const getSession = async (ctx, sessionID) => {
  if (!sessionID || typeof ctx.session.get !== 'function') return null;
  if (_sessionCache.has(sessionID)) return _sessionCache.get(sessionID);
  let session = null;
  try {
    const r = await ctx.session.get({ sessionID });
    session = r && typeof r === 'object' ? ('data' in r ? r.data : r) : null;
    if (session && session.id !== sessionID) session = null;
  } catch (err) {
    debug('session lookup failed:', err?.message || err);
    return null;   // fail open, uncached
  }
  if (_sessionCache.size > 512) _sessionCache.clear();
  _sessionCache.set(sessionID, session);
  debug('session', sessionID, session ? Object.keys(session) : null);
  return session;
};

// ---------------------------------------------------------------------------
// setup(): the V2 entry point.
// ---------------------------------------------------------------------------
async function setup(ctx) {
  if (!ctx || !ctx.skill || typeof ctx.skill.transform !== 'function' || !ctx.session || typeof ctx.session.hook !== 'function') {
    log('OpenCode V2 plugin API not found; nothing registered');
    return;
  }
  debug('ctx keys', Object.keys(ctx), 'directory', ctx.directory);

  // 1. Skills, one per folder under skills/.
  try {
    const skills = [];
    if (fs.existsSync(SKILLS_DIR)) {
      for (const entry of fs.readdirSync(SKILLS_DIR, { withFileTypes: true })) {
        if (!entry.isDirectory() || entry.name.startsWith('.')) continue;
        const skillPath = path.join(SKILLS_DIR, entry.name, 'SKILL.md');
        if (!fs.existsSync(skillPath)) continue;
        const { frontmatter, body } = splitFrontmatter(fs.readFileSync(skillPath, 'utf8'));
        skills.push({
          id: entry.name,
          name: frontmatter.name || entry.name,
          ...(frontmatter.description ? { description: frontmatter.description } : {}),
          path: skillPath,
          content: body,
        });
      }
    }
    await ctx.skill.transform((draft) => {
      for (const skill of skills) {
        try { draft.add(skill); } catch (err) { log(`skill "${skill.id}" rejected by host, skipped:`, err?.message || err); }
      }
    });
    debug('registered skills', skills.map((s) => s.id).join(', '));
  } catch (err) {
    log('skill registration failed:', err?.message || err);
  }

  // 2. The agent shells, one per agents/<name>.md, as subagents. The shell's body is the
  // system prompt and the role skill it preloads is appended to it, so "preloaded above"
  // reads true here as in Claude Code. The model is left unset: a subagent inherits the
  // session's. A shell whose tools: line has no Write/Edit is denied edit.
  if (ctx.agent && typeof ctx.agent.transform === 'function') {
    try {
      const shells = [];
      if (fs.existsSync(AGENTS_DIR)) {
        for (const entry of fs.readdirSync(AGENTS_DIR)) {
          if (!entry.endsWith('.md')) continue;
          const { frontmatter, body } = splitFrontmatter(fs.readFileSync(path.join(AGENTS_DIR, entry), 'utf8'));
          const id = frontmatter.name || entry.replace(/\.md$/, '');
          // `skills:` is a YAML list; the frontmatter reader joins its lines as "- a - b".
          const roleSkills = (frontmatter.skills || '').split(/\s+/).filter((t) => t && t !== '-');
          let system = body.trim();
          for (const s of roleSkills) {
            const skillPath = path.join(SKILLS_DIR, s, 'SKILL.md');
            if (!fs.existsSync(skillPath)) continue;
            system += `\n\n---\n\n# The \`${s}\` skill (preloaded)\n\n${splitFrontmatter(fs.readFileSync(skillPath, 'utf8')).body.trim()}`;
          }
          const tools = frontmatter.tools ? frontmatter.tools.split(',').map((t) => t.trim()) : null;
          const readOnly = tools && !tools.some((t) => /^(Write|Edit|NotebookEdit)$/i.test(t));
          const permissions = [
            { action: '*', resource: '*', effect: 'allow' },
            { action: 'subagent', resource: '*', effect: 'deny' },
            ...(readOnly ? [{ action: 'edit', resource: '*', effect: 'deny' }] : []),
          ];
          shells.push({ id, description: frontmatter.description || '', system, permissions });
        }
      }
      // The editor has no add(); update() on an unknown id creates the agent (OpenCode 2.3.0, undocumented).
      await ctx.agent.transform((editor) => {
        for (const shell of shells) {
          try {
            editor.update(shell.id, (a) => {
              a.id = shell.id;
              a.name = shell.id;
              a.description = shell.description;
              a.mode = 'subagent';
              a.hidden = false;
              a.system = shell.system;
              a.permissions = shell.permissions;
              if (!a.request) a.request = { settings: {}, headers: {}, body: {} };
            });
          } catch (err) {
            log(`agent "${shell.id}" rejected by host, skipped:`, err?.message || err);
          }
        }
      });
      debug('registered agents', shells.map((s) => s.id).join(', '));
    } catch (err) {
      log('agent registration failed:', err?.message || err);
    }
  }

  // 3. The context, into the first user message of every request shape.
  const inject = async (event) => {
    try {
      if (!event?.messages?.length) return;
      const firstUser = event.messages.find((m) => m.role === 'user');
      if (firstUser && (!firstUser.content || !firstUser.content.length)) return;
      if (firstUser?.content.some((p) => p.type === 'text' && p.text?.startsWith(CONTEXT_MARKER))) return;

      const session = await getSession(ctx, event.sessionID);
      const directory = session?.directory || ctx.directory || process.cwd();
      const isChild = typeof session?.parentID === 'string' && session.parentID.length > 0;
      const hookEvent = isChild ? 'SubagentStart' : 'SessionStart';
      const agentType = isChild ? (typeof session?.agent === 'string' ? session.agent : 'unknown') : undefined;

      const text = runContextScript(hookEvent, directory, agentType);
      if (!text) return;
      const part = { type: 'text', text: wrapContext(text) };
      if (firstUser) firstUser.content.unshift(part);
      else event.messages.push({ role: 'user', content: [part] });
      debug('injected', hookEvent, 'for', directory);
    } catch (err) {
      log('session hook failed:', err?.message || err);
    }
  };
  for (const name of ['context', 'compaction', 'generate']) {
    try { await ctx.session.hook(name, inject); } catch (err) { log(`session hook registration failed (${name}):`, err?.message || err); }
  }
}

export default {
  id: 'asimov',
  setup,
};
