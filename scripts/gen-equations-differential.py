#!/usr/bin/env -S uv run python3
"""Write libs/Equations/tests/differential.xtl: equations drawn at random
from the grammar (sums, products, max and min as terms, + - * ^, groups,
references, indices), each with its value computed here, in Python,
over the same small arrays, so e:e_q< is checked against an
independent evaluation and not against itself. Deterministic (a fixed
seed); rerun to regenerate after a grammar change, then bless.
  scripts/gen-equations-differential.py
"""
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "libs/Equations/tests/differential.xtl"
random.seed(2026_10_17)

# The caller's arrays: A is 3 by 3 (1 to 9), v and w have 3 items.
A = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
v = [2, -1, 3]
w = [1, 4, 2]
N = 3
WORDS = ["sum", "prod", "max", "min"]


def atom(scope):
    """An atom: a number, an index in scope, or a reference using the indices in scope."""
    choices = [lambda: str(random.randint(1, 3))]
    for i in scope:
        choices.append(lambda i=i: i)
        choices.append(lambda i=i: f"v[{i}]")
        choices.append(lambda i=i: f"w[{i}]")
    if len(scope) >= 2:
        a, b = scope[0], scope[1]
        choices.append(lambda: f"A[{a},{b}]")
    return random.choice(choices)()


def term(scope, depth):
    if depth == 0:
        return atom(scope)
    kind = random.choice(["bin", "bin", "group", "sum", "pow", "atom"])
    if kind == "atom":
        return atom(scope)
    if kind == "group":
        return f"({term(scope, depth - 1)})"
    if kind == "pow":
        return f"{atom(scope)}^{random.randint(1, 2)}"
    if kind == "sum" and len(scope) < 2:
        j = "j" if "j" not in scope else "k"
        word = random.choice(WORDS)
        return f"({word} {j}:=0..{N - 1} | {term(scope + [j], depth - 1)})"
    op = random.choice(["+", "-", "*"])
    return f"{term(scope, depth - 1)} {op} {term(scope, depth - 1)}"


def value(text, env):
    """The Python value of an equation text: the grammar's operators map to Python's."""
    t = text
    # (word j:=0..2 | body) -> reduce over j of body
    while "|" in t:
        # innermost parenthesized sum: find the last "(sum"-like open before a "|"
        bar = t.index("|")
        open_ = t.rfind("(", 0, bar)
        depth = 0
        close = None
        for k in range(open_, len(t)):
            depth += (t[k] == "(") - (t[k] == ")")
            if depth == 0:
                close = k
                break
        inner = t[open_ + 1:close]
        head, body = inner.split("|", 1)
        word, binding = head.strip().split(" ", 1)
        j, rng = binding.split(":=")
        lo, hi = rng.split("..")
        vals = [value(body, {**env, j.strip(): x}) for x in range(int(lo), int(hi) + 1)]
        red = {"sum": sum, "prod": lambda xs: __import__("math").prod(xs), "max": max, "min": min}[word]
        t = t[:open_] + f"({red(vals)})" + t[close + 1:]
    py = t.replace("^", "**")
    for i in ("i", "j", "k"):
        if i in env:
            py = __import__("re").sub(rf"\b{i}\b", f"({env[i]})", py)
    py = __import__("re").sub(r"A\[\((\d+)\),\((\d+)\)\]", lambda m: f"({A[int(m.group(1))][int(m.group(2))]})", py)
    py = __import__("re").sub(r"v\[\((\d+)\)\]", lambda m: f"({v[int(m.group(1))]})", py)
    py = __import__("re").sub(r"w\[\((\d+)\)\]", lambda m: f"({w[int(m.group(1))]})", py)
    return eval(py)  # noqa: S307 (our own generated arithmetic)


def literal(n):
    return str(n)


lines = [
    "#!/usr/bin/env xetal",
    "# Written by scripts/gen-equations-differential.py: equations drawn at",
    "# random from the grammar, each compared (m_atch) with its value computed",
    "# independently in Python over the same arrays; every line prints 1.",
    '"e:" u_se< "Equations"',
    "A := 3 3 r_eshape r_ange 9",
    "v := 2 -1 3",
    "w := 1 4 2",
]
made = 0
while made < 40:
    scalar = random.random() < 0.3
    scope = [] if scalar else ["i"]
    text = term(scope, random.randint(1, 3))
    try:
        if scalar:
            val = value(text, {})
            expect = literal(val)
            lhs = '"r[] | "'
        else:
            vals = [value(text, {"i": i}) for i in range(N)]
            expect = " ".join(literal(x) for x in vals)
            lhs = f'"r[i] | {N}"'
    except Exception:
        continue
    if any(abs(x) > 10**15 for x in ([val] if scalar else vals)):
        continue
    lines.append(f'({lhs} e:e_q< "{text}") m_atch {expect}')
    made += 1
OUT.write_text("\n".join(lines) + "\n")
print(f"wrote {OUT.relative_to(ROOT)} with {made} equations")
