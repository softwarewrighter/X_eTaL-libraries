#!/usr/bin/env bash
# Every line between $$ that a library's tests record (tests/*.out) is
# LaTeX that KaTeX accepts (the version the live demo loads from its
# CDN), checked with node and tools/katex (cd tools/katex && npm ci);
# skipped without them. Run by the gate.
#   scripts/check-latex.sh
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v node >/dev/null || [ ! -d "$root/tools/katex/node_modules/katex" ]; then
  echo "check-latex: no node or KaTeX (cd tools/katex && npm ci); skipped"; exit 0
fi
node - "$root" <<'JS'
const fs = require('fs'), path = require('path');
const root = process.argv[2];
const katex = require(path.join(root, 'tools/katex/node_modules/katex'));
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
