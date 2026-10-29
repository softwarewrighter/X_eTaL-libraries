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
| `"y[n] \| full" e:c_onvolve< "x h"` | the discrete convolution of the signal `x` by the kernel `h`, the sum it is, in the named mode (`full`, `same` or `valid`; none is implicit) |
| `"y[n] \| valid" e:c_orrelate< "x h"` | the cross-correlation (the kernel not reversed), the same call shape |
| `"y[n] \| full" e:c_onvolveTex< "x h"`, `e:c_orrelateTex<` | the LaTeX of a convolution or correlation call: `y_{n} = \sum_{m} x_{n - m} \, h_{m} \quad \text{(full)}` |

All three read the call the same way, so the value and the LaTeX of
one call describe the same equation. A line of output written between
`$$` is drawn as math in the live demo (KaTeX); at the command line it
is the LaTeX itself, for a document.

### Drawn as math where the program is drawn

The two strings of an `e:e_q<`, `e:b_oth<`, `e:c_onvolve<` or
`e:c_orrelate<` call are notations (X_eTaL MC32): the macro declares
`## takes: notation notation` and `## draws: t_ex<` (or
`c_onvolveTex<`, `c_orrelateTex<`), so wherever a program is drawn
rather than run, the call is shown as the macro's name and then one
math box, the LaTeX that drawer gives, typeset by KaTeX: in the live
demo here, in X_eTaL's live demo, doc site and `xetal render --html`,
in the literate pages. The binding and the macro name stay as code, so
the reader still sees which macro ran:

```
s := e:e_q< [ S = \sum_{i=0}^{2} x_{i} ]      (the box typeset)
```

The terminal (`xetal render --color`, `xetal edit`) has no math
renderer and shows the typed strings in the notation style. The
program's text and value are unchanged: the drawer runs only where the
program is drawn, never when it runs (`../tests/notation.xtl`; its
HTML is `../tests/drawn-notation.out`).

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
  `sin(x)`, `cos(x)`, `max(a, b)` and `min(a, b)`, in the paper's
  spelling; the table grows on purpose, and any other name applied is
  refused.
- **An integral** is the operator word `integral`: it binds a
  continuous variable over Float bounds and takes the value of its
  body by a quadrature rule written after `by`, the rule and the
  number of steps: `integral tau:=0..1 by simpson 64 | exp(tau)`
  (`trapezoid` or `simpson`; without `by`, `trapezoid 64`; simpson
  needs an even number). The variable is the grid of n + 1 points a,
  a + h, ..., b, so the body is evaluated once over the grid, and an
  integral may hold sums and sums integrals. Trapezoid is exact on
  lines, simpson on cubics; at a jump of the body the sample takes
  the body's value at that point as written. A bound of `inf` is
  refused: write a truncation and show the tail is small, or change
  variables so the bounds are finite. Its LaTeX is `\int_{a}^{b}
  ... \, d\tau`. A Greek letter's name is its command wherever it
  appears: the result (`Phi` is `\Phi`), an index, a bound, the body;
  the capitals LaTeX has (Gamma, Delta, Theta, Lambda, Xi, Pi, Sigma,
  Upsilon, Phi, Psi, Omega) as well as the lowercase letters.
- **A scan** is the operator word `scan`: a term whose value depends
  on the one before it, which `sum`'s reduce cannot give (its reduce
  is a right fold, same as `prod`, `max` and `min`, only the same as a
  running accumulation when the combining step is associative).
  `scan t:=T..1 by seed | prev + t` folds one term at a time from `T`
  down to 1 (either direction: `low..high` is `sum`'s convention, a
  scan's own is `start..end`), naming the one before with the
  reserved word `prev`; `by seed` gives `prev` its value before the
  first term (`scan`'s own option, where `integral` writes its rule
  and grid). A scan must be the term's only binding (no sum, prod, max,
  min or integral alongside it), and a body that names `prev` needs a
  seed -- without one there is no value for it to hold at the first
  term, and the call is refused rather than guessing one. `prev` is
  reserved everywhere else, refused even inside a plain sum. Its LaTeX
  is `\operatorname{scan}_{t=T}^{1}`; `prev` draws as itself.
- **Every rule uses all of its text or refuses it**: a group is one
  parenthesized term, a reference ends at its closing bracket, an atom
  is a name or a number, and only the grammar's characters may appear.
  So `y[i]2`, `y[i] % 2`, `(y[i])(2)` and `y[i][0]` are compile-time
  errors naming the text, never a value with part of the equation
  dropped; and what was read is written back and compared with the
  text at every call, so a rule that dropped a character would refuse
  the call rather than mislead. The result is held to the same rule:
  `Y[o]2 | O` is refused, not read as `Y[o]`. A bound or extent may
  not depend on an index (a grid has one extent per axis). The rules
  are the [Parsing](../../Parsing/docs/README.md) library's (`pa:`),
  its refusals reported as `error[bad-equation]`.
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
- A sum, product, max or min's range is the caller's own values
  (`sum t:=T..1`), so whether it runs backwards cannot be told until
  the program runs either: that check is `error[bad-equation]` too,
  naming the word and the range as written (`"sum's range runs
  low..high: T..1"`), not the array machinery's own count error. A
  range that reaches exactly one below its low (`0..N-1` when `N` is
  0) is the empty sum, not a refusal.

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

### Convolution and correlation

Both are library macros over `sum`, not words of the grammar (X_eTaL
Saga 42 decision 5): `xetal expand` shows the sum each call becomes.
Convolution is `y[n] = sum_m x[n - m] h[m]`, the kernel reversed as it
slides; correlation `y[n] = sum_m x[n + m] h[m]`, the kernel as
written (what a CNN layer computes), so correlation is convolution
with the kernel reversed. The modes: `full` gives `L + M - 1` values
(every overlap, the signal padded with `M - 1` zeros of its own type at
each end), `same` the `L` centered on full (as numpy centers them),
`valid` the `L - M + 1` complete overlaps (a kernel longer than the
signal stops the program when it runs, `error[valid-mode]`). The
fixture is asymmetric so the two cannot be confused. From
`../tests/convolution.xtl`:

```
      "y[n] | full" e:c_onvolve< "x h"
1 4 10 16 17 12
      "y[n] | valid" e:c_onvolve< "x h"
10 16
      "y[n] | valid" e:c_orrelate< "x h"
14 20
```

### Integrals

From `../tests/integrals.xtl` (the oracle: X_eTaL-ML's Integrals,
the same call standing alone):

```
      "L[] | " e:e_q< "integral x:=0..1 by simpson 2 | x^2"
0.3333333333333333
      "L[] | " e:e_q< "integral x:=0..2 by trapezoid 4 | 1 + 2 * x"
6.0
```

Doubling the grid divides trapezoid's error by about 4 and simpson's
by about 16 (`exp` over 0..1):

```
      f_loor 0.5 + (t8 / t16) c_at (t16 / t32) c_at (s8 / s16) c_at s16 / s32
4 4 16 16
```

And from `../tests/integral-latex.xtl`:

```
      "L[] | " e:t_ex< "integral tau:=0..1 | exp(tau)"
L = \int_{0}^{1} \exp(\tau) \, d\tau
      "L[] | " e:t_ex< "integral x:=0..1, integral y:=0..x | x * y"
L = \int_{0}^{1} \int_{0}^{x} x \, y \, dy \, dx
```

### Scans

From `../tests/scan.xtl`, with `N := 4`: the sum of squares from `N`
down to 1, folded one term at a time (`prev` the running total, `by
0` its seed), and the same read ascending -- either direction gives
the same value, since `+` does not care which end a scan starts at:

```
      "r[] | " e:e_q< "(scan t:=N..1 by 0 | prev + t * t)"
30
      "r[] | " e:e_q< "(scan t:=1..N by 0 | prev + t * t)"
30
```

A scan is a term like any other, so `2 * (scan ...)` reads normally,
and a single-term scan (`start` and `end` the same) still takes its
seed:

```
      "r[] | " e:e_q< "1 + 2 * (scan t:=N..1 by 0 | prev + t)"
21
      "r[] | " e:e_q< "(scan t:=N..N by 100 | prev + t)"
104
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

From `../tests/reject-descending-range.xtl`, with `T := 3`: a sum
written backwards (the caller's `T` is not known until the program
runs, so this cannot be caught sooner):

```
      "r[] | " e:e_q< "sum t:=T..1 | 1"
error[bad-equation]: sum's range runs low..high: T..1
```

A scan outside a sum (`../tests/reject-prev-outside-scan.xtl`),
mixed with another binding (`../tests/reject-scan-mixed.xtl`) and
with no seed (`../tests/reject-scan-no-seed.xtl`):

```
      "r[] | " e:e_q< "sum i:=0..3 | prev + i"
error[bad-equation]: prev names the term before inside a scan; it cannot be used here: (sum i:=0..3 | prev + i)
      "r[] | " e:e_q< "(scan t:=N..1 by 0, sum i:=0..1 | prev + t + i)"
error[bad-equation]: a scan must be the only binding of its term (no sum, prod, max, min or integral alongside it): (scan t:=N..1 by 0, sum i:=0..1 | prev + t + i)
      "r[] | " e:e_q< "(scan t:=N..1 | prev + t)"
error[bad-equation]: a scan whose body uses prev needs a seed: scan t:=N..1 by seed | prev + t
```

## Demos

- [`demos/cnn.xtl`](../demos/cnn.xtl): one CNN layer as the paper
  writes it, its result and its LaTeX from one call (`e:b_oth<`),
  the result checked against `e:c_orrelate`.
- [`demos/convolution.xtl`](../demos/convolution.xtl): convolution
  and correlation of an asymmetric signal and kernel in every mode,
  the valid cases also written out as equations with their LaTeX, a
  smoothing and a difference filter.
- [`demos/integrals.xtl`](../demos/integrals.xtl): two continuous
  equations: GELU, x times the Gaussian CDF as an integral, against
  the tanh approximation the frameworks compute (its largest error
  0.000473), and the KL divergence of two Gaussians by the integral
  and by its closed form (0.443147 both).
- [`demos/catalog.xtl`](../demos/catalog.xtl): thirteen equations as
  ML papers print them, each one call with its LaTeX and its value
  checked against an independent computation (plain X_eTaL, or a
  closed form): a matrix product, a dense layer with its bias,
  attention scores and output, softmax, cross-entropy, mean squared
  error, layer norm's mean and variance, cosine similarity, an L2
  penalty, max pooling, a 1-D convolution (against `e:c_onvolve<` and
  against inner products), GELU by its integral (against the tanh
  approximation, to 5e-4) and the KL divergence of two Gaussians by
  its integral (against the closed form).

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
