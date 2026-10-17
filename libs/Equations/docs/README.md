# Equations

Equations as printed in papers: one macro call gives the array
computation, its LaTeX, or both. The 2-D cross-correlation of a CNN
layer, written as array code, is the oracle the macros are checked
against.

```
"e:" u_se< "Equations"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `e:` is the
recommended alias.

## The macros

| Macro | What |
| ----- | ---- |
| `"Y[o,h,w] \| O Ho Wo" e:e_q< "(sum j:=0..M-1 \| W[i,j] * x[j]) + b[i]"` | the value of the equation, an array with one axis per free index |
| `"..." e:t_ex< "..."` | the same call's LaTeX, a string: `Y_{o,h,w} = \sum_{c=0}^{C - 1} ...` |
| `"..." e:b_oth< "..."` | both, the pair `(value, latex)` |

All three read the call the same way, so the value and the LaTeX of
one call describe the same equation. A line of output written between
`$$` is drawn as math in the live demo (KaTeX); at the command line it
is the LaTeX itself, for a document.

The left string names the result, its free indices in brackets, then
`|` and one extent per free index (`"L[] | "` for a scalar). The right
string is an expression over the free indices in which a
parenthesized sum is a term, as a paper's sigma is a term of a larger
formula: `(sum j:=0..M-1 | W[i,j] * x[j]) + b[i]` is a dense layer with
its bias. A sum is an operator word (`sum`, `prod`, `max`, `min`), an
index, `:=` and an inclusive range `low..high`; several, separated by
commas, nest outermost first; then `|` and the body. A right side that
is one bare sum needs no parentheses. The CNN layer
`Y[o,h,w] = sum_c sum_r sum_s X[c,h+r,w+s] W[o,c,r,s]` is written as
the paper prints it:

```
Y := "Y[o,h,w] | O Ho Wo" e:e_q< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X[c,h+r,w+s] * W[o,c,r,s]"
```

Inside the strings:

- Expressions follow **math precedence**: `^` binds tightest (right to
  left), then `*` and `/`, then `+` and `-` (left to right); parentheses
  group; a leading `-` negates. So `2*i+k` is `(2*i)+k` and
  `(y[i] - p[i])^2` is the squared difference, whatever X_eTaL's
  right-to-left order would make of them. Bounds, extents and the
  summand are all expressions.
- **The functions** are `exp(x)`, `log(x)`, `sqrt(x)`, `abs(x)`,
  `max(a, b)` and `min(a, b)`, in the paper's spelling; the table grows
  on purpose, and any other name applied is refused.
- **Every rule uses all of its text or refuses it**: a group is one
  parenthesized term, a reference ends at its closing bracket, an atom
  is a name or a number, and only the grammar's characters may appear.
  So `y[i]2`, `y[i] % 2`, `(y[i])(2)` and `y[i][0]` are compile-time
  errors naming the text, never a value with part of the equation
  dropped; and what was read is written back and compared with the
  text at every call, so a rule that dropped a character would refuse
  the call rather than mislead. A bound or extent may not depend on an
  index (a grid has one extent per axis).
- `A[e1,e2,...]` reads one element of the caller's array `A`, **one
  index per axis, counting from 0** as the paper does.
- Any other name (`C`, `Kh`, `X`, `W`) is the caller's value. An index
  that is neither summed nor free (a misspelling) is therefore read as
  a caller's name, and X_eTaL reports it as undefined when the program
  is compiled, at the call.
- A call that is malformed is refused when the program is compiled,
  `error[bad-equation]` at the argument: a missing `|`, a free index
  without an extent, a sum without its word or its range, an index
  bound twice, an operator without a value on each side, an empty
  expression.
- What only the arrays can tell is checked when the program runs,
  before anything is read, and never silently: a reference with fewer
  or more indices than its array has axes is `error[rank]`; an index
  outside its axis is `error[index]`, naming the array, the axis, the
  index and the expression it came from.

The expansion (`xetal expand`, or Expand in the live demo) is ordinary
X_eTaL, laid out as a program (one definition per line, one gather
per line): a grid of every index's values, the two checks, a gather
per array reference and one reduction per sum. The macro's own names are fresh
(`g1:grid`, ...), so the caller's are untouched.

## Examples: equations as papers print them

From `../tests/terms.xtl`, each value checked by hand. A dense layer
with its bias (`W` is 2 by 3 of 1 to 6, `x` three ones, `b` is
`10 20`), the mean squared error, attention scores with their scale
(`Q` the first two unit vectors, so the identity over 2), a softmax,
and max pooling over 2 by 2 windows:

```
      "z[i] | 2" e:e_q< "(sum j:=0..2 | W[i,j] * x[j]) + b[i]"
16 35
      "L[] | " e:e_q< "(sum i:=0..3 | (y[i] - p[i])^2) / 4"
0.3125
      "S[i,j] | 2 2" e:e_q< "(sum d:=0..3 | Q[i,d] * Q[j,d]) / sqrt(4)"
0.5 0.0
0.0 0.5
      "s[i] | 3" e:e_q< "exp(z[i]) / (sum j:=0..2 | exp(z[j]))"
0.09003057317038045 0.24472847105479764 0.6652409557748219
      "P[o,h,w] | 1 2 2" e:e_q< "max r:=0..1, max s:=0..1 | X[o,2*h+r,2*w+s]"
 6  8
14 16
      "r[] | " e:e_q< "prod i:=1..4 | i"
24
```

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `X e:c_orrelate W` | `Num a => a -> a -> a` | the valid cross-correlation of pictures `X` (channels, height, width) with filters `W` (outputs, channels, kernel height, kernel width), written without the macro: `Y[o,h,w]` is the sum over `c`, `r`, `s` of `X[c,h+r,w+s] * W[o,c,r,s]`, shape outputs, `H - Kh + 1`, `Wd - Kw + 1` |

As CNN layers compute it: no kernel flip (a convolution would turn
the kernel around), stride 1, no padding. It is the independent check
of `e:e_q<` (`tests/cnn.xtl` matches the two on three fixtures).

## Examples

From `../tests/precedence.xtl`, with `v := r_ange 10` (so `v[j]` is
`j + 1`): `v[2*i+k]` is `v[(2*i)+k]`, summed over `i` in 0..1 for
`k` in 0..2:

```
      "t[k] | 3" e:e_q< "sum i:=0..1 | v[2*i+k]"
4 6 8
```

Parentheses group, and a bound is an expression too (`i` runs 0..3):

```
      "t[k] | 1" e:e_q< "sum i:=0..1 | v[2*(i+k)]"
4
      "t[k] | 1+1" e:e_q< "sum i:=0..2*2-1 | v[i+k]"
10 14
```

No sum at all: the summand on the free indices.

```
      "t[k] | 4" e:e_q< " | v[k] * v[k]"
1 4 9 16
```

From `../tests/cnn.xtl`, two 4 by 4 pictures of 1 to 32 through one
2 by 2 by 2 filter of 1 to 8 (`C`, `Kh`, `Kw`, `O`, `Ho`, `Wo` bound
to 2, 2, 2, 1, 3, 3):

```
      "Y[o,h,w] | O Ho Wo" e:e_q< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X2[c,h+r,w+s] * W2[o,c,r,s]"
560 596 632
704 740 776
848 884 920
```

The same call's LaTeX (`../tests/latex.xtl`), between `$$` for the
live demo to draw:

```
      "$$" c_at ("Y[o,h,w] | O Ho Wo" e:t_ex< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X[c,h+r,w+s] * W[o,c,r,s]") c_at "$$"
$$Y_{o,h,w} = \sum_{c=0}^{C - 1} \sum_{r=0}^{Kh - 1} \sum_{s=0}^{Kw - 1} X_{c,h+r,w+s} \, W_{o,c,r,s}$$
      "$$" c_at ("t[k] | 3" e:t_ex< "sum i:=0..1 | v[2*i+k]") c_at "$$"
$$t_{k} = \sum_{i=0}^{1} v_{2\,i+k}$$
```

From `../tests/grammar.xtl`, with `y := f_loat 1 2 3 4` and
`p := 1.5 2 2 4`: the squared error and the mean squared error, then
`^` right to left:

```
      "L[] | " e:e_q< "sum i:=0..3 | (y[i] - p[i])^2"
1.25
      "L[] | " e:e_q< "sum i:=0..3 | (y[i] - p[i])^2 / 4"
0.3125
      "r[] | " e:e_q< " | 2^3^2"
512
```

Text the grammar cannot use is refused (`../tests/reject-trailing.xtl`):

```
      "L[] | " e:e_q< "sum i:=0..3 | y[i]2"
error[bad-equation]: an array reference ends with its closing bracket; nothing follows it: y[i]2
```

From `../tests/rank.xtl` and `../tests/bounds.xtl` (`X` is 2 by 4 by
4, `C` is 2): two indices for three axes, and `c` running one past
its channel:

```
      "Y[o,h,w] | O Ho Wo" e:e_q< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X[c,h+r] * W[o,c,r,s]"
error[rank]: X[c,h+r] indexes 2 axes, but X has rank 3
      "Y[o,h,w] | O Ho Wo" e:e_q< "sum c:=0..C | X[c,h,w]"
error[index]: X axis 1: index 2 is outside 0..1 (from c)
```

## Demos

- [`demos/cnn.xtl`](../demos/cnn.xtl): one CNN layer as the paper
  writes it, its result and its LaTeX from one call (`e:b_oth<`),
  the result checked against `e:c_orrelate`.
- [`demos/catalog.xtl`](../demos/catalog.xtl): ten equations as ML
  papers print them, each one call with its LaTeX and its value
  checked against the same computation in plain X_eTaL: a matrix
  product, a dense layer with its bias, attention scores and output,
  softmax, cross-entropy, mean squared error, layer norm's mean and
  variance, cosine similarity, an L2 penalty and max pooling.

## How it is checked

Besides the tests above, `../tests/differential.xtl` holds forty
equations drawn at random from the grammar by
`scripts/gen-equations-differential.py`, each compared with its value
computed independently in Python over the same arrays (every line
prints `1`); and every call compares what the reader read, written
back, with the text it was given, so a rule that dropped a character
refuses the call.

## Provenance

Designed in X_eTaL (`docs/spatial.md`, `docs/eq-rationale.md`: why
each sum carries its own bounds, decision D154) and written here. The
cross-correlation is the textbook definition used by CNN layers (for
example PyTorch's `Conv2d`, which documents it as cross-correlation);
the numbers in the tests were also checked by a direct four-loop
computation outside X_eTaL.
