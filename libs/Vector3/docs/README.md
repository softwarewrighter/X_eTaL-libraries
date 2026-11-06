# Vector3

Batched 3D vectors and rigid transforms. Import with
`"v:" u_se< "Vector3"`; Matrix is the only library dependency.
Put both source directories on `XETAL_PATH` (`just path`).

Points and directions are N by 3 Float rows (including zero rows).
A single point is a 1 by 3 matrix. Two batches must have identical
shapes; there is no implicit broadcasting. Offsets and pivots are
length-3 vectors. Numeric inputs are converted to Float. Coordinates
are right-handed xyz with y up; angles are scalar radians. Geometry's
2 by N point layout remains separate: transpose a 2D contour and add
an explicit z column before using it here.

## Vectors

| Export | Type | Result |
| ------ | ---- | ------ |
| `a v:d_ot b` | `(Num a, Num b) => a -> b -> Float` | N dot products |
| `a v:c_ross b` | `(Num a, Num b) => a -> b -> Float` | N by 3 right-handed cross products |
| `v:l_ength p` | `Num a => a -> Float` | N Euclidean lengths |
| `v:n_ormalize p` | `Num a => a -> Float` | N by 3 unit vectors; zero rows stay zero |

For `x := 2 3 r_eshape 1 0 0 3 0 4` and
`y := 2 3 r_eshape 0 1 0 0 0 0`, `x v:d_ot y` is `0.0 0.0`,
`x v:c_ross y` has rows `(0,0,1)` and `(0,0,0)`,
`v:l_ength x` is `1.0 5.0`, and `v:n_ormalize x` has rows
`(1,0,0)` and `(0.6,0,0.8)`. These cases are in `tests/basics.xtl`.

Lengths and normalization scale by the row's largest magnitude before
squaring. Normalization also handles vectors whose length would
overflow. Zero rows use a finite denominator before division. Dot and
cross use direct products; overflow is refused, rather than returned.

## Transforms

| Export | Type | Result |
| ------ | ---- | ------ |
| `v:t_ranslation offset` | `Num a => a -> Float` | 4 by 4 translation matrix |
| `v:r_otationY angle` | `Num a => a -> Float` | 4 by 4 y rotation matrix |
| `matrix v:t_ransform p` | `(Num a, Num b) => a -> b -> Float` | transformed N by 3 points |
| `offset v:t_ranslate p` | `(Num a, Num b) => a -> b -> Float` | translated N by 3 points |
| `((pivot v:r_otateY angle)_ p)` | `(Num a, Num b, Num c) => a -> b -> c -> Float` | rotated N by 3 points about pivot |

Matrices use column-vector mathematics: `T mx:m_ul R` rotates first,
then translates. The implementation multiplies homogeneous point rows
by the matrix transpose, reusing `mx:m_ul`. A positive pi/2 about y
sends `(1,0,0)` to `(0,0,-1)`. Pivot rotation uses
`T(pivot) R_y(angle) T(-pivot)`.

For `p := 1 3 r_eshape 2 3 4`, `1 2 3 v:t_ranslate p` is the row
`(3,5,7)` and `((2 3 4 v:r_otateY 0.7)_ p)` leaves p fixed.
The [pivot demo](../demos/pivot.xtl) rotates a vane point about a
fixed point. Tests also check composed transforms and full turns.

## Validation and limits

Wrong shapes, nonfinite inputs and nonfinite computed results panic
with a Vector3 diagnostic. Transform matrices must have bottom row
`(0,0,0,1)`, an orthogonal 3 by 3 rotation and determinant +1, each to
absolute tolerance 1e-10. Scaling, shear and reflections are refused.
This tolerance permits floating-point composition error; it does not
repair a malformed matrix. Points include translation; directions
should use vector functions or an origin-centered rotation.

CPU results use the pinned evaluator's Float precision. Compare
rotations with a tolerance (the tests use Check), not exact equality.
GPU lowering and its precision are the consuming repository's concern.
No language workaround, device API, macro or native code is needed.

## Provenance

Original MIT implementation from standard Euclidean dot/cross products,
scaled Euclidean norms and homogeneous rigid-transform equations.
No external implementation or renderer assets were copied.
