#!/usr/bin/env python3
"""The libraries: lib/<Name>.xtl, each with tests/<Name>/ and docs/libs/<Name>.md.

  scripts/libs.py list     # library names, one per line
  scripts/libs.py table    # name, alias, summary
  scripts/libs.py check    # every library is complete and well-formed

A library's header: line 1 is "# Name: summary", and a comment line
holds its import line, '"alias:" u_se< "Name"' (the recommended alias).
XETAL_LIBS_ROOT overrides the repository root (scripts/selftest-libs.sh).
"""
import os
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
ROOT = Path(os.environ.get("XETAL_LIBS_ROOT", REPO))
STANDARD = {p.stem for p in (REPO / "vendor/xetal/lib").glob("*.xtl")}


def names():
    return sorted(p.stem for p in (ROOT / "lib").glob("*.xtl"))


def header(name):
    text = (ROOT / "lib" / f"{name}.xtl").read_text()
    lines = text.splitlines()
    m = re.match(rf"# {re.escape(name)}: (.+)", lines[0] if lines else "")
    a = re.search(rf'"([a-z]+:)" u_se< "{re.escape(name)}"', text)
    return (m.group(1) if m else None), (a.group(1) if a else None)


def exports(name):
    types = ROOT / "tests" / name / "expected" / "types.out"
    if not types.exists():
        return []
    return [m.group(1) for m in re.finditer(r"^l:(\S+) :", types.read_text(), re.M)]


def check():
    errors = []
    for name in names():
        where = f"lib/{name}.xtl"
        if not re.fullmatch(r"[A-Z][A-Za-z0-9]*", name):
            errors.append(f"{where}: a library name is UpperCamel")
        if name in STANDARD:
            errors.append(f"{where}: named like the standard library {name}")
        summary, alias = header(name)
        if not summary:
            errors.append(f"{where}: line 1 must be '# {name}: what it is'")
        if not alias:
            errors.append(f"{where}: no import line '\"x:\" u_se< \"{name}\"' in its header")
        t = ROOT / "tests" / name
        if not list(t.glob("*.xtl")):
            errors.append(f"tests/{name}/: no test programs")
        if not (t / "expected" / "types.out").exists():
            errors.append(f"tests/{name}/expected/types.out: missing (XETAL_BLESS=1 to create)")
        page = ROOT / "docs" / "libs" / f"{name}.md"
        if not page.exists():
            errors.append(f"docs/libs/{name}.md: missing")
        else:
            text = page.read_text()
            for e in exports(name):
                if f"{alias or ''}{e}" not in text:
                    errors.append(f"docs/libs/{name}.md: export {alias or ''}{e} not documented")
    for t in sorted((ROOT / "tests").glob("*/")):
        if t.name not in names():
            errors.append(f"tests/{t.name}/: no lib/{t.name}.xtl")
    for e in errors:
        print(f"libs: {e}", file=sys.stderr)
    return 1 if errors else 0


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "list"
    if cmd == "list":
        for n in names():
            print(n)
    elif cmd == "table":
        for n in names():
            summary, alias = header(n)
            print(f"{n}\t{alias or '?'}\t{summary or '?'}")
    elif cmd == "check":
        sys.exit(check())
    else:
        sys.exit(f"libs.py: unknown command {cmd!r} (list, table, check)")


if __name__ == "__main__":
    main()
