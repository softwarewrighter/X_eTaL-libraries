# Matrix

Matrices: identity, diagonal, trace, product, determinant, inverse,
solving linear systems, orthonormal bases and rank, projection onto a
subspace and coordinates in a basis, eigenvalues and eigenvectors of a
symmetric matrix. The transpose is X_eTaL's built-in `o_\`.

```
"mx:" u_se< "Matrix"
```

Put each library's `src/` directory on `XETAL_PATH` (`just path`
prints them; see the [README](../../../README.md)); `mx:` is the
recommended alias (`m:` is the usual letter for the standard `Maybe`).

A matrix is a rank-2 array, rows first. The numerical functions
(`mx:d_et`, `mx:i_nverse`, `mx:s_olve`) work in Floats, by Gaussian
elimination with partial pivoting; compare their results with Check's
`ch:n_ear`, not `ch:i_s`.

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
| `mx:o_rthonormal b` | `Num a => a -> Float` | an orthonormal basis of the span of `b`'s rows, as rows, one per dimension |
| `mx:r_ank b` | `Num a => a -> Int` | the dimension of the span of `b`'s rows |
| `b mx:p_roject m` | `(Num a, Num b) => a -> b -> Float` | each row of `m` (or the vector `m`) projected onto the span of `b`'s rows: its nearest point there |
| `b mx:r_emainder m` | `(Num a, Num b) => a -> b -> Float` | what is left, `m` less its projection: orthogonal to every row of `b` |
| `mx:e_igenvalues s` | `Num a => a -> Float` | the eigenvalues of the symmetric matrix `s`, largest first |
| `mx:e_igenvectors s` | `Num a => a -> Float` | its eigenvectors, one per row in the same order, unit length, each signed so its largest item is positive |
| `b mx:c_oordinates m` | `(Num a, Num b) => a -> b -> Float` | `c` with `c mx:m_ul b` equal to `m` (of its projection, for `m` outside the span), for independent rows of `b` |

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
      mx:o_rthonormal 2 3 r_eshape 3 4 0  1 1 1
                0.6                  0.8                0.0
0.15689290811054718 -0.11766968108291039 0.9805806756909201
      mx:r_ank 3 3 r_eshape 1 2 3  2 4 6  0 0 1
2
```

The first row of the basis is `(3, 4, 0)` made unit length; the second
is `(1, 1, 1)` less its part along the first, `(0.16, -0.12, 1)`, made
unit length. The rank is 2 because the second row is twice the first.

```
      (2 3 r_eshape 1 0 0  0 1 0) mx:p_roject 3 4 5
3.0 4.0 0.0
      (2 3 r_eshape 1 0 0  0 1 0) mx:r_emainder 3 4 5
0.0 0.0 5.0
      (2 2 r_eshape 1 0  1 1) mx:c_oordinates 3 5
-2.0 5.0
```

`(3, 4, 5)` projected onto the xy plane is `(3, 4, 0)`, and `(0, 0, 5)`
is left; `(3, 5)` is `-2 (1, 0) + 5 (1, 1)`.

```
      mx:e_igenvalues 2 2 r_eshape 2 1  1 2
2.9999999999999996 0.9999999999999998
      mx:e_igenvectors 2 2 r_eshape 2 1  1 2
0.7071067811865475  0.7071067811865475
0.7071067811865475 -0.7071067811865475
```

`[[2, 1], [1, 2]]` has eigenvalues 3 and 1, with eigenvectors along
`(1, 1)` and `(1, -1)`; the rows of `mx:e_igenvectors` are them, so
`s` is `(o_\ v) mx:m_ul diag(values) mx:m_ul v`.

`../tests/checks.xtl` checks the algebra with the Check library: the
transpose twice and the identity change nothing, a matrix times its
inverse is the identity, a solution solves, the determinant of a
product is the product of the determinants, of the transpose the
same, a row swap negates it, and the transpose of a product is the
product of the transposes reversed.

`../tests/subspaces.xtl` checks orthonormal bases and rank: the rows
orthonormal (`Q Q'` the identity) and spanning `b` (`b` projected onto
them is `b`), a known basis, a dependent row dropped, repeated and zero
rows, a zero first row skipped, a row `1e-12` off the span counted as
dependent and one `1e-8` off not, nearly dependent rows still giving an
orthonormal basis, a square basis of the whole space, and wide and tall
matrices.

`../tests/projection.xtl` checks projection and coordinates: projecting
twice is projecting once, the remainder is orthogonal to `b`, projection
plus remainder is `m`, a row of `b` projects to itself, a vector and a
one-row matrix agree, dependent rows of `b` and no rows at all,
coordinates that rebuild `m` in a non-orthogonal basis, and outside the
span the coordinates of the projection. It also runs the inline
projection X_eTaL-fine-tuning used before these existed (`M B' (B B')^-1
B`, by `mx:i_nverse`) as a differential test where `b` is well
conditioned (they agree), and gives the exact answer where `b`'s rows
are nearly dependent.

`../tests/eigen.xtl` checks eigenvalues and eigenvectors on matrices
built with known ones, `s = q' diag(d) q` for an orthonormal `q`: the
values largest first, the vectors up to sign and orthonormal, `s v =
lambda v` for each pair, `s` rebuilt from them, the sign rule, the sum
the trace and the product the determinant, a repeated eigenvalue, a
multiple of the identity, a diagonal matrix, 1 by 1, and a 6 by 6
rebuilt to the last digits. A matrix that is not symmetric or not
square stops (tests `panic-nonsymmetric`, `panic-nonsquare`).

## Demos

- [`demos/line-fit.xtl`](../demos/line-fit.xtl): a straight line
  through noisy points by least squares, solving the normal equations
  (`just demo Matrix`).

## Limits

- `mx:s_olve` and `mx:i_nverse` of a singular matrix stop with
  `error[panic]: the matrix is singular ...` (a pivot below 1e-12;
  test `panic-singular`); `mx:d_et` gives 0. A nearly singular matrix
  above that bound gives large, inaccurate numbers.
- Elimination runs one column at a time (a recursion per column),
  `O(n^3)` work in whole-row operations: fine for the small systems of
  teaching and demos.
- `mx:o_rthonormal` counts a row as dependent when its remainder, after
  removing its part in the span of the rows before it, is at most
  `1e-10` of the row's own length (tests: a row `1e-12` off the span is
  dropped, one `1e-8` off is kept). It is modified Gram-Schmidt with
  each remainder taken twice: on nearly dependent rows (three rows
  within `1e-7` of `(1, 1, 1)`) one pass leaves `Q Q'` off the identity
  by `0.15`, two passes by `2.2e-16`. The basis depends on the order of
  the rows: it is built in row order, so it is one basis of the span,
  not a canonical one.
- `mx:p_roject` and `mx:c_oordinates` go through the orthonormal basis
  (`m Q' Q`; `c R = m Q'` with `R = b Q'`), never inverting `b b'`. That
  inverse squares how close `b`'s rows are to dependent: with rows
  `(1, 1, 1)` and `(1, 1, 1 + d)`, projecting `(1, 0, 0)` (exactly
  `(0.5, 0.5, 0)`) by `M B' (B B')^-1 B` is off by `2.3e-10` at
  `d = 1e-3` and `6e-8` at `1e-4`, and from `1e-6` the inverse stops as
  singular; `mx:p_roject` is within `2e-16` at every `d` down to
  `1e-7` (measured at `XETAL_COMMIT`).
- `mx:c_oordinates` of rows that are dependent stops with
  `error[panic]: the rows of the basis are dependent ...` (test
  `panic-coordinates`): coordinates in them are not unique.
- `mx:e_igenvalues` and `mx:e_igenvectors` are for symmetric matrices
  only: one more than `1e-12` of its largest item from symmetric stops
  with `error[panic]` rather than being symmetrized (a non-symmetric
  matrix can have complex eigenvalues). They are cyclic Jacobi: sweeps
  of rotations, each zeroing one off-diagonal pair, until the
  off-diagonal part's length (Frobenius) is at most `1e-15` of the
  whole matrix's, or 30 sweeps (then `error[panic]: Jacobi did not
  converge`; Jacobi converges quadratically, in a handful of sweeps).
  The results are accurate to the last digits relative to the matrix:
  a 6 by 6 is rebuilt to `7e-15` on items up to 14. Each rotation is a
  full matrix applied by products, `O(n^3)` work a rotation and
  `O(n^5)` a sweep: fine to a few dozen rows (a 12 by 12 takes well
  under a second). Calling both exports runs Jacobi twice.
- With a repeated eigenvalue, the eigenvectors for it are one
  orthonormal basis of its eigenspace among many: the space is
  determined, its basis is not.
- The lengths are `sqrt(sum of squares)`, unscaled: a row past about
  `1e154` overflows when squared.
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
| `e_igenvalues`, `e_igenvectors` | the cyclic Jacobi method for the symmetric eigenproblem, with the rotation of Golub and Van Loan's *Matrix Computations* (`sym.schur2`, the smaller of the two angles); asked for by X_eTaL-fine-tuning (FL2) |
| `p_roject`, `r_emainder`, `c_oordinates` | orthogonal projection through an orthonormal basis (`Q Q'` is the projector onto the span); coordinates by the triangular system `R` of the QR factorization of `b`'s rows; asked for by X_eTaL-fine-tuning (FL3) |
| `o_rthonormal`, `r_ank` | modified Gram-Schmidt with reorthogonalization ("twice is enough": Giraud, Langou and Rozloznik, *The loss of orthogonality in the Gram-Schmidt orthogonalization process*, Computers and Mathematics with Applications 50, 2005), a rank by dropping rows within a stated tolerance; asked for by X_eTaL-fine-tuning (FL3), where X_eTaL-ML's `lo:r_ank` runs a Gram-Schmidt inside itself and keeps only the count |
