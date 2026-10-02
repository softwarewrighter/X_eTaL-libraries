# Combinatorics

Counting and listing: factorials, binomial coefficients,
combinations, permutations, subsets, Cartesian products.

```
"cb:" u_se< "Combinatorics"
```

Put this repository's `lib/` directory on `XETAL_PATH` (see the
[README](../../README.md)); `cb:` is the recommended alias (`c:` is
the usual letter for the standard `Combinators`).

Lists come as matrices, one combination (or permutation, subset,
pair) per row, in lexicographic order, so a row is `i s_elect m` and
the count is `t_ally m`.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `cb:f_actorial n` | `Int -> Int` | `n!`, item by item (`0!` is 1) |
| `k cb:c_hoose n` | `Int -> Int -> Int` | how many ways to choose `k` of `n`, item by item, exactly |
| `k cb:c_ombinations n` | `Int -> Int -> Int` | every choice of `k` of `1..n`, one per row |
| `cb:p_ermutations n` | `Int -> Int` | every ordering of `1..n`, one per row |
| `cb:s_ubsets n` | `Int -> Int` | every subset of `1..n` as a 0/1 mask, one per row, counting in binary |
| `cb:p_owerset v` | `a -> Box a` | every subset of the items of `v`, as a list |
| `a cb:p_roduct b` | `a -> a -> a` | every pair of an item of `a` and one of `b`, one per row |

`cb:c_hoose` multiplies and divides one step at a time, so it stays
exact (and in range) long after the factorials overflow: `30 cb:c_hoose
60` is 118264581564861424, though `60!` is far past 64 bits.

## Examples

From `tests/Combinatorics/basics.xtl`:

```
      cb:f_actorial 0 1 5 10 20
1 1 120 3628800 2432902008176640000
      (o_ffsets 7) cb:c_hoose 6
1 6 15 20 15 6 1
      2 cb:c_ombinations 4
1 2
1 3
1 4
2 3
2 4
3 4
      cb:p_ermutations 3
1 2 3
1 3 2
2 1 3
2 3 1
3 1 2
3 2 1
      cb:s_ubsets 2
0 0
0 1
1 0
1 1
      1 2 cb:p_roduct 7 8 9
1 7
1 8
1 9
2 7
2 8
2 9
```

`cb:p_owerset "abc"` is the eight strings `""`, `"c"`, `"b"`, `"bc"`,
`"a"`, `"ac"`, `"ab"`, `"abc"` (as boxes).

`tests/Combinatorics/checks.xtl` checks with the Check library: the
number of rows is the count (`3 cb:c_hoose 7`, `5!`, `2^5`), rows of a
combination increase, permutations are distinct, sorted, and each is
an ordering of 1 to 5, a row of Pascal's triangle sums to `2^n`.

## Limits

- The lists grow fast: `cb:p_ermutations 8` has 40320 rows. They are
  built by recursion (one level per element) and joined from boxes.
- `cb:f_actorial` overflows past `20!` (ask X6, big numbers).
- X_eTaL has no transpose yet; the library turns `e_ncode`'s columns
  into rows with a reshape of `r_avel_2` (the Matrix library has the
  same as `mx:t_ranspose`).

## Provenance

| Function | After |
| -------- | ----- |
| `c_ombinations` | dfns `cmat` (the recursion on whether 1 is chosen) |
| `p_ermutations` | dfns `pmat` (each first element, then the permutations of the rest renumbered around it) |
| `s_ubsets`, `p_owerset` | the APL idiom of counting in binary with encode |
| `c_hoose` | the multiplicative formula, as APL's binomial (`!`) behaves |
| `p_roduct` | the replicate-and-reshape idiom for a Cartesian product |
