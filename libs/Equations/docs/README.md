# Equations

Sums as printed in papers: one macro call gives the array computation.
The 2-D cross-correlation of a CNN layer, written as array code, is
the oracle the macro is checked against.

```
"e:" u_se< "Equations"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `e:` is the
recommended alias.

## The macro

| Macro | What |
| ----- | ---- |
| `"Y[o,h,w] \| O Ho Wo" e:q_< "sum c:=0..C - 1, ... \| summand"` | the value of the sum, an array with one axis per free index |

The left string names the result, its free indices in brackets, then
`|` and one extent per free index. The right string lists the sums,
outermost first, each an operator word (`sum`), an index, `:=` and an
inclusive range `low..high`; then `|` and the summand. The CNN layer
`Y[o,h,w] = sum_c sum_r sum_s X[c,h+r,w+s] W[o,c,r,s]` is written as
the paper prints it:

```
Y := "Y[o,h,w] | O Ho Wo" e:q_< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X[c,h+r,w+s] * W[o,c,r,s]"
```

Inside the strings:

- Expressions follow **math precedence**: `*` and `/` before `+` and
  `-`, left to right, parentheses group, a leading `-` negates. So
  `2*i+k` is `(2*i)+k`, whatever X_eTaL's right-to-left order would
  make of it. Bounds, extents and the summand are all expressions.
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

The expansion (`xetal expand`, or Expand in the live demo) is ordinary
X_eTaL: a grid of every index's values, a gather per array reference
and one reduction per sum. The macro's own names are fresh
(`g1:grid`, ...), so the caller's are untouched.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `X e:c_orrelate W` | `Num a => a -> a -> a` | the valid cross-correlation of pictures `X` (channels, height, width) with filters `W` (outputs, channels, kernel height, kernel width), written without the macro: `Y[o,h,w]` is the sum over `c`, `r`, `s` of `X[c,h+r,w+s] * W[o,c,r,s]`, shape outputs, `H - Kh + 1`, `Wd - Kw + 1` |

As CNN layers compute it: no kernel flip (a convolution would turn
the kernel around), stride 1, no padding. It is the independent check
of `e:q_<` (`tests/cnn.xtl` matches the two on three fixtures).

## Examples

From `../tests/precedence.xtl`, with `v := r_ange 10` (so `v[j]` is
`j + 1`): `v[2*i+k]` is `v[(2*i)+k]`, summed over `i` in 0..1 for
`k` in 0..2:

```
      "t[k] | 3" e:q_< "sum i:=0..1 | v[2*i+k]"
4 6 8
```

Parentheses group, and a bound is an expression too (`i` runs 0..3):

```
      "t[k] | 1" e:q_< "sum i:=0..1 | v[2*(i+k)]"
4
      "t[k] | 1+1" e:q_< "sum i:=0..2*2-1 | v[i+k]"
10 14
```

No sum at all: the summand on the free indices.

```
      "t[k] | 4" e:q_< " | v[k] * v[k]"
1 4 9 16
```

From `../tests/cnn.xtl`, two 4 by 4 pictures of 1 to 32 through one
2 by 2 by 2 filter of 1 to 8 (`C`, `Kh`, `Kw`, `O`, `Ho`, `Wo` bound
to 2, 2, 2, 1, 3, 3):

```
      "Y[o,h,w] | O Ho Wo" e:q_< "sum c:=0..C - 1, sum r:=0..Kh - 1, sum s:=0..Kw - 1 | X2[c,h+r,w+s] * W2[o,c,r,s]"
560 596 632
704 740 776
848 884 920
```

## Demos

- [`demos/cnn.xtl`](../demos/cnn.xtl): one CNN layer as the paper
  writes it, checked against `e:c_orrelate`.

## Provenance

Designed in X_eTaL (`docs/spatial.md`, `docs/eq-rationale.md`: why
each sum carries its own bounds, decision D154) and written here. The
cross-correlation is the textbook definition used by CNN layers (for
example PyTorch's `Conv2d`, which documents it as cross-correlation);
the numbers in the tests were also checked by a direct four-loop
computation outside X_eTaL.
