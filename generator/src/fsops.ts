// Deterministic file-system helpers: sorted walks, LF-only writes, whole-tree replace.
// No timestamps, no run-dependent values (D101 §7.5).

import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';

export function readText(file: string): string {
  return readFileSync(file, 'utf8').replace(/\r\n/g, '\n');
}

export function writeText(file: string, content: string): void {
  mkdirSync(dirname(file), { recursive: true });
  const lf = content.replace(/\r\n/g, '\n');
  writeFileSync(file, lf.endsWith('\n') ? lf : lf + '\n');
}

/** Sorted, deterministic directory listing. */
export function listDir(dir: string): string[] {
  return readdirSync(dir).sort();
}

/** Recursively list files under dir, repo-relative, sorted. */
export function walk(dir: string, prefix = ''): string[] {
  const out: string[] = [];
  for (const entry of listDir(dir)) {
    const full = join(dir, entry);
    const rel = prefix === '' ? entry : `${prefix}/${entry}`;
    if (statSync(full).isDirectory()) out.push(...walk(full, rel));
    else out.push(rel);
  }
  return out;
}

/** Copy a tree verbatim (LF-normalised), file by file, sorted. */
export function copyTree(from: string, to: string): void {
  for (const rel of walk(from)) {
    writeText(join(to, rel), readText(join(from, rel)));
  }
}

/**
 * Empty a directory if present (output dirs are replaced wholesale each run). Every stale FILE must
 * go — a file that cannot be removed fails the run. Directories are best-effort: on Windows a tool
 * that holds a folder open (Codex serving a local-clone install, its sandbox service, an IDE) makes
 * removing that folder fail with EPERM/EBUSY although its contents can go, so a held folder is kept
 * and simply written into again. The emitted files are what the pipeline byte-compares.
 */
export function clearDir(dir: string): void {
  if (!existsSync(dir)) return;
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      clearDir(full);
      try {
        rmSync(full, { recursive: true, force: true });
      } catch (e) {
        if (!isHeld(e)) throw e;
      }
    } else {
      rmSync(full, { force: true });
    }
  }
}

function isHeld(e: unknown): boolean {
  const code = (e as NodeJS.ErrnoException).code;
  return code === 'EPERM' || code === 'EBUSY' || code === 'ENOTEMPTY';
}

export function writeJson(file: string, value: unknown): void {
  writeText(file, JSON.stringify(value, null, 2));
}
