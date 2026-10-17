#!/usr/bin/env -S uv run python3
"""The math a program prints: run a library's demo or test program as
the tests do (scripts/xt run), print each line between $$ as LaTeX,
and write a page under work/tex/ that shows the program, its output
and the math drawn by KaTeX (from jsDelivr, the version the live demo
loads; nothing redistributed), opened in the browser.
  scripts/tex.py Equations cnn          # libs/Equations/demos/cnn.xtl
  scripts/tex.py Equations latex        # libs/Equations/tests/latex.xtl
  XETAL_TEX_OPEN=0 scripts/tex.py ...   # write the page, do not open it
"""
import html
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
KATEX = "https://cdn.jsdelivr.net/npm/katex@0.18.10/dist"
CSS_SRI = "sha384-rdqqrpVNEfmY6hsVFS50HU5L84tWeMdr4XpF+TJPvLR6e8YxPgRyDzzpawPHMQE6"
JS_SRI = "sha384-oeXTyN/gxEn/v98/oDFW+7XVfZrp59R6Tporzsg2uNs9g+G9Xel/Afxdamc4Mags"
AUTO_SRI = "sha384-bjyGPfbij8/NDKJhSGZNP/khQVgtHUE5exjm4Ydllo42FwIgYsdLO2lXGmRBf5Mz"
FONT = "https://cdn.jsdelivr.net/gh/cormullion/juliamono@v0.63.2/webfonts/JuliaMono-Regular.woff2"

PAGE = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>{title}</title>
<link rel="stylesheet" href="{katex}/katex.min.css" integrity="{css}" crossorigin="anonymous">
<script defer src="{katex}/katex.min.js" integrity="{js}" crossorigin="anonymous"></script>
<script defer src="{katex}/contrib/auto-render.min.js" integrity="{auto}" crossorigin="anonymous"
  onload="renderMathInElement(document.body, {{delimiters: [{{left: '$$', right: '$$', display: true}}]}})"></script>
<style>
@font-face {{ font-family: JuliaMono; src: url("{font}") format("woff2"); font-display: swap; }}
body {{ max-width: 60rem; margin: 2rem auto; padding: 0 1rem; font: 15px/1.45 system-ui, sans-serif; color: #222; }}
h1 {{ font-size: 1.3rem; }} h2 {{ font-size: 1rem; color: #666; text-transform: uppercase; letter-spacing: .04em; }}
pre {{ font-family: JuliaMono, Menlo, monospace; background: #f6f6f6; border: 1px solid #ddd; border-radius: 8px; padding: 12px; white-space: pre-wrap; }}
.katex-display {{ margin: .4em 0; }}
</style></head><body>
<h1>{title}</h1>
<h2>Program</h2><pre>{program}</pre>
<h2>Output</h2>
{output}
<p>Each line the program printed between $$ is drawn by KaTeX; the rest is its output as printed.</p>
</body></html>
"""


def is_math(line: str) -> bool:
    t = line.strip()
    return t.startswith("$$") and t.endswith("$$") and len(t) >= 4


def blocks(output: str) -> str:
    """The output as HTML: runs of text lines in a pre, each $$ line as
    its own block for auto-render (which skips pre and code)."""
    parts, text = [], []
    flush = lambda: parts.append(f"<pre>{html.escape(chr(10).join(text))}</pre>") if text else None
    for line in output.splitlines():
        if is_math(line):
            flush(); text = []
            parts.append(f'<div class="math">{html.escape(line.strip())}</div>')
        else:
            text.append(line)
    flush()
    return "\n".join(parts)


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    name, prog = sys.argv[1], sys.argv[2].removesuffix(".xtl")
    path = next((p for p in (ROOT / "libs" / name / d / f"{prog}.xtl" for d in ("demos", "tests")) if p.exists()), None)
    if path is None:
        print(f"tex: no libs/{name}/demos/{prog}.xtl or tests/{prog}.xtl", file=sys.stderr)
        return 1
    run = subprocess.run([str(ROOT / "scripts" / "xt"), "run", path.name], cwd=path.parent, capture_output=True, text=True)
    output = run.stdout + run.stderr
    tex = [l.strip()[2:-2].strip() for l in output.splitlines() if is_math(l)]
    for t in tex:
        print(t)
    if not tex:
        print(f"tex: {path.relative_to(ROOT)} prints no line between $$", file=sys.stderr)
    out = ROOT / "work" / "tex" / f"{name}-{prog}.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(PAGE.format(title=f"{name}: {prog}.xtl", katex=KATEX, css=CSS_SRI, js=JS_SRI, auto=AUTO_SRI, font=FONT,
                               program=html.escape(path.read_text()), output=blocks(output)))
    print(f"page: {out.relative_to(ROOT)}")
    if os.environ.get("XETAL_TEX_OPEN", "1") != "0":
        opener = "open" if sys.platform == "darwin" else "xdg-open"
        subprocess.run([opener, str(out)], check=False)
    return 0 if run.returncode == 0 else run.returncode


if __name__ == "__main__":
    sys.exit(main())
