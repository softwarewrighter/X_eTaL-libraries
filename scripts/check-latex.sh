#!/usr/bin/env bash
# Every line between $$ that a library's tests record (tests/*.out) is
# LaTeX that KaTeX accepts, checked with node and the live demo's
# vendored KaTeX (site/katex); skipped without node. Run by the gate.
#   scripts/check-latex.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v node >/dev/null || { echo "check-latex: no node; skipped"; exit 0; }
node - "$root" <<'JS'
const fs = require('fs'), path = require('path');
const root = process.argv[2];
const katex = require(path.join(root, 'site/katex/katex.min.js'));
let n = 0, bad = 0;
for (const lib of fs.readdirSync(path.join(root, 'libs')).sort()) {
  const dir = path.join(root, 'libs', lib, 'tests');
  if (!fs.existsSync(dir)) continue;
  for (const f of fs.readdirSync(dir).filter((f) => f.endsWith('.out')).sort()) {
    for (const line of fs.readFileSync(path.join(dir, f), 'utf8').split('\n')) {
      const t = line.trim();
      if (!(t.startsWith('$$') && t.endsWith('$$') && t.length >= 4)) continue;
      n++;
      try { katex.renderToString(t.slice(2, -2), { displayMode: true, throwOnError: true, strict: 'error' }); }
      catch (e) { bad++; console.error(`check-latex: ${lib}/tests/${f}: ${e.message}`); }
    }
  }
}
console.log(`check-latex: ${n} lines through KaTeX, ${bad} rejected`);
process.exit(bad ? 1 : 0);
JS
