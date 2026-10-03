# Matrix

Matrices: identity, diagonal, trace, product, determinant, inverse,
solving linear systems. The transpose is X_eTaL's built-in `o_\`.

```
"mx:" u_se< "Matrix"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `mx:` is the
recommended alias (`m:` is the usual letter for the standard `Maybe`).

A matrix is a rank-2 array, rows first. The numerical functions
(`mx:d_et`, `mx:i_nverse`, `mx:s_olve`) work in Floats, by Gaussian
elimination with partial pivoting; compare their results with Check's
`k:n_ear`, not `k:i_s`.

## Functions

| Function | Type | What |
| -------- | ---- | ---- |
| `mx:i_dentity n` | `Num a => Int -> a` | the `n` by `n` identity matrix |
| `mx:d_iag m` | `a -> a` | the items on the main diagonal |
| `mx:t_race m` | `Num a => a -> a` | the sum of the diagonal |
| `a mx:m_ul b` | `Num a => a -> a -> a` | the matrix product (a vector on either side works too) |
| `mx:d_et a` | `Num a => a -> Float` | the determinant of a square matrix |
| `b mx:s_olve a` | `Num a => a -> a -> Float` | `x` with `a mx:m_ul x` equal to `b`, for a square `a`; `b` a vector or a matrix of right-hand sides |
| `mx:i_nverse a` | `Num a => a -> Float` | the inverse of a square matrix |

Both arguments of `mx:m_ul` and `mx:s_olve` have one type: multiply an
Int matrix by a Float one as `(f_loat a) mx:m_ul f`.

## Examples

From `../tests/basics.xtl`:

```
      mx:i_dentity 3
1 0 0
0 1 0
0 0 1
      a := 2 3 r_eshape r_ange 6
      a mx:m_ul o_\ a
14 32
32 77
      s := 3 3 r_eshape 2 1 1 1 3 2 1 0 0
      mx:d_et s
-0.9999999999999998
      4 5 6 mx:s_olve s
6.0 15.0 -22.999999999999993
      mx:i_nverse 2 2 r_eshape 4 7 2 6
  0.6000000000000001 -0.7000000000000001
-0.19999999999999996  0.3999999999999999
```

`../tests/checks.xtl` checks the algebra with the Check library: the
transpose twice and the identity change nothing, a matrix times its
inverse is the identity, a solution solves, the determinant of a
product is the product of the determinants, of the transpose the
same, a row swap negates it, and the transpose of a product is the
product of the transposes reversed.

## Demos

- [`demos/line-fit.xtl`](../demos/line-fit.xtl): a straight line
  through noisy points by least squares, solving the normal equations
  (`just demo Matrix`).

## Limits

- A singular matrix divides by an exact zero pivot
  (`error[division-by-zero]` from `mx:s_olve` and `mx:i_nverse`;
  `mx:d_et` gives 0); a nearly singular one gives large, inaccurate
  numbers. X_eTaL cannot raise an error of the library's own (ask X3).
- Elimination runs one column at a time (a recursion per column),
  `O(n^3)` work in whole-row operations: fine for the small systems of
  teaching and demos.
- There is no matrix divide built in (APL's domino, ask X7): the
  library solves by elimination in X_eTaL.

## Provenance

| Function | After |
| -------- | ----- |
| `i_dentity` | the APL idiom: `1` followed by `n` zeros, reshaped |
| `m_ul` | APL's `+.x` inner product |
| `s_olve`, `i_nverse` | APL's matrix divide and inverse (domino), by Gauss-Jordan elimination with partial pivoting |
| `d_et` | elimination: the product of the pivots, a sign per row swap |
| `d_iag`, `t_race` | the ravel-index idiom (every `n + 1`-th item) |
