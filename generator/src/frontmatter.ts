// Frontmatter parse + serialise for the neutral source and the emitted markdown files.
// Line-based on purpose: the source frontmatter is flat key: value, and a hand-rolled parser
// keeps the generator dependency-free (determinism, D101 §7.5).

export interface SourceDoc {
  fields: Record<string, string>;
  body: string;
}

export function parseFrontmatter(text: string, file: string): SourceDoc {
  const m = /^---\n([\s\S]*?)\n---\n?/.exec(text);
  if (!m) throw new Error(`${file}: no frontmatter block`);
  const fields: Record<string, string> = {};
  let lastKey: string | null = null;
  for (const line of m[1]!.split('\n')) {
    const kv = /^([a-z-]+):\s*(.*)$/.exec(line);
    if (kv) {
      fields[kv[1]!] = kv[2]!;
      lastKey = kv[1]!;
    } else if (lastKey !== null && /^\s+\S/.test(line)) {
      fields[lastKey] += ' ' + line.trim();
    } else if (line.trim() !== '') {
      throw new Error(`${file}: unparseable frontmatter line: ${line}`);
    }
  }
  return { fields, body: text.slice(m[0].length) };
}

/** Serialise frontmatter with a fixed key order — emission order is part of determinism. */
export function serialiseFrontmatter(fields: Record<string, string | undefined>, order: string[]): string {
  const lines = ['---'];
  for (const key of order) {
    const value = fields[key];
    if (value !== undefined && value !== '') lines.push(`${key}: ${value}`);
  }
  lines.push('---', '');
  return lines.join('\n');
}

export function requireField(doc: SourceDoc, key: string, file: string): string {
  const value = doc.fields[key];
  if (value === undefined || value === '') {
    throw new Error(`${file}: required frontmatter field '${key}' is missing — a missing designation fails generation, never defaults (D101 §6.6)`);
  }
  return value;
}
