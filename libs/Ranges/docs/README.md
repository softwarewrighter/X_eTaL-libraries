# Ranges

Ranges: macros only -- a list of stepped ranges written the way a
paper would, each bound to a name, over
[`libs/Parsing`](../../Parsing).

```
"rg:" u_se< "Ranges"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `rg:` is the
recommended alias.

X_eTaL's `r_ange` is `1..n`, nothing more: no low bound, no step.
`rg:f_or<` writes a stepped, zero-based range for each piece it is
given, as an ordinary array, so the rest of the program uses it like
any other.

## The macro

| Macro | Call | Writes |
| ----- | ---- | ------ |
| `rg:f_or<` | `@ rg:f_or< "for i:=0..10 by 2"` | `i := 0 + (2 * ((r_ange (1 + f_loor ((10 - 0) / 2))) - 1))` -- the array `0 2 4 6 8 10` |

## Grammar

```
for i:=0..10 by 2, for j:=0..9
```

- a comma-separated list, one binding per name;
- each binding is `for NAME:=LOW..HIGH`, optionally `by STEP` (1 when
  not written); `for` is the only loop word -- it exists so the
  notation reads as a sentence, nothing more;
- `NAME` is a lowercase name (a letter, then letters or digits);
- `LOW` and `HIGH` are each a bound: a number, a parenthesized chain
  of them with `+` and `-` (a leading `-` negates the first), an
  array's length (`len(A)`), or one of its elements (`A[0]`);
  `STEP` is a bare whole number.

From [`../tests/basics.xtl`](../tests/basics.xtl):

```
      "rg:" u_se< "Ranges"
      A := 0 0 0 0 0
      @ rg:f_or< "for i:=0..10 by 2"
      i
0 2 4 6 8 10
      @ rg:f_or< "for j:=0..4, for k:=0..len(A)-1"
      j
0 1 2 3 4
      k
0 1 2 3 4
      @ rg:f_or< "for m:=A[0]..A[0]+3"
      m
0 1 2 3
```

## What is checked, and when

Every reading rule uses all of its text or refuses the call under
`error[bad-range]`, when the program is compiled; what was read is
written back and compared with the text at every call
([`libs/Parsing`](../../Parsing)'s whole-text check), so nothing
written is ever dropped.

| Mistake | Example |
| ------- | ------- |
| a loop word that is not `for` | [`../tests/reject-word.xtl`](../tests/reject-word.xtl) |
| a step that is not a whole number | [`../tests/reject-step.xtl`](../tests/reject-step.xtl) |
| an operator with no value beside it | [`../tests/reject-chain.xtl`](../tests/reject-chain.xtl) |
| a bound's function that is not `len` | [`../tests/reject-function.xtl`](../tests/reject-function.xtl) |
| text left over once every piece is read | [`../tests/reject-extra.xtl`](../tests/reject-extra.xtl) |

From [`../tests/reject-word.xtl`](../tests/reject-word.xtl):

```
      @ rg:f_or< "while i:=0..10"
error[bad-range]: a binding starts with a loop variable (for) (for): while i:=0..10
```

## Limits

- No descending range: `STEP` is a bare whole number, never signed,
  so `HIGH` must not be below `LOW`.
- A bound's only function is `len`; any other name is refused
  ([`../tests/reject-function.xtl`](../tests/reject-function.xtl)), so
  a range cannot, say, bound itself by an array's maximum.

## Demos

- [`demos/sampled.xtl`](../demos/sampled.xtl): every third reading of
  a sensor log, by index (`just demo Ranges sampled`).

## Provenance

Written for this repository, as the worked example of
[`libs/Parsing/docs/guide.md`](../../Parsing/docs/guide.md) ("Writing
a notation macro with Parsing"): the guide builds this exact macro,
tool by tool; this package is it, with its own tests, demo and
catalog row. No code copied.
