#!/usr/bin/env python3
"""A program's macro calls and what each became (xetal expand).

  scripts/expand.py FILE           # each changed line: before and after
  scripts/expand.py --all FILE     # the whole program, the changes marked

Runs scripts/xt expand on FILE (from its directory) and compares it
with FILE line by line: lines that differ are a macro call (its name
picked out) and its expansion. Colours when the output is a terminal.
"""
import difflib
import os
import re
import subprocess
import sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = sys.argv[1:]
show_all = "--all" in args
args = [a for a in args if a != "--all"]
if len(args) != 1:
    sys.exit("usage: expand.py [--all] FILE")
path = os.path.abspath(args[0])
src = open(path).read().splitlines()
run = subprocess.run([os.path.join(root, "scripts", "xt"), "expand", os.path.basename(path)],
                     cwd=os.path.dirname(path), capture_output=True, text=True)
if run.returncode != 0:
    sys.stderr.write(run.stdout + run.stderr)
    sys.exit(run.returncode)
out = run.stdout.splitlines()
while out and not out[-1].strip():
    out.pop()
while src and not src[-1].strip():
    src.pop()

tty = sys.stdout.isatty()
def paint(code, text):
    return f"\033[{code}m{text}\033[0m" if tty else text
MACRO = re.compile(r"\b[a-z][A-Za-z0-9]*:?[a-z]_[A-Za-z0-9]*<|\b[a-z]_[A-Za-z0-9]*<")
def mark(line):                       # the macro's name picked out
    return MACRO.sub(lambda m: m.group(0) if m.group(0).endswith("u_se<") else paint("1;33", m.group(0)), line)

blocks = [op for op in difflib.SequenceMatcher(None, src, out, autojunk=False).get_opcodes() if op[0] != "equal"]
calls = [m.group(0) for b in blocks for l in src[b[1]:b[2]] for m in MACRO.finditer(l) if not m.group(0).endswith("u_se<")]
names = sorted(set(calls))
if not blocks:
    print("no macro calls to expand (u_se< imports are not expanded)")
    sys.exit(0)
n = len(calls) or len(blocks)
print(f"{n} macro call{'s' if n != 1 else ''} expanded ({', '.join(names) or 'a macro'}):")
if show_all:
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, src, out, autojunk=False).get_opcodes():
        if tag == "equal":
            for l in out[j1:j2]:
                print("  " + (paint("2", l) if tty else l))
        else:
            for l in src[i1:i2]:
                print(paint("31", "- ") + mark(l))
            for l in out[j1:j2]:
                print(paint("32", "+ ") + paint("1", l))
else:
    for tag, i1, i2, j1, j2 in blocks:
        print()
        print(f"line {i1 + 1}" + (f"-{i2}" if i2 - i1 > 1 else "") + ":")
        for l in src[i1:i2]:
            print("  written:  " + mark(l.strip()))
        for k, l in enumerate(out[j1:j2]):
            print(("  expanded: " if k == 0 else "            ") + paint("1;32", l.strip()))
