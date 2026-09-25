// The one token-substitution implementation — both emitters call this, so a token can never
// behave differently per target by accident (D101 §7.5). A token without a value for the
// current target fails the run; so does a token the generator does not know (§6.4.2).
//
// Token grammar: {{lowercase-kebab}} only. Uppercase placeholders like {{REPO-NAME}} are
// template content quoted in prose (the D101/index templates' own placeholder style) and pass
// through untouched — the two namespaces are deliberately distinct.

export function substitute(body: string, values: Record<string, string>, file: string): string {
  const out = body.replace(/\{\{([a-z][a-z-]*)\}\}/g, (_, token: string) => {
    const value = values[token];
    if (value === undefined) {
      throw new Error(`${file}: token {{${token}}} has no value for this target — a token without a value for every target fails generation (D101 §6.4.2)`);
    }
    return value;
  });
  const leftover = /\{\{[a-z][a-z-]*\}\}/.exec(out);
  if (leftover) throw new Error(`${file}: unresolved token ${leftover[0]} after substitution`);
  return out;
}
