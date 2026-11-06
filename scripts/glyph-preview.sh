#!/usr/bin/env bash
# Reproducible unshaded RL2a readability review from exported X_eTaL meshes.
# The SVG contains primary-hit masks, with no host font or geometry copy.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
out="$root/work/glyph-readability"
mkdir -p "$out"
"$root/scripts/xt" run tools/glyph-preview.xtl > "$out/silhouettes.txt"
if rg -q '^FAIL' "$out/silhouettes.txt"; then cat "$out/silhouettes.txt"; exit 1; fi
uv run python3 - "$out/silhouettes.txt" "$out/silhouettes.svg" <<'PY'
import html
import re
import sys
from pathlib import Path
panels = []
for line in Path(sys.argv[1]).read_text().splitlines():
    if line.startswith("panel "):
        panels.append((line[6:], []))
    elif panels and re.fullmatch(r"[.#]+", line):
        panels[-1][1].append(line)
if len(panels) != 4 or any(not rows for _, rows in panels):
    raise SystemExit("glyph-preview: expected four nonempty silhouette panels")
svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="820" height="820" viewBox="0 0 820 820">',
       '<rect width="820" height="820" fill="white"/>']
for (label, rows), (left, top) in zip(panels, [(24, 64), (300, 64), (24, 330), (24, 580)]):
    svg.append(f'<text x="{left}" y="{top-16}" font-family="sans-serif" font-size="20">{html.escape(label)}</text>')
    paths = []
    for y, row in enumerate(rows):
        for run in re.finditer(r"#+", row):
            x, width = run.start(), run.end() - run.start()
            paths.append(f"M{x} {y}h{width}v1h{-width}z")
    svg.append(f'<path transform="translate({left} {top}) scale(6)" d="{" ".join(paths)}" fill="#151515"/>')
svg.append('</svg>')
Path(sys.argv[2]).write_text('\n'.join(svg) + '\n')
PY
echo "glyph silhouettes: $out/silhouettes.svg"
if command -v rsvg-convert >/dev/null; then
    rsvg-convert -o "$out/silhouettes.png" "$out/silhouettes.svg"
    echo "glyph preview: $out/silhouettes.png"
fi
