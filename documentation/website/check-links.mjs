// documentation/website/check-links.mjs — every relative href/src in site/ must resolve to a file.
// Run: node documentation/website/check-links.mjs
import { readdirSync, readFileSync, statSync, existsSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';

const root = resolve('site');
const files = [];
(function walk(d) { for (const n of readdirSync(d)) { const p = join(d, n); statSync(p).isDirectory() ? walk(p) : n.endsWith('.html') && files.push(p); } })(root);

let bad = 0;
for (const f of files) {
  const html = readFileSync(f, 'utf8');
  for (const m of html.matchAll(/\b(?:href|src)="([^"#?]+)/g)) {
    const t = m[1];
    if (/^(https?:|mailto:|data:)/.test(t)) continue;
    let p = t.startsWith('/') ? join(root, t) : join(dirname(f), t);
    if (t.endsWith('/')) p = join(p, 'index.html');
    if (!existsSync(p)) { bad++; console.log(`${f}: ${t}`); }
  }
}
console.log(bad ? `${bad} broken link(s)` : `ok: ${files.length} page(s), all links resolve`);
process.exit(bad ? 1 : 0);
