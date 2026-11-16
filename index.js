// Root entrypoint for OpenCode V2: a plugin configured as a local path must be a directory
// with an index.js (a bare file path is refused), and a git/npm spec resolves package.json
// `main`. Both land here. Nothing else in the repo reads this file.
export { default } from './plugins/asimov-plugin/.opencode/plugins/asimov.js';
